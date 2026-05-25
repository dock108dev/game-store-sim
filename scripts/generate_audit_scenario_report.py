#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
import time
from pathlib import Path
from typing import Any

from audit_report_writers import (
    STATUS_FAIL,
    STATUS_KNOWN_FAIL,
    STATUS_MISSING,
    STATUS_PASS,
    STATUS_SKIPPED,
    write_json,
    write_junit,
    write_markdown,
)

PASS_RE = re.compile(r"^AUDIT: PASS ([A-Za-z0-9_]+)(?:\s+(.*))?$")
FAIL_RE = re.compile(r"^AUDIT: FAIL ([A-Za-z0-9_]+)(?:\s+(.*))?$")
AUTOMATION_RE = re.compile(r"^AUTOMATION: (\{.*\})$")
SCENARIO_FAIL_RE = re.compile(r"^SCENARIO: FAIL code=(\d+) name=([^ ]+) message=(.*?) context=(.*)$")
SCENARIO_EXIT_RE = re.compile(r"^SCENARIO: EXIT code=(\d+) failures=(\d+)(?: context=(.*))?$")
EVENT_RE = re.compile(r"^\[([A-Z_]+)\] (.*)$")
SCREENSHOT_RE = re.compile(r"([A-Za-z0-9_./:-]+\.(?:png|jpg|jpeg|webp))")
ASSERTS_RE = re.compile(r"^Asserts\s+(\d+)\s*$")
TESTS_RE = re.compile(r"^Tests\s+(\d+)\s*$")
PASSING_RE = re.compile(r"^\s+Passing\s+(\d+)\s*$")
FAILING_RE = re.compile(r"^\s+Failing\s+(\d+)\s*$")

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate scenario reports from canonical AuditLog output."
    )
    parser.add_argument("--audit-log", required=True)
    parser.add_argument("--artifact-root", required=True)
    parser.add_argument("--required-file", required=True)
    parser.add_argument("--known-fail-file", default="")
    parser.add_argument("--metadata-file", default="")
    parser.add_argument("--scenario-id", default="runtime_audit")
    parser.add_argument("--seed", default="")
    return parser.parse_args()

def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()

def strip_manifest(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        raise FileNotFoundError(f"manifest not found: {path}")
    entries: list[dict[str, str]] = []
    for raw_line in read_lines(path):
        line = raw_line.split("#", 1)[0].strip()
        if not line:
            continue
        status = ""
        checkpoint = line
        if line.lower().startswith("skip "):
            status = STATUS_SKIPPED
            checkpoint = line.split(None, 1)[1].strip()
        elif line.lower().startswith("known_fail "):
            status = STATUS_KNOWN_FAIL
            checkpoint = line.split(None, 1)[1].strip()
        entries.append({"id": checkpoint, "status": status})
    return entries


def load_known_fail(path_text: str) -> set[str]:
    if not path_text:
        return set()
    path = Path(path_text)
    if not path.exists():
        return set()
    return {entry["id"] for entry in strip_manifest(path)}

def load_metadata(path_text: str, warnings: list[str]) -> dict[str, dict[str, Any]]:
    if not path_text:
        warnings.append("metadata_file_not_configured")
        return {}
    path = Path(path_text)
    if not path.exists():
        warnings.append(f"metadata_file_missing:{path}")
        return {}
    with path.open("r", encoding="utf-8") as file:
        parsed = json.load(file)
    if not isinstance(parsed, dict):
        warnings.append(f"metadata_file_not_object:{path}")
        return {}
    metadata: dict[str, dict[str, Any]] = {}
    for key, value in parsed.items():
        if isinstance(value, dict):
            metadata[str(key)] = value
        else:
            warnings.append(f"metadata_entry_not_object:{key}")
    return metadata


def default_metadata(checkpoint: str, scenario_id: str, warnings: list[str]) -> dict[str, Any]:
    warnings.append(f"metadata_missing:{checkpoint}")
    title = checkpoint.replace("_", " ").title()
    return {
        "title": title,
        "suite": "runtime_audit",
        "scenario": scenario_id,
        "requirement": "",
        "severity": "normal",
        "owner": "unowned",
        "required": True,
        "junit_classname": "Mallcore.RuntimeAudit.Unassigned",
        "source": "",
        "test": "",
        "expected_events": [],
    }


def metadata_for(
    checkpoint: str,
    metadata: dict[str, dict[str, Any]],
    scenario_id: str,
    warnings: list[str],
) -> dict[str, Any]:
    base = default_metadata(checkpoint, scenario_id, warnings)
    if checkpoint not in metadata:
        return base
    warnings.pop()
    merged = dict(base)
    merged.update(metadata[checkpoint])
    return merged


def parse_log(path: Path) -> dict[str, Any]:
    passes: dict[str, list[dict[str, Any]]] = {}
    failures: dict[str, list[dict[str, Any]]] = {}
    events: list[dict[str, Any]] = []
    scenario_failures: list[dict[str, Any]] = []
    scenario_exit: dict[str, Any] = {}
    screenshots: list[str] = []
    automation: dict[str, Any] = {}
    assertion_counts = {"tests": 0, "passing": 0, "failing": 0, "asserts": 0}

    for index, line in enumerate(read_lines(path)):
        if match := PASS_RE.match(line):
            passes.setdefault(match.group(1), []).append(
                {"detail": match.group(2) or "", "line": index + 1, "raw": line}
            )
            continue
        if match := FAIL_RE.match(line):
            failures.setdefault(match.group(1), []).append(
                {"reason": match.group(2) or "", "line": index + 1, "raw": line}
            )
            continue
        if match := EVENT_RE.match(line):
            events.append({"tag": f"[{match.group(1)}]", "raw": line, "line": index + 1})
        if match := AUTOMATION_RE.match(line):
            parsed = parse_json_object(match.group(1))
            if parsed:
                automation.update(parsed)
        if match := SCENARIO_FAIL_RE.match(line):
            scenario_failures.append(
                {
                    "code": int(match.group(1)),
                    "name": match.group(2),
                    "message": match.group(3),
                    "context": parse_json_object(match.group(4)),
                    "line": index + 1,
                    "raw": line,
                }
            )
        if match := SCENARIO_EXIT_RE.match(line):
            scenario_exit = {
                "code": int(match.group(1)),
                "failures": int(match.group(2)),
                "context": parse_json_object(match.group(3) or "{}"),
                "line": index + 1,
                "raw": line,
            }
        if "screenshot" in line.lower():
            for screenshot in SCREENSHOT_RE.findall(line):
                if screenshot not in screenshots:
                    screenshots.append(screenshot)
        update_counts(assertion_counts, line)

    return {
        "passes": passes,
        "failures": failures,
        "events": events,
        "scenario_failures": scenario_failures,
        "scenario_exit": scenario_exit,
        "screenshots": screenshots,
        "automation": automation,
        "assertion_counts": assertion_counts,
    }


def parse_json_object(text: str) -> dict[str, Any]:
    try:
        parsed = json.loads(text)
    except json.JSONDecodeError:
        return {}
    return parsed if isinstance(parsed, dict) else {}


def update_counts(counts: dict[str, int], line: str) -> None:
    if match := TESTS_RE.match(line):
        counts["tests"] = int(match.group(1))
    elif match := PASSING_RE.match(line):
        counts["passing"] = int(match.group(1))
    elif match := FAILING_RE.match(line):
        counts["failing"] = int(match.group(1))
    elif match := ASSERTS_RE.match(line):
        counts["asserts"] = int(match.group(1))


def build_records(
    required_entries: list[dict[str, str]],
    known_fail: set[str],
    metadata: dict[str, dict[str, Any]],
    parsed_log: dict[str, Any],
    scenario_id: str,
    warnings: list[str],
) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    seen: set[str] = set()
    passes = parsed_log["passes"]
    failures = parsed_log["failures"]
    screenshots = parsed_log["screenshots"]

    for entry in required_entries:
        checkpoint = entry["id"]
        manifest_status = entry.get("status", "")
        seen.add(checkpoint)
        meta = metadata_for(checkpoint, metadata, scenario_id, warnings)
        record = base_record(checkpoint, meta, scenario_id, screenshots)
        if manifest_status == STATUS_SKIPPED:
            record.update({"status": STATUS_SKIPPED, "failure_summary": "Skipped by manifest"})
        elif checkpoint in passes:
            first_pass = passes[checkpoint][0]
            record.update(
                {
                    "status": STATUS_PASS,
                    "detail": first_pass["detail"],
                    "source_line": first_pass["line"],
                    "raw_line": first_pass["raw"],
                }
            )
        elif checkpoint in failures and checkpoint in known_fail:
            first_fail = failures[checkpoint][0]
            record.update(
                {
                    "status": STATUS_KNOWN_FAIL,
                    "reason": first_fail["reason"],
                    "source_line": first_fail["line"],
                    "raw_line": first_fail["raw"],
                    "failure_summary": "Known failure",
                }
            )
        elif checkpoint in failures:
            first_fail = failures[checkpoint][0]
            record.update(
                {
                    "status": STATUS_FAIL,
                    "reason": first_fail["reason"],
                    "source_line": first_fail["line"],
                    "raw_line": first_fail["raw"],
                    "failure_summary": first_fail["reason"] or "Checkpoint emitted FAIL",
                }
            )
        elif checkpoint in known_fail or manifest_status == STATUS_KNOWN_FAIL:
            record.update({"status": STATUS_KNOWN_FAIL, "failure_summary": "Known failure"})
        else:
            record.update(
                {
                    "status": STATUS_MISSING,
                    "failure_summary": "Required checkpoint did not emit PASS",
                }
            )
        records.append(record)

    for checkpoint, failures_for_checkpoint in failures.items():
        if checkpoint in seen:
            continue
        first_fail = failures_for_checkpoint[0]
        meta = metadata_for(checkpoint, metadata, scenario_id, warnings)
        record = base_record(checkpoint, meta, scenario_id, screenshots)
        record.update(
            {
                "status": STATUS_FAIL,
                "reason": first_fail["reason"],
                "source_line": first_fail["line"],
                "raw_line": first_fail["raw"],
                "failure_summary": first_fail["reason"] or "Unexpected checkpoint FAIL",
                "unexpected": True,
            }
        )
        records.append(record)
        seen.add(checkpoint)

    for checkpoint, passes_for_checkpoint in passes.items():
        if checkpoint in seen:
            continue
        first_pass = passes_for_checkpoint[0]
        meta = metadata_for(checkpoint, metadata, scenario_id, warnings)
        record = base_record(checkpoint, meta, scenario_id, screenshots)
        record.update(
            {
                "status": STATUS_PASS,
                "detail": first_pass["detail"],
                "source_line": first_pass["line"],
                "raw_line": first_pass["raw"],
                "required": False,
            }
        )
        records.append(record)
    return records


def base_record(
    checkpoint: str,
    metadata: dict[str, Any],
    scenario_id: str,
    screenshots: list[str],
) -> dict[str, Any]:
    return {
        "id": checkpoint,
        "status": "",
        "scenario_id": str(metadata.get("scenario", scenario_id)),
        "severity": str(metadata.get("severity", "normal")),
        "detail": "",
        "reason": "",
        "duration_msec": 0,
        "screenshot_paths": list(screenshots),
        "required": bool(metadata.get("required", True)),
        "metadata": metadata,
        "source_line": 0,
        "raw_line": "",
        "failure_summary": "",
    }


def append_scenario_failures(
    records: list[dict[str, Any]],
    failures: list[dict[str, Any]],
    scenario_id: str,
) -> None:
    existing = {record["id"] for record in records}
    for failure in failures:
        checkpoint = str(failure.get("name", "scenario_failed"))
        if checkpoint in existing:
            continue
        status = STATUS_FAIL
        records.append(
            {
                "id": checkpoint,
                "status": status,
                "scenario_id": scenario_id,
                "severity": "critical" if int(failure.get("code", 0)) == 14 else "high",
                "detail": "",
                "reason": str(failure.get("message", "")),
                "duration_msec": 0,
                "screenshot_paths": [],
                "required": True,
                "metadata": {
                    "title": checkpoint.replace("_", " ").title(),
                    "suite": "runtime_audit",
                    "scenario": scenario_id,
                    "severity": "critical" if int(failure.get("code", 0)) == 14 else "high",
                    "junit_classname": "Mallcore.RuntimeAudit.Scenario",
                },
                "source_line": int(failure.get("line", 0)),
                "raw_line": str(failure.get("raw", "")),
                "failure_summary": str(failure.get("message", "")) or "Scenario failed",
            }
        )
        existing.add(checkpoint)


def summarize(records: list[dict[str, Any]], assertion_counts: dict[str, int]) -> dict[str, Any]:
    status_counts = {
        STATUS_PASS: 0,
        STATUS_FAIL: 0,
        STATUS_MISSING: 0,
        STATUS_KNOWN_FAIL: 0,
        STATUS_SKIPPED: 0,
    }
    for record in records:
        status = str(record.get("status", ""))
        if status in status_counts:
            status_counts[status] += 1
    failed = next(
        (
            record
            for record in records
            if record.get("status") in {STATUS_FAIL, STATUS_MISSING}
        ),
        {},
    )
    return {
        "scenario_count": 1,
        "checkpoint_count": len(records),
        "passed": status_counts[STATUS_PASS],
        "failed": status_counts[STATUS_FAIL],
        "missing": status_counts[STATUS_MISSING],
        "known_fail": status_counts[STATUS_KNOWN_FAIL],
        "skipped": status_counts[STATUS_SKIPPED],
        "duration_msec": sum(int(record.get("duration_msec", 0)) for record in records),
        "assertion_counts": assertion_counts,
        "failed_step": str(failed.get("id", "")),
        "failure_summary": str(failed.get("failure_summary", "")),
    }


def scenario_status(summary: dict[str, Any]) -> str:
    if int(summary["failed"]) > 0 or int(summary["missing"]) > 0:
        return STATUS_FAIL
    if int(summary["checkpoint_count"]) == int(summary["skipped"]):
        return STATUS_SKIPPED
    return STATUS_PASS


def main() -> int:
    args = parse_args()
    warnings: list[str] = []
    audit_log = Path(args.audit_log)
    artifact_root = Path(args.artifact_root)
    required_file = Path(args.required_file)
    scenario_id = args.scenario_id.strip() or "runtime_audit"
    report_dir = artifact_root / "reports" / "scenario" / scenario_id
    report_dir.mkdir(parents=True, exist_ok=True)

    required_entries = strip_manifest(required_file)
    known_fail = load_known_fail(args.known_fail_file)
    metadata = load_metadata(args.metadata_file, warnings)
    parsed_log = parse_log(audit_log)
    seed = args.seed or str(parsed_log["automation"].get("seed", ""))
    records = build_records(
        required_entries,
        known_fail,
        metadata,
        parsed_log,
        scenario_id,
        warnings,
    )
    append_scenario_failures(records, parsed_log["scenario_failures"], scenario_id)
    summary = summarize(records, parsed_log["assertion_counts"])
    status = scenario_status(summary)
    scenario = {
        "id": scenario_id,
        "suite": "runtime_audit",
        "seed": seed,
        "status": status,
        "duration_msec": summary["duration_msec"],
        "screenshot_paths": parsed_log["screenshots"],
        "assertion_counts": parsed_log["assertion_counts"],
        "failed_step": summary["failed_step"],
        "failure_summary": summary["failure_summary"],
        "scenario_exit": parsed_log["scenario_exit"],
        "checkpoints": records,
        "events": parsed_log["events"],
    }
    report = {
        "schema_version": 1,
        "project": "mallcore-sim",
        "suite": "runtime_audit",
        "generated_unix": int(time.time()),
        "artifact_root": str(artifact_root),
        "summary": summary,
        "warnings": warnings,
        "scenarios": [scenario],
    }
    checkpoints = {
        "schema_version": 1,
        "checkpoints": [
            {
                "id": record["id"],
                "status": record["status"],
                "scenario_id": record["scenario_id"],
                "severity": record["severity"],
                "detail": record["detail"],
                "reason": record["reason"],
                "duration_msec": record["duration_msec"],
                "screenshot_paths": record["screenshot_paths"],
                "failure_summary": record["failure_summary"],
            }
            for record in records
        ],
    }
    write_json(report_dir / "scenario-report.json", report)
    write_markdown(report_dir / "scenario-report.md", report)
    write_json(report_dir / "audit-checkpoints.json", checkpoints)
    write_junit(report_dir / "junit-audit.xml", report)
    print(f"REPORT: wrote {report_dir / 'scenario-report.json'}")
    print(f"REPORT: wrote {report_dir / 'scenario-report.md'}")
    print(f"REPORT: wrote {report_dir / 'audit-checkpoints.json'}")
    print(f"REPORT: wrote {report_dir / 'junit-audit.xml'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
