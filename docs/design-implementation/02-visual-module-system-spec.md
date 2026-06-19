# Visual Module System Spec

## Purpose

This spec defines the reusable construction language for the design reset.

Current note: `docs/visual-bible/` supersedes this spec wherever art quality, object-family detail, or production-method expectations conflict.

The goal is a major visual increase. We are not constrained to Godot-native primitives if another workflow produces a stronger result. Godot remains the runtime and integration surface, but authored meshes, Blender-made assets, bitmap textures, and imported modular kits are allowed when they improve the store read.

## Target Read

Original packet target language is retained for history. Current target is polished stylized indie with early/mid-2000s retail inspiration and Blender-authored MVP assets.

The historical visual target was late-PS2-era 3D retail:

- simple geometry with intentional silhouettes
- strong readable shapes
- modest polygon budgets
- bitmap texture detail
- stylized but grounded proportions
- visible material changes between carpet, slatwall, glass, metal, laminate, plastic, paper, and cardboard
- dense enough to feel like a real early-2000s game store
- clean enough that player movement and interaction remain reliable

The target is not photorealism, modern high-end rendering, or raw prototype geometry.

## Production Workflow Policy

Allowed workflows:

- Godot scenes composed from imported meshes
- Blender-authored modular meshes
- Godot-native helper scenes for collision, anchors, interaction points, and placement logic
- bitmap textures for surfaces, signs, product covers, stickers, posters, and decals
- reusable material resources shared across modules

Disallowed as final visible art:

- raw CSG or box primitives used as primary visible objects
- visible debug labels used to explain object identity
- untextured flat gray planes as final walls, floors, ceilings, fixtures, or props
- loose rectangle clutter that does not read as a specific retail object

Hidden collision helpers, occluders, triggers, anchors, and editor-only guide nodes may use primitive shapes if they are not part of the visible final presentation.

## Module Philosophy

Prefer modular, reusable pieces that can be upgraded, replaced, removed, or rearranged later.

The system should support:

- day-one underfunded store state
- later fixture upgrades
- fixture replacement
- removable or reconfigurable display pieces
- progression from sparse startup to dense mature store
- future store layout adjustments without rebuilding every asset

Do not create one-off decorative chunks when a reusable module would support growth, upgrades, or stocking.

## Module Granularity

Use a hybrid approach:

- Small reusable modules for fixtures, trim, product facings, signs, lights, wall panels, doors, shelves, counters, bins, racks, and clutter.
- Medium authored chunks for storefront facade assemblies, checkout counter assemblies, demo kiosk assemblies, and wall-section presets.
- Avoid large whole-room chunks unless they are pure background mall architecture with no gameplay interaction.

Rationale:

- Small modules support upgrades and replacement.
- Medium chunks preserve visual cohesion where many pieces need to align.
- Whole-room chunks make future gameplay/layout changes harder.

## Grid And Scale Standard

All modules should follow a consistent grid.

Base units:

- 1 Godot unit = 1 meter.
- Primary placement grid: 0.5 meters.
- Fine detail grid: 0.25 meters.
- Tiny detail may be off-grid only when it is attached to a parent module and has no collision.

Recommended dimensions:

| Module Type | Preferred Width | Preferred Depth | Preferred Height |
| --- | ---: | ---: | ---: |
| Wall panel | 2.0 m | 0.1-0.2 m | 3.0 m |
| Slatwall bay | 1.0-2.0 m | 0.08-0.16 m | 2.2-2.6 m |
| Wall shelf bay | 1.0-2.0 m | 0.35-0.55 m | 1.8-2.2 m |
| Gondola bay | 1.0-2.0 m | 0.75-1.0 m | 1.2-1.6 m |
| Endcap | 0.75-1.0 m | 0.45-0.75 m | 1.2-1.6 m |
| Checkout counter module | 1.0-1.5 m | 0.65-0.9 m | 0.95-1.1 m |
| Product facing block | 0.12-0.2 m | 0.02-0.06 m | 0.18-0.28 m |
| Poster frame | 0.45-0.75 m | 0.02-0.05 m | 0.65-1.1 m |
| Header sign | 0.75-2.0 m | 0.04-0.12 m | 0.25-0.45 m |

Exact dimensions may change per asset, but modules should snap predictably and avoid fractional scene drift.

## Navigation And Collision Rules

Navigation clearance is strict for now.

Minimum clearances:

- Primary customer/player paths: 1.2 m minimum.
- Secondary browse aisles: 0.9 m minimum.
- Behind-counter player route: 0.75 m minimum.
- Door threshold clear width: 0.9 m minimum.
- Interaction standing position: 0.6 m radius clear.
- Carry/stocking approach position: 0.75 m radius clear.

Collision rules:

- Major fixtures need simple collision shapes.
- Small decorative props should usually have no collision.
- Product facings should not block movement.
- Hanging signs, posters, trim, decals, price strips, and paper details should not have collision.
- Every interactable module needs a clear approach point.
- No visual module may block existing core routes unless the gameplay route is intentionally redesigned and validated.

## Required Module Families

### Store Shell Modules

Needed for the first-read pass:

- storefront glass door
- storefront window bay
- mall-side facade panel
- store logo sign housing
- threshold mat
- low-pile carpet floor tile
- ceiling tile/light grid
- slatwall back wall bay
- slatwall side wall bay
- cash wrap wall panel
- backroom doorway/frame

### Fixture Modules

Needed for floor and wall merchandising:

- wall game shelf bay
- double-sided gondola bay
- narrow endcap display
- used-game wall bay
- new-release shelf bay
- wire accessory pegboard
- glass hardware case
- strategy guide rack
- bargain dump bin
- portable game case rack
- controller hanging rail
- memory card peg rail
- clearance shelf

### Counter Modules

Needed for operations:

- main checkout counter
- trade-in intake counter
- corner counter connector
- register terminal
- receipt printer
- barcode scanner
- price gun
- inspection pad
- used sleeve box
- trade-in tote
- behind-counter drawer bank
- counter impulse rack

### Product Modules

Needed for recognizable inventory:

- standard game case mesh
- used game case variant
- loose disc sleeve
- loose cartridge/card package
- boxed hardware package
- accessory blister/card package
- strategy guide/magazine
- price sticker
- used sticker
- clearance tag
- platform divider

### Signage And Marketing Modules

Needed for world readability:

- platform header sign rail
- shelf price strip
- coming soon board
- new release poster frame
- preorder poster frame
- clearance tag set
- employee pick card
- store policy card
- hours decal
- open/closed sign

### Mall Context Modules

Needed for the opening route:

- mall floor tile strip
- railing segment
- neighboring storefront blank bay
- closed neighboring storefront shutter
- bench or planter silhouette
- overhead mall light
- directory/poster board

Mall context should support the storefront read without becoming a second game.

## Bitmap Texture Policy

Bitmap textures are preferred for the visual reset.

Use bitmaps for:

- carpet pattern
- slatwall grooves
- laminate counter surfaces
- worn shelf edges
- product covers and spines
- sticker sheets
- platform symbols
- posters
- paper clutter
- cardboard labels
- glass smudges/subtle reflections

Texture style:

- readable at 1280x720
- period-authentic without real brands
- slightly imperfect
- not over-detailed
- no photoreal scans of real copyrighted products

Recommended starting sizes:

- large surfaces: 512x512 or 1024x1024
- product covers/posters: 256x256 or 512x512
- sticker/label sheets: 256x256
- tiny props: share atlas textures where possible

## Material Rules

Every visible module should use a named material or texture set.

Material families:

- `retail_carpet_*`
- `retail_slatwall_*`
- `retail_laminate_*`
- `retail_black_metal_*`
- `retail_plastic_*`
- `retail_cardboard_*`
- `retail_paper_*`
- `retail_glass_*`
- `retail_signage_*`
- `retail_product_*`

Avoid one-off unnamed materials unless generated by import and then cleaned up.

## Upgradeable/Replaceable Rules

Fixtures should be built as replaceable modules even when the first implementation places them by hand.

Each upgradeable fixture should expose:

- stable root node name
- category/purpose metadata
- footprint dimensions
- collision shape
- stocking surface anchors when applicable
- product-facing anchors when applicable
- interaction anchor when applicable
- visual variant hook
- upgrade tier hook

Examples:

- cheap wall shelf -> better wall shelf -> premium wall shelf
- starter gondola -> expanded gondola -> lit gondola
- basic counter -> L counter -> service/trade-in counter
- starter demo kiosk -> upgraded demo station

## Scene Organization

Recommended folders:

```text
game/scenes/world/modules/shell/
game/scenes/world/modules/fixtures/
game/scenes/world/modules/counter/
game/scenes/world/modules/products/
game/scenes/world/modules/signage/
game/scenes/world/modules/mall/
game/assets/models/retail/
game/assets/textures/retail/
game/assets/materials/retail/
```

Scene naming:

- `module_storefront_glass_door.tscn`
- `module_wall_slatwall_bay.tscn`
- `module_fixture_gondola_basic.tscn`
- `module_counter_checkout_basic.tscn`
- `module_product_game_case_nova.tscn`
- `module_sign_platform_header_nova.tscn`

Use clear names over clever names.

## Node Organization

Recommended module structure:

```text
ModuleRoot
  Visuals
  Collision
  Anchors
  Interaction
  Metadata
```

Rules:

- `Visuals` contains visible meshes, decals, and lights.
- `Collision` contains simple collision helpers.
- `Anchors` contains placement, stocking, product-facing, and approach markers.
- `Interaction` contains interactable nodes if the module is interactive.
- `Metadata` may contain scripts/resources describing footprint, tags, category, tier, and validation hints.

## Level-Of-Detail And Performance

The first goal is visual quality, but modules must remain practical.

Guidelines:

- Prefer simple silhouette meshes with bitmap detail.
- Use atlases for repeated products, stickers, and small paper clutter.
- Avoid per-object lights except for important fixtures or signs.
- Keep transparent glass reasonable and limited.
- Batch repeated product facings where possible.
- Use real separate interactable items only where gameplay needs them.
- Use non-interactive visual facings to represent density when needed.

## Visual Facing Versus Gameplay Item

A visible product does not always need to be a full gameplay item.

Allowed:

- interactive stocked item for products the player can pick up, price, stock, sell, or inspect
- non-interactive product facing for shelf density
- locked display item behind glass
- decorative package in a window or poster display

Rules:

- Interactive stock must align with actual inventory mechanics.
- Non-interactive facings must not imply a product is available if gameplay says it is locked or unavailable.
- Future inventory should appear in catalogs, posters, coming-soon boards, or locked previews, not as physical stock ready to sell.

## Acceptance Checklist

The visual module system is acceptable when:

- modules can be assembled into the opening store without raw visible primitive geometry
- every major visible surface has material or bitmap texture treatment
- fixture modules preserve strict navigation clearances
- shelves/counters/products can support future replacement or upgrade
- repeated modules snap to a shared grid
- product facings can create density without breaking inventory logic
- storefront, fixture, counter, product, signage, and mall module families have clear implementation rules
- agents can build future slice packets without inventing a new art language

## Stop Conditions

Stop and ask for owner or lead review if:

- a module needs a real-world brand-like visual reference to read correctly
- a desired asset would require a workflow the repo cannot import or validate
- strict navigation clearance prevents the intended density
- Blender/modeling workflow setup becomes a blocker
- a module requires changing core mechanics rather than replacing visuals
- the late-PS2 visual target is not achievable with the current asset approach

## Open Follow-Up

The next document, `03-store-shell-and-mall-entrance-slice.md`, should decide how the player first sees the store, how the mall concourse frames it, and what the storefront must communicate before the player enters.
