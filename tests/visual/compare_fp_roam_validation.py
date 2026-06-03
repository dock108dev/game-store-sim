#!/usr/bin/env python3
"""Create side-by-side control/candidate panels for FP roam validation."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--control", required=True, type=Path)
    parser.add_argument("--candidate", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument(
        "--common-only",
        action="store_true",
        help="Compare only filenames present in both manifests for archived phase deltas.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    control_manifest = read_manifest(args.control.parent / "review_manifest.json")
    candidate_manifest = read_manifest(args.candidate.parent / "review_manifest.json")
    required = required_filenames(control_manifest, candidate_manifest, args.common_only)
    args.out.mkdir(parents=True, exist_ok=True)

    results: list[dict] = []
    for filename in required:
        control_path = args.control / filename
        candidate_path = args.candidate / filename
        row = {
            "filename": filename,
            "control_exists": control_path.exists(),
            "candidate_exists": candidate_path.exists(),
            "side_by_side": "",
        }
        if control_path.exists() and candidate_path.exists():
            out_path = args.out / filename
            make_pair(control_path, candidate_path, out_path)
            row["side_by_side"] = str(out_path)
        results.append(row)

    contact_sheet_path = args.out / "contact_sheet.png"
    contact_sheet = make_contact_sheet(results, contact_sheet_path)
    payload = {
        "ok": bool(results) and all(
            r["control_exists"] and r["candidate_exists"] for r in results
        ),
        "control_dir": str(args.control),
        "candidate_dir": str(args.candidate),
        "side_by_side_dir": str(args.out),
        "contact_sheet": str(contact_sheet) if contact_sheet else "",
        "comparison_count": sum(1 for r in results if r["side_by_side"]),
        "common_only": args.common_only,
        "results": results,
    }
    if not results:
        payload["error"] = "No common captures found." if args.common_only else "No captures found."
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    if payload["ok"]:
        print(f"FP roam side-by-side comparison ready: {args.out}")
        return 0
    print(f"FP roam comparison has missing captures: {args.manifest}")
    return 1


def read_manifest(path: Path) -> dict:
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def required_filenames(
    control_manifest: dict, candidate_manifest: dict, common_only: bool
) -> list[str]:
    control_names = manifest_filenames(control_manifest)
    candidate_names = manifest_filenames(candidate_manifest)
    if common_only:
        return [name for name in control_names if name in candidate_names]
    names: list[str] = []
    for filename in [*control_names, *candidate_names]:
        if filename and filename not in names:
            names.append(filename)
    return names


def manifest_filenames(manifest: dict) -> list[str]:
    names: list[str] = []
    for key in ["beats", "captures"]:
        for row in manifest.get(key, []):
            filename = str(row.get("filename", "")).strip()
            if filename and filename not in names:
                names.append(filename)
    return names


def make_pair(control_path: Path, candidate_path: Path, out_path: Path) -> None:
    control = Image.open(control_path).convert("RGB")
    candidate = Image.open(candidate_path).convert("RGB")
    width = max(control.width, candidate.width)
    height = max(control.height, candidate.height)
    header = 34
    canvas = Image.new("RGB", (width * 2, height + header), (22, 20, 18))
    canvas.paste(control, (0, header))
    canvas.paste(candidate, (width, header))
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.load_default()
    draw.text((12, 10), "CONTROL", fill=(245, 232, 210), font=font)
    draw.text((width + 12, 10), "CANDIDATE", fill=(245, 232, 210), font=font)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out_path)


def make_contact_sheet(results: list[dict], out_path: Path) -> Path | None:
    pair_paths = [
        Path(str(row["side_by_side"]))
        for row in results
        if str(row.get("side_by_side", "")).strip()
    ]
    pair_paths = [path for path in pair_paths if path.exists()]
    if not pair_paths:
        return None

    font = ImageFont.load_default()
    header = 24
    max_width = 1280
    tiles: list[Image.Image] = []
    for pair_path in pair_paths:
        image = Image.open(pair_path).convert("RGB")
        if image.width > max_width:
            new_height = round(image.height * (max_width / image.width))
            image = image.resize((max_width, new_height), Image.Resampling.LANCZOS)
        tile = Image.new("RGB", (image.width, image.height + header), (22, 20, 18))
        tile.paste(image, (0, header))
        draw = ImageDraw.Draw(tile)
        draw.text((12, 7), pair_path.name, fill=(245, 232, 210), font=font)
        tiles.append(tile)

    sheet_width = max(tile.width for tile in tiles)
    sheet_height = sum(tile.height for tile in tiles)
    sheet = Image.new("RGB", (sheet_width, sheet_height), (14, 13, 12))
    y = 0
    for tile in tiles:
        sheet.paste(tile, (0, y))
        y += tile.height
    out_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out_path)
    return out_path


if __name__ == "__main__":
    raise SystemExit(main())
