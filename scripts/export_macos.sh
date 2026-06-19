#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/Users/michaelfuscoletti/.local/bin/godot}"
TEMPLATE_PATH="$HOME/Library/Application Support/Godot/export_templates/4.6.2.stable/macos.zip"
OUTPUT_PATH="$ROOT_DIR/game/build/macos/GameStoreSimEngineProof.zip"

if [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot binary is not executable: $GODOT_BIN" >&2
  exit 1
fi

if [[ ! -f "$TEMPLATE_PATH" ]]; then
  cat >&2 <<EOF
Missing Godot macOS export template:
$TEMPLATE_PATH

Install export templates for Godot 4.6.2 stable, then rerun:
  scripts/export_macos.sh

The local engine proof validation can still run without export templates:
  scripts/validate_local.sh
EOF
  exit 2
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"
(
  cd "$ROOT_DIR/game"
  "$GODOT_BIN" --headless --path "$ROOT_DIR/game" --export-debug macOS "$OUTPUT_PATH"
)

echo "$OUTPUT_PATH"
