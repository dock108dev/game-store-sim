#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAME_DIR="$REPO_ROOT/game"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
PRESET="${EXPORT_PRESET:-macOS Desktop}"
ARTIFACT_DIR="${EXPORT_ARTIFACT_DIR:-$REPO_ROOT/artifacts/builds/desktop}"
PACK_PATH="$ARTIFACT_DIR/game-store-sim.pck"
BINARY_PATH="$ARTIFACT_DIR/Game Store Sim.app"
EXPORT_LOG="$ARTIFACT_DIR/desktop-export.log"
BOOT_LOG="$ARTIFACT_DIR/desktop-pack-boot.log"
MODE="${1:---pack-smoke}"

cd "$REPO_ROOT"

if [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot binary not found or not executable: $GODOT_BIN" >&2
  echo "Set GODOT_BIN=/path/to/Godot to override." >&2
  exit 1
fi

if [[ ! -f "$GAME_DIR/export_presets.cfg" ]]; then
  echo "Missing Godot export presets: $GAME_DIR/export_presets.cfg" >&2
  exit 1
fi

if ! rg -n "name=\"$PRESET\"" "$GAME_DIR/export_presets.cfg" >/dev/null; then
  echo "Export preset '$PRESET' is missing from game/export_presets.cfg" >&2
  exit 1
fi

mkdir -p "$ARTIFACT_DIR"

case "$MODE" in
  --pack-smoke)
    rm -f "$PACK_PATH"
    rm -f "$EXPORT_LOG" "$BOOT_LOG"
    echo "== Export pack =="
    if ! "$GODOT_BIN" --headless --path "$GAME_DIR" --export-pack "$PRESET" "$PACK_PATH" >"$EXPORT_LOG" 2>&1; then
      tail -80 "$EXPORT_LOG" >&2
      echo "Export pack failed. Full log: $EXPORT_LOG" >&2
      exit 1
    fi
    if [[ ! -s "$PACK_PATH" ]]; then
      tail -80 "$EXPORT_LOG" >&2
      echo "Export pack was not created or is empty: $PACK_PATH" >&2
      exit 1
    fi

    echo "== Pack boot smoke =="
    if ! "$GODOT_BIN" --headless --main-pack "$PACK_PATH" --quit-after 1 >"$BOOT_LOG" 2>&1; then
      tail -80 "$BOOT_LOG" >&2
      echo "Pack boot smoke failed. Full log: $BOOT_LOG" >&2
      exit 1
    fi
    echo "Desktop pack export smoke passed: $PACK_PATH"
    echo "Logs: $EXPORT_LOG, $BOOT_LOG"
    ;;
  --binary)
    rm -rf "$BINARY_PATH"
    echo "== Export debug binary =="
    if ! "$GODOT_BIN" --headless --path "$GAME_DIR" --export-debug "$PRESET" "$BINARY_PATH"; then
      echo "Binary export failed. Install matching Godot export templates for 4.6.2 or use --pack-smoke for template-free verification." >&2
      exit 1
    fi
    if [[ ! -e "$BINARY_PATH" ]]; then
      echo "Binary export did not create expected app: $BINARY_PATH" >&2
      exit 1
    fi
    echo "Desktop binary export passed: $BINARY_PATH"
    ;;
  *)
    echo "Usage: scripts/verify_desktop_export.sh [--pack-smoke|--binary]" >&2
    exit 1
    ;;
esac
