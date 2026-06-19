# Current State

Status date: 2026-06-19

Machine-readable status lives in `docs/status.json`.

## Summary

The project has a broad validated first-person retail prototype with working core mechanics: movement, interaction, receiving, carrying, pricing, stocking, register sales, returns, trade-ins, supplier ordering, fixture placement, save/load, pause/settings, and backroom workflows.

The prototype also retains optional hidden-thread hooks, but hidden narrative content is not part of the current visual rebuild scope.

The first Visual Bible object-family implementation pass is now integrated and visually rejected. Starter product art, fixture/display capacity, shell/storefront/counter, receiving, and backroom kits are technically present, but latest screenshots still read as primitive Godot box geometry rather than a convincing early-2000s game shop.

The playable scene remains a mechanics prototype. It is not the visual baseline.

A replacement authored-art proof now exists at `game/scenes/world/art_benchmark/hero_art_slice.tscn`. It uses repo-local baked bitmap assets from `game/assets/art_proof/generated/`, avoids live Godot text panels, and remains isolated from the playable mechanics scene.

The owner-facing review artifact is `docs/production/images/hero_art_slice_review_board.png`.

The active visual target is now:

- [Design Source Of Truth](design-source-of-truth/README.md)
- [Visual Bible](visual-bible/README.md)
- [Design Implementation Index](design-implementation/README.md)
- [Work Packet Index](design-implementation/work-packets/00-packet-index.md)

## Current Decision

Block the current MVP object-family pass and the first procedural hero art slice before any broad implementation. The store still targets a 2002-2004 independent specialty game shop, with legal-safe fictional products and visible room to grow.

Visually failed implementation packets:

1. MVP product art kit.
2. MVP fixture and display kit.
3. Store shell, counter, receiving, and backroom kit.
4. Playable store integration review.

Current checkpoint:

1. Review the authored proof board: `docs/production/images/hero_art_slice_review_board.png`.
2. Decide whether this art-production method is approved enough to turn into constrained production integration packets.
3. If approved, follow [Authored Art Proof Integration Plan](production/17-authored-art-proof-integration-plan.md).
4. If rejected, do not integrate; change production method again before touching the playable scene.

Do not broaden catalog visuals, customers, employees, decoration breadth, hidden narrative, later-era content, beta/tester packaging, mechanics work, or production integration until the authored visual proof is approved.

## Validation Snapshot

Latest recorded gate:

```text
scripts/validate_godot.sh
```

Current doc-contract expectation:

- GUT: 595 tests, 12306 asserts.
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
- VIS-021: the authored hero proof is ready, but broad work remains blocked until owner review approves it.

## Review Plan

Read [Failed Visual Validation](production/15-failed-visual-validation.md) and [Hero Art Slice Review](production/16-hero-art-slice-review.md).

Next review focus:

- the authored proof board at `docs/production/images/hero_art_slice_review_board.png`
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
- `docs/production/16-hero-art-slice-review.md`
- `docs/production/17-authored-art-proof-integration-plan.md`

Do not use deleted packet names as implementation instructions.
