#!/usr/bin/env bash
# Validates structured scenario reports generated from AuditLog-format output.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PASS=0
FAIL=0
pass() { PASS=$((PASS + 1)); echo "  PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL: $1"; }

echo "=== Scenario report generation ==="

LOG="$TMP_DIR/audit.log"
REQ="$TMP_DIR/required.txt"
KNOWN="$TMP_DIR/known_fail.txt"
META="$TMP_DIR/metadata.json"
ARTIFACTS="$TMP_DIR/artifacts"

cat > "$LOG" <<'LOGEOF'
AUTOMATION: {"type":"automation_start","scenario_id":"smoke","seed":"seed_123"}
AUDIT: PASS boot_scene_ready from=boot.gd
AUDIT: FAIL flaky_checkpoint transient
SCENARIO: FAIL code=14 name=scenario_timeout message=flow timed out context={"step":"wait_for_customer"}
[STAT] actor=system target=player action=stat_changed stat=money delta=10
Asserts           12
Tests             4
  Passing         3
  Failing         1
LOGEOF

cat > "$REQ" <<'REQEOF'
boot_scene_ready
flaky_checkpoint
missing_checkpoint
skip optional_checkpoint
REQEOF

cat > "$KNOWN" <<'KFEOF'
flaky_checkpoint
KFEOF

cat > "$META" <<'METAEOF'
{
  "boot_scene_ready": {
    "scenario": "smoke",
    "severity": "critical",
    "junit_classname": "Mallcore.RuntimeAudit.Smoke"
  },
  "flaky_checkpoint": {
    "scenario": "smoke",
    "severity": "low",
    "junit_classname": "Mallcore.RuntimeAudit.Smoke"
  }
}
METAEOF

OUT="$(python3 "$ROOT/scripts/generate_audit_scenario_report.py" \
	--audit-log "$LOG" \
	--artifact-root "$ARTIFACTS" \
	--required-file "$REQ" \
	--known-fail-file "$KNOWN" \
	--metadata-file "$META" \
	--scenario-id "smoke" 2>&1)"
RC=$?

if [ "$RC" -eq 0 ]; then
	pass "generator exits 0"
else
	fail "generator exits $RC"
	echo "$OUT"
fi

REPORT_DIR="$ARTIFACTS/reports/scenario/smoke"
for artifact in scenario-report.json scenario-report.md audit-checkpoints.json junit-audit.xml; do
	if [ -s "$REPORT_DIR/$artifact" ]; then
		pass "$artifact written"
	else
		fail "$artifact missing"
	fi
done

python3 - "$REPORT_DIR" <<'PY'
import json
import sys
from pathlib import Path

report_dir = Path(sys.argv[1])
report = json.loads((report_dir / "scenario-report.json").read_text())
flat = json.loads((report_dir / "audit-checkpoints.json").read_text())
statuses = {row["id"]: row["status"] for row in flat["checkpoints"]}
assert report["scenarios"][0]["id"] == "smoke"
assert report["scenarios"][0]["seed"] == "seed_123"
assert report["scenarios"][0]["assertion_counts"]["asserts"] == 12
assert statuses["boot_scene_ready"] == "PASS"
assert statuses["flaky_checkpoint"] == "KNOWN_FAIL"
assert statuses["missing_checkpoint"] == "MISSING"
assert statuses["optional_checkpoint"] == "SKIPPED"
assert statuses["scenario_timeout"] == "FAIL"
assert report["summary"]["failed_step"] == "missing_checkpoint"
assert any(str(w).startswith("metadata_missing:") for w in report["warnings"])
PY
if [ "$?" -eq 0 ]; then
	pass "JSON report maps pass, known-fail, missing, skipped, and timeout states"
else
	fail "JSON report content mismatch"
fi

if grep -q '<failure message="Required checkpoint did not emit PASS">' \
		"$REPORT_DIR/junit-audit.xml" \
		&& grep -q '<skipped message="Known failure" />' "$REPORT_DIR/junit-audit.xml" \
		&& grep -q 'name="scenario_timeout"' "$REPORT_DIR/junit-audit.xml"; then
	pass "JUnit maps failure, known-fail, and timeout testcase statuses"
else
	fail "JUnit status mapping missing"
fi

FULL_LOG="$TMP_DIR/audit_full.log"
{
	for checkpoint in \
		boot_scene_ready main_menu_ready gameplay_shell_ready store_id_resolved \
		scene_instantiated controller_ready content_instantiated camera_active \
		player_present input_gameplay; do
		echo "AUDIT: PASS $checkpoint"
	done
} > "$FULL_LOG"

RUN_OUT="$(AUDIT_SKIP_RUN=1 \
	AUDIT_LOG="$FULL_LOG" \
	AUDIT_REQUIRED_FILE="$ROOT/tests/audit_scenarios/smoke_required_checkpoints.txt" \
	AUDIT_SCENARIO_ID="smoke" \
	MALLCORE_ARTIFACT_DIR="$ARTIFACTS/audit_run" \
	bash "$ROOT/tests/audit_run.sh" 2>&1)"
RUN_RC=$?
if [ "$RUN_RC" -eq 0 ] && echo "$RUN_OUT" | grep -q "AUDIT PASSED"; then
	pass "audit_run supports scenario-specific required manifest"
else
	fail "audit_run scenario manifest path failed"
	echo "$RUN_OUT"
fi

TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] || exit 1
exit 0
