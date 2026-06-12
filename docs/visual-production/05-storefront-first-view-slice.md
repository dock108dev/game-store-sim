# Storefront First View Slice

## Goal

Make the first standing view look like an authored mid-00s independent game shop, not a labeled blockout.

This slice should be reviewed before replacing the whole store.

## Implementation Status

First phase 0-4 pass failed owner screenshot review. Current reset implementation starts the player on a second-floor mall concourse facing the branded storefront, with neon/glass framing, a walkable open door, neighboring closed shopfront cues, planters, railings, and no visible customers or employees before opening. This is a better composition, not a finished visual baseline. The follow-up implementation must replace visible box/label graphics on this route with authored assets before adding breadth.

## Scope

In scope:

- Second-floor mall concourse spawn.
- Storefront wall.
- Glass door/window.
- Sign band.
- Window display.
- Entry mat and threshold.
- Walkable route from concourse into the store.
- Initial outside-in sightline to the storefront; register/shelf/backroom detail becomes the next interior-corner slice.
- Lighting visible from spawn.
- Day-one restraint: visible merchandise should suggest a newly opening shop, not a mature full-catalog store.
- Pre-open restraint: no customers or employees visible in the opening scene.

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
- Mall concourse tile kit.
- Atrium railing/posts.
- Closed neighboring shopfront/shutter kit.
- Planter/cafe/directory props.
- Store sign mesh/decal.
- Window poster set.
- Window display shelf.
- Boxed products for display.
- Entry mat.
- Floor/wall/trim materials.
- Authored replacements for visible CSG blockout forms on the opening route.

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

- Player starts outside the store on a second-floor mall concourse and can walk in.
- Player can identify the store as a game shop before reading small labels.
- Storefront has real frame/glass/display depth.
- Storefront reads through silhouette, glass, trim, neon, and display props, not just a floating label.
- Mall, storefront, threshold, and first interior objects no longer read as raw boxes with labels.
- Posters and display products feel fictional but era-appropriate.
- First view has authored composition.
- The opening state is quiet and pre-open: no customers or employees visible.
- Register and shelf route become legible after entering, without dominating the initial exterior frame.
- Empty or lightly stocked areas read as intentional early-shop capacity.
- No unsupported exterior interaction is implied.

## Fail Criteria

- View still reads as white walls plus labels.
- View still reads as box graphics with labels.
- Store identity depends on a floating sign only.
- Window display is sparse or random.
- First view implies the full catalog is already available on day one.
- Entry props block movement or prompt sightlines.
