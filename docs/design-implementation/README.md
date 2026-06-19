# Design Implementation Index

## Purpose

This folder turns the design source of truth and Visual Bible into agent-ready implementation work.

The old Packet 01-09 sequence was completed and then blocked by owner visual review. The first Visual Bible object-family pass was also implemented and then visually rejected. The current queue is now a strict isolated hero art slice proof before any more broad implementation.

## Authority

If this folder conflicts with `docs/design-source-of-truth/`, the design source of truth wins.

If this folder conflicts with `docs/visual-bible/` on visible object quality, fixture/product shape, art production method, or MVP object requirements, the Visual Bible wins.

If a slice cannot satisfy the design source of truth without changing a core gameplay mechanic, stop and record the decision point before continuing.

## Implementation Policy

- Start work only from current Visual Bible packets, not deleted legacy packets.
- Work may start only on the active hero art slice packet.
- Do not continue broad object-family, playable-store, mechanics, or docs passes until the hero screenshot is approved.
- Commit after the completed slice for tracking.
- Preserve existing mechanics by not touching them unless the hero slice requires isolated smoke support.
- Do not broaden catalog visuals, customers, decoration breadth, hidden narrative, later-era content, or external playtest packaging until the hero art slice is approved.

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
10. Use focused scene-load/screenshot checks for the hero slice. Run `scripts/validate_godot.sh` only when production-route mechanics change.
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
| `work-packets/01-mvp-product-art-kit.md` | Visually rejected | Starter product art, legal-safe packaging, and product validation. |
| `work-packets/02-mvp-fixture-display-kit.md` | Visually rejected | Fixture/display assets, capacity language, and stocking validation. |
| `work-packets/03-shell-counter-backroom-kit.md` | Visually rejected | Shell, counter, register, trade-in, stockroom, receiving, and office modules. |
| `work-packets/04-playable-store-integration-review.md` | Visually rejected | Final integration and owner review evidence. |
| `work-packets/05-hero-art-slice-proof.md` | Active next implementation | One isolated screenshot-first art slice proving the visual method. |

Deleted legacy docs:

- Old slice specs `03` through `12`.
- Old work packets `01` through `09`.
- Old alpha/owner review package names under `docs/production/`.

Their useful decisions were consolidated into `docs/design-source-of-truth/`, `docs/visual-bible/`, `docs/production/13-visual-blockers.md`, and `docs/production/14-visual-bible-implementation-review.md`.

## Packet Set

1. MVP product art kit: visually rejected as baseline.
2. MVP fixture and display kit: visually rejected as baseline.
3. Store shell and mall interior kit: visually rejected as baseline.
4. Playable store integration and route validation: visually rejected as baseline.
5. Hero art slice proof: active next work.

## Slice Completion Definition

A slice is complete when:

- requested assets/scenes/code are implemented
- mechanics touched by the slice still work
- docs reflect current behavior
- focused tests pass
- focused scene/screenshot checks pass
- screenshot/review evidence is regenerated where relevant
- the slice is committed
- owner decision points are documented clearly

Owner signoff is required before any non-conflicting dependent work continues. Rejected visuals must not trigger broad follow-up passes.

## Current Next Step

Implement `work-packets/05-hero-art-slice-proof.md`.

The only required proof is one owner-facing screenshot that looks like the target inspiration. If it fails, change art-production method, asset workflow, or tooling before touching the playable mechanics prototype.
