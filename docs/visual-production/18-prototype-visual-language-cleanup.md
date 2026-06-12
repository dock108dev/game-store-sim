# Prototype Visual Language Cleanup

## Purpose

Remove the prototype visual language that still dominates the promoted `store_world.tscn` scene before adding product, fixture, catalog, customer, or decoration breadth.

The scene architecture pass is accepted as infrastructure: `store_world.tscn` is the right production target, the module manifests are useful, and `graybox_store.tscn` can remain as a compatibility wrapper for now. It is not accepted as the visual quality bar. The current screenshots still rely too much on floating labels, debug-like signs, random clutter, and simple zone lines.

This pass should make the existing opening store read more like a believable mid-00s mall game shop from first-person screenshots.

## Owner Validation Notes

Accepted:

- The second-floor mall/store entrance direction is better than the earlier store box.
- The scene is now more modular and has a clear production scene target.
- The architecture can be used for the next implementation pass.

Rejected:

- The store still has too many labels and debug-like callouts.
- The interior still has random prototype clutter.
- The backroom is not a convincing room; a floor line is not enough.
- The current result is still far from the inspiration bar.
- Do not move into broad catalog/product/decoration breadth yet.

## Scope

In scope:

- Remove, shrink, or convert oversized floating labels into believable shop surfaces.
- Replace the backroom line divider with a real staff threshold.
- Build one front sales-floor benchmark view from the entrance/register area.
- Clean up receiving and stock clutter so it reads as staged work, not random boxes.
- Preserve the current `store_world.tscn` module boundaries unless a boundary clearly blocks implementation.

Out of scope:

- Full catalog art.
- Full fixture catalog breadth.
- Customer body/silhouette pass.
- Decoration/upgrades breadth.
- Economy, day loop, unlock, supplier, or trade-in system changes.
- Retiring `graybox_store.tscn`.

## Implementation Slices

### Slice 1: Label Purge

Goal: stop labels from carrying the store identity.

Implementation:

- Audit visible labels in `main_scene.png`, `storefront_entry.png`, `register_counter.png`, `receiving_area.png`, and `backroom_summary.png`.
- Delete labels that only exist to explain a prototype object.
- Convert required labels into physical signage:
  - shelf talkers
  - small price tags
  - condition stickers
  - register placards
  - staff-only decals
  - small posters
- Keep interaction prompts and UI labels intact.
- Update tests if they currently assert oversized label nodes instead of meaningful signage nodes.

Acceptance:

- The main screenshots read as a game shop before small text is read.
- No major zone is identified only by a giant floating label.
- Signage looks attached to a surface, fixture, package, counter, or door.

### Slice 2: Backroom Threshold

Goal: make the backroom read as an actual employees-only room.

Implementation:

- Replace the floor-line-only boundary with a staff doorway or partial wall.
- Add a clear threshold: doorframe, side jambs, header, mat, or short hallway cue.
- Add a material and lighting change between sales floor and backroom.
- Keep a visible stock flow beyond the threshold: shelves, receiving, sorted trays, or service bench.
- Keep backroom computer access and receiving paths unblocked.

Acceptance:

- `backroom_summary.png` and the entrance/register view show a believable staff-only transition.
- The player can understand where public floor ends and stockroom begins without reading text.
- Navigation and interaction tests still pass.

### Slice 3: Front Sales-Floor Benchmark

Goal: create one believable interior benchmark from the entry/register sightline.

Implementation:

- Pick the entrance/register-facing view as the benchmark composition.
- Reduce random props that do not support the view.
- Group visible merchandise into intentional fixture states:
  - starter new games
  - one console
  - one accessory/controller
  - used-game shelf/bins
  - receiving stock staged away from display stock
- Add enough physical detail to sell the store: shelving depth, counter trim, display layers, small tags, product silhouettes, and warm/cool lighting contrast.
- Avoid filling the store as if the full catalog is unlocked.

Acceptance:

- `main_scene.png`, `storefront_entry.png`, and `register_counter.png` have a coherent first impression.
- The view has fewer explanation labels and more object identity.
- The shop still feels newly opening and restrained.

### Slice 4: Receiving And Stock Clutter Cleanup

Goal: make boxes and loose items look like an intentional receiving workflow.

Implementation:

- Keep cardboard boxes only where they make operational sense.
- Group stock into receiving, sorted, backstock, and display-ready states.
- Remove or relocate props that look dumped into the scene.
- Clarify invoices, sorted trays, stock tags, and delivery surfaces without label spam.
- Keep day-one physical stock limited; future inventory must remain catalog/planning/receiving driven.

Acceptance:

- `receiving_area.png` and `supplier_delivery.png` show a workflow, not random clutter.
- Products are visually separated from cardboard, invoices, and backstock.
- The player can see what is pickup stock, what is receiving context, and what is decoration.

### Slice 5: Screenshot QA And Docs Sync

Goal: prove the cleanup is worth building on before broader visual breadth.

Implementation:

- Run `scripts/validate_godot.sh`.
- Regenerate the screenshot contact sheet.
- Review:
  - `main_scene.png`
  - `storefront_entry.png`
  - `register_counter.png`
  - `receiving_area.png`
  - `backroom_summary.png`
  - full contact sheet
- Update `docs/status.json`, `docs/CURRENT_STATE.md`, `docs/production/04-backlog.md`, and `docs/production/13-alpha-bug-list.md`.

Acceptance:

- Full validation passes.
- The five review screenshots no longer read primarily as labels, box graphics, zone lines, or random prop dumps.
- Owner can approve the cleaned-up interior as the baseline for product/fixture visual breadth.

## Required Files

Likely touched:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/modules/storefront_shell.tscn`
- `game/scenes/world/modules/store_interior_shell.tscn`
- `game/scenes/world/modules/front_counter_zone.tscn`
- `game/scenes/world/modules/sales_floor_fixtures.tscn`
- `game/scenes/world/modules/receiving_area.tscn`
- `game/scenes/world/modules/backroom_shell.tscn`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/validation/scenarios/store_visual_polish.json`
- `game/tests/validation/scenarios/stockroom_production_plan.json`
- `docs/qa/screenshot-review.md`
- `docs/production/13-alpha-bug-list.md`

## Stop Conditions

Stop and ask for owner validation if:

- The cleanup requires a major store-layout change.
- The backroom threshold blocks routes or breaks core interactions.
- Removing labels makes interaction targets unclear.
- The front benchmark still reads as prototype after label removal.
- The work starts drifting into full product catalog or decoration breadth.

## Next Pass After Approval

If this cleanup passes owner screenshot review, the next implementation pass should be the product and fixture visual kit:

- product cases, console boxes, accessory packs, condition tags
- wall shelf, gondola/bin, pegboard, locked case
- restrained day-one display states
- catalog/unlocked/future inventory kept out of physical stock until purchased, ordered, received, released, or traded in
