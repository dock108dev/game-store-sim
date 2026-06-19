# Backlog

For current status and validation numbers, read `docs/CURRENT_STATE.md` and `docs/status.json` first.

## Current Phase

Design reset documentation is complete. Visual Bible documentation is complete. The first implementation pass for MVP object families is technically integrated and visually rejected.

Goal: stop broad implementation and prove one screenshot first. The next implementation must create a strict isolated hero art slice that makes the opening store read as a small, independent, underfunded but functional 2002-2004 game store.

## Active Work

1. Treat [Failed Visual Validation](15-failed-visual-validation.md) as the current production gate.
2. Implement only [Hero Art Slice Proof](../design-implementation/work-packets/05-hero-art-slice-proof.md).
3. Capture one owner-facing screenshot at 1280x720 or larger.
4. Ask whether that screenshot proves the art-production method.
5. Do not continue broad implementation until that screenshot is approved.

## Paused Work

- Full catalog visual breadth.
- Customer visual breadth.
- Decoration and upgrade breadth.
- Hidden narrative object breadth.
- Later-era platform rollout.
- Multi-day visual playtest.
- External alpha/beta packaging.
- Playable-store polish.
- Mechanics expansion.
- Broad docs rewrites unrelated to the hero slice.

These resume only after the isolated hero art slice screenshot is visually approved and a constrained rebuild/integration plan is written from that proven method.

## Stop Conditions

Stop and ask for owner review if:

- the implementation conflicts with the source-of-truth era, store size, inventory-access, or starting-density rules
- the hero screenshot still reads as primitive boxes
- product art still needs labels to be understood
- the asset workflow cannot produce a believable screenshot quickly
- a real mesh/modeling workflow or engine/tooling decision is required
- changing the visual route would alter gameplay flow
- performance or import constraints make the intended asset plan impractical
- a phase cannot be validated from screenshots or a 1280x720 walk-in

## Finish Gate

Every implementation pass must keep:

- focused GUT tests green for changed contracts
- `scripts/validate_godot.sh` green for production route integration when production route changes
- `docs/status.json` and `docs/CURRENT_STATE.md` current
- `docs/production/13-visual-blockers.md` current for design/visual blockers
- `docs/design-source-of-truth/` updated when the owner makes a design decision
- `docs/design-implementation/` updated when execution scope, phase order, evidence, or agent packet rules change

Passing automation is not visual approval. The hero art slice is approved only by owner screenshot review.
