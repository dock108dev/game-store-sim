# Implementation Roadmap

## Strategy

Do not replace the whole store at once.

Build one final-quality visual slice, review it, then propagate its asset/style language through the store.

## Phase 0: Visual Reset Planning

Status: ready for owner review.

Deliverables:

- This visual-production folder.
- Updated current-state/status language.
- Deprecated visual-doc list.
- Mid-00s game shop inventory checklist.

Exit criteria:

- Owner approves or revises the era, store type, style, clutter level, and first visual slice.
- Owner approves or revises the day-one stock rule: 2 new games, 1 console, 1 accessory, trade-ins as early growth, future products visible through catalogs/planning surfaces, and physical stock arriving only after purchase/order/unlock.

## Phase 1: Target Slice Prototype

Recommended scope:

- Storefront first view.
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
- Screenshots show a restrained newly opening shop, not a fully stocked endpoint.
- Owner approves style before broader replacement.

## Phase 2: Product And Fixture Kit

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

Scope:

- Receiving station.
- Backstock shelves.
- Pull stage.
- Office desk and service bench visual kit.

Exit criteria:

- `receiving_area.png`, `supplier_delivery.png`, and `backroom_summary.png` pass visual QA.

## Phase 4: Customer Role Visuals

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
