# Current State

This is the authoritative handoff for the repo. If another doc disagrees with this page or `docs/status.json`, update the older doc or treat it as historical.

## Playable Build

The current Godot game is a broad validated mechanical prototype with the first phase 0-4 visual pass rejected by owner review. It is not a final-art alpha. The active visual reset slice now starts the player outside the shop on a second-floor mall concourse, with a walkable glass storefront entry and no visible customers or employees before opening. The first opening visual asset pass is implemented, and scene architecture modularization is accepted as infrastructure: `store_world.tscn` is the production main scene, `graybox_store.tscn` is a compatibility wrapper, and module manifests define ownership for the mall, storefront, threshold, interior shell, counter, starter display, sales fixtures, receiving, backroom, and systems surfaces. Prototype visual language cleanup is now implemented for owner validation: oversized interior labels were reduced, right-wall posters gained small physical product silhouettes, the staff/backroom boundary now has doorway/header/return-wall/floor cues, and receiving has staged-cart/strapped-box workflow cues. Visual quality is not approved yet; the next decision is whether this cleaned baseline is good enough for the product/fixture visual-kit pass. The first-person retail loop includes:

- Movement, click-first targeting, prompts, hover feedback, and mouse capture recovery.
- Receiving, multi-item carry, pricing, stocking, buyer queueing, and register sales.
- Returns, trade-ins, preorder deposits, service tickets, and daily reports.
- Supplier ordering, physical receiving, backstock storage, stock pulls, fixture orders, fixture placement, and category assignment.
- Release calendar, launch allocation, launch-day resolution, market/demand summaries, upgrades, decoration surface hooks, save/load, settings, pause/main menu, and desktop pack smoke.
- Full first-catalog data with 60 fictional products, 9 release-calendar entries, and 4 supplier lots.
- Optional hidden-thread infrastructure for suspicious items, supplier notes, suspicious customer cues, records, choices, and nonblocking consequences.

## Validation Snapshot

Current gate: `scripts/validate_godot.sh`.

Latest verified baseline:

- 570 GUT tests and 10026 asserts pass.
- UI scenario automation coverage is 508/628, or 80.9%, against an 80% threshold.
- Production script mapping is 53/53, or 100.0%, against an 80% threshold.
- 3 standalone validation tools are active.
- Product catalog validation passes with 60 products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, and old-name scan pass.
- All 23 required screenshots are present, and the latest contact sheet is `artifacts/validation/latest/screenshot-contact-sheet.png`.

Validation artifacts are written to `artifacts/validation/latest/`. The important screenshots are listed in [Screenshot Review](qa/screenshot-review.md) (`docs/qa/screenshot-review.md`).

## Current Blocker

External alpha playtest remains paused. The repo is mechanically green, but the visual read still needs owner approval. The opening composition and modular production scene are directionally better, and the cleanup pass reduced oversized interior labels, added a real staff threshold, and staged receiving clutter. Remaining owner-review risks are the still-visible tiny label speckle through storefront/interior views, receiving label density, and the broader lack of true product/fixture art. The next gate is owner validation of [Prototype Visual Language Cleanup](visual-production/18-prototype-visual-language-cleanup.md).

Required reviews:

- Owner opening visual asset pass signoff.
- Owner prototype visual language cleanup signoff.
- Owner opening mall/storefront screenshot review.
- Owner walk-in empty-store review.
- Owner day-one owned-stock flow review.
- Owner catalog/unlock/receiving flow review.
- Manual 1280x720 readability pass for prompts, UI panels, product labels, customers, and screenshot composition.

## Visual Read

The current scene is still pending owner art approval. The accepted direction is narrow: prove the opening approach first. The player spawns in a quiet second-floor mall concourse, faces a branded glass storefront, can walk through the open door, and sees an empty pre-open shop. Customer nodes remain present and mechanically wired for later systems, but they are hidden for the opening state. The first asset pass adds tile panels, rail posts, shutter details, planter foliage, storefront mullions, threshold pieces, starter product packaging, and a first interior benchmark corner. The prototype-language cleanup pass adds smaller physical signage, right-wall poster product silhouettes, a staffed doorway/threshold, and receiving staging. Owner review still needs to decide whether this clears enough of the box-label read to become the style benchmark.

Current visual risk areas:

- Opening route blockout read is reduced, but screenshots still do not clear the owner art bar.
- Tiny label speckle is still visible from some storefront/interior screenshots, especially through glass and across the far wall.
- Receiving is more staged, but still has dense labels/tags and needs product/fixture art before it can read as finished.
- The backroom now has a staff threshold, but the broader backroom still needs real room treatment and material depth.
- The new module boundaries are accepted as infrastructure; deeper physical extraction should happen only when it helps the cleanup pass.
- Store identity depends too much on labels instead of authored meshes, materials, lighting, and product density.
- CSG primitives are still the implementation medium for this pass, so shape/material quality needs screenshot review.
- The first interior benchmark corner exists, but it needs approval before the rest of the shop expands.
- Dense backroom computer screens.
- Some UI panels and labels needing real-window readability approval.
- Customer body/prop language is mechanically present but intentionally hidden for the opening state.
- Fixture and screenshot compositions that may still read as blockout from some angles.

## Current Visual Planning

The active visual direction is [Visual Production](visual-production/README.md). It targets a 2005-2007 independent game shop with stylized semi-realistic indie-sim assets. The exterior/entry direction has shifted from a simple strip-mall storefront to a second-floor mall concourse approach inspired by neon-framed retail facades, glass storefronts, quiet pre-open corridors, planters, railings, shuttered neighboring shops, and a clear walk-in threshold.

Owner note: the opening store should be restrained. Day one should start with a small owned assortment, likely 2 new games, 1 console, and 1 accessory, with starter stock staged in the stockroom for the player to place before opening. Future products should live in catalogs, store-design surfaces, supplier/release planning, or trade-in opportunities until purchased/unlocked; then they arrive through receiving or customer intake.

Start review with:

- [Scene Architecture Modularization](visual-production/17-scene-architecture-modularization.md)
- [Visual Reset](visual-production/00-visual-reset.md)
- [Art Direction Target](visual-production/01-art-direction-target.md)
- [Opening Visual Asset Pass](visual-production/16-opening-visual-asset-pass.md)
- [Mid-00s Game Shop Inventory](visual-production/02-mid-00s-game-shop-inventory.md)
- [Implementation Roadmap](visual-production/12-implementation-roadmap.md)
- [Visual QA Checklist](visual-production/13-visual-qa-checklist.md)
- [Deprecated Visual Docs](visual-production/14-deprecated-visual-docs.md)
- [Day One Stock And Unlocks](visual-production/15-day-one-stock-and-unlocks.md)

## Prior Design Planning

The prior planning program in [Design Planning](design-planning/README.md) remains useful for zone intent, interaction responsibilities, screenshot names, catalog rules, and nonblocking path/prompt constraints. It is now historical for final visual direction.

## Next Decision

Review [Prototype Visual Language Cleanup](visual-production/18-prototype-visual-language-cleanup.md) before more scene work. The production scene/module structure is accepted as the infrastructure baseline, and the cleanup pass is implemented for owner validation. Broader visual work should wait until the cleanup screenshots are accepted or corrected.

If the cleanup pass validates:

1. Continue product and fixture visual-kit implementation on top of the cleaned `store_world.tscn`.
2. Keep `graybox_store.tscn` as a compatibility wrapper for one more review cycle.
3. Move deeper child-node extraction into modules only where approved boundaries need it.
4. Preserve stable interaction targets and screenshot subjects during each visual slice.

If the cleanup pass fails:

1. Revise the visual-production docs.
2. Continue label/backroom/clutter cleanup before adding product or fixture breadth.
3. Keep external alpha playtest paused.

## Active Documentation

- [Validation](production/06-validation.md)
- [Visual Production](visual-production/README.md)
- [Design Planning](design-planning/README.md)
- [Backlog](production/04-backlog.md)
- [Alpha Bug List](production/13-alpha-bug-list.md)
- [Alpha Playtest Package](production/15-alpha-playtest-package.md)
- [Smoke Playtest](qa/smoke-playtest.md)
- [Full-Day Playtest](qa/full-day-playtest.md)
- [Screenshot Review](qa/screenshot-review.md)
- [Release Package Check](qa/release-package-check.md)

## Historical Documentation

Long production plans are retained as implementation records. They explain how the current build got here, but they are not the active next-step source. See [Archive Index](archive/README.md).
