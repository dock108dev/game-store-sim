#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAME_DIR="$REPO_ROOT/game"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
ARTIFACT_DIR="$REPO_ROOT/artifacts/validation/latest"
SCREENSHOT_DIR="$ARTIFACT_DIR/screenshots"
SCREENSHOT_SCENARIOS=(
  main_scene
  receiving_area
  supplier_message
  suspicious_customer
  register_counter
  customer_queue
  trade_in_offer
  preorder_deposit
  backroom_summary
  release_calendar
  supplier_delivery
  fixture_ghost
  fixture_invalid_ghost
  fixture_rotated_ghost
  fixture_placed
)

cd "$REPO_ROOT"

if [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot binary not found or not executable: $GODOT_BIN" >&2
  echo "Set GODOT_BIN=/path/to/Godot to override." >&2
  exit 1
fi

rm -rf "$ARTIFACT_DIR"
mkdir -p "$SCREENSHOT_DIR"

echo "== Whitespace checks =="
git diff --check -- . ":(exclude)game/addons/**"
git diff --cached --check -- . ":(exclude)game/addons/**"

echo "== Godot editor import/load =="
"$GODOT_BIN" --headless --editor --path "$GAME_DIR" --quit

echo "== Godot runtime quit smoke =="
"$GODOT_BIN" --headless --path "$GAME_DIR" --quit

echo "== Godot main-scene boot smoke =="
"$GODOT_BIN" --headless --path "$GAME_DIR" --quit-after 1

echo "== GUT tests =="
GUT_LOG="$ARTIFACT_DIR/gut-output.log"
"$GODOT_BIN" \
  --headless \
  --path "$GAME_DIR" \
  --script res://addons/gut/gut_cmdln.gd \
  -gconfig=res://.gutconfig.json \
  -gjunit_xml_file="$ARTIFACT_DIR/gut-results.xml" \
  -gexit | tee "$GUT_LOG"

if rg -n "SCRIPT ERROR|ERROR: Failed to load script|Ignoring script" "$GUT_LOG"; then
  echo "GUT emitted script load errors or ignored test scripts." >&2
  exit 1
fi

echo "== Coverage policy =="
python3 "$REPO_ROOT/scripts/check_validation_coverage.py"

echo "== Screenshot capture =="
CAPTURE_LOG="$ARTIFACT_DIR/screenshot-capture.log"
for scenario in "${SCREENSHOT_SCENARIOS[@]}"; do
  "$GODOT_BIN" \
    --path "$GAME_DIR" \
    --resolution 1280x720 \
    --fixed-fps 1 \
    --disable-vsync \
    --quiet \
    --script res://tests/tools/capture_main_scene_screenshot.gd \
    -- \
    --output "$SCREENSHOT_DIR/$scenario.png" \
    --width 1280 \
    --height 720 \
    --scenario "$scenario" | tee -a "$CAPTURE_LOG"
done

if rg -n "SCRIPT ERROR|ERROR:" "$CAPTURE_LOG"; then
  echo "Screenshot capture emitted script errors." >&2
  exit 1
fi

echo "== Screenshot sanity check =="
SCREENSHOT_CHECK_LOG="$ARTIFACT_DIR/screenshot-check.log"
for scenario in "${SCREENSHOT_SCENARIOS[@]}"; do
  "$GODOT_BIN" \
    --headless \
    --path "$GAME_DIR" \
    --quiet \
    --script res://tests/tools/check_png.gd \
    -- \
    --image "$SCREENSHOT_DIR/$scenario.png" \
    --width 1280 \
    --height 720 \
    --min-unique-colors 8 | tee -a "$SCREENSHOT_CHECK_LOG"
done

if rg -n "SCRIPT ERROR|ERROR:" "$SCREENSHOT_CHECK_LOG"; then
  echo "Screenshot sanity check emitted script errors." >&2
  exit 1
fi

echo "== Old-name scan =="
if rg -n "Mallcore|Mallcore Sim|Mall Sim|mall-sim|mallcore-sim" . \
  -g "!game/.godot/**" \
  -g "!game/addons/**" \
  -g "!artifacts/**" \
  -g "!scripts/validate_godot.sh"; then
  echo "Old project naming found." >&2
  exit 1
fi

echo "Validation passed. Artifacts: $ARTIFACT_DIR"
