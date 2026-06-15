# Sales Floor And Fixtures Plan

Implementation plan for the first sales-floor quality pass: product density, retail zones, navigation, and fixture language.

## Goal

Make the sales floor feel stocked, navigable, and intentionally merchandised before adding more catalog depth or multi-day playtesting.

## Design Intent

The sales floor should feel like the playable heart of the store. It needs enough physical density to read as retail, but not so much density that prompts, shelf slots, customers, or carry routes become hard to read.

The player should understand:

- Where used games live.
- Where new releases and preorders are promoted.
- Where accessories, bargain stock, staff picks, and impulse stock sit.
- Where customers queue.
- Which fixtures are real, previewed, locked, or decorative.

## References

- `IMG_1044.PNG`: dense shelf-wall read and repeated product spines.
- `IMG_1045.PNG`: compact retail category separation.
- `IMG_1064.PNG`: fixture lanes and backroom/sales-floor transition.
- `IMG_1068.PNG`: accessory and peg-wall density.
- `IMG_1071.PNG`: aisle readability with stocked surfaces.
- `IMG_1074.PNG`: fixture preview and merchandising footprint language.

## Current Implementation State

Implemented in the current branch:

- Used-game wall has repeated spine rows, price tags, category band, and shelf talker.
- Sales floor zones include used wall, new-release endcap, staff picks, accessory peg wall, bargain bin, preorder wall, and register impulse area.
- Fixture system includes ghost, invalid ghost, rotated ghost, and placed fixture screenshot coverage.
- Upgrade-locked fixture goals have physical noninteractive panels for the accessory peg-wall and backroom storage upgrades.
- Scene tests assert density props are non-colliding, near intended zones, and inside the store floorprint.

This establishes the opening-store merchandising baseline. The full catalog pass should add breadth without weakening these route and readability contracts.

## Scope

### In Scope

- Used-game shelf density and shelf-slot readability.
- Starter retail zones for used games, new releases, preorders, accessories, bargain stock, staff picks, services/trade-ins, and impulse stock.
- Navigation routes between entry, shelves, register, receiving, and backroom.
- Fixture placement visual states.
- Screenshot acceptance for `stocked_aisle.png`, `customer_queue.png`, `fixture_placed.png`, `fixture_ghost.png`, `fixture_invalid_ghost.png`, and `fixture_rotated_ghost.png`.

### Out Of Scope

- Full final catalog population.
- Final mesh/art replacement for every product.
- Procedural planogram generation.
- Dynamic customer crowd simulation.
- Store expansion beyond the current opening-store footprint.

## Player Read Contract

From normal player angles:

1. The used-game wall should read as stocked inventory, not isolated blocks.
2. New/preorder/accessory/bargain zones should be visually distinct before reading labels.
3. Customers should have clear queue and browse positions.
4. Carry routes should stay open from receiving to shelf and shelf to register.
5. Fixture preview states should be legible without implying they are ordinary products.

## Implementation Plan

### 1. Used-Game Wall Density

Build requirements:

- Add repeated spine rows that imply many titles without requiring every title to be a unique item.
- Preserve shelf-slot interaction and hover affordance.
- Add a short category header and shelf talker.
- Use price/tag cues to support retail read without making labels too tiny.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/props/placeholder_shelf.tscn`
- `game/scripts/store_layout/shelf_slot.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_shelf_slot.gd`

Tests:

- Assert shelf density cues exist.
- Assert shelf slots remain interactable and category-assigned.
- Assert density props are non-colliding and do not hide prompt/slot cues.

### 2. Starter Retail Zones

Build requirements:

- Used wall anchors the first stocking loop.
- New-release/preorder area previews launch and preorder systems.
- Accessory peg wall and impulse rack preview small-ticket retail.
- Bargain/staff-pick areas add store personality without adding unsupported mechanics.
- Service/trade-in zone cues should point back to the register and service bench, not create new standalone workstations.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/data/fixtures/*.tres`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_fixture_catalog.gd`

Tests:

- Assert each retail zone has a visible cue.
- Assert zone cues use short fictional labels.
- Assert zone cues are placed inside the store floorprint.

### 3. Navigation Preservation

Required clear routes:

- Entry to used shelf.
- Entry to register.
- Shelf to register.
- Receiving to shelf carry route.
- Register queue lane.
- Backroom doorway.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scripts/systems/customer_manager.gd`
- `game/tests/gut/test_customer_manager.gd`
- `game/tests/gut/test_graybox_store.gd`

Tests:

- Assert customer paths validate inside the store.
- Assert buyer queue spacing does not overlap special-customer arc.
- Assert retail clutter stays away from interaction hotspots.
- Assert fixture placement blocks critical path points when invalid.

### 4. Fixture State Language

Fixture states:

- Real fixture: grounded, stocked, and physically readable.
- Valid ghost: transparent/preview language, clear footprint.
- Invalid ghost: visibly rejected through material and placement contract.
- Rotated ghost: orientation is obvious.
- Future/locked fixture: reads as a goal, not a broken object.
- Decorative fixture dressing: noninteractive and clearly secondary.

Implementation files:

- `game/scripts/store_layout/fixture_placement_manager.gd`
- `game/scripts/store_layout/fixture_definition.gd`
- `game/data/fixtures/*.tres`
- `game/tests/gut/test_fixture_placement_manager.gd`
- `game/tests/gut/test_fixture_catalog.gd`
- `game/tests/validation/scenarios/screenshots.json`

Tests:

- Assert ghost visibility, rotation, invalid state, overlap rejection, grid movement, cancel, and confirmation behavior.
- Assert placed fixtures remain inside bounds and do not occupy critical path points.
- Assert screenshot scenarios cover valid, invalid, rotated, and placed states.

## File Impact Matrix

| File | Role | Change Type |
| --- | --- | --- |
| `game/scenes/world/graybox_store.tscn` | Sales-floor props, zones, path cues | Primary implementation |
| `game/scenes/props/placeholder_shelf.tscn` | Shelf slot/product read | Update when shelf affordance changes |
| `game/scripts/store_layout/shelf_slot.gd` | Stocking and slot interaction | Behavior contract |
| `game/scripts/store_layout/fixture_placement_manager.gd` | Fixture preview/placement | Behavior contract |
| `game/scripts/store_layout/fixture_definition.gd` | Fixture metadata | Data contract |
| `game/data/fixtures/*.tres` | Fixture catalog entries | Data implementation |
| `game/tests/gut/test_graybox_store.gd` | Scene density and path assertions | Required |
| `game/tests/gut/test_shelf_slot.gd` | Shelf interaction assertions | Required if shelf changes |
| `game/tests/gut/test_fixture_placement_manager.gd` | Fixture behavior assertions | Required if fixture changes |
| `docs/qa/screenshot-review.md` | Human screenshot review | Update if criteria change |

## Screenshot Acceptance

### `stocked_aisle.png`

Pass criteria:

- Used wall and nearby retail zones read as stocked.
- Product density does not hide shelf prompt, slot identity, or carry route.
- Category signage is short and readable.

Fail criteria:

- Products look like random blocks.
- Shelf interaction is visually ambiguous.
- Aisle density blocks navigation.

### `customer_queue.png`

Pass criteria:

- Buyer queue, special-customer arc, register, and shelf zones remain visually separated.
- Customers read by role prop/silhouette before long text.
- Queue spacing supports register interaction.

Fail criteria:

- Role labels pile up.
- Customer bodies/props block register or shelf targets.
- Queue lane overlaps special-customer positions.

### Fixture Screenshots

Required files:

- `fixture_ghost.png`
- `fixture_invalid_ghost.png`
- `fixture_rotated_ghost.png`
- `fixture_placed.png`

Pass criteria:

- Each state is distinguishable in one glance.
- Placed fixture is grounded and does not dominate the camera.
- Invalid state reads as rejected, not merely unlit.

Fail criteria:

- Ghost/placed/invalid states look interchangeable.
- Placed fixture blocks the screenshot subject.
- Fixture material language conflicts with product or signage language.

## Automated Validation

Required:

```text
scripts/validate_godot.sh
```

Focused checks before full validation:

```text
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit
```

Relevant GUT surfaces:

- `test_graybox_store.gd`
- `test_shelf_slot.gd`
- `test_fixture_placement_manager.gd`
- `test_fixture_catalog.gd`
- `test_customer_manager.gd`
- `test_alpha_regression_coverage.gd`

## Manual Review

Review in this order:

1. `stocked_aisle.png`
2. `customer_queue.png`
3. `fixture_ghost.png`
4. `fixture_invalid_ghost.png`
5. `fixture_rotated_ghost.png`
6. `fixture_placed.png`

Record failures in `docs/production/13-alpha-bug-list.md` with screenshot name, priority, problem, and acceptance check.

## Risks

- Product density can quickly hide interaction prompts.
- Fixture screenshots can pass nonblank checks while still framing the wrong subject.
- Dense retail zones can make the store feel visually busy before the player understands the core loop.
- Decorative props can accidentally look like unsupported interaction targets.

## Completion Criteria

This plan is complete when:

- The sales floor contains readable retail density across the starter zones.
- Fixture state language is implemented and tested.
- Critical player and customer routes remain clear.
- Required sales-floor/fixture screenshots exist and are reviewable.
- Full validation passes.
- Owner screenshot review either approves the sales-floor read or files targeted rework.
