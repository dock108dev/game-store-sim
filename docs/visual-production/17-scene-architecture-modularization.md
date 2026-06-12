# Scene Architecture Modularization

## Purpose

Stop treating `graybox_store.tscn` as the long-term production world.

The current scene is valuable because it proves the retail loop, screenshot harness, validation gate, interaction wiring, and first opening visual pass. It is not a healthy production surface for continued art work. It mixes prototype layout, production-intent visual pieces, gameplay managers, interaction targets, screenshot anchors, and legacy documentation assumptions in one large scene.

This implementation pass creates a modular production scene architecture while preserving the validated game behavior.

## Decision

Do not delete `graybox_store.tscn` during the first modularization pass.

Use it as the legacy compatibility wrapper until the production world is owner-approved. The new production path has been introduced, validated, and promoted after the player route, interaction targets, screenshot capture, and tests stayed green.

## Implementation Status

Implemented for review on June 12, 2026:

- `game/scenes/world/store_world.tscn` is the production main scene.
- `game/scenes/world/graybox_store.tscn` is retained as a thin compatibility wrapper around `store_world.tscn`.
- `game/scenes/world/modules/` contains module manifests for mall concourse, storefront shell, opening threshold, store interior shell, front counter, starter product display, sales-floor fixtures, receiving area, backroom shell, and systems ownership.
- `game/scripts/world/visual_module_manifest.gd` records `module_id`, responsibility, and owned node names, with tests verifying every owned node resolves in the production world.
- `game/project.godot`, screenshot capture tools, performance tooling, and main-scene tests now target `store_world.tscn`.

The implementation is intentionally conservative: visual and gameplay nodes keep their validated runtime placement while manifests and production anchors define ownership. Do not do a deeper physical child-node move until owner validation confirms the module boundaries are right.

## Target Outcome

After this pass, the repo has:

- A production world scene with a production name, not `graybox_store`.
- Modular manifest subscenes for the mall shell, storefront, threshold, first interior view, counter, sales fixtures, receiving/backroom, and system managers.
- Clear separation between visual modules, collision/navigation modules, interaction targets, and gameplay state managers.
- Tests proving the new production world loads and preserves the existing player route and core interaction contracts.
- `graybox_store.tscn` retained only as a compatibility harness until it can be safely archived.

## Naming Target

Preferred production scene:

```text
game/scenes/world/store_world.tscn
```

Preferred module folder:

```text
game/scenes/world/modules/
```

Preferred first module set:

```text
game/scenes/world/modules/mall_concourse.tscn
game/scenes/world/modules/storefront_shell.tscn
game/scenes/world/modules/opening_threshold.tscn
game/scenes/world/modules/store_interior_shell.tscn
game/scenes/world/modules/front_counter_zone.tscn
game/scenes/world/modules/starter_product_display.tscn
game/scenes/world/modules/backroom_shell.tscn
game/scenes/world/modules/receiving_area.tscn
game/scenes/world/modules/store_systems.tscn
```

Preferred resource folders:

```text
game/assets/visual/materials/
game/assets/visual/meshes/store_shell/
game/assets/visual/meshes/fixtures/
game/assets/visual/meshes/products/
game/assets/visual/meshes/props/
game/assets/visual/textures/signage/
game/assets/visual/textures/trim/
```

## Scene Ownership Rules

### Production World Owns Composition

`store_world.tscn` should own:

- Player spawn.
- Module placement.
- Lighting and ambience placement.
- Screenshot anchor points.
- Top-level navigation/collision boundaries.
- References between modules and system managers.

It should not own individual product-case details, shelf slats, sign trim, price stickers, or counter clutter directly.

### Visual Modules Own Visual Identity

Visual modules should own:

- Mesh/CSG composition for that zone.
- Local visual-only props.
- Local material assignments.
- Local decals/signage surfaces.
- Local nonblocking visual detail.

Visual modules should not own economy state, customer spawning rules, register transactions, supplier ordering, or save/load state.

### Systems Module Owns Gameplay Managers

`store_systems.tscn` should own:

- `StoreSession`
- `CustomerManager`
- `TransactionLedger`
- `SuspiciousEventLog`
- `EvidenceStorage`
- `FixturePlacementManager`
- Shared controller/wiring nodes that do not belong to a visual zone.

It may expose exported `NodePath` fields or a small wiring script so `store_world.tscn` can connect systems to interactable modules.

### Interaction Targets Stay Stable

Interactable nodes should keep stable names or compatibility aliases during migration:

- `RegisterWorkstation`
- `BackroomComputer`
- `ReceivingBox`
- `GameDisplayRack`
- `FixturePlacementManager`
- `CustomerManager`
- `StoreSession`

If a module move changes a path, tests must locate by stable names, groups, or exported references rather than brittle deep scene paths.

### Collision Stays Simple

Detailed visuals should not become detailed collision.

Each module should use simple, explicit collision for:

- Floor and wall blockers.
- Storefront threshold.
- Counter blockers.
- Fixtures.
- Backroom/staff-only boundaries.

Decorative trim, labels, small product props, stickers, and signs should remain non-colliding unless they are intentional interaction targets.

## Migration Slices

### Slice 1: Production World Skeleton

Status: implemented.

Goal: create `store_world.tscn` without changing player-facing behavior.

Implementation:

- Add `game/scenes/world/store_world.tscn`.
- Instance or duplicate the current top-level world composition from `graybox_store.tscn` as a starting point.
- Add clear root groups:
  - `WorldModules`
  - `Systems`
  - `Lighting`
  - `ScreenshotAnchors`
  - `DebugLegacy`
- Keep project main scene pointing at the current validated scene unless parity is complete in the same pass.
- Add GUT coverage that loads `store_world.tscn` and asserts the player, route, core systems, and screenshot anchors exist.

Exit criteria:

- `store_world.tscn` loads in editor and runtime smoke.
- Existing `graybox_store.tscn` still passes all current tests.
- New tests prove the production scene has the same critical anchors.

### Slice 2: Opening Route Module Extraction

Status: implemented as ownership manifests and production anchors; physical child extraction is deferred until owner validation.

Goal: extract only the approved opening route first.

Implementation:

- Extract or recreate these modules:
  - `mall_concourse.tscn`
  - `storefront_shell.tscn`
  - `opening_threshold.tscn`
  - `store_interior_shell.tscn`
  - `starter_product_display.tscn`
- Preserve world transforms from the current validated opening route.
- Keep visual-only child details inside each module.
- Keep walkable threshold and player spawn unchanged from player perspective.
- Add module-level tests for non-colliding decorative details and route blockers.

Exit criteria:

- `main_scene.png` and `storefront_entry.png` still frame the same subjects.
- The player can walk from mall spawn through the open threshold.
- Customer and employee actors remain hidden in the pre-open state.

### Slice 3: Systems And Interaction Wiring

Status: implemented as a systems manifest while preserving existing system node paths.

Goal: separate gameplay managers from visual modules.

Implementation:

- Create `store_systems.tscn`.
- Move manager nodes under the systems module or instance existing managers there.
- Wire managers to module-owned interactables through exported paths, groups, or a small `StoreWorldWiring` script.
- Avoid rewriting system behavior.
- Add tests that exercise register, receiving, stocking, fixture placement, backroom computer, and save/load through the production scene.

Exit criteria:

- Existing interaction tests pass against the legacy scene.
- New production-world smoke tests prove the same manager names and interaction surfaces resolve.
- No gameplay state is stored in visual-only modules.

### Slice 4: Fixture And Backroom Module Extraction

Status: implemented as ownership manifests for counter, fixtures, receiving, and backroom surfaces; deeper physical extraction remains a follow-up after boundary validation.

Goal: split the rest of the currently validated store without broad visual redesign.

Implementation:

- Extract:
  - `front_counter_zone.tscn`
  - `sales_floor_fixtures.tscn`
  - `receiving_area.tscn`
  - `backroom_shell.tscn`
  - `manager_office_zone.tscn`
  - `service_security_zone.tscn`
- Keep the current visuals where necessary; this slice is architectural, not an art upgrade.
- Preserve screenshot scenario subjects and camera framing.

Exit criteria:

- All 23 screenshot scenarios still capture their named subjects.
- Core pathing and interaction prompts remain readable.
- The production scene can run the full current retail loop.

### Slice 5: Main Scene Promotion

Status: implemented.

Goal: make the production scene the primary game scene only after parity.

Implementation:

- Switch the project main scene from the legacy scene to `store_world.tscn`.
- Update screenshot capture tools to target the production scene.
- Update docs/status to name the production scene as primary.
- Keep `graybox_store.tscn` as a legacy compatibility scene for one pass.

Exit criteria:

- `scripts/validate_godot.sh` passes.
- Screenshot contact sheet has no missing or blank frames.
- Docs and tests no longer describe `graybox_store.tscn` as the production target.

### Slice 6: Legacy Scene Retirement

Status: not started; intentionally deferred until owner validation and at least one more visual implementation cycle proves the wrapper is no longer useful.

Goal: stop editing `graybox_store.tscn` for production visuals.

Implementation:

- Move legacy references into archive docs or compatibility notes.
- Either keep `graybox_store.tscn` as a small integration fixture or rename/archive it after all tests and tools stop depending on it.
- Remove duplicated visual changes from the legacy scene only after the production scene is the validated source.

Exit criteria:

- No active doc sends implementation work to `graybox_store.tscn`.
- Tests and screenshot tools target `store_world.tscn` or reusable modules.
- Legacy scene is clearly marked as historical or test-only.

## Tests Required

Add or update GUT coverage for:

- `store_world.tscn` loads.
- Player spawn remains on the mall concourse.
- Storefront threshold remains walkable.
- Required module instances exist under `WorldModules`.
- Core systems exist under `Systems`.
- Register, backroom computer, receiving box, display rack, customer manager, and fixture placement manager still resolve.
- Decorative visual details stay non-colliding.
- Screenshot anchors exist and point at the production scene.
- `graybox_store.tscn` is not used as the long-term production scene after promotion.
- `graybox_store.tscn` still loads as a compatibility wrapper during the review cycle.

Do not remove current `graybox_store` tests until production-world tests cover the same behavior. For now the test filename remains `test_graybox_store.gd` for continuity, but its main scene target is `store_world.tscn`.

## Documentation Required During Implementation

Update these with each migration slice:

- `docs/status.json`
- `docs/CURRENT_STATE.md`
- `docs/visual-production/12-implementation-roadmap.md`
- `docs/visual-production/17-scene-architecture-modularization.md`
- `docs/production/04-backlog.md`
- `docs/production/06-validation.md` only if validation numbers or artifact behavior changes.
- `docs/qa/screenshot-review.md` only if screenshot targets, names, or approval surfaces change.

## Non-Goals

Do not use this pass to:

- Redesign the whole store layout.
- Add full product catalog visuals.
- Add customers to the opening state.
- Change economy, day loop, trade-ins, supplier ordering, or release allocation.
- Replace every CSG primitive with imported meshes.
- Improve every screenshot composition at once.

This pass is about ownership and modularity. Visual quality may improve as a side effect, but it is not the primary acceptance criterion.

## Risks

- Scene paths can break interaction tests if modules are extracted without stable references.
- Screenshot tools can silently keep targeting the legacy scene if docs and scripts are not updated together.
- Duplicating the whole scene first can create two divergent production surfaces; parity slices must stay short.
- Moving system managers too early can turn a visual architecture pass into a gameplay rewrite.
- Keeping `graybox_store.tscn` forever as the primary scene will continue the current sprawl problem.

## Validation

Every slice must finish with:

```text
scripts/validate_godot.sh
```

Manual review should inspect:

- `main_scene.png`
- `storefront_entry.png`
- `fixture_placed.png`
- `receiving_area.png`
- `backroom_summary.png`
- latest screenshot contact sheet
- real 1280x720 walk from mall spawn through the storefront

## Approval Criteria

This modularization phase passes when:

- Production work has a production-named scene.
- Opening route and core gameplay systems are split into reusable modules.
- The full validation gate passes from the production scene.
- The screenshot harness captures the production scene.
- Active docs no longer imply that the long-term game world is `graybox_store.tscn`.

Current owner validation questions:

- Do the module boundaries match how future implementation should be divided?
- Is the manifest-first extraction enough for the next product/fixture visual pass, or should any module physically own child nodes before that work begins?
- Should `graybox_store.tscn` remain as a compatibility wrapper for one more visual cycle?
- Are `main_scene.png`, `storefront_entry.png`, and the contact sheet acceptable evidence for continuing into product/fixture art breadth?
