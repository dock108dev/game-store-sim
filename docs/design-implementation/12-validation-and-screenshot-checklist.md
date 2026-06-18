# Validation And Screenshot Checklist

## Goal

Define how the design-reset implementation is reviewed once implementation work starts.

Validation should be visual-first. The opening store is failing because the player-visible result does not yet meet the target, so final game-window screenshots and detailed visual notes are the primary review surface. Automated tests still matter, but they support the review by proving mechanics, contracts, screenshots, and data stayed intact.

Docs-only planning phases do not run validation.

## Player-Facing Result

When an implementation batch is ready for review, the owner receives:

- final game-window screenshots from the implemented build
- current automated screenshot artifacts as the starting review set
- detailed pass/fail notes per screenshot
- explicit failure language when the store still reads wrong
- automated validation results after visual review artifacts are captured
- clear decision points only when owner input is needed before continuing

The review should answer one main question: does the opening game store finally look and feel like the intended small early-2000s mall game shop?

## Owner Decisions Captured

- Validation order should be screenshots first, then automated tests.
- Start from the screenshots already produced by the automated validation script and adjust as needed.
- Implementation slices require final screenshots, not before/after screenshots by default.
- Use game-window screenshots unless editor mode is needed for a specific validation.
- Screenshot review should be detailed with notes.
- Owner validation should happen at the end, not after every slice, unless there is a natural and necessary stopping point requiring a decision before continuing.
- Fail language should be explicit.
- Docs-only phases should skip validation entirely until implementation starts.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Store Shell And Mall Entrance Slice](03-store-shell-and-mall-entrance-slice.md)
- [Starting Store Layout Spec](04-starting-store-layout-spec.md)
- [Fixture Grid Slice](05-fixture-grid-slice.md)
- [Checkout And Trade-In Counter Slice](06-checkout-and-trade-in-counter-slice.md)
- [Product And Platform Visual Language Spec](07-product-and-platform-visual-language-spec.md)
- [Required Zones Slice](08-required-zones-slice.md)
- [Density And Clutter Rules](09-density-and-clutter-rules.md)
- [Signage Branding And Store Identity Spec](10-signage-branding-and-store-identity-spec.md)
- [Lighting Materials And Color Palette Spec](11-lighting-materials-and-color-palette-spec.md)
- [Validation And Signoff](../design-source-of-truth/04-validation-and-signoff.md)
- [Validation](../production/06-validation.md)

Feeds:

- [Agent Work Packet Template](13-agent-work-packet-template.md)
- [Phase Implementation Roadmap](14-phase-implementation-roadmap.md)

## In Scope

- Define screenshot-first review order.
- Define final screenshot artifact expectations.
- Define game-window versus editor screenshot policy.
- Define detailed notes format.
- Define explicit fail language.
- Define owner validation timing.
- Define docs-only validation skip rule.
- Define how automated validation fits after visual artifacts.

## Out Of Scope

- Changing the existing validation script in this docs-only pass.
- Defining final screenshot filenames for every future feature.
- Adding new automated tests now.
- Requiring before/after screenshot capture for every implementation slice.
- Requiring owner review after every implementation slice.

## Validation Order

Implementation validation should run in this order:

1. Capture final game-window screenshots.
2. Review screenshots with detailed notes.
3. Identify visual/design failures and decision points.
4. If no owner decision is required, run automated validation.
5. Package screenshots, contact sheet, logs, and notes.
6. Present review outcome.

Automated tests are still required before marking implementation complete, but screenshot review leads because visual quality is the current blocker.

## Docs-Only Rule

Docs-only planning work does not run validation.

Rules:

- update docs, status contract, and doc tests as needed
- commit each completed doc slice
- do not run `scripts/validate_godot.sh` for docs-only slice creation
- do not claim a fresh validated baseline without running the gate
- use current doc-contract expectation wording when active docs change

Validation begins again when code/assets/scenes are implemented.

## Screenshot Source

Start with the current automated screenshot script output.

Rules:

- use existing automated screenshot set as the baseline review set
- add or adjust screenshot targets only when current artifacts miss an important design question
- keep screenshot review tied to actual game-window output
- use editor screenshots only when a specific validation requires editor-only context

Game-window screenshots are the default because the owner and player judge the game as it runs.

## Final Screenshot Policy

Implementation slices require final screenshots by default, not before/after screenshots.

Use before/after screenshots only when:

- a regression needs proof
- a specific visual comparison is requested
- an implementation risk is hard to explain without comparison

Otherwise, final state matters. The review should not reward relative improvement if the result is still below the target.

## Core Review Views

Start with automated script screenshots. Ensure coverage can answer these views:

- mall approach toward storefront
- storefront/entrance first read
- inside entrance looking into the store
- checkout/register and customer line
- demo area near the front
- shelf/product close-up
- sales floor route and fixture placement
- stockroom door/read
- stockroom receiving area
- stockroom desk/planning area
- lighting/materials read
- signage/product label read

If the automated set already covers these, do not duplicate. If it misses one, add a targeted final screenshot.

## Detailed Notes Format

Each screenshot review note should include:

- screenshot filename
- pass/fail status
- what reads correctly
- what fails or feels weak
- required correction
- severity
- whether owner decision is needed

Severity:

- `blocker`: cannot continue broadening scope until fixed
- `major`: must fix before owner signoff
- `minor`: polish issue, can batch with later work
- `note`: observation only

Example:

```text
Screenshot: storefront_entry.png
Status: fail
Severity: blocker
Reads correctly: storefront exists and entrance path is clear.
Fails: still reads as flat gray planes with text labels, not a mall game store.
Required correction: replace storefront surfaces/signage with modular mall/storefront assets and readable editable sign.
Owner decision needed: no
```

## Explicit Fail Language

Use direct fail language. Do not soften a visual miss into vague polish.

Allowed fail phrases:

- still reads as cubes/prototype
- too cluttered
- too empty in a missing-art way
- not retail
- not early-2000s
- not a game store
- stockroom still reads as exposed back area
- fixture labels are doing the work instead of fixtures/products
- signage is too noisy
- lighting makes products unreadable
- product wall still looks like boxes, not games
- receiving is customer-facing
- demo area does not read
- store does not feel ready to open

The point is to make corrections actionable.

## Owner Validation Timing

Owner validation happens at the end of the implementation pass by default.

Do not stop after every slice for owner signoff unless:

- a design choice is blocked
- an implementation decision could invalidate later work
- the current result reveals the plan is wrong
- owner taste/approval is needed before continuing
- the next slice depends on a disputed visual direction

Otherwise, keep implementing through the planned pass and prepare a final review package.

## Automated Validation Role

After screenshot artifacts are captured and reviewed, run automated validation for implementation work.

Automated validation should confirm:

- GUT/doc contracts pass
- screenshot capture completes
- screenshot sanity passes
- validation artifacts are generated
- no script load failures
- mechanics touched by implementation still work
- validation metadata stays consistent

The current full gate is:

```text
scripts/validate_godot.sh
```

Do not use automated success to override visual failure. A green gate with a visually bad store is still not design-approved.

## Review Package

A review-ready implementation package should include:

- branch/commit range
- summary of implemented slices
- final screenshot/contact-sheet location
- screenshot review notes
- automated validation summary
- known residual issues
- owner decision points, if any

The package should separate:

- objective failures
- owner preference decisions
- known future work
- automation/test status

## Pass Criteria

The implementation pass is ready for owner review when:

- final game-window screenshots exist
- screenshot notes are detailed
- explicit failures are listed
- automated validation has run for implementation work
- no known blocker is hidden
- the store can be evaluated against docs 02-11
- any owner decision points are isolated and concrete

Design approval requires the visual read to pass, not merely tests.

## Fail Conditions

The review fails if:

- no final game-window screenshots are provided
- only editor screenshots are provided without a specific editor-only reason
- screenshots are not detailed enough to judge the store
- notes avoid direct failure language
- automated tests pass but visual blockers are ignored
- owner is asked to validate every small slice without a real decision need
- docs-only work claims validation it did not run
- screenshots still read as cubes/prototype/not retail

## Required Modules

Implementation should produce or standardize review artifacts for:

- final screenshot manifest
- screenshot contact sheet
- screenshot review notes file
- automated validation summary
- owner decision-point list

These may be generated by existing validation tooling or by small additions when implementation starts.

## Likely Files

Likely touched during implementation:

- `scripts/validate_godot.sh`
- screenshot capture scripts
- screenshot sanity scripts
- validation manifests
- docs review templates
- `artifacts/validation/latest/*`

This docs-only pass should not modify validation scripts unless later implementation requires it.

## Tests To Add Or Update

Later implementation should add or update tests for:

- screenshot manifest includes required final review views
- validation metadata points to current contact sheet
- docs/status contract names active validation artifacts
- docs-only updates do not claim fresh validation
- editor-only screenshots are marked with a reason when used
- screenshot review notes file exists for owner review packages

Doc/status tests should include this doc as an active planning document once written.

## Screenshot Targets

The review starts from automated screenshots. Targeted additions, if missing, should include:

- `review_mall_approach.png`
- `review_storefront_first_read.png`
- `review_inside_entrance.png`
- `review_checkout.png`
- `review_demo_area.png`
- `review_product_closeup.png`
- `review_stockroom_door.png`
- `review_receiving.png`
- `review_stockroom_desk.png`
- `review_lighting_materials.png`

Do not add duplicates if the automated set already covers the same question.

## Acceptance Checklist

- [ ] Docs-only work skips validation.
- [ ] Implementation validation starts with final game-window screenshots.
- [ ] Automated script screenshots are the baseline review set.
- [ ] Additional screenshots are added only for missing design questions.
- [ ] Editor screenshots are used only with a specific validation reason.
- [ ] Before/after screenshots are not required by default.
- [ ] Screenshot notes are detailed and include pass/fail, severity, and corrections.
- [ ] Fail language is explicit.
- [ ] Owner validation happens at end unless a decision point blocks continuing.
- [ ] Automated validation runs after visual artifacts for implementation work.
- [ ] Automated success does not override visual failure.

## Stop/Ask-Owner Conditions

Stop and ask owner before continuing implementation if:

- screenshots reveal the plan is aiming at the wrong visual target
- a natural design branch needs owner taste before more work
- the store footprint/layout decision would invalidate later slices
- a legal/name/brand decision blocks asset work
- implementation cannot satisfy docs 02-11 without changing core direction

Do not stop merely because a slice is complete if the next slice can proceed without a decision.

## Commit Expectation

Commit validation/checklist implementation separately after docs, tests, scripts, and artifacts are updated.

For this docs-only planning slice, commit only the documentation/status/test-contract updates and do not run the validation gate.

## Next Document

After this doc, write `13-agent-work-packet-template.md` to define the standard work packet format implementation agents should use for each future code/asset pass.
