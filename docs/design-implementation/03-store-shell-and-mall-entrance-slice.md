# Store Shell And Mall Entrance Slice

## Goal

Create the first visual slice for the design reset: the player spawns facing the `Games4U` storefront, sees a modest but believable retail entrance, and can walk through an open glass door into the starting store.

The opening does not need to commit to a specific mall type forever. For this slice, use the simplest retail-corridor or mall-concourse setup that looks decent, frames the store clearly, and supports later expansion.

## Player-Facing Result

At game start, the player should see:

- a modest `Games4U` storefront
- open glass entry doors
- a lightly detailed retail corridor or mall concourse
- a few neighboring shops with minimal readable identity
- enough mall detail to sell context without distracting from the store
- no customers
- no employees

The player should immediately understand: this is a small independent game store that is about to open.

## Owner Decisions Captured

- Opening location is flexible: strip mall, standard mall, or retail corridor is acceptable. Pick what is easiest to make look good.
- Player starts facing the storefront.
- Nearby shops should be lightly readable with minimal detail.
- Temporary store name: `Games4U`.
- Glass door starts open.
- Door should support later interactable open/close behavior.
- Entrance mood is modest, not flashy.
- Mall details should be minor: enough context, not a whole mall simulation.
- Opening scene has zero customers and zero employees.
- Customers spawn from off-world only after store open.
- Employees are future unlocks once the store can afford them.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Master Design Source Of Truth](../design-source-of-truth/00-master-design-source-of-truth.md)
- [Asset Inventory Roadmap](../design-source-of-truth/03-asset-inventory-roadmap.md)

This slice provides the visual foundation for:

- [Starting Store Layout Spec](04-starting-store-layout-spec.md)
- [Fixture Grid Slice](05-fixture-grid-slice.md)
- [Signage, Branding, And Store Identity Spec](10-signage-branding-and-store-identity-spec.md)
- [Lighting, Materials, And Color Palette Spec](11-lighting-materials-and-color-palette-spec.md)

## In Scope

- Opening player spawn and first camera direction.
- Retail corridor or mall-concourse shell.
- `Games4U` storefront facade.
- Open glass door and threshold.
- Storefront sign housing.
- Front window/poster bay.
- Minor neighboring shop fronts.
- Minor mall context props.
- Initial floor, wall, ceiling, trim, glass, and lighting treatment.
- Strict collision/navigation around the entry.
- Door structure prepared for later interaction.

## Out Of Scope

- Full mall simulation.
- Customers or employees visible at start.
- Animated crowds.
- Complete neighboring shops.
- Exterior parking lot or large exterior street scene unless it is clearly faster and better.
- Full store interior layout decisions beyond the immediate threshold/first-read support.
- Broad decoration pass.
- Product/platform visual language beyond what is needed to hint that the store sells games.
- Final brand system beyond the temporary `Games4U` sign.

## Required Modules

Build or adapt these module families from the visual module spec:

- `module_mall_floor_tile_strip`
- `module_mall_wall_panel`
- `module_neighbor_storefront_blank`
- `module_neighbor_storefront_closed`
- `module_storefront_facade_games4u`
- `module_storefront_glass_door_open`
- `module_storefront_window_poster_bay`
- `module_storefront_sign_housing`
- `module_threshold_mat`
- `module_storefront_trim_set`
- `module_overhead_mall_light`
- optional `module_mall_railing_segment`
- optional `module_mall_bench_or_planter`
- optional `module_mall_directory_board`

Names may change to match existing repo conventions, but the implementation should preserve these responsibilities.

## Required Storefront Read

The storefront should communicate:

- small independent shop
- modest startup budget
- early-2000s retail
- game-store purpose
- open but not yet operating

Use:

- `Games4U` sign
- glass door/window
- front poster bay
- visible but restrained game-store hints inside
- threshold mat
- trim and sign housing
- non-modern materials

Avoid:

- sterile modern electronics-store facade
- luxury mall boutique read
- huge corporate logo treatment
- fully stocked mature-store read
- debug signs explaining every object

## Mall Context Rules

The mall/corridor exists to frame the store.

Use minor context:

- one or two neighboring storefronts
- simple shop signs or silhouettes
- corridor floor pattern
- wall panels
- overhead lights
- maybe a bench, planter, directory, railing, or shutter

Keep details minimal. The player should not wonder whether the game is about the mall.

Neighboring stores can be fictional and simple:

- apparel shop silhouette
- music/media shop silhouette
- food/snack shop silhouette
- shuttered empty unit

Do not use real brands.

## Spawn And Camera Rules

The player spawn should:

- face the `Games4U` storefront directly
- be far enough back to read the sign, glass, doorway, and a little mall context
- place the door and threshold in the natural forward path
- avoid starting with the player clipped into geometry or staring at a blank wall
- support 1280x720 screenshot review

Suggested first-view composition:

- storefront centered or slightly right of center
- neighboring shop/readable mall detail in peripheral view
- open glass door visible
- interior promise visible through glass
- no NPCs in frame

## Door Rules

For this slice:

- glass door starts open
- collision must not block entry
- door visuals should make open state obvious
- door frame should support later interactable open/close behavior
- node naming should reserve a stable hook for future door interaction

Future behavior:

- player can open/close the door later
- store-open state may control whether customers can enter
- customers spawn off-world only after store open

Do not implement the full future interaction in this slice unless it is trivial and does not distract from the visual pass.

## No-NPC Opening Rule

At scene start:

- no customers visible
- no employees visible
- no mall walkers needed
- no customer queue staged outside
- no staff behind counter

Customer spawning remains tied to store-open gameplay and should originate from off-world spawn paths. Employees are future unlocks, not day-one scenery.

## Likely Scene Files

Likely touched:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/graybox_store.tscn` only if compatibility wrapper needs references updated
- `game/scenes/world/modules/mall/*.tscn`
- `game/scenes/world/modules/shell/*.tscn`
- `game/assets/materials/retail/*.tres`
- `game/assets/textures/retail/*`
- `game/assets/models/retail/*`

Use existing scene structure where practical, but new final-art modules should live under the module folders defined in the visual module spec.

## Likely Script Files

Likely touched only if needed:

- player spawn or store-world setup scripts
- customer manager spawn path scripts if current start-state assumptions expose customers too early
- future door-interaction placeholder script only if adding stable hooks is cleaner than scene-only setup

Do not rewrite core customer, register, receiving, or stocking mechanics for this slice.

## Tests To Add Or Update

Update or add focused GUT coverage for:

- player spawn faces storefront first read
- `Games4U` storefront module exists
- open glass door path is walkable
- starting scene has zero visible customers/employees in the opening view/state
- customer manager still supports off-world/customer-after-open flow
- mall context modules exist but remain nonblocking
- no visible raw CSG/box primitive modules are used for the storefront first-read route
- active docs list includes this slice

Existing screenshot and store-world tests may be updated if they currently assume stale storefront names or old route language.

## Screenshot Targets

Primary:

- `main_scene.png`
- `storefront_entry.png`

Secondary:

- `register_counter.png` only to ensure entry changes do not break interior route
- `stocked_aisle.png` only to ensure storefront changes do not block store access

Manual review:

- 1280x720 real-window first spawn view
- 1280x720 walk forward through doorway

## Acceptance Checklist

Pass only if:

- first view clearly faces `Games4U`
- `Games4U` reads as a modest game store before entering
- storefront has glass, trim, threshold, sign housing, and poster/window treatment
- mall/corridor context is present but minimal
- neighboring shops are lightly readable without stealing focus
- open door path is clear
- player can enter the store naturally
- no customers or employees are visible at start
- customer spawn remains tied to store-open/off-world flow
- visuals are not raw visible primitive boxes
- collision and navigation around the threshold are strict and reliable
- screenshots pass the design-source review criteria

## Fail Conditions

Fail if:

- the storefront still reads like a graybox wall with labels
- the first view is a blank corridor, wall, or confusing angle
- the store looks like a major chain or luxury mall store
- the mall becomes visually louder than the game store
- entry is blocked or awkward
- NPCs are visible before the store opens
- raw primitive geometry is the final visible storefront language

## Stop/Ask-Owner Conditions

Stop and ask if:

- `Games4U` no longer feels like the right working name
- the chosen mall/corridor format cannot look decent quickly
- a strip-mall/exterior setup becomes clearly easier and better than the corridor setup
- door interaction needs a broader gameplay decision
- customer off-world spawn conflicts with existing customer manager assumptions
- navigation clearance prevents a convincing storefront composition

## Commit Expectation

Commit after this slice passes focused tests and `scripts/validate_godot.sh`.

Suggested commit message:

```text
Implement store shell and mall entrance slice
```

## Next Document

After this doc, write `04-starting-store-layout-spec.md` to define the exact store footprint, zone placement, backroom relationship, and day-one density plan.
