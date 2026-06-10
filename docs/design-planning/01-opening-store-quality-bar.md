# Opening Store Quality Bar

This is the active implementation plan for making the first playable store and backroom the quality target for the rest of the game.

## Premise

The core loop is mechanically validated. The next milestone should not be another large system. It should make the first store feel like an intentional specialty game shop.

The player should be able to start a new game, look around, receive stock, price a used game, stock a shelf, ring up a customer, step into the backroom, and understand the shop without reading design docs.

## Outcome

When this plan is complete:

- The opening store is no longer "a box with mechanics."
- The first five minutes establish the game's tone, scale, store identity, and retail loop.
- The backroom and stockroom are physically understandable.
- The fictional catalog has enough identity to support a later full content pass.
- Future titles, consoles, decorations, suppliers, and multi-day tuning have a concrete visual/content bar to match.

## Non-Negotiables

- Keep the game playable after every slice.
- Run `scripts/validate_godot.sh` before calling any slice done.
- Do not introduce real-world brands, product names, console names, logos, or trade dress.
- Do not add new economy systems during this phase.
- Do not expand multi-day balance until the first-store quality bar passes.
- Do not hide prompts, shelf slots, products, customer paths, or modal UI behind new detail.
- Keep hidden-thread content optional and secondary.
- Keep one register interaction target.
- Preserve center-reticle/click-first interaction.

## Quality Bar Definition

The quality bar passes when all of these are true:

- Spawn view immediately reads as a small specialty game shop.
- Storefront, sales floor, register, receiving, stockroom, backroom office, and service/records corners are visually distinct.
- Sales floor density feels intentional and stocked without blocking movement.
- Register counter physically supports sale, return, trade-in, preorder, and service workflows.
- Receiving and backstock read as physical stock movement.
- Backroom computer reads as an owner workstation.
- Product/platform/decor language is coherent and fictional.
- The 23 validation screenshots pass `docs/qa/screenshot-review.md`.
- `docs/design-planning/08-quality-bar-checklist.md` passes.
- `scripts/validate_godot.sh` passes.
- No open P0/P1 quality-bar issue remains in `docs/production/13-alpha-bug-list.md`.

## Current Baseline

Current strengths:

- Broad first-person retail loop already works.
- The project has scene tests, screenshot generation, catalog checks, pack smoke, and performance smoke.
- The store has early production-blockout signs, props, products, customers, backroom zones, and fixture ghosts.

Current weaknesses:

- Opening view still risks reading as a primitive blockout.
- Product density is not yet the primary store read.
- The current store identity depends too much on labels.
- Backroom computer can still read as a dense panel instead of an owner workstation.
- Fictional platforms/catalogs are not yet strong enough to carry long-form play.

## Implementation Slices

### Slice 0: Source Lock And Baseline

Type: checklist/setup slice.

Purpose:

Lock the inputs and evidence before scene changes.

Implement:

- Confirm `docs/design-planning/00-inspiration-review.md` covers every image in `inspiration/`.
- Run `scripts/validate_godot.sh`.
- Generate or refresh `artifacts/design-planning/inspiration-contact-sheet.png` if references change.
- Generate a validation screenshot contact sheet from `artifacts/validation/latest/screenshots/`.
- Review all 23 screenshots against `docs/design-planning/08-quality-bar-checklist.md`.
- Add or update bug-list entries for every P0/P1 quality-bar failure.

Primary files:

- `docs/design-planning/00-inspiration-review.md`
- `docs/design-planning/08-quality-bar-checklist.md`
- `docs/production/13-alpha-bug-list.md`
- `artifacts/validation/latest/screenshots/`

Acceptance:

- Baseline screenshots exist.
- Failing quality-bar screenshots are named.
- No scene changes are bundled into this slice.

Validation:

- `scripts/validate_godot.sh`
- Manual screenshot review.

Stop condition:

- Stop and review if bug-list scope grows beyond opening store/backroom quality.

### Slice 1: Storefront And Spawn Composition

Type: implementation slice.

Purpose:

Make the first view sell the shop before the player moves.

Inspiration:

- `IMG_1033.PNG`, `IMG_1034.PNG`, `IMG_1035.PNG`, `IMG_1037.PNG`, `IMG_1038.PNG`, `IMG_1054.PNG`, `IMG_1055.PNG`.

Implement:

- Recompose spawn so store identity, register, shelf wall, and backroom hint are visible.
- Reduce empty ceiling/floor/wall dominance.
- Add or refine sign band, glass, door frame, open-hours decal, trade/service decal, and window display shelf.
- Add trim and facade segmentation so the front is not one flat plane.
- Add display products behind glass without making them interactable.
- Ensure first view still leaves the reticle and prompt area clean.

Primary files likely affected:

- `game/scenes/world/graybox_store.tscn`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/tools/capture_main_scene_screenshot.gd`
- `game/tests/validation/scenarios/screenshots.json`
- `docs/qa/screenshot-review.md`

Acceptance screenshots:

- `main_scene.png`
- `storefront_entry.png`

Acceptance checks:

- Store name or brand silhouette is readable.
- Player understands this is a game shop without docs.
- Entry threshold is visible.
- No prop implies an unsupported exit interaction.
- Spawn composition does not hide shelf/register/backroom route.

Implemented evidence:

- Added facade piers, center door frames, and an interior threshold strip so the front wall reads as a framed shop entrance.
- Added entry route stripes that split toward register and shelf zones from the spawn/threshold area.
- Added a backroom hint panel visible through the first-store composition to communicate office/stock beyond the sales floor.
- Added a window platform stack and expanded storefront scene tests to lock first-view landmarks.

Validation:

- Focused scene tests if added.
- `scripts/validate_godot.sh`.
- Manual 1280x720 screenshot review.

Stop condition:

- Stop if spawn requires moving customer/register/receiving flows enough to risk core-loop behavior.

### Slice 2: Finished Shell And Material Pass

Type: implementation slice.

Purpose:

Make the room feel finished before adding more product density.

Inspiration:

- `IMG_1036.PNG`, `IMG_1048.PNG`, `IMG_1049.PNG`, `IMG_1050.PNG`, `IMG_1053.PNG`.

Implement:

- Add baseboards, wall trim, corner trim, ceiling panels, floor transition strips, counter trim, and door casing.
- Establish warm sales floor and cooler stockroom/backroom material contrast.
- Add clear material separation for glass, painted wall, laminate/counter, cardboard, metal shelf, paper sign, and rubber mat.
- Avoid one-color or one-material screen dominance.

Primary files likely affected:

- `game/scenes/world/graybox_store.tscn`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/validation/scenarios/store_visual_polish.json`

Acceptance screenshots:

- `main_scene.png`
- `storefront_entry.png`
- `receiving_area.png`
- `backroom_summary.png`

Acceptance checks:

- Screens no longer read as raw room planes.
- Wall/floor/counter/trim materials are distinguishable.
- Prompt and UI contrast remains strong.
- Navigation clearance remains unchanged.

Implemented evidence:

- Added sales-floor chair rails, back-corner trim, ceiling grid strips, and low-profile rubber mats at entry/register.
- Kept all finish props non-colliding and bounded inside the existing floorprint.
- Expanded scene tests to assert trim/material cues, ceiling finish height, mat thinness, and material contrast.

Validation:

- Scene/material tests.
- `scripts/validate_godot.sh`.

Stop condition:

- Stop if material/lighting changes reduce text, prompt, or product-label contrast.

### Slice 3: Sales Floor Product Density

Type: implementation slice.

Purpose:

Make the sales floor feel like a stocked shop while preserving pathing and interactions.

Inspiration:

- `IMG_1064.PNG`, `IMG_1068.PNG`, `IMG_1071.PNG`, `IMG_1074.PNG`.

Implement:

- Add used-game spine repetition to shelves/racks.
- Add new-release/preorder wall read.
- Add accessory peg wall read.
- Add bargain/impulse zone.
- Add category signs and shelf talkers with short fictional copy.
- Add route cues from entry to shelf, shelf to register, receiving to shelf, and store to backroom.
- Distinguish interactive products from noninteractive visual fill.

Primary files likely affected:

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/props/placeholder_shelf.tscn`
- `game/scripts/store_layout/shelf_slot.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_shelf_slot.gd`

Acceptance screenshots:

- `main_scene.png`
- `stocked_aisle.png`
- `customer_queue.png`
- `fixture_placed.png`

Acceptance checks:

- At least four store zones are visually readable.
- Stocked shelves do not block shelf slots.
- Customer queue remains readable.
- Player can identify where to stock used games.
- Density comes from products and fixtures, not huge signs.

Implemented evidence:

- Added repeated used-game spine rows and a small shelf talker to make the stocked used wall read as product density.
- Added a preorder wall with header and case-stack cues on the right wall, separate from the interactive register flow.
- Expanded sales-floor tests to lock the used shelf, preorder wall, endcap, staff picks, accessory, bargain, and route-cue composition.

Validation:

- Shelf and scene tests.
- Customer path/queue tests.
- `scripts/validate_godot.sh`.

Stop condition:

- Stop if customer movement or click targets become ambiguous.

### Slice 4: Register Command Center

Type: implementation slice.

Purpose:

Make every first-store transaction physically understandable at the counter.

Inspiration:

- `IMG_1039.PNG`, `IMG_1060.PNG`, `IMG_1061.PNG`, `IMG_1062.PNG`, `IMG_1067.PNG`, `IMG_1072.PNG`, `IMG_1073.PNG`.

Implement:

- Add owner-side scanner, card reader, receipt printer, payment display, cash drawer, and counter mat.
- Add customer-side mat, bag/sleeve stack, impulse product cue, and clear approach point.
- Add return tray, trade-in inspection pad, preorder slip stack, and service pickup marker.
- Keep one register interaction target.
- Align UI states with physical props: sale, return, trade-in, preorder, service.

Primary files likely affected:

- `game/scenes/props/register_workstation.tscn`
- `game/scripts/store_layout/register_workstation.gd`
- `game/scenes/ui/register_checkout_panel.tscn`
- `game/scripts/ui/register_checkout_panel.gd`
- `game/scenes/ui/trade_in_offer_panel.tscn`
- `game/tests/gut/test_register_checkout_panel.gd`
- `game/tests/gut/test_register_checkout_ui.gd`
- `game/tests/gut/test_trade_in_offer_panel.gd`

Acceptance screenshots:

- `register_counter.png`
- `trade_in_offer.png`
- `preorder_deposit.png`
- `service_request.png`

Acceptance checks:

- Register reads as a working command center before UI opens.
- Sale/return/trade/preorder/service each have a physical counter cue.
- UI decision values are visible before confirm.
- Props do not create fake interactions.

Implemented evidence:

- Added a sale scan pad, labeled sleeve/bag stack, and customer approach marker to complete the owner/customer-side read.
- Added a compact register mode cue rail for sale, return, trade, preorder, and service so the physical counter matches supported workflows.
- Expanded register scene tests to assert the new cues are non-colliding, near the single register interaction target, and label-aligned.

Validation:

- Register, return, trade-in, service, and preorder tests.
- `scripts/validate_godot.sh`.

Stop condition:

- Stop if register target ownership becomes unclear.

### Slice 5: Receiving And Stockroom Workflow

Type: implementation slice.

Purpose:

Make stock arrival and storage feel physical and legible.

Inspiration:

- `IMG_1040.PNG`, `IMG_1063.PNG`, `IMG_1064.PNG`, `IMG_1070.PNG`.

Implement:

- Build receiving station with delivery point, box state, invoice surface, sort tray, and status cards.
- Build backstock shelves with category lanes and capacity/overflow read.
- Add a pull stage between backstock and sales floor.
- Improve route from receiving to shelf and backstock.
- Ensure supplier delivery screenshot shows workflow state.

Primary files likely affected:

- `game/scenes/world/graybox_store.tscn`
- `game/scripts/systems/store_session.gd`
- `game/scripts/ui/day_summary_panel.gd`
- `game/tests/gut/test_store_session.gd`
- `game/tests/gut/test_day_summary_panel.gd`
- `game/tests/gut/test_graybox_store.gd`

Acceptance screenshots:

- `receiving_area.png`
- `supplier_delivery.png`
- `carry_stack.png`

Acceptance checks:

- Receiving does not look like floor clutter.
- Supplier delivery does not imply instant inventory.
- Backstock categories are visible.
- Store/Pull workflow is physically grounded.
- Carry path remains clear.

Implemented evidence:

- Added receiving workflow cards for delivery, check, and sort states beside the intake surface.
- Added low floor arrows linking receiving to pull staging and backstock toward shelf-restock flow.
- Expanded receiving/backstock tests to lock the workflow cards, carry arrows, pull stage, and non-colliding stockroom route.

Validation:

- Store session, day summary, scene tests.
- `scripts/validate_godot.sh`.

Stop condition:

- Stop if receiving/backstock visuals imply mechanics that are not supported.

### Slice 6: Backroom Office And Computer Read

Type: implementation slice.

Purpose:

Make the backroom computer feel like an owner workstation and make management screens easier to scan.

Inspiration:

- `IMG_1040.PNG`, `IMG_1041.PNG`, `IMG_1042.PNG`, `IMG_1070.PNG`.

Implement:

- Add desk, chair, planning board, bills, calendar, supplier paperwork, records shelf, and task lighting.
- Improve computer framing so the backroom office is visible behind/around the UI.
- Reduce dense text where card or tab summaries are possible.
- Keep dashboard, inventory, ordering, releases, reports, services, storage, settings, suppliers, and records visibly distinct.
- Keep hidden-thread records and safe/security text optional and secondary.

Primary files likely affected:

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/props/backroom_computer.tscn`
- `game/scenes/ui/day_summary_panel.tscn`
- `game/scripts/ui/day_summary_panel.gd`
- `game/tests/gut/test_day_summary_panel.gd`
- `game/tests/gut/test_graybox_store.gd`

Acceptance screenshots:

- `backroom_summary.png`
- `catalog_design_cues.png`
- `upgrade_preview.png`
- `release_calendar.png`
- `release_allocation.png`
- `launch_day.png`
- `supplier_message.png`
- `suspicious_customer.png`

Acceptance checks:

- Backroom computer reads as management, not debug.
- Primary tab purpose is clear within one glance.
- Main controls are visible at 1280x720.
- Hidden-thread content does not look required.

Validation:

- Day summary, store session, hidden-thread, scene tests.
- `scripts/validate_godot.sh`.

Stop condition:

- Stop if UI refactor risks changing accounting/session behavior.

### Slice 7: Catalog Language Foundation

Type: content/design slice with light implementation.

Purpose:

Prepare the full catalog pass by locking fictional platforms, title rules, supplier identity, and product taxonomy.

Inspiration:

- `IMG_1041.PNG`, `IMG_1042.PNG`, `IMG_1065.PNG`, `IMG_1066.PNG`, `IMG_1067.PNG`, `IMG_1069.PNG`, `IMG_1070.PNG`.

Implement:

- Define platform families.
- Define title naming rules.
- Define category, format, condition, completeness, authenticity/risk, rarity, and demand taxonomy.
- Define supplier identities.
- Define decor and upgrade naming style.
- Perform a starter product copy pass where needed, without trying to build the full final catalog yet.

Primary files likely affected:

- `docs/design-planning/06-catalog-and-platform-identity-plan.md`
- `game/data/products/*.tres`
- `game/data/releases/*.tres`
- `game/data/suppliers/*.tres`
- `scripts/check_product_catalog.py`
- `game/tests/gut/test_product_catalog.gd`

Acceptance checks:

- Product names feel fictional and coherent.
- Platform names fit together.
- Starter products support the shop identity.
- No real IP leakage.
- Tags, receipts, pricing, trade-in, supplier, and release UI remain readable.

Validation:

- `python3 scripts/check_product_catalog.py`
- Product catalog GUT tests.
- `scripts/validate_godot.sh`.

Stop condition:

- Stop if content scope grows into full catalog before the opening store quality bar passes.

### Slice 8: Screenshot Review And Lock

Type: checklist/review slice.

Purpose:

Approve or reject the quality bar before moving to full catalog/decor/platform work.

Implement:

- Run `scripts/validate_godot.sh`.
- Generate a fresh screenshot contact sheet.
- Review all 23 screenshots using:
  - `docs/qa/screenshot-review.md`
  - `docs/design-planning/08-quality-bar-checklist.md`
- Update `docs/production/13-alpha-bug-list.md`.
- Update `docs/status.json` if the phase moves forward.

Acceptance:

- Full gate passes.
- All required screenshots pass.
- P0/P1 quality-bar issues are closed.
- A clear next-phase decision exists: full catalog/platform/decor implementation or targeted rework.

Stop condition:

- Stop if any owner screenshot review rejects the opening store/backroom read.

## Screenshot Evidence Map

- Storefront/spawn: `main_scene.png`, `storefront_entry.png`
- Sales floor/density: `stocked_aisle.png`, `customer_queue.png`, `fixture_placed.png`
- Product handling: `carry_stack.png`, `receiving_area.png`
- Register: `register_counter.png`, `trade_in_offer.png`, `preorder_deposit.png`, `service_request.png`
- Backroom: `backroom_summary.png`, `catalog_design_cues.png`, `upgrade_preview.png`
- Release/management: `release_calendar.png`, `release_allocation.png`, `launch_day.png`
- Stockroom/delivery: `supplier_delivery.png`
- Hidden-thread optionality: `supplier_message.png`, `suspicious_customer.png`
- Fixture/build mode: `fixture_ghost.png`, `fixture_invalid_ghost.png`, `fixture_rotated_ghost.png`

## Required Test Stack

Minimum per implementation slice:

```text
scripts/validate_godot.sh
```

Useful focused checks before the full gate:

```text
python3 scripts/check_validation_coverage.py
python3 scripts/check_product_catalog.py
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit
```

## Documentation Updates Per Slice

Update only the docs that changed meaning:

- `docs/design-planning/01-opening-store-quality-bar.md` when slice status or sequence changes.
- `docs/design-planning/08-quality-bar-checklist.md` when acceptance changes.
- `docs/qa/screenshot-review.md` when screenshot criteria or filenames change.
- `docs/production/13-alpha-bug-list.md` when a screenshot fails or a blocker closes.
- `docs/status.json` only when phase state changes.

## Exit Decision

After Slice 8, choose one path:

1. If quality bar passes: start full catalog/platform/decor implementation and then multi-day playtesting.
2. If quality bar fails: implement only the failed slice surfaces and repeat Slice 8.

Do not start full catalog/decor/platform depth while the opening store still fails the quality bar.
