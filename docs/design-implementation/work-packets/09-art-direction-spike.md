# Work Packet: Art Direction Spike

Status: Ready
Owner decision required: Yes
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/15-art-direction-reset-and-spike-plan.md`
Dependencies: `docs/production/14-owner-visual-review-package.md`, `docs/design-source-of-truth/`, `inspiration/`, `new_real_inspiration/`
Expected commit scope: reference extraction, asset workflow plan, isolated art-spike scene/assets if implementation starts, screenshot review board, and owner handoff

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

1. Reference extraction notes from `inspiration/`.
2. Period retail extraction notes from `new_real_inspiration/`.
3. Asset workflow notes: custom Blender modules, allowed packs, texture approach.
4. Isolated spike scene or mockup.
5. Owner-facing screenshot/review board.
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

## Validation Required

Minimum:

- screenshot proves the art direction better than current visual baseline
- screenshot notes cite the `inspiration/` and `new_real_inspiration/` rules used
- no major primitive-cube read in the hero view
- owner can judge the look without reading implementation chat

Optional if implemented in Godot:

- Godot scene load smoke
- screenshot capture script for the spike

Full gameplay validation is not required until the approved art kit is integrated into the playable store.

## Stop Conditions

- Reference extraction cannot produce a coherent small-chain visual target.
- Legally clean assets cannot be sourced and custom asset creation is not feasible in this pass.
- Blender/Godot import workflow blocks authored module creation.
- The art spike still reads like the current primitive route.
- Owner needs to choose between multiple viable art directions.

## Final Handoff Requirements

- Reference board path or notes
- Real-life reference notes
- Spike scene/mockup path
- Screenshot path
- Asset source/licensing notes
- What improved versus current
- What still fails
- Recommendation: approve, revise, or block
