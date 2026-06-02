#!/usr/bin/env bash
## Run the display-backed store visual sweep and optional golden screenshot diff.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/godot_resolver.sh"

GODOT_VERSION_BUCKET="${GODOT_VERSION:-4.6.2-stable}"
ARTIFACT_ROOT="${MALLCORE_ARTIFACT_DIR:-$REPO_ROOT/artifacts}"
RAW_MODE="${1:-${MALLCORE_VISUAL_SWEEP_MODE:-first-ten-seconds}}"
case "$RAW_MODE" in
	first|first-ten|first-ten-seconds|first_ten_seconds)
		CAPTURE_TARGET="first_ten_seconds"
		DIFF_SUITE="first-ten-seconds"
		SUITE_DIR="retro_games_day_one"
		BASELINE_DIR="${MALLCORE_VISUAL_BASELINE_DIR:-$REPO_ROOT/tests/visual/baselines/retro_games_day_one/$GODOT_VERSION_BUCKET/linux}"
		;;
	overhaul|overhaul-acceptance|overhaul_acceptance)
		CAPTURE_TARGET="overhaul_acceptance"
		DIFF_SUITE="overhaul-acceptance"
		SUITE_DIR="retro_games_overhaul_acceptance"
		BASELINE_DIR="${MALLCORE_OVERHAUL_VISUAL_BASELINE_DIR:-$REPO_ROOT/tests/visual/baselines/retro_games_overhaul_acceptance/$GODOT_VERSION_BUCKET/linux}"
		;;
	*)
		echo "ERROR: Unknown visual sweep mode '$RAW_MODE'. Use first-ten-seconds or overhaul-acceptance." >&2
		exit 1
		;;
esac
CURRENT_DIR="$ARTIFACT_ROOT/visual_sweep/$SUITE_DIR/current"
DIFF_DIR="$ARTIFACT_ROOT/visual_sweep/$SUITE_DIR/diff"
REVIEW_MANIFEST="$ARTIFACT_ROOT/visual_sweep/$SUITE_DIR/review_manifest.json"
DIFF_MANIFEST="$ARTIFACT_ROOT/visual_sweep/$SUITE_DIR/diff_manifest.json"

if ! GODOT_BIN="$(resolve_mallcore_godot)"; then
	echo "ERROR: Godot not found (tried: $(mallcore_configured_godot)). Set GODOT to your 4.x editor binary." >&2
	exit 1
fi

echo "Visual sweep validation channels: authored-full scene checks; store-session runtime checks; reference-visible visual review; manual route captures."
echo "Fresh first-ten-seconds captures are required for geometry, camera, readability, visual-scope, and prop changes."
echo "Overhaul acceptance captures use the separate '$SUITE_DIR' target for non-first-ten-seconds states."
echo "Spawn acceptance evidence: display-backed 1280x720 gl_compatibility capture at current/01_spawn_first_look.png."
echo "Originality closeout: bash scripts/validate_originality.sh and bash tests/validate_original_content.sh."

mkdir -p "$CURRENT_DIR" "$DIFF_DIR"
GODOT_SWEEP_ARGS=(
	--path "$REPO_ROOT"
	--rendering-method gl_compatibility
	--script res://tests/visual/capture_store_visual_sweep.gd
)

if [[ "$(uname -s)" == "Linux" && -z "${DISPLAY:-}" ]]; then
	if ! command -v xvfb-run >/dev/null 2>&1; then
		echo "ERROR: xvfb-run is required for display-backed visual captures on Linux CI." >&2
		exit 1
	fi
	MALLCORE_VISUAL_SWEEP_TARGET="$CAPTURE_TARGET" \
		xvfb-run -a --server-args="-screen 0 1920x1080x24 +extension GLX +render -noreset" \
		"$GODOT_BIN" "${GODOT_SWEEP_ARGS[@]}"
else
	MALLCORE_VISUAL_SWEEP_TARGET="$CAPTURE_TARGET" "$GODOT_BIN" "${GODOT_SWEEP_ARGS[@]}"
fi

python3 "$REPO_ROOT/tests/visual/diff_screenshots.py" \
	--baseline "$BASELINE_DIR" \
	--current "$CURRENT_DIR" \
	--diff "$DIFF_DIR" \
	--manifest "$DIFF_MANIFEST" \
	--review-manifest "$REVIEW_MANIFEST" \
	--suite "$DIFF_SUITE" \
	--allow-missing-baseline
