# Current State

Status date: 2026-06-19

Machine-readable status lives in `docs/status.json`.

## Summary

The project has a broad validated first-person retail prototype with working core mechanics: movement, interaction, receiving, carrying, pricing, stocking, register sales, returns, trade-ins, supplier ordering, fixture placement, save/load, pause/settings, and backroom workflows.

The prototype also retains optional hidden-thread hooks, but hidden narrative content is not part of the current visual rebuild scope.

The first Visual Bible object-family implementation pass is now integrated and visually rejected. Starter product art, fixture/display capacity, shell/storefront/counter, receiving, and backroom kits are technically present, but latest screenshots still read as primitive Godot box geometry rather than a convincing early-2000s game shop.

The playable scene remains a mechanics prototype. It is not the visual baseline.

The active visual target is now:

- [Design Source Of Truth](design-source-of-truth/README.md)
- [Visual Bible](visual-bible/README.md)
- [Design Implementation Index](design-implementation/README.md)
- [Work Packet Index](design-implementation/work-packets/00-packet-index.md)

## Current Decision

Block the current MVP object-family pass and pivot to one strict hero art slice before any more broad implementation. The store still targets a 2002-2004 independent specialty game shop, with legal-safe fictional products and visible room to grow.

Visually failed implementation packets:

1. MVP product art kit.
2. MVP fixture and display kit.
3. Store shell, counter, receiving, and backroom kit.
4. Playable store integration review.

Current checkpoint:

1. Build one isolated hero art slice.
2. Capture one screenshot that looks like the inspiration.
3. Ask owner if the screenshot proves the visual method.
4. Only then plan a constrained rebuild/integration path.

Do not broaden catalog visuals, customers, employees, decoration breadth, hidden narrative, later-era content, beta/tester packaging, or mechanics work until the hero art slice is visually approved.

## Validation Snapshot

Latest recorded gate:

```text
scripts/validate_godot.sh
```

Current doc-contract expectation:

- GUT: 592 tests, 12273 asserts.
- UI automation: 512/632, or 81.0%.
- Production script mapping: 55/55, or 100.0%.
- Active validation tools: 3.
- Catalog products: 62.
- Screenshot count: 27.
- Contact sheet: `artifacts/validation/latest/screenshot-contact-sheet.png`.

Important: validation and contact sheets are regression evidence only. They do not approve art quality or define visual progress.

## Blockers

Read [Visual Blockers](production/13-visual-blockers.md).

Primary blockers:

- VIS-020: the integrated object-family pass is visually rejected.
- VIS-021: no more broad work until one hero art slice screenshot looks like the target inspiration.

## Review Plan

Read [Failed Visual Validation](production/15-failed-visual-validation.md).

Next review focus:

- one isolated hero art slice screenshot
- storefront/concourse read
- first 15-20 feet of shop interior
- one believable fixture
- one believable counter
- 2-3 believable product objects
- whether the asset production method is good enough to rebuild from

## Removed Docs Policy

Old Packet 01-09 implementation docs, old slice specs, and old alpha/owner review docs were removed from the active tree. Their useful decisions were consolidated into:

- `docs/design-source-of-truth/`
- `docs/visual-bible/`
- `docs/design-implementation/`
- `docs/production/13-visual-blockers.md`
- `docs/production/14-visual-bible-implementation-review.md`
- `docs/production/15-failed-visual-validation.md`

Do not use deleted packet names as implementation instructions.
