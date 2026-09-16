# Encounter architecture and state

This describes the implemented R5 project in `encounter/`. The older [architecture](architecture.md) and [data model](data-model.md) are retained historical proposals, not the encounter's module layout or save schema. See [local development](local-development.md) for setup and configuration, and the [player guide](../../encounter/README.md) for product rules and controls.

## Runtime map

| Source | Responsibility |
| --- | --- |
| `encounter/project.godot` → `main.tscn` | Compatibility renderer, viewport, save namespace and entry scene. The root node retains the historical name `MotionProof`. |
| `encounter/main.gd` | Builds the world and shift desk, routes input and pending actions, moves actors with `AStarGrid2D`, advances the customer wave, restores the view and runs optional comparison/capture adapters. |
| `encounter/state.gd` | `RefCounted` business state: inventory, phases, orders, reservations, decisions, sales, reports and validated JSON checkpoints. |
| `encounter/actor.gd` | Builds and animates the illustrated rigs from `art/rig.json` and textures. |
| `encounter/scripts/validate.py` | Import-safe entry point with separate project isolation, source manifest, process/log checks and optional capture helpers. |
| `encounter/scripts/test_validation_runner.py` | Standard-library tests for isolated saves and engine failure detection. |
| `encounter/scripts/test_assortment.gd` | R5 business-state and save/load checks. |
| `encounter/scripts/test_assortment_scene.gd` | Scene controls, routing, dialogs and two-day behavior; optional rendered screenshots. |
| `encounter/scripts/test_price_request.gd` | Captures product and cents when a label action is requested, before Rowan finishes walking. |

There are no autoload services, database, API, network providers, scheduler or background worker in the active project. The frame loop in `main.gd` advances visitors. `state.gd` supplies deterministic product preferences and budgets; no provider or wall-clock input drives demand. Capture frame directories use a timestamp, independently of business decisions.

Input flows through `request_action()` and `perform()` to the state methods; dialogs also call state operations. `refresh()` derives UI from state. Customer motion in `update_wave()` updates persisted positions and settled flags and invokes arrival, browsing, selection, queue and exit transitions. The state layer owns transaction validity, while the scene supplies movement and elapsed browse progress. Animation is presentation, not the inventory ledger.

## Schema 5

`State.data` is a dictionary serialized as JSON. Money is integer cents in runtime state; valid JSON numeric values are normalized to integers on load. Catalog definitions and customer formulas live in `state.gd`, not in external data files.

| Fields | Meaning |
| --- | --- |
| `version`, `day`, `phase` | Version 5; day starts at 1; `prep`, `open`, `closing`, `report`. |
| `cash`, `received`, `carried` | Starts at 55000 cents; starter shipment received flag; carried-copy reference. The current UI primarily uses direct stock allocation. |
| `items` | Dictionary keyed by unique physical-copy ID: `product`, `location`, `owner`, `price`, historical `cost`. Locations: `backroom`, `shelf`, `customer`, `sold`. |
| `orders` | Paid day, total quantity, per-product quantity/cost lines, total payment and received flag. |
| `customers`, `queue`, `clock` | Stable visitor IDs, names, preference, budget, arrival, state, position, elapsed browse time, settled flag, live item reference, retained offer-copy reference, offer and decision; FIFO IDs; admission clock. |
| `decisions`, `sales` | Cumulative day/product/customer records. Decisions retain offer, budget and outcome. Sales retain copy, sale price and historical cost. |

Receive creates starter IDs `case-01` through `case-03`; later receipts use `order-<day>-<product>-<copy>`. Four shelf spaces include reservations. `reserve()` selects the first eligible copy in dictionary order, records an unavailable decision if none exists, or locks a copy and offer. `decide()` records buy/decline; refusal releases the copy. `sale()` requires the settled FIFO head and matching ownership/product/offer, records the sale once, clears live references and frees capacity.

Closing cancels waiting visitors and permits admitted transactions. `finalize()` requires an empty queue and all visitors gone/cancelled. Report phase permits ordering and day advance but no sales. `advance()` resets the roster/queue/clock while retaining inventory and ledgers. `report(product)` filters current-day sales and misses, counts remaining copies, and returns current cash. Margin is sold revenue minus sold-copy costs; cash is initial cash plus cumulative sales minus paid orders. Neither includes overhead.

`valid()` checks schema, expected inventory identities, order/cost consistency, cash reconciliation, reservations, decisions, queue and phase relationships. `save_to()` validates, writes and flushes a sibling `.tmp` file, then renames it. `load_from()` parses and validates a separate candidate before replacing live state. This is not a proven crash-durability or arbitrary-corrupt-input guarantee. There is no old-schema migration, autosave or backup rotation. Animation poses and player routes are not persisted. See the player guide for checkpoint behavior.

## Repository boundaries

| Directory | Status |
| --- | --- |
| `encounter/` | Active R5 runtime, editable Krita sources, exports, local validators and retained evidence. |
| `samples/b-retail-v4/`, `samples/b-motion/` | Retained art/motion samples and their own Godot projects/tools; not the active retail state. |
| `game/`, root `scripts/` | Historical first-person engine proof, its validator and macOS export preset. These do not build/test R5. |
| `assets/blender/` | Retained source/export/review assets from the earlier workflow. |
| `game-guide/`, historical design/technical docs | Superseded product concepts, explicitly marked historical. Not implemented progression or current acceptance criteria. |
| `real_inspiration/`, `other_game_inspiration/` | Reference material, not runtime integration. |
| `artifacts/`, `encounter/evidence/` | Generated or retained validation material. Historical success applies to its recorded candidate only. |

Older encounter tests (`test_state`, `test_days`, `test_pricing`, `test_wave`, `test_encounter` and older scene variants) remain as slice history; the current validator selects the three R5 suites above. Do not run every `test_*.gd` as a current test matrix. No removal is required to preserve this boundary.

## Limits and follow-up decisions

R5 is a local bounded review project: three products, four shelf positions and three visitors per day. There is no substitution, multi-item basket, employee/reputation system or shop expansion. Existing motion limitations and the unresolved capture-exit ObjectDB warning are recorded in [R5 delivery](../03-production/r5-delivery.md). Save migration, broader gameplay, motion reconstruction, portable tooling and a release/export pipeline require separately scoped work. The repository contains no active encounter export preset or CI workflow; the historical export is not evidence of R5 packaging, signing or release readiness.

Maintenance decision (2026-09-16): keep the state rules and schema validation together in `state.gd`; preserve the scene and its comparison/capture adapters in `main.gd` during this tooling pass. Extracting them would change the pending review runtime without a demonstrated need for this cleanup. Historical slice tests and art/capture tools are retained evidence workflows, not unused experiments to delete. No size-only split is warranted.
