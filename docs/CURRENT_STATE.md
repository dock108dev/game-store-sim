# Current State

This is the authoritative handoff for the repo. If another doc disagrees with this page, `docs/status.json`, `docs/design-source-of-truth/`, or `docs/design-implementation/`, update or remove the older doc.

## Build State

The game is a broad validated first-person retail prototype. Core mechanics are working: movement, click-first interaction, receiving, carrying, pricing, stocking, register sales, returns, trade-ins, preorders, services, supplier ordering, release allocation, fixture placement, backroom computer workflows, save/load, settings, pause/menu, and optional hidden-thread hooks.

The design and visual target is being reset. The owner-provided store/world brief, vertical slice spec, and 300-object asset inventory are consolidated into [Design Source Of Truth](design-source-of-truth/README.md). Active execution is sliced in [Design Implementation Index](design-implementation/README.md).

## Current Blocker

External playtest and broad visual expansion are paused.

The owner selected the block path for the current visual direction. The current Godot scene is frozen as a mechanics prototype, not the visual baseline.

Packet 09 now provides a separate inside-looking-out art spike for review. Revision 2 incorporates owner feedback that the first spike had weird text, cluttered walls, too much color, and still read as a graybox. It uses `inspiration/` for stylized scaffold and `new_real_inspiration/` for real period retail construction: storefront glass rhythm, mall corridor, drop ceiling, quieter walls, orderly slatwall case rows, flat bitmap sign panels, restrained price-sticker language, and a glass display counter. The spike may still need visual correction, but the next decision is owner review of this direction before the playable store is rebuilt.

Packet 09 artifacts:

- Scene: `game/scenes/world/art_benchmark/packet_09_inside_out_art_spike.tscn`
- Capture tool: `game/tests/tools/capture_packet_09_art_spike_screenshot.gd`
- Review board: `artifacts/validation/latest/packet-09-art-spike-review-board.png`
- Screenshots: `artifacts/validation/latest/screenshots/packet_09_inside_out_art_spike.png`, `packet_09_shelf_density.png`, and `packet_09_storefront_frame.png`

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

- Current doc-contract expectation is 587 GUT tests and 11865 asserts.
- UI scenario automation coverage is 512/632, or 81.0%.
- Production script mapping is 54/54, or 100.0%.
- 3 standalone validation tools are active.
- Product catalog validation passes with 62 products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, contact-sheet generation, and old-name scan pass.
- All 27 required screenshots are present in `artifacts/validation/latest/screenshots/`.
- Contact sheet: `artifacts/validation/latest/screenshot-contact-sheet.png`.
- Packet 09 art-spike review board: `artifacts/validation/latest/packet-09-art-spike-review-board.png`.

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

The next implementation pass is blocked on owner review:

1. Review [Art Direction Spike Packet](design-implementation/work-packets/09-art-direction-spike.md) and the revised Packet 09 review board.
2. Decide whether the spike direction is approved, needs revision, or is blocked.
3. If approved, rebuild the playable store visuals around the Packet 09 method while preserving current mechanics.
4. If revised or blocked, update the spike first before touching the playable store.

Packet 06 added editable `Games4U` identity data, changed the day-one door sign to `CLOSED`, replaced the fake used-wall shelf default with attached `Potpourri` mixed-shelf labeling, and added fictional new-release, trade-in, coming-soon, and now-on-sale poster support.

Packet 07 added brighter clean store lighting, warmer mall approach lighting, firm commercial-carpet cues, attached wall color panels, fixed product/stockroom doorway screenshot targets, and expanded visual-review screenshot evidence. Packet 08 packaged the final screenshot notes, known residual risks, validation evidence, and approve/revise/block owner decision path. The current outcome is block: stop trying to polish the current scene as the visual source.

The contact sheet and `scripts/validate_godot.sh` remain regression evidence, not design approval by themselves.

Stop if the implementation would change core mechanics instead of replacing the visual/design surface.

## Next Validation Pass

1. Inspect `artifacts/validation/latest/packet-09-art-spike-review-board.png`.
2. Compare the art spike against the current screenshot baseline.
3. Treat `scripts/validate_godot.sh` and the old contact sheet as mechanics/regression evidence only.
4. Owner decides approve, revise, or block the art spike.

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
