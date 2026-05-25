#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/artifact_paths.sh"

ARTIFACT_ROOT="$(resolve_mallcore_artifact_root "$ROOT")"
export MALLCORE_ARTIFACT_DIR="$ARTIFACT_ROOT"

_resolve_godot_bin() {
	local configured="${GODOT:-${GODOT_EXECUTABLE:-godot}}"
	local candidates=(
		"$configured"
		"/Applications/Godot.app/Contents/MacOS/Godot"
		"$HOME/Applications/Godot.app/Contents/MacOS/Godot"
	)
	local candidate=""
	for candidate in "${candidates[@]}"; do
		if [ -x "$candidate" ]; then
			echo "$candidate"
			return 0
		fi
		if command -v "$candidate" &>/dev/null; then
			command -v "$candidate"
			return 0
		fi
	done
	return 1
}

GODOT_BIN="$(_resolve_godot_bin)"
LOG_DIR="$(mallcore_artifact_path "$ARTIFACT_ROOT" "logs/scenario")"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/fresh_install_smoke.log"

"$GODOT_BIN" --path "$ROOT" --headless -- \
	--test-mode \
	--scenario=fresh_install_smoke \
	--seed=fresh_install_smoke \
	--fresh-save=fresh_install_smoke \
	--record-screenshots \
	--exit-on-complete \
	2>&1 | tee "$LOG_FILE"

