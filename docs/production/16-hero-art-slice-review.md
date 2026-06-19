# Hero Art Slice Review

Status: Pending owner visual validation

## Scope

This review is for the isolated hero art proof scene only:

- Scene: `res://scenes/world/art_benchmark/hero_art_slice.tscn`
- Script: `res://scripts/world/hero_art_slice_scene.gd`
- Capture tool: `res://tests/tools/capture_hero_art_slice_screenshot.gd`

The playable store, mechanics, catalog, customers, employees, and `store_world.tscn` remain out of scope.

## What Changed

The hero scene builds a single mall storefront proof shot with:

- `Games4U` small-chain storefront identity
- second-floor mall concourse context
- glass panes, mullions, open door, fascia, threshold, lit trim, and tile transition
- visible first 15-20 feet of store interior
- right-side cash-wrap/display case with register, scanner, bags, and controller prop
- starter wall rack with visible empty capacity
- 2-3 starter product anchors, generated case art, console box art, and accessory packaging
- no customer, employee, catalog, or mechanics integration

## Validation Question

Does this screenshot prove the visual method enough to continue into production integration?

Answer options for owner review:

1. Approve this direction and convert it into production modules.
2. Request a focused enhancement pass on this hero scene.
3. Reject the method and change art-production approach before more Godot implementation.

## Local Capture

Headless capture can fail under Godot's dummy renderer because no viewport texture is available. Run the capture tool from a normal Godot window/session:

```bash
/Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/michaelfuscoletti/Desktop/game-store-sim/game \
  --script res://tests/tools/capture_hero_art_slice_screenshot.gd \
  -- \
  --output res://../artifacts/validation/latest/screenshots/hero_art_slice.png \
  --width 1600 \
  --height 900
```

Expected output:

```text
artifacts/validation/latest/screenshots/hero_art_slice.png
```

Use the screenshot, not `scripts/validate_godot.sh`, as the art approval artifact.
