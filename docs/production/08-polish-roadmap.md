# Polish Roadmap

This phase turns the validated graybox into a readable, appealing first production pass. The goal is not final art. The goal is visual clarity, better menus, stronger store identity, and a manual checklist that matches what the player actually sees.

Active execution plan: `10-polish-execution-plan.md`.

## Phase Goal

Make the current retail loop feel intentional:

- The store should read as a small specialty game shop.
- The backroom should read as receiving, storage, management, service, and paperwork space.
- The computer should read as a management interface, not a debug summary.
- Customers should read as distinct roles before the player clicks them.
- Products and fixtures should remain easy to inspect, carry, stock, and sell.

## Inspiration Translation

Use the inspiration images as production constraints:

- Small retail frontage and signage imply the store needs a stronger brand/signage pass.
- Dense fixture layouts imply the store should feel stocked but not visually noisy.
- Backroom/office references imply a practical operations zone with boxes, paperwork, computer, repair/storage surfaces, and optional suspicious artifacts.
- Placement UI references imply visible ghost previews, grid/snap affordances, and clear valid/invalid states.
- Supplier/menu references imply grouped categories and readable controls, not one long text panel.
- Retail clutter references imply posters, price tags, bins, signage, and display props, but every interactive object must stay readable.

Do not copy overlays, facecams, streamer UI, real brands, or platform chrome.

## Slice 1: Backroom Spatial And Visual Identity

Status: done.

Implementation plan: `09-backroom-polish-implementation-plan.md`.

Outcome:

- Backroom has clear receiving, storage, computer, and service/paperwork zones.
- Receiving box, supplier note, hidden clue, and storage rack preview do not visually crowd each other.
- Backroom computer placement reads as management.

Likely work:

- Adjust backroom layout and prop placement.
- Add simple graybox props for storage shelves, boxes, paperwork, and service/repair surface.
- Improve backroom floor/wall/material separation from sales floor.
- Update screenshots and manual checklist.

Validation:

- `scripts/validate_godot.sh`.
- Automated `backroom_polish` scenarios for zone anchors and prop existence.
- Manual checks for backroom readability, receiving clutter, computer identity, hidden clue optionality, and screenshot composition.

## Slice 2: Backroom Computer And Menu Information Architecture

Outcome:

- Backroom computer is organized into clear sections or tabs.
- Reports, inventory, supplier orders, fixtures, release planning, and day controls are easier to scan.
- Buttons fit without crowding and disabled states are understandable.

Likely work:

- Refactor `DaySummaryPanel` layout.
- Group labels and actions by domain.
- Preserve current store-session behavior.
- Keep text short enough for actual 1280x720 screenshots.

Validation:

- Existing day summary, supplier, fixture, release, service, preorder, and launch tests.
- Manual checks for panel readability, button labels, visual hierarchy, and mouse capture.

## Slice 3: Customer Readability And Role Silhouettes

Outcome:

- Buyer, trade-in seller, preorder customer, service customer, and suspicious customer are visually distinct.
- Register area reads as organized retail activity, not a pile of placeholders.
- Customer prompts and feedback are clear.

Likely work:

- Adjust customer meshes, colors, carried props, poses, and placements.
- Add simple role indicators that fit the world.
- Improve queue orientation and role separation.

Validation:

- Existing customer, register, spacing, and screenshot tests.
- Manual checks for role readability, queue clarity, and special-customer separation.

## Slice 4: Store Lighting, Materials, And Signage

Outcome:

- Sales floor feels warmer and more like a specialty game shop.
- Store zones are visually legible.
- Signage helps identify receiving, register, backroom, display rack, and pricing/stocking context.

Likely work:

- Lighting pass.
- Wall/floor material contrast.
- Fictional store signage and simple retail posters.
- Price/signage props that do not block interaction.

Validation:

- Screenshot sanity plus manual screenshot composition review.
- Manual checks for prompt readability under lighting changes.

## Slice 5: Product And Fixture Presentation

Outcome:

- Used-game cases, shelves, racks, receiving box, carried stack, and customer-carried items look intentional.
- Fixture ghost and placed fixture states remain distinct.
- Product affordances remain clear from player camera angles.

Likely work:

- Improve case materials and cover labels.
- Add rack/shelf detail.
- Improve receiving-box contents and delivered-stock placement.
- Tune carry pose if visual polish changes scale.

Validation:

- Existing product, shelf, player carry, screenshot, and manual visual checks.

## Slice 6: Validation And Manual QA Tightening

Outcome:

- Manual validation stays current after visual/menu polish.
- Any new critical visual or UI scenario is automated where practical.
- Screenshot list remains useful and not just nonblank.

Likely work:

- Update `07-current-manual-playtest.md`.
- Update `manual_checks.json`.
- Add or rename screenshot captures only when they prove a real regression surface.

Validation:

- `scripts/validate_godot.sh`.
- Human manual pass recorded in the implementation summary when performed.

## Phase Exit Criteria

- Current full retail loop remains validated.
- Backroom and sales floor are visually distinct.
- Backroom computer is organized enough for repeated use.
- Customers read as separate roles.
- Core props and products look intentional.
- Manual checklist reflects the actual UI and scene.
- No new visual polish breaks interaction readability, accounting, customer flow, or hidden-thread optionality.
