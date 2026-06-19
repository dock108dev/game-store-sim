# Game Store Sim

This repo is the source-of-truth documentation and future implementation repo for Game Store Sim.

Game Store Sim is a first-person, warm-nostalgic retail life sim about opening a small independent video game store in a mall and growing it from an understocked lease into a memorable local shop. The game uses fictional brands, fictional products, fictional platforms, and fictional suppliers. Real-world and other-game references are used for design extraction only, not for direct copying.

## Start Here

Read these files first:

1. [Source Master Plan](docs/MASTER_PLAN.md)
2. [Product Brief](docs/00-product/product-brief.md)
3. [Vertical Slice Contract](docs/01-design/vertical-slice-contract.md)
4. [First 0.3% Visual Benchmark](docs/01-design/visual-benchmark-first-0.3.md)
5. [Visual First Task List](docs/03-production/visual-first-task-list.md)
6. [Local Validation Plan](docs/04-validation/local-validation-plan.md)

## Repository Roles

- `docs/`: production, design, engineering, validation, and decision docs.
- `game-guide/`: player-facing strategy-guide canon and validation reference. It is not frozen. If production docs need to change a canon rule, the change should be explicit and discussed.
- `real_inspiration/`: real period retail references for extracting fixture, lighting, density, signage, and object rules.
- `other_game_inspiration/`: game feel and simulator presentation references for extracting interaction, UI, and readability patterns.

## Current Build State

The repo has a Godot/macOS engine proof that validates the technical path: item state, pickup/stock/sale flow, customer state, save/load, local validation, macOS export, and exported app launch.

The current active milestone is not more gameplay breadth. It is the visual benchmark for the first 0.3% of the game. The existing engine proof scene is technical scaffolding, not the production visual baseline.

The first 0.3% vertical slice still covers:

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

Before those systems expand, the first store must visually lock:

- mall storefront
- empty understocked sales floor
- receiving/backroom
- counter/register
- starter shipment
- carried game case
- shelf with about ten physical games
- customer entering from mall
- daily report presentation
