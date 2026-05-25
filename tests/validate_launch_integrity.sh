#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

check_file() {
	local path="$1"
	if [ ! -f "$ROOT/$path" ]; then
		echo "FAIL: missing $path" >&2
		exit 1
	fi
}

check_contains() {
	local path="$1"
	local needle="$2"
	if ! grep -Fq "$needle" "$ROOT/$path"; then
		echo "FAIL: $path missing '$needle'" >&2
		exit 1
	fi
}

check_file "scripts/validate_static_repo_guards.sh"
check_file "scripts/validate_resource_integrity.sh"
check_file "scripts/validate_resource_integrity.gd"

bash -n "$ROOT/scripts/validate_static_repo_guards.sh"
bash -n "$ROOT/scripts/validate_resource_integrity.sh"

check_contains ".github/workflows/validate.yml" "static-repo-guards:"
check_contains ".github/workflows/validate.yml" "bash scripts/validate_static_repo_guards.sh"
check_contains ".github/workflows/validate.yml" "bash scripts/validate_resource_integrity.sh"
check_contains ".github/workflows/validate.yml" "bash tests/automation/run_pr_smoke.sh"
check_contains ".github/workflows/export.yml" "bash scripts/validate_export_config.sh"
check_contains "tests/run_tests.sh" "scripts/validate_static_repo_guards.sh"
check_contains "tests/run_tests.sh" "scripts/validate_resource_integrity.sh"
check_contains "scripts/run_godot_tests.sh" "scripts/validate_resource_integrity.sh"

echo "Launch integrity wiring OK"
