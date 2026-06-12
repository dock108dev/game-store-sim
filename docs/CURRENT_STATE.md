# Current State

This is the authoritative handoff for the repo. If another doc disagrees with this page or `docs/status.json`, update the older doc or treat it as historical.

## Playable Build

The current Godot game is a broad validated mechanical prototype with visual phases 0-4 implemented for owner review. It is not a final-art alpha until the owner screenshot pass approves the new target. The first-person retail loop includes:

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

- 565 GUT tests and 9694 asserts pass.
- UI scenario automation coverage is 508/628, or 80.9%, against an 80% threshold.
- Production script mapping is 52/52, or 100.0%, against an 80% threshold.
- 3 standalone validation tools are active.
- Product catalog validation passes with 60 products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, and old-name scan pass.
- All 23 required screenshots are present, and the latest contact sheet is `artifacts/validation/latest/screenshot-contact-sheet.png`.

Validation artifacts are written to `artifacts/validation/latest/`. The important screenshots are listed in [Screenshot Review](qa/screenshot-review.md) (`docs/qa/screenshot-review.md`).

## Current Blocker

External alpha playtest remains paused. The repo is mechanically green, and visual phases 0-4 are implemented for owner validation, but they still need screenshot/signoff review before the store can be treated as the approved visual baseline.

Required reviews:

- Owner visual phases 0-4 screenshot review.
- Owner day-one owned-stock flow review.
- Owner catalog/unlock/receiving flow review.
- Manual 1280x720 readability pass for prompts, UI panels, product labels, customers, and screenshot composition.

## Visual Read

The current scene is still pending owner art approval, but phases 0-4 now have concrete review surfaces: target storefront/register/shelf slice, restrained day-one owned starter stock, catalog/design planning surfaces for locked inventory, paid-arrivals receiving lane, backroom operations props, and customer role silhouettes.

Current visual risk areas:

- Some areas may still read as a Godot blockout from editor and player views until Phase 5 lighting/polish.
- Store identity depends too much on labels instead of authored meshes, materials, lighting, and product density.
- CSG primitives are being used as visual stand-ins beyond their useful prototype role.
- Dense backroom computer screens.
- Some UI panels and labels needing real-window readability approval.
- Placeholder customer body/prop language.
- Fixture and screenshot compositions that may still read as blockout from some angles.

## Current Visual Planning

The active visual direction is [Visual Production](visual-production/README.md). It targets a 2005-2007 independent strip-mall used game shop with stylized semi-realistic indie-sim assets. Phases 0-4 are implemented and ready for owner review before Phase 5 lighting/polish and broader all-screenshot approval.

Owner note: the opening store should be restrained. Day one should start with a small owned assortment, likely 2 new games, 1 console, and 1 accessory, with starter stock staged in the stockroom for the player to place before opening. Future products should live in catalogs, store-design surfaces, supplier/release planning, or trade-in opportunities until purchased/unlocked; then they arrive through receiving or customer intake.

Start review with:

- [Visual Reset](visual-production/00-visual-reset.md)
- [Art Direction Target](visual-production/01-art-direction-target.md)
- [Mid-00s Game Shop Inventory](visual-production/02-mid-00s-game-shop-inventory.md)
- [Implementation Roadmap](visual-production/12-implementation-roadmap.md)
- [Visual QA Checklist](visual-production/13-visual-qa-checklist.md)
- [Deprecated Visual Docs](visual-production/14-deprecated-visual-docs.md)
- [Day One Stock And Unlocks](visual-production/15-day-one-stock-and-unlocks.md)

## Prior Design Planning

The prior planning program in [Design Planning](design-planning/README.md) remains useful for zone intent, interaction responsibilities, screenshot names, catalog rules, and nonblocking path/prompt constraints. It is now historical for final visual direction.

## Next Decision

Review [Visual Production](visual-production/README.md) and the latest screenshot artifacts.

If visual phases 0-4 pass:

1. Lock phases 0-4 as the first approved visual baseline.
2. Continue to Phase 5 lighting/material/camera polish.
3. Use [Visual QA Checklist](visual-production/13-visual-qa-checklist.md) for all 23 screenshot approvals.
4. Keep catalog/unlock/receiving rules as a hard progression constraint.

If any phase fails:

1. Revise the visual-production docs.
2. Patch the rejected scene surfaces or visual rules.
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
