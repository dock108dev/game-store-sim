# Current State

This is the authoritative handoff for the repo. If another doc disagrees with this page or `docs/status.json`, update the older doc or treat it as historical.

## Playable Build

The current Godot game is a broad validated production-blockout build, not a final-art alpha. The first-person retail loop includes:

- Movement, click-first targeting, prompts, hover feedback, and mouse capture recovery.
- Receiving, multi-item carry, pricing, stocking, buyer queueing, and register sales.
- Returns, trade-ins, preorder deposits, service tickets, and daily reports.
- Supplier ordering, physical receiving, backstock storage, stock pulls, fixture orders, fixture placement, and category assignment.
- Release calendar, launch allocation, launch-day resolution, market/demand summaries, upgrades, decoration, save/load, settings, pause/main menu, and desktop pack smoke.
- Optional hidden-thread infrastructure for suspicious items, supplier notes, suspicious customer cues, records, choices, and nonblocking consequences.

## Validation Snapshot

Current gate: `scripts/validate_godot.sh`.

Latest verified baseline:

- 553 GUT tests and 7064 asserts pass.
- UI scenario automation coverage is 508/628, or 80.9%, against an 80% threshold.
- Production script mapping is 52/52, or 100.0%, against an 80% threshold.
- 3 standalone validation tools are active.
- Product catalog validation passes with 33 products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, and old-name scan pass.

Validation artifacts are written to `artifacts/validation/latest/`. The important screenshots are listed in [Screenshot Review](qa/screenshot-review.md) (`docs/qa/screenshot-review.md`).

## Current Blocker

External alpha playtest remains paused. The repo is mechanically green, but human review still has to approve the current 1280x720 screenshot set in a real game window.

Required reviews:

- Owner recovery screenshot review.
- Owner stockroom screenshot review.
- Owner production-visual screenshot review.
- Manual 1280x720 readability pass for prompts, UI panels, product labels, customers, and screenshot composition.

## Visual Read

The game now reads as a playable small game shop with production-blockout visual language: clear zones, signs, products, customers, counter props, stockroom stations, and build-mode ghosts. It still uses primitive geometry and placeholder-heavy bodies/props, so it should not be described as final art.

Current visual risk areas:

- Dense backroom computer screens.
- Some UI panels and labels needing real-window readability approval.
- Placeholder customer body/prop language.
- Fixture and screenshot compositions that may still read as blockout from some angles.

## Current Design Planning

The active planning program is [Design Planning](design-planning/README.md). The first milestone is [Opening Store Quality Bar](design-planning/01-opening-store-quality-bar.md): make the opening store, sales floor, receiving/stockroom, and backroom office good enough to become the quality bar for catalog, decoration, platform, and multi-day playtest work.

## Next Decision

Review [Screenshot Review](qa/screenshot-review.md).

If the screenshot set passes:

1. Use [Opening Store Quality Bar](design-planning/01-opening-store-quality-bar.md) to decide whether the first store/backroom quality target is met.
2. Rerun `scripts/validate_godot.sh`.
3. Run [Release Package Check](qa/release-package-check.md) if the target is good enough for external alpha.
4. Reopen [Alpha Playtest Package](production/15-alpha-playtest-package.md) only after the quality bar passes.

If any screenshot fails:

1. File the failed screenshot and reason in [Alpha Bug List](production/13-alpha-bug-list.md).
2. Fix only the failed visual/readability surface.
3. Rerun `scripts/validate_godot.sh`.
4. Repeat screenshot review.

## Active Documentation

- [Validation](production/06-validation.md)
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
