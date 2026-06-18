# Fixture Grid Slice

## Goal

Define the fixture system that turns the store from static set dressing into a player-configurable retail space.

Fixtures are the bridge between layout, products, inventory, and visual quality. The player should buy or unlock fixtures, place them on a snap grid, label or assign them, and then stock physical products onto visible shelf/table/bin capacity.

This slice should prevent the store from becoming a pile of unrelated cubes. Every fixture needs a clear retail purpose, a believable cheap starter material read, visible capacity, and rules for how it supports later growth.

## Player-Facing Result

At opening setup, the player sees a modest underfunded store with a small number of cheap fixtures and obvious growth space:

- primarily wall shelves or wall racks for starter product
- empty or mostly empty fixture capacity
- starter products physically visible only after the player places them
- no bins full of fake future inventory
- no wall of duplicate product cases pretending to be progression
- fixture labels such as Used Games, New Releases, Bargain, Accessories, or Hardware only where the player assigns them
- snap-to placement feedback for movable fixtures

The store should read as a place the player is setting up for the first time, not a finished shop with missing art.

## Owner Decisions Captured

- Starter fixture style should read as cheap laminate, with a small mix of simple budget materials if useful.
- Day-one fixtures should primarily be wall shelves or wall racks for product.
- Bins come later, once the store has used games, extra new-game copies, or discounted inventory.
- More consoles, display tables, and demo tables come later as unlocks/upgrades.
- Everything purchasable or unlockable should be movable.
- Fixed elements are limited to operational and architectural anchors such as register, stock receiving, backroom/back-alley door, walls, storefront, and structural thresholds.
- Fixture labels/headers are wanted.
- Locked/glass cases are later unlocks, not day-one requirements.
- Starter fixtures should be empty until the player places physical media on them.
- When a player places a game or accessory, that item should visibly appear on the shelf, table, bin, or fixture.
- Shelves, bins, and tables need visible capacity limits.
- Placement should snap to a grid.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Store Shell And Mall Entrance Slice](03-store-shell-and-mall-entrance-slice.md)
- [Starting Store Layout Spec](04-starting-store-layout-spec.md)
- [Vertical Slice Specification](../design-source-of-truth/01-vertical-slice-spec.md)
- [Store Design And World Building](../design-source-of-truth/02-store-design-world-building.md)

Feeds:

- [Checkout And Trade-In Counter Slice](06-checkout-and-trade-in-counter-slice.md)
- [Product And Platform Visual Language Spec](07-product-and-platform-visual-language-spec.md)
- [Required Zones Slice](08-required-zones-slice.md)
- [Density And Clutter Rules](09-density-and-clutter-rules.md)
- [Signage Branding And Store Identity Spec](10-signage-branding-and-store-identity-spec.md)

## In Scope

- Define starter fixture families and unlockable fixture families.
- Define movable versus fixed fixture rules.
- Define fixture labels/category assignment.
- Define visible slot/capacity behavior.
- Define snap-to placement rules.
- Define how empty fixtures should look before stocking.
- Define how physical products appear after stocking.
- Define fixture-scale expectations so products, aisles, and player movement remain readable.
- Define implementation acceptance checks for fixture placement, labeling, and visible stocked state.

## Out Of Scope

- Final product art for every platform.
- Full mature-store density.
- Locked/glass-case implementation on day one.
- Bargain bins on day one unless a later inventory state requires them.
- Customer browsing behavior beyond preserving routes and approach points.
- Decorative clutter that does not support stocking, browsing, checkout, receiving, or progression.

## Fixture Families

### Starter Fixtures

Starter fixtures should feel cheap, practical, and replaceable.

Required starter candidates:

- basic wall shelf
- basic wall rack
- small product-facing shelf insert or slot strip
- compact label/header rail
- demo display base if required by the opening setup

Starter materials:

- cheap laminate boards
- simple black or dark metal supports
- scuffed shelf edges
- muted sticker/label strips
- no premium glass or polished retail buildout

Starter fixtures should not look like temporary debug geometry. They can be simple, but they need enough bevels, scale control, material contrast, and product slots to read as store fixtures.

### Later Unlock Fixtures

Later fixture unlocks should expand capacity and store identity.

Later candidates:

- bargain bin
- used-game bin
- freestanding gondola shelf
- display table
- console demo table
- accessory pegboard or wall hook rack
- glass or locked hardware case
- premium wall bay
- endcap or promo stand

Later fixtures should be upgradeable, replaceable, and removable if they are purchased/unlocked by the player.

## Movable Versus Fixed Rules

Movable:

- purchased shelves
- purchased wall racks where attached to valid wall zones
- bins
- display tables
- demo tables
- freestanding gondolas
- accessory racks
- later locked/glass cases if purchased by the player

Fixed:

- register/cash wrap anchor
- stock receiving anchor
- backroom/back-alley door
- structural walls
- storefront threshold and entrance
- required utility/operational anchors if a system depends on them

Fixed items may still be upgradeable visually later, but this slice should not treat them as freely movable store fixtures.

## Placement Rules

Fixtures should use snap-to placement.

Required placement behavior:

- snap to grid
- reject collisions with walls, doors, counters, stocked fixtures, and route blockers
- show clear ghost/preview state before placement
- preserve approach positions for stocking and browsing
- keep main routes between entrance, checkout, stockroom, and starter fixtures open
- support wall-attached fixtures only on valid wall spans
- support freestanding fixtures only inside valid floor placement zones

The grid should feel like retail layout assistance, not a visible board-game overlay. Debug grid visuals can exist for development, but the player-facing implementation should be clean.

## Category Labels And Headers

Fixtures should support player-assigned category intent.

Examples:

- New Releases
- Used Games
- Bargain
- Accessories
- Hardware
- Guides
- Trade-In Picks

Label rules:

- labels are small in-world retail signage, not giant debug text
- labels should be readable at normal browsing distance
- labels should attach to a header rail, shelf strip, pegboard plate, or bin card
- labels must not float randomly in the room
- labels should not spawn for future inventory that is not present

Category assignment should drive stocking compatibility where practical. For example, a fixture assigned to Accessories should accept accessories first, while a Used Games fixture should support used-game facings once that system is active.

## Capacity And Product Visibility

Fixtures must expose visible capacity.

Required behavior:

- every stockable fixture has a defined capacity
- capacity should map to visible facings, slots, stacks, hooks, or shelf positions
- empty capacity should look intentionally empty
- placed products should become visible physical objects
- product count should not exceed the visible capacity without a clear overflow rule
- sold or removed products should visibly clear or reduce

The player should be able to understand what a fixture can hold by looking at it. The implementation can start with simplified facings, but the shelf/table/bin must show the item after placement.

## Day-One Fixture State

Day-one should stay lean.

Required:

- checkout exists as an operational anchor, covered in the checkout slice
- wall product fixture exists for initial games/accessories
- demo display exists if required by the starting layout
- fixture capacity is mostly empty
- player places the starting one or two unique games and one starter accessory/console item into valid locations

Avoid:

- fully stocked walls
- bins before the store has bargain/used overflow
- glass cases before hardware stock justifies them
- fixed category zones that block player customization
- many tables before the store has enough product to make them meaningful

## Stockroom And Receiving Relationship

Unlocked or ordered fixtures and products should not appear as future clutter on the sales floor.

Required relationship:

- purchasable fixtures unlock through catalog/progression
- ordered fixtures or products arrive through receiving
- received products enter stockroom/receiving flow before being stocked
- only currently owned and placed fixtures exist on the sales floor
- only physically placed product appears on fixtures

This prevents the store from looking crowded with items the player has not earned or chosen to use.

## Required Modules

Implementation should produce or standardize modules for:

- starter wall shelf
- starter wall rack
- fixture label/header rail
- shelf slot or facing marker
- product placement point
- movable fixture footprint/ghost
- fixture collision/clearance shape
- fixture approach point

Later modules should be planned, but not necessarily implemented in this starter pass:

- bargain bin
- used-game bin
- freestanding display table
- gondola shelf
- accessory pegboard
- locked/glass hardware case
- console demo table

## Likely Scene Files

Likely touched during implementation:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/graybox_store.tscn`
- `game/scenes/world/modules/fixtures/*.tscn`
- `game/scenes/world/modules/signage/*.tscn`
- `game/scenes/world/modules/products/*.tscn`

Exact paths may change if implementation creates a cleaner module folder structure.

## Likely Script Files

Likely touched during implementation:

- fixture placement manager
- fixture catalog or unlock data
- stocking interaction scripts
- inventory/product placement scripts
- save/load serialization for placed fixtures and labels
- UI prompt or tool state for fixture placement

Implementation should prefer existing systems when they already support placement, stocking, inventory, and save/load. This slice is a redesign and stabilization of the visual/fixture layer, not a rewrite of working retail mechanics.

## Data Requirements

Each fixture definition should provide:

- id
- display name
- fixture family
- unlock state
- purchase cost if purchasable
- movable/fixed flag
- valid placement type
- footprint size
- collision shape
- capacity
- supported product categories
- default material/style tier
- optional label/header support
- optional upgrade replacement id

Each stock slot/facing should provide:

- slot id
- local transform
- supported product size/category
- occupancy state
- visible product instance or placeholder state

## Tests To Add Or Update

Later implementation should add or update tests for:

- starter fixtures exist in catalog or module registry
- purchased/unlocked fixtures can be placed on valid snap points
- fixtures reject invalid placement and route blockers
- wall fixtures reject non-wall placement
- fixed anchors are not treated as movable store fixtures
- fixture labels persist through save/load
- stocked products occupy visible capacity slots
- over-capacity stocking is rejected or routed to overflow
- empty fixtures do not show fake product facings

Doc/status tests should include this slice as an active planning document once written.

## Screenshot Targets

Capture these once the implementation exists:

- `fixture_empty_wall_shelf.png`: starter wall shelf/rack empty or mostly empty.
- `fixture_stocked_wall_shelf.png`: one or two starting products visibly placed.
- `fixture_label_assignment.png`: assigned label/header visible on a fixture.
- `fixture_placement_preview.png`: snap preview/ghost before placement.
- `fixture_invalid_placement.png`: blocked placement state near a door/counter/route.
- `fixture_floor_route.png`: view showing entrance, checkout, stockroom route remains open after fixture placement.

## Acceptance Checklist

- [ ] Starter fixtures read as cheap laminate or budget mixed materials, not raw cubes.
- [ ] Day-one fixture set is primarily wall shelves/racks.
- [ ] Starter fixtures begin empty or mostly empty.
- [ ] Player-stocked products are visibly represented on fixtures.
- [ ] Fixture capacity is visible and enforced.
- [ ] Movable fixtures include purchased/unlocked shelves, racks, bins, tables, and cases.
- [ ] Fixed anchors remain fixed where gameplay or architecture requires them.
- [ ] Fixture labels/headers are player-assigned and readable without becoming debug text.
- [ ] Placement snaps to a grid.
- [ ] Placement preserves doors, checkout access, stockroom access, and main routes.
- [ ] Future/locked inventory is not physically staged on the sales floor.
- [ ] Bins, glass cases, and extra tables are treated as later unlocks unless explicitly needed.

## Fail Conditions

This slice fails if:

- the store still reads as scattered primitive boxes
- fixtures are just generic cubes with text labels
- fake product walls appear before inventory exists
- day-one store is overfilled
- players cannot tell where products will go on a fixture
- stocked items do not visibly appear
- fixture labels float in the room
- movable fixtures block essential routes without validation
- the implementation hard-codes permanent category zones that prevent player customization

## Stop/Ask-Owner Conditions

Stop and ask before:

- making glass/locked cases a day-one core fixture
- making bins the primary day-one merchandising fixture
- changing the store fantasy away from cheap underfunded independent retail
- removing player-driven fixture placement/category assignment
- making purchased/unlocked fixtures non-movable

Do not stop for normal fixture shape, material, or layout iteration if the implementation keeps the above rules intact.

## Commit Expectation

Commit the fixture-grid implementation as its own slice after docs, tests, and screenshots are updated.

The commit should be reviewable independently from checkout, product-art, signage, and lighting work unless those are required to make fixture placement function.

## Next Document

After this doc, write `06-checkout-and-trade-in-counter-slice.md` to define the register, trade-in station, behind-counter storage, operational anchors, and counter clutter rules.
