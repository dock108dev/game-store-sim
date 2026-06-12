# Storefront First View Slice

## Goal

Make the first standing view look like an authored mid-00s independent game shop, not a labeled blockout.

This slice should be reviewed before replacing the whole store.

## Scope

In scope:

- Storefront wall.
- Glass door/window.
- Sign band.
- Window display.
- Entry mat and threshold.
- Initial sightline to register, shelf wall, and backroom hint.
- Lighting visible from spawn.
- Day-one restraint: visible merchandise should suggest a newly opening shop, not a mature full-catalog store.

Out of scope:

- Full sales-floor replacement.
- Full backroom replacement.
- Full sales-floor stocking.
- Full catalog visibility.
- New gameplay mechanics.

## Assets Needed

- Modular storefront frame.
- Glass material.
- Door frame and handle.
- Store sign mesh/decal.
- Window poster set.
- Window display shelf.
- Boxed products for display.
- Entry mat.
- Floor/wall/trim materials.

## Implementation Files

Likely affected:

- `game/scenes/world/graybox_store.tscn`
- future `game/assets/visual/meshes/store_shell/*`
- future `game/assets/visual/textures/posters/*`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/validation/scenarios/screenshots.json`
- `docs/qa/screenshot-review.md`

## Acceptance Screenshots

- `main_scene.png`
- `storefront_entry.png`

## Pass Criteria

- Player can identify the store as a game shop before reading small labels.
- Storefront has real frame/glass/display depth.
- Posters and display products feel fictional but era-appropriate.
- First view has authored composition.
- Register and shelf route remain legible.
- Empty or lightly stocked areas read as intentional early-shop capacity.
- No unsupported exterior interaction is implied.

## Fail Criteria

- View still reads as white walls plus labels.
- Store identity depends on a floating sign only.
- Window display is sparse or random.
- First view implies the full catalog is already available on day one.
- Entry props block movement or prompt sightlines.
