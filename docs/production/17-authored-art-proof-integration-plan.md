# Authored Art Proof Integration Plan

Status: Pending owner visual review

This doc exists so the new art proof does not get confused with completed production integration.

## Current Proof

The current proof replaces the rejected procedural hero slice with:

- repo-local generated bitmap assets in `game/assets/art_proof/generated/`
- isolated runtime scene at `game/scenes/world/art_benchmark/hero_art_slice.tscn`
- scene builder at `game/scripts/world/hero_art_slice_scene.gd`
- deterministic review board at `docs/production/images/hero_art_slice_review_board.png`

The proof is intentionally isolated. It does not edit `store_world.tscn`, customer logic, inventory logic, fixture placement, save/load, or register flow.

## What This Proves

The proof tests whether this production method is worth carrying forward:

- baked legal-safe bitmap signage instead of live 3D text
- fictional cover art and hardware package art
- sparse pre-day-one starter inventory
- mall storefront composition
- visible first-store growth space
- fixture/counter/storefront object families that can become modules later

## What It Does Not Prove Yet

- final production mesh quality
- full playable-store integration
- fixture placement compatibility
- inventory-slot automation
- final catalog breadth
- customer pathing around the new geometry

## If Owner Approves

Create constrained implementation packets in this order:

1. Product packaging module replacement: convert starter DVD cases, console box, and accessory pack into reusable runtime modules.
2. Fixture module replacement: convert the starter rack/display into inventory-slot compatible fixtures.
3. Storefront/shell module replacement: replace the current primitive mall/storefront first-read with the approved visual language.
4. Counter module replacement: rebuild the cash-wrap/display/register area while preserving register/trade-in contracts.
5. Integration route: swap approved modules into `store_world.tscn`, then run full regression validation and owner screenshots.

## If Owner Rejects

Do not polish this proof as a broad implementation pass.

Instead, change production method again before touching the playable scene. Likely options:

- real Blender-authored `.glb` modules
- licensed low-poly retail/mall asset pack
- engine/tooling change if Godot scene assembly remains the blocker

## Validation Boundary

`scripts/validate_godot.sh` remains regression evidence only. Owner review of the proof image decides whether this art direction can move into implementation.
