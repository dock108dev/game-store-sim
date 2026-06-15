# Inspiration Review

Purpose: convert the `inspiration/` folder into actionable implementation direction for the opening-store quality bar.

Source images: `inspiration/IMG_1033.PNG` through `inspiration/IMG_1074.PNG`.

Generated review aid: `artifacts/design-planning/inspiration-contact-sheet.png`.

## Use And Ignore Rules

Use the references for:

- Storefront composition, sign placement, glass, entry threshold, and first impression.
- Retail fixture density, aisle spacing, product repetition, shelf labels, and customer pathing.
- Register, pricing, payment, trade, service, and product-value presentation.
- Catalog, supplier, design, upgrade, and build-mode UI structure.
- Backroom office, receiving, storage, service, paperwork, and operations read.

Ignore:

- Stream overlays, chat, facecams, creator branding, watermarks, platform chrome, video controls, and compression artifacts.
- Exact real-world brands, product art, store names, console names, logos, or trade dress.
- UI scale caused by streamer layout rather than game usability.
- Reference color palettes when they conflict with the current game's readable warm sales floor / cool stockroom split.

## Target Translation

The references are not asking for a simulator clone. They point to a practical quality bar:

- The shop should read from the first camera frame.
- Products should be repeated, categorized, and value-coded, not scattered.
- Store systems should be physically grounded: stock arrives at receiving, gets stored, moves to shelves, and sells at a counter.
- UI should appear at decision points and show the numbers the player needs before committing.
- Build/design/catalog screens should use cards, swatches, previews, and state badges instead of long text walls.
- The backroom should feel like an owner/operator workspace, not a debug panel room.

## Reference Inventory

### `IMG_1033.PNG`

Observed read:

- Small exterior storefront at sidewalk scale.
- Visible facade rhythm with door, windows, and street approach.
- Human figure gives scale.

Use:

- Storefront threshold proportions.
- Sidewalk or entry-strip cue.
- Door/window framing that makes the shop feel like a place.

Implementation:

- `storefront_entry.png` should include glass, frame, door threshold, and sign context.
- Spawn or entry composition should show store identity before any interaction.

### `IMG_1034.PNG`

Observed read:

- Exterior with customer-scale figure close to the door.
- Storefront frontage is readable before interior detail.

Use:

- Scale reference for doorway and customer height.
- Customer near storefront as a readability test.

Implementation:

- Customer bodies near the register/entry should not dwarf or disappear into fixtures.
- Door and facade props should be scaled against the player and customer rigs.

### `IMG_1035.PNG`

Observed read:

- Sidewalk storefront with repeated window modules.
- Strong exterior approach and retail strip context.

Use:

- Repetition of glass/window panels to avoid one flat wall.
- Storefront rhythm and facade segmentation.

Implementation:

- Add trim and panel divisions instead of one blocky front plane.
- Use open-hours and trade/service decals as noninteractive dressing.

### `IMG_1036.PNG`

Observed read:

- Empty shop shell.
- Wall/floor/ceiling planes dominate until material and trim are added.

Use:

- Negative example for current risk: empty box read.
- Material/trim priority before prop density.

Implementation:

- Opening store quality bar must first reduce empty-plane dominance.
- Add baseboards, ceiling panels, wall trim, transition strips, and color/material contrast.

### `IMG_1037.PNG`

Observed read:

- Strong sign silhouette and storefront identity.
- Facade color and signage create immediate brand read.

Use:

- Sign band shape and readability.
- Brand-first exterior composition.

Implementation:

- `SAVE POINT GAMES` needs a stronger sign band or framed logo surface.
- Sign should not be cropped in `main_scene.png` or `storefront_entry.png`.

### `IMG_1038.PNG`

Observed read:

- Storefront identity with readable sign and glass.
- Entry and facade work together.

Use:

- Balanced sign, windows, door, and wall color.
- Exterior identity without relying on text alone.

Implementation:

- Add window display objects under the sign to make the store category clear even if text is small.

### `IMG_1039.PNG`

Observed read:

- Counter/register surface with payment and product context.
- Warm shop interior with enough props to suggest operation.

Use:

- Register counter as command center.
- Countertop prop clustering.

Implementation:

- Register should visually support sale, return, trade-in, preorder, and service.
- Add scanner, card reader, receipt printer, cash drawer, sleeve stack, return tray, trade pad, preorder slips, and service pickup marker.

### `IMG_1040.PNG`

Observed read:

- Backroom/office desk with computer and shelves.
- Work area has chair, surfaces, and equipment context.

Use:

- Manager office/backroom computer grounding.
- Backroom task composition.

Implementation:

- Backroom computer should sit inside an office/workstation zone with chair, bills, planning board, and supplier paperwork.
- Avoid an isolated monitor in an empty room.

### `IMG_1041.PNG`

Observed read:

- Catalog notebook with category buttons and item cards.
- Locked/available states are obvious.

Use:

- Card-based catalog structure.
- Clear category tabs.

Implementation:

- Supplier lot, fixture, decor, and upgrade UI should move toward card summaries: name, price, locked state, effect, action.

### `IMG_1042.PNG`

Observed read:

- Shelf/furniture catalog with visible locked items and categories.

Use:

- Progression through locked future fixtures.
- Category grouping.

Implementation:

- Fixtures and decor can show future options, but locked entries must be visually distinct and not imply broken interactions.

### `IMG_1043.PNG`

Observed read:

- Move/build tool with colored placement ghost and floor bounds.

Use:

- Valid/invalid build-mode preview language.
- Floor footprint and handle framing.

Implementation:

- `fixture_ghost.png`, `fixture_invalid_ghost.png`, and `fixture_rotated_ghost.png` must have clear color, footprint, and rotation read.

### `IMG_1044.PNG`

Observed read:

- Sparse starter room with fixture placement tool.
- Empty space still has bounds and purposeful setup.

Use:

- Starter store can be sparse if fixture zones and movement controls are clear.

Implementation:

- Opening store may remain small, but every empty area needs a future-purpose cue or material treatment.

### `IMG_1045.PNG`

Observed read:

- Fixture movement with wall/floor context and readable preview.

Use:

- Ghost preview against room materials.
- Boundaries and path clearance.

Implementation:

- Fixture placement should preserve entry, register, shelf, receiving, and backroom routes.

### `IMG_1046.PNG`

Observed read:

- Design tool with material/color options.

Use:

- Swatch-based customization UI.
- Preview framing.

Implementation:

- Decor/upgrade pass should avoid text-only settings lists.
- Use swatches for wall, floor, sign trim, lights, and display props.

### `IMG_1047.PNG`

Observed read:

- Design categories with wall/floor options and preview.

Use:

- Simple visual choices grouped by surface.

Implementation:

- Backroom computer Settings tab should eventually show decoration categories with visual samples and effects.

### `IMG_1048.PNG`

Observed read:

- Material picker and room preview.

Use:

- Immediate feedback for shop customization.

Implementation:

- Decor purchases should have visible world-state changes before they matter economically.

### `IMG_1049.PNG`

Observed read:

- Strong wall color preview against existing trim.

Use:

- Color contrast and material identity.

Implementation:

- Do not let opening store remain one hue family.
- Wall/floor/counter/trim should be distinguishable in screenshots.

### `IMG_1050.PNG`

Observed read:

- More design categories and swatch controls.

Use:

- Catalog UI structure for decorations.

Implementation:

- Use consistent card/swatch language across design, fixture, and supplier catalogs.

### `IMG_1051.PNG`

Observed read:

- Design tool focused on storefront/sign appearance.

Use:

- Store identity customization as a future goal.

Implementation:

- Opening quality bar should lock the base brand direction before exposing sign customization.

### `IMG_1052.PNG`

Observed read:

- Preview-oriented design workflow.

Use:

- Small preview surfaces and purchase/apply state.

Implementation:

- Upgrade/decor screens should show "available", "locked", "applied", and "effect" states.

### `IMG_1053.PNG`

Observed read:

- Interior material and room-scale customization.

Use:

- Finished-room material pass.

Implementation:

- Store shell needs baseboards, trim, ceiling panels, floor strips, and lighting before full catalog expansion.

### `IMG_1054.PNG`

Observed read:

- Storefront sign and exterior identity.

Use:

- Sign silhouette, color blocking, and shop frontage.

Implementation:

- The sign should work as a shape from distance, not only as text.

### `IMG_1055.PNG`

Observed read:

- Main-menu/title composition built around storefront.

Use:

- Brand signal as first-viewport feature.

Implementation:

- Future title/menu work should use the finished storefront, not a separate abstract screen.

### `IMG_1056.PNG`

Observed read:

- Empty starter shop with tutorial/system prompt.

Use:

- The danger of large empty surfaces.
- Starter fixture purchase/setup readability.

Implementation:

- Any tutorial/onboarding prompt must not be compensating for unreadable space.
- The store should visually explain what to do first.

### `IMG_1057.PNG`

Observed read:

- Early shop setup with sparse furniture and floor/wall context.

Use:

- Sparse but purposeful starter footprint.

Implementation:

- Opening store should have enough density to feel intentional while leaving room for fixture growth.

### `IMG_1058.PNG`

Observed read:

- Early fixture/supplier purchase or setup view.

Use:

- Item-card purchasing and starter inventory setup.

Implementation:

- First supplier lot and fixture catalogs should show cost, due day, storage needs, and physical receiving expectation.

### `IMG_1059.PNG`

Observed read:

- Ghost preview and stockable wall/shelf space.

Use:

- Fixture preview tied to future stock placement.

Implementation:

- Ghosts should preview stocking value, not just shape.

### `IMG_1060.PNG`

Observed read:

- Set-price modal with cost, market, sale price, profit, and action buttons.

Use:

- Decision UI at pricing point.

Implementation:

- Pricing panel should remain the reference for all money decisions: show input, consequence, and confirm/cancel clearly.

### `IMG_1061.PNG`

Observed read:

- Shelf-stocked goods connected to pricing.

Use:

- Products at shelf scale with pricing UI.

Implementation:

- Product price tags and shelf labels must stay readable but not oversized.

### `IMG_1062.PNG`

Observed read:

- Payment/register terminal with charged amount and transaction state.

Use:

- Payment-specific register read.

Implementation:

- Register UI should separate subtotal, tax, total/refund, tender/change, and confirmation.

### `IMG_1063.PNG`

Observed read:

- Stock boxes and product handling.

Use:

- Receiving and unpacking as physical work.

Implementation:

- Supplier delivery should create visible receiving work, not instant inventory.

### `IMG_1064.PNG`

Observed read:

- Dense shelves, boxes, customers, and sales floor context.

Use:

- Retail density target.
- Aisle and counter relationship.

Implementation:

- Sales floor must layer shelves, product repeats, category markers, and customers without blocking paths.

### `IMG_1065.PNG`

Observed read:

- Item/value presentation with game object focus.

Use:

- Product inspection and value cards.

Implementation:

- Inspect/pricing/trade-in UI should show product identity, value, condition, and margin with clear hierarchy.

### `IMG_1066.PNG`

Observed read:

- Product card/value presentation.

Use:

- Rarity/value/condition summary.

Implementation:

- Full catalog pass should include metadata that supports value-based UI, not only names and prices.

### `IMG_1067.PNG`

Observed read:

- Offer/accept/decline decision around a valuable item.

Use:

- Trade/offer decision framing.

Implementation:

- Trade-in and return decisions should show risk, offer/refund, margin, reason, and consequence before confirm.

### `IMG_1068.PNG`

Observed read:

- Small products/cards laid out in world space.

Use:

- Product density at table/shelf scale.

Implementation:

- The store needs repeated small items and tags that read as inventory without becoming visual noise.

### `IMG_1069.PNG`

Observed read:

- Close-up collection/value view.

Use:

- Product identity and total value read.

Implementation:

- Catalog and inspection panels should eventually support collection-like product value summaries.

### `IMG_1070.PNG`

Observed read:

- Supplier/order UI with cart and item list.

Use:

- Cart summary, quantity, unit cost, total, and purchase state.

Implementation:

- Supplier ordering should use a cart/card model, not only text lines.

### `IMG_1071.PNG`

Observed read:

- Stocked shelves with customers and aisle navigation.

Use:

- Customer traffic around retail density.

Implementation:

- Customer browse/queue paths must be validated after adding shelf density.

### `IMG_1072.PNG`

Observed read:

- Close counter/product handling with scanner/register context.

Use:

- Counter-side product scale and checkout props.

Implementation:

- Register counter should show scanned product space and customer-side context.

### `IMG_1073.PNG`

Observed read:

- Product, terminal, and customer-side counter detail.

Use:

- Register prop density and interaction focus.

Implementation:

- Counter props should support checkout read while leaving one clear interaction target.

### `IMG_1074.PNG`

Observed read:

- Dense retail environment with shelves, customers, counter, and path.

Use:

- Final opening-store density target.

Implementation:

- The quality bar should move from "functional blockout" toward this kind of stocked, navigable, legible retail floor.

## Cross-Cutting Implementation Requirements

### Spatial Read

- Store identity visible from spawn.
- Primary routes visible without tutorial text.
- Each zone has a different silhouette: storefront, sales shelf, register, receiving, backstock, office.
- Empty planes are broken by trim, materials, signs, or purposeful future-space cues.

### Product Read

- Product density comes from repeated small items, not oversized signs.
- Tags are readable up close and quiet at distance.
- Product identity, platform, category, condition, price, and risk must fit UI and world labels.
- No real IP, console names, or recognizable trade dress.

### UI Read

- All money decisions show cost/value/price/offer/profit/consequence before confirmation.
- Cards and swatches should replace long text rows where possible.
- Locked, available, purchased, applied, and invalid states need distinct visual language.
- UI must fit 1280x720.

### Backroom Read

- Receiving is a station with state, not a pile.
- Backstock is categorized storage, not hidden inventory.
- Computer is an office workstation, not an isolated debug panel.
- Safe/security/hidden-thread props stay optional and secondary.

## Quality-Bar Priorities

1. Storefront and spawn composition.
2. Sales floor shell/materials/pathing.
3. Shelf and fixture product density.
4. Register command center.
5. Receiving and stockroom physical workflow.
6. Backroom office and computer context.
7. Catalog/platform language foundation.
8. Decoration and upgrade preview language.

## Evidence Required

Each implementation slice should produce:

- Changed scene/resource/script list.
- Passing `scripts/validate_godot.sh`.
- Updated screenshot names.
- Pass/fail note against `docs/design-planning/08-quality-bar-checklist.md`.
- Bug-list update if any screenshot fails.
