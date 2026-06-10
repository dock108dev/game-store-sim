# Game Store Sim Godot Project

This directory is the Godot project root.

## Godot Version

Pinned target: Godot 4.6.3 stable.

The local app currently used by validation is `/Applications/Godot.app` at `4.6.2.stable.official.71f334935`. The project validates there today, but active development should prefer the pinned 4.6.3 stable target when the local app is upgraded.

## Mandatory Validation

Run the local gate from the repository root before finishing any implementation:

```text
scripts/validate_godot.sh
```

The script assumes Godot is available at `/Applications/Godot.app/Contents/MacOS/Godot`. Override that with `GODOT_BIN=/path/to/Godot scripts/validate_godot.sh` when needed.

Validation artifacts are written to `artifacts/validation/latest/` and are intentionally untracked.

## Input Target

Keyboard/mouse desktop play. The current interaction model is center-reticle targeting with left click as the primary action. Escape releases mouse capture, and click recaptures.

## Current Structure

- `scenes/`: Godot scenes for world, player, UI, customers, and props.
- `scripts/`: GDScript systems grouped by interaction, inventory, economy, customers, store layout, save, releases, suppliers, UI, and narrative.
- `data/`: Godot resources for products, fixtures, supplier lots, and release calendar entries.
- `tests/`: GUT tests, validation scenario manifests, script coverage mapping, and screenshot validation tools.

## Current Gameplay Systems

- First-person movement and click-first raycast interaction.
- Product-backed used-game item instances with unique IDs, prices, cost basis, serial metadata, and locations.
- Receiving box pickup, bounded carry stack, held-item pricing, shelf stocking, and apply-to-matching pricing.
- Buyer customers with price sensitivity, product selection across multiple copies, movement to item, and register queueing.
- Register sales, trade-ins, preorder deposits, and service completion.
- Backroom computer for reports, inventory summaries, reorder suggestions, supplier orders, release planning, allocation commitments, launch-day outcomes, and storage fixture placement.
- Fixture ordering, ghost preview, valid/invalid placement, movement, rotation, snap, and placement confirmation.
- Hidden event log, supplier message, mismatched serial item, suspicious customer cue, and hidden evidence storage.
- Codec-level persistence smoke coverage for session, ledger, inventory, and fixture order state.
