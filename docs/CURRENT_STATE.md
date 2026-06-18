# Current State

This is the authoritative handoff for the repo. If another doc disagrees with this page, `docs/status.json`, or `docs/design-source-of-truth/`, update or remove the older doc.

## Build State

The game is a broad validated first-person retail prototype. Core mechanics are working: movement, click-first interaction, receiving, carrying, pricing, stocking, register sales, returns, trade-ins, preorders, services, supplier ordering, release allocation, fixture placement, backroom computer workflows, save/load, settings, pause/menu, and optional hidden-thread hooks.

The design and visual target is being reset. The owner-provided store/world brief, vertical slice spec, and 300-object asset inventory are now consolidated into [Design Source Of Truth](design-source-of-truth/README.md).

## Current Blocker

External playtest and broad visual expansion are paused.

The active blocker is: rebuild the opening store so it reads as a small, independent, underfunded but functional 2002-2004 specialty game store with visible growth potential.

Start with:

- [Master Design Source Of Truth](design-source-of-truth/00-master-design-source-of-truth.md)
- [Vertical Slice Specification](design-source-of-truth/01-vertical-slice-spec.md)
- [Store Design And World Building](design-source-of-truth/02-store-design-world-building.md)
- [Asset Inventory Roadmap](design-source-of-truth/03-asset-inventory-roadmap.md)
- [Validation And Signoff](design-source-of-truth/04-validation-and-signoff.md)

## Validation Snapshot

Current gate:

```text
scripts/validate_godot.sh
```

Current validation snapshot:

- Current doc-contract expectation is 570 GUT tests and 10805 asserts.
- UI scenario automation coverage is 508/628, or 80.9%.
- Production script mapping is 53/53, or 100.0%.
- 3 standalone validation tools are active.
- Product catalog validation passes with 60 products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, contact-sheet generation, and old-name scan pass.
- All 23 required screenshots are present in `artifacts/validation/latest/screenshots/`.
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

Use [Asset Inventory Roadmap](design-source-of-truth/03-asset-inventory-roadmap.md) Phase 1 as the next build target:

1. Storefront glass door.
2. Front window poster bay.
3. Configurable fictional logo sign.
4. Low-pile carpet material.
5. Fluorescent light bank.
6. Cash wrap wall panel.
7. Slatwall modules.
8. Preserve movement, entrance, counter reachability, receiving, trade-ins, ordering, stocking, and register workflows.

Stop if the implementation would change core mechanics instead of replacing the visual/design surface.

## Next Validation Pass

1. Run focused doc/source-of-truth tests.
2. Run `scripts/validate_godot.sh`.
3. Review the regenerated production contact sheet.
4. Do a real-window 1280x720 walk-in from entrance to checkout.
5. Decide whether Phase 1 makes the store read as a small early-2000s independent game store, or whether it needs corrections before Phase 2.

## Active Documentation

- [Documentation Index](README.md)
- [Design Source Of Truth](design-source-of-truth/README.md)
- [Backlog](production/04-backlog.md)
- [Validation](production/06-validation.md)
- [Visual Bug List](production/13-alpha-bug-list.md)
- [QA Index](qa/README.md)
- [Screenshot Review](qa/screenshot-review.md)
- [Smoke Playtest](qa/smoke-playtest.md)
