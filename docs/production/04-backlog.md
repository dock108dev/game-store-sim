# Backlog

For current status and validation numbers, read `docs/CURRENT_STATE.md` and `docs/status.json` first.

## Current Phase

Art language rebuild: first kit integrated, pending owner validation.

Goal: validate whether the new reusable modular art kit makes the opening mall-entry/storefront/register route read as a simple mid-00s game shop.

## Active Work

1. Run full validation after the integrated art-kit route.
2. Review the production contact sheet, especially `main_scene.png`, `storefront_entry.png`, `register_counter.png`, `receiving_area.png`, and `backroom_summary.png`.
3. Capture sandbox views from `game/scenes/world/art_benchmark/game_shop_art_benchmark.tscn`.
4. Complete a real-window 1280x720 walk-in from mall spawn to register.
5. Record owner corrections or approval before broadening the store.

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
