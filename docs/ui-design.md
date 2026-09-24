# Replay Junction UI design

Use the [design requirements](ui-design-requirements.md) and `encounter/glass_ui.gd` when changing the interface.

## Layout and behavior

The illustrated shop uses native Godot controls styled with translucent `StyleBoxFlat` surfaces. Text needs sufficiently opaque backing; these surfaces do not provide browser backdrop blur or native Apple materials. `encounter/main.gd` applies the theme.

Bills and rack capacity have stable header positions. Actor labels sit above bodies; decorative elements ignore input. Entry, recovery and help dialogs provide keyboard focus.

Price entry precedes Apply. Finances leads with cash, operating result and unpaid bills, with arithmetic behind Calculation details. Copy records retain condition, availability, cost and unset prices. Supplier blockers and release dates remain visible. Preserve shop geometry, illustrated assets, gameplay and saved values.

## Visual checks

Check the affected screens at supported sizes, including keyboard focus, long content, disabled actions and error recovery. Existing review records are in [UI verification](ui-verification.md).
