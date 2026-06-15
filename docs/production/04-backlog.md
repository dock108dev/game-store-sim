# Backlog

For current status and validation numbers, read `docs/CURRENT_STATE.md` and `docs/status.json` first.

## Current Phase

Art language rebuild.

Goal: replace the visible cube/label scene language with a reusable modular art kit that makes the opening mall-entry/storefront/register route read as a simple mid-00s game shop.

## Active Work

1. Finish the docs/status/test overhaul so no active doc routes back to graybox, beta, or broad-production plans.
2. Build `game/scenes/world/art_benchmark/game_shop_art_benchmark.tscn`.
3. Build the first reusable modules under `game/scenes/world/kits/`.
4. Prove the storefront, register, shelf/product, receiving, and staff-threshold kits in sandbox screenshots.
5. Replace the production route in `store_world.tscn` with approved kit instances.
6. Run `scripts/validate_godot.sh`.
7. Review the contact sheet and real-window walk-in before broadening the store.

## Paused Work

- Full catalog visual breadth.
- Customer visual rebuild.
- Decoration and upgrade visuals.
- Multi-day visual playtest.
- External alpha/beta packaging.

These resume only after the modular art-kit baseline is approved.

## Stop Conditions

Stop and ask for owner review if:

- the sandbox still reads as cubes after a serious art-kit pass
- the storefront identity/sign shape needs selection
- a real mesh/modeling workflow decision is required
- changing the visual route would alter gameplay flow
- performance or import constraints make the intended kit impractical

## Finish Gate

Every implementation pass must keep:

- focused GUT tests green for changed contracts
- `scripts/validate_godot.sh` green for production route integration
- `docs/status.json` and `docs/CURRENT_STATE.md` current
- `docs/production/13-alpha-bug-list.md` current for visual blockers
