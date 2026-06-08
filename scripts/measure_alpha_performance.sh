#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAME_DIR="$REPO_ROOT/game"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
ARTIFACT_DIR="${ALPHA_PERF_ARTIFACT_DIR:-$REPO_ROOT/artifacts/performance/latest}"
BUILD_ARTIFACT_DIR="${EXPORT_ARTIFACT_DIR:-$REPO_ROOT/artifacts/builds/desktop}"
PACK_PATH="$BUILD_ARTIFACT_DIR/game-store-sim.pck"
CORE_REPORT="$ARTIFACT_DIR/alpha-performance-core.json"
SHELL_REPORT="$ARTIFACT_DIR/alpha-performance-shell.json"
SCREENSHOT_PATH="$ARTIFACT_DIR/performance-main-scene.png"
SCREENSHOT_LOG="$ARTIFACT_DIR/performance-screenshot.log"
PACK_STARTUP_LOG="$ARTIFACT_DIR/performance-pack-startup.log"
SCREENSHOT_THRESHOLD_MS="${ALPHA_SCREENSHOT_THRESHOLD_MS:-20000}"
PACK_STARTUP_THRESHOLD_MS="${ALPHA_PACK_STARTUP_THRESHOLD_MS:-15000}"
MODE="${1:---full}"

cd "$REPO_ROOT"

if [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot binary not found or not executable: $GODOT_BIN" >&2
  echo "Set GODOT_BIN=/path/to/Godot to override." >&2
  exit 1
fi

case "$MODE" in
  --full|--skip-export)
    ;;
  *)
    echo "Usage: scripts/measure_alpha_performance.sh [--full|--skip-export]" >&2
    exit 1
    ;;
esac

now_ms() {
  python3 -c 'import time; print(int(time.time() * 1000))'
}

duration_ms() {
  local started_at="$1"
  local finished_at
  finished_at="$(now_ms)"
  echo $((finished_at - started_at))
}

mkdir -p "$ARTIFACT_DIR"

echo "== Alpha performance core =="
"$GODOT_BIN" \
  --headless \
  --path "$GAME_DIR" \
  --script res://tests/tools/measure_alpha_performance.gd \
  -- \
  --output "$CORE_REPORT"

if [[ "$MODE" != "--skip-export" || ! -s "$PACK_PATH" ]]; then
  echo "== Alpha export pack preparation =="
  "$REPO_ROOT/scripts/verify_desktop_export.sh" --pack-smoke
fi

echo "== Alpha screenshot timing =="
screenshot_start="$(now_ms)"
"$GODOT_BIN" \
  --path "$GAME_DIR" \
  --resolution 1280x720 \
  --fixed-fps 1 \
  --disable-vsync \
  --quiet \
  --script res://tests/tools/capture_main_scene_screenshot.gd \
  -- \
  --output "$SCREENSHOT_PATH" \
  --width 1280 \
  --height 720 \
  --scenario main_scene >"$SCREENSHOT_LOG" 2>&1
screenshot_ms="$(duration_ms "$screenshot_start")"
if (( screenshot_ms > SCREENSHOT_THRESHOLD_MS )); then
  tail -80 "$SCREENSHOT_LOG" >&2
  echo "Screenshot timing ${screenshot_ms}ms exceeded threshold ${SCREENSHOT_THRESHOLD_MS}ms." >&2
  exit 1
fi

echo "== Alpha pack startup timing =="
pack_start="$(now_ms)"
"$GODOT_BIN" --headless --main-pack "$PACK_PATH" --quit-after 1 >"$PACK_STARTUP_LOG" 2>&1
pack_startup_ms="$(duration_ms "$pack_start")"
if (( pack_startup_ms > PACK_STARTUP_THRESHOLD_MS )); then
  tail -80 "$PACK_STARTUP_LOG" >&2
  echo "Pack startup timing ${pack_startup_ms}ms exceeded threshold ${PACK_STARTUP_THRESHOLD_MS}ms." >&2
  exit 1
fi

{
  printf '{\n'
  printf '  "screenshot_main_scene_ms": %s,\n' "$screenshot_ms"
  printf '  "screenshot_threshold_ms": %s,\n' "$SCREENSHOT_THRESHOLD_MS"
  printf '  "pack_startup_ms": %s,\n' "$pack_startup_ms"
  printf '  "pack_startup_threshold_ms": %s,\n' "$PACK_STARTUP_THRESHOLD_MS"
  printf '  "pack_path": "%s",\n' "$PACK_PATH"
  printf '  "core_report": "%s"\n' "$CORE_REPORT"
  printf '}\n'
} >"$SHELL_REPORT"

echo "Alpha performance smoke passed."
echo "Reports: $CORE_REPORT, $SHELL_REPORT"
