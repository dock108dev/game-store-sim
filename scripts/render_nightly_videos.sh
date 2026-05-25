#!/usr/bin/env bash
## Render advisory Movie Maker scenario videos into the automation artifact tree.
set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$PROJECT_ROOT/scripts/artifact_paths.sh"

ARTIFACT_ROOT="$(resolve_mallcore_artifact_root "$PROJECT_ROOT")"
OUTPUT_ROOT="${OUTPUT_ROOT:-$(mallcore_artifact_path "$ARTIFACT_ROOT" "videos/scenario/nightly")}"
LOG_ROOT="${LOG_ROOT:-$(mallcore_artifact_path "$ARTIFACT_ROOT" "logs/scenario/nightly-videos")}"
FPS="${FPS:-60}"
SCENARIO_RUNNER="${SCENARIO_RUNNER:-res://tests/movie_scenarios/movie_scenario_runner.tscn}"
REQUESTED_SCENARIO="${SCENARIO:-}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-600}"

SCENARIOS=(
	"store_opening:720"
	"checkout_pressure:900"
	"upgrade_purchase_loop:840"
	"toast_readability_pass:600"
	"objective_rail_progression:780"
	"gallery_walkthrough_smoke:840"
)

mkdir -p "$OUTPUT_ROOT" "$LOG_ROOT"

_timeout_command() {
	if command -v timeout >/dev/null 2>&1; then
		printf '%s\n' "timeout"
		return 0
	fi
	if command -v gtimeout >/dev/null 2>&1; then
		printf '%s\n' "gtimeout"
		return 0
	fi
	return 1
}

_scenario_known() {
	local candidate="$1"
	local entry=""
	local scenario_id=""
	for entry in "${SCENARIOS[@]}"; do
		IFS=":" read -r scenario_id _duration_frames <<<"$entry"
		if [ "$candidate" = "$scenario_id" ]; then
			return 0
		fi
	done
	return 1
}

_run_godot_movie() {
	local output_file="$1"
	local scenario_id="$2"
	local duration_frames="$3"
	shift 3
	local timeout_bin=""
	if timeout_bin="$(_timeout_command)"; then
		"$timeout_bin" "$TIMEOUT_SECONDS" bash "$PROJECT_ROOT/scripts/godot_exec.sh" \
			--path "$PROJECT_ROOT" \
			--write-movie "$output_file" \
			--fixed-fps "$FPS" \
			"$SCENARIO_RUNNER" \
			-- \
			--movie-scenario "$scenario_id" \
			--duration-frames "$duration_frames" \
			"$@"
		return $?
	fi
	bash "$PROJECT_ROOT/scripts/godot_exec.sh" \
		--path "$PROJECT_ROOT" \
		--write-movie "$output_file" \
		--fixed-fps "$FPS" \
		"$SCENARIO_RUNNER" \
		-- \
		--movie-scenario "$scenario_id" \
		--duration-frames "$duration_frames" \
		"$@"
}

if [ -n "$REQUESTED_SCENARIO" ] && ! _scenario_known "$REQUESTED_SCENARIO"; then
	echo "ERROR: unknown scenario id '$REQUESTED_SCENARIO'" >&2
	echo "Accepted scenario ids:" >&2
	printf '  %s\n' "${SCENARIOS[@]%%:*}" >&2
	exit 64
fi

rendered_count=0
for entry in "${SCENARIOS[@]}"; do
	IFS=":" read -r scenario_id duration_frames <<<"$entry"
	if [ -n "$REQUESTED_SCENARIO" ] && [ "$REQUESTED_SCENARIO" != "$scenario_id" ]; then
		continue
	fi

	output_file="$OUTPUT_ROOT/${scenario_id}.avi"
	log_file="$LOG_ROOT/${scenario_id}.log"
	rm -f "$output_file" "$log_file"

	echo "Rendering Movie Maker scenario '$scenario_id' (${duration_frames} frames at ${FPS} FPS)"
	set +e
	_run_godot_movie "$output_file" "$scenario_id" "$duration_frames" >"$log_file" 2>&1
	status=$?
	set -e
	if [ "$status" -ne 0 ]; then
		if [ "$status" -eq 124 ]; then
			echo "ERROR: runner timeout for scenario '$scenario_id' after ${TIMEOUT_SECONDS}s" >&2
		elif grep -q "unknown_scenario_id" "$log_file"; then
			echo "ERROR: unknown scenario id '$scenario_id'" >&2
		else
			echo "ERROR: movie runner failed for scenario '$scenario_id' (exit $status)" >&2
		fi
		echo "Log: $log_file" >&2
		exit "$status"
	fi

	if [ ! -f "$output_file" ]; then
		echo "ERROR: missing movie file for scenario '$scenario_id': $output_file" >&2
		echo "Log: $log_file" >&2
		exit 66
	fi
	if [ ! -s "$output_file" ]; then
		echo "ERROR: empty movie file for scenario '$scenario_id': $output_file" >&2
		echo "Log: $log_file" >&2
		exit 67
	fi
	rendered_count=$((rendered_count + 1))
	echo "Rendered: $output_file"
done

if [ "$rendered_count" -eq 0 ]; then
	echo "ERROR: no movie scenarios rendered" >&2
	exit 65
fi

echo "Nightly Movie Maker rendering complete. rendered_count=$rendered_count"
