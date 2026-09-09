# Recovery review — 2026-09-07

## Identity and actual inventory

Recovered baseline: `837bd4a8d33ec01fe48dec83bd16fedb9dfaaff1`, initially clean on `main`, matching locally stored `origin/main`. Full, non-shallow history: 546 reachable commits; `git fsck --full` exited 0 without diagnostics. Only local `main` and remote `origin/main` existed before preparation. Remote configured as `https://github.com/dock108dev/game-store-sim.git`. No fetch, push, remote mutation, or branch recovery was needed. The recovery tracker reports the GitHub repository archived; live archive status was not rechecked in this local review.

Created local `codex/restart-preparation` at that baseline. Preparation is uncommitted and is not a new accepted candidate. Baseline source remains unchanged.

The tracked checkout has 160 files before preparation: four GDScript files, two scenes, one editable Blender source and 18 GLB files (nine exports mirrored into the engine assets). No tracked PNG or Krita masters were found. References also include other formats; absence of PNG does not imply absence of reference imagery. Generator scripts, a manifest and capture tooling exist. Regeneration from Blender source was not tested.

- `game/project.godot`: Godot 4.6 configuration, GDScript, Compatibility; main scene is `scenes/main/engine_proof.tscn`.
- `game/scripts/systems/engine_proof_state.gd`: the actual stock, fixtures, customer records, sale/report and save/load implementation.
- `game/scripts/systems/engine_proof_scene.gd`: builds a first-person box world, capsule customer, simple UI and keyboard adapters at runtime.
- `game/scenes/visual_benchmark/VisualBenchmarkStore.tscn`: separate assembled GLB store, lights and reference cameras. No retail state script is attached to this scene. The main playable proof does not use these benchmark assets.
- `game/scripts/tools/run_validation.gd`: scripted happy path, scene/manifest/asset loads, JSON summary, synthetic pixel-painted image.
- `game/scripts/tools/capture_visual_benchmark.gd` and Blender capture/generator scripts: historical visual tooling, not fresh graphics evidence.

History begins with mallcore-sim scaffolding (`48517113`) and contains older movement, UI and broader store experiments. Later cleanup (`6818e005`) removed older state/specification material; `48757fcc` introduced the currently surviving proof-state file and broad visual-first direction. `647612ff` extended load validation; `837bd4a8` changed GLBs/generation/capture composition. Earlier hero-art and completion claims belong to earlier work. They are neither current executable breadth nor a reason to restore deleted systems. The full history remains available if a specific reuse need emerges.

## Retail decisions and consequences

| Loop step | What works now | Decision/consequence worth preserving; missing pieces |
| --- | --- | --- |
| Prepare | $550 starting cash, 12 seeded items, two fixtures with 12 and 8 slots; one preset shelf move | Allocate space and cash before opening. Current move is a fixed position/rotation; no layout validity, meaningful placement choice or customer-route consequence. |
| Receive | Starter items already exist in shipment-box state; nearby items can be picked up | Decide what to buy/receive and verify quantity/cost. No receiving action, invoice reconciliation, purchase spending, supplier order or reorder. Starter acquisition is not deducted from cash. |
| Price | Used-item API accepts a price, rounds cents and clamps to at least $0.01; new items reject repricing | Balance margin against sell-through. P only chooses the suggested maximum; customers ignore price, budget and preference, so the central tradeoff is absent. |
| Stock | Item identity/location, carried item and occupied shelf slots; sold items cannot be stocked | Choose what gets limited shelf capacity. The scene always places into the first available slot on the used shelf, from anywhere, so location/category/layout strategy is not realized. |
| Open | Prep → open, then one customer spawned by the scene | Decide readiness versus sales opportunity. Opening empty is allowed; no time/cost pressure, recurring arrivals or schedule. |
| Serve | Capsule tweens to shelf and counter; record becomes queued | Prioritize customers and respond to demand. Customer selects the first sellable stocked item; no demand, patience, navigation, real queue/reservation, or alternatives. Empty-stock callback still claims the customer queued and moves its visual toward the counter. |
| Sell | E records revenue/cost/margin, increments cash, clears shelf slot and marks item sold | Understand what sold and why. Sale needs no counter proximity; item reservations and phase/hand consistency are defective. Gross margin is not net profit. |
| Close | Open → report | Decide when to stop and settle outstanding work. Closing does not wait for customers and sales can still occur afterward. |
| Review | Revenue, cost basis, gross margin, units, cash, remaining sellable stock, event count | Diagnose stock/price decisions. All transactions are aggregated, not filtered by day; remaining includes unshelved stock. No missed-demand reasons, expenses, trends, or actionable guidance. |
| Decide next | No implementation | No advance-day function, new preparation phase, reorder, restock budget or repeatable business cycle. This is the largest missing link in the loop. |

This is a useful one-sale scaffold, not yet evidence of a compelling repeated game. Item handling can be direct selection, drag/drop, sprites or 3D objects in a restart; the player decisions do not require the current camera.

## Reuse assessment

Best candidates are logical item IDs/location transitions, fixture occupancy, transaction cost/revenue fields, event records, report arithmetic, serialization shape and isolated happy-path fixtures. `EngineProofState` extends RefCounted and is separate from scene nodes, which makes a presentation-independent extraction plausible. Fixture positions use three-number arrays and must be adapted or replaced for the selected view. Reuse concepts selectively, not the whole class without review.

Before relying on reused logic, address the reproduced transaction defects below. Also review save schema/invariant validation (version checking alone is insufficient), invalid inputs, atomic save behavior, and day-scoped reporting. These are source-inspection risks, not additional executed failures. Current scene reload rebuilds items/fixtures but does not reconstruct customer visuals/tweens or report UI from loaded state; happy-path persistence does not prove general scene restoration.

The old movement, hard-coded placement, debug UI, tween customer and geometry are disposable adapters. Blender source, exports and reference material are optional resources; no visual quality or production repeatability verdict was made. The manager/autoload architecture in old docs is a proposal, not separate implemented systems. Trade-ins, services, reputation, secrets, expansion and multi-era completion in the guide are historical plans only.

## Fresh verification and limits

Godot `4.6.2.stable.official.71f334935`. Tested a `git archive` of the exact baseline in a temporary directory. Only disposable project settings changed to give Godot a unique custom user directory. Original gameplay/source files were untouched; proof saves used an explicit artifact path, and K/L handler testing used the unique directory. No owner save was read or overwritten. Prior `artifacts/validation/latest` was not replaced in the recovered checkout.

| Check | Result | Scope |
| --- | --- | --- |
| Git integrity/full history/initial cleanliness | PASS | Local checkout and object database, not live remote state |
| Original `bash scripts/validate_local.sh` | PASS, exit 0 | Fresh import, both scene loads, nine manifest asset loads, 15 happy-path state steps, synthetic image write and short headless main-scene launch |
| Baseline log scan | No WARNING/ERROR matches | Does not establish visual quality or broad runtime correctness |
| Extra recovery probes | 6 pass, 4 fail; exit 1 | Includes real scene instantiation/tween and handler smoke under headless execution, not an owner-operated playtest |
| Export, exported app, display-backed graphics, manual usability, animation quality | NOT RUN | Historical claims and preset presence do not count as fresh verification |

Passing extra probes: fixed new-stock pricing, occupied-slot rejection, duplicate-sale rejection, exact $569.99 cash / $11.99 margin for a $19.99 sale with $8 cost, customer tween reaching queued state, and scene-handler sale → report → save/load.

Reproduced failures (left unchanged in this review):

1. **Sale after close:** queue a customer, close, then complete_sale succeeds in report phase. Closed report/cash can change.
2. **Duplicate selection:** two customers queue against the same item. There is no reservation; the second is stranded after the first buys it.
3. **Sold item still carried:** queue, pick up selected stock, complete sale; carried_item_id still references a sold item.
4. **Forward input reversed:** press move_forward at initial orientation; player moves +Z while camera forward is -Z. The input-vector sign is multiplied against an already negated forward basis.

No gameplay fixes were made. The original gate remains honestly green and the additional suite honestly red. Its pixel-painted `engine-proof-state.png` is a synthetic technical fixture, not a rendered screenshot. The shell image sanity check examines compressed bytes/dimensions, not scene quality. The default gate does not run the real capture tool or optional export and does not cover all advertised historical validation requirements.

## Evidence and preparation changes

[Preserved evidence](../04-validation/recovery-evidence-2026-09-07/context.json) includes baseline identity/isolation, full validator log, summary, probe source, probe log, results, exit codes and hashes. Raw local output, synthetic image and isolated save copy also remain under `artifacts/recovery-2026-09-07/`. The temporary checkout/user directory are retained for reproducibility, not owner state. See the [validation instructions](../04-validation/local-validation-plan.md).

README/master plan, art direction, proof contract, work list, milestones and source policy now describe this restart. Decision 0005 supersedes old locks. Historical documents are visibly labeled at their own entry points; their bodies remain available for research. Desktop tracker is synchronized. No gameplay/assets changed, art generated, feature built, commit made, or remote modified.

## Single next action

Present a compact board of actual visual references for illustrated 2D, 2.5D and 3D, showing retail readability and motion tradeoffs, so the owner can select the primary reference before any art or engine sample is built.
