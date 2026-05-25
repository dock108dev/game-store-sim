#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT_BIN="${GODOT:-${GODOT_EXECUTABLE:-godot}}"

"$GODOT_BIN" --path "$ROOT" --headless --script res://addons/gut/gut_cmdln.gd -- \
	-gconfig=res://.gutconfig.pr-smoke.json -gexit
