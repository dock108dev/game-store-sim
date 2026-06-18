# Checkout And Trade-In Counter Slice

## Goal

Define the opening-store checkout surface as a clean, believable, functional command point without overbuilding it.

The register area should support sales, trade-ins, one customer line, and behind-counter hold/intake storage. It should not become a giant decorative cash-wrap buildout before the store earns that level of complexity.

## Player-Facing Result

At opening setup, the player sees a simple checkout table or modest counter with:

- one register
- scanner
- cash drawer
- bags
- register interaction that supports sales and trade-ins
- a single customer line position
- clean behind-counter space for trade-in intake and held items

The counter should read as functional small-store retail: clean, underfunded, and ready to operate.

## Owner Decisions Captured

- Checkout and trade-ins happen at the same counter.
- Counter placement can be whichever side and exact position works best for layout, routing, and camera readability.
- Do not overcomplicate the starting cash wrap. It is basically a register/scanner setup on a table or modest counter.
- The register should support full required features, including trade-ins.
- Required day-one counter props are register, scanner, cash drawer, and bags.
- Behind-counter storage should largely hold trade-in product that still needs to be stocked, plus consoles/items on hold for future customers.
- Day-one demo item should live in the demo area, not behind the counter.
- Trade-in inspection happens at the counter.
- Customers should use one line.
- Later upgrades can add a second register when employees or demand justify it.
- Starting counter should read clean, not scrappy/busy.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Store Shell And Mall Entrance Slice](03-store-shell-and-mall-entrance-slice.md)
- [Starting Store Layout Spec](04-starting-store-layout-spec.md)
- [Fixture Grid Slice](05-fixture-grid-slice.md)
- [Vertical Slice Specification](../design-source-of-truth/01-vertical-slice-spec.md)
- [Store Design And World Building](../design-source-of-truth/02-store-design-world-building.md)

Feeds:

- [Product And Platform Visual Language Spec](07-product-and-platform-visual-language-spec.md)
- [Required Zones Slice](08-required-zones-slice.md)
- [Density And Clutter Rules](09-density-and-clutter-rules.md)
- [Signage Branding And Store Identity Spec](10-signage-branding-and-store-identity-spec.md)
- [Validation And Screenshot Checklist](12-validation-and-screenshot-checklist.md)

## In Scope

- Define checkout/trade-in as one operational station.
- Define required day-one checkout props.
- Define counter/table scale and clean visual treatment.
- Define one-line customer routing.
- Define behind-counter storage purpose.
- Define trade-in inspection location.
- Define future upgrade direction for second register/employee support.
- Define acceptance checks for visual read and gameplay compatibility.

## Out Of Scope

- Full multi-register checkout bank.
- Employee unlock implementation.
- Complex queue simulation redesign.
- Premium cash-wrap cabinetry.
- Busy counter clutter.
- Behind-counter demo display.
- Mature-store security cage or high-value locked storage.

## Station Model

The opening station is one combined checkout/trade-in station.

Required behavior:

- sales route through the register
- trade-ins route through the same register/counter interaction
- trade-in inspection happens on the customer-facing counter surface
- customer queue uses one line
- the station remains reachable from entrance, sales floor, and stockroom
- checkout does not block the main sales-floor route

The visual target is not a big-box service desk. It should feel like a modest independent shop where one person can run sales, trade-ins, and setup work from the same counter.

## Counter Placement

Counter placement should follow the starting store layout spec:

- against a left or right side wall, whichever works best
- near the middle depth of the store
- close enough to watch the entrance and sales floor
- with a clear route to the stockroom
- with enough customer-side space for one line
- with enough player-side space for register and trade-in interactions

The exact side can be chosen during implementation based on the strongest first-person read and the least route friction.

## Required Day-One Props

Day-one checkout props:

- register
- scanner
- cash drawer
- bags

Prop rules:

- props should be small but readable
- props should sit naturally on or under the table/counter
- props should not be replaced with floating text labels
- scanner and register should align with interaction affordances
- cash drawer can be represented as part of the register/table assembly if needed
- bags should be present but restrained

Optional later props:

- receipt printer
- phone
- price gun
- trade-in pad
- employee second-register setup

Optional later props are not required for the opening baseline.

## Visual Treatment

The checkout should read clean and cheap.

Recommended treatment:

- simple laminate counter or sturdy table
- dark modest base or legs
- clean top surface
- small register/scanner cluster
- subtle bag stack or bag hook
- no excessive papers, signs, or prop spam

Avoid:

- giant black block counter
- oversized signage on the counter face
- clutter piles that hide interaction points
- premium corporate checkout fixtures
- debug labels in place of props

## Behind-Counter Storage

Behind-counter storage should have a specific operational reason.

Primary uses:

- trade-in product waiting to be processed or stocked
- consoles/items on hold for a future customer
- small stack of bags or checkout supply

Rules:

- storage should not become random box clutter
- held/trade-in items should look intentionally staged
- behind-counter items should not duplicate future locked inventory
- storage should not compete with the demo area
- the customer should understand this is employee-side handling space

This area can visually hint at operations without making the store look messy on day one.

## Trade-In Flow

Trade-ins happen at the same counter as checkout.

Expected flow:

1. customer reaches the one line
2. customer steps to the register/counter
3. trade-in product is placed or represented on the counter inspection area
4. register interaction resolves trade-in value and intake
5. accepted trade-in moves to behind-counter intake or stockroom/receiving flow
6. rejected or returned item leaves with the customer

Implementation can use simplified visuals at first, but the counter should visually support inspection rather than making trade-ins feel like a disconnected menu.

## Queue And Upgrade Rules

Day one:

- one line
- one register
- no employee
- no second station

Later upgrades:

- second register can unlock when employees or traffic justify it
- second line should only appear if a second register exists
- added register should respect the same clean visual language
- upgrade should not require redesigning the whole store

This keeps the starting store understandable and leaves room for growth.

## Required Modules

Implementation should produce or standardize modules for:

- checkout table/counter
- register
- scanner
- cash drawer representation
- bag stack or bag hook
- counter interaction point
- trade-in inspection surface
- behind-counter intake/hold shelf or small storage surface
- one-line customer queue marker

Later modules:

- second register upgrade
- employee-side workstation variation
- receipt printer
- phone
- price gun
- hold-tag or processed trade-in marker

## Likely Scene Files

Likely touched during implementation:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/graybox_store.tscn`
- `game/scenes/world/modules/fixtures/*.tscn`
- `game/scenes/world/modules/checkout/*.tscn`
- `game/scenes/world/modules/products/*.tscn`

Exact paths may change if implementation creates a cleaner module folder structure.

## Likely Script Files

Likely touched during implementation:

- register interaction scripts
- trade-in flow scripts
- customer queue/line scripts
- fixture or anchor placement scripts
- save/load state for checkout upgrades
- visual module registration or scene factory scripts

Implementation should preserve existing register, sales, returns, and trade-in mechanics. This slice is about making the physical checkout area believable and coherent.

## Data Requirements

Checkout definition should provide:

- station id
- station type
- fixed or upgrade anchor flag
- interaction point
- customer queue point
- employee/player approach point
- supported workflows
- required props
- optional upgrade slots
- behind-counter storage capacity or role

Behind-counter item state should distinguish:

- trade-in intake
- customer hold
- checkout supply
- decorative filler, if any

Decorative filler should be minimal and should never imply sellable stock that the player does not own.

## Tests To Add Or Update

Later implementation should add or update tests for:

- checkout station exists as the active sales station
- trade-ins route through the same station
- one queue/line is active for the starter counter
- required props exist in the checkout module registry or scene
- demo item is not staged behind counter by default
- behind-counter storage roles are valid
- second register is not active at day one
- second register can be reserved as a later upgrade path
- customer route reaches the counter without blocking entrance or stockroom paths

Doc/status tests should include this slice as an active planning document once written.

## Screenshot Targets

Capture these once the implementation exists:

- `checkout_front_read.png`: customer-side view of the clean register/table setup.
- `checkout_player_side.png`: player-side view showing register, scanner, cash drawer, and bags.
- `checkout_trade_in_counter.png`: counter inspection surface with a trade-in item represented.
- `checkout_behind_counter_storage.png`: held/trade-in items staged behind counter.
- `checkout_customer_line.png`: one-line customer approach clear and unobstructed.
- `checkout_route_to_stockroom.png`: route from checkout to stockroom/backroom remains readable.

## Acceptance Checklist

- [ ] Checkout and trade-ins share one station.
- [ ] Counter placement supports the best layout read and clear routing.
- [ ] Day-one counter has register, scanner, cash drawer, and bags.
- [ ] Counter reads clean and modest, not busy or premium.
- [ ] Trade-in inspection happens at the counter.
- [ ] Behind-counter storage has purposeful trade-in/hold/supply use.
- [ ] Demo item is placed in the demo area, not behind counter.
- [ ] One customer line is active for day one.
- [ ] No second register appears before employee/traffic upgrade logic.
- [ ] Station preserves existing sales, returns, and trade-in mechanics.
- [ ] Counter does not block entrance, fixture browsing, or stockroom route.

## Fail Conditions

This slice fails if:

- checkout becomes a giant black block or generic cube desk
- trade-ins feel disconnected from the physical counter
- multiple customer lines appear before a second register exists
- day-one counter is visually cluttered
- behind-counter storage is random boxes with no role
- demo product is hidden behind counter instead of showcased in the demo area
- props are represented by floating labels instead of readable objects
- counter placement makes the opening store route confusing

## Stop/Ask-Owner Conditions

Stop and ask before:

- adding a second day-one register
- making checkout a large multi-register service desk
- moving trade-ins away from the counter
- making behind-counter storage the primary product display
- adding busy clutter as a substitute for better prop modeling

Do not stop for side-wall selection if the chosen side preserves the layout goals and one-line customer flow.

## Commit Expectation

Commit the checkout/trade-in counter implementation as its own slice after docs, tests, and screenshots are updated.

The commit should be reviewable independently from product-art, required-zone, signage, and lighting work unless those are required to preserve register/trade-in functionality.

## Next Document

After this doc, write `07-product-and-platform-visual-language-spec.md` to define fictional game cases, platform identity, covers, spines, stickers, price strips, and readable shelf facings.
