# Engine Proof Milestone

## Status

Implemented, macOS-exportable, and locally validated.

## Purpose

This milestone proves that the repo can host a runnable Godot 4 prototype for the hardest first-playable assumptions:

- first-person mall/store shell
- physical item pickup
- shelf slot placement
- movable fixture
- physical customer spawn from mall path
- customer browse and queue state
- register sale that updates inventory and cash
- save/load round trip for item and fixture state
- local validation gate
- macOS export preset and export helper

## Implementation Paths

- Godot project: `game/project.godot`
- Main proof scene: `game/scenes/main/engine_proof.tscn`
- Interactive scene script: `game/scripts/systems/engine_proof_scene.gd`
- Proof state model: `game/scripts/systems/engine_proof_state.gd`
- Headless validation runner: `game/scripts/tools/run_validation.gd`
- Local validation command: `scripts/validate_local.sh`
- macOS export helper: `scripts/export_macos.sh`

## Manual Prototype Controls

Run:

```bash
/Users/michaelfuscoletti/.local/bin/godot --path game
```

Controls:

- `WASD`: move
- mouse click: capture mouse
- `Esc`: release mouse
- `E`: pick up nearest case, place carried case, or complete queued sale
- `P`: price carried used case
- `F`: move and rotate the used shelf fixture
- `O`: open store and spawn a customer from the mall path
- `R`: close register and show daily report
- `K`: save
- `L`: load

## Validation

Run:

```bash
scripts/validate_local.sh
```

The gate checks:

- required docs and project files exist
- Godot 4.6.2 can run the proof model
- starter inventory creates 12 physical item records
- one physical case can be picked up
- a used case can be priced
- the carried case can be stocked into a shelf slot
- a fixture can be moved and rotated
- the store can open
- a customer can spawn from the mall path
- the customer can browse and queue
- the register sale updates item/cash/transaction state
- the day can close into report phase
- save/load restores cash, fixture position, and sold item state
- a proof screenshot artifact is written and sanity checked
- the main scene launches for headless frames without script errors

Artifacts are written to:

```text
artifacts/validation/latest/
```

## macOS Export Status

The repo includes and currently validates:

- `game/export_presets.cfg`
- `scripts/export_macos.sh`
- `GSS_EXPORT_MACOS=1 scripts/validate_local.sh`

The Godot 4.6.2 stable macOS export template is installed locally at:

```text
~/Library/Application Support/Godot/export_templates/4.6.2.stable/macos.zip
```

The current export artifact path is:

```text
game/build/macos/GameStoreSimEngineProof.zip
```

This is a local development export. It is not Developer ID signed or notarized.

## What This Milestone Does Not Prove

- polished art
- final first-person feel
- robust customer navigation around arbitrary layouts
- full inventory UI
- real shelf-density rendering
- code architecture at final scale
- signed/notarized macOS distribution

Those belong to the next production milestone.

## Production Interpretation

This milestone proves technical viability only. It does not define the final visual language, store layout quality, fixture style, lighting standard, product-art standard, or customer presentation standard.

The next milestone should treat the existing scene as disposable technical scaffolding unless a piece directly helps the visual benchmark.
