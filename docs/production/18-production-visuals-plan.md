# Production Visuals Plan

This is the implementation record for the large production-visuals phase. It supersedes small isolated polish work and turns the `inspiration/` folder into an ordered implementation sequence. The goal is not "make it pretty" in one pass. The goal is to replace the remaining graybox read with a believable specialty game store while preserving the already validated retail loop.

External alpha playtest remains paused until the owner recovery screenshot set, stockroom screenshot set, and this visual-overhaul review set are readable in a real `1280x720` window.

## Current State

The game is mechanically broad but still visually underdeveloped:

- The first-person loop works: receiving, pricing, stocking, checkout, trade-ins, preorders, services, supplier ordering, storage, fixture placement, release planning, save/load, and reports.
- The readability recovery and stockroom phases improved composition, UI legibility, backroom zoning, and physical stock handling.
- The store now has a mechanically complete production-blockout visual baseline for storefront identity, finished-room cues, product density, register transaction surfaces, backroom/catalog context, build-mode language, lighting/signage, and upgrade/decor visibility.
- The visual language is still primitive-prop based rather than final bespoke art, but the remaining work is now human screenshot approval and later art replacement, not missing slice coverage.
- External alpha playtest remains paused until the owner confirms the recovery, stockroom, and production-visual screenshot sets in a real 1280x720 window.

## Implementation Status

Completed baseline: Slice 0 through Slice 14 are mechanically implemented and validated.

Validation snapshot:

- `scripts/validate_godot.sh` passes with 552 GUT tests.
- UI scenario automation coverage is 504/624.
- Production script mapping coverage is 52/52.
- Product catalog validation passes with 33 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot sanity, and old-name scan pass.

Implemented scene surfaces:

- Storefront and brand: sign trim, window console/case display, poster card, trade/service decal, and the preexisting `SAVE POINT GAMES`, open-hours, glass, and entry cues.
- Architecture and materials: sales-floor baseboards, ceiling panels, floor transition strip, counter trim, warm/cool material contrast, stockroom material variation, and existing wall/detail panels.
- Sales floor and product density: new shelf density band, shelf price tags, existing used/new/staff-pick/accessory/locked-case/bargain-bin/impulse fixture cues, and path-preserving route mats.
- Register command center: return review tray, trade-in inspection tray, preorder slip stack, service pickup marker, cash drawer slot, payment status glow, scanner, card reader, receipt printer, sleeves, impulse rack, and customer-side mat.
- Catalog/design/build/customization: backroom catalog cards, cart summary panel, design swatches, ghost footprint outline, valid-footprint instruction panel, wall/floor material samples, upgrade preview card, and expansion footprint tape.
- Backroom and secondary spaces: receiving, backstock, manager-office, service, safe, security, records, hold-tray, and storage flow surfaces remain covered by the stockroom production baseline.
- Lighting/effects/readability: warm sales/register lights, cooler backroom/task lights, bounded accent lights, nonblocking glow panels, depth-safe labels, and navigation-clearance coverage.

Automated coverage added in this pass:

- `test_production_visual_overhaul_storefront_and_architecture_cues_exist`
- `test_production_visual_overhaul_product_density_and_transaction_surfaces_exist`
- `test_production_visual_overhaul_catalog_build_and_upgrade_cues_exist`
- `store_visual_polish.json` entries for the same three visual-overhaul surfaces.

Human review still required:

- Inspect the generated screenshot set under `artifacts/validation/latest/screenshots/`.
- Approve `main_scene.png`, `customer_queue.png`, `register_counter.png`, `receiving_area.png`, `backroom_summary.png`, `fixture_ghost.png`, `fixture_invalid_ghost.png`, `fixture_rotated_ghost.png`, and `fixture_placed.png` against this plan.
- Keep `15-alpha-playtest-package.md` paused if any screenshot still reads as graybox, label clutter, blocked product path, unreadable signage, or UI squeeze.

## Inspiration Audit

Source folder: `inspiration/IMG_1033.PNG` through `inspiration/IMG_1074.PNG`.

Ignore in all references:

- Stream chat, facecams, video controls, creator watermarks, sponsor panels, and platform chrome.
- Exact real-world names, logos, trade dress, branded product packaging, and any third-party IP.
- UI scale caused by video compression rather than game design.

Use from the references:

- Storefront identity, glass, sign silhouette, sidewalk approach, and first-impression composition.
- Small-shop fixture density, shelves, counters, aisle spacing, and customer circulation.
- Build/design tools with obvious ghost previews, material swatches, and valid/invalid placement color.
- Supplier/catalog UI grouped by category with item cards, prices, locked entries, and purchase buttons.
- Register/payment/pricing UI where profit, market price, cash, and decision buttons are visible at the point of action.
- Product handling details: cards/cases in hand, shelves loaded with repeated small products, price tags, and value readouts.
- Backroom/office/service context: computer desk, task board, storage boxes, repair/service equipment, and paperwork.

### Reference Groups

Storefront and exterior identity:

- `IMG_1033.PNG`, `IMG_1034.PNG`, `IMG_1035.PNG`: sidewalk approach, glass storefront, strip-mall scale, readable shop frontage.
- `IMG_1037.PNG`, `IMG_1038.PNG`, `IMG_1054.PNG`: sign silhouette, facade color, window framing, door position, local-shop identity.
- `IMG_1055.PNG`: main-menu/title composition with storefront as the brand signal.

Empty shell, layout, and early setup:

- `IMG_1036.PNG`: empty interior shell before identity is installed.
- `IMG_1043.PNG`, `IMG_1044.PNG`, `IMG_1045.PNG`: fixture placement ghost, floor warnings, move tool framing, and sparse starter layout.
- `IMG_1056.PNG`, `IMG_1058.PNG`, `IMG_1059.PNG`: empty shop with tutorial, early fixture purchase, ghost preview, and stockable wall/shelf space.

Catalog, supplier, and design UI:

- `IMG_1041.PNG`, `IMG_1042.PNG`: catalogue notebook with grouped categories and locked future equipment.
- `IMG_1046.PNG`, `IMG_1047.PNG`, `IMG_1048.PNG`, `IMG_1049.PNG`, `IMG_1050.PNG`, `IMG_1051.PNG`, `IMG_1052.PNG`: design tool, material list, wall/floor color choice, preview framing, and storefront sign color/style controls.
- `IMG_1058.PNG`, `IMG_1070.PNG`: item-card supplier UI and shopping-cart style purchase review.

Register, pricing, payment, and transaction UI:

- `IMG_1060.PNG`, `IMG_1061.PNG`: shelf-stocked goods and set-item-price modal with unit cost, sale price, market price, and profit.
- `IMG_1062.PNG`: register/payment terminal with charged amount and cash/change style readout.
- `IMG_1063.PNG`, `IMG_1064.PNG`: boxes, stock handling, and dense shelves connected to transaction flow.
- `IMG_1067.PNG`: offer/accept/decline/think transaction choices around a valuable item.

Retail density, shelves, and customer traffic:

- `IMG_1064.PNG`, `IMG_1068.PNG`, `IMG_1071.PNG`, `IMG_1074.PNG`: stocked shelves, aisles, shoppers, counter lines, wall displays, and readable product density.
- `IMG_1072.PNG`, `IMG_1073.PNG`: close product handling, scanner/cash terminal, wall shelf, and customer-side counter context.

Product inspection and value presentation:

- `IMG_1065.PNG`, `IMG_1066.PNG`, `IMG_1067.PNG`: item presentation with rarity/value, market comparison, total value, and offer decision.
- `IMG_1068.PNG`, `IMG_1069.PNG`: small products/cards laid out in the world and close-up collection/value view.

## Visual Direction

Target style: stylized retail realism.

Rules:

- Keep silhouettes readable before adding detail.
- Use simplified geometry with bevels, trim, labels, material contrast, and functional clutter.
- Keep all brands fictional: `SAVE POINT GAMES` remains the store name unless a deliberate branding slice renames it.
- Use warm retail lighting on the sales floor and cooler practical light in stockroom/service/office areas.
- Add density in layers: architecture, fixtures, products, signage, clutter, customers, then effects.
- Do not let detail hide prompts, shelf slots, held items, customer paths, or modal text.

## Slice Plan

Every slice must keep the game shippable, update manual validation if player-visible behavior or visuals change, and run `scripts/validate_godot.sh` before commit.

### Slice 0: Visual Source Lock And Screenshot Baseline

Goal: make the visual-overhaul phase measurable before touching scene art.

Inspiration:

- Whole folder, especially the contrast between empty shop setup (`IMG_1036.PNG`, `IMG_1056.PNG`) and stocked retail density (`IMG_1064.PNG`, `IMG_1074.PNG`).

Implementation:

- Add this plan to the README/doc map/backlog.
- Capture a current screenshot baseline from `scripts/validate_godot.sh`.
- Add a visual-overhaul review checklist to `07-current-manual-playtest.md`.
- Decide which current screenshot names are the required before/after proof set.

Acceptance:

- Plan is linked from README and backlog.
- Required screenshots are named before implementation starts.
- No scene changes yet.

### Slice 1: Storefront And Brand First Impression

Goal: make the exterior and first viewport read as a real small game shop.

Inspiration:

- `IMG_1033.PNG`, `IMG_1035.PNG`, `IMG_1038.PNG`, `IMG_1054.PNG`, `IMG_1055.PNG`.

Implementation:

- Rebuild front facade proportions: glass panels, door frame, sign band, trim, sidewalk-facing detail.
- Improve `SAVE POINT GAMES` sign silhouette and lighting without copying any reference logo.
- Add believable window display hints: console boxes, poster cards, open-hours decal, trade-in/service decals.
- Frame player spawn so store name, counter, sales wall, and backroom hint are visible without ceiling dominance.

Acceptance:

- `main_scene.png` reads as a shop before the player moves.
- Storefront sign is readable and not cropped.
- Window dressing adds identity without becoming interactable clutter.

### Slice 2: Interior Architecture, Palette, And Materials

Goal: replace the raw room read with a finished retail interior.

Inspiration:

- `IMG_1036.PNG`, `IMG_1048.PNG`, `IMG_1049.PNG`, `IMG_1050.PNG`, `IMG_1051.PNG`, `IMG_1052.PNG`, `IMG_1053.PNG`.

Implementation:

- Add wall baseboards, corner trim, ceiling panels, floor transition strips, counter trim, and door casing.
- Establish sales-floor palette: warm wall base, durable floor, dark counter, wood/laminate accents, teal/yellow brand highlights.
- Establish stockroom palette: cooler walls, concrete floor, metal shelving, cardboard/paper tones.
- Add material variants used by future slices: painted wall, glass, plastic case, laminate, cardboard, metal shelf, paper sign, rubber mat.

Acceptance:

- `main_scene.png`, `receiving_area.png`, and `backroom_summary.png` show distinct room materials.
- The whole screen is not dominated by one hue family.
- Prompt, reticle, labels, and UI remain high contrast.

### Slice 3: Sales Floor Layout And Fixture Density

Goal: make the sales floor feel like a small shop with planned merchandising, not a test room.

Inspiration:

- `IMG_1044.PNG`, `IMG_1045.PNG`, `IMG_1064.PNG`, `IMG_1068.PNG`, `IMG_1071.PNG`, `IMG_1074.PNG`.

Implementation:

- Add a fixture layout pass with wall shelving, used-game rack, new-release/preorder wall, accessory peg wall, bargain/bin area, and impulse/counter rack.
- Keep aisles and register queue readable.
- Add inactive preview fixtures where mechanics are not fully implemented yet, but label them as future categories without promising unsupported interaction.
- Use shelf silhouettes and repeated slots to imply inventory density.

Acceptance:

- `customer_queue.png` and `main_scene.png` show a readable path through the shop.
- At least four retail category zones are visible: used games, new releases/preorders, accessories, services/trade-ins.
- Fixtures do not block customer paths or current interactions.

### Slice 4: Register Command Center Rebuild

Goal: make the register counter visually carry sales, returns, trade-ins, preorders, and service pickup.

Inspiration:

- `IMG_1039.PNG`, `IMG_1062.PNG`, `IMG_1072.PNG`, `IMG_1073.PNG`, `IMG_1074.PNG`.

Implementation:

- Add distinct owner/customer sides to the counter.
- Add scanner, card reader, cash drawer hint, receipt printer, bag/sleeve stack, counter mat, return/trade-in tray, preorder slips, and small service pickup marker.
- Keep the current register workstation as the only register interaction target.
- Make the return review baseline visible as a tray/clipboard/review surface.

Acceptance:

- `register_counter.png` reads as a command center, not a block with a monitor.
- The register prompt remains easy to target.
- Sales, return, trade-in, preorder, and service roles make visual sense at the same counter.

### Slice 5: Product Visual Production Pass

Goal: make products read as desirable game-store inventory at hand, shelf, receiving, and customer scale.

Inspiration:

- `IMG_1060.PNG`, `IMG_1063.PNG`, `IMG_1064.PNG`, `IMG_1065.PNG`, `IMG_1066.PNG`, `IMG_1068.PNG`, `IMG_1069.PNG`.

Implementation:

- Upgrade used-game cases with stronger cover blocks, spine bands, platform color strips, back-cover hints, price stickers, condition wear, and rarity/authenticity cues.
- Add visual families for cartridge, loose disc, accessory, hardware box, service ticket, and card-sized product references.
- Keep product identity data-driven through current product visual rules.
- Add shelf-facing repetition without making every item a unique hand-built scene.

Acceptance:

- `carry_stack.png`, `receiving_area.png`, and shelf screenshots show products as inventory, not colored blocks.
- Price tags remain readable but do not replace the interaction prompt.
- Condition/risk cues are visible only at appropriate proximity.

### Slice 6: Signage, Wayfinding, And Retail Graphics

Goal: make signage useful and physical, not oversized validation labels.

Inspiration:

- `IMG_1038.PNG`, `IMG_1054.PNG`, `IMG_1052.PNG`, `IMG_1064.PNG`, `IMG_1071.PNG`.

Implementation:

- Rework category signs: Used Games, New Releases, Trade-Ins, Services, Preorders, Accessories, Staff Picks, Bargain Bin.
- Add price/deal cards, small shelf talkers, store-policy cards, and open-hours/storefront decals.
- Add register-side service/return/trade-in cards.
- Keep signs short and fictional.

Acceptance:

- Signs are readable from normal angles and do not clip at oblique views.
- Category labels clarify where to stock/browse without turning into UI.
- No sign hides a product, prompt, reticle, or customer face/role cue.

### Slice 7: Customer Visual Kit And Crowd Readability

Goal: make customers feel like store visitors before prompt text appears.

Inspiration:

- `IMG_1034.PNG`, `IMG_1068.PNG`, `IMG_1071.PNG`, `IMG_1074.PNG`.

Implementation:

- Add body-shape, clothing, prop, and posture variants for buyer, trade-in seller, preorder/customer-service, return customer, service customer, regular/browser, and suspicious contact.
- Improve queue poses and counter-facing stance.
- Add compact customer intent props: basket, trade case, return bag, preorder slip, repair disc/ticket, suspicious note/cash.
- Keep labels as support, not the primary identity read.

Acceptance:

- `customer_queue.png` distinguishes roles without reading only floating labels.
- Special customers stay out of the buyer queue lane.
- Props stay below head/face level and do not become visual blockers.

### Slice 8: Backroom, Office, Service, And Stockroom Dressing

Goal: make operations spaces look practical enough to support the current systems.

Inspiration:

- `IMG_1040.PNG`, `IMG_1053.PNG`, `IMG_1070.PNG`, plus the office/backroom principles already captured in `17-stockroom-production-plan.md`.

Implementation:

- Upgrade receiving station: pallet/roll-up hint, open boxes, packing slips, tape, sorted trays, damaged box variant, intake tags.
- Upgrade backstock: labeled shelves, bins, overflow, pull-stage surface, service-parts shelf.
- Upgrade manager office: desk, chair, task board, receipt/bill stacks, supplier folder, small computer context.
- Upgrade service/security: repair mat/tools, parts bins, safe, records binder, camera monitor, hold tray.

Acceptance:

- `receiving_area.png`, `supplier_delivery.png`, and stockroom screenshot set read as employees-only operations.
- Backroom computer feels physically located in an office, not floating in the room.
- Suspicious props remain optional anomalies, not quest markers.

### Slice 9: Build Mode And Fixture Placement Visual Language

Goal: make placement feel like a production building mode with clear feedback.

Inspiration:

- `IMG_1043.PNG`, `IMG_1044.PNG`, `IMG_1045.PNG`, `IMG_1057.PNG`, `IMG_1059.PNG`.

Implementation:

- Improve ghost materials for valid, invalid, rotated, and snap states.
- Add footprint outline, clearance/path warnings, and anchor markers.
- Make placed fixtures visually distinct from ghosts.
- Add small in-world placement helpers only when placement mode is active.

Acceptance:

- `fixture_ghost.png`, `fixture_invalid_ghost.png`, `fixture_rotated_ghost.png`, and `fixture_placed.png` are visually distinct.
- Valid/invalid states are readable under final lighting.
- Placement UI still fits the backroom computer panel.

### Slice 10: Computer, Catalog, And Management UI Visual Pass

Goal: make repeated management screens feel like an in-world shop system, not debug text.

Inspiration:

- `IMG_1041.PNG`, `IMG_1042.PNG`, `IMG_1058.PNG`, `IMG_1070.PNG`.

Implementation:

- Rework computer panel style around a task OS: dashboard, inventory, ordering, releases, reports, services, storage, suppliers, settings, records.
- Use item cards for supplier/fixture/decor purchases with category, cost, due day, availability, and locked state.
- Add cart/order summary affordance for supplier purchases.
- Keep current keyboard/mouse focus and modal capture behavior.

Acceptance:

- Backroom UI is faster to scan and no longer one long dense report surface.
- Cash, cost, due day, inventory count, and consequence are visible at decision points.
- Existing backroom actions remain available and grouped by task.

### Slice 11: Pricing, Register, Trade-In, Return, And Payment UI Pass

Goal: align all transaction UI with the reference decision surfaces.

Inspiration:

- `IMG_1061.PNG`, `IMG_1062.PNG`, `IMG_1065.PNG`, `IMG_1066.PNG`, `IMG_1067.PNG`.

Implementation:

- Pricing panel: emphasize unit cost, market price, sale price, profit, demand, and warning state.
- Register panel: keep receipt lines, total/refund due, tender/change, transaction feedback, and confirmation button hierarchy.
- Trade-in panel: emphasize condition, market value, cash/store-credit offer, projected margin, risk, accept/decline.
- Return review: emphasize item, refund, reason, disposition, receiving-review routing, and reputation implication.

Acceptance:

- Each transaction panel communicates the decision before confirmation.
- Confirm/Close focus remains reliable.
- UI text fits at `1280x720`.

### Slice 12: Lighting, Effects, And Atmosphere

Goal: make the store feel warm, busy, and readable without final art dependency.

Inspiration:

- `IMG_1037.PNG`, `IMG_1053.PNG`, `IMG_1064.PNG`, `IMG_1071.PNG`, `IMG_1074.PNG`.

Implementation:

- Add warmer sales-floor light, cooler stockroom light, register work light, service-bench task light, subtle sign glow, and shelf highlights.
- Add nonintrusive feedback effects for sale/return/service confirmations, invalid placement, stocking, and cash/reputation updates.
- Add ambient visual details: dust motes or subtle screen glow only if they do not reduce clarity.

Acceptance:

- Lighting guides the player to register, rack, receiving, and computer.
- No bloom/glow hides labels or prompts.
- Performance remains inside alpha smoke thresholds.

### Slice 13: Decoration, Customization, And Upgrade Visibility

Goal: make store progression visually visible, not only a stat change.

Inspiration:

- `IMG_1046.PNG` through `IMG_1052.PNG`, `IMG_1058.PNG`.

Implementation:

- Expand decoration surfaces: wall colors, floor materials, sign style/color, posters, lights, counter trim, shelf color.
- Make upgrade states visible: storage bay, signage, computer analytics, service tools, expansion footprint.
- Keep customization fictional and restrained.

Acceptance:

- Applying decor changes the store read without breaking interaction layout.
- Upgrade purchases produce clear physical signs of progress.
- Store still avoids a single-hue visual theme.

### Slice 14: Screenshot Composition And Visual Review Package

Goal: prove the visual overhaul as a set, not just isolated object improvements.

Inspiration:

- Whole folder, especially before/after contrast between sparse and stocked shots.

Implementation:

- Add or retune validation screenshot positions for storefront, spawn, register, stocked aisle, customer queue, return review, receiving, stockroom, manager office, service bench, computer ordering, fixture placement, and decor.
- Update manual playtest with a Production Visuals Focus.
- Update alpha package gating so external playtest remains paused until visual review passes.

Acceptance:

- Required screenshots are useful, nonblank, and composition-specific.
- Human review can judge store identity, category read, counter read, product read, customer read, stockroom read, and UI read.
- Full gate passes after the sync.

## Enhancement Backlog By Surface

Storefront:

- Larger but bounded `SAVE POINT GAMES` sign.
- Glass reflections and window display hints.
- Door decal, open-hours card, trade-in/service decal.
- Exterior color trim tied to future decor state.

Sales floor:

- Used-game wall/rack density.
- New-release/preorder wall.
- Accessory peg wall.
- Bargain bin and staff-pick endcap.
- Counter impulse rack.
- Floor mats and queue lane.

Register:

- Scanner, receipt printer, cash drawer, card reader.
- Return/trade-in intake tray.
- Preorder/service pickup clipboard.
- Customer-side mat/sign.
- Sleeves/bags/counter clutter.

Products:

- Cover/spine/back-label variants.
- Platform strips and category color.
- Condition wear layers.
- Price stickers and rarity tags.
- Risk/authenticity markers.
- Small-product/card-style variant family.

Customers:

- Role clothing color and silhouette.
- Compact props for intent.
- Queue and counter poses.
- Customer-side navigation spacing.
- Reduced dependency on floating labels.

Backroom:

- Delivery/pallet/open-box context.
- Intake table and sorted trays.
- Backstock shelves with labels/bins.
- Pull-stage surface.
- Manager office desk context.
- Service bench and parts shelf.
- Safe/security/records corner.

UI:

- Supplier item cards and cart summary.
- Design/material swatches.
- Register receipt visual hierarchy.
- Trade-in appraisal card.
- Return-review disposition card.
- Pricing decision card.
- Better selected/disabled states.

Lighting/effects:

- Sales-floor warmth.
- Stockroom cool task lighting.
- Register/service/computer pools.
- Subtle sign glow.
- Confirmation and invalid-action effects.

## Validation Requirements

Every implementation slice must update at least one of:

- GUT tests for scene structure, prop bounds, UI state, or data wiring.
- Validation scenario matrix when a new visual/UI scenario is introduced.
- Manual checklist when human readability is required.
- Screenshot capture list when composition changes need proof.

Minimum command before commit:

```text
scripts/validate_godot.sh
```

For visual-heavy slices, also inspect:

- `artifacts/validation/latest/screenshots/main_scene.png`
- `artifacts/validation/latest/screenshots/register_counter.png`
- `artifacts/validation/latest/screenshots/customer_queue.png`
- `artifacts/validation/latest/screenshots/receiving_area.png`
- `artifacts/validation/latest/screenshots/backroom_summary.png`
- `artifacts/validation/latest/screenshots/fixture_placed.png`

## Non-Goals

- No real brands, real product labels, real platform logos, or copied store signage.
- No one-shot art replacement that bypasses slice validation.
- No visual clutter that hides interactables.
- No new mechanic dependency unless the slice explicitly adds and validates it.
- No reopening external alpha playtest from visuals alone; human screenshot review remains required.

## Next Goals

1. Owner screenshot review gate: inspect the recovery, stockroom, and production-visual screenshot sets in a real 1280x720 window and update `13-alpha-bug-list.md` with any remaining P0/P1 readability issues.
2. Real art replacement pass: replace the highest-impact primitive-prop clusters with reusable art assets or procedural scene components, starting with storefront/window display, register counter, shelf density, and product-facing tags.
3. Screenshot composition pass: retune screenshot camera positions only where human review shows the named artifact does not frame its subject clearly enough.
4. External alpha reopen decision: reopen `15-alpha-playtest-package.md` only after the owner screenshot review passes and the full validation gate remains green.
