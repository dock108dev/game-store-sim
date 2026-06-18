# Work Packet: Lighting Density And Integration Polish

Status: Complete
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/09-density-and-clutter-rules.md`
Dependencies: `docs/design-implementation/11-lighting-materials-and-color-palette-spec.md`, `docs/design-implementation/12-validation-and-screenshot-checklist.md`, all previous work packets
Expected commit scope: final integrated opening-store visual polish, route cleanup, screenshot composition, density tuning, and validation readiness

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `docs/design-implementation/work-packets/00-packet-index.md`
5. `docs/design-implementation/09-density-and-clutter-rules.md`
6. `docs/design-implementation/11-lighting-materials-and-color-palette-spec.md`
7. `docs/design-implementation/12-validation-and-screenshot-checklist.md`
8. Packets 01-06 final handoffs and decision logs

## Context

- Current problem: even if individual modules work, the final scene can still read as a mash of pieces, too dark, too empty, too cluttered, or still prototype-heavy.
- Target player-facing result: the opening store reads coherently as a bright, modest, underfunded 2002-2004 independent game store with a warmer mall approach and clear growth potential.
- Existing systems that must keep working: all core mechanics, routes, interactions, screenshots, validation tooling.
- Visual/design docs that define success: density rules, lighting/materials, validation checklist, source of truth.
- Known prior failures to avoid: over-dark interior, raw geometry silhouettes, clutter added to hide weak assets, route-blocking props, screenshot angles exposing prototype leftovers.

## In Scope

- Bright retail lighting pass.
- Warmer mall lighting contrast.
- Material tuning across carpet, walls, glass, fixtures, product cases, signage, and counter.
- Density tuning for empty-promising day-one state.
- Clutter removal.
- Route cleanup.
- Screenshot target composition.
- Contact-sheet review notes.
- Final fixes required for opening-store baseline review.

## Out Of Scope

- New broad product categories.
- New customer/employee visual systems.
- Hidden narrative content.
- Later-era platforms.
- Beta/tester package.
- Major layout redesign unless screenshots prove the integrated plan is wrong.

## Do Not Do

- Do not add random props to make the store feel finished.
- Do not use darkness to hide unfinished geometry.
- Do not tune screenshots only while leaving normal play angles broken.
- Do not let automated validation override bad screenshots.
- Do not broaden scope to decoration/customer/catalog work.
- Do not move core zones without checking downstream screenshots and mechanics.
- Do not ignore route/collision regressions for visual gain.

## Implementation Plan

1. Review final handoffs from packets 01-06.
2. Capture current final game-window screenshots before making polish changes.
3. Identify visual blockers by screenshot and walking route.
4. Tune lighting/materials/density/clutter/route composition.
5. Remove visible prototype leftovers and overlarge debug labels.
6. Adjust screenshot targets only when they miss the real review question.
7. Run focused tests for changed systems.
8. Run full `scripts/validate_godot.sh`.
9. Produce screenshot notes for packet 08.
10. Commit and push.

## Likely Files

Scenes:
- active store/main scene
- lighting scenes
- screenshot target scenes

Scripts:
- screenshot target/camera scripts if changed
- route/interaction scripts if movement blockers are corrected

Assets:
- lighting/material resources
- prop/module materials
- poster/sign/product material adjustments

Data:
- screenshot target manifests
- validation scenario data if screenshot coverage changes

Tests:
- screenshot sanity/target tests
- route/scene load tests
- focused tests for touched scripts

Docs:
- `docs/design-implementation/09-density-and-clutter-rules.md`
- `docs/design-implementation/11-lighting-materials-and-color-palette-spec.md`
- `docs/design-implementation/12-validation-and-screenshot-checklist.md`
- `docs/production/13-alpha-bug-list.md`

## Validation Required

Implementation packet:

- Capture final game-window screenshots first.
- Review screenshots with detailed notes before automated validation.
- Run focused tests for changed contracts.
- Run `scripts/validate_godot.sh`.
- Confirm artifacts under `artifacts/validation/latest/`.

## Screenshot Evidence

Required final screenshots:

- mall approach
- storefront entrance
- first interior view
- checkout/register
- stocked fixture/shelf
- product closeup
- stockroom doorway from sales floor
- receiving area inside stockroom
- 1280x720 walk-in route
- contact sheet

## Tests To Add Or Update

- Screenshot target tests if targets change.
- Scene/load tests if lighting or scene structure changes.
- Route/collision tests if fixtures or modules move.
- Validation manifest updates if screenshot set changes.

## Tests To Run

- focused tests for changed scenes/scripts
- screenshot capture/sanity if available separately
- `scripts/validate_godot.sh`

## Documentation Updates

- Update visual blocker list with resolved/new blockers.
- Update validation docs only if screenshot evidence requirements change.
- Prepare notes for packet 08 review package.

## Implementation Notes

- Tuned active scene materials so the sales floor reads as rough commercial carpet, walls read as brighter painted retail surfaces, and mall tile/grout reads warmer than the store interior.
- Added low-profile commercial-carpet fleck geometry and attached wall color panels to break up raw slab surfaces without adding loose clutter.
- Retuned active lighting so the mall approach is warmer, the store is brighter/cleaner, and the backroom remains a cooler utility layer.
- Added Packet 07 screenshot targets: `lighting_materials_store.png`, `lighting_materials_mall.png`, `product_closeup.png`, and `stockroom_doorway.png`.
- Fixed `product_closeup.png` composition so it frames starter product cases instead of clipping into a shelf.
- Fixed the employee-only stockroom sign orientation so it reads correctly from the sales-floor doorway.
- Updated screenshot manifests, validation docs, QA screenshot-review targets, and status contracts for 27 required screenshots.

## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
| Screenshot review happens before full validation. | Owner approval depends on visual read, not just green tests. | No | Packet 08 packages final screenshots and validation. |
| Treat `scripts/validate_godot.sh` and contact sheet as regression evidence only. | The older gate and contact sheet were written for graybox-era assumptions and cannot approve design quality by themselves. | No | Packet 08 must present screenshot notes and owner review language. |
| Complete Packet 07 without broad prop/catalog/customer expansion. | The visual read improved through lighting/material/screenshot composition while preserving scope and mechanics. | No | Packet 08 should decide whether residual primitive fixture/counter read blocks owner signoff. |

## Stop Conditions

- Integrated scene still reads as cubes/prototype after polish.
- Screenshot review shows the design direction is wrong.
- Lighting/material fixes require a core asset workflow decision.
- Route/collision regressions cannot be fixed locally.
- Validation exposes a blocker.

## Continue Conditions

- Opening route reads coherently in normal gameplay.
- Visual blockers are resolved or clearly logged.
- Full validation passes.
- Packet 08 can package review evidence.

## Final Handoff Requirements

- Commit hash
- Branch
- Screenshot/contact-sheet paths
- Validation command/result
- Screenshot notes summary
- Known residual issues
- Owner/lead decisions needed

## Final Handoff

- Branch: `codex/hard-visual-benchmark-implementation`
- Validation command/result: `scripts/validate_godot.sh` passed.
- GUT result: 581 tests, 11799 asserts.
- UI automation coverage: 512/632, or 81.0%.
- Screenshot/contact-sheet paths: `artifacts/validation/latest/screenshots/`, `artifacts/validation/latest/screenshot-contact-sheet.png`.
- Screenshot notes summary: mall/store lighting contrast is improved, sales floor is brighter, carpet/wall material read is clearer, product closeup and stockroom doorway evidence now frame the intended subjects.
- Known residual issues: fixture/counter/shelf silhouettes still contain obvious primitive geometry; contact-sheet thumbnails remain too small for final art approval; Packet 08 must package these risks for owner validation instead of treating the gate as approval.
- Owner/lead decisions needed: none before Packet 08 packaging; owner signoff is still required before external beta/tester readiness.
