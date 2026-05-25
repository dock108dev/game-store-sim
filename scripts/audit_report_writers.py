"""Writers for runtime audit scenario report artifacts."""

from __future__ import annotations

import json
import xml.sax.saxutils
from pathlib import Path
from typing import Any

STATUS_FAIL = "FAIL"
STATUS_KNOWN_FAIL = "KNOWN_FAIL"
STATUS_MISSING = "MISSING"
STATUS_PASS = "PASS"
STATUS_SKIPPED = "SKIPPED"


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def write_markdown(path: Path, report: dict[str, Any]) -> None:
    summary = report["summary"]
    scenario = report["scenarios"][0]
    lines = [
        "# Runtime Audit Scenario Report",
        "",
        "## Summary",
        "",
        f"- Scenario: {scenario['id']}",
        f"- Status: {scenario['status']}",
        f"- Seed: {scenario['seed']}",
        f"- Checkpoints: {summary['checkpoint_count']}",
        f"- Passed: {summary['passed']}",
        f"- Failed: {summary['failed']}",
        f"- Missing: {summary['missing']}",
        f"- Known Fail: {summary['known_fail']}",
        f"- Skipped: {summary['skipped']}",
        f"- Failed Step: {summary['failed_step']}",
        f"- Failure Summary: {summary['failure_summary']}",
        "",
        "## Checkpoints",
        "",
        "| Checkpoint | Status | Severity | Detail |",
        "|---|---:|---:|---|",
    ]
    for record in scenario["checkpoints"]:
        detail = record.get("detail") or record.get("reason") or record.get("failure_summary")
        lines.append(
            "| {id} | {status} | {severity} | {detail} |".format(
                id=escape_markdown(str(record.get("id", ""))),
                status=escape_markdown(str(record.get("status", ""))),
                severity=escape_markdown(str(record.get("severity", ""))),
                detail=escape_markdown(str(detail)),
            )
        )
    if report["warnings"]:
        lines.extend(["", "## Warnings", ""])
        lines.extend(f"- {escape_markdown(str(warning))}" for warning in report["warnings"])
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_junit(path: Path, report: dict[str, Any]) -> None:
    scenario = report["scenarios"][0]
    records = scenario["checkpoints"]
    failures = sum(1 for record in records if record["status"] in {STATUS_FAIL, STATUS_MISSING})
    skipped = sum(1 for record in records if record["status"] in {STATUS_KNOWN_FAIL, STATUS_SKIPPED})
    testcase_xml: list[str] = []
    for record in records:
        metadata = record.get("metadata", {})
        classname = xml_escape(str(metadata.get("junit_classname", "Mallcore.RuntimeAudit")))
        name = xml_escape(str(record.get("id", "")))
        testcase_xml.append(
            f'    <testcase classname="{classname}" name="{name}" time="0.000">'
        )
        if record["status"] in {STATUS_FAIL, STATUS_MISSING}:
            message = xml_escape(str(record.get("failure_summary", "")))
            body = xml_escape(str(record.get("raw_line") or record.get("reason") or message))
            testcase_xml.append(f'      <failure message="{message}">{body}</failure>')
        elif record["status"] in {STATUS_KNOWN_FAIL, STATUS_SKIPPED}:
            message = xml_escape(str(record.get("failure_summary", record["status"])))
            testcase_xml.append(f'      <skipped message="{message}" />')
        system_out = xml_escape(str(record.get("detail") or record.get("reason", "")))
        testcase_xml.append(f"      <system-out>{system_out}</system-out>")
        testcase_xml.append("    </testcase>")
    tests = len(records)
    suite = xml_escape(str(scenario.get("suite", "runtime_audit")))
    body = "\n".join(testcase_xml)
    path.write_text(
        "\n".join(
            [
                '<?xml version="1.0" encoding="UTF-8"?>',
                f'<testsuites tests="{tests}" failures="{failures}" skipped="{skipped}" time="0.000">',
                f'  <testsuite name="{suite}" tests="{tests}" failures="{failures}" skipped="{skipped}" time="0.000">',
                body,
                "  </testsuite>",
                "</testsuites>",
                "",
            ]
        ),
        encoding="utf-8",
    )


def escape_markdown(value: str) -> str:
    return value.replace("|", "\\|").replace("\n", " ")


def xml_escape(value: str) -> str:
    return xml.sax.saxutils.escape(value, {'"': "&quot;", "'": "&apos;"})
