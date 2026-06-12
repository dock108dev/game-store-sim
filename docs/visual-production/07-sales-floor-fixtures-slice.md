# Sales Floor Fixtures Slice

## Implementation Status

Implemented for owner review. Current scene surfaces include wall shelf facing, restrained day-one shelf capacity, accessory peg wall, locked/glass case cue, empty growth space, and fixture-placement footprint cues.

## Goal

Make the sales floor feel stocked and browsable.

This slice should make product density and platform/category organization the primary visual read.

## Scope

In scope:

- Main used-game wall.
- One center aisle/gondola or faceout fixture.
- New-release area.
- Bargain bin.
- Accessory pegboard.
- Shelf strips and price tags.
- Product density rules.

Out of scope:

- Full catalog expansion beyond existing data.
- Procedural shelf generation unless needed after hand-authored slice proves the target.

## Assets Needed

- Wall shelf module.
- Gondola/center fixture.
- DVD-case rows.
- Cartridge/box rows.
- Faceout display cases.
- Bargain bin mesh.
- Accessory pegboard hooks.
- Boxed controller/accessory props.
- Platform/category shelf strips.
- Price sticker decals.

## Implementation Files

Likely affected:

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/store_layout/display_rack.tscn`
- `game/scenes/store_layout/shelf_slot.tscn`
- `game/scripts/inventory/product_item.gd`
- `game/tests/gut/test_shelf_slot.gd`
- `game/tests/gut/test_product_item.gd`
- `game/tests/gut/test_graybox_store.gd`

## Acceptance Screenshots

- `stocked_aisle.png`
- `fixture_placed.png`
- `main_scene.png`
- `customer_queue.png`

## Pass Criteria

- Shelves read as many game cases, not a few blocks.
- Platform/category differences are visible without real brands.
- Price/condition tags are readable enough at first-person distance.
- Fixture density does not block prompts, slots, or paths.
- Placed fixtures look grounded and intentional.

## Fail Criteria

- Product density still reads abstract.
- All shelves look identical.
- Product tags become noise.
- Customers and fixtures visually collide.
