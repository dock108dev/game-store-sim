# Implementation Roadmap

## Strategy

Do not replace the whole store at once.

Build one final-quality visual slice, review it, then propagate its asset/style language through the store.

## Phase 0: Visual Reset Planning

Status: complete, with revision from owner review.

Deliverables:

- This visual-production folder.
- Updated current-state/status language.
- Deprecated visual-doc list.
- Mid-00s game shop inventory checklist.

Exit criteria:

- Owner rejected the first phase 0-4 visual screenshot pass as too blockout/label-driven.
- Owner revised the opening target toward a second-floor mall walk-in scene with no customers or employees visible before opening.
- Owner approves or revises the day-one stock rule: 2 new games, 1 console, 1 accessory, trade-ins as early growth, future products visible through catalogs/planning surfaces, and physical stock arriving only after purchase/order/unlock.

## Phase 1: Opening Composition Reset

Status: composition reset implemented; directionally better, but not an approved art baseline.

Recommended scope:

- Second-floor mall concourse spawn.
- Branded glass storefront first view.
- Walkable threshold into an empty pre-open store.
- Register counter.
- One adjacent sales-floor shelf/aisle.
- Owned starter-stock staging for the opening setup fantasy.

Deliverables:

- Second-floor mall entry layout.
- Walkable storefront threshold.
- Empty pre-open store state.
- First-person screenshots.
- Updated scene tests for required visual anchors.
- QA checklist pass/fail notes.
- Day-one stock/unlock notes.

Exit criteria:

- Opening screenshots show the player outside the shop, walking in from a mall concourse.
- Opening screenshots show no visible customers or employees before business begins.
- Screenshots show a restrained newly opening shop, not a fully stocked endpoint.
- Owner confirms the premise is worth turning into the first visual asset pass.

## Phase 1A: Opening Visual Asset Pass

Status: implemented; ready for owner screenshot and real-window walk-in review.

Scope:

- Mall spawn.
- Storefront approach.
- Glass threshold and door.
- First interior view from the doorway.
- One polished interior benchmark corner.

Deliverables:

- Authored mall/storefront shell kit. Implemented as tile panels, grout seams, round rail posts, shutter slats, planters, directory detail, storefront mullions, threshold pieces, and sign treatment.
- Authored signage/decal treatment that supports identity without carrying it alone. Implemented with smaller decals, sign icons, and storefront module details.
- Authored starter product/display props for 2 games, 1 console, and 1 accessory. Implemented in the window/entry route with case, console, accessory, cover, sticker, and price-tag modules.
- Beveled/trimmed store shell, floor, ceiling, rail, planter, and window details. Implemented as the first modular CSG asset pass.
- Updated scene tests and screenshot review notes. Implemented; owner approval remains pending.

Exit criteria:

- `main_scene.png` and `storefront_entry.png` do not read as box graphics with labels after owner review.
- The route reads as a mall game shop before small text is read.
- The first interior corner becomes the style benchmark for the rest of the store.
- The player can still walk from spawn through the storefront without new blockers.
- Owner approves style before broader replacement.

## Phase 1B: Scene Architecture Modularization

Status: planned next; ready for implementation.

Scope:

- Create a production scene, preferably `game/scenes/world/store_world.tscn`.
- Keep `graybox_store.tscn` as the legacy integration reference until parity is proven.
- Extract the opening route into reusable modules.
- Separate visual modules from gameplay managers.
- Preserve screenshot anchors, interaction targets, and validation behavior.

Deliverables:

- `store_world.tscn` production root.
- `game/scenes/world/modules/` with opening-route modules first.
- `store_systems.tscn` or equivalent systems grouping.
- Tests proving both legacy and production scenes load until promotion.
- Updated screenshot/tooling references once the production scene is promoted.

Exit criteria:

- `scripts/validate_godot.sh` passes.
- Production scene loads and preserves the mall spawn, storefront threshold, core systems, and key interaction targets.
- Screenshot capture targets the production scene after promotion.
- Active docs no longer treat `graybox_store.tscn` as the future visual production surface.

## Phase 2: Product And Fixture Kit

Status: mechanically present; paused until Phase 1B is implemented and validated.

Scope:

- Product case/box/cartridge/sleeve language.
- Shelf, gondola, bin, pegboard, locked case.
- Price/condition/platform stickers.
- Catalog/planning states for locked products, supplier orders, release stock, fixture/store-design items, and trade-in stock.

Exit criteria:

- `stocked_aisle.png`, `carry_stack.png`, and `fixture_placed.png` pass visual QA.
- Locked products do not appear sellable before they are unlocked.
- Future products do not appear as physical stock before they are purchased, ordered, released, or traded in.

## Phase 3: Backroom Operations Kit

Status: mechanically present; paused until Phase 1B is implemented and validated.

Scope:

- Receiving station.
- Backstock shelves.
- Pull stage.
- Office desk and service bench visual kit.

Exit criteria:

- `receiving_area.png`, `supplier_delivery.png`, and `backroom_summary.png` pass visual QA.

## Phase 4: Customer Role Visuals

Status: mechanically present; hidden during the pre-open slice and paused until Phase 1B is implemented and validated.

Scope:

- Customer silhouettes.
- Role props.
- Queue/readability.
- Modal background composition.

Exit criteria:

- Customer role screenshots pass without relying on floating labels.

## Phase 5: Lighting And Polish Pass

Scope:

- Sales/backroom lighting.
- Material consistency.
- Contact shadows/AO/postprocess.
- Screenshot composition.

Exit criteria:

- All 23 validation screenshots pass visual QA.
- Current state can move from `prototype_blockout_visuals` to `visual_vertical_slice_approved` or later approved state.

## Gates

Every phase requires:

- Screenshot review.
- `scripts/validate_godot.sh`.
- Updated docs/status if phase changes.
- No P0/P1 visual regression in `docs/production/13-alpha-bug-list.md`.
