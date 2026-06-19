# Game Store Sim

This repo is the source-of-truth documentation and future implementation repo for Game Store Sim.

Game Store Sim is a first-person, warm-nostalgic retail life sim about opening a small independent video game store in a mall and growing it from an understocked lease into a memorable local shop. The game uses fictional brands, fictional products, fictional platforms, and fictional suppliers. Real-world and other-game references are used for design extraction only, not for direct copying.

## Start Here

Read these files first:

1. [Source Master Plan](docs/MASTER_PLAN.md)
2. [Product Brief](docs/00-product/product-brief.md)
3. [Vertical Slice Contract](docs/01-design/vertical-slice-contract.md)
4. [Engine Evaluation](docs/02-technical/engine-evaluation.md)
5. [Local Validation Plan](docs/04-validation/local-validation-plan.md)

## Repository Roles

- `docs/`: production, design, engineering, validation, and decision docs.
- `game-guide/`: player-facing strategy-guide canon and validation reference. It is not frozen. If production docs need to change a canon rule, the change should be explicit and discussed.
- `real_inspiration/`: real period retail references for extracting fixture, lighting, density, signage, and object rules.
- `other_game_inspiration/`: game feel and simulator presentation references for extracting interaction, UI, and readability patterns.

## Current Build State

As of this documentation pass, this repo contains design/reference material only. The engine project has not started yet.

The first implementation milestone is the 0.0%-0.3% vertical slice:

- enter the mall store
- receive starter shipment
- pick up physical inventory
- price used stock with suggested pricing
- stock shelves one physical item at a time
- open the store
- serve physical customers
- complete first sale
- close register
- read daily report
- save and load

