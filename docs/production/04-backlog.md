# Backlog

For current status and validation numbers, read `docs/CURRENT_STATE.md` and `docs/status.json` first.

## Current Phase

Design reset implementation planning is complete.

Goal: turn the owner-provided store/world brief, vertical slice spec, and 300-object asset inventory into implementation work that makes the opening store read as a small, independent, underfunded but functional 2002-2004 game store.

## Active Work

1. Start implementation work from [Work Packet Index](../design-implementation/work-packets/00-packet-index.md).
2. Complete [Visual Module Foundation Packet](../design-implementation/work-packets/01-visual-module-foundation.md).
3. Continue through packets 02-08 until validation fails, a blocker appears, or owner input is required.
4. Preserve existing gameplay mechanics while replacing the visual/design surface.
5. Keep `docs/design-source-of-truth/` as the design canon for owner decisions and quality bar.
6. Run focused tests for changed scene/doc contracts during implementation.
7. Run `scripts/validate_godot.sh` before implementation completion.
8. Review required screenshots against [Validation And Screenshot Checklist](../design-implementation/12-validation-and-screenshot-checklist.md) and [Screenshot Review](../qa/screenshot-review.md).
9. Capture owner corrections before moving to tester/beta readiness.

## Paused Work

- Full catalog visual breadth.
- Customer visual breadth.
- Decoration and upgrade breadth.
- Hidden narrative object breadth.
- Later-era platform rollout.
- Multi-day visual playtest.
- External alpha/beta packaging.

These resume only after the opening store satisfies the design source of truth, completes the implementation roadmap review package, and the owner approves the next stage.

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
- `docs/design-implementation/` updated when execution scope, phase order, evidence, or agent packet rules change
