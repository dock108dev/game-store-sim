# Encounter architecture and state

This describes the active B6 business rules with B7–B9 presentation and the separate September 23 maintenance source in `encounter/`. The older [architecture](architecture.md) and [data model](data-model.md) are retained historical proposals, not the encounter's module layout or save schema. See [local development](local-development.md) for setup and configuration, and the [player guide](../../encounter/README.md) for product rules and controls.

## Runtime map

| Source | Responsibility |
| --- | --- |
| `encounter/project.godot` → `main.tscn` | Compatibility renderer, viewport, save namespace and entry scene. The root node retains the historical name `MotionProof`. |
| `encounter/main.gd` | Builds the world and shift desk, routes input and pending actions, moves actors with `AStarGrid2D`, advances the customer wave, restores the view and runs optional comparison/capture adapters. |
| `encounter/layout.gd` | Pure shared fixture definitions, floor bounds, artwork anchors, ports, slots, obstacle inflation, grid navigation and connectivity validation. |
| `encounter/week_content.gd` | Authoritative catalog, release dates, authored rosters and reference-based buyer budgets; state exposes aliases. |
| `encounter/state.gd` | `RefCounted` business state: inventory, phases, orders, reservations, decisions, sales, reports and validated JSON checkpoints. |
| `encounter/economy.gd` | Pure settlement, financial summaries and reconstruction of frozen closes/terminal results; no workers. |
| `encounter/used.gd` | Saved seller terms/negotiation, exact acquisition commits and used-copy provenance validation. |
| `encounter/staff.gd` | Employment/claim validation, deterministic active-job lookup and cancellation; physical motion remains in the scene. |
| `encounter/actor.gd` | Builds and animates the illustrated rigs from `art/rig.json` and textures. |
| `encounter/scripts/validate.py` | Import-safe entry point with separate project isolation, source manifest, process/log checks and optional capture helpers. |
| `encounter/scripts/test_validation_runner.py` | Standard-library tests for isolated saves and engine failure detection. |
| `encounter/scripts/test_week.gd`, `test_week_regressions.gd` | Current business-state and shared-invariant checks under B6 content rules. |
| `encounter/scripts/test_week_scene.gd`, `test_breadth_scene.gd` | Larger optional validation selection; ordinary controls, full-week and breadth scenarios. |
| `encounter/scripts/test_price_request.gd` | Captures product and cents when a label action is requested, before Rowan finishes walking. |

There are no autoload services, database, API, network providers, scheduler or background worker in the active project. The frame loop in `main.gd` advances visitors, sellers and employees. `week_content.gd` supplies deterministic product preferences and budgets through `state.gd`; no provider or wall-clock input drives demand. Capture frame directories use a timestamp, independently of business decisions.

Input flows through `request_action()` and `perform()` to the state methods; dialogs also call state operations. `refresh()` derives UI from state. Customer motion in `update_wave()` updates persisted positions and settled flags and invokes arrival, browsing, selection, queue and exit transitions. The state layer owns transaction validity, while the scene supplies movement and elapsed browse progress. Animation is presentation, not the inventory ledger.

## Schema 10 / b6-retail-1

`State.data` is a dictionary serialized as JSON. Money is integer cents in runtime state; valid JSON numeric values are normalized to integers on load. `week_content.gd` owns the five-title catalog, releases and authored roster; `state.gd` materializes and validates daily content at opening.

| Fields | Meaning |
| --- | --- |
| `version`, `day`, `phase` | Version 10; days 1–7; `prep`, `open`, `closing`, `report`, `week_complete`, `bankrupt`. |
| `cash`, `received`, `carried` | Starts at 55000 cents; starter shipment received flag; carried-copy reference. The UI snapshots an explicit copy/slot request before walking. |
| `items` | Dictionary keyed by unique physical-copy ID: `product`, `location`, `owner`, `price`, historical `cost`, `fixture_id`, `slot_index`, acquisition ID/sequence, `kind`, `condition`, `available_day`. Locations: `backroom`, `shelf`, `customer`, `sold`. |
| `daily_content` | Immutable per-open-day roster snapshots keyed by day, with unique buyer run/day/ordinal IDs, appearance, title, eligibility, budget and arrival. |
| `sellers` | Persisted per-day terms, offers, accepted cents, revision, inspection, resolution and physical progress; details below. |
| `orders` | Paid day, total quantity, per-product quantity/cost lines, total payment and received flag. |
| `customers`, `queue`, `clock` | Stable visitor IDs, names, preference, budget, arrival, state, position, elapsed browse time, settled flag, live item reference, retained offer-copy reference, offer and decision; FIFO IDs; admission clock. |
| `staff`, `employment`, `jobs`, `next_job` | Employment state/history; serial execution claims with actor, copy, slot/customer, revision, receiving visit and claimed/committed/cancelled status. |
| `wage_commitments`, `settlements`, `terminal` | Staff/day commitment identities; settled-day sequence bounds and frozen financial reports; survived/bankrupt result with due event, shortfall and all unpaid identities. |
| `decisions`, `sales` | Cumulative day/product/customer records. Decisions retain offer, budget and outcome. Sales retain copy, sale price and historical cost. |

Receive creates starter IDs `case-01` through `case-06`; later receipts use `order-<day>-<product>-<copy>`. Capacity is derived from four slots per owned rack; reservations retain their slots until sale. Fixed stations and rack origins are persisted in `layout`; `layout_revision` changes only on confirmed edits. `events` is the authoritative financial ledger (paid/due; only paid entries affect cash), with detail references from orders, sales and fixture purchases. `fulfilled_requests` makes repeated layout confirmations inert across reloads. `reserve()` selects the first eligible copy in stable acquisition-sequence order at the persisted browse rack, breaking ties by copy ID, records an unavailable decision if none exists, or locks a copy and offer. `decide()` records buy/decline; refusal releases the copy. `sale()` requires the settled FIFO head and matching ownership/product/offer, records the sale once, clears live references and frees capacity.

Closing cancels waiting visitors and permits admitted transactions. `finalize()` requires no active jobs, an empty queue, all visitors gone/cancelled and all sellers gone. Atomic settlement pays committed wages in staff-ID order, then $150 day-7 rent, without partial payments. The first unaffordable bill leaves it and all later obligations due. Each day has one `finalize:<run>:<day>` record. Days 1–6 enter report; day 7 ends survived/bankrupt. Terminal phases reject business commands. Report phase permits day advance, with no orders or sales. Supplier ordering and receiving occur in the same preparation; 0–6/released title, one paid mixed order/day, cash and 64-copy inbound/backroom preflight. `advance()` resets the roster/queue/clock while retaining inventory and ledgers. `report(product)` filters current-day sales and misses, counts remaining copies, and returns current cash. Margin is sold revenue minus sold-copy costs; cash is opening cash plus paid sales minus paid supplier/used purchases, fixture, expansion and overhead events. `business_report(day=0)` provides week totals, or daily totals for a specified day. Incurred overhead includes unpaid terminal bills; operating result subtracts incurred overhead from merchandise margin. Inventory purchase outlays and investment remain separate. All supplier spending precedes that day’s opening and frozen settlement report.

`valid()` checks schema, shared layout reachability, unique slots, expected inventory identities and acquisition event provenance, order/cost consistency, cash reconciliation, reservations, decisions, queue and phase relationships. `save_to()` validates, writes and flushes a sibling `.tmp` file, then renames it. `load_from()` parses and validates a separate candidate before replacing live state. This is not a proven crash-durability or arbitrary-corrupt-input guarantee. Autosave runs synchronously after settlement, advance and expansion; `checkpoint_path` is configured by the scene. Failure preserves live transactions, sets `save_pending`, and `retry_save()` writes without replaying commands. Restart must preserve a terminal file before resetting. There is no old-schema migration or backup rotation. Animation poses and player routes are not persisted. See the player guide for checkpoint behavior.

## Repository boundaries

| Directory | Status |
| --- | --- |
| `encounter/` | Active B6 runtime, editable Krita sources, exports, local validators and retained evidence. |
| `samples/b-retail-v4/`, `samples/b-motion/` | Retained art/motion samples and their own Godot projects/tools; not the active retail state. |
| `game/`, root `scripts/` | Historical first-person engine proof, its validator and macOS export preset. These do not build/test the active encounter. |
| `assets/blender/` | Retained source/export/review assets from the earlier workflow. |
| `game-guide/`, historical design/technical docs | Superseded product concepts, explicitly marked historical. Not implemented progression or current acceptance criteria. |
| `real_inspiration/`, `other_game_inspiration/` | Reference material, not runtime integration. |
| `artifacts/`, `encounter/evidence/` | Generated or retained validation material. Historical success applies to its recorded candidate only. |

Older encounter tests (`test_state`, `test_days`, `test_pricing`, `test_wave`, `test_encounter` and older scene variants) remain as slice history; the current validator selects `test_week`, `test_week_regressions`, pending-price, `test_week_scene` and `test_breadth_scene`; the B6 suites preserve relevant layout, growth, staff and used invariants under the new content contract. Do not run every `test_*.gd` as a current test matrix. No removal is required to preserve this boundary.

## Limits and follow-up decisions

B3 retains three products/reference prices and three visitors, with four/eight/twelve capacity. It adds six prepaid copies, a 64-copy backroom/inbound limit, $100 expansion from day 5 and rent/terminal progression. [B3 delivery](../03-production/b3-delivery.md) records the intermediate ruleset and evidence. B4 connects employment and dismissal/open commitments to `commit_wage(staff_id, amount=1200)`, extends drain to execution claims and retains exactly-once events. B5 now adds used trading. B6 now replaces the interim references, roster, seller timing and supplier ordering; see [B6 delivery](../03-production/b6-delivery.md). Historical motion and scripted exit-warning limits remain. B9 separately qualified personal packaging/audio startup; complete-week owner acceptance remains pending.

Maintenance decision (2026-09-16): keep the state rules and schema validation together in `state.gd`; preserve the scene and its comparison/capture adapters in `main.gd` during this tooling pass. Extracting them would change the pending review runtime without a demonstrated need for this cleanup. Historical slice tests and art/capture tools are retained evidence workflows, not unused experiments to delete. No size-only split is warranted.


## B4 employees

Morgan and Jules are available from day-3 preparation via **Employees**. Confirm **Hire · $12 today**, then choose Unassigned, Stocking or Checkout. Hiring owes that day's $12 even if dismissed immediately. Existing staff owe a new day's wage when Open is confirmed; dismiss during preparation before opening to avoid it. Reassignment and idle time never cancel an existing commitment. Opening with unassigned staff displays a warning.

Stocking uses one priced backroom copy and a free shelf slot in prep/open. Workers walk through receiving and then the rack before committing. Checkout claims the settled FIFO head and cashier, then walks/reaches before selling. Keep aisles and work ports clear; Rowan blocks workers just as other bodies do. **Stock** keeps player stocking available while open. **Employees → Take over** transfers unfinished work to Rowan, who must travel normally. A completed sale cannot be reversed.

Arrangement pauses workers and releases unfinished jobs. Closing releases unfinished stock jobs and starts no new ones; checkout staff keep draining. Reload preserves employment, wage commitments, inventory and buyer reservations, cancels saved unfinished execution claims and rebuilds routes from legal separated spawns. Finances and Daily closes include actual wages, paid overhead and full unpaid wage/rent liabilities. Technical evidence, source identity and limitations are in [B4 delivery](../03-production/b4-delivery.md).

## B5 used business

`used.gd` defines final authored seller terms, bounded negotiation, purchase preflight/commit and independent reconstruction of used acquisition provenance. `state.gd` delegates these transitions and retains shared inventory, claims, buyer reservations and sales. `main.gd` supplies visible seller entry/intake/exit, physical Rowan inspection and offer/payment/copy dialogs. `layout.gd` protects seller intake (850,420) and Rowan inspection (810,420), distinct from buyer/cashier ports; all actors share dynamic clearance.

Persisted `sellers` retain day/ID, product, condition, reference/ask/floor, offer list, accepted amount, inspection flag, revision, resolution, motion and position. Used purchases produce one `used_purchase` event and one `used:<run>:<day>:1` copy with immutable accepted cost/provenance and `available_day=day+1`. New copies have `kind=new`, `condition=new`, and availability 1. Validation reconstructs all expected used copies from completed sellers/events, checks negotiation limits, phase/motion history and exactly-once event/cash relationships before publishing a loaded candidate. JSON integer normalization happens after validation.

Product-wide labels affect new copies only. `price_copy` captures exact copy state and rejects reserved, claimed, sold, stale or not-yet-eligible copies; ordinary labeling travels through receiving. Condition factors (good 80%, fair 60%, worn 40%) affect suggested resale and generic seller terms. Five authored sellers override ask/floor; worn day-7 Rally uses generic terms. Buyer budgets stay based on NEW references regardless of selected condition. First title occurrences accept only new; repeats accept used. Stable acquisition order uses event sequence ×100 plus within-shipment index (starter sequences 1–6), then copy ID. Historical costs never change with references or labels. Buyer IDs in jobs validate against their own day/run roster. No shopper negotiation is added.

`Economy.summary` treats supplier and used purchases as cash inventory spending and inventory-at-cost additions. Only sold copies contribute their actual immutable cost to cost of sales/margin. Purchase, wage and rent events remain separate. Closing cancels every unpaid trade, drains visible sellers and admitted buyers, preserves paid purchases, then permits existing staff/bill settlement. See [B5 delivery](../03-production/b5-delivery.md) for exact evidence, intermediate rules and B6 handoff.


## B6 arrival and artwork integration

Eight scene actor slots are rekeyed by run/day/ordinal on advance/reload; at most three buyers are visible/admitted. Worker and seller bodies are separate. All movement preserves shared clearance and requires actual station arrival to commit work. Automatic player/worker travel yields to nearby queued/exiting buyers, preventing reciprocal route oscillation; grid waypoints are reached before advancing, avoiding unsafe corner shortcuts. Appearance overlays retain original rigs and motion limitations. Source SVG groups are editable separately for case/platform, illustration and title. See B6 delivery for current visual checks and limitations.

## B9 packaging and traffic repair

[B9 delivery](../03-production/b9-delivery.md) adds an encounter-only Mac preset and personal export feature without changing schema-10 state or B6 economics. Development and personal save directories remain separate; there is no migration. The traffic yield predicate now checks whether a nearby queued/leaving shopper can actually take a collision-clear next step. A blocked shopper no longer freezes the player/worker that must vacate its route. Static geometry, body clearance and physical work/transaction checks remain. The daily panel names the existing `r.cost` value Sold-copy cost. Source and packaged checks, retained failure evidence and exact candidate hashes are in B9.

## Current SSOT enforcement

[SSOT ownership](ssot.md) records current domains/callers and the retired pricing mode. `State.SCHEMA_VERSION` and `State.RULESET_ID` own persistence identity; entry/reload probes now call `load_from` once and use its failure stage, instead of separately parsing and checking compatibility. Historical slice tests and review evidence remain preserved outside the selected current validation matrix. The dated September 16 decision above describes that tooling pass; this separately authorized pass removes only the obsolete pricing adapter and retains the used assortment/capture workflows.
