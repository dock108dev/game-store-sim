# Current State

This is the authoritative handoff for the repo. If another doc disagrees with this page, `docs/status.json`, `docs/design-source-of-truth/`, or `docs/design-implementation/`, update or remove the older doc.

## Build State

The game is a broad validated first-person retail prototype. Core mechanics are working: movement, click-first interaction, receiving, carrying, pricing, stocking, register sales, returns, trade-ins, preorders, services, supplier ordering, release allocation, fixture placement, backroom computer workflows, save/load, settings, pause/menu, and optional hidden-thread hooks.

The design and visual target is being reset. The owner-provided store/world brief, vertical slice spec, and 300-object asset inventory are consolidated into [Design Source Of Truth](design-source-of-truth/README.md). Active execution is sliced in [Design Implementation Index](design-implementation/README.md).

## Current Blocker

External playtest and broad visual expansion are paused.

The owner selected the block path for the current visual direction. The current Godot scene is now frozen as a mechanics prototype, not the visual baseline. The next work is a separate art-direction spike using `inspiration/` for stylized scaffold, `new_real_inspiration/` for real period retail construction, Blender-authored modular assets, bitmap textures, and legally clean asset packs/custom assets as needed.

The first proof target is an inside-looking-out shot for a small-chain game store. The spike may redesign the footprint, storefront, facade, and world placement heavily.

For design intent, read:

- [Master Design Source Of Truth](design-source-of-truth/00-master-design-source-of-truth.md)
- [Vertical Slice Specification](design-source-of-truth/01-vertical-slice-spec.md)
- [Store Design And World Building](design-source-of-truth/02-store-design-world-building.md)
- [Asset Inventory Roadmap](design-source-of-truth/03-asset-inventory-roadmap.md)
- [Validation And Signoff](design-source-of-truth/04-validation-and-signoff.md)

For implementation, start with:

- [Design Implementation Index](design-implementation/README.md)
- [Work Packet Index](design-implementation/work-packets/00-packet-index.md)
- [Art Direction Reset And Spike Plan](design-implementation/15-art-direction-reset-and-spike-plan.md)
- [Art Direction Spike Packet](design-implementation/work-packets/09-art-direction-spike.md)

## Validation Snapshot

Current gate:

```text
scripts/validate_godot.sh
```

Current validation snapshot:

- Current doc-contract expectation is 581 GUT tests and 11818 asserts.
- UI scenario automation coverage is 512/632, or 81.0%.
- Production script mapping is 53/53, or 100.0%.
- 3 standalone validation tools are active.
- Product catalog validation passes with 62 products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, contact-sheet generation, and old-name scan pass.
- All 27 required screenshots are present in `artifacts/validation/latest/screenshots/`.
- Contact sheet: `artifacts/validation/latest/screenshot-contact-sheet.png`.

## Current Design Direction

Target:

- Era: 2002-2004.
- Store type: small independent specialty video game store.
- Business state: owner-operated, limited cash, limited inventory, limited shelving, limited distributor access, limited reputation.
- Store read: new, underfunded, understocked, promising, and operational.
- Starting platforms: Nova, Vertex, Prism, and Pocket.
- Product mix: game-first, with hardware, accessories, guides/media, and collectibles supporting the store fantasy.
- Opening inventory: limited but not bare, with roughly 40-60 visible games, 5-10 accessories, and 5-10 guide/media items.
- Opening density: 25-40% wall occupancy and 30-50% floor occupancy.
- Mature density target: 80-95% wall occupancy and 70-85% floor occupancy.

Rejected path:

- Treating the old art-kit route as sufficient by itself.
- More loose primitive clutter.
- More debug-zone identity text.
- Future inventory physically staged before it is purchased, unlocked, received, released, or traded in.
- Broad catalog/customer/decoration/hidden-narrative work before one opening store loop looks right.

## Next Implementation Pass

Use [Work Packet Index](design-implementation/work-packets/00-packet-index.md) as the build queue history. Packet assembly is complete. Packets 01-08 are implemented and validated. Packet 08 produced the [Owner Visual Review Package](production/14-owner-visual-review-package.md), and the owner chose the block path.

The next implementation pass is:

1. Execute [Art Direction Spike Packet](design-implementation/work-packets/09-art-direction-spike.md).
2. Use `inspiration/` and `new_real_inspiration/` as primary reference input.
3. Prove an inside-looking-out small-chain store shot before rebuilding the full playable store.

Packet 06 added editable `Games4U` identity data, changed the day-one door sign to `CLOSED`, replaced the fake used-wall shelf default with attached `Potpourri` mixed-shelf labeling, and added fictional new-release, trade-in, coming-soon, and now-on-sale poster support.

Packet 07 added brighter clean store lighting, warmer mall approach lighting, firm commercial-carpet cues, attached wall color panels, fixed product/stockroom doorway screenshot targets, and expanded visual-review screenshot evidence. Packet 08 packaged the final screenshot notes, known residual risks, validation evidence, and approve/revise/block owner decision path. The current outcome is block: stop trying to polish the current scene as the visual source.

The contact sheet and `scripts/validate_godot.sh` remain regression evidence, not design approval by themselves.

Stop if the implementation would change core mechanics instead of replacing the visual/design surface.

## Next Validation Pass

1. Extract visual rules from `inspiration/` and `new_real_inspiration/`.
2. Build or mock one inside-looking-out art-direction spike.
3. Compare the art spike against the current screenshot baseline.
4. Treat `scripts/validate_godot.sh` and the old contact sheet as mechanics/regression evidence only.
5. Owner decides approve, revise, or block the art spike.

## Active Documentation

- [Documentation Index](README.md)
- [Design Source Of Truth](design-source-of-truth/README.md)
- [Design Implementation Index](design-implementation/README.md)
- [Art Direction Reset And Spike Plan](design-implementation/15-art-direction-reset-and-spike-plan.md)
- [Real Period Retail Inspiration](../new_real_inspiration/README.md)
- [Work Packet Index](design-implementation/work-packets/00-packet-index.md)
- [Backlog](production/04-backlog.md)
- [Validation](production/06-validation.md)
- [Visual Bug List](production/13-alpha-bug-list.md)
- [Owner Visual Review Package](production/14-owner-visual-review-package.md)
- [QA Index](qa/README.md)
- [Screenshot Review](qa/screenshot-review.md)
- [Smoke Playtest](qa/smoke-playtest.md)
