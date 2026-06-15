# Opening Visual Asset Pass

## Purpose

Turn the improved mall-entry composition into the first real art benchmark.

This is the current owner-validation cycle. It happens before broader sales-floor, catalog, customer, decoration, or multi-day work. The implemented scene proves the route and framing and now includes the first authored modular asset pass for the visible mall/storefront/opening route. Owner review still needs to decide whether it clears enough of the previous box-label read to become the benchmark for the rest of the shop.

## Implementation Status

Implemented for review on June 12, 2026:

- Mall shell: tile panels, grout seams, round rail posts, rail highlight, shutter slats, planter foliage, and directory map cues.
- Storefront: additional mullions, mid-rails, threshold lip, open-door rails, sign glow backer, cartridge/disc icon details, and reduced sign-label scale.
- Starter product set: two new-game cases, one console box, one accessory/controller box, cover strips, stickers, price tags, and display supports.
- First interior benchmark corner: slatwall rails, new-release shelf, console display plinth, accessory peg, and packaged accessory detail.
- Tests: `game/tests/gut/test_graybox_store.gd` now asserts the authored route modules, starter product kit, and first benchmark corner.

Still pending:

- Owner review of `main_scene.png`, `storefront_entry.png`, the latest contact sheet, and a real 1280x720 walk-in.
- Corrections to any opening-route objects that still read as raw boxes, labels, or oversized debug signage.
- Hard visual benchmark rebuild before broadening visual work; see [Hard Visual Benchmark Rebuild](19-hard-visual-benchmark-rebuild.md).

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

- `game/scenes/world/store_world.tscn` as the production scene and active screenshot/tool target.
- `game/scenes/world/graybox_store.tscn` as the legacy compatibility wrapper.
- `game/scenes/world/modules/*` for production module manifests and future physical extraction.
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

1. Replace mall floor, wall edges, railing, planter, and neighbor-store blocks with a modular mall shell kit. Done.
2. Replace storefront frame, sign band, glass, door, handle, and threshold with authored pieces. Done.
3. Replace window/interior box stacks with the starter product/display kit. Done.
4. Rebuild the first interior corner so register/front shelf/new-release read by shape and material. Done.
5. Reduce oversized label panels to believable signage, decals, shelf talkers, tags, and packaging. First pass done; owner review may require further reduction.
6. Re-run scene tests, full validation, and screenshot review. Automated validation required before signoff; owner screenshot review remains the final gate.

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
- Stop broadening `graybox_store.tscn`; future production visual breadth should happen through `store_world.tscn` and the approved module boundaries.
