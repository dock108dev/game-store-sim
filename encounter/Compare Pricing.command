#!/bin/zsh
set -eu
pricing_root="${0:A:h}"
echo 'Pricing comparison: same fresh day-1 visitor; separate demo save.'
echo 'Choose low ($16.99), reference ($21.99), or high ($26.99):'
read pricing_choice
case "$pricing_choice" in
 low|reference|high) ;;
 *) echo 'Enter low, reference, or high.'; exit 1 ;;
esac
exec /Applications/Godot.app/Contents/MacOS/Godot --path "$pricing_root" -- --pricing-demo="$pricing_choice"
