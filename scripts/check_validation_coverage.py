#!/usr/bin/env python3
import json
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
GAME_ROOT = REPO_ROOT / "game"
VALIDATION_ROOT = GAME_ROOT / "tests" / "validation"
THRESHOLDS_PATH = VALIDATION_ROOT / "thresholds.json"
SCENARIOS_ROOT = VALIDATION_ROOT / "scenarios"
SCRIPT_COVERAGE_ROOT = VALIDATION_ROOT / "script_coverage"
TOOL_CHECKS_ROOT = VALIDATION_ROOT / "tool_checks"


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


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        raise ValueError(f"{path.relative_to(REPO_ROOT)} is invalid JSON: {exc}") from exc


def load_validation_data() -> dict:
    if not THRESHOLDS_PATH.exists():
        raise ValueError(f"Missing validation thresholds file: {THRESHOLDS_PATH.relative_to(REPO_ROOT)}")

    data = {
        "thresholds": load_json(THRESHOLDS_PATH),
        "ui_scenarios": [],
        "script_tests": [],
        "validation_tools": [],
    }

    scenario_files = sorted(SCENARIOS_ROOT.glob("*.json"))
    if not scenario_files:
        raise ValueError(f"No validation scenario files found in {SCENARIOS_ROOT.relative_to(REPO_ROOT)}")

    for path in scenario_files:
        file_data = load_json(path)
        scenarios = file_data.get("ui_scenarios")
        if not isinstance(scenarios, list):
            raise ValueError(f"{path.relative_to(REPO_ROOT)} must contain ui_scenarios list")
        data["ui_scenarios"].extend(scenarios)

    script_files = sorted(SCRIPT_COVERAGE_ROOT.glob("*.json"))
    if not script_files:
        raise ValueError(f"No script coverage files found in {SCRIPT_COVERAGE_ROOT.relative_to(REPO_ROOT)}")

    for path in script_files:
        file_data = load_json(path)
        script_tests = file_data.get("script_tests")
        if not isinstance(script_tests, list):
            raise ValueError(f"{path.relative_to(REPO_ROOT)} must contain script_tests list")
        data["script_tests"].extend(script_tests)

    if TOOL_CHECKS_ROOT.exists():
        for path in sorted(TOOL_CHECKS_ROOT.glob("*.json")):
            file_data = load_json(path)
            validation_tools = file_data.get("validation_tools")
            if not isinstance(validation_tools, list):
                raise ValueError(f"{path.relative_to(REPO_ROOT)} must contain validation_tools list")
            data["validation_tools"].extend(validation_tools)

    return data


def main() -> int:
    failures: list[str] = []
    try:
        data = load_validation_data()
    except ValueError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

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

    scenario_ids = [item["id"] for item in data["ui_scenarios"]]
    duplicate_scenario_ids = sorted({
        scenario_id for scenario_id in scenario_ids
        if scenario_ids.count(scenario_id) > 1
    })
    for scenario_id in duplicate_scenario_ids:
        failures.append(f"duplicate UI scenario id: {scenario_id}")

    production_scripts = collect_production_scripts()
    mapped_scripts = {item["script"] for item in data["script_tests"]}
    script_entries = [item["script"] for item in data["script_tests"]]
    duplicate_script_entries = sorted({
        script for script in script_entries
        if script_entries.count(script) > 1
    })
    for script in duplicate_script_entries:
        failures.append(f"duplicate script_tests entry: {script}")

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

    tool_ids = [item["id"] for item in data["validation_tools"]]
    duplicate_tool_ids = sorted({
        tool_id for tool_id in tool_ids
        if tool_ids.count(tool_id) > 1
    })
    for tool_id in duplicate_tool_ids:
        failures.append(f"duplicate validation tool id: {tool_id}")

    active_tools = [
        item for item in data["validation_tools"]
        if item.get("status") != "retired"
    ]
    for item in active_tools:
        status = item.get("status")
        if status != "active":
            failures.append(f"validation tool {item.get('id', '<missing>')} has invalid status {status}")
        command = item.get("command", "")
        if not command:
            failures.append(f"validation tool {item.get('id', '<missing>')} lacks command")
        else:
            command_path = REPO_ROOT / command.split()[0]
            if not command_path.exists():
                failures.append(f"validation tool {item.get('id', '<missing>')} command is missing: {command}")
        covered_paths = item.get("covered_paths", [])
        if not covered_paths:
            failures.append(f"validation tool {item.get('id', '<missing>')} needs covered_paths")
        for covered_path in covered_paths:
            path = REPO_ROOT / covered_path
            if not path.exists():
                failures.append(f"validation tool {item.get('id', '<missing>')} covered path is missing: {covered_path}")
        if not item.get("requirements"):
            failures.append(f"validation tool {item.get('id', '<missing>')} needs requirements")

    print(f"UI automation coverage: {len(automated_scenarios)}/{len(active_scenarios)} = {ui_percent:.1f}%")
    print(f"Script test mapping coverage: {len(set(covered_scripts))}/{len(production_scripts)} = {script_percent:.1f}%")
    print(f"Validation tool manifests: {len(active_tools)} active")

    if failures:
        for failure in failures:
            print(f"ERROR: {failure}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
