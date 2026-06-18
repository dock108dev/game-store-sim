# Work Packet: Visual Module Foundation

Status: Complete
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/02-visual-module-system-spec.md`
Dependencies: `docs/design-implementation/09-density-and-clutter-rules.md`, `docs/design-implementation/11-lighting-materials-and-color-palette-spec.md`
Expected commit scope: reusable material/module foundation for the opening-store visual reset

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `docs/design-implementation/work-packets/00-packet-index.md`
5. `docs/design-implementation/02-visual-module-system-spec.md`
6. `docs/design-implementation/09-density-and-clutter-rules.md`
7. `docs/design-implementation/11-lighting-materials-and-color-palette-spec.md`

## Context

- Current problem: the store still risks reading as raw cubes, scattered primitives, and temporary prototype geometry.
- Target player-facing result: reusable low-poly modules that make the later store shell, fixtures, lighting, and product displays feel intentional before detailed art arrives.
- Existing systems that must keep working: movement, collision, click-first interaction, fixture placement, stocking, save/load, screenshot capture.
- Visual/design docs that define success: module system, density rules, lighting/material palette.
- Known prior failures to avoid: visible raw CSG/cube assets, mismatched material palette, over-dark store, labels doing the work of object identity, module collision blocking routes.

## In Scope

- Establish reusable material resources for store walls, mall walls, carpet, laminate, black metal, glass, cardboard, price-label paper, and sign panels.
- Establish reusable lighting modules for bright retail fluorescent panels and warmer mall ambient fixtures.
- Establish reusable prop/module scene patterns with clear naming, anchors, collision expectations, and replaceability.
- Create module folders and file naming rules where the current repo needs them.
- Add small import/load or scene-contract tests if new reusable scenes/scripts require them.
- Update docs if implementation discovers a better module path or naming convention.

## Out Of Scope

- Full store shell build.
- Final storefront assembly.
- Product catalog art breadth.
- Customer or employee visuals.
- Hidden narrative props.
- Beta/tester packaging.
- Replacing core mechanics.

## Do Not Do

- Do not use visible debug labels as final object identity.
- Do not leave raw primitive cubes as final visible assets.
- Do not stage future locked inventory physically on the sales floor.
- Do not add clutter just to fill empty space.
- Do not create one-off assets when a reusable module is clearly needed.
- Do not make material choices that force a single uneditable store palette.
- Do not break collision, nav, stocking, or click interaction to improve appearance.
- Do not replace visual review with automated-test success.
- Do not revert unrelated user/agent changes.

## Implementation Plan

1. Inspect current scene, asset, material, and script structure.
2. Identify existing helper patterns for generated meshes, scenes, resources, and validation.
3. Define the module folder/naming structure using repo conventions.
4. Implement the core material set.
5. Implement reusable light/module scenes or resources.
6. Add anchors/collision metadata where current systems need it.
7. Update docs/tests/status only if behavior or active docs change.
8. Capture final screenshots of module use if any are integrated into visible scenes.
9. Run focused tests, then `scripts/validate_godot.sh` for implementation work.
10. Commit and push.

## Likely Files

Scenes:
- `game/scenes/**/*.tscn`
- `game/scenes/modules/**/*.tscn`
- `game/scenes/visual_modules/**/*.tscn`

Scripts:
- `game/scripts/**/*.gd`
- existing scene-builder or fixture helper scripts if present

Assets:
- `game/assets/materials/**`
- `game/assets/textures/**`
- `game/assets/visual_modules/**`

Data:
- placement/module metadata if already used by the repo

Tests:
- `game/tests/gut/**`
- `game/tests/validation/**`

Docs:
- `docs/design-implementation/02-visual-module-system-spec.md`
- `docs/design-implementation/work-packets/01-visual-module-foundation.md`
- `docs/status.json` only if status metadata changes

## Validation Required

Implementation packet:

- Capture final game-window screenshots first when visible modules are integrated.
- Review screenshots with notes about whether modules still read as cubes.
- Run focused tests for changed contracts.
- Run `scripts/validate_godot.sh`.
- Confirm artifacts under `artifacts/validation/latest/`.

Do not claim validation passed unless commands ran in the current implementation pass.

## Screenshot Evidence

Required final screenshots:

- module/material use in the store if integrated into the main scene
- close readable angle of wall, floor, light, glass/sign, and fixture material families
- route/collision screenshot if modules changed movement space

Use game-window screenshots unless editor mode is needed to show anchors/collision.

## Tests To Add Or Update

- Add scene/resource load tests for new reusable module scenes if the repo has matching patterns.
- Add contract tests for new module metadata if new data is introduced.
- Update screenshot target metadata only if new required screenshots are added.

## Tests To Run

- focused GUT tests for touched scripts/scenes
- `scripts/validate_godot.sh`

## Documentation Updates

- Update the module spec if final paths/names differ from the planned structure.
- Update packet decision log for assumptions and rejected approaches.
- Do not update validation baseline counts unless tests actually change.

## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
| Main store integration stays sequential. | Module assets can be built alone, but the store scene is shared and high-risk. | No | Packet 02 integrates shell modules. |
| Visual module manifests now declare owned visuals, collision nodes, anchors, and material resources. | Future scene edits need a testable implementation contract, not just a loose module name. | No | Packet 02 must keep these manifests current while reshaping the shell. |
| Store systems module remains a nonvisual ownership wrapper. | Gameplay managers should stay separable from visual module contracts. | No | Keep it out of visual-quality assertions unless systems gain visible debug surfaces. |
| Validation baseline moved to 571 GUT tests and 10908 asserts. | The packet added a visual-module implementation contract test. | No | Full production gate still required after visible scene integration. |

## Stop Conditions

- Modules still read as raw cubes/prototype after material/shape pass.
- Required module structure conflicts with existing mechanics.
- Collision or interaction systems require redesign.
- Material/lighting approach cannot meet the bright retail target.
- Validation exposes a blocker that cannot be fixed locally.

## Continue Conditions

- Reusable modules load cleanly.
- Existing mechanics remain preserved.
- Store/mall materials and lights are ready for shell assembly.
- Any visual shortcomings are fixable in packet 02 or 07 without owner decision.

Current result:

- Visual module manifest script exposes module, visual, collision, anchor, and material dependency checks.
- Main world visual modules publish explicit implementation contracts against current scene nodes.
- GUT passes with 571 tests and 10908 asserts.
- Full `scripts/validate_godot.sh` remains required after Packet 02 visible shell integration.

## Final Handoff Requirements

- Commit hash
- Branch
- Screenshots/contact-sheet paths
- Validation command/result
- New module/material paths
- Known residual issues
- Owner/lead decisions needed
