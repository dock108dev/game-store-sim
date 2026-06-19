# Work Packet: Hero Art Slice Proof

Status: Implemented, pending owner screenshot validation
Owner decision required: Yes
Target branch: `codex/hard-visual-benchmark-implementation`
Primary docs: `docs/production/15-failed-visual-validation.md`, `docs/visual-bible/08-art-production-pipeline.md`
Expected commit scope: one isolated visual proof scene and minimal capture/test support only
Implemented scene: `game/scenes/world/art_benchmark/hero_art_slice.tscn`
Owner review note: `docs/production/16-hero-art-slice-review.md`

## Goal

Build one isolated screenshot-first art slice that proves the visual method before any more broad playable-store work.

This is not a gameplay slice. This is not a full-store rebuild. This is the new visual gate.

## Required Read First

1. `docs/production/15-failed-visual-validation.md`
2. `docs/CURRENT_STATE.md`
3. `docs/visual-bible/README.md`
4. `docs/visual-bible/01-store-shell-architecture.md`
5. `docs/visual-bible/02-fixtures-and-displays.md`
6. `docs/visual-bible/03-product-art-and-packaging.md`
7. `docs/visual-bible/05-counter-register-and-trade-in.md`
8. `docs/visual-bible/08-art-production-pipeline.md`

## Hard Rules

- Do not edit core mechanics.
- Do not polish `store_world.tscn`.
- Do not expand catalog, customers, employees, hidden narrative, or beta packaging.
- Do not use labels to make objects understandable.
- Do not use `scripts/validate_godot.sh` as visual approval.
- Do not spawn broad agents until the hero screenshot is visually accepted.

## Required Slice

Create one isolated art-proof scene, separate from the playable mechanics scene.

Implementation note: this scene now exists as `res://scenes/world/art_benchmark/hero_art_slice.tscn`. The next action is owner visual validation of the screenshot, not broad implementation.

The screenshot must include:

- mall or concourse storefront read
- `Games4U` or editable fictional small-chain identity
- glass, door, mullions, sign housing, threshold, and floor transition
- first 15-20 feet of interior
- one real-looking counter/cash-wrap area
- one real-looking shelf/rack/display fixture
- 2-3 product hero objects that read as game cases/console boxes before text
- simple lighting and material treatment that looks intentional

## Asset Method

Preferred method:

- authored mesh assets or imported `.glb` modules
- bitmap/detail texture sheets for product faces, posters, signage, trim, or case art
- Godot scene assembly for layout and lighting

Godot primitive boxes may be used only as hidden collision/proxy structure, not as the visible art language.

## Output Evidence

Required:

- one hero screenshot at 1280x720 or larger
- one scene-load test or lightweight smoke script
- short notes listing what is authored mesh, bitmap texture, or temporary placeholder
- explicit owner review question: “Does this screenshot prove the visual method?”

## Stop Conditions

Stop before implementation expands if:

- the screenshot still reads as primitive blocks
- product art still requires labels
- the asset workflow cannot produce better results inside Godot quickly
- changing engine/tooling appears necessary to hit the target

## Completion Definition

This packet is complete only when:

- the isolated scene loads
- the hero screenshot exists
- docs point to the screenshot
- owner review is requested
- no broad mechanics/playable-store changes were made

It is not complete because `validate_godot.sh` passes.
