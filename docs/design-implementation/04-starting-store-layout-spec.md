# Starting Store Layout Spec

## Goal

Define the first playable store layout while preserving proven mechanics.

The current proof of concept established working mechanics. This slice may keep, adjust, or redesign the footprint and world placement if that produces a stronger store. The visual layout must stop reading as a strange half-wall back area and become a believable small game store with a real stockroom, clear sales floor, and configurable player-placed merchandising.

## Player-Facing Result

At the start, the player enters a modest `Games4U` store with:

- a clear sales floor
- a real stockroom/backroom behind a door or doorway
- a checkout counter placed along one side of the room, near the middle depth of the store
- minimal starter inventory
- fixture placement that lets the player decide where used games, new releases, demo, bargain, guides, and other zones live
- no customers or employees before the store opens

The store should feel underfunded and ready to set up, not empty because art is missing.

## Owner Decisions Captured

- Preserve proof-of-concept functionality, but allow the footprint, storefront side, world placement, or store size to change if that materially improves the visual target.
- The store needs a real stockroom, not a half-wall with objects behind it.
- Checkout should be near the middle of the room against the left or right wall, which matches common small game-store layouts.
- Used games wall placement should be customizable by the player.
- New release placement should be customizable by the player.
- Demo, bargain, guides, and other merchandising zones should be guided by player fixture placement.
- Player buys or places a shelf, bin, wall rack, or fixture, labels/assigns it, then stocks games there.
- Backroom/stockroom door should be in one of the back corners.
- Day-one stock is minimal: one demo display, one console, and one or two unique games to start.
- Startup inventory means unique products, not a pile of duplicate copies.
- The sales floor may show the stockroom door/doorway and a basic employees-only sign.
- Customers spawn only after store open.
- Employees are future unlocks once the store can afford them.

## Relationship To Vertical Slice Targets

The vertical slice source of truth names a fuller 40-60 visible game target for a validated slice. This layout spec defines the earliest opening/setup state before the store grows.

Use two density stages:

1. Opening setup state: minimal stock, one demo display, one console, one or two unique games, clear growth space.
2. Later vertical-slice validation state: expanded visible inventory and fixtures after ordering, receiving, buying fixtures, and stocking.

Do not fake day-one fullness with unavailable future inventory.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Store Shell And Mall Entrance Slice](03-store-shell-and-mall-entrance-slice.md)
- [Vertical Slice Specification](../design-source-of-truth/01-vertical-slice-spec.md)
- [Store Design And World Building](../design-source-of-truth/02-store-design-world-building.md)

Feeds:

- [Fixture Grid Slice](05-fixture-grid-slice.md)
- [Checkout And Trade-In Counter Slice](06-checkout-and-trade-in-counter-slice.md)
- [Required Zones Slice](08-required-zones-slice.md)
- [Density And Clutter Rules](09-density-and-clutter-rules.md)

## In Scope

- Preserve the existing gameplay flows and store systems.
- Define sales floor, checkout wall, and stockroom relationship.
- Replace half-wall backroom read with real stockroom architecture.
- Define backroom door/doorway location in a back corner.
- Define initial setup state and starter stock.
- Define player-driven fixture zone rules.
- Define clear routes between entrance, checkout, stockroom, and initial fixtures.
- Define what is visible from the sales floor.

## Out Of Scope

- Multiple stores.
- Broad exterior/mall architecture beyond what is needed to fit the store well in the world.
- Final mature store density.
- Employees.
- Customers before opening.
- Fixed permanent category zones that prevent player customization.
- Full stockroom production art pass beyond the architectural requirement that it is a real room.

## Footprint And World-Fit Rule

Implementation may preserve, adjust, or redesign the store footprint if that produces a better game-store read.

Allowed changes:

- change store size class if the result better fits a small independent shop
- move the storefront to another side
- redesign the sales floor footprint
- create or adjust the surrounding world/global space so the store fits naturally
- change how the store is added into the world
- add a proper stockroom wall/door/doorframe
- move/remove the half-wall that currently makes the backroom feel fake
- adjust local wall segments for entry/stockroom readability
- move existing placeholder fixtures to support the layout

Hard requirements:

- preserve the functioning retail loop
- preserve player movement and interaction
- preserve receiving, stocking, pricing, register, and customer-flow compatibility
- include a real stockroom/backroom function
- keep sales floor zones player-driven through fixture placement

The goal is not to protect the old footprint. The goal is to protect working gameplay while allowing the store shape to become visually credible.

## Sales Floor Zones

The sales floor should not hard-code permanent category zones.

Instead, zones emerge from fixtures:

- wall rack assigned to used games
- wall shelf assigned to new releases
- bin assigned to bargain
- demo display placed by the player
- guide rack placed by the player
- hardware case placed by the player
- accessory pegboard placed by the player

Each fixture should support:

- category assignment or label
- stocking compatibility
- clear approach position
- movement/placement rules where applicable
- later upgrade/replacement

This preserves the sim fantasy: the player designs the store by buying fixtures, placing them, labeling them, and stocking products.

## Checkout Placement

Checkout should be:

- near the middle depth of the room
- against either the left or right wall
- reachable from entrance, sales floor, and stockroom
- visually central enough to feel like the operational command center
- not blocking the main route

The exact left/right wall choice may be based on what best preserves movement and camera readability in the current scene.

The counter should not sit randomly in the center of the room or hide in a back corner.

## Stockroom Placement

The stockroom must read as a real back-of-house room.

Required:

- back-corner door or doorway
- visible frame
- staff-only/employees-only sign or decal
- wall separation that makes the stockroom feel enclosed
- receiving/storage space inside or beyond the doorway
- clear route from checkout to stockroom

Acceptable:

- player can see the doorway from sales floor
- player can see a hint of storage/receiving beyond the threshold
- door can be open for setup workflow

Avoid:

- half-wall divider with random objects behind it
- backroom fully exposed like a sales-floor extension
- stockroom entrance placed where customers naturally path through it
- giant text labels replacing architectural read

## Opening Setup State

The opening setup state should be intentionally minimal.

Required starter content:

- one demo display
- one console/hardware item
- one or two unique games
- enough empty fixture or floor opportunity to show growth
- checkout counter present
- stockroom present
- receiving or setup surface present if mechanics need it

The player should feel like they are setting up a new store for the first time.

Do not represent locked/future inventory as physical stock in the store.

## Customer And Employee Rules

At initial load:

- no customers
- no employees
- no mall walkers required
- no queue outside

After the store opens:

- customers may spawn from off-world
- customers may enter or leave based on normal simulation rules
- customer spawn paths must not require visible waiting customers before opening

Employees:

- future unlocks
- tied to affordability/progression
- not present in the opening scene

## Likely Scene Files

Likely touched during implementation:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/graybox_store.tscn` only for compatibility references if needed
- `game/scenes/world/modules/shell/*`
- `game/scenes/world/modules/counter/*`
- `game/scenes/world/modules/fixtures/*`
- `game/scenes/world/modules/signage/*`

Likely asset folders:

- `game/assets/models/retail/`
- `game/assets/textures/retail/`
- `game/assets/materials/retail/`

## Likely Script Files

Likely touched only if the implementation needs hooks:

- fixture placement manager
- fixture catalog
- store session fixture assignment/category metadata
- customer manager spawn path data
- store-world setup helpers

Avoid changing register, stocking, receiving, or customer-sale core mechanics unless a layout bug requires it.

## Tests To Add Or Update

Future implementation should add or update focused tests for:

- store footprint/world placement supports a believable small game shop
- stockroom has a back-corner door/doorway
- stockroom reads as staff-only architecture
- checkout is against a side wall near middle store depth
- opening setup starts with no customers or employees visible
- starter inventory is minimal and unique-product based
- fixture/category zones are assignable rather than hard-coded
- customer spawn remains off-world/unopened until store-open flow
- stockroom/check-out/entrance routes remain clear
- active docs list includes this layout spec

## Screenshot Targets

Primary:

- `main_scene.png`
- `storefront_entry.png`
- `register_counter.png`
- `receiving_area.png`
- `backroom_summary.png`

Manual review:

- stand at entrance and identify sales floor, checkout, and backroom door
- stand near checkout and identify route to stockroom
- stand at stockroom door and confirm it is a real room/threshold, not a divider line

## Acceptance Checklist

Pass only if:

- footprint and world placement support the store fantasy
- stockroom reads as a real room
- backroom door/doorway is in a back corner
- sales floor is clearly separate from stockroom
- checkout is against a side wall near the middle of the room
- starter store is minimally stocked
- starter products are unique products, not duplicate filler
- used/new/demo/bargain/guides placement is fixture-driven and customizable
- no customers or employees appear before store open
- customers can later spawn from off-world after opening
- navigation between entrance, checkout, stockroom, and initial fixtures is clear

## Fail Conditions

Fail if:

- implementation preserves the old footprint even though it prevents a believable store
- stockroom is still a half-wall or exposed back corner with clutter
- used/new/demo/guides/bargain zones are fixed in a way that blocks player store-design control
- opening stock looks mature or falsely full
- future locked inventory appears physically stocked in the store
- checkout is awkwardly centered or hidden in a back corner
- customers or employees are visible before opening

## Stop/Ask-Owner Conditions

Stop and ask if:

- footprint or world placement changes would break proven mechanics
- checkout placement cannot work on either side wall without route problems
- fixture customization conflicts with current stocking/category mechanics
- customer off-world spawn requires a broader simulation decision
- the minimal-stock start conflicts with a system that assumes many visible products at load

## Commit Expectation

Commit after this slice passes docs review and, when implementation begins later, after focused tests and the agreed validation gate for implementation work.

Suggested implementation commit message:

```text
Implement starting store layout slice
```

## Next Document

After this doc, write `05-fixture-grid-slice.md` to define shelves, racks, bins, placement rules, category labels, and stockable fixture behavior.
