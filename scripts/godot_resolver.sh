#!/usr/bin/env bash
## Shared Godot editor binary resolution for local scripts and CI runners.

mallcore_configured_godot() {
	printf '%s\n' "${GODOT:-${GODOT_EXECUTABLE:-godot}}"
}

resolve_mallcore_godot() {
	local configured
	configured="$(mallcore_configured_godot)"
	local candidates=(
		"$configured"
		"/Applications/Godot.app/Contents/MacOS/Godot"
		"$HOME/Applications/Godot.app/Contents/MacOS/Godot"
	)
	local candidate=""
	for candidate in "${candidates[@]}"; do
		if [ -x "$candidate" ]; then
			echo "$candidate"
			return 0
		fi
		if command -v "$candidate" >/dev/null 2>&1; then
			command -v "$candidate"
			return 0
		fi
	done
	return 1
}
