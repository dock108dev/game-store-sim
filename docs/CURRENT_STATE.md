# Current State

Status date: 2026-06-19

Machine-readable status lives in `docs/status.json`.

## Summary

The project has a broad validated first-person retail prototype with working core mechanics: movement, interaction, receiving, carrying, pricing, stocking, register sales, returns, trade-ins, supplier ordering, fixture placement, save/load, pause/settings, and backroom workflows.

The prototype also retains optional hidden-thread hooks, but hidden narrative content is not part of the current visual rebuild scope.

The first Visual Bible object-family implementation pass is now integrated. Starter product art, fixture/display capacity, shell/storefront/counter, receiving, and backroom kits have been rebuilt away from the rejected graybox packet route. This is ready for owner visual review, not beta/tester release.

The active visual target is now:

- [Design Source Of Truth](design-source-of-truth/README.md)
- [Visual Bible](visual-bible/README.md)
- [Design Implementation Index](design-implementation/README.md)
- [Work Packet Index](design-implementation/work-packets/00-packet-index.md)

## Current Decision

Review the first MVP object-family pass before beta/tester prep. The store still targets a 2002-2004 independent specialty game shop, with legal-safe fictional products and visible room to grow.

Completed implementation packets:

1. MVP product art kit.
2. MVP fixture and display kit.
3. Store shell, counter, receiving, and backroom kit.

Current checkpoint:

1. Playable store integration review.
2. Owner visual review.
3. Targeted corrections or beta/tester preparation based on owner feedback.

Do not broaden catalog visuals, customers, employees, decoration breadth, hidden narrative, later-era content, or beta/tester packaging until the MVP visual pass is reviewable.

## Validation Snapshot

Latest recorded gate:

```text
scripts/validate_godot.sh
```

Current doc-contract expectation:

- GUT: 592 tests, 12263 asserts.
- UI automation: 512/632, or 81.0%.
- Production script mapping: 55/55, or 100.0%.
- Active validation tools: 3.
- Catalog products: 62.
- Screenshot count: 27.
- Contact sheet: `artifacts/validation/latest/screenshot-contact-sheet.png`.

Important: validation and contact sheets are regression evidence only. They do not approve art quality.

## Blockers

Read [Visual Blockers](production/13-visual-blockers.md).

Primary blocker:

- VIS-012: prior art-production method still produces a primitive 4.5/10 read.

## Review Plan

Read [Visual Bible Implementation Review](production/14-visual-bible-implementation-review.md).

First review focus:

- product close-up quality from `artifacts/validation/latest/screenshots/product_closeup.png`
- fixture/display capacity and silhouette from `artifacts/validation/latest/screenshots/stocked_aisle.png`
- storefront first read from `artifacts/validation/latest/screenshots/storefront_entry.png`
- register/counter read from `artifacts/validation/latest/screenshots/register_counter.png`
- stockroom/receiving read from `artifacts/validation/latest/screenshots/receiving_area.png` and `artifacts/validation/latest/screenshots/stockroom_doorway.png`
- whether this object-family method can plausibly reach the 7.5/10 Visual Bible target with targeted corrections

## Removed Docs Policy

Old Packet 01-09 implementation docs, old slice specs, and old alpha/owner review docs were removed from the active tree. Their useful decisions were consolidated into:

- `docs/design-source-of-truth/`
- `docs/visual-bible/`
- `docs/design-implementation/`
- `docs/production/13-visual-blockers.md`
- `docs/production/14-visual-bible-implementation-review.md`

Do not use deleted packet names as implementation instructions.
