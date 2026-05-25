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

"$GODOT_BIN" --path "$ROOT" --headless -- \
	--test-mode \
	--scenario=fresh_install_smoke \
	--seed=fresh_install_smoke \
	--fresh-save=fresh_install_smoke \
	--record-screenshots \
	--exit-on-complete \
	2>&1 | tee "$LOG_FILE"
