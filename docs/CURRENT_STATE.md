# Current State

Status date: 2026-06-19

Machine-readable status lives in `docs/status.json`.

## Summary

The project has a broad validated first-person retail prototype with working core mechanics: movement, interaction, receiving, carrying, pricing, stocking, register sales, returns, trade-ins, supplier ordering, fixture placement, save/load, pause/settings, and backroom workflows.

The prototype also retains optional hidden-thread hooks, but hidden narrative content is not part of the current visual rebuild scope.

The visual direction is blocked. Owner feedback still rates the current look around 4.5/10 because too much of the store reads as primitive assembled geometry. The current playable Godot scene is a mechanics prototype, not the visual baseline.

The active visual target is now:

- [Design Source Of Truth](design-source-of-truth/README.md)
- [Visual Bible](visual-bible/README.md)
- [Design Implementation Index](design-implementation/README.md)
- [Work Packet Index](design-implementation/work-packets/00-packet-index.md)

## Current Decision

Build MVP object families from the Visual Bible before another playable-store polish pass. The store still targets a 2002-2004 independent specialty game shop, with legal-safe fictional products and visible room to grow.

Next implementation order:

1. MVP product art kit.
2. MVP fixture and display kit.
3. Store shell and mall interior kit.
4. Counter/register/trade-in kit.
5. Stockroom/receiving/office kit.
6. Minimal signage/store identity kit.
7. Playable store integration.
8. Owner review package.

Do not broaden catalog visuals, customers, employees, decoration breadth, hidden narrative, later-era content, or beta/tester packaging until the MVP visual pass is reviewable.

## Validation Snapshot

Latest recorded gate:

```text
scripts/validate_godot.sh
```

Current doc-contract expectation:

- GUT: 587 tests, 11859 asserts.
- UI automation: 512/632, or 81.0%.
- Production script mapping: 54/54, or 100.0%.
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

- product close-up quality
- fixture/display capacity and silhouette
- whether the object-family method can plausibly reach 7.5/10 before full scene integration

## Removed Docs Policy

Old Packet 01-09 implementation docs, old slice specs, and old alpha/owner review docs were removed from the active tree. Their useful decisions were consolidated into:

- `docs/design-source-of-truth/`
- `docs/visual-bible/`
- `docs/design-implementation/`
- `docs/production/13-visual-blockers.md`
- `docs/production/14-visual-bible-implementation-review.md`

Do not use deleted packet names as implementation instructions.
