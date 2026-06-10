# Sales Floor And Fixtures Plan

Implementation plan for the first sales-floor quality pass.

## Goal

Make the sales floor feel stocked, navigable, and intentionally merchandised before adding more day-loop playtesting.

## References

- `IMG_1044.PNG`
- `IMG_1045.PNG`
- `IMG_1064.PNG`
- `IMG_1068.PNG`
- `IMG_1071.PNG`
- `IMG_1074.PNG`

## Build Tasks

1. Used-game wall/rack density.
   - Add repeated spine language.
   - Preserve shelf-slot interaction.
   - Add category header and short shelf talkers.

2. Starter retail zones.
   - Used games.
   - New releases/preorders.
   - Accessories.
   - Services/trade-ins.
   - Bargain or impulse area.

3. Navigation preservation.
   - Entry-to-shelf route.
   - Shelf-to-register route.
   - Receiving-to-shelf carry route.
   - Register queue lane.
   - Backroom doorway.

4. Fixture system language.
   - Define visual difference between real fixture, preview fixture, locked future fixture, and noninteractive dressing.
   - Keep fixture placement ghost color language consistent.

## Files To Expect

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/props/placeholder_shelf.tscn`
- `game/scripts/store_layout/shelf_slot.gd`
- `game/scripts/store_layout/fixture_placement_manager.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_shelf_slot.gd`
- `game/tests/gut/test_fixture_placement_manager.gd`

## Acceptance

- `stocked_aisle.png` reads as stocked retail, not scattered blocks.
- `customer_queue.png` keeps customers, queue, and shelf zones visually separate.
- `fixture_placed.png` shows a grounded placed fixture, not a camera-blocking slab.
- No density hides prompts, product labels, shelf slots, or customer paths.

## Test

- Run relevant GUT tests for scene, shelf slot, fixture placement, and customer manager.
- Run `scripts/validate_godot.sh`.
- Review sales-floor screenshots at 1280x720.
