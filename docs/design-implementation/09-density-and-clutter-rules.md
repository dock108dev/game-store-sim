# Density And Clutter Rules

## Goal

Define how the opening store avoids becoming either an empty prototype or a pile of unrelated objects.

Day one should feel empty and promising. The store is being set up for the first time, so visible objects should mostly support first tasks: receiving, placing fixtures, stocking starter products, setting up demo hardware, and preparing to open for a small number of early customers.

Density approval is visual-review based, not a strict percentage gate. The store must read as a believable underfunded game store with growth space.

## Player-Facing Result

At opening setup, the player sees:

- clean open sales floor space
- a small number of purposeful setup items
- boxes tied to receiving, setup, or large console stock display
- no random piles of primitive clutter
- a stockroom with starter receiving tasks and a backroom planning desk
- a sales floor that looks ready to become a store, not abandoned or complete
- mall atmosphere that can include some fixed decoration

The first impression should be: this store can open today after the player completes a few setup tasks.

## Owner Decisions Captured

- Day one should feel empty and promising.
- Day-one clutter should mostly be boxes and setup needs that serve first pre-opening tasks.
- The opening tasks should prepare the store for a couple customers wandering in.
- Some immovable decorations are acceptable, especially in the mall.
- Displays, posters, and additional demo units are purposeful purchases that can be updated, changed, or removed when the player wants.
- Future open sales-floor space should be clean space, not visual placeholders.
- Stockroom should start with a couple starter items to receive for day one.
- Stockroom should include a desk with computer and calendar.
- Ordering, release dates, events, and store expansion options are backroom work, not register work.
- Sales-floor boxes should generally be limited to large consoles used to represent stock.
- A player should be able to place a console box in a grid space and stack a few more on top.
- Games, controllers, handheld consoles, guides, and shelves should generally use shelves/fixtures on the sales floor.
- In the stockroom, products can be placed on floor or tables as storage, preferably grid-limited with healthy storage maximums.
- Hard no-list includes random cubes, floating labels, too many signs, unreadable piles, and clutter spam.
- Repeated boxes are allowed when they represent intentional repeated stock, such as several identical console boxes on display.
- Density targets should be decided by visual review, not strict percentages.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Store Shell And Mall Entrance Slice](03-store-shell-and-mall-entrance-slice.md)
- [Starting Store Layout Spec](04-starting-store-layout-spec.md)
- [Fixture Grid Slice](05-fixture-grid-slice.md)
- [Checkout And Trade-In Counter Slice](06-checkout-and-trade-in-counter-slice.md)
- [Product And Platform Visual Language Spec](07-product-and-platform-visual-language-spec.md)
- [Required Zones Slice](08-required-zones-slice.md)
- [Vertical Slice Specification](../design-source-of-truth/01-vertical-slice-spec.md)
- [Store Design And World Building](../design-source-of-truth/02-store-design-world-building.md)

Feeds:

- [Signage Branding And Store Identity Spec](10-signage-branding-and-store-identity-spec.md)
- [Lighting Materials And Color Palette Spec](11-lighting-materials-and-color-palette-spec.md)
- [Validation And Screenshot Checklist](12-validation-and-screenshot-checklist.md)

## In Scope

- Define day-one density intent.
- Define acceptable sales-floor clutter.
- Define acceptable stockroom clutter.
- Define repeated-box rules.
- Define pure atmosphere versus gameplay-purpose rules.
- Define mall-decoration flexibility.
- Define hard no-list.
- Define visual-review acceptance rules.

## Out Of Scope

- Mature-store density targets.
- Full decoration catalog.
- Final mall art pass.
- Hidden narrative clutter rules beyond avoiding premature spam.
- Exact object count budgets for every room.
- Automated density scoring.

## Density Philosophy

The opening store should be sparse by design.

Use visual review questions instead of strict counts:

- Does the store look like it can open after a short setup phase?
- Is there clean space for future shelves, displays, and expansion?
- Does every visible object have a clear reason?
- Does the player understand the next task by looking at the room?
- Is the store still readable from the entrance?
- Can the player move cleanly through entrance, checkout, demo, stockroom, and starter fixtures?

Avoid solving emptiness by adding filler. The right day-one read is potential, not fullness.

## Sales Floor Rules

Sales floor should be clean and purposeful.

Allowed day-one sales-floor objects:

- checkout/register setup
- demo area
- starter fixtures
- starter products after player places them
- large console boxes if intentionally placed/stacked to show stock
- small setup boxes only if tied to an active setup task
- store/mall signage that supports orientation or mood

Avoid on sales floor:

- random loose games/controllers/guides on floor
- random cardboard box piles
- unassigned future inventory
- pure clutter that blocks routes
- repeated tiny props used only to fill space
- floating labels explaining object identity

The floor should mostly stay clear. Products that belong on shelves should use shelves or stockroom storage, not sales-floor scatter.

## Large Console Box Rule

Large console boxes are the main exception to sales-floor box restrictions.

Allowed:

- place one large console box on a valid grid space
- stack a small number of matching boxes on top when physically plausible
- use repeated boxes to show real inventory in stock
- keep stacks aligned, readable, and route-safe

Required:

- boxes must represent actual inventory or approved visual stock state
- stack height must be capped
- stack footprint must respect grid/collision rules
- boxes must not block customer routes or key interactions
- repeated boxes must be intentional, not filler spam

Examples:

- acceptable: a neat stack of three `Vertex` console boxes on a display grid square.
- not acceptable: twelve random unbranded cubes scattered across the checkout path.

## Stockroom Rules

Stockroom can be more work-like than the sales floor, but it should still be controlled.

Day-one stockroom should include:

- a couple starter receiving items
- receiving area farthest practical point from sales-floor door
- setup boxes tied to first tasks
- desk with computer
- calendar
- planning/ordering surface

Backroom desk role:

- ordering
- release dates
- event calendar
- store expansion options
- distributor planning
- future unlock review

This work should happen in the stockroom/backroom, not on the sales register.

Stockroom storage rules:

- games/controllers/handhelds/guides/shelves can be placed on stockroom floor or tables as needed
- stockroom placement should still use grid/slot limits where possible
- storage caps should be generous enough to avoid frustrating the player
- storage caps should prevent infinite messy piles that break future systems

## Setup Task Clutter

Opening clutter should support actual first tasks.

Acceptable task clutter:

- unopened starter shipment box
- opened shipment box
- boxed starter console
- starter products waiting to be stocked
- packaging tied to demo setup
- receiving checklist or clipboard, if implemented
- backroom desk/calendar/computer

Each setup object should lead naturally into an action:

- receive
- unpack
- place
- stock
- price
- set up demo
- open store

If an object does not support a task, atmosphere, or clear store function, it should probably be removed.

## Atmosphere Decoration Rules

Some pure atmosphere is allowed, especially outside the store in the mall.

Mall/exterior atmosphere can include:

- fixed planters
- benches
- corridor signs
- neighboring store displays
- light fixtures
- simple poster bays
- directory-style signs

Sales-floor atmosphere should mostly be player-owned or store-functional:

- posters are purchasable/changeable/removable where practical
- displays are purchasable/changeable/removable
- extra demo units are purposeful purchases
- fixed decor should be restrained and should not fight player customization

Pure atmosphere can exist, but it should not become an excuse for clutter spam.

## Purposeful Purchase Rules

The following should generally be player purchases/unlocks rather than permanent filler:

- posters
- promotional displays
- extra demo units
- endcaps
- bargain bins
- guide racks
- hardware cases
- store decorations

Purchased or unlocked objects should be:

- placeable where practical
- updatable where practical
- removable where practical
- governed by collision/route rules
- tied to store progression or player choice

## Hard No-List

Do not use:

- random cubes as final clutter
- floating labels as object identity
- unreadable piles
- route-blocking prop spam
- too many signs fighting for attention
- repeated boxes with no inventory/purpose
- future inventory staged on sales floor
- oversized text replacing art
- raw primitive objects left as visible final assets
- clutter that hides interaction points
- clutter that makes screenshots unreadable

Repeated boxes are allowed only when they represent intentional repeated stock or storage.

## Visual Review Standard

Density is approved by screenshot and walkthrough review.

Required review viewpoints:

- mall approach into storefront
- entrance looking into store
- checkout looking across store
- demo area looking toward entrance
- sales floor looking toward stockroom door
- stockroom door looking into stockroom
- stockroom desk/receiving view

Pass criteria:

- store feels empty and promising
- setup tasks are understandable
- clean growth space is visible
- clutter has purpose
- stockroom reads as backroom work space
- receiving is not customer-facing
- mall can have atmosphere without stealing focus
- no view reads as a random pile of cubes

## Required Modules

Implementation should produce or standardize modules for:

- setup box
- opened shipment box
- large console box stack
- stockroom receiving box
- backroom desk
- computer
- calendar
- simple setup checklist/clipboard, optional
- mall atmosphere props
- prop placement/collision cap rules

Later modules:

- purchasable poster
- purchasable promotional display
- extra demo unit
- decoration catalog item
- stockroom table storage
- store expansion planning board

## Likely Scene Files

Likely touched during implementation:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/graybox_store.tscn`
- `game/scenes/world/modules/stockroom/*.tscn`
- `game/scenes/world/modules/products/*.tscn`
- `game/scenes/world/modules/decor/*.tscn`
- `game/scenes/world/modules/mall/*.tscn`

Exact paths may change if implementation creates a cleaner module folder structure.

## Likely Script Files

Likely touched during implementation:

- prop placement scripts
- inventory placement scripts
- stockroom storage scripts
- fixture/decoration catalog scripts
- receiving task scripts
- save/load for placed clutter and storage
- visual review screenshot manifests

Implementation should preserve the working retail loop while making visible objects purposeful and readable.

## Data Requirements

Each clutter/prop definition should include:

- prop id
- prop role
- movable/fixed flag
- player-owned flag
- purchasable/unlockable flag
- valid room/zone
- inventory representation flag
- stackable flag
- max stack height
- footprint
- collision shape
- route-blocking behavior
- visual-review category

Prop roles should include:

- setup task
- stockroom storage
- sales-floor inventory display
- mall atmosphere
- store decoration
- fixture/display purchase
- hidden/optional

## Tests To Add Or Update

Later implementation should add or update tests for:

- day-one clutter registry includes only approved starter roles
- large console boxes can stack within capped limits
- non-console sales-floor boxes are rejected unless tied to active setup task
- stockroom floor/table storage uses limits
- backroom desk/computer/calendar exist in stockroom planning area
- receiving items are not customer-facing
- mall fixed atmosphere props are allowed outside player customization rules
- floating debug labels are not used as final clutter identity
- placed clutter persists through save/load if player-owned or task-relevant

Doc/status tests should include this doc as an active planning document once written.

## Screenshot Targets

Capture these once the implementation exists:

- `density_entrance_empty_promising.png`: entrance view with clean growth space.
- `density_setup_task_boxes.png`: day-one setup boxes tied to receiving/stocking.
- `density_console_box_stack.png`: intentional large-console box stack on valid grid.
- `density_stockroom_planning_desk.png`: stockroom desk with computer/calendar.
- `density_stockroom_receiving.png`: receiving area with starter items, hidden from sales floor.
- `density_mall_atmosphere.png`: mall decor atmosphere without stealing store focus.
- `density_no_pile_review.png`: representative view proving no random cube pile/clutter spam.

## Acceptance Checklist

- [ ] Day-one sales floor feels empty and promising.
- [ ] Clean future growth space is visible.
- [ ] Day-one clutter supports first setup tasks.
- [ ] Sales-floor boxes are limited to active setup or intentional large-console inventory display.
- [ ] Large console boxes can be stacked with capped grid/collision rules.
- [ ] Games/controllers/handhelds/guides use shelves/fixtures on sales floor.
- [ ] Stockroom supports floor/table storage with healthy limits.
- [ ] Stockroom includes desk, computer, and calendar for backroom planning.
- [ ] Ordering/release/events/expansion work is tied to backroom desk, not register.
- [ ] Mall may include restrained fixed atmosphere decor.
- [ ] Player-purchased displays/posters/demo units are updateable/changeable/removable where practical.
- [ ] No random cubes, floating labels, unreadable piles, or sign spam remain as final visual language.
- [ ] Approval is based on screenshot/walkthrough visual review.

## Fail Conditions

This doc fails if:

- day-one store looks fully stocked or mature
- day-one store looks abandoned instead of promising
- open sales-floor space is filled with filler clutter
- clutter does not support setup, gameplay, atmosphere, or inventory display
- stockroom planning work is pushed onto the register counter
- repeated boxes are used as meaningless filler
- random cubes or floating labels explain object identity
- screenshot views look like object spam instead of a store

## Stop/Ask-Owner Conditions

Stop and ask before:

- making strict numeric density percentages the primary approval gate
- adding large amounts of pure atmosphere to the sales floor
- making posters/displays/demo units permanent instead of player-updatable where practical
- allowing non-console sales-floor product piles as normal merchandising
- removing the backroom planning desk concept

Do not stop for normal object count tuning if visual review keeps the opening store empty, promising, and task-readable.

## Commit Expectation

Commit the density/clutter implementation as its own slice after docs, tests, and screenshots are updated.

The commit should be reviewable independently from signage, lighting, validation checklist, and final roadmap work unless those are required to prove clutter readability.

## Next Document

After this doc, write `10-signage-branding-and-store-identity-spec.md` to define store name, brand tone, signs, posters, headers, mall storefront identity, and copy style.
