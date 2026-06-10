# Game Store Sim

First-person specialty video game retail simulator. The player runs a small game shop by physically receiving stock, pricing used games, stocking fixtures, serving customers, handling trade-ins and services, planning launch allocations, and noticing optional suspicious activity under the normal retail loop.

The first playable counter loop is implemented and validated. The first polish/readability pass, alpha hardening pass, readability recovery implementation, employees-only stockroom production phase, and returns baseline are also validated. The next production direction is the multi-slice visual overhaul in `docs/production/18-production-visuals-plan.md`. External alpha playtest is still paused for owner recovery, stockroom, and production-visual screenshot review.

## Current Playable State

- Godot project lives under `game/`.
- Current branch work targets keyboard/mouse desktop play.
- The validated graybox includes receiving stock, multi-item carry, click-first interaction, used-game pricing, display stocking, buyer queueing, register sales, trade-ins, preorder deposits, service completion, supplier ordering, release allocation, launch-day resolution, fixture ordering/placement, hidden-thread clues, persistence smoke coverage, and named validation screenshots.
- The local validation gate is `scripts/validate_godot.sh`.
- The completed stockroom production sequence is `docs/production/17-stockroom-production-plan.md`.
- The active production-visuals sequence is `docs/production/18-production-visuals-plan.md`.

## Current Inputs

- `inspiration/`: reference screenshots from YouTube/Twitch gameplay videos. Streaming overlays, chat boxes, facecams, platform chrome, and creator branding are out of scope. The useful references are store density, fixture placement, signage, color, UI readability, menu grouping, and backroom/office retail identity.

## Document Map

- [Vision](docs/game-design/00-vision.md): target experience, design pillars, scope boundaries.
- [Inspiration Analysis](docs/game-design/01-inspiration-analysis.md): reference takeaways translated into visual, UI, and mechanics principles.
- [Core Loop And Systems](docs/game-design/02-core-loop-and-systems.md): player loop, shop systems, data model, simulation surfaces.
- [Progression And Roadmap](docs/game-design/03-progression-and-content-roadmap.md): expansion phases beyond the current playable slice.
- [Tech Stack And Architecture](docs/production/00-tech-stack-and-architecture.md): current project architecture and implementation rules.
- [Vertical Slice Plan](docs/production/01-vertical-slice-plan.md): historical first-playable checklist and acceptance criteria.
- [Development Process](docs/production/02-development-process.md): slice cadence, definition of done, and validation expectations.
- [Decision Log](docs/production/03-decision-log.md): recorded production decisions and rejected alternatives.
- [Backlog](docs/production/04-backlog.md): current production backlog and completed-slice summary.
- [Validation Strategy](docs/production/06-validation.md): automated gate, coverage policy, manual validation expectations.
- [Current Manual Playtest](docs/production/07-current-manual-playtest.md): human playtest checklist for the current build.
- [Polish Roadmap](docs/production/08-polish-roadmap.md): completed first readability pass for visuals, menus, backroom, computer UX, customers, and store readability.
- [Backroom Polish Implementation Plan](docs/production/09-backroom-polish-implementation-plan.md): slice stops, acceptance checks, validation, and commit/sync rules for the backroom spatial pass.
- [Production Polish Execution Plan](docs/production/10-polish-execution-plan.md): completed multi-slice execution plan for the first polish backlog.
- [Game Completion Plan](docs/production/11-game-completion-plan.md): active plan for moving from validated prototype to alpha-quality game.
- [Production Target Contracts](docs/production/12-production-target-contracts.md): active screenshot teardown, art, layout, UI, content, and acceptance contracts for the next production build.
- [Employees-Only Stockroom Production Plan](docs/production/17-stockroom-production-plan.md): completed Slice 1-8 production record for the physical stockroom, receiving, backstock, office computer, service/security corners, and validation sync.
- [Production Visuals Plan](docs/production/18-production-visuals-plan.md): completed production-blockout baseline for storefront, sales floor, register, product visuals, customers, backroom dressing, UI, lighting, customization, and screenshot review.
- [Hidden Thread](docs/narrative/hidden-thread.md): spoiler-facing plan for the optional suspicious narrative layer.

## Production Rule

Every major system should remain data-first, playable, and validated:

1. Define the smallest player-facing slice.
2. Keep the manual checklist current before and after implementation.
3. Implement narrowly.
4. Run `scripts/validate_godot.sh`.
5. Commit and push each validated slice before starting the next one.
