#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PR_WORKFLOW="$ROOT/.github/workflows/validate.yml"
NIGHTLY_WORKFLOW="$ROOT/.github/workflows/nightly.yml"
VIDEO_WORKFLOW="$ROOT/.github/workflows/nightly-videos.yml"
RELEASE_WORKFLOW="$ROOT/.github/workflows/export.yml"

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

check_file() {
	local path="$1"
	[ -f "$path" ] || fail "missing $path"
}

check_contains() {
	local path="$1"
	local needle="$2"
	grep -Fq -- "$needle" "$path" || fail "$(basename "$path") missing '$needle'"
}

check_absent() {
	local path="$1"
	local needle="$2"
	if grep -Fq -- "$needle" "$path"; then
		fail "$(basename "$path") should not contain '$needle'"
	fi
}

check_file "$PR_WORKFLOW"
check_file "$NIGHTLY_WORKFLOW"
check_file "$VIDEO_WORKFLOW"
check_file "$RELEASE_WORKFLOW"

check_contains "$PR_WORKFLOW" "name: PR Fast Validation"
check_contains "$PR_WORKFLOW" "Static Lane - Repo Guards"
check_contains "$PR_WORKFLOW" "Static Lane - GDScript Lint"
check_contains "$PR_WORKFLOW" "Scene Lane - Resource and Autoload Integrity"
check_contains "$PR_WORKFLOW" "Unit and Flow Lane - PR GUT Smoke"
check_contains "$PR_WORKFLOW" "bash scripts/validate_static_repo_guards.sh"
check_contains "$PR_WORKFLOW" "bash scripts/validate_resource_integrity.sh"
check_contains "$PR_WORKFLOW" "gdlint game/"
check_contains "$PR_WORKFLOW" "bash tests/automation/run_pr_smoke.sh"
check_absent "$PR_WORKFLOW" "bash scripts/run_godot_tests.sh"
check_absent "$PR_WORKFLOW" "bash tests/audit_run.sh"
check_absent "$PR_WORKFLOW" "bash scripts/run_store_visual_sweep.sh"
check_absent "$PR_WORKFLOW" "long_day_soak"

check_contains "$NIGHTLY_WORKFLOW" "name: Nightly Full Validation"
check_contains "$NIGHTLY_WORKFLOW" "Unit Lane - Full GUT Tests"
check_contains "$NIGHTLY_WORKFLOW" "Scene and Flow Lane - Interaction Audit"
check_contains "$NIGHTLY_WORKFLOW" "Visual Snapshot Lane - Soft Review"
check_contains "$NIGHTLY_WORKFLOW" "Soak Lane - Long Day Scenario"
check_contains "$NIGHTLY_WORKFLOW" "continue-on-error: true"
check_contains "$NIGHTLY_WORKFLOW" "bash scripts/run_godot_tests.sh"
check_contains "$NIGHTLY_WORKFLOW" "bash tests/audit_run.sh"
check_contains "$NIGHTLY_WORKFLOW" "bash scripts/run_store_visual_sweep.sh"
check_contains "$NIGHTLY_WORKFLOW" "--scenario=long_day_soak"
check_contains "$NIGHTLY_WORKFLOW" "artifacts/logs/scenario/"
check_contains "$NIGHTLY_WORKFLOW" "artifacts/reports/scenario/"
check_contains "$NIGHTLY_WORKFLOW" "artifacts/screenshots/scenario/"
check_contains "$NIGHTLY_WORKFLOW" "artifacts/visual_sweep/"
check_contains "$NIGHTLY_WORKFLOW" "artifacts/manifests/"

check_contains "$VIDEO_WORKFLOW" "name: Nightly Video Review"
check_contains "$VIDEO_WORKFLOW" "Video Lane - Scenario Movies"
check_contains "$VIDEO_WORKFLOW" "artifacts/videos/scenario/nightly/"
check_contains "$VIDEO_WORKFLOW" "artifacts/logs/scenario/nightly-videos/"

check_contains "$RELEASE_WORKFLOW" "name: Release Playtest and Export"
check_contains "$RELEASE_WORKFLOW" "workflow_dispatch:"
check_contains "$RELEASE_WORKFLOW" "Release Lane - Validate Trigger"
check_contains "$RELEASE_WORKFLOW" "Unit Lane - Full GUT Tests"
check_contains "$RELEASE_WORKFLOW" "Scene and Flow Lane - Interaction Audit"
check_contains "$RELEASE_WORKFLOW" "Release Lane - Validate Export Config"
check_contains "$RELEASE_WORKFLOW" "Advisory Review Lane - Release Playtest Manifest"
check_contains "$RELEASE_WORKFLOW" "Release Lane - Publish Version Tag"
check_contains "$RELEASE_WORKFLOW" "release-playtest-checklist.md"
check_contains "$RELEASE_WORKFLOW" "if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/v')"
check_contains "$RELEASE_WORKFLOW" "bash scripts/validate_export_config.sh"
check_contains "$RELEASE_WORKFLOW" "bash scripts/run_godot_tests.sh"
check_contains "$RELEASE_WORKFLOW" "bash tests/audit_run.sh"
check_contains "$RELEASE_WORKFLOW" "artifacts/logs/gut/"
check_contains "$RELEASE_WORKFLOW" "artifacts/logs/scenario/"
check_contains "$RELEASE_WORKFLOW" "artifacts/reports/scenario/"
check_contains "$RELEASE_WORKFLOW" "artifacts/screenshots/scenario/"
check_contains "$RELEASE_WORKFLOW" "artifacts/manifests/"

echo "CI gate partition wiring OK"
