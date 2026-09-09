#!/bin/zsh
set -eu
sample_root="${0:A:h}"
godot_bin="/Applications/Godot.app/Contents/MacOS/Godot"
engine_version="$($godot_bin --version)"
if [[ "$engine_version" != 4.6.2.stable.official.71f334935 ]]; then
  print "This sample requires Godot 4.6.2 Standard. Found: $engine_version"
  exit 1
fi
"$godot_bin" --headless --path "$sample_root" --editor --import --quit > "$sample_root/evidence/launch-import.log" 2>&1
exec "$godot_bin" --path "$sample_root" "$@"
