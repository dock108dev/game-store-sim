# Work Packet: Art Direction Spike

Status: Implemented, awaiting owner visual review
Owner decision required: Yes
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/15-art-direction-reset-and-spike-plan.md`
Dependencies: `docs/production/14-owner-visual-review-package.md`, `docs/design-source-of-truth/`, `inspiration/`, `new_real_inspiration/`
Expected commit scope: reference extraction, asset workflow plan, isolated art-spike scene/assets, screenshot review board, and owner handoff

## Implementation Result

Packet 09 is implemented as a separate, non-playable visual proof scene. It does not modify `store_world.tscn` or the current mechanics prototype. Revision 2 incorporates owner feedback that the first spike had weird text, cluttered walls, too much color, and still read too much like a graybox.

Implemented files:

- `game/scenes/world/art_benchmark/packet_09_inside_out_art_spike.tscn`
- `game/scripts/world/packet_09_art_spike_scene.gd`
- `game/tests/tools/capture_packet_09_art_spike_screenshot.gd`
- `game/tests/gut/test_packet_09_art_spike.gd`

Review artifacts:

- `artifacts/validation/latest/packet-09-art-spike-review-board.png`
- `artifacts/validation/latest/screenshots/packet_09_inside_out_art_spike.png`
- `artifacts/validation/latest/screenshots/packet_09_shelf_density.png`
- `artifacts/validation/latest/screenshots/packet_09_storefront_frame.png`

Owner decision needed: approve, revise, or block the Packet 09 visual method before rebuilding the playable store visuals.

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/production/14-owner-visual-review-package.md`
3. `docs/design-implementation/15-art-direction-reset-and-spike-plan.md`
4. `docs/design-source-of-truth/README.md`
5. `docs/qa/screenshot-review.md`
6. `inspiration/`
7. `new_real_inspiration/`

## Context

- Owner selected the block path: current visual direction misses badly enough to require a deeper art-production reset.
- Godot remains the runtime and mechanics integration target for now.
- The current playable scene is frozen as a mechanics prototype, not the visual baseline.
- The next proof must be an art-direction spike, not another graybox polish pass.
- The target is late-PS2 / early low-poly 3D with bitmap textures.
- Blender-authored modular assets and legally clean third-party packs are allowed.
- The first proof shot is inside looking out.
- The vibe is small chain game store.
- Layout/facade/footprint may change heavily.

## In Scope

- Audit the `inspiration/` folder and extract concrete visual rules.
- Audit the `new_real_inspiration/` folder and extract concrete real-life period retail rules.
- Define the minimum module kit for the inside-looking-out shot.
- Source candidate legally clean asset packs if useful.
- Build or assemble an isolated art-spike scene.
- Use authored modules, trims, bevels, material breaks, and bitmap detail.
- Capture a large owner-facing review screenshot or board.
- Compare the spike against the current screenshot baseline.
- Document whether the spike is approved, needs revision, or blocks the current toolchain.

## Out Of Scope

- Full playable store rebuild.
- Broad catalog expansion.
- Customer visuals.
- Employee visuals.
- Hidden narrative.
- Beta/tester package.
- Reworking existing mechanics unless needed to load the art spike.

## Do Not Do

- Do not continue adding primitive cube props to `store_world` as the visual answer.
- Do not use labels as the main readability mechanism.
- Do not judge success from `validate_godot.sh`.
- Do not rebuild the whole store before one hero shot works.
- Do not change engines before proving the art workflow failure is engine-related rather than pipeline-related.

## Deliverables

1. Reference extraction notes from `inspiration/`: storefront glass rhythm, mall corridor framing, fascia/sign proportion, small-chain storefront composition.
2. Period retail extraction notes from `new_real_inspiration/`: drop ceiling, slatwall, dense rows of case facings, yellow price stickers, acrylic/glass display surfaces, commercial tile/carpet.
3. Asset workflow notes: procedural Godot proof with bitmap-like generated textures; loose `TextMesh` signage and random wall promo cards are removed; next approved production pass should convert this into authored reusable modules/assets rather than expanding the current primitive store scene.
4. Isolated spike scene or mockup: `game/scenes/world/art_benchmark/packet_09_inside_out_art_spike.tscn`.
5. Owner-facing screenshot/review board: `artifacts/validation/latest/packet-09-art-spike-review-board.png`.
6. Decision handoff: approve, revise, or block.

## Target Shot

Inside looking out:

- player/camera is inside the store
- storefront glass, door, sign/fascia, and frames are visible
- mall or small-chain corridor exterior is visible beyond the glass
- first 10-15 feet of interior are visible
- one counter or shelf anchor is visible
- no customers or employees
- no debug labels
- minimal text, limited to flat bitmap sign panels
- walls read as shopfit/slatwall architecture rather than random decoration

## Validation Required

Minimum:

- screenshot proves the art direction better than current visual baseline
- screenshot notes cite the `inspiration/` and `new_real_inspiration/` rules used
- no major primitive-cube read in the hero view
- no loose 3D text/sign labels as the main readability mechanism
- no random promo wall panels filling empty space
- owner can judge the look without reading implementation chat

Optional if implemented in Godot:

- Godot scene load smoke
- screenshot capture script for the spike

Full gameplay validation is not required until the approved art kit is integrated into the playable store.

Packet 09 validation commands:

```text
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://addons/gut/gut_cmdln.gd -gtest=res://tests/gut/test_packet_09_art_spike.gd -gexit
/Applications/Godot.app/Contents/MacOS/Godot --path game --resolution 1280x720 --fixed-fps 1 --disable-vsync --quiet --script res://tests/tools/capture_packet_09_art_spike_screenshot.gd -- --output /Users/michaelfuscoletti/Desktop/game-store-sim/artifacts/validation/latest/screenshots/packet_09_inside_out_art_spike.png --width 1280 --height 720 --view inside_out
```

Screenshot sanity is checked with `res://tests/tools/check_png.gd`; broader regression is still `scripts/validate_godot.sh`.

## Stop Conditions

- Reference extraction cannot produce a coherent small-chain visual target.
- Legally clean assets cannot be sourced and custom asset creation is not feasible in this pass.
- Blender/Godot import workflow blocks authored module creation.
- The art spike still reads like the current primitive route.
- Owner needs to choose between multiple viable art directions.

## Final Handoff Requirements

- Reference board path or notes: this document plus `artifacts/validation/latest/packet-09-art-spike-review-board.png`.
- Real-life reference notes: extracted from `new_real_inspiration/` into dense shelving, drop ceiling, store tile/carpet, price stickers, and glass display counter choices.
- Spike scene/mockup path: `game/scenes/world/art_benchmark/packet_09_inside_out_art_spike.tscn`.
- Screenshot path: `artifacts/validation/latest/screenshots/packet_09_inside_out_art_spike.png`.
- Asset source/licensing notes: no third-party art pack used in this spike; the proof uses generated Godot geometry/materials and generated bitmap-like textures.
- What improved versus current: cleaner storefront rhythm, stronger ceiling/material read, denser but more orderly product facings, flat bitmap sign panels instead of loose 3D text, calmer color palette, clean slatwall instead of random wall clutter, and an isolated scene that avoids touching mechanics.
- What still fails: still not a finished production art kit; signage and product art are proof-level, not final authored assets; playable store has not been rebuilt around this method; owner may still decide the procedural/low-poly method is not enough.
- Recommendation: owner review. Approve this method for playable-store rebuild, request specific revisions to the spike, or block and change the art-production approach again.
