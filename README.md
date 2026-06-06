# Game Store Sim

Working title for a first-person retro game retail simulator inspired by late-90s and 2000s specialty stores: EB Games, FuncoLand, GameStop, local video game shops, trade-in counters, preorder desks, repair benches, and the weird service economy around used games.

This repository is in preproduction. The current goal is to plan the game like an indie production, then build it in vertical slices instead of making a disposable prototype.

## Current Inputs

- `inspiration/`: reference screenshots from YouTube/Twitch gameplay videos. Streaming overlays, chat boxes, facecams, and platform UI are out of scope.

## Document Map

- [Vision](docs/game-design/00-vision.md): target experience, design pillars, scope boundaries.
- [Inspiration Analysis](docs/game-design/01-inspiration-analysis.md): what the screenshots imply mechanically and visually.
- [Core Loop And Systems](docs/game-design/02-core-loop-and-systems.md): player loop, shop systems, data model, simulation surfaces.
- [Progression And Roadmap](docs/game-design/03-progression-and-content-roadmap.md): expansions, unlocks, and scalable content phases.
- [Tech Stack And Architecture](docs/production/00-tech-stack-and-architecture.md): engine choice, tooling, project structure, implementation strategy.
- [Vertical Slice Plan](docs/production/01-vertical-slice-plan.md): first playable milestones and acceptance criteria.
- [Development Process](docs/production/02-development-process.md): slice cadence, decision logging, backlog buckets, and definition of done.
- [Decision Log](docs/production/03-decision-log.md): recorded production decisions and rejected alternatives.
- [Backlog](docs/production/04-backlog.md): coarse work buckets for the first slices.
- [Hidden Thread](docs/narrative/hidden-thread.md): spoiler-facing plan for the optional illegal-activity narrative.

## Production Rule

Every major system should be built data-first and slice-first:

1. Prove the fun with the smallest playable loop.
2. Move tunable values into data files.
3. Add content through data before adding new code.
4. Only broaden scope after the current loop is testable and shippable.
