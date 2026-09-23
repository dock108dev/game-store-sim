#!/bin/zsh
set -eu
assortment_root="${0:A:h}"
echo 'Same day-2 visitors and prices: Curb $21.99, Tide $19.99, Orbit $12.99.'
echo 'Choose stocked (2 Curb / 1 Tide / 1 Orbit) or missing (2 Curb / 2 Tide):'
read assortment_choice
case "$assortment_choice" in
 stocked|missing) ;;
 *) echo 'Enter stocked or missing.'; exit 1 ;;
esac
exec /Applications/Godot.app/Contents/MacOS/Godot --path "$assortment_root" -- --assortment-demo="$assortment_choice"
