# Art Language Rebuild Plan

## Purpose

The hard visual benchmark implementation proved that adding more CSG boxes, label panels, and small prop rectangles will not reach the inspiration target. The next implementation pass must change the production method before it changes the amount of content.

This plan supersedes `19-hard-visual-benchmark-rebuild.md` as the active visual implementation source. Doc 19 remains a useful implementation record and failure case: it improved routing, tests, and some fixture intent, but it still reads as a cube-based graybox rather than a simple, authored indie-shop environment.

## Diagnosis

The current scene fails for a specific reason: the visual hierarchy is backwards.

The inspiration is simple, but it is not primitive. It gets its read from:

- large clean authored shapes before detail
- bevels, trim, curved awnings, framed windows, sign housings, and material seams
- glass, metal, brick, tile, laminate, plastic signage, cardboard, and warm interior lighting
- integrated signs and posters instead of freestanding explanatory labels
- restrained product detail that sits on believable fixtures
- one strong first read per view

The current scene gets its read from:

- raw rectangular solids
- labels explaining what each object is
- scattered block props
- weak material separation
- flat wall/floor/ceiling planes
- CSG objects used as final art instead of temporary composition aids

The next pass must build a small approved art kit first, then replace the benchmark route with that kit. It should not broaden catalog, customer, decoration, or multi-day visuals until the first route passes owner review.

## Non-Negotiables

- `store_world.tscn` remains the production scene.
- `graybox_store.tscn` remains compatibility only.
- The current mechanics stay intact: movement, prompts, receiving, pickup, pricing, stocking, register, backroom computer, fixture placement, save/load, and validation.
- Customers and employees remain hidden in the opening pre-business state.
- Day-one physical inventory remains restrained: 2 new games, 1 console, 1 accessory/controller, plus trade-in/receiving capacity.
- Future locked inventory stays in catalogs/planning surfaces until purchased, unlocked, received, released, or traded in.
- Raw CSG boxes may be used for collision, invisible blockers, or temporary layout, but not as visible final art for the approved benchmark route.
- Large explanatory labels do not return as the primary visual language.
- The first pass proves one view and one route before rebuilding the whole shop.

## Target Route

The approved route is still narrow:

1. Start on the second-floor mall concourse.
2. Face a branded storefront that reads as a real shopfront.
3. Walk through the glass/door threshold.
4. See register plus first sales-floor fixture family.
5. Identify the place as a mid-00s independent game shop before reading labels.
6. See a staff/backroom threshold that reads as architecture, not a line or sign.

Primary screenshots:

- `main_scene.png`
- `storefront_entry.png`
- `register_counter.png`
- `receiving_area.png`
- `backroom_summary.png`

Secondary screenshots that must not regress:

- `stocked_aisle.png`
- `carry_stack.png`
- `catalog_design_cues.png`
- `fixture_placed.png`
- `fixture_ghost.png`

## Implementation Model

Do not edit the whole store into shape one cube at a time. Build and validate a small art kit, then instance it into the production scene.

Required new implementation surfaces:

- `game/scenes/world/art_benchmark/` for isolated visual proof scenes.
- `game/scenes/world/kits/` for reusable shop modules.
- `game/assets/materials/retail/` for shared materials.
- `game/assets/decals/retail/` or equivalent texture resources for product/poster/sign surface detail.
- existing `game/scenes/world/modules/` manifests updated only after a kit module is approved.

The production scene should become an assembly of visual modules, not a single file full of raw geometry.

## Phase A: Baseline Lock And Rejection Record

Goal: make the failure explicit so the next implementation cannot accidentally optimize the wrong thing.

Tasks:

1. Update source-of-truth docs to mark the hard benchmark as rejected for art-language reasons.
2. Keep the latest contact sheet as evidence, but do not treat it as an owner approval target.
3. Add a "cube-language rejection" note to the alpha bug list.
4. Update tests/status so the active route points to this rebuild plan.
5. Define the first approved benchmark target as an isolated art-kit scene, not the full store.

Deliverables:

- `docs/status.json` updated to the new active phase.
- `docs/CURRENT_STATE.md` updated with the new blocker.
- `docs/production/13-alpha-bug-list.md` updated with a new visual blocker.
- `docs/visual-production/README.md` and roadmap updated.

Acceptance:

- Active docs no longer say the next step is owner approval of the hard benchmark.
- Active docs say the current visual method is the blocker.
- Full validation still passes after the doc/test update.

## Phase B: Art-Kit Sandbox Scene

Goal: prove the visual language in isolation before touching the full production route.

Create one sandbox scene:

- `game/scenes/world/art_benchmark/game_shop_art_benchmark.tscn`

This scene should contain only:

- one storefront facade bay
- one mall concourse floor/wall slice
- one glass door/window module
- one register counter module
- one wall shelf/display module
- one product/poster/decal material set
- one lighting setup
- one camera that captures the intended first read

Tasks:

1. Build a small 10m to 14m wide storefront slice.
2. Use authored module scenes rather than adding loose primitives directly to the benchmark root.
3. Establish one camera angle that proves the storefront plus interior hint.
4. Establish one camera angle that proves the register plus shelf family.
5. Add a debug-free screenshot capture path for this benchmark.

Acceptance:

- The sandbox screenshot has no giant explanatory labels.
- The view reads as shopfront/register/fixture through shapes and materials.
- Large planes have material seams, trim, or fixture coverage.
- The module count stays small enough to review.

Stop condition:

- If the sandbox still reads as cubes, stop and improve the module kit before touching `store_world.tscn`.

## Phase C: Storefront Facade Kit

Goal: replace the flat storefront read with a believable facade module inspired by the reference images.

Required modules:

- curved or stepped sign fascia
- sign backing/housing with depth
- neon/LED trim strip
- glass window bays with mullions
- door frame with handle, threshold, kick plate, and open-door state
- side pilasters or wall returns
- mall tile apron and storefront base trim
- neighboring shutter/black storefront panel for concourse context
- planter/bench/rail module as restrained environment dressing

Implementation notes:

- Use mesh or authored scene modules for visible pieces.
- Use bevel-like geometry where possible: thin trim strips, layered frames, chamfered-looking edges, curved fascia if practical.
- Do not rely on a flat sign rectangle with large text.
- Store identity can use a sign, but the sign must be housed in architecture.

Acceptance:

- `main_scene.png` reads as a storefront before text.
- Glass reads as glass through tint, reflectivity/alpha, frame density, and interior visibility.
- The facade has a top/middle/base hierarchy.
- The mall concourse no longer looks like an empty gray hallway.

## Phase D: Register Counter And First Interior Kit

Goal: make the first interior view work as a real game-shop operations surface.

Required modules:

- counter shell with base, top slab, trim bands, kick panel, and register-side depth
- monitor/POS/scanner/card-reader module
- bag/sleeve stack
- small impulse display tray
- front shelf or display case face
- register mat and small paper/receipt surfaces
- lighting above counter

Implementation notes:

- The counter should be one readable object with a controlled silhouette, not a pile of blocks.
- Counter detail should be small and grouped.
- Avoid text cards that explain register functions.
- UI prompts may remain; environment signage should be physical and secondary.

Acceptance:

- `register_counter.png` reads as register/counter/retail surface without labels.
- Counter detail does not block interaction prompts.
- The scene still supports all register workflows.

## Phase E: Wall Shelf, Product, And Poster Kit

Goal: make products and fixtures carry shop identity.

Required modules:

- wall shelf bay with uprights, shelf boards, back/slat panel, and tag strip
- shelf lip and product stop
- new game case front
- new game case spine row
- boxed console silhouette
- controller/accessory hanging pack
- poster/promo panel
- small sticker/decal variants for price, platform, condition, and sale tags

Implementation notes:

- Product detail should use materials/decals or colored planes, not readable micro-label spam.
- The first day should look understocked but intentional.
- Product rows should align cleanly and repeat from reusable modules.
- Future catalog products should not become physical shelf objects yet.

Acceptance:

- `stocked_aisle.png` and `register_counter.png` show recognizable product categories from shape/color.
- Day-one stock remains restrained.
- Fixtures feel designed, not randomly assembled from boxes.

## Phase F: Receiving And Backroom Threshold Kit

Goal: make operations read as staged workflow and staff architecture.

Required modules:

- receiving table or intake counter
- open shipping carton module
- tape/label/sorting tray details
- invoice/paper stack as small physical surfaces
- backstock shelf with bins
- staff doorway with jambs, header, partial wall returns, and material transition
- utility floor/wall treatment behind threshold
- cooler backroom light

Implementation notes:

- Receiving should be visibly work-in-progress, but cleanly grouped.
- Backroom threshold must be architecture, not a label or line.
- Public floor should not see a wall of tiny labels through the threshold.

Acceptance:

- `receiving_area.png` reads as receiving/sorting, not dumped cubes.
- `backroom_summary.png` reads as employees-only space with depth.
- Routes to receiving, storage, and computer remain clear.

## Phase G: Production Route Replacement

Goal: replace the current benchmark route in `store_world.tscn` with approved modules.

Tasks:

1. Remove or hide the visible CSG benchmark pieces from doc 19 that still read as cube clutter.
2. Instance approved kit scenes into `store_world.tscn`.
3. Update module manifests to own the new kit instances.
4. Preserve existing node paths for mechanics where needed.
5. Keep old CSG collision/anchors only if invisible or clearly not part of the visual read.
6. Update scene tests to assert kit instances, not raw benchmark cube nodes.

Acceptance:

- The five primary screenshots use the new kit modules.
- Old label/card/cube benchmark nodes are not visible in the benchmark route.
- All existing mechanics still pass.

## Phase H: Validation And Owner Review

Goal: finish with evidence that can be approved or rejected clearly.

Tasks:

1. Run `scripts/validate_godot.sh`.
2. Generate the contact sheet automatically.
3. Capture or manually inspect the 1280x720 real-window walk-in route.
4. Compare screenshots against the reference principles.
5. Record outcome in status/current-state/backlog/bug-list.

Acceptance:

- Full validation passes.
- The owner can answer one question: does the route now read like the intended simple indie shop instead of cube geometry?

## Required Tests

Add or update tests for:

- active docs/status route points to this plan
- art-kit scene loads
- production scene instances approved kit modules
- visible benchmark route has no oversized explanatory labels
- day-one stock physical limits are preserved
- future catalog products are not physically present
- register, receiving, backroom computer, and fixture placement remain interactable
- screenshot scenarios still produce all 23 images

## Commit Strategy

Commit in small validation-ready slices:

1. Documentation and status routing.
2. Sandbox scene and materials.
3. Storefront kit.
4. Register/interior kit.
5. Product/shelf kit.
6. Receiving/backroom kit.
7. Production route replacement.
8. QA/status handoff.

Each commit should run at least the relevant focused GUT tests. The production-route replacement and final handoff must run `scripts/validate_godot.sh`.

## Decision Points

Ask for owner input only if:

- the storefront identity/name/sign shape needs selection
- a real mesh/modeling workflow is required and the repo has no acceptable tooling path
- the sandbox art-kit screenshot still reads as cubes after one serious pass
- changing the route layout would alter gameplay flow
- performance or Godot import constraints make the intended kit impractical

## Next Implementation Pass

Start with Phase A and Phase B. Do not keep adding CSG detail to `store_world.tscn` until the isolated art-kit benchmark looks right.

- Stop if the sandbox scene still reads as cubes.
- Do not build broad catalog variants until the first modular art kit passes owner review.
