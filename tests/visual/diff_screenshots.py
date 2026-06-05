#!/usr/bin/env python3
"""Compare store visual sweep captures against optional golden baselines."""

from __future__ import annotations

import argparse
import json
import math
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

try:
    from PIL import Image
except ImportError as exc:
    raise SystemExit("Pillow is required: python3 -m pip install pillow") from exc


REQUIRED_FIRST_TEN_SECONDS_FILENAMES = [
    "01_spawn_first_look.png",
    "02_checkout_manager_counter.png",
    "03_shelf_wall_product_focus.png",
    "04_stockroom_looking_in.png",
    "05_stockroom_work_area_interior.png",
    "06_starter_stocked_opening_review.png",
    "07_checkout_close_day.png",
    "08_exit_threshold_return_view.png",
]
REQUIRED_OVERHAUL_ACCEPTANCE_FILENAMES = [
    "09_build_design_tool.png",
    "10_stocked_shelf_state.png",
    "11_shelf_after_sale_gap.png",
    "12_checkout_transaction_active.png",
    "13_register_trade_in_no_sale.png",
    "14_customer_queue_state.png",
    "15_customization_featured_display.png",
    "16_stockroom_inventory_state.png",
    "17_growth_expansion_preview.png",
    "18_lighting_balance_review.png",
    "19_decision_panels_work_surface_balance.png",
]
REQUIRED_FILENAMES = REQUIRED_FIRST_TEN_SECONDS_FILENAMES
NOISE_FLOOR = 3
CHANGED_RATIO_WARN = 0.0025
CHANGED_RATIO_FAIL = 0.01
MAE_WARN = 0.75
MAE_FAIL = 2.0
MAX_DELTA_FAIL = 96
MIN_LUMINANCE_STDDEV = 2.0
MAX_NEAR_SOLID_RATIO = 0.98


@dataclass
class Thresholds:
    noise_floor: int = NOISE_FLOOR
    changed_ratio_warn: float = CHANGED_RATIO_WARN
    changed_ratio_fail: float = CHANGED_RATIO_FAIL
    mae_warn: float = MAE_WARN
    mae_fail: float = MAE_FAIL
    max_delta_fail: int = MAX_DELTA_FAIL
    min_luminance_stddev: float = MIN_LUMINANCE_STDDEV
    max_near_solid_ratio: float = MAX_NEAR_SOLID_RATIO


def main() -> int:
    args = parse_args()
    current_dir = args.current
    diff_dir = args.diff
    diff_dir.mkdir(parents=True, exist_ok=True)
    thresholds = Thresholds()
    review_manifest = load_json(args.review_manifest)
    required_filenames = required_filenames_for_suite(args.suite)
    results: list[dict[str, Any]] = []

    for filename in required_filenames:
        current_path = current_dir / filename
        validation = validate_current_capture(
            current_path,
            filename,
            args.width,
            args.height,
            review_manifest,
            thresholds,
        )
        results.append(validation)

    current_ok = all(result["status"] != "fail" for result in results)
    baseline_dir = args.baseline
    baselines_present = baseline_dir.exists()
    mode = "diff" if baselines_present else "baseline_missing"
    missing_baselines: list[str] = []

    if not baselines_present:
        if not args.allow_missing_baseline:
            results.append(failure_result("baseline_dir", f"Missing baseline directory: {baseline_dir}"))
        write_manifest(
            args.manifest,
            mode,
            args,
            thresholds,
            results,
            missing_baselines,
            required_filenames,
        )
        if current_ok and args.allow_missing_baseline:
            print(f"Store visual baselines missing; current captures are ready for review: {current_dir}")
            return 0
        return 1

    for filename in required_filenames:
        baseline_path = baseline_dir / filename
        current_path = current_dir / filename
        if not baseline_path.exists():
            missing_baselines.append(filename)
            results.append(failure_result(filename, f"Missing baseline image: {baseline_path}"))
            continue
        if not current_path.exists():
            continue
        results.append(compare_images(baseline_path, current_path, diff_dir / f"{filename}.diff.png", thresholds))

    extra_current = sorted(
        path.name for path in current_dir.glob("*.png") if path.name not in required_filenames
    )
    extra_baseline = sorted(
        path.name for path in baseline_dir.glob("*.png") if path.name not in required_filenames
    )
    manifest = write_manifest(
        args.manifest,
        mode,
        args,
        thresholds,
        results,
        missing_baselines,
        required_filenames,
        extra_current,
        extra_baseline,
    )
    if manifest["ok"]:
        print(f"Store visual sweep diff passed: {args.manifest}")
        return 0
    print(f"Store visual sweep diff failed: {args.manifest}")
    return 1


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--current", type=Path, required=True)
    parser.add_argument("--diff", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--review-manifest", type=Path)
    parser.add_argument("--width", type=int, default=1280)
    parser.add_argument("--height", type=int, default=720)
    parser.add_argument(
        "--suite",
        choices=["first-ten-seconds", "overhaul-acceptance"],
        default="first-ten-seconds",
    )
    parser.add_argument("--allow-missing-baseline", action="store_true")
    args = parser.parse_args()
    if args.review_manifest is None:
        args.review_manifest = args.current.parent / "review_manifest.json"
    return args


def required_filenames_for_suite(suite: str) -> list[str]:
    if suite == "overhaul-acceptance":
        return REQUIRED_OVERHAUL_ACCEPTANCE_FILENAMES
    return REQUIRED_FIRST_TEN_SECONDS_FILENAMES


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    with path.open("r", encoding="utf-8") as handle:
        parsed = json.load(handle)
    if isinstance(parsed, dict):
        return parsed
    return {}


def validate_current_capture(
    path: Path,
    filename: str,
    expected_width: int,
    expected_height: int,
    review_manifest: dict[str, Any],
    thresholds: Thresholds,
) -> dict[str, Any]:
    if not path.exists():
        return failure_result(filename, f"Missing current capture: {path}")
    manifest_capture = capture_manifest_row(review_manifest, filename)
    if manifest_capture.get("placeholder") is True:
        return failure_result(filename, f"Placeholder capture rejected: {filename}")
    metadata_failure = validate_capture_metadata(manifest_capture, filename)
    if metadata_failure is not None:
        return metadata_failure
    try:
        image = Image.open(path).convert("RGB")
    except OSError as exc:
        return failure_result(filename, f"Cannot read capture {path}: {exc}")
    width, height = image.size
    if width != expected_width or height != expected_height:
        return failure_result(
            filename,
            f"Wrong dimensions: got {width}x{height}, expected {expected_width}x{expected_height}",
            width,
            height,
        )
    blank = blankness_metrics(image)
    if blank["luminance_stddev"] < thresholds.min_luminance_stddev:
        return failure_result(filename, "Capture is near-blank", width, height, blank)
    if blank["near_black_ratio"] > thresholds.max_near_solid_ratio:
        return failure_result(filename, "Capture is near-black", width, height, blank)
    if blank["near_white_ratio"] > thresholds.max_near_solid_ratio:
        return failure_result(filename, "Capture is near-white", width, height, blank)
    return {
        "filename": filename,
        "status": "pass",
        "phase": "capture_validation",
        "width": width,
        "height": height,
        "placeholder": bool(manifest_capture.get("placeholder", False)),
        "blankness": blank,
    }


def validate_capture_metadata(
    manifest_capture: dict[str, Any],
    filename: str,
) -> dict[str, Any] | None:
    required_text_fields = [
        "beat",
        "active_route_stage",
        "active_prompt",
        "next_expected_beat",
        "local_action",
        "next_destination",
        "visual_scope_mode",
        "primary_work_surface_target",
    ]
    if not manifest_capture:
        return failure_result(filename, "Capture missing from review manifest")
    for field in required_text_fields:
        if not str(manifest_capture.get(field, "")).strip():
            return failure_result(filename, f"Capture metadata missing {field}")
    if manifest_capture.get("non_acceptance_evidence") is True:
        return failure_result(filename, "Capture marked as non-acceptance evidence")
    contract_failure = validate_review_manifest_contract(manifest_capture, filename)
    if contract_failure is not None:
        return contract_failure
    closeout_failure = validate_inspiration_closeout(manifest_capture, filename)
    if closeout_failure is not None:
        return closeout_failure
    anchor_validation = manifest_capture.get("anchor_validation", {})
    if not isinstance(anchor_validation, dict) or anchor_validation.get("ok") is not True:
        return failure_result(filename, "Capture did not validate intended visual anchors")
    action_context_validation = manifest_capture.get("action_context_validation", {})
    if not isinstance(action_context_validation, dict) or action_context_validation.get("ok") is not True:
        return failure_result(filename, "Capture did not validate unambiguous action context")
    debug_validation = manifest_capture.get("debug_ui_validation", {})
    if not isinstance(debug_validation, dict) or debug_validation.get("ok") is not True:
        return failure_result(filename, "Capture did not validate editor/debug UI absence")
    image_validation = manifest_capture.get("image_validation", {})
    if isinstance(image_validation, dict) and image_validation.get("ok") is False:
        return failure_result(filename, "Capture image validation failed")
    return None


def validate_review_manifest_contract(
    manifest_capture: dict[str, Any],
    filename: str,
) -> dict[str, Any] | None:
    contract = manifest_capture.get("review_manifest_contract", {})
    if not isinstance(contract, dict) or not contract:
        return failure_result(filename, "Capture metadata missing review_manifest_contract")
    required_fields = [
        "route_target",
        "anchors",
        "visual_scope_mode",
        "inspiration_cluster",
        "baseline_policy",
        "blank_wall_dominance",
        "work_surface_dominance",
        "disconnected_prop_dominance",
        "route_obstruction",
        "ui_clipping",
        "originality_notes",
        "capture_resolution_validity",
    ]
    for field in required_fields:
        value = contract.get(field)
        if value is None or value == "" or value == []:
            return failure_result(filename, f"Capture review manifest contract missing {field}")
    if contract.get("anchors") != manifest_capture.get("anchor_validation", {}).get("visible"):
        visible = manifest_capture.get("anchor_validation", {}).get("visible", [])
        declared = contract.get("anchors", [])
        if not isinstance(visible, list) or not set(declared).issubset(set(visible)):
            return failure_result(filename, "Capture review manifest anchors do not match validation")
    if str(contract.get("capture_resolution_validity", "")) != "must_match_1280x720":
        return failure_result(filename, "Capture review manifest has invalid resolution policy")
    return None


def validate_inspiration_closeout(
    manifest_capture: dict[str, Any],
    filename: str,
) -> dict[str, Any] | None:
    closeout = manifest_capture.get("inspiration_closeout", {})
    if not isinstance(closeout, dict) or not closeout:
        return failure_result(filename, "Capture metadata missing inspiration_closeout")
    clusters = closeout.get("reference_clusters", [])
    if not isinstance(clusters, list) or not clusters:
        return failure_result(filename, "Capture metadata missing reference cluster")
    for cluster in clusters:
        if not isinstance(cluster, dict):
            return failure_result(filename, "Capture reference cluster must be an object")
        if not str(cluster.get("id", "")).strip() or not str(cluster.get("label", "")).strip():
            return failure_result(filename, "Capture reference cluster missing id or label")
    if not str(closeout.get("mallcore_original_adaptation", "")).strip():
        return failure_result(filename, "Capture metadata missing original adaptation")
    if not str(closeout.get("intended_pattern_validation", "")).strip():
        return failure_result(filename, "Capture metadata missing pattern validation intent")
    required_commands = closeout.get("required_originality_commands", [])
    for command in [
        "bash scripts/validate_originality.sh",
        "bash tests/validate_original_content.sh",
    ]:
        if command not in required_commands:
            return failure_result(filename, f"Capture metadata missing originality command: {command}")
    policy = closeout.get("source_policy", {})
    if not isinstance(policy, dict) or policy.get("allowed_use") != "pattern_reference_only":
        return failure_result(filename, "Capture metadata missing pattern-reference source policy")
    return None


def capture_manifest_row(review_manifest: dict[str, Any], filename: str) -> dict[str, Any]:
    captures = review_manifest.get("captures", [])
    if not isinstance(captures, list):
        return {}
    for capture in captures:
        if isinstance(capture, dict) and capture.get("filename") == filename:
            return capture
    return {}


def blankness_metrics(image: Image.Image) -> dict[str, float]:
    pixels = list(image.getdata())
    total = len(pixels)
    if total == 0:
        return {"luminance_stddev": 0.0, "near_black_ratio": 1.0, "near_white_ratio": 0.0}
    luminance = [(r * 0.2126) + (g * 0.7152) + (b * 0.0722) for r, g, b in pixels]
    mean = sum(luminance) / total
    variance = sum((value - mean) ** 2 for value in luminance) / total
    near_black = sum(1 for value in luminance if value <= 8.0)
    near_white = sum(1 for value in luminance if value >= 247.0)
    return {
        "luminance_stddev": math.sqrt(variance),
        "near_black_ratio": near_black / total,
        "near_white_ratio": near_white / total,
    }


def compare_images(
    baseline_path: Path,
    current_path: Path,
    diff_path: Path,
    thresholds: Thresholds,
) -> dict[str, Any]:
    baseline = Image.open(baseline_path).convert("RGB")
    current = Image.open(current_path).convert("RGB")
    width, height = current.size
    if baseline.size != current.size:
        return failure_result(
            current_path.name,
            f"Dimension mismatch: baseline {baseline.size}, current {current.size}",
            width,
            height,
        )

    changed_count = 0
    max_delta = 0
    absolute_sum = 0
    heatmap = Image.new("RGBA", current.size, (0, 0, 0, 0))
    heat_pixels = heatmap.load()
    baseline_pixels = baseline.load()
    current_pixels = current.load()

    for y in range(height):
        for x in range(width):
            br, bg, bb = baseline_pixels[x, y]
            cr, cg, cb = current_pixels[x, y]
            dr = abs(cr - br)
            dg = abs(cg - bg)
            db = abs(cb - bb)
            pixel_delta = max(dr, dg, db)
            absolute_sum += dr + dg + db
            max_delta = max(max_delta, pixel_delta)
            if pixel_delta > thresholds.noise_floor:
                changed_count += 1
                heat_pixels[x, y] = (255, max(0, 255 - pixel_delta), 0, min(255, 80 + pixel_delta))

    diff_path.parent.mkdir(parents=True, exist_ok=True)
    heatmap.save(diff_path)
    pixel_count = width * height
    changed_ratio = changed_count / pixel_count
    mae = absolute_sum / (pixel_count * 3)
    status = "pass"
    failures: list[str] = []
    warnings: list[str] = []
    if changed_ratio > thresholds.changed_ratio_fail:
        failures.append("changed_ratio")
    elif changed_ratio > thresholds.changed_ratio_warn:
        warnings.append("changed_ratio")
    if mae > thresholds.mae_fail:
        failures.append("mean_absolute_error")
    elif mae > thresholds.mae_warn:
        warnings.append("mean_absolute_error")
    if max_delta > thresholds.max_delta_fail and changed_ratio > thresholds.changed_ratio_warn:
        failures.append("max_delta")
    if failures:
        status = "fail"
    elif warnings:
        status = "warn"
    return {
        "filename": current_path.name,
        "status": status,
        "phase": "pixel_diff",
        "width": width,
        "height": height,
        "changed_count": changed_count,
        "changed_ratio": changed_ratio,
        "mae": mae,
        "max_delta": max_delta,
        "diff_image": str(diff_path),
        "warnings": warnings,
        "failures": failures,
    }


def failure_result(
    filename: str,
    error: str,
    width: int = 0,
    height: int = 0,
    details: dict[str, Any] | None = None,
) -> dict[str, Any]:
    result: dict[str, Any] = {
        "filename": filename,
        "status": "fail",
        "width": width,
        "height": height,
        "error": error,
    }
    if details:
        result["details"] = details
    return result


def write_manifest(
    path: Path,
    mode: str,
    args: argparse.Namespace,
    thresholds: Thresholds,
    results: list[dict[str, Any]],
    missing_baselines: list[str],
    required_filenames: list[str],
    extra_current: list[str] | None = None,
    extra_baseline: list[str] | None = None,
) -> dict[str, Any]:
    ok = all(result.get("status") != "fail" for result in results)
    payload: dict[str, Any] = {
        "ok": ok,
        "mode": mode,
        "suite": args.suite,
        "baseline_dir": str(args.baseline),
        "current_dir": str(args.current),
        "diff_dir": str(args.diff),
        "required_filenames": required_filenames,
        "thresholds": asdict(thresholds),
        "missing_baselines": missing_baselines,
        "extra_current": extra_current or [],
        "extra_baseline": extra_baseline or [],
        "results": results,
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)
        handle.write("\n")
    return payload


if __name__ == "__main__":
    sys.exit(main())
