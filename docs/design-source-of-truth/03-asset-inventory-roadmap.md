# Asset Inventory Roadmap

## Purpose

This roadmap turns the 300-object asset inventory workbook into implementation phases. It is not a mandate to build all 300 objects immediately.

The active art direction is now the Visual Bible. The workbook is an inventory source; `docs/visual-bible/` is the object-family quality bar.

## Inventory Summary

Workbook totals:

- total objects: 300
- Product: 67
- Marketing: 49
- Display: 25
- Hidden Narrative: 25
- Architecture: 22
- Signage: 22
- Electronics: 16
- Clutter: 15
- Storage: 13
- Paper Goods: 10
- Shelving: 8
- Utility: 8
- Equipment: 7
- Demo: 6
- Counter: 5
- Furniture: 2

## Current MVP Rule

Build object families first, not all spreadsheet rows.

Do not build all 300 objects as loose props.

MVP + first-store work is limited to:

- product art and packaging
- fixtures and displays
- store shell and mall interior
- counter/register/trade-in
- stockroom/receiving/office
- minimal signage and store identity

Broad marketing, decorations, hidden narrative props, mature catalog breadth, later platforms, customer visuals, employee visuals, mechanics work, playable-store polish, and beta/tester package assets stay out of scope until the isolated hero art slice screenshot is approved.

## Starter Product Direction

Use legally safe fictional products only.

Opening starter pack:

- `Footy 2002`
- one sequel-ready adventure/RPG franchise title with a better working name than prior drafts
- one starter console
- one starter accessory/controller

Rejected as source-of-truth starter title names:

- `Space Marines 2`
- `Blue Alive and Thriving`

The exact RPG title can be changed during product-art implementation, but it must be funny/recognizable without copying real games, publishers, logos, or packaging.

## Phase 0: Documentation Cleanup

Goal: make the new source of truth active and remove docs that route agents back to the rejected packet sequence.

Deliverables:

- active docs/status point to design source, Visual Bible, implementation index, current blockers, and QA evidence
- stale alpha/beta and Packet 01-09 docs removed from active routing
- validation docs state that automated gates are regression evidence, not art approval

## Phase 1: MVP Product Art Kit

Goal: make product close-ups look like actual legally safe video game merchandise.

Build:

- DVD-style game case mesh with bevels, spine, cover insert, back panel suggestion, plastic sheen, and price sticker
- used/new sticker variants
- two-tone platform/genre visual language
- starter cover art for `Footy 2002`
- starter cover art for one adventure/RPG franchise title
- starter console box
- starter accessory/controller box
- duplicate stack visual language

Acceptance:

- products read before floating labels
- cover art is recognizable at first-person distance
- legal safety is prioritized over parody closeness
- day-one stock remains limited

## Phase 2: MVP Fixture And Display Kit

Goal: replace primitive shelf/rack geometry with authored retail fixtures that can hold real capacity.

Build:

- starter wall shelf/rack
- optional small freestanding display
- empty capacity slots
- shelf label strip
- stocked and empty states
- collision/interaction anchors compatible with current mechanics

Acceptance:

- fixture holds roughly 10-30 items depending on size
- empty slots are visibly intentional
- fixture does not read as rectangles plus rods
- stocking still works

## Phase 3: Store Shell And Mall Interior Kit

Goal: make the store and mall approach read as a clean early/mid-2000s retail location.

Build:

- storefront glass rhythm
- door/threshold details
- sign housing
- drywall wall language
- low-pile carpet
- quiet ceiling/drop-panel treatment
- modest neighboring mall context

Acceptance:

- first read is a small game store, not a graybox room
- walls are not cluttered with random panels
- mall context supports the store without becoming a mall simulation

## Phase 4: Counter/Register/Trade-In Kit

Goal: make checkout and trade-in read as a real small-store workstation.

Build:

- straight counter/cash wrap
- register/POS
- scanner
- cash drawer/receipt/bags
- trade-in intake surface
- behind-counter hold/intake storage

Acceptance:

- counter reads from shape and props, not labels
- one customer line remains supported
- trade-in and checkout are one station

## Phase 5: Stockroom/Receiving/Office Kit

Goal: make the backroom a real operational space.

Build:

- receiving area
- clean storage racks
- setup boxes
- office desk/computer/calendar
- door/sign/threshold from sales floor

Acceptance:

- backroom reads as office + storage
- starter delivery/setup flow is visible
- receiving is far enough from the sales-floor door to feel like a work area

## Phase 6: Minimal Signage And Identity

Goal: add readable store support without using text as the whole visual solution.

Build:

- editable `Games4U` storefront sign
- grand-opening sign
- open/closed sign support
- shelf labels
- restrained legal-safe promo posters

Acceptance:

- signs are readable and restrained
- product/fixture/shell objects still communicate without text
- signage does not clutter clean walls

## Phase 7: Playable Store Integration

Goal: replace the primitive visible objects in the playable store while preserving mechanics.

Acceptance:

- player can enter, receive, carry, stock, price, sell, trade in, and use backroom computer
- new object families are visible in the real route
- screenshots support owner review against the 7.5/10 target
- `scripts/validate_godot.sh` passes
