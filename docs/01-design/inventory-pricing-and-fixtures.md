# Inventory, Pricing, And Fixtures

## Inventory Philosophy

Inventory is the heart of the game. Items are not abstract stock counts.

One copy of one game is one physical item with its own:

- object in the world
- identity
- condition
- price
- location
- sale history
- optional metadata

If the store has ten copies of the same fictional game, the player should be able to see roughly ten physical cases on the shelf.

## Item Categories

First playable categories:

- used game case
- new game case
- boxed accessory, optional

Future categories:

- hardware box
- loose disc
- cartridge
- guide/media item
- preorder card
- service item
- suspicious goods
- rare display item

## Fictional Product Rules

Products must be fictionalized.

Allowed:

- era-inspired box shapes
- fictional platform names
- fictional genres
- fictional release stickers
- fictional publisher marks

Not allowed:

- real game titles
- real platform names
- copied cover art
- copied store branding
- parody names that are too close to real products

## Item State

Each physical item should track:

- `item_id`
- `product_id`
- `display_name`
- `platform_id`
- `category`
- `condition`
- `new_or_used`
- `cost_basis`
- `current_price`
- `suggested_price_min`
- `suggested_price_max`
- `fixed_price_until_date`, for new goods
- `location_type`
- `location_id`
- `slot_id`
- `provenance_state`
- `is_sellable`
- `is_sold`

## Pricing Rules

### Used Goods

Used goods support player pricing.

The pricing panel should show:

- item name
- platform
- condition
- cost basis
- suggested price range
- current price
- margin
- warning if below cost
- warning if above suggested range

Suggested pricing should help the player without fully automating the decision.

### New Goods

New goods use fixed pricing while considered new.

Rules:

- price cannot be edited in the first playable
- the UI should show why it is fixed
- fixed pricing should feel like normal distributor/retail contract behavior

Later, when a product is no longer considered new, it can become eligible for discounting or clearance rules.

## Fixture Philosophy

Fixtures are gameplay objects, not decoration.

They define:

- where stock can live
- what customers can browse
- how dense the store feels
- how clear the layout is
- how the business identity reads

## First Playable Fixture Types

Required:

- wall shelf or rack for game cases
- freestanding shelf or gondola
- checkout counter

Recommended if cheap:

- small glass display case
- wire-grid rack
- receiving table

## Shelf Slots

Slots should be authored data.

Each slot should know:

- accepted item categories
- local position
- local rotation
- max stack/display count if using grouped visuals
- item id occupying it

The interaction model can support snapping. The player should not need perfect physics placement for every case.

## Visual Count Rule

The shelf must communicate approximate stock count.

Examples:

- one item: one visible case
- two to five items: a small row
- ten items: visibly dense row
- full shelf: clearly full

The internal simulation still tracks individual items.

## Placement Rules

Valid placement:

- shelf accepts category
- slot is empty or supports row insertion
- player is close enough
- item is sellable or allowed as display

Invalid placement:

- wrong category
- blocked fixture
- no slot available
- placing through wall
- placing in unreachable area

## Inventory Locations

Required first playable locations:

- shipment box
- player hand
- shelf slot
- counter/register transaction
- sold/out of store
- backroom floor or table

Future locations:

- backstock shelf
- quarantine shelf
- service bench
- customer hand
- display case
- supplier return box

## Stocking Feedback

Stocking should provide quiet feedback:

- snap sound
- subtle highlight on valid slot
- shelf count/state update
- item price sticker visible if possible

Avoid excessive tutorial text.

