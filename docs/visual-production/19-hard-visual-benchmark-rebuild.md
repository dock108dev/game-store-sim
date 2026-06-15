# Hard Visual Benchmark Rebuild

## Purpose

Replace the current label-heavy blockout read with one credible first-person visual benchmark before any broader catalog, decoration, customer, or multi-day visual work continues.

Owner review after the prototype visual language cleanup is rejected as a visual baseline. The implementation did make small scene/test/doc improvements, but the live view still reads as a graybox with signs and primitive props. This plan supersedes `18-prototype-visual-language-cleanup.md` as the active next visual implementation source.

## Target

Build one approved benchmark route:

1. Player starts on the second-floor mall concourse.
2. Player enters the storefront.
3. Player sees the register and first sales-floor area.
4. Player can identify the shop as a mid-00s game store before reading any labels.
5. Backroom threshold reads as architecture, not a zone marker.
6. Receiving remains visible as restrained setup context, not random clutter.

The first approved benchmark screenshot set must cover:

- `main_scene.png`
- `storefront_entry.png`
- `register_counter.png`
- `receiving_area.png`
- `backroom_summary.png`
- a manual real-window walkthrough from mall approach into register view

## Current Failure

The current scene still fails because:

- large flat walls, floors, and ceiling dominate the frame
- rectangular sign cards carry too much object identity
- product and fixture silhouettes are too primitive
- props still look scattered or debug-authored
- material variation is weak
- lighting does not yet create a believable retail interior
- backroom architecture is still too shallow
- `graybox_store.tscn` remains a wrapper name, but the visual problem is in the promoted `store_world.tscn` production content

## Non-Negotiables

- Work in `store_world.tscn`; keep `graybox_store.tscn` as compatibility only.
- Keep all core interactions working: receiving, pickup, pricing, stocking, register, backroom computer, fixture placement, save/load.
- Keep customers hidden in the opening state.
- Keep day-one physical inventory restrained: 2 new games, 1 console, 1 accessory/controller, used/trade-in capacity, and only received or owned goods physically present.
- Keep future locked inventory in catalog/planning surfaces until purchased/unlocked/received/released/traded in.
- Do not solve this with more labels.
- Do not broaden to full catalog art before the benchmark route is approved.

## Definition Of Done

The pass is done only when:

- `scripts/validate_godot.sh` passes.
- The contact sheet is regenerated.
- The five benchmark screenshots no longer read primarily as graybox, label cards, or random props.
- The register/sales-floor view reads as a small game shop from shapes, fixtures, products, materials, and lighting.
- The backroom threshold reads as a real staff-only transition.
- Owner can either approve the benchmark as the next baseline or reject it with specific screenshot-targeted corrections.

## Phase 0: Prep And Baseline Lock

Goal: make sure implementation starts from a known visual target, not editor-stale confusion.

Implementation slices:

1. Record baseline screenshots from `artifacts/validation/latest/screenshots/` and the owner-provided 12:22 PM screenshots as rejected evidence.
2. Add/update a QA note that Godot may need the running game stopped plus `Scene > Reload Saved Scene` after external file edits; this is not a new-project issue.
3. Pick the exact benchmark route: mall approach, storefront entry, register-first interior, receiving corner, backroom threshold.
4. Confirm `store_world.tscn` and module manifests are the only visual implementation target for this pass.
5. Add tests/docs that name this new phase as active, so status does not route back to the softer cleanup pass.

Likely files:

- `docs/CURRENT_STATE.md`
- `docs/status.json`
- `docs/production/04-backlog.md`
- `docs/production/13-alpha-bug-list.md`
- `docs/qa/screenshot-review.md`
- `game/tests/gut/test_docs_status_contract.gd`

Acceptance:

- Active docs point to this plan.
- Prior cleanup is recorded as insufficient for visual approval.
- Validation status still reflects the last passing gate until implementation changes it.

## Phase 1: Benchmark Composition

Goal: make one view worth building toward before detail work spreads across the whole shop.

Implementation slices:

1. Reframe the player opening route so the first meaningful interior view is register plus sales-floor fixture silhouettes, not ceiling/floor/label cards.
2. Establish a stable benchmark camera composition for automated screenshots and manual walkthrough:
   - mall approach should frame storefront name, glass, threshold, and interior hint
   - storefront entry should show the register and front sales floor
   - register counter should show counter depth, display objects, and one visible fixture family
3. Remove or relocate props that only clutter the benchmark view.
4. Reduce large empty wall planes visible from the benchmark view by adding fixture silhouettes, trim, posters, or material breaks.
5. Add a test that protects named benchmark anchors:
   - storefront identity
   - register counter
   - first fixture wall
   - day-one stock staging
   - backroom threshold

Likely files:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/modules/storefront_shell.tscn`
- `game/scenes/world/modules/opening_threshold.tscn`
- `game/scenes/world/modules/store_interior_shell.tscn`
- `game/scenes/world/modules/front_counter_zone.tscn`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/validation/scenarios/store_visual_polish.json`

Acceptance:

- `main_scene.png`, `storefront_entry.png`, and `register_counter.png` each show a coherent composition.
- The first read is shop layout and merchandise shape, not scattered cards.
- No customer or employee actors are visible in opening-state screenshots.

Stop condition:

- If the current floor plan cannot produce a credible benchmark composition without moving major gameplay routes, stop for owner layout review.

## Phase 2: Label Suppression And Signage Rules

Goal: remove explanatory text as the primary visual language.

Implementation slices:

1. Inventory every `Label3D` visible from the benchmark route.
2. Classify labels:
   - allowed: exterior store identity, small shelf tags, price stickers, condition stickers, staff door decal, UI prompts
   - convert: category cards, zone labels, giant feature text, debug-like process labels
   - delete/hide: any label that only explains a prototype object
3. Replace oversized category cards with physical cues:
   - shelf strips
   - color-coded product rows
   - small pegboard tags
   - poster art blocks without readable debug text
   - price stickers on product cases
4. Add size/visibility tests for benchmark-route labels:
   - no interior label above the agreed pixel-size threshold except storefront identity
   - no label text containing zone words such as `DISPLAY RACKS`, `BACKROOM`, `RECEIVING`, `STORAGE`, `USED WALL`, or `CONTROLLERS`
   - prompt/UI labels remain readable and unaffected
5. Update screenshot QA to fail if a screenshot needs a label to understand the store.

Likely files:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/modules/sales_floor_fixtures.tscn`
- `game/scenes/world/modules/front_counter_zone.tscn`
- `game/scenes/world/modules/receiving_area.tscn`
- `game/scenes/world/modules/backroom_shell.tscn`
- `game/tests/gut/test_graybox_store.gd`
- `docs/qa/screenshot-review.md`

Acceptance:

- The benchmark view reads as retail before text.
- Interior labels are secondary details, not the scene’s explanation layer.
- Existing interaction prompts still work and remain readable.

Stop condition:

- If removing labels makes interaction targets unclear, stop and replace them with better physical affordances rather than restoring large signs.

## Phase 3: Fixture Silhouette Kit

Goal: make the shop identifiable through fixture and product shapes.

Implementation slices:

1. Build the first wall-shelf kit:
   - side uprights
   - shelf boards with depth
   - back panel or slatwall
   - short product rows
   - shelf lip and tag strip
2. Build a pegboard/accessory kit:
   - pegboard panel
   - hooks
   - 1 accessory/controller pack
   - 2-3 empty pegs for restrained day-one density
3. Build the register counter display kit:
   - counter trim
   - small impulse display tray
   - receipt/card/scanner objects as physical props
   - no oversized card signs
4. Build day-one product silhouettes:
   - 2 new game case fronts/spines
   - 1 boxed console
   - 1 boxed/loose controller accessory
   - a small used-game row or bin with restrained density
5. Build fixture tests that assert:
   - named fixtures exist
   - product silhouettes are present and nonblocking
   - day-one physical stock is limited
   - future inventory is absent from physical shelves unless received/unlocked

Likely files:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/modules/starter_product_display.tscn`
- `game/scenes/world/modules/sales_floor_fixtures.tscn`
- `game/scenes/world/modules/front_counter_zone.tscn`
- `game/scenes/props/placeholder_shelf.tscn` or new fixture scenes if extraction is warranted
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_product_visual_rules.gd`

Acceptance:

- From `register_counter.png`, a player can identify shelves, game cases, boxed hardware, and accessory display without reading labels.
- Products look intentionally arranged, not dumped.
- The store feels newly opening and understocked, not full catalog unlocked.

Stop condition:

- If CSG-only fixture primitives cannot hit the silhouette bar, stop and define reusable mesh/asset requirements before adding more CSG clutter.

## Phase 4: Physical Detail Replacement

Goal: replace sign-card language with believable store details.

Implementation slices:

1. Replace large wall cards with:
   - poster blocks
   - faded promo rectangles
   - shelf strips
   - small fictional logo decals
   - scuffed wall/floor trim
2. Add product-facing detail:
   - colored cover bands
   - spine strips
   - price stickers
   - condition dots
   - platform color blocks
3. Add counter detail:
   - laminate/trim bands
   - register mat
   - small bag/sleeve stack
   - service slips as paper geometry, not giant labels
4. Add receiving detail:
   - packing tape
   - sorted trays
   - shipping labels as small stickers
   - keep the workflow readable without sign spam
5. Add tests that protect physical detail density and prevent reintroducing oversized explanatory cards.

Likely files:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/modules/front_counter_zone.tscn`
- `game/scenes/world/modules/sales_floor_fixtures.tscn`
- `game/scenes/world/modules/receiving_area.tscn`
- `game/scenes/props/product_item.tscn` or product visual scripts if details belong there
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_product_item.gd`

Acceptance:

- `register_counter.png` and `receiving_area.png` show object identity through physical details.
- The view no longer looks like beige cards attached to boxes.
- Small details support the scene without creating unreadable speckle.

Stop condition:

- If detail becomes noisy at 1280x720, reduce density and increase silhouette clarity before adding more props.

## Phase 5: Ceiling, Lighting, And Materials

Goal: make the room feel like a believable retail interior instead of a gray room.

Implementation slices:

1. Add ceiling language:
   - drop-ceiling panels or visible soffit strips
   - fluorescent fixtures
   - register-area warm light
   - cooler backroom light
2. Add floor material breaks:
   - mall tile outside
   - store carpet/vinyl inside
   - threshold strip
   - backroom utility floor
3. Add wall material breaks:
   - baseboards
   - trim lines
   - slatwall/fretwork where fixtures live
   - fewer flat blank planes
4. Tune material palette:
   - avoid a one-note gray/brown blockout
   - keep mid-00s local shop warmth
   - keep readable contrast for products and prompts
5. Run performance and screenshot checks after lighting/material changes.

Likely files:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/modules/mall_concourse.tscn`
- `game/scenes/world/modules/storefront_shell.tscn`
- `game/scenes/world/modules/store_interior_shell.tscn`
- `game/scenes/world/modules/backroom_shell.tscn`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/validation/scenarios/store_visual_polish.json`

Acceptance:

- The benchmark screenshots have distinct mall, storefront, sales floor, register, and backroom material reads.
- Ceiling/floor no longer dominate as flat gray planes.
- Performance smoke remains green.

Stop condition:

- If lighting/material changes reduce readability or performance, roll back the heavy pieces and solve with simpler material/geometry contrast.

## Phase 6: Backroom Architecture Rebuild

Goal: make the backroom read as a real employees-only room from normal player movement.

Implementation slices:

1. Replace the remaining shallow threshold read with real architecture:
   - partial wall returns
   - deeper doorway or short hall cue
   - header/soffit
   - door jambs
   - material transition
2. Build visible backroom depth beyond the threshold:
   - receiving side
   - backstock shelf
   - service/management surface hint
   - clear walking route
3. Remove or reduce backroom zone labels/cards visible from public floor.
4. Add backroom lighting contrast:
   - cooler utility light
   - less retail warmth
   - still readable enough for interaction
5. Add route and nonblocking tests:
   - player route from sales floor to computer remains clear
   - receiving route remains clear
   - threshold props are nonblocking or intentionally collidable only where walls are real
   - backroom computer remains interactable

Likely files:

- `game/scenes/world/store_world.tscn`
- `game/scenes/world/modules/backroom_shell.tscn`
- `game/scenes/world/modules/receiving_area.tscn`
- `game/scenes/world/modules/store_interior_shell.tscn`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/validation/scenarios/stockroom_production_plan.json`

Acceptance:

- `backroom_summary.png` and a manual entry/register view show a believable staff-only transition.
- The player understands public vs staff space without reading a label.
- The backroom computer and receiving flow still work.

Stop condition:

- If deeper architecture blocks routes or breaks interactions, stop and review layout before adding more backroom detail.

## Phase 7: QA, Docs, And Owner Handoff

Goal: finish the pass as reviewable evidence.

Implementation slices:

1. Run `scripts/validate_godot.sh`.
2. Regenerate `artifacts/validation/latest/screenshot-contact-sheet.png`.
3. Review the five benchmark screenshots and capture a manual real-window walkthrough if needed.
4. Update:
   - `docs/status.json`
   - `docs/CURRENT_STATE.md`
   - `docs/production/04-backlog.md`
   - `docs/production/13-alpha-bug-list.md`
   - `docs/qa/screenshot-review.md`
5. Record owner-review status:
   - approved benchmark baseline
   - rejected with required corrections
   - blocked by asset-pipeline decision

Acceptance:

- Full validation passes.
- Docs point to the completed benchmark pass.
- Owner has a concrete screenshot set to approve or reject.

## Test Strategy

Automated:

- GUT tests for required benchmark nodes, fixture silhouettes, label suppression, route clearance, material/lighting cues, and module ownership.
- Validation scenario references for the benchmark screenshots.
- Existing interaction and store-session tests must remain green.
- `scripts/validate_godot.sh` remains the authoritative finish line.

Manual:

- Stop the running Godot game.
- Reload saved scene or reopen the project if the editor appears stale.
- Launch the game in a normal 1280x720 window.
- Walk from mall approach through storefront into the register view.
- Check that the shop reads as a game store before labels.
- Check that the backroom threshold reads as staff-only architecture.

## Owner Review Checklist

Pass only if:

- the first view reads as a game shop, not a gray room with signs
- register/sales-floor view has fixture and product identity without labels
- ceiling/floor/walls have enough material treatment to stop feeling like graybox
- labels are secondary details
- backroom threshold reads as architecture
- receiving reads as staged workflow
- day-one stock remains restrained

Fail if:

- the scene still needs labels to explain itself
- screenshots still look like primitive boxes with signs
- flat ceiling/floor/walls dominate the frame
- receiving or backroom still reads like random props or zone markers
- future catalog inventory appears physically present before unlock/receipt

## Next Pass After Approval

If approved, move to broader product and fixture visual-kit breadth:

- reusable product case/box/accessory variants
- complete fixture families
- full day-one placement flow
- catalog/unlock/receiving visual states
- then customer silhouettes and decoration/upgrades

If rejected, keep all work inside this benchmark plan until the five screenshot targets pass.
