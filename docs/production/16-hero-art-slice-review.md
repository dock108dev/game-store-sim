# Hero Art Slice Review

Status: Authored replacement proof ready for owner review

Owner decision needed: review the replacement proof board and decide whether this art-production method is good enough to turn into constrained production integration packets.

Previous owner rejection notes:

- text appears inverted
- the view reads like the screen is shaking
- the visual result is still not close to the desired shop feel

Engineering interpretation: the shaking read is likely z-fighting/flicker from overlapping procedural panels and transparent/billboard geometry, and the inverted text comes from generated panel orientation. Fixing those two symptoms would not solve the larger issue: this is still a procedural Godot box/quad proof, not an authored art-production method.

That first procedural proof is dead as a baseline. The current proof replaces it with baked bitmap assets and a simpler isolated art scene.

## Scope

This review is for the isolated hero art proof scene only:

- Scene: `res://scenes/world/art_benchmark/hero_art_slice.tscn`
- Script: `res://scripts/world/hero_art_slice_scene.gd`
- Capture tool: `res://tests/tools/capture_hero_art_slice_screenshot.gd`
- Asset generator: `tools/generate_hero_art_proof_assets.py`
- Review-board renderer: `tools/render_hero_art_review_board.py`
- Review board: `docs/production/images/hero_art_slice_review_board.png`

The playable store, mechanics, catalog, customers, employees, and `store_world.tscn` remain out of scope.

## What Changed In The Replacement Proof

The hero scene and review board now use:

- `Games4U` small-chain storefront identity
- second-floor mall concourse context
- glass panes, mullions, open door, fascia, threshold, lit trim, and tile transition
- visible first 15-20 feet of store interior
- right-side cash-wrap/display case with register, scanner, bags, and controller prop
- starter wall rack with visible empty capacity
- sparse day-one starter products: `Footy 2002`, `Critter Quest II`, one Vortex console box, and one controller accessory pack
- baked legal-safe bitmap cover art, console box art, sign art, poster art, and floor/carpet textures
- no live Godot text panels for the visible proof
- no customer, employee, catalog, or mechanics integration

## Validation Result

Does this proof board prove the visual method enough to continue into production integration?

Answer: pending owner review.

Do not continue into production integration until owner review answers yes.

Owner review options:

1. Approve the authored proof method and create constrained integration packets.
2. Reject the proof and change production method again before touching the playable scene.

## Current Direction

The proof stops relying on visible procedural Godot text panels for art readability. It uses:

- repo-local generated bitmap assets
- isolated Godot runtime scene assembly
- screenshot/review-board-first validation
- explicit future integration boundary in [Authored Art Proof Integration Plan](17-authored-art-proof-integration-plan.md)

If this still fails owner review, the next production-method change should be real Blender-authored `.glb` modules or licensed retail/mall asset packs.

## Review Board

Open:

```text
docs/production/images/hero_art_slice_review_board.png
```

This board was generated from repo-local art assets and is the current owner-facing proof artifact.

## Local Review Window

Use this to review the isolated Godot scene. The window stays open until you close it:

```bash
/Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/michaelfuscoletti/Desktop/game-store-sim/game \
  --script res://tests/tools/capture_hero_art_slice_screenshot.gd \
  -- \
  --keep-open \
  --width 1600 \
  --height 900
```

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

Use the review board and local scene window, not `scripts/validate_godot.sh`, as the art approval artifact.
