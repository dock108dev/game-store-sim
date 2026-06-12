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

## Phase 1: Target Slice Prototype

Status: reset implemented; ready for owner screenshot review.

Recommended scope:

- Second-floor mall concourse spawn.
- Branded glass storefront first view.
- Walkable threshold into an empty pre-open store.
- Register counter.
- One adjacent sales-floor shelf/aisle.
- Owned starter-stock staging for the opening setup fantasy.

Deliverables:

- Authored mesh/material kit for this slice.
- First-person screenshots.
- Updated scene tests for required visual anchors.
- QA checklist pass/fail notes.
- Day-one stock/unlock notes.

Exit criteria:

- Screenshots look like an indie game target, not blockout.
- Opening screenshots show the player outside the shop, walking in from a mall concourse.
- Opening screenshots show no visible customers or employees before business begins.
- Screenshots show a restrained newly opening shop, not a fully stocked endpoint.
- Owner approves style before broader replacement.

## Phase 2: Product And Fixture Kit

Status: implemented; ready for owner screenshot review.

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

Status: implemented; ready for owner screenshot review.

Scope:

- Receiving station.
- Backstock shelves.
- Pull stage.
- Office desk and service bench visual kit.

Exit criteria:

- `receiving_area.png`, `supplier_delivery.png`, and `backroom_summary.png` pass visual QA.

## Phase 4: Customer Role Visuals

Status: implemented; ready for owner screenshot review.

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
