# Encounter architecture and state

This describes the implemented B2 project in `encounter/`. The older [architecture](architecture.md) and [data model](data-model.md) are retained historical proposals, not the encounter's module layout or save schema. See [local development](local-development.md) for setup and configuration, and the [player guide](../../encounter/README.md) for product rules and controls.

## Runtime map

| Source | Responsibility |
| --- | --- |
| `encounter/project.godot` → `main.tscn` | Compatibility renderer, viewport, save namespace and entry scene. The root node retains the historical name `MotionProof`. |
| `encounter/main.gd` | Builds the world and shift desk, routes input and pending actions, moves actors with `AStarGrid2D`, advances the customer wave, restores the view and runs optional comparison/capture adapters. |
| `encounter/layout.gd` | Pure shared fixture definitions, floor bounds, artwork anchors, ports, slots, obstacle inflation, grid navigation and connectivity validation. |
| `encounter/state.gd` | `RefCounted` business state: inventory, phases, orders, reservations, decisions, sales, reports and validated JSON checkpoints. |
| `encounter/actor.gd` | Builds and animates the illustrated rigs from `art/rig.json` and textures. |
| `encounter/scripts/validate.py` | Import-safe entry point with separate project isolation, source manifest, process/log checks and optional capture helpers. |
| `encounter/scripts/test_validation_runner.py` | Standard-library tests for isolated saves and engine failure detection. |
| `encounter/scripts/test_assortment.gd` | R5 business-state and save/load checks. |
| `encounter/scripts/test_assortment_scene.gd` | Scene controls, routing, dialogs and two-day behavior; optional rendered screenshots. |
| `encounter/scripts/test_price_request.gd` | Captures product and cents when a label action is requested, before Rowan finishes walking. |

There are no autoload services, database, API, network providers, scheduler or background worker in the active project. The frame loop in `main.gd` advances visitors. `state.gd` supplies deterministic product preferences and budgets; no provider or wall-clock input drives demand. Capture frame directories use a timestamp, independently of business decisions.

Input flows through `request_action()` and `perform()` to the state methods; dialogs also call state operations. `refresh()` derives UI from state. Customer motion in `update_wave()` updates persisted positions and settled flags and invokes arrival, browsing, selection, queue and exit transitions. The state layer owns transaction validity, while the scene supplies movement and elapsed browse progress. Animation is presentation, not the inventory ledger.

## Schema 6 / b2-layout-1

`State.data` is a dictionary serialized as JSON. Money is integer cents in runtime state; valid JSON numeric values are normalized to integers on load. Catalog definitions and customer formulas live in `state.gd`, not in external data files.

| Fields | Meaning |
| --- | --- |
| `version`, `day`, `phase` | Version 6; day starts at 1; `prep`, `open`, `closing`, `report`. |
| `cash`, `received`, `carried` | Starts at 55000 cents; starter shipment received flag; carried-copy reference. The UI snapshots an explicit copy/slot request before walking. |
| `items` | Dictionary keyed by unique physical-copy ID: `product`, `location`, `owner`, `price`, historical `cost`, `fixture_id`, `slot_index`, acquisition ID/sequence. Locations: `backroom`, `shelf`, `customer`, `sold`. |
| `orders` | Paid day, total quantity, per-product quantity/cost lines, total payment and received flag. |
| `customers`, `queue`, `clock` | Stable visitor IDs, names, preference, budget, arrival, state, position, elapsed browse time, settled flag, live item reference, retained offer-copy reference, offer and decision; FIFO IDs; admission clock. |
| `decisions`, `sales` | Cumulative day/product/customer records. Decisions retain offer, budget and outcome. Sales retain copy, sale price and historical cost. |

Receive creates starter IDs `case-01` through `case-03`; later receipts use `order-<day>-<product>-<copy>`. Capacity is derived from four slots per owned rack; reservations retain their slots until sale. Fixed stations and rack origins are persisted in `layout`; `layout_revision` changes only on confirmed edits. `events` is the authoritative paid-cash ledger, with detail references from orders, sales and fixture purchases. `fulfilled_requests` makes repeated layout confirmations inert across reloads. `reserve()` selects the earliest acquired eligible copy at the persisted browse rack, breaking ties by copy ID, records an unavailable decision if none exists, or locks a copy and offer. `decide()` records buy/decline; refusal releases the copy. `sale()` requires the settled FIFO head and matching ownership/product/offer, records the sale once, clears live references and frees capacity.

Closing cancels waiting visitors and permits admitted transactions. `finalize()` requires an empty queue and all visitors gone/cancelled. Report phase permits ordering and day advance but no sales. `advance()` resets the roster/queue/clock while retaining inventory and ledgers. `report(product)` filters current-day sales and misses, counts remaining copies, and returns current cash. Margin is sold revenue minus sold-copy costs; cash is opening cash plus paid sale events minus supplier and fixture purchase events. Rack spending is investment, shown separately from merchandise margin. Neither includes overhead.

`valid()` checks schema, shared layout reachability, unique slots, expected inventory identities and acquisition event provenance, order/cost consistency, cash reconciliation, reservations, decisions, queue and phase relationships. `save_to()` validates, writes and flushes a sibling `.tmp` file, then renames it. `load_from()` parses and validates a separate candidate before replacing live state. This is not a proven crash-durability or arbitrary-corrupt-input guarantee. There is no old-schema migration, autosave or backup rotation. Animation poses and player routes are not persisted. See the player guide for checkpoint behavior.

## Repository boundaries

| Directory | Status |
| --- | --- |
| `encounter/` | Active B2 runtime, editable Krita sources, exports, local validators and retained evidence. |
| `samples/b-retail-v4/`, `samples/b-motion/` | Retained art/motion samples and their own Godot projects/tools; not the active retail state. |
| `game/`, root `scripts/` | Historical first-person engine proof, its validator and macOS export preset. These do not build/test R5. |
| `assets/blender/` | Retained source/export/review assets from the earlier workflow. |
| `game-guide/`, historical design/technical docs | Superseded product concepts, explicitly marked historical. Not implemented progression or current acceptance criteria. |
| `real_inspiration/`, `other_game_inspiration/` | Reference material, not runtime integration. |
| `artifacts/`, `encounter/evidence/` | Generated or retained validation material. Historical success applies to its recorded candidate only. |

Older encounter tests (`test_state`, `test_days`, `test_pricing`, `test_wave`, `test_encounter` and older scene variants) remain as slice history; the current validator selects the assortment state/scene, pending-price, and B2 layout state/scene suites. Do not run every `test_*.gd` as a current test matrix. No removal is required to preserve this boundary.

## Limits and follow-up decisions

B2 retains three products and three visitors, with four/eight capacity and preparation-only layout controls. There is no expansion, staff, used trading, bills, release calendar or seven-day endpoint yet. [B2 delivery](../03-production/b2-delivery.md) records the geometry correction, source identity, technical evidence and B3 handoff. Historical motion and exit-warning limits remain. Packaging and complete-week acceptance are later gates.

Maintenance decision (2026-09-16): keep the state rules and schema validation together in `state.gd`; preserve the scene and its comparison/capture adapters in `main.gd` during this tooling pass. Extracting them would change the pending review runtime without a demonstrated need for this cleanup. Historical slice tests and art/capture tools are retained evidence workflows, not unused experiments to delete. No size-only split is warranted.
