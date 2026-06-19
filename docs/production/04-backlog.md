# Backlog

For current status and validation numbers, read `docs/CURRENT_STATE.md` and `docs/status.json` first.

## Current Phase

Design reset documentation is complete. Visual Bible documentation is complete. The first implementation pass for MVP object families is complete and ready for owner visual review.

Goal: turn the owner-provided store/world brief, vertical slice spec, and 300-object asset inventory into implementation work that makes the opening store read as a small, independent, underfunded but functional 2002-2004 game store.

## Active Work

1. Review the Visual Bible object-family pass from [Playable Store Integration Review](../design-implementation/work-packets/04-playable-store-integration-review.md).
2. Compare screenshots against [Screenshot Review](../qa/screenshot-review.md) and [Visual Bible Implementation Review](14-visual-bible-implementation-review.md).
3. Capture owner corrections before moving to tester/beta readiness.
4. If approved, continue into owner-directed polish and beta/tester preparation.
5. If rejected, revise the affected packet docs and run another focused object-family pass.

## Paused Work

- Full catalog visual breadth.
- Customer visual breadth.
- Decoration and upgrade breadth.
- Hidden narrative object breadth.
- Later-era platform rollout.
- Multi-day visual playtest.
- External alpha/beta packaging.

These resume only after the opening store satisfies the design source of truth, completes the Visual Bible implementation review, and the owner approves the next stage.

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
- `docs/production/13-visual-blockers.md` current for design/visual blockers
- `docs/design-source-of-truth/` updated when the owner makes a design decision
- `docs/design-implementation/` updated when execution scope, phase order, evidence, or agent packet rules change
