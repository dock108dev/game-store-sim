# Storefront And Entry Plan

Implementation plan for the shop exterior, spawn view, and first threshold.

## Goal

The player should understand within five seconds that they are in or entering a small specialty game store.

## References

- `IMG_1033.PNG`
- `IMG_1034.PNG`
- `IMG_1035.PNG`
- `IMG_1037.PNG`
- `IMG_1038.PNG`
- `IMG_1054.PNG`
- `IMG_1055.PNG`

## Build Tasks

1. Recompose spawn.
   - Lower ceiling dominance.
   - Show store identity, register, shelf wall, and backroom hint.
   - Keep reticle and bottom prompt clear.

2. Build storefront identity.
   - Sign band.
   - Glass panels.
   - Door frame.
   - Open-hours decal.
   - Trade/service decal.
   - Window display shelf.

3. Add facade material language.
   - Exterior trim.
   - Interior threshold floor strip.
   - Warm/cool contrast from outside to inside.
   - Avoid one-color walls.

4. Add first-view composition props.
   - Small display products behind glass.
   - Poster cards.
   - Counter silhouette.
   - Category sign hints.

## Files To Expect

- `game/scenes/world/graybox_store.tscn`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/tools/capture_main_scene_screenshot.gd`
- `game/tests/validation/scenarios/screenshots.json`
- `docs/qa/screenshot-review.md`

## Acceptance

- `main_scene.png` reads as a game shop without docs.
- `storefront_entry.png` shows a real threshold and readable store identity.
- No storefront prop implies the player can leave if leaving is unsupported.
- Path from entry to register, shelf, receiving, and backroom remains visible.

## Test

- Run focused scene tests if updated.
- Run `scripts/validate_godot.sh`.
- Review `main_scene.png` and `storefront_entry.png` in a real 1280x720 window.
