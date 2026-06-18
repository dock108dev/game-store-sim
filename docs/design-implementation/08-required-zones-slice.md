# Required Zones Slice

## Goal

Define the required store zones as gameplay-supported roles rather than hard-coded permanent floor sections.

The store should support new releases, used games, demo, bargain, guides/media, hardware, and receiving workflows. However, the player should organize the store through fixture placement, labels, inventory source, pricing, and first-use guidance. The zone system should help the store read clearly without taking away player layout control.

## Player-Facing Result

At opening setup, the player should understand:

- products know whether they are new, used, trade-in, ordered, held, or received
- fixtures can be labeled or organized by the player
- new/used status is not manually faked by giant labels
- a day-one demo area exists near the front opposite the register side
- receiving is in the stockroom, far from the sales-floor door
- guides/media and bargain are future unlocks, not day-one clutter
- hardware begins as an out-of-box demo item plus boxed inventory where relevant
- first-time guidance explains new mechanics when the player tries or unlocks them

The store should feel guided but not prescriptive. If the player wants a `Footy 2002 MultiPlat` shelf instead of platform-by-platform shelves, the systems should allow that.

## Owner Decisions Captured

- New versus used should be automatic based on where inventory came from.
- New games should have a default assumed price.
- The player can change used prices.
- The player can change new prices only after the new game has been released for some time.
- Day-one demo area is required.
- Demo should be near the front, opposite the register side where practical.
- Bargain should not exist day one.
- Used inventory comes from trade-ins or bulk used orders through the used inventory system.
- Guides/media are too much detail for the opening baseline and should be later unlocks.
- Hardware begins with demo out of box.
- Console inventory remains boxed.
- Larger console boxes can be stackable on the floor if the player chooses to keep them there.
- Receiving should not be visible from the sales floor.
- Receiving should be in the stockroom, farthest from the door to the sales floor.
- Platform sections are not mandatory day one because the store is player organized.
- The player can organize products by game title, platform, condition, genre, or any fixture label that makes sense.
- First-use guidance should appear the first time the player tries, unlocks, or uses something.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Starting Store Layout Spec](04-starting-store-layout-spec.md)
- [Fixture Grid Slice](05-fixture-grid-slice.md)
- [Checkout And Trade-In Counter Slice](06-checkout-and-trade-in-counter-slice.md)
- [Product And Platform Visual Language Spec](07-product-and-platform-visual-language-spec.md)
- [Vertical Slice Specification](../design-source-of-truth/01-vertical-slice-spec.md)
- [Store Design And World Building](../design-source-of-truth/02-store-design-world-building.md)

Feeds:

- [Density And Clutter Rules](09-density-and-clutter-rules.md)
- [Signage Branding And Store Identity Spec](10-signage-branding-and-store-identity-spec.md)
- [Lighting Materials And Color Palette Spec](11-lighting-materials-and-color-palette-spec.md)
- [Validation And Screenshot Checklist](12-validation-and-screenshot-checklist.md)

## In Scope

- Define required zone roles.
- Define which zones exist day one versus later.
- Define inventory-source-driven new/used status.
- Define default and editable pricing rules.
- Define demo area placement rule.
- Define hardware display/storage split.
- Define receiving location inside the stockroom.
- Define first-use guidance behavior.
- Define acceptance checks for zone readability without fixed permanent sections.

## Out Of Scope

- Full guides/media production pass.
- Bargain-bin implementation at day one.
- Mandatory platform aisles.
- Mature-store planogram.
- Employee-assisted zone workflows.
- Full tutorial scripting beyond first-use guidance requirements.
- Deep pricing economy tuning.

## Zone Philosophy

Zones are functional roles, not fixed architecture.

Allowed organization examples:

- fixture labeled `New Releases`
- fixture labeled `Used Games`
- shelf labeled `Footy 2002 MultiPlat`
- shelf row using platform dividers inside a title-focused display
- demo area near the front opposite register
- used products grouped on a used shelf after trade-ins arrive
- hardware boxes stacked on floor or stockroom shelf if the player chooses

Avoid:

- hard-coded permanent new/used/platform zones that ignore player fixture labels
- debug text floating over every area
- future products staged as physical inventory to make a zone look complete
- mandatory day-one bargain/guides areas before those systems matter

## Inventory Source Rules

Product condition and zone defaults should come from inventory source.

New inventory:

- comes from distributor orders, launch/release allocations, or new stock receiving
- receives default assumed new price
- cannot be freely repriced immediately at release unless the pricing system explicitly allows it
- becomes eligible for player repricing only after the game has been released for some time

Used inventory:

- comes from customer trade-ins
- comes from bulk used orders once that inventory system is available
- receives used condition markers and used price sticker rules
- can be repriced by the player
- can later support bargain/clearance routing

Held inventory:

- can sit behind counter if on hold for a future customer
- should not be stocked as ordinary sale inventory until released from hold

Receiving inventory:

- starts in stockroom receiving
- should move from receiving to stockroom/storage/sales-floor fixtures through normal stocking flow

## Pricing Rules

Pricing should support the visual language without adding unnecessary opening complexity.

Required:

- new games get default new price
- used games get editable used price
- case sticker should show condition and price
- new price becomes editable only after a release-age threshold
- pricing UI/state should distinguish new and used copies

Examples:

- `New $49.99`
- `Used $5.99`
- `Used $12.99`

The exact release-age threshold can be tuned later. This doc only requires the rule that brand-new releases are not immediately fully free-priced in the same way used products are.

## Day-One Required Zones

Day one should include:

- checkout/trade-in counter
- demo area
- stockroom
- receiving area inside stockroom
- player-placeable product fixture capacity
- minimal product display based on owned starting inventory

Day one should not require:

- bargain bin
- guides/media rack
- fully populated platform sections
- full hardware case
- full used wall before trade-ins/used orders exist

## New Releases Role

New release identity comes from product source and release timing.

Implementation requirements:

- new products arrive from distributor/release flow
- default new price applies
- product case shows new condition/price sticker
- player may assign a fixture label such as `New Releases`
- products can be stocked wherever compatible with fixture rules

New Releases should be available as a label/organization concept, but it should not force a permanent wall location.

## Used Games Role

Used games come from trade-ins or bulk used orders.

Implementation requirements:

- used condition is automatic from source
- used case/sticker language applies
- used price is player-editable
- used products can be stocked into any compatible fixture
- player may assign a fixture label such as `Used Games`
- later bargain routing can reuse used inventory state

The store should not start with a fake used wall unless the player actually receives used inventory through the appropriate system.

## Demo Area

The demo area is required day one.

Placement rule:

- near the front
- opposite the register side where practical
- visible when entering
- not blocking entrance path
- not hidden behind the counter

If the register is middle-left, the demo target should be front-right. If the register is middle-right, the demo target should be front-left.

Demo content:

- one out-of-box demo console/hardware item
- display/TV/kiosk appropriate to the visual source of truth
- clean route for player and customers

Demo area is the place to show hardware out of box. Boxed console inventory should remain boxed.

## Hardware Role

Hardware begins modestly.

Day-one hardware:

- one out-of-box demo item in demo area
- boxed inventory for actual stock

Boxed hardware rules:

- larger console boxes can stack if the player keeps them on the floor
- boxed hardware can live in stockroom or player-chosen sales floor location when fixture/routing rules allow
- boxed hardware should look like inventory boxes, not loose display consoles

Later hardware:

- glass/locked cases
- dedicated hardware fixtures
- larger platform launches
- more demo stations

## Bargain Role

Bargain is not day one.

Unlock conditions may include:

- used inventory surplus
- extra new copies after demand falls
- clearance decisions
- bulk used orders
- aging inventory

Bargain should become a label/bin/fixture role once inventory conditions justify it. Do not stage a bargain bin just to fill space in the opening store.

## Guides And Media Role

Guides/media are later unlocks for the opening baseline.

Future role:

- strategy guide rack
- gaming magazine/media rack
- lightweight browsing hook
- cross-sell near relevant products

Do not spend day-one visual budget on guides/media until the core product, fixture, demo, checkout, stockroom, and receiving reads are stable.

## Receiving Role

Receiving must be in the stockroom.

Placement:

- not visible from sales floor
- farthest practical point from the stockroom door to the sales floor
- clearly back-of-house
- reachable from stockroom workflow

Receiving supports:

- distributor orders
- bulk used orders
- fixture deliveries
- incoming product boxes
- unpacking/sorting flow

Receiving should not become a decorative pile of boxes in the customer-facing store.

## First-Use Guidance

Guidance should appear when a player first tries, unlocks, or uses a system.

Guidance targets:

- first fixture placement
- first fixture label/category assignment
- first new stock placement
- first used trade-in intake
- first used price edit
- first demo setup
- first receiving flow
- first bargain unlock
- first guides/media unlock
- first hardware box stocking or floor stack

Guidance rules:

- explain the action at the moment it matters
- avoid permanent on-screen instructions
- avoid forcing one correct layout
- suggest a sensible starting action, then let the player override
- do not use giant in-world labels as tutorial replacement

Example behavior:

- When first placing a shelf, suggest assigning a label.
- When first stocking `Footy 2002`, explain that player can group by title, platform, condition, or genre.
- When first used trade-in arrives, explain used price editing.
- When bargain unlocks, explain that bargain is useful for surplus/aging/used stock.

## Required Modules

Implementation should produce or standardize modules for:

- zone role definitions
- fixture label presets
- inventory-source condition markers
- new/used price sticker state
- demo area anchor
- receiving area anchor
- boxed hardware stackable module
- first-use guidance trigger definitions

Later modules:

- bargain bin
- guides/media rack
- hardware case
- platform section helper signage
- clearance/bargain sticker set

## Likely Scene Files

Likely touched during implementation:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/graybox_store.tscn`
- `game/scenes/world/modules/fixtures/*.tscn`
- `game/scenes/world/modules/products/*.tscn`
- `game/scenes/world/modules/demo/*.tscn`
- `game/scenes/world/modules/stockroom/*.tscn`

Exact paths may change if implementation creates a cleaner module folder structure.

## Likely Script Files

Likely touched during implementation:

- inventory source/state scripts
- pricing scripts
- fixture labeling scripts
- product stocking scripts
- demo setup scripts
- receiving/stockroom scripts
- first-use guidance scripts
- save/load for zone labels and guidance completion

Implementation should preserve the working retail loop while making zone identity arise from real inventory state and fixture choices.

## Data Requirements

Inventory item state should include:

- source type
- condition
- release date or release-age state
- default price
- current price
- price editability state
- held/stocked/receiving/storage state
- compatible fixture roles

Fixture label presets should include:

- New Releases
- Used Games
- Demo
- Hardware
- Bargain
- Guides/Media
- custom player label

Guidance state should include:

- guidance id
- trigger condition
- completion state
- optional suggested action
- related system

## Tests To Add Or Update

Later implementation should add or update tests for:

- new inventory is tagged from distributor/release source
- used inventory is tagged from trade-in or bulk used source
- used prices are editable
- brand-new release prices are not immediately editable unless release-age threshold allows it
- fixture labels can be player-assigned and persisted
- platform sections are optional, not mandatory day-one fixtures
- demo area exists day one near front opposite register side when layout allows
- bargain is not day-one required
- guides/media are not day-one required
- receiving anchor is inside stockroom and not visible from sales floor
- first-use guidance triggers once per relevant system

Doc/status tests should include this slice as an active planning document once written.

## Screenshot Targets

Capture these once the implementation exists:

- `zones_demo_front_opposite_register.png`: demo area near front opposite register side.
- `zones_new_used_labels_player_assigned.png`: fixture labels assigned by player, not permanent layout labels.
- `zones_used_from_trade_in.png`: used product created from trade-in flow and ready to stock.
- `zones_receiving_stockroom_deep.png`: receiving area at far stockroom location, hidden from sales floor.
- `zones_hardware_box_stack.png`: boxed console inventory stackable without loose-console clutter.
- `zones_guidance_first_fixture.png`: first-use guidance for fixture/label setup.

## Acceptance Checklist

- [ ] New/used status comes from inventory source.
- [ ] New games have default prices.
- [ ] Used prices are player-editable.
- [ ] New prices become editable only after an age/release threshold.
- [ ] Day-one demo area exists near the front opposite register side where practical.
- [ ] Bargain is not required day one.
- [ ] Guides/media are not required day one.
- [ ] Hardware demo is out of box while actual stock can remain boxed.
- [ ] Larger console boxes can stack if player keeps them on floor.
- [ ] Receiving is in the stockroom, farthest practical point from sales-floor door.
- [ ] Platform sections are optional and player-organized.
- [ ] Fixture labels support title/platform/condition/genre/custom organization.
- [ ] First-use guidance appears when systems are first tried, unlocked, or used.

## Fail Conditions

This slice fails if:

- zones are hard-coded in a way that prevents player organization
- new/used status is manually faked by labels instead of inventory source
- used games appear before trade-ins or used inventory acquisition
- bargain or guides/media clutter the day-one store before unlocks
- demo is hidden in back or behind counter
- receiving is visible from the sales floor
- platform sections are mandatory day-one layout requirements
- guidance becomes permanent UI noise or giant in-world instruction text

## Stop/Ask-Owner Conditions

Stop and ask before:

- forcing fixed platform aisles on day one
- making bargain or guides/media required in the opening setup
- allowing new-release repricing immediately with no release-age rule
- placing receiving where customers can see it
- replacing player organization with a rigid planogram

Do not stop for normal label presets, tutorial copy, or fixture-zone iteration if the player remains free to organize the store.

## Commit Expectation

Commit the required-zones implementation as its own slice after docs, tests, and screenshots are updated.

The commit should be reviewable independently from density/clutter, signage, and lighting polish unless those are required to prove the zone read.

## Next Document

After this doc, write `09-density-and-clutter-rules.md` to define day-one occupancy, acceptable mess, purposeful props, anti-spam rules, and how the store avoids becoming a pile of unrelated objects.
