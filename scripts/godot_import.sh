#!/usr/bin/env bash
## Run Godot editor import so `.godot/imported/` exists (addons, textures, etc.).
## Use before GUT or headless runs on a fresh clone. Requires Godot 4.x editor build.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/godot_resolver.sh"

if ! GODOT_BIN="$(resolve_mallcore_godot)"; then
	echo "ERROR: Godot not found (tried: $(mallcore_configured_godot)). Set GODOT to your 4.x editor binary." >&2
	exit 1
fi

echo "Godot import: project=$ROOT binary=$GODOT_BIN"
exec "$GODOT_BIN" --path "$ROOT" --headless --import
