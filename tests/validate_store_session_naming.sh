#!/usr/bin/env bash
# Fails when runtime/game architecture reintroduces beta-language names.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

EXIT_CODE=0

_fail_block() {
	local title="$1"
	local body="$2"
	if [ -n "$body" ]; then
		echo "FAIL: $title"
		echo "$body"
		EXIT_CODE=1
	fi
}

tracked_paths="$(git ls-files game tests scripts project.godot .gutconfig.json)"

path_violations="$(
	printf "%s\n" "$tracked_paths" \
		| grep -E '(^|/)beta(/|_|\.|$)|beta_hud' \
		| grep -v -E '^game/scenes/stores/retro_games\.tscn$' \
		|| true
)"
_fail_block "tracked runtime paths must not use beta naming" "$path_violations"

class_violations="$(
	rg -n '^class_name[[:space:]]+Beta[A-Za-z0-9_]+' game tests scripts || true
)"
_fail_block "class_name declarations must not start with Beta" "$class_violations"

signal_violations="$(
	rg -n '^signal[[:space:]]+beta_' game tests scripts || true
)"
_fail_block "EventBus/runtime signals must not use beta_ prefixes" "$signal_violations"

hard_reference_violations="$(
	rg -n 'game/scripts/beta|game/content/beta|res://game/scripts/beta|res://game/content/beta|debug/beta_|beta_hud\.gd|beta_run_state|BetaRunState|BetaHUD|BetaDayOneController|BetaRightPanel|BetaEventLogPanel|BetaDaySummaryPanel|BetaManagerNotePanel|BetaModalTheme' game tests scripts project.godot \
		| grep -v -E '^tests/validate_store_session_naming\.sh:' \
		|| true
)"
_fail_block "runtime references must use store-session names" "$hard_reference_violations"

language_violations="$(
	rg -n '\b[Bb]eta\b|beta_|BETA_' game tests scripts project.godot \
		| grep -v -E '^tests/validate_store_session_naming.sh:' \
		|| true
)"
_fail_block "runtime language must not describe playable systems as beta" "$language_violations"

if [ "$EXIT_CODE" -eq 0 ]; then
	echo "PASS: store-session naming audit"
fi

exit "$EXIT_CODE"
