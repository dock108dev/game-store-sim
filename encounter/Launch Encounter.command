#!/bin/zsh
set -eu
r1_root="${0:A:h}"
exec /Applications/Godot.app/Contents/MacOS/Godot --path "$r1_root" "$@"
