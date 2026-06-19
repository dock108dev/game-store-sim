#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/Users/michaelfuscoletti/.local/bin/godot}"
ARTIFACT_DIR="$ROOT_DIR/artifacts/validation/latest"
LOG_FILE="$ARTIFACT_DIR/validation.log"
ENGINE_LOG="$ARTIFACT_DIR/engine-proof.log"
LAUNCH_LOG="$ARTIFACT_DIR/main-scene-launch.log"
SUMMARY_FILE="$ARTIFACT_DIR/summary.json"
SCREENSHOT_FILE="$ARTIFACT_DIR/screenshots/engine-proof-state.png"

rm -rf "$ARTIFACT_DIR"
mkdir -p "$ARTIFACT_DIR/screenshots"

{
  echo "Game Store Sim local validation"
  echo "root=$ROOT_DIR"
  echo "godot=$GODOT_BIN"
  date
} | tee "$LOG_FILE"

required_files=(
  "$ROOT_DIR/docs/MASTER_PLAN.md"
  "$ROOT_DIR/docs/01-design/vertical-slice-contract.md"
  "$ROOT_DIR/docs/02-technical/architecture.md"
  "$ROOT_DIR/docs/04-validation/manual-playtest-checklist.md"
  "$ROOT_DIR/game/project.godot"
  "$ROOT_DIR/game/scenes/main/engine_proof.tscn"
  "$ROOT_DIR/game/scripts/systems/engine_proof_state.gd"
  "$ROOT_DIR/game/scripts/systems/engine_proof_scene.gd"
  "$ROOT_DIR/game/scripts/tools/run_validation.gd"
  "$ROOT_DIR/game/export_presets.cfg"
)

for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" | tee -a "$LOG_FILE"
    exit 1
  fi
done

if [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot binary is not executable: $GODOT_BIN" | tee -a "$LOG_FILE"
  exit 1
fi

"$GODOT_BIN" --version | tee -a "$LOG_FILE"

(
  cd "$ROOT_DIR/game"
  GSS_VALIDATION_DIR="$ARTIFACT_DIR" "$GODOT_BIN" --headless --path "$ROOT_DIR/game" --script res://scripts/tools/run_validation.gd
) >"$ENGINE_LOG" 2>&1 || {
  cat "$ENGINE_LOG" | tee -a "$LOG_FILE"
  exit 1
}

cat "$ENGINE_LOG" >> "$LOG_FILE"

if rg -n "SCRIPT ERROR|Parse Error|Failed to load script|Ignoring script|ENGINE_PROOF_VALIDATION: FAIL" "$ENGINE_LOG" >/tmp/game_store_sim_validation_errors.txt; then
  cat /tmp/game_store_sim_validation_errors.txt | tee -a "$LOG_FILE"
  exit 1
fi

(
  cd "$ROOT_DIR/game"
  "$GODOT_BIN" --headless --path "$ROOT_DIR/game" --quit-after 2
) >"$LAUNCH_LOG" 2>&1 || {
  cat "$LAUNCH_LOG" | tee -a "$LOG_FILE"
  exit 1
}

cat "$LAUNCH_LOG" >> "$LOG_FILE"

if rg -n "SCRIPT ERROR|Parse Error|Failed to load script|Ignoring script" "$LAUNCH_LOG" >/tmp/game_store_sim_launch_errors.txt; then
  cat /tmp/game_store_sim_launch_errors.txt | tee -a "$LOG_FILE"
  exit 1
fi

if [[ ! -f "$SUMMARY_FILE" ]]; then
  echo "Missing validation summary: $SUMMARY_FILE" | tee -a "$LOG_FILE"
  exit 1
fi

if [[ ! -f "$SCREENSHOT_FILE" ]]; then
  echo "Missing proof screenshot: $SCREENSHOT_FILE" | tee -a "$LOG_FILE"
  exit 1
fi

width="$(sips -g pixelWidth "$SCREENSHOT_FILE" 2>/dev/null | awk '/pixelWidth/ {print $2}')"
height="$(sips -g pixelHeight "$SCREENSHOT_FILE" 2>/dev/null | awk '/pixelHeight/ {print $2}')"
if [[ "$width" != "640" || "$height" != "360" ]]; then
  echo "Unexpected screenshot dimensions: ${width}x${height}" | tee -a "$LOG_FILE"
  exit 1
fi

if ! /usr/bin/python3 - "$SCREENSHOT_FILE" <<'PY'
import struct
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = path.read_bytes()
if len(data) < 128 or not data.startswith(b"\x89PNG\r\n\x1a\n"):
    raise SystemExit(1)

# Lightweight sanity: the generated proof image should contain many colors.
unique_chunks = set(data[i:i+3] for i in range(64, min(len(data), 4096), 17))
if len(unique_chunks) < 8:
    raise SystemExit(1)
PY
then
  echo "Screenshot sanity check failed" | tee -a "$LOG_FILE"
  exit 1
fi

if [[ "${GSS_EXPORT_MACOS:-0}" == "1" ]]; then
  MACOS_ZIP="$ROOT_DIR/game/build/macos/GameStoreSimEngineProof.zip"
  MACOS_RUN_DIR="$ARTIFACT_DIR/macos-export-run"
  MACOS_RUN_LOG="$ARTIFACT_DIR/macos-export-launch.log"
  mkdir -p "$ROOT_DIR/game/build/macos"
  (
    cd "$ROOT_DIR/game"
    "$GODOT_BIN" --headless --path "$ROOT_DIR/game" --export-debug macOS "build/macos/GameStoreSimEngineProof.zip"
  ) >>"$LOG_FILE" 2>&1

  if [[ ! -f "$MACOS_ZIP" ]]; then
    echo "Missing macOS export artifact: $MACOS_ZIP" | tee -a "$LOG_FILE"
    exit 1
  fi

  rm -rf "$MACOS_RUN_DIR"
  mkdir -p "$MACOS_RUN_DIR"
  unzip -q "$MACOS_ZIP" -d "$MACOS_RUN_DIR"
  MACOS_EXEC="$MACOS_RUN_DIR/Game Store Sim - Engine Proof.app/Contents/MacOS/Game Store Sim - Engine Proof"
  if [[ ! -x "$MACOS_EXEC" ]]; then
    echo "Missing executable in macOS export: $MACOS_EXEC" | tee -a "$LOG_FILE"
    exit 1
  fi

  "$MACOS_EXEC" --headless --quit-after 2 >"$MACOS_RUN_LOG" 2>&1 || {
    cat "$MACOS_RUN_LOG" | tee -a "$LOG_FILE"
    exit 1
  }
  cat "$MACOS_RUN_LOG" >> "$LOG_FILE"

  if rg -n "SCRIPT ERROR|Parse Error|Failed to load script|Ignoring script" "$MACOS_RUN_LOG" >/tmp/game_store_sim_macos_export_errors.txt; then
    cat /tmp/game_store_sim_macos_export_errors.txt | tee -a "$LOG_FILE"
    exit 1
  fi
fi

echo "VALIDATION PASS" | tee -a "$LOG_FILE"
