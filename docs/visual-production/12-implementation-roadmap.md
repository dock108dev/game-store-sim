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

Status: planned next; ready for implementation discussion.

Scope:

- Mall spawn.
- Storefront approach.
- Glass threshold and door.
- First interior view from the doorway.
- One polished interior benchmark corner.

Deliverables:

- Authored mall/storefront shell kit.
- Authored signage/decal treatment that supports identity without carrying it alone.
- Authored starter product/display props for 2 games, 1 console, and 1 accessory.
- Beveled/trimmed store shell, floor, ceiling, rail, planter, and window details.
- Updated scene tests and screenshot review notes.

Exit criteria:

- `main_scene.png` and `storefront_entry.png` do not read as box graphics with labels.
- The route reads as a mall game shop before small text is read.
- The first interior corner becomes the style benchmark for the rest of the store.
- The player can still walk from spawn through the storefront without new blockers.
- Owner approves style before broader replacement.

## Phase 2: Product And Fixture Kit

Status: mechanically present; paused until Phase 1A is approved.

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

Status: mechanically present; paused until Phase 1A is approved.

Scope:

- Receiving station.
- Backstock shelves.
- Pull stage.
- Office desk and service bench visual kit.

Exit criteria:

- `receiving_area.png`, `supplier_delivery.png`, and `backroom_summary.png` pass visual QA.

## Phase 4: Customer Role Visuals

Status: mechanically present; hidden during the pre-open slice and paused until Phase 1A is approved.

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
