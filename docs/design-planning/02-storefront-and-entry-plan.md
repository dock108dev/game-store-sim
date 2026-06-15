# Storefront And Entry Plan

Implementation plan for the shop exterior, spawn view, first threshold, and first five seconds of readability.

## Goal

The player should understand within five seconds that they are in or entering a small specialty game store. The opening view must sell the store identity before the player learns menus, economy systems, or the day loop.

## Design Intent

The storefront is the player's first contract with the game. It should communicate:

- This is a deliberately built retail space, not a graybox room.
- The player is inside a specialty game shop with a storefront, display windows, product shelves, register, and backroom operations.
- The player can navigate toward shelves, register, receiving, and backroom without needing a tutorial paragraph.
- The exterior/entry language is present even if leaving the store is not supported yet.

## References

- `IMG_1033.PNG`: storefront massing, sign band, and entrance identity.
- `IMG_1034.PNG`: small-shop glass and threshold language.
- `IMG_1035.PNG`: window display density and shop-front merchandising.
- `IMG_1037.PNG`: compact retail signage hierarchy.
- `IMG_1038.PNG`: door/window frame rhythm.
- `IMG_1054.PNG`: first-view retail orientation.
- `IMG_1055.PNG`: entry route and interior landmark framing.

## Current Implementation State

Implemented in `graybox_store.tscn`:

- Facade piers and door-frame segmentation.
- Threshold strip and entry route stripes.
- Storefront glass/window-display prop stack.
- Window shelf deck, cases, controller props, poster card, console box, and platform stack.
- `BackroomHintFromEntryPanel` to keep office/stockroom direction visible from the opening composition.
- Scene tests covering storefront cue presence and first-view landmarks.

This is enough to support the current owner review. Future work should refine the entry into final art, not re-argue the spatial contract.

## Scope

### In Scope

- First-person spawn composition.
- Storefront sign and shop identity.
- Glass, door, frame, threshold, and window-display cues.
- Entry-to-register and entry-to-shelf visual routes.
- Early backroom hinting without making the backroom feel like the first required objective.
- Screenshot acceptance for `main_scene.png` and `storefront_entry.png`.

### Out Of Scope

- Playable exterior street.
- Working front door exit.
- Final logo/brand art.
- NPCs entering from outside.
- Animated exterior traffic or day/night storefront states.

## Player Read Contract

From the opening camera:

1. The sign band and window display should identify the place as a game store.
2. The register should be visible as a near-term service target.
3. At least one stocked shelf/wall should be visible as the product target.
4. The backroom hint should be visible but secondary.
5. The reticle, prompt, and center view should not be blocked by ceiling, giant signage, or near-camera props.

## Implementation Plan

### 1. Spawn Composition

Build requirements:

- Camera starts with shop identity, register, shelf wall, and backroom hint in view.
- Ceiling occupies a supporting background role, not the dominant first-view shape.
- The bottom prompt area stays visually calm.
- The first movement route is readable without floor arrows becoming gamey.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/tools/capture_main_scene_screenshot.gd`

Tests:

- Assert first-view landmarks exist.
- Assert spawn remains above floor and in valid store footprint.
- Assert storefront/entry props stay non-colliding where they are visual-only.

### 2. Storefront Identity

Build requirements:

- Sign band reads as store identity from entry screenshots.
- Glass panels have display content behind them.
- Door frame and open-hours decal imply a shop entrance.
- Trade/service decal previews broader store workflows.
- Storefront does not imply unsupported free-roam exterior play.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/tests/gut/test_graybox_store.gd`

Tests:

- Assert sign, door, glass, decal, and display nodes exist.
- Assert signage text remains fictional and short.
- Assert doorway remains blocked/managed until exit gameplay exists.

### 3. Threshold Material Language

Build requirements:

- Exterior/interior boundary reads through trim, floor strip, lighting contrast, and door framing.
- Wall and floor surfaces should no longer be a single uninterrupted gray read.
- Entry strip guides the player inward without becoming a fake interaction target.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/tests/gut/test_graybox_store.gd`

Tests:

- Assert trim, threshold, route stripes, and shell cues exist.
- Assert visual-only surfaces do not add collision.
- Assert route elements do not obstruct the register or shelf path.

### 4. Window Display

Build requirements:

- Window display includes small products, platform boxes, poster cards, and a clear shelf deck.
- Props should look like retail merchandising, not loose debug blocks.
- Props should be low enough and offset enough that they do not dominate the spawn camera.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/tests/gut/test_graybox_store.gd`

Tests:

- Assert display props are present and inside the storefront zone.
- Assert props are non-colliding unless intentionally interactive.
- Assert display density does not block entry route or prompt readability.

## File Impact Matrix

| File | Role | Change Type |
| --- | --- | --- |
| `game/scenes/world/graybox_store.tscn` | Storefront/entry geometry and props | Primary implementation |
| `game/tests/gut/test_graybox_store.gd` | Scene contract assertions | Required with scene changes |
| `game/tests/tools/capture_main_scene_screenshot.gd` | Screenshot framing | Update if spawn/framing changes |
| `game/tests/validation/scenarios/screenshots.json` | Screenshot scenario registry | Update if screenshot names/framing change |
| `docs/qa/screenshot-review.md` | Human review checklist | Update if acceptance changes |
| `docs/design-planning/08-quality-bar-checklist.md` | Cross-slice checklist | Update when criteria change |

## Screenshot Acceptance

### `main_scene.png`

Pass criteria:

- Reads as a small game shop within one glance.
- Includes store identity, product shelf, register silhouette, and backroom hint.
- No large blank ceiling/wall plane dominates.
- Prompt/reticle region stays clear.

Fail criteria:

- Looks like an empty graybox.
- Requires design docs to explain what room it is.
- Storefront or signage blocks the actual playable route.

### `storefront_entry.png`

Pass criteria:

- Shows door, glass, sign/identity, threshold, and display merchandising.
- Entrance reads as an intentional shop threshold.
- Does not promise unsupported exterior traversal.

Fail criteria:

- Glass/signage is unreadable.
- Threshold reads as a wall, not a shop entrance.
- Window props block pathing or prompts.

## Automated Validation

Required:

```text
scripts/validate_godot.sh
```

Focused checks before full validation:

```text
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit
```

Relevant GUT surfaces:

- `test_graybox_store.gd`
- `test_alpha_regression_coverage.gd`

## Manual Review

Review in this order:

1. Open `artifacts/validation/latest/screenshots/main_scene.png`.
2. Open `artifacts/validation/latest/screenshots/storefront_entry.png`.
3. Compare against `docs/design-planning/08-quality-bar-checklist.md`.
4. If either screenshot fails, file the exact screenshot name and reason in `docs/production/13-alpha-bug-list.md`.

## Risks

- Overbuilding the storefront could imply a playable exterior before that system exists.
- Dense signage can solve identity while hurting prompt readability.
- Window props can make the first view feel cluttered if they sit too close to the camera.
- A strong backroom hint can accidentally make the backroom look like the first objective instead of a later management space.

## Completion Criteria

This plan is complete when:

- Storefront and entry props are implemented and tested.
- `main_scene.png` and `storefront_entry.png` are part of the required screenshot set.
- Full validation passes.
- Owner screenshot review either approves the entry read or files targeted rework.
- Future exterior expansion can build from this threshold without changing the opening-store spatial contract.
