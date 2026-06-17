# Backlog

For current status and validation numbers, read `docs/CURRENT_STATE.md` and `docs/status.json` first.

## Current Phase

Design reset source of truth adopted.

Goal: turn the owner-provided store/world brief, vertical slice spec, and 300-object asset inventory into implementation work that makes the opening store read as a small, independent, underfunded but functional 2002-2004 game store.

## Active Work

1. Keep `docs/design-source-of-truth/` as the active authority.
2. Implement [Asset Inventory Roadmap](../design-source-of-truth/03-asset-inventory-roadmap.md) Phase 1: store shell and first read.
3. Preserve the existing gameplay mechanics while replacing the visual/design surface.
4. Run focused source-of-truth tests after docs or contract changes.
5. Run `scripts/validate_godot.sh` before completion.
6. Review `main_scene.png`, `storefront_entry.png`, `register_counter.png`, `stocked_aisle.png`, `receiving_area.png`, and `backroom_summary.png` against [Screenshot Review](../qa/screenshot-review.md).
7. Capture owner corrections before moving to Phase 2.

## Paused Work

- Full catalog visual breadth.
- Customer visual breadth.
- Decoration and upgrade breadth.
- Hidden narrative object breadth.
- Later-era platform rollout.
- Multi-day visual playtest.
- External alpha/beta packaging.

These resume only after the opening store satisfies the design source of truth and the owner approves the next implementation stage.

## Stop Conditions

Stop and ask for owner review if:

- the implementation conflicts with the source-of-truth era, store size, inventory-access, or starting-density rules
- the storefront identity/sign shape needs owner selection
- a real mesh/modeling workflow decision is required
- changing the visual route would alter gameplay flow
- performance or import constraints make the intended asset plan impractical
- a phase cannot be validated from screenshots or a 1280x720 walk-in

## Finish Gate

Every implementation pass must keep:

- focused GUT tests green for changed contracts
- `scripts/validate_godot.sh` green for production route integration
- `docs/status.json` and `docs/CURRENT_STATE.md` current
- `docs/production/13-alpha-bug-list.md` current for design/visual blockers
- `docs/design-source-of-truth/` updated when the owner makes a design decision
