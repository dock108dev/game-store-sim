#!/usr/bin/env bash
# Test runner that uses Godot when available, falls back to static validation.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$ROOT/tests"
source "$ROOT/scripts/artifact_paths.sh"
source "$ROOT/scripts/godot_resolver.sh"
ARTIFACT_ROOT="$(resolve_mallcore_artifact_root "$ROOT")"
export MALLCORE_ARTIFACT_DIR="$ARTIFACT_ROOT"
GUT_LOG_DIR="$(mallcore_artifact_path "$ARTIFACT_ROOT" "logs/gut")"
STATIC_LOG_DIR="$(mallcore_artifact_path "$ARTIFACT_ROOT" "logs/static-validation")"
mkdir -p "$GUT_LOG_DIR" "$STATIC_LOG_DIR"
EXIT_CODE=0

run_static_validator() {
    local label="$1"
    local command_path="$2"
    local log_name="$3"
    echo ""
    echo "$label"
    local validator_log="$STATIC_LOG_DIR/$log_name.log"
    set +e
    bash "$command_path" 2>&1 | tee "$validator_log"
    local status="${PIPESTATUS[0]}"
    set -e
    if [ "$status" -ne 0 ]; then
        EXIT_CODE="$status"
    fi
}

run_static_validator "Running static repo guards..." "$ROOT/scripts/validate_static_repo_guards.sh" "validate_static_repo_guards"
if [ "$EXIT_CODE" -ne 0 ]; then
    exit "$EXIT_CODE"
fi

# Check if Godot is available
if GODOT_BIN="$(resolve_mallcore_godot)"; then
    LOG_FILE="$GUT_LOG_DIR/test_run.log"
    : >"$LOG_FILE"

    echo "Godot found — importing project assets (addons/GUT textures, etc.)..."
    "$GODOT_BIN" --path "$ROOT" --headless --import 2>/dev/null

    echo "Running resource integrity checks..."
    set +e
    MALLCORE_SKIP_IMPORT=1 bash "$ROOT/scripts/validate_resource_integrity.sh" \
        2>&1 | tee "$STATIC_LOG_DIR/validate_resource_integrity.log"
    RESOURCE_STATUS="${PIPESTATUS[0]}"
    set -e
    if [ "$RESOURCE_STATUS" -ne 0 ]; then
        exit "$RESOURCE_STATUS"
    fi

    echo "Seeding GUT editor environment..."
    "$GODOT_BIN" --path "$ROOT" --headless \
        --script res://tests/setup_gut_env.gd 2>/dev/null || true

    echo "Running GDScript tests... (full output → $LOG_FILE)"
    # Redirect stderr (Godot engine warnings/errors) to the log file only.
    # Stdout (GUT results) is tee'd so the terminal shows the pass/fail summary
    # without being flooded by thousands of push_warning lines.
    "$GODOT_BIN" --path "$ROOT" --headless --script res://addons/gut/gut_cmdln.gd \
        2>>"$LOG_FILE" | tee -a "$LOG_FILE" | grep -E "^\*|passed\.|failed\.|Passing|Failing|Run Summary|Scripts|Tests|Time|Risky"
    EXIT_CODE="${PIPESTATUS[0]}"

    if [ -f "$ROOT/game/tests/run_tests.gd" ]; then
        "$GODOT_BIN" --path "$ROOT" --headless --script res://game/tests/run_tests.gd \
            2>>"$LOG_FILE" | tee -a "$LOG_FILE" | grep -E "^\*|passed\.|failed\.|Passing|Failing|Run Summary|Scripts|Tests|Time|Risky"
        [ "${PIPESTATUS[0]}" -ne 0 ] && EXIT_CODE="${PIPESTATUS[0]}"
    fi
else
    if [ -n "${GODOT:-}" ] || [ -n "${GODOT_EXECUTABLE:-}" ]; then
        echo "ERROR: GODOT/GODOT_EXECUTABLE is set (\"${GODOT:-${GODOT_EXECUTABLE:-}}\") but no executable Godot binary was found." >&2
        echo "Install Godot 4.6.2 and point GODOT at it, then re-run." >&2
        exit 1
    fi
    echo "Godot not found — running static validation tests only (install Godot 4.6.2 for full suite)..."
    echo ""
fi

# Run maintained shell validators. Archived acceptance scripts remain available
# to run directly, but they are not part of the default regression gate because
# several encode older one-off task snapshots rather than current repo contracts.
_should_run_default_validator() {
    local script_name
    script_name="$(basename "$1")"
    case "$script_name" in
        validate_issue_*) return 1 ;;
    esac
    return 0
}

for test_script in "$TESTS_DIR"/validate_*.sh; do
    if [ -f "$test_script" ] && _should_run_default_validator "$test_script"; then
        echo ""
        VALIDATOR_LOG="$STATIC_LOG_DIR/$(basename "$test_script" .sh).log"
        set +e
        bash "$test_script" 2>&1 | tee "$VALIDATOR_LOG"
        STATUS="${PIPESTATUS[0]}"
        set -e
        [ "$STATUS" -ne 0 ] && EXIT_CODE="$STATUS"
    fi
done

# Phase 0.1 SSOT tripwires (see docs/audits/phase0-ui-integrity.md P2.1).
SCRIPTS_DIR="$ROOT/scripts"
for tripwire in validate_translations.sh validate_single_store_ui.sh validate_tutorial_single_source.sh; do
    if [ -x "$SCRIPTS_DIR/$tripwire" ]; then
        echo ""
        TRIPWIRE_LOG="$STATIC_LOG_DIR/${tripwire%.sh}.log"
        set +e
        bash "$SCRIPTS_DIR/$tripwire" 2>&1 | tee "$TRIPWIRE_LOG"
        STATUS="${PIPESTATUS[0]}"
        set -e
        [ "$STATUS" -ne 0 ] && EXIT_CODE="$STATUS"
    fi
done

exit $EXIT_CODE
