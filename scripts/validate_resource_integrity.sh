#!/usr/bin/env bash
## Run Godot-backed launch/resource integrity checks before gameplay tests.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="resource-integrity"
NEXT_COMMAND="bash scripts/validate_resource_integrity.sh"

fail() {
	local message="$1"
	echo "::error::[$VALIDATOR] $message. Next: $NEXT_COMMAND" >&2
	exit 1
}

if [ "${MALLCORE_SKIP_IMPORT:-0}" != "1" ]; then
	bash "$ROOT/scripts/godot_import.sh" || fail "Godot import failed"
fi

if ! bash "$ROOT/scripts/godot_exec.sh" \
	--path "$ROOT" \
	--headless \
	--script res://scripts/validate_resource_integrity.gd; then
	fail "resource reference scan failed"
fi

set +e
LAUNCH_OUTPUT="$(
	bash "$ROOT/scripts/godot_exec.sh" \
		--path "$ROOT" \
		--headless \
		--quit-after 1 2>&1
)"
LAUNCH_STATUS=$?
set -e
printf "%s\n" "$LAUNCH_OUTPUT"

if [ "$LAUNCH_STATUS" -ne 0 ]; then
	fail "Godot launch check exited with status $LAUNCH_STATUS"
fi

LAUNCH_FAILURES="$(printf "%s\n" "$LAUNCH_OUTPUT" \
	| grep -E 'SCRIPT ERROR|Failed to load script|Failed loading resource|Parse Error|Cannot open file|Unable to load|Invalid get index|Invalid call' || true)"
if [ -n "$LAUNCH_FAILURES" ]; then
	printf "%s\n" "$LAUNCH_FAILURES" >&2
	fail "Godot launch check reported script/resource errors"
fi

echo "Resource integrity: launch OK"
