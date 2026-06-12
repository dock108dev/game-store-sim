# Opening Visual Asset Pass

## Purpose

Turn the improved mall-entry composition into the first real art benchmark.

This is the next implementation cycle. It should happen before broader sales-floor, catalog, customer, decoration, or multi-day work. The current scene proves the route and framing, but too many visible objects still read as boxes with labels. This pass replaces that visible blockout language on the opening route with authored modular assets.

## Slice Boundary

Only this route is in scope:

`mall spawn -> storefront approach -> glass threshold -> first interior view`

The player should still start outside the store on the second-floor mall concourse, walk into the shop, and see an empty pre-open interior with no customers or employees visible.

## In Scope

- Mall floor tile kit with seams, edge strips, and material variation.
- Atrium railing/post kit with authored silhouettes instead of raw bars.
- Neighbor storefront/shutter kit that frames the shop without becoming the subject.
- Storefront wall, sign band, mullions, glass door, handle, and threshold.
- Store sign treatment using mesh/decal/texture surfaces, not floating label identity.
- Window display props that read as game retail before text.
- First interior corner benchmark: register/front shelf/new-release display language.
- Starter product visual set: 2 new games, 1 console box, and 1 accessory/controller box.
- Reduced label scale: labels become believable signage, decals, tags, receipts, or packaging.
- Simple collision retained for the walking route.

## Out Of Scope

- Full sales-floor replacement.
- Full backroom replacement.
- Visible customer role work.
- Full catalog product art.
- Decoration/upgrades breadth.
- New economy or day-loop mechanics.
- External alpha playtest reopening.

## Required Asset Families

### Mall Shell

- `mall_floor_tile_*`
- `mall_baseboard_*`
- `mall_railing_post_*`
- `mall_railing_rail_*`
- `mall_neighbor_shutter_*`
- `mall_planter_*`
- `mall_directory_*`

### Storefront

- `storefront_wall_panel_*`
- `storefront_sign_band_*`
- `storefront_glass_panel_*`
- `storefront_door_frame_*`
- `storefront_door_handle_*`
- `storefront_threshold_*`
- `storefront_window_display_shelf_*`

### First Interior Corner

- `counter_register_module_*`
- `front_shelf_module_*`
- `new_release_display_*`
- `product_case_new_game_*`
- `product_console_box_*`
- `product_accessory_box_*`
- `price_tag_small_*`
- `paper_poster_window_*`

## Files Expected To Change

- `game/scenes/world/graybox_store.tscn`
- future `game/assets/visual/materials/*`
- future `game/assets/visual/meshes/store_shell/*`
- future `game/assets/visual/meshes/fixtures/*`
- future `game/assets/visual/meshes/products/*`
- future `game/assets/visual/textures/posters/*`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/tools/capture_main_scene_screenshot.gd`
- `docs/qa/screenshot-review.md`
- `docs/production/13-alpha-bug-list.md`

## Implementation Order

1. Replace mall floor, wall edges, railing, planter, and neighbor-store blocks with a modular mall shell kit.
2. Replace storefront frame, sign band, glass, door, handle, and threshold with authored pieces.
3. Replace window/interior box stacks with the starter product/display kit.
4. Rebuild the first interior corner so register/front shelf/new-release read by shape and material.
5. Reduce oversized label panels to believable signage, decals, shelf talkers, tags, and packaging.
6. Re-run scene tests, full validation, and screenshot review.

## Validation

Automated:

- `scripts/validate_godot.sh`
- `game/tests/gut/test_graybox_store.gd`
- screenshot capture and sanity checks
- old-name scan

Manual:

- `docs/qa/screenshot-review.md`
- real-window 1280x720 walk from spawn through the storefront

Required screenshots:

- `main_scene.png`
- `storefront_entry.png`
- first-person live screenshots from spawn, door, threshold, and first interior corner

## Pass Criteria

- The opening route reads as a small mall game shop before small text is read.
- No visible opening-route object reads as a raw debug box unless it is intentionally a cardboard box.
- Store identity comes from facade, glass, window display, product silhouettes, signage treatment, and lighting.
- Starter products read as games/hardware/accessories by shape, packaging, and shelf placement.
- The first interior corner becomes the style benchmark for later sales-floor work.
- Customers and employees remain absent in the opening state.
- The player can walk from spawn through the threshold with prompts/routes still clear.
- The day-one shop remains restrained and leaves room for later unlocks.

## Fail Criteria

- Screenshots still read primarily as flat walls, floor planes, boxes, and floating labels.
- The scene only reads as a game shop because of large text.
- New details block the walking route, prompts, register, shelf, or receiving path.
- Product/display clutter implies the full catalog is available on day one.
- The pass spreads into the whole store before the opening route is approved.

## Stop Conditions

- Stop if replacing visuals changes core interaction targets.
- Stop if the pass requires new gameplay systems.
- Stop if imported assets introduce real-world brands, logos, product names, or recognizable trade dress.
- Stop if screenshot review still fails `main_scene.png` or `storefront_entry.png`; do not broaden scope until those are fixed.
