# Design Implementation Index

## Purpose

This folder turns the design source of truth and Visual Bible into agent-ready implementation work.

The old Packet 01-09 sequence was completed and then blocked by owner visual review. It is not the current implementation queue. The current queue starts from `docs/visual-bible/` and rebuilds MVP object families with authored assets before reintegrating them into the playable store.

## Authority

If this folder conflicts with `docs/design-source-of-truth/`, the design source of truth wins.

If this folder conflicts with `docs/visual-bible/` on visible object quality, fixture/product shape, art production method, or MVP object requirements, the Visual Bible wins.

If a slice cannot satisfy the design source of truth without changing a core gameplay mechanic, stop and record the decision point before continuing.

## Implementation Policy

- Start work only from current Visual Bible packets, not deleted legacy packets.
- Work may start on a slice once its dependencies are complete.
- Work does not need final owner signoff before the next non-conflicting dependent slice starts, but every slice must end in a reviewable state.
- Commit after each completed slice for tracking.
- Preserve existing mechanics while replacing the visual/design surface.
- Do not broaden catalog visuals, customers, decoration breadth, hidden narrative, later-era content, or external playtest packaging until the MVP opening-store visual pass reaches owner review.

## Agent Operating Rules

Every implementation agent should:

1. Read `docs/CURRENT_STATE.md`.
2. Read `docs/design-source-of-truth/README.md`.
3. Read `docs/visual-bible/README.md`.
4. Read this index.
5. Read `docs/design-implementation/work-packets/00-packet-index.md`.
6. Read the current Visual Bible family doc and `docs/visual-bible/09-mvp-object-implementation-checklist.md`.
7. Make only the changes required for the current slice.
8. Update docs/tests that describe changed behavior or validation.
9. Run focused tests for changed contracts.
10. Run `scripts/validate_godot.sh` before marking an implementation slice complete.
11. Commit the completed slice.

Do not use visible debug labels, loose primitive clutter, old graybox geometry, or future inventory staging as shortcuts for store readability.

## Active Implementation Docs

| Document | Status | Purpose |
| --- | --- | --- |
| `README.md` | Active | Implementation index and agent operating rules. |
| `02-visual-module-system-spec.md` | Active reference | Grid, module, collision, and replacement rules; Visual Bible wins on art quality. |
| `13-agent-work-packet-template.md` | Active | Packet format for new implementation slices. |
| `14-phase-implementation-roadmap.md` | Active | Roadmap from Visual Bible packets to owner validation. |
| `15-art-direction-reset-and-spike-plan.md` | Historical reference | Captures why the prior primitive route was blocked. |
| `work-packets/00-packet-index.md` | Active | Current packet queue and legacy packet deletion policy. |

Deleted legacy docs:

- Old slice specs `03` through `12`.
- Old work packets `01` through `09`.
- Old alpha/owner review package names under `docs/production/`.

Their useful decisions were consolidated into `docs/design-source-of-truth/`, `docs/visual-bible/`, `docs/production/13-visual-blockers.md`, and `docs/production/14-visual-bible-implementation-review.md`.

## Next Packet Set

Create and implement new packets from the Visual Bible in this order:

1. MVP product art kit.
2. MVP fixture and display kit.
3. Store shell and mall interior kit.
4. Counter, register, and trade-in kit.
5. Stockroom, receiving, and office kit.
6. Minimal signage and store identity kit.
7. Playable store integration and route validation.
8. Owner review package.

## Slice Completion Definition

A slice is complete when:

- requested assets/scenes/code are implemented
- mechanics touched by the slice still work
- docs reflect current behavior
- focused tests pass
- full `scripts/validate_godot.sh` passes
- screenshot/review evidence is regenerated where relevant
- the slice is committed
- owner decision points are documented clearly

Owner signoff can happen after the slice is complete. Approval is not required to continue non-conflicting dependent work, but rejected visuals must be corrected before broadening scope.

## Current Next Step

Assemble the first Visual Bible implementation packet: MVP product art kit. The packet should produce authored DVD cases, recognizable legal-safe starter cover art, console/accessory packaging, price stickers, duplicate-stack language, and first-person close-up screenshot evidence before any broad playable-store rebuild.
