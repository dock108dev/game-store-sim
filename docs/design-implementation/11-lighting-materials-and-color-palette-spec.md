# Lighting Materials And Color Palette Spec

## Goal

Define the lighting, materials, and color behavior for the opening store reset.

The store should read as a bright early-2000s mall game shop: practical retail fluorescent lighting, firm commercial carpet, clean light walls, editable color panels, cheap laminate fixtures, and product/poster color doing much of the visual work. The mall should be warmer than the store so the storefront feels brighter and more operational when entered.

## Player-Facing Result

At opening setup, the player sees:

- a bright, readable retail store
- warmer mall concourse lighting outside the store
- firm commercial carpet underfoot
- clean light walls with editable paintable color panels
- cheap laminate and black-metal starter fixtures
- a default editable color palette
- product cases, posters, signs, and demo screens providing controlled color accents
- demo/console screen light that comes from actual display surfaces, not fake glow effects

The store should feel clear and usable. It should not feel graybox-flat, dark, beige, neon, or modern showroom sterile.

## Owner Decisions Captured

- Store lighting should be bright.
- Mall concourse lighting should be warmer than store lighting.
- Flooring should feel like firm commercial carpet.
- Walls should be clean and light.
- Walls can include paintable color panels.
- Starter fixtures should continue to use cheap laminate and black metal.
- Color palette should have a default, but it should be editable.
- Demo/console areas can get light from display screens.
- Do not add fake glow just to make demo areas pop.
- No hard banned color/material list was requested beyond avoiding bad visual read through review.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Store Shell And Mall Entrance Slice](03-store-shell-and-mall-entrance-slice.md)
- [Starting Store Layout Spec](04-starting-store-layout-spec.md)
- [Fixture Grid Slice](05-fixture-grid-slice.md)
- [Product And Platform Visual Language Spec](07-product-and-platform-visual-language-spec.md)
- [Density And Clutter Rules](09-density-and-clutter-rules.md)
- [Signage Branding And Store Identity Spec](10-signage-branding-and-store-identity-spec.md)
- [Store Design And World Building](../design-source-of-truth/02-store-design-world-building.md)

Feeds:

- [Validation And Screenshot Checklist](12-validation-and-screenshot-checklist.md)
- [Agent Work Packet Template](13-agent-work-packet-template.md)
- [Phase Implementation Roadmap](14-phase-implementation-roadmap.md)

## In Scope

- Define store lighting target.
- Define mall/store lighting contrast.
- Define floor material target.
- Define wall material and editable color-panel target.
- Define starter fixture material target.
- Define default/editable palette behavior.
- Define demo/display light rules.
- Define screenshot review criteria for brightness, contrast, and material read.

## Out Of Scope

- Final shader implementation details.
- Full post-processing policy.
- Advanced dynamic lighting.
- Night/closed-store lighting pass.
- Final mature-store decoration palette.
- Full material library for every future unlock.
- Photoreal material simulation.

## Lighting Direction

The store should be bright retail.

Required:

- clear visibility across the sales floor
- readable products, labels, and register area
- no moody darkness as the primary store look
- no excessive contrast that hides shelves or routes
- bright enough for 1280x720 screenshots to read

Recommended store light feel:

- fluorescent retail ceiling lights
- practical overhead light banks
- mild cool/neutral store tone
- limited shadow heaviness
- no dramatic spotlight-only setup

The store lighting is functional first. Mood comes from products, posters, signage, and layout, not from making the room dark.

## Mall Lighting Contrast

The mall concourse should be warmer than the store.

Purpose:

- make the mall feel slightly more ambient
- make the store feel brighter and more operational
- separate exterior concourse from interior retail space
- preserve the storefront as the visual focus

Rules:

- mall is warm/neutral, not orange or dark
- store is brighter and cleaner
- transition through glass/storefront should be readable
- neighboring store signs should remain flavor, not bright distractions

## Flooring

Flooring should feel like firm commercial carpet.

Rules:

- low/firm pile visual
- not plush residential carpet
- not polished modern showroom floor
- not raw flat gray plane
- should support early-2000s mall specialty-store read
- can use subtle pattern, flecking, or low-contrast texture

Flooring should help the store feel finished without becoming visually loud.

## Walls And Color Panels

Walls should be clean and light.

Required:

- light base wall material
- no raw prototype gray
- no blank infinite plane feel
- readable corner/trim separation
- paintable color panels where useful

Paintable panel rules:

- default palette exists
- player can later edit/replace colors where supported
- panels should not dominate the room
- panels can help define store identity without forcing permanent category zones
- panels should work with signage/posters/products instead of fighting them

The walls are a calm retail backdrop. Product covers, posters, signs, and fixtures carry most of the color.

## Fixture Materials

Starter fixtures use cheap laminate and black metal.

Rules:

- laminate surfaces should have subtle material treatment
- black metal supports should read as frames/legs/rails
- fixture edges should not look like unmodified cubes
- materials should support modular upgrades and replacement later
- starter fixtures should feel affordable and practical

Avoid:

- premium glass/wood everywhere at day one
- raw black block counters
- untextured primitive shelves
- overly glossy modern fixtures

## Palette Rules

The store should have a default palette, but it should be editable.

Default palette role:

- provide coherent initial store identity
- support readable signage and product displays
- keep wall/fixture/background colors restrained
- leave room for products and posters to provide stronger accents

Editable palette role:

- future customization
- color-panel updates
- store identity upgrades
- player preference

Rules:

- palette is not hard-locked
- products/platforms/genres keep their own color systems
- signage remains readable against editable panels
- fixtures remain readable against flooring/walls
- avoid one-note monochrome rooms during implementation review

## Demo And Screen Light

Demo/console areas can have screen-driven light.

Allowed:

- display screen material emits or appears bright
- nearby area reflects the presence of an active screen subtly
- CRT/demo screen can create a local visual focal point

Avoid:

- fake glow unrelated to an actual display surface
- oversized bloom that washes out products/signage
- neon underlighting as a shortcut for visual interest
- making demo brighter than the store’s main readability

The demo area should be noticeable because it has a screen and hardware, not because of artificial glow spam.

## Material Hierarchy

Use materials to clarify function.

Suggested hierarchy:

- mall floor/walls: warm, neutral, background
- store walls: clean light base with editable panels
- store carpet: firm commercial texture
- fixtures: cheap laminate with black metal
- register/table: clean laminate or modest counter material
- products: strongest color/detail concentration
- signage/posters: controlled readable accents
- stockroom: more utilitarian but still finished

This hierarchy should help every screenshot read quickly.

## Required Modules

Implementation should produce or standardize modules/materials for:

- store fluorescent light bank
- mall warmer light module
- commercial carpet material
- clean light wall material
- editable wall color panel material
- cheap laminate fixture material
- black metal frame material
- demo display screen material
- material/palette data binding

Later modules:

- upgraded fixture materials
- alternate wall panel color sets
- store identity palette presets
- closed-store/dim lighting state
- mature-store accent lighting

## Likely Asset Files

Likely created or updated:

- `game/assets/materials/store/*.tres`
- `game/assets/materials/mall/*.tres`
- `game/assets/materials/fixtures/*.tres`
- `game/assets/materials/lighting/*.tres`
- `game/assets/textures/flooring/*.png`
- `game/assets/textures/walls/*.png`
- `game/assets/data/palettes/*.json`

Exact paths may change if implementation creates a cleaner asset folder structure.

## Likely Scene Files

Likely touched during implementation:

- `game/scenes/world/modules/lighting/*.tscn`
- `game/scenes/world/modules/storefront/*.tscn`
- `game/scenes/world/modules/fixtures/*.tscn`
- `game/scenes/world/modules/mall/*.tscn`
- `game/scenes/world/modules/demo/*.tscn`
- `game/scenes/world/store_world.tscn`
- `game/scenes/world/graybox_store.tscn`

## Likely Script Files

Likely touched during implementation:

- palette/settings scripts
- material binding scripts
- store identity/customization scripts
- lighting state scripts
- screenshot review manifests

Implementation should preserve movement and interactions while replacing flat graybox materials with readable store materials.

## Data Requirements

Palette data should include:

- palette id
- default flag
- editable flag
- wall base color
- wall panel color
- trim color
- fixture laminate color
- metal color
- signage contrast recommendations

Material definitions should include:

- material id
- surface type
- editable flag
- texture id
- color/tint
- roughness/visual intent
- replacement/upgrade id if applicable

Lighting definitions should include:

- light id
- location/zone
- color temperature intent
- brightness intent
- state binding if any
- screenshot review role

## Tests To Add Or Update

Later implementation should add or update tests for:

- store light modules exist and are active in opening store
- mall light modules use warmer material/light intent than store modules
- floor material is assigned to commercial carpet target
- light wall material is assigned to store walls
- editable color panel material exists
- starter fixtures use laminate and black metal material ids
- default palette exists and is marked editable
- demo screen light is tied to a screen/display surface
- no fake standalone glow prop is required for demo readability

Doc/status tests should include this doc as an active planning document once written.

## Screenshot Targets

Capture these once the implementation exists:

- `lighting_store_bright_read.png`: bright sales floor with readable fixtures/products.
- `lighting_mall_warmer_store_brighter.png`: mall/store contrast from storefront.
- `materials_commercial_carpet.png`: floor material read from walking height.
- `materials_light_walls_color_panels.png`: clean walls with editable panel treatment.
- `materials_fixture_laminate_black_metal.png`: starter fixture material close read.
- `lighting_demo_screen_source.png`: demo area light clearly coming from screen/display.
- `palette_default_editable.png`: default palette applied without locking future customization.

## Acceptance Checklist

- [ ] Store lighting reads bright retail.
- [ ] Mall lighting is warmer than store lighting.
- [ ] Store remains readable in 1280x720 screenshots.
- [ ] Flooring reads as firm commercial carpet.
- [ ] Walls are clean/light and no longer raw graybox planes.
- [ ] Paintable/editable wall color panels exist where useful.
- [ ] Starter fixtures use cheap laminate and black metal.
- [ ] Default palette exists and is editable.
- [ ] Product/poster/sign colors carry major accents without making the room chaotic.
- [ ] Demo/console light comes from actual screen/display surfaces.
- [ ] No fake glow is used as a substitute for better material/lighting design.

## Fail Conditions

This slice fails if:

- store remains flat graybox colored
- store is too dark to read
- mall and store lighting feel identical
- floor reads like raw plane or modern showroom tile
- walls lack material/color-panel treatment
- fixtures still look like unmodified cubes
- demo area uses artificial glow unrelated to a display
- palette is hard-locked with no customization path
- products/posters/signs are washed out by lighting

## Stop/Ask-Owner Conditions

Stop and ask before:

- making the store intentionally dim or moody
- replacing firm commercial carpet with a very different floor type
- removing editable palette/color-panel plans
- making demo glow independent from display screens
- hard-locking a final palette with no customization path

Do not stop for normal brightness, temperature, texture, or palette tuning if the store remains bright, readable, and editable.

## Commit Expectation

Commit the lighting/materials/palette implementation as its own slice after docs, tests, and screenshots are updated.

The commit should be reviewable independently from validation checklist and final roadmap work unless those are required to prove screenshot readability.

## Next Document

After this doc, write `12-validation-and-screenshot-checklist.md` to define owner review screenshots, pass/fail language, validation artifacts, and the implementation-to-validation cycle.
