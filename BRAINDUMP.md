# Braindump

## Next Focus: Polished Solid Defaults

The next braindump should focus on replacing the current "basic default"
objects with solid, finished-feeling starter versions. The goal is not luxury
or late-game upgrades. The goal is that the first playable store already looks
intentional, readable, and worth interacting with.

Right now the store has the correct zones and rough silhouettes, but too many
required objects still read like placeholders: register, stock room, tables,
shelves, game cases, console boxes, and other default props. The next pass
should make these fundamentals feel like finished baseline assets.

## Principle

Every default object should answer three questions from first-person view:

- What is this?
- Can I use it?
- Does it belong in this store?

If an object is required for Day 1 or the first sale loop, it should not look
temporary. It can still be low-poly and budget-store, but it needs shape,
material contrast, useful details, and a clear interaction side.

## Default Asset Targets

### Register / Checkout

The checkout counter should be a complete retail station, not just a table with
small props on it.

Needed:

- solid counter body with front/customer side and staff side
- register terminal with readable screen angle
- cash drawer or drawer seam
- receipt printer
- card reader
- small cable/detail pieces so the station feels assembled
- clear customer handoff zone
- interaction highlight that lands on the register, not random desk clutter

The manager checkout area should look like a real place to talk and transact.
It should carry the first-day instruction visually before the prompt text does.

### Stock Room / Back Room

The stock room should read as a working storage area from the doorway.

Needed:

- stronger shelving units with real uprights, cross braces, shelf thickness,
  and visible inventory boxes
- labeled stock bins or cartons
- receiving table or sorting bench
- a clear pickup/restock interaction target
- floor dressing that separates stock room from sales floor
- enough silhouette variety that it does not look like a wall plus cubes

The player should be able to glance in and understand: this is where unshelved
inventory lives.

### Basic Table

The starter table should look sturdy and intentional.

Needed:

- thicker tabletop with bevel or rim
- visible legs that connect cleanly
- underside support rails
- small price tags, risers, trays, or display mats
- product placement zones that feel deliberate
- front-facing composition for first-person inspection

The table should support gameplay readability: product, price, and interaction
target should not visually merge.

### Basic Shelf

The default shelf is a core gameplay object and needs to look like a stocked
retail fixture.

Needed:

- proper side panels or uprights
- shelf thickness and back panel
- front lips or label rails
- slot markers that look like tags, not debug strips
- a few always-visible product silhouettes
- empty-state version that still looks intentional
- stocked-state version with clear item count/readability

The shelf should be recognizable from across the store and satisfying up close.

### Basic Game / Cartridge / Case

The default game product should feel like a real collectible object, even when
generic.

Needed:

- distinct case/cartridge shape
- front label color block
- title stripe or icon shape
- spine/edge detail for shelf readability
- slight thickness and shadow separation
- clean scale relative to table and shelf

Default games can use fictional labels, but they should not read as plain flat
rectangles.

### Basic Console / Console Box

The default console should feel like merchandise, not a generic cube.

Needed:

- console box with lid/flap seams
- front branding band or icon panel
- side label/spine
- optional controller silhouette or cable line
- color/material difference between box, label, and shadow
- size variation from game cases

The player should be able to tell "console" versus "game" without reading UI.

### Basic Display Props

Small default props should help the store read better rather than become visual
noise.

Useful defaults:

- price tags
- shelf labels
- small acrylic stands
- controller bin
- repair/testing mat
- clipboards or intake slips
- taped box labels
- small security tag blocks

These should be reusable kit pieces that upgrade the whole store when placed
consistently.

## Visual Bar

The assets should stay low-poly and performant, but the default level should
feel "shippable starter store," not "greybox with labels."

Minimum bar:

- readable silhouette from 6-10 meters
- clean material separation
- no wafer-thin furniture
- no floating props
- no ambiguous interaction side
- no blank cube products
- no single-color blocks where a label, trim, or seam would solve readability

## First-Day Store Pass

The first-day flow should be reviewed through the default-object lens:

- approach checkout and see a finished register station
- look toward the sales floor and recognize shelf/table stock
- enter stock room and recognize back-room inventory
- inspect a game and understand it is a product
- inspect a console and understand it is a higher-value product
- stock shelf without the shelf looking like a debug fixture
- complete first sale with checkout area visually supporting the moment

The store can still feel humble and early. It should not feel unfinished.

## Suggested Implementation Shape

Build a small "starter retail kit" instead of polishing one-off scene blobs.

Kit pieces:

- `starter_checkout_counter`
- `starter_register_terminal`
- `starter_card_reader`
- `starter_receipt_printer`
- `starter_wall_shelf`
- `starter_gondola_shelf`
- `starter_display_table`
- `starter_stockroom_shelf`
- `starter_receiving_table`
- `starter_game_case`
- `starter_cartridge`
- `starter_console_box`
- `starter_price_tag`
- `starter_shelf_label`

These should become the default Day 1 objects. Later upgrades can add better
materials, lighting, and premium variants, but the defaults need to be solid
enough that screenshots already sell the loop.

## Acceptance Feel

When taking screenshots of the first-day store, the reaction should be:

"This is a small starter game shop that is already usable and coherent."

Not:

"This is a placeholder store waiting for art."
