#!/usr/bin/env bash
## Capture the reusable first-person roam validation route.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/godot_resolver.sh"

RUN_LABEL="${1:-control}"
case "$RUN_LABEL" in
	control|candidate) ;;
	*)
		echo "ERROR: run label must be 'control' or 'candidate'." >&2
		exit 1
		;;
esac

if ! GODOT_BIN="$(resolve_mallcore_godot)"; then
	echo "ERROR: Godot not found (tried: $(mallcore_configured_godot)). Set GODOT to your 4.x editor binary." >&2
	exit 1
fi

ARTIFACT_ROOT="${MALLCORE_ARTIFACT_DIR:-$REPO_ROOT/artifacts}"
CONTROL_DIR="$ARTIFACT_ROOT/fp_roam_validation/control/current"
CANDIDATE_DIR="$ARTIFACT_ROOT/fp_roam_validation/candidate/current"
COMPARE_DIR="$ARTIFACT_ROOT/fp_roam_validation/compare"
COMPARE_MANIFEST="$COMPARE_DIR/compare_manifest.json"

echo "FP roam validation run: $RUN_LABEL"
echo "Control captures:   $CONTROL_DIR"
echo "Candidate captures: $CANDIDATE_DIR"

GODOT_ARGS=(
	--path "$REPO_ROOT"
	--rendering-method gl_compatibility
	--script res://tests/visual/capture_fp_roam_validation.gd
)

if [[ "$(uname -s)" == "Linux" && -z "${DISPLAY:-}" ]]; then
	if ! command -v xvfb-run >/dev/null 2>&1; then
		echo "ERROR: xvfb-run is required for display-backed FP roam captures on Linux CI." >&2
		exit 1
	fi
	MALLCORE_ARTIFACT_DIR="$ARTIFACT_ROOT" MALLCORE_FP_ROAM_RUN="$RUN_LABEL" \
		xvfb-run -a --server-args="-screen 0 1280x720x24 +extension GLX +render -noreset" \
		"$GODOT_BIN" "${GODOT_ARGS[@]}"
else
	MALLCORE_ARTIFACT_DIR="$ARTIFACT_ROOT" MALLCORE_FP_ROAM_RUN="$RUN_LABEL" \
		"$GODOT_BIN" "${GODOT_ARGS[@]}"
fi

if [[ "$RUN_LABEL" == "candidate" && -d "$CONTROL_DIR" ]]; then
	python3 "$REPO_ROOT/tests/visual/compare_fp_roam_validation.py" \
		--control "$CONTROL_DIR" \
		--candidate "$CANDIDATE_DIR" \
		--out "$COMPARE_DIR" \
		--manifest "$COMPARE_MANIFEST"
elif [[ "$RUN_LABEL" == "candidate" ]]; then
	echo "No control captures found yet; run: bash scripts/run_fp_roam_validation.sh control"
fi
