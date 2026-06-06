#!/usr/bin/env python3
import json
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
GAME_ROOT = REPO_ROOT / "game"
MATRIX_PATH = GAME_ROOT / "tests" / "validation_matrix.json"


def pct(numerator: int, denominator: int) -> float:
    if denominator == 0:
        return 100.0
    return (numerator / denominator) * 100.0


def res_to_path(res_path: str) -> Path:
    if not res_path.startswith("res://"):
        raise ValueError(f"Expected res:// path, got {res_path}")
    return GAME_ROOT / res_path.removeprefix("res://")


def evidence_path(evidence: str) -> str:
    return evidence.split("::", 1)[0]


def collect_production_scripts() -> set[str]:
    scripts = set()
    for path in (GAME_ROOT / "scripts").rglob("*.gd"):
        scripts.add("res://" + path.relative_to(GAME_ROOT).as_posix())
    return scripts


def main() -> int:
    failures: list[str] = []
    data = json.loads(MATRIX_PATH.read_text())
    thresholds = data["thresholds"]

    active_scenarios = [
        item for item in data["ui_scenarios"]
        if item["status"] != "not_applicable"
    ]
    automated_scenarios = [
        item for item in active_scenarios
        if item["status"] == "automated"
    ]
    ui_percent = pct(len(automated_scenarios), len(active_scenarios))
    ui_threshold = float(thresholds["ui_automation_percent"])
    if ui_percent < ui_threshold:
        failures.append(
            f"UI automation coverage {ui_percent:.1f}% is below {ui_threshold:.1f}%"
        )

    for item in active_scenarios:
        status = item["status"]
        if status not in {"automated", "manual"}:
            failures.append(f"{item['id']} has invalid status {status}")
        if item.get("critical") and status != "automated":
            failures.append(f"critical UI scenario {item['id']} must be automated")
        if status == "automated":
            evidence = item.get("evidence", "")
            if not evidence:
                failures.append(f"automated UI scenario {item['id']} lacks evidence")
            else:
                path = res_to_path(evidence_path(evidence))
                if not path.exists():
                    failures.append(f"evidence for UI scenario {item['id']} is missing: {evidence}")
        if status == "manual":
            if not item.get("reason") or not item.get("owner"):
                failures.append(f"manual UI scenario {item['id']} needs reason and owner")

    production_scripts = collect_production_scripts()
    mapped_scripts = {item["script"] for item in data["script_tests"]}
    missing_entries = sorted(production_scripts - mapped_scripts)
    extra_entries = sorted(mapped_scripts - production_scripts)
    for script in missing_entries:
        failures.append(f"production script missing from script_tests: {script}")
    for script in extra_entries:
        failures.append(f"script_tests entry does not exist: {script}")

    covered_scripts = []
    for item in data["script_tests"]:
        tests = item.get("tests", [])
        existing_tests = [test for test in tests if res_to_path(test).exists()]
        if existing_tests:
            covered_scripts.append(item["script"])
        elif item.get("critical"):
            failures.append(f"critical script lacks an existing automated test: {item['script']}")

    script_percent = pct(len(set(covered_scripts)), len(production_scripts))
    script_threshold = float(thresholds["script_test_mapping_percent"])
    if script_percent < script_threshold:
        failures.append(
            f"script test mapping coverage {script_percent:.1f}% is below {script_threshold:.1f}%"
        )

    print(f"UI automation coverage: {len(automated_scenarios)}/{len(active_scenarios)} = {ui_percent:.1f}%")
    print(f"Script test mapping coverage: {len(set(covered_scripts))}/{len(production_scripts)} = {script_percent:.1f}%")

    if failures:
        for failure in failures:
            print(f"ERROR: {failure}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
