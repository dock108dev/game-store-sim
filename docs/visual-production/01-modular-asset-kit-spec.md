# Modular Asset Kit Spec

## Purpose

This spec defines the production asset approach for the art-language rebuild. The goal is to stop using loose CSG cubes as visible final art and instead build a small set of reusable modules that can be approved in isolation and then instanced into the production scene.

## Folder Layout

Use these folders for the rebuild:

```text
game/scenes/world/art_benchmark/
game/scenes/world/kits/storefront/
game/scenes/world/kits/interior/
game/scenes/world/kits/fixtures/
game/scenes/world/kits/products/
game/scenes/world/kits/backroom/
game/assets/materials/retail/
game/assets/decals/retail/
```

Existing module manifests under `game/scenes/world/modules/` should reference approved kit instances after each kit is integrated.

## Scene Naming

Use descriptive names that encode the role, not the implementation material:

- `storefront_facade_bay.tscn`
- `storefront_glass_door_open.tscn`
- `mall_concourse_slice.tscn`
- `register_counter_kit.tscn`
- `wall_shelf_bay_kit.tscn`
- `product_case_new_game_a.tscn`
- `product_box_console_day_one.tscn`
- `accessory_controller_pack.tscn`
- `receiving_intake_kit.tscn`
- `backroom_staff_threshold_kit.tscn`

Avoid names like:

- `BoxA`
- `PanelThing`
- `BenchmarkCube`
- `SignCard`
- `DebugShelf`

## Module Rules

Each visible kit scene should have:

- a single root `Node3D`
- grouped child nodes by function
- stable named anchors for tests
- collision only where the object should physically block the player
- no large explanatory `Label3D`
- shared materials from `game/assets/materials/retail/`
- optional decal planes for readable visual detail

Each production module should be reusable. If a shape only works from one camera angle and cannot be reused, it belongs in the sandbox until approved.

## Visible Geometry Rules

Allowed visible geometry:

- authored mesh instances
- CSG used sparingly for simple trim, invisible collision, or temporary sandbox proof
- thin planes for decals/posters/stickers
- repeated module scenes
- simple geometry with layered trim and material contrast

Avoid as final route art:

- raw rectangular CSG blocks standing in for all objects
- large floating sign panels explaining zones
- random stacks of boxes to imply detail
- tiny unreadable labels as decoration
- single flat walls/floors/ceilings with no seams, trim, or fixtures

## Shape Language

The reference target is simple but shaped. Every primary module should have a top/middle/base read.

Storefront:

- top: sign housing, neon/LED trim, awning/fascia
- middle: glass, mullions, door, interior hint
- base: threshold, kick plates, storefront base trim

Register:

- top: countertop and equipment silhouettes
- middle: counter face, display case/front shelf
- base: kick panel and floor shadow

Wall shelf:

- top: header/trim or poster band
- middle: product rows
- base: shelf base, lower storage, floor contact

Backroom threshold:

- top: header/soffit
- middle: jambs/wall returns
- base: material transition and utility floor

## Material Families

Create or reuse a small material palette:

- mall floor tile
- mall wall plaster/panel
- storefront metal dark trim
- storefront glass blue-gray tint
- neon/LED cyan accent
- warm interior wall
- dark register laminate
- cream counter top
- cardboard
- product plastic case
- product paper cover
- utility backroom floor
- backroom cool wall

Each material should have a clear purpose. Do not create many nearly identical gray/brown materials.

## Decal And Surface Detail

Use decals or flat planes for:

- poster art blocks
- fictional promo graphics
- game cover color fields
- price stickers
- platform color strips
- condition dots
- small shipping labels
- receipt/invoice paper

Rules:

- Text is optional and should not carry the object identity.
- At 1280x720, decals should read as color/graphic detail even if text is unreadable.
- No third-party brands, real platform marks, streamer references, or licensed covers.
- Use fictional marks and abstract cover layouts.

## Lighting Rules

Lighting should support material read:

- mall concourse: neutral/cool ambient with storefront accent
- storefront glass: cyan/blue trim and interior warmth visible through glass
- register/sales floor: warm retail light
- backroom: cooler utility light
- receiving: practical work light, not dramatic darkness

Avoid:

- one flat global light doing all work
- dark corners that hide products
- overbright signs that become the only readable thing

## Collision And Interaction Rules

Visual modules must not break mechanics:

- retain clear route from mall spawn to threshold
- retain clear route to register
- retain clear route to receiving and backroom computer
- avoid collision on thin decals, trim strips, labels, paper, posters, and small props
- use collision on walls, counter base, shelf body, and real blockers only
- keep interaction targets at existing node paths unless intentionally refactored with test updates

## Extraction Rules

Extract a module when:

- it appears in more than one screenshot
- it is reused in another zone
- it needs independent approval
- it has more than a handful of child nodes
- it is part of the approved art language

Keep local in `store_world.tscn` only when:

- it is a temporary anchor
- it is invisible collision
- it is a one-off scene composition marker

## Test Anchors

Each approved kit should expose stable child names:

- `StorefrontSignHousing`
- `StorefrontGlassBay`
- `StorefrontDoorFrame`
- `RegisterCounterBody`
- `RegisterEquipmentCluster`
- `WallShelfProductRows`
- `DayOneProductSet`
- `ReceivingIntakeSurface`
- `BackroomThresholdFrame`

Tests should assert these anchors exist after production integration.

## Acceptance Bar

A kit is approved only when:

- it reads correctly in the sandbox scene
- it reads correctly in at least one production screenshot
- it does not need a label to explain its purpose
- it does not block player routes or interactions
- it uses shared materials
- it is named and organized for reuse
- it survives `scripts/validate_godot.sh`

## First Kit Build Order

1. `mall_concourse_slice`
2. `storefront_facade_bay`
3. `storefront_glass_door_open`
4. `register_counter_kit`
5. `wall_shelf_bay_kit`
6. `product_day_one_set`
7. `receiving_intake_kit`
8. `backroom_staff_threshold_kit`

Do not build broad catalog variants until this first kit passes owner review.
