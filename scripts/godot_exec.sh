#!/usr/bin/env bash
## Resolve a Godot editor binary and execute it with the provided arguments.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/godot_resolver.sh"

if ! GODOT_BIN="$(resolve_mallcore_godot)"; then
	echo "ERROR: Godot not found (tried: $(mallcore_configured_godot)). Set GODOT to your 4.x editor binary." >&2
	exit 1
fi

exec "$GODOT_BIN" "$@"
