#!/usr/bin/env bash
## Fast repository guardrail checks for PR and release validation.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VALIDATOR="static-repo-guards"
NEXT_COMMAND="bash scripts/validate_static_repo_guards.sh"

fail() {
	local path="$1"
	local message="$2"
	echo "::error::[$VALIDATOR] $message: $path. Next: $NEXT_COMMAND" >&2
	exit 1
}

run_check() {
	local label="$1"
	shift
	echo "[$VALIDATOR] $label"
	if ! "$@"; then
		local command_text
		command_text="$(printf "%q " "$@")"
		echo "::error::[$VALIDATOR] $label failed. Next: ${command_text% }" >&2
		exit 1
	fi
}

required_files=(
	"project.godot"
	"README.md"
	"LICENSE"
	"docs/architecture.md"
	"export_presets.cfg"
	".github/workflows/nightly.yml"
	".github/workflows/nightly-videos.yml"
	".gutconfig.json"
	".gutconfig.pr-smoke.json"
	"scripts/validate_export_config.sh"
	"scripts/validate_originality.sh"
	"scripts/validate_single_store_ui.sh"
	"scripts/validate_translations.sh"
	"scripts/validate_tutorial_single_source.sh"
	"tests/validate_ci_gate_partition.sh"
	"tests/validate_gut_config_discovery.sh"
)

for required_file in "${required_files[@]}"; do
	if [ ! -f "$required_file" ]; then
		fail "$required_file" "required file missing"
	fi
done

if find . -name ".DS_Store" -print -quit | grep -q .; then
	find . -name ".DS_Store" -print >&2
	fail ".DS_Store" "forbidden Finder metadata found"
fi

run_check "export preset structure" bash scripts/validate_export_config.sh
run_check "CI gate partition wiring" bash tests/validate_ci_gate_partition.sh
run_check "content originality denylist" bash scripts/validate_originality.sh
run_check "GUT discovery config" bash tests/validate_gut_config_discovery.sh
run_check "translation source of truth" bash scripts/validate_translations.sh
run_check "single store UI source of truth" bash scripts/validate_single_store_ui.sh
run_check "tutorial text source of truth" bash scripts/validate_tutorial_single_source.sh

echo "Static repo guards: OK"
