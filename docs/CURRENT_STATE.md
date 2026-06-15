# Current State

This is the authoritative handoff for the repo. If another doc disagrees with this page or `docs/status.json`, update or remove the older doc.

## Build State

The game is a broad validated first-person retail prototype. Core mechanics are working: movement, click-first interaction, receiving, carrying, pricing, stocking, register sales, returns, trade-ins, preorders, services, supplier ordering, release allocation, fixture placement, backroom computer workflows, save/load, settings, pause/menu, and optional hidden-thread hooks.

The visuals are not approved. The latest hard visual benchmark still reads as a cube-based blockout: raw rectangular solids, scattered prop blocks, weak material separation, and labels/sign cards doing too much explanatory work. That means the next pass is not more store content. It is an art-language rebuild.

## Current Blocker

External playtest and broad visual expansion are paused.

The active blocker is: replace the visible cube/label language with a small modular art kit that can make the mall-entry/storefront/register route read as a simple mid-00s game shop before labels.

Start with:

- [Art Language Rebuild Plan](visual-production/00-art-language-rebuild-plan.md)
- [Modular Asset Kit Spec](visual-production/01-modular-asset-kit-spec.md)
- [Art Rebuild Validation Plan](visual-production/02-art-rebuild-validation-plan.md)

## Validation Snapshot

Current gate:

```text
scripts/validate_godot.sh
```

Latest validated baseline after this docs overhaul:

- 566 GUT tests and 10705 asserts pass.
- UI scenario automation coverage is 508/628, or 80.9%.
- Production script mapping is 53/53, or 100.0%.
- 3 standalone validation tools are active.
- Product catalog validation passes with 60 products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, contact-sheet generation, and old-name scan pass.
- All 23 required screenshots are present in `artifacts/validation/latest/screenshots/`.
- Contact sheet: `artifacts/validation/latest/screenshot-contact-sheet.png`.

## Current Visual Direction

Target:

- Era: 2005-2007.
- Store type: independent used video game shop in a small mall or retail strip.
- Style: simple but authored, with bevels, trim, glass, framed signs, warm shop lighting, material seams, product rows, posters, and decals.
- Opening state: pre-business, no customers or employees visible.
- Day-one stock: restrained physical stock, roughly 2 new games, 1 console, 1 accessory/controller, plus receiving/trade-in capacity.
- Future inventory: catalog/planning only until purchased, unlocked, received, released, or traded in.

Rejected path:

- More loose CSG boxes.
- More label panels.
- More small rectangle clutter.
- Broad catalog/customer/decoration work before one route looks good.

## Next Implementation Pass

1. Complete the docs/status/test overhaul.
2. Build an isolated art benchmark scene under `game/scenes/world/art_benchmark/`.
3. Build reusable kit modules under `game/scenes/world/kits/`.
4. Prove storefront, register, shelf/product, receiving, and backroom-threshold modules in isolation.
5. Replace the production route in `store_world.tscn` with approved kit modules.
6. Run `scripts/validate_godot.sh`.
7. Review the contact sheet and a real-window 1280x720 walk-in.

Stop if the sandbox scene still reads as cubes.

## Active Documentation

- [Documentation Index](README.md)
- [Visual Production](visual-production/README.md)
- [Backlog](production/04-backlog.md)
- [Validation](production/06-validation.md)
- [Visual Bug List](production/13-alpha-bug-list.md)
- [QA Index](qa/README.md)
- [Screenshot Review](qa/screenshot-review.md)
- [Smoke Playtest](qa/smoke-playtest.md)
