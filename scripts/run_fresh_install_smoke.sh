#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/artifact_paths.sh"
source "$ROOT/scripts/godot_resolver.sh"

ARTIFACT_ROOT="$(resolve_mallcore_artifact_root "$ROOT")"
export MALLCORE_ARTIFACT_DIR="$ARTIFACT_ROOT"

GODOT_BIN="$(resolve_mallcore_godot)"
LOG_DIR="$(mallcore_artifact_path "$ARTIFACT_ROOT" "logs/scenario")"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/fresh_install_smoke.log"

GODOT_ARGS=(
	--path "$ROOT"
	--rendering-method gl_compatibility
	--
	--test-mode
	--scenario=fresh_install_smoke
	--seed=fresh_install_smoke
	--fresh-save=fresh_install_smoke
	--record-screenshots
	--exit-on-complete
)

if [[ "$(uname -s)" == "Linux" && -z "${DISPLAY:-}" ]]; then
	if ! command -v xvfb-run >/dev/null 2>&1; then
		echo "ERROR: xvfb-run is required for screenshot-backed fresh-install smoke on Linux CI." >&2
		exit 1
	fi
	xvfb-run -a --server-args="-screen 0 1920x1080x24 +extension GLX +render -noreset" \
		"$GODOT_BIN" "${GODOT_ARGS[@]}" 2>&1 | tee "$LOG_FILE"
else
	"$GODOT_BIN" "${GODOT_ARGS[@]}" 2>&1 | tee "$LOG_FILE"
fi
