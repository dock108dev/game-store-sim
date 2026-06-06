# Game Store Sim Godot Project

This directory is the Godot project root.

## Godot Version

Pinned target: Godot 4.6.3 stable.

The local app detected during setup was `/Applications/Godot.app` at `4.6.2.stable.official.71f334935`. The bare project contains no 4.6.3-specific assets or scripts yet, but active development should use 4.6.3 stable so generated files and project metadata stay consistent.

## Mandatory Validation

Run the local gate from the repository root before finishing any implementation:

```text
scripts/validate_godot.sh
```

The script assumes Godot is available at `/Applications/Godot.app/Contents/MacOS/Godot`. Override that with `GODOT_BIN=/path/to/Godot scripts/validate_godot.sh` when needed.

Validation artifacts are written to `artifacts/validation/latest/` and are intentionally untracked.

## Input Target

Keyboard/mouse only for the first playable and early production slices. Controller support is intentionally out of scope until the core retail loop is proven.

## Structure

- `scenes/`: Godot scenes grouped by world, player, store, UI, customers, and props.
- `scripts/`: GDScript systems grouped by interaction, inventory, economy, customers, store layout, save, and narrative.
- `data/`: Data-driven definitions for products, fixtures, customers, dialogue, suppliers, and progression.
- `assets/`: Game assets grouped by models, materials, textures, and audio.
- `tests/`: GUT tests, validation manifests, and screenshot validation tools.

## First Slice

The first implementation slice should stay narrow:

1. Graybox store.
2. Keyboard/mouse first-person controller.
3. Interaction raycast and prompt.
4. One inspectable used-game prop.
5. One placeholder shelf.
6. One register placeholder.
