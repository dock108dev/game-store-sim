#!/usr/bin/env bash
# Headless interaction audit runner + Runtime Truth gate.
#
# Structured `AUDIT: PASS <name>` / `AUDIT: FAIL <name>` lines emitted
# by AuditLog are the only accepted checkpoint source. They are compared
# against the required-checkpoint manifest derived from
# docs/audit/pass-fail-matrix.md, with optional whitelisting via
# tests/audit_known_fail.txt.
#
# Final summary line is exactly one `AUDIT: N/M verified`. Exit 1 if any
# required checkpoint is unaccounted for, or any AUDIT: FAIL line appears
# for a checkpoint not whitelisted in known-fail.
#
# Test hook: set AUDIT_SKIP_RUN=1 and AUDIT_LOG=<path> to skip the headless
# Godot run and gate against an existing log file (used by
# shell validator tests).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/artifact_paths.sh"
source "$ROOT/scripts/godot_resolver.sh"
ARTIFACT_ROOT="$(resolve_mallcore_artifact_root "$ROOT")"
export MALLCORE_ARTIFACT_DIR="$ARTIFACT_ROOT"
SCENARIO_LOG_DIR="$(mallcore_artifact_path "$ARTIFACT_ROOT" "logs/scenario")"
mkdir -p "$SCENARIO_LOG_DIR"
AUDIT_LOG="${AUDIT_LOG:-$SCENARIO_LOG_DIR/audit.log}"
REQUIRED_FILE="${AUDIT_REQUIRED_FILE:-$ROOT/tests/audit_required_checkpoints.txt}"
METADATA_FILE="${AUDIT_METADATA_FILE:-$ROOT/tests/audit_checkpoint_metadata.json}"
SCENARIO_ID="${AUDIT_SCENARIO_ID:-runtime_audit}"
SCENARIO_SEED="${AUDIT_SCENARIO_SEED:-}"
if [ -n "${AUDIT_KNOWN_FAIL_FILE:-}" ]; then
	KNOWN_FAIL_FILE="$AUDIT_KNOWN_FAIL_FILE"
elif [ -n "${AUDIT_REQUIRED_FILE:-}" ]; then
	KNOWN_FAIL_FILE="$ROOT/tests/audit_scenarios/${SCENARIO_ID}_known_fail.txt"
else
	KNOWN_FAIL_FILE="$ROOT/tests/audit_known_fail.txt"
fi
EXIT_CODE=0

# ── Run headless audit (unless test hook bypassed) ────────────────────────────
if [ "${AUDIT_SKIP_RUN:-0}" != "1" ]; then
	if ! GODOT_BIN="$(resolve_mallcore_godot)"; then
		if [ -n "${GODOT:-}" ] || [ -n "${GODOT_EXECUTABLE:-}" ]; then
			echo "ERROR: GODOT/GODOT_EXECUTABLE is set but no executable binary found." >&2
			exit 1
		fi
		if [ "${CI:-false}" = "true" ]; then
			echo "ERROR: Godot not found in CI; interaction audit cannot be skipped." >&2
			exit 1
		fi
		echo "WARNING: Godot not found — skipping headless audit run." >&2
		echo "Install Godot 4.6.2 and set GODOT to run the full audit." >&2
		exit 0
	fi

	echo "=== Interaction Audit ==="
	echo "Importing project assets..."
	"$GODOT_BIN" --path "$ROOT" --headless --import 2>/dev/null || true

	echo "Seeding GUT editor environment..."
	"$GODOT_BIN" --path "$ROOT" --headless \
		--script res://tests/setup_gut_env.gd 2>/dev/null || true

	echo "Running audit checkpoint tests..."
	"$GODOT_BIN" --path "$ROOT" --headless \
		--script res://addons/gut/gut_cmdln.gd -- \
		-gconfig=res://.gutconfig.json \
		-ginclude_subdirs \
		-gdir=res://tests/gut \
		-gprefix=test_audit \
		-gexit \
		2>&1 | tee "$AUDIT_LOG" || true
fi

if [ ! -f "$AUDIT_LOG" ]; then
	echo "ERROR: audit log not found at $AUDIT_LOG" >&2
	exit 1
fi

# ── Load required + known-fail manifests ──────────────────────────────────────
_strip_manifest() {
	# stdin: file with comments/blank lines; stdout: bare entries.
	sed -e 's/#.*$//' -e 's/[[:space:]]\+$//' -e 's/^[[:space:]]\+//' \
		| grep -v '^$' || true
}

_list_contains() {
	local needle="$1"
	shift
	local item
	for item in "$@"; do
		if [ "$item" = "$needle" ]; then
			return 0
		fi
	done
	return 1
}

_text_contains_line() {
	local needle="$1"
	local haystack="$2"
	printf '%s' "$haystack" | grep -Fxq "$needle"
}

if [ ! -f "$REQUIRED_FILE" ]; then
	echo "ERROR: required-checkpoint manifest missing: $REQUIRED_FILE" >&2
	exit 1
fi

REQUIRED_LIST=()
while IFS= read -r ck; do
	REQUIRED_LIST+=("$ck")
done < <(_strip_manifest < "$REQUIRED_FILE")

KNOWN_FAIL_LIST=()
if [ -f "$KNOWN_FAIL_FILE" ]; then
	while IFS= read -r ck; do
		KNOWN_FAIL_LIST+=("$ck")
	done < <(_strip_manifest < "$KNOWN_FAIL_FILE")
fi

# Orphan check: known-fail entries must reference a required checkpoint.
if [ "${#KNOWN_FAIL_LIST[@]}" -gt 0 ]; then
	for ck in "${KNOWN_FAIL_LIST[@]}"; do
		if ! _list_contains "$ck" "${REQUIRED_LIST[@]}"; then
			echo "AUDIT FAILED: known-fail entry '$ck' is not in required manifest." >&2
			EXIT_CODE=1
		fi
	done
fi

# ── Parse structured AUDIT: PASS|FAIL <name> lines (AuditLog) ─────────────────
AUDIT_PASS_TEXT=""
AUDIT_FAIL_TEXT=""

while IFS= read -r line; do
	if [[ "$line" =~ ^AUDIT:\ PASS\ ([A-Za-z0-9_]+) ]]; then
		AUDIT_PASS_TEXT="${AUDIT_PASS_TEXT}${BASH_REMATCH[1]}"$'\n'
		continue
	fi
	if [[ "$line" =~ ^AUDIT:\ FAIL\ ([A-Za-z0-9_]+) ]]; then
		AUDIT_FAIL_TEXT="${AUDIT_FAIL_TEXT}${BASH_REMATCH[1]}"$'\n'
		continue
	fi
done < "$AUDIT_LOG"

# Also count GUT failures
GUT_FAIL_COUNT=$(grep -c "^FAILED\b\|^ *[0-9]* failed\b\|Tests: [0-9]*, Passing: [0-9]*, Failing: [1-9]" "$AUDIT_LOG" 2>/dev/null || true)

if [ "$GUT_FAIL_COUNT" -gt 0 ]; then
	echo "AUDIT FAILED: $GUT_FAIL_COUNT GUT test failure(s)." >&2
	EXIT_CODE=1
fi

# ── Runtime Truth gate (matrix-derived manifest) ──────────────────────────────
M=${#REQUIRED_LIST[@]}
N=0
MISSING=("")
for ck in "${REQUIRED_LIST[@]}"; do
	if _text_contains_line "$ck" "$AUDIT_PASS_TEXT"; then
		N=$((N + 1))
	elif [ "${#KNOWN_FAIL_LIST[@]}" -gt 0 ] && _list_contains "$ck" "${KNOWN_FAIL_LIST[@]}"; then
		: # whitelisted — counted toward M but not toward N
	else
		MISSING+=("$ck")
	fi
done

# Surface unexpected AUDIT: FAIL lines (real runtime failures).
while IFS= read -r ck; do
	if [ -z "$ck" ]; then
		continue
	fi
	if [ "${#KNOWN_FAIL_LIST[@]}" -eq 0 ] || ! _list_contains "$ck" "${KNOWN_FAIL_LIST[@]}"; then
		echo "AUDIT FAILED: AUDIT: FAIL '$ck' emitted (not whitelisted)." >&2
		EXIT_CODE=1
	fi
done <<< "$AUDIT_FAIL_TEXT"

# Surface required checkpoints that have neither PASS nor known-fail entry.
for ck in "${MISSING[@]}"; do
	if [ -z "$ck" ]; then
		continue
	fi
	echo "AUDIT FAILED: required checkpoint '$ck' produced no AUDIT: PASS line and is not in tests/audit_known_fail.txt." >&2
	echo "              Either implement the emitter or whitelist it explicitly." >&2
	EXIT_CODE=1
done

# Detect stale known-fail entries (whitelisted but actually emitted PASS).
if [ "${#KNOWN_FAIL_LIST[@]}" -gt 0 ]; then
	for ck in "${KNOWN_FAIL_LIST[@]}"; do
		if _text_contains_line "$ck" "$AUDIT_PASS_TEXT"; then
			echo "AUDIT FAILED: '$ck' emitted PASS but is still listed in tests/audit_known_fail.txt — remove it." >&2
			EXIT_CODE=1
		fi
	done
fi

# Single canonical summary line — parsed by CI.
echo "AUDIT: $N/$M verified"

if command -v python3 &>/dev/null; then
	if ! python3 "$ROOT/scripts/generate_audit_scenario_report.py" \
		--audit-log "$AUDIT_LOG" \
		--artifact-root "$ARTIFACT_ROOT" \
		--required-file "$REQUIRED_FILE" \
		--known-fail-file "$KNOWN_FAIL_FILE" \
		--metadata-file "$METADATA_FILE" \
		--scenario-id "$SCENARIO_ID" \
		--seed "$SCENARIO_SEED"; then
		echo "AUDIT FAILED: scenario report generation failed." >&2
		EXIT_CODE=1
	fi
else
	echo "AUDIT FAILED: python3 is required to generate scenario reports." >&2
	EXIT_CODE=1
fi

if [ "$EXIT_CODE" -eq 0 ]; then
	echo "AUDIT PASSED"
fi

exit $EXIT_CODE
