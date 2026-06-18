# Phase Implementation Roadmap

## Goal

Define the master roadmap from design planning through implementation, validation, owner review, and beta/tester readiness.

This roadmap is the control document for turning the design reset into a reviewable game build. It assumes docs 02-13 are the current implementation source and that code/asset work should continue through the planned implementation pass until validation fails, a blocker appears, or a real owner decision is required.

## Current State

Planning state:

- design source of truth is active
- implementation docs 02-13 are complete
- docs-only work skips validation
- no new implementation validation is claimed by this roadmap

Implementation state:

- core mechanics are broadly functional
- visual reset is the blocker
- old graybox/prototype expectations are not the target
- opening store needs a full implementation pass before owner signoff

## Roadmap Principles

- Screenshots drive visual approval.
- Automated validation supports, but does not replace, visual approval.
- Commits happen after each completed implementation phase.
- Agents keep working through non-conflicting phases until blocked.
- Owner validation happens at the end of the implementation pass unless a decision is needed earlier.
- Tester/beta readiness starts only after the opening-store visual baseline is approved.

## Phase 0: Planning Lock

Status: Complete after this doc is committed.

Purpose:

- finish the design implementation planning set
- remove ambiguity for implementation agents
- define exact review/validation expectations

Required docs:

- `docs/design-implementation/02-visual-module-system-spec.md`
- `docs/design-implementation/03-store-shell-and-mall-entrance-slice.md`
- `docs/design-implementation/04-starting-store-layout-spec.md`
- `docs/design-implementation/05-fixture-grid-slice.md`
- `docs/design-implementation/06-checkout-and-trade-in-counter-slice.md`
- `docs/design-implementation/07-product-and-platform-visual-language-spec.md`
- `docs/design-implementation/08-required-zones-slice.md`
- `docs/design-implementation/09-density-and-clutter-rules.md`
- `docs/design-implementation/10-signage-branding-and-store-identity-spec.md`
- `docs/design-implementation/11-lighting-materials-and-color-palette-spec.md`
- `docs/design-implementation/12-validation-and-screenshot-checklist.md`
- `docs/design-implementation/13-agent-work-packet-template.md`
- `docs/design-implementation/14-phase-implementation-roadmap.md`

Exit criteria:

- all active planning docs exist
- `docs/status.json` includes the active planning set
- doc status contract reflects the active planning set
- planning docs are committed and pushed

Validation:

- no `scripts/validate_godot.sh` run required for docs-only planning

## Phase 1: Implementation Packet Assembly

Purpose:

- convert docs 02-12 into concrete work packets using doc 13
- define file ownership, dependencies, and evidence expectations
- decide which packets can run independently

Lead tasks:

- create packet for visual module foundation
- create packet for store shell/mall entrance
- create packet for starting layout/stockroom
- create packet for fixture/product stocking surface
- create packet for checkout/trade-in counter
- create packet for product/platform visual language
- create packet for required zones and first-use guidance
- create packet for density/clutter/signage/lighting polish
- define integration owner for shared scenes/data

Parallel-safe work:

- independent module prototypes
- standalone texture/material work
- poster/product bitmap drafts
- documentation packet drafting

Not parallel-safe:

- same main store scene edits
- same product/catalog data edits
- same validation/status files
- store footprint decisions
- final integration pass

Exit criteria:

- each implementation packet has read-first docs, scope, no-go rules, likely files, validation, screenshots, and decision log
- phase ownership is clear
- no packet depends on unresolved owner decision

Commit:

- commit packet assembly if files are added/changed

## Phase 2: Visual Module Foundation

Primary docs:

- `02-visual-module-system-spec.md`
- `09-density-and-clutter-rules.md`
- `11-lighting-materials-and-color-palette-spec.md`

Purpose:

- replace raw primitive visual language with reusable module families
- establish materials, collision, anchors, naming, and replacement rules

Build:

- store/mall material set
- fluorescent store light and warmer mall light modules
- commercial carpet material
- light wall and editable panel material
- laminate/black metal fixture materials
- module folder structure where needed
- reusable anchors for placement, stocking, and screenshots

Exit criteria:

- modules have clear paths and naming
- no new final visible module is a raw cube/CSG shortcut
- material system supports later store assembly
- movement/collision rules are preserved

Commit:

- commit module foundation before broad store assembly

Validation:

- focused import/load tests where applicable
- no owner review unless module approach cannot meet visual target

## Phase 3: Store Shell, Mall Entrance, And Layout

Primary docs:

- `03-store-shell-and-mall-entrance-slice.md`
- `04-starting-store-layout-spec.md`
- `09-density-and-clutter-rules.md`
- `11-lighting-materials-and-color-palette-spec.md`

Purpose:

- make the first player view read as a mall storefront leading into a real small game store
- create real stockroom/backroom relationship
- remove the exposed half-wall/prototype read

Build:

- mall concourse approach
- editable storefront sign shell
- open door/threshold path
- clean sales floor
- real stockroom door/doorway
- receiving area deep in stockroom
- stockroom planning desk with computer/calendar
- lighting/materials pass for shell

Exit criteria:

- player spawns/starts outside or at mall approach as planned
- store reads from mall approach
- sales floor and stockroom are distinct
- stockroom receiving is not visible from sales floor
- checkout/demonstration placement anchors can fit without route conflicts

Commit:

- commit shell/layout phase before fixture/product work

Validation:

- focused movement/scene-load tests
- final screenshots for mall approach, entrance, stockroom door, stockroom receiving

Stop conditions:

- footprint/layout cannot satisfy store fantasy without owner decision
- stockroom cannot be made real while preserving mechanics

## Phase 4: Fixtures, Checkout, And Day-One Setup Loop

Primary docs:

- `05-fixture-grid-slice.md`
- `06-checkout-and-trade-in-counter-slice.md`
- `08-required-zones-slice.md`
- `09-density-and-clutter-rules.md`

Purpose:

- make the store setup phase playable and visually purposeful
- give the player fixtures, checkout, demo, and setup tasks without overfilling the store

Build:

- starter wall shelves/racks
- fixture snap/placement visuals
- shelf labels/default labels
- visible fixture capacity/slots
- simple checkout/register/scanner/cash drawer/bags
- one-line customer queue support
- trade-in inspection surface at checkout
- behind-counter hold/intake storage
- starter receiving boxes/setup tasks
- large console box stack rules

Exit criteria:

- player can place/stock starter products into visible slots
- checkout/trade-in station works and reads clean
- day-one store remains empty and promising
- no fake future inventory appears on sales floor
- first-use guidance exists for core setup actions where needed

Commit:

- commit fixtures/checkout/setup phase before product-art phase if mechanics and routes are stable

Validation:

- focused tests for fixture placement, stocking, register/trade-in, save/load where touched
- final screenshots for fixture empty/stocked, checkout, setup boxes, console stack

Stop conditions:

- fixture placement conflicts with existing stocking mechanics
- checkout/trade-in mechanics require a core redesign
- route/queue cannot be preserved

## Phase 5: Product, Platform, Signage, And Promotions

Primary docs:

- `07-product-and-platform-visual-language-spec.md`
- `08-required-zones-slice.md`
- `10-signage-branding-and-store-identity-spec.md`

Purpose:

- make products read as games instead of blocks
- make platform/genre/condition/price readable without legal risk
- make store signage usable and editable

Build:

- Nova/Vertex/Prism/Pocket case language
- standard and used case variants
- platform and genre color signals
- case price/condition stickers
- starter working products such as `Footy 2002` and anchor franchise placeholder
- editable storefront name sign
- open/closed sign
- employees-only sign
- demo sign
- shelf labels including mixed/default label
- release/trade-in/upcoming/sale poster templates
- neighboring mall sign flavor

Exit criteria:

- products read as game cases in screenshots
- used/new condition reads visually
- price sticker appears on case
- platform and genre signals can coexist
- signage is readable but not tutorial-heavy
- store name remains editable and not final-locked

Commit:

- commit product/signage phase before final polish

Validation:

- focused tests for product data, price/condition labels, store-name persistence if implemented
- final screenshots for product closeups, shelf read, storefront sign, posters, employees-only sign

Stop conditions:

- legal/name/trade-dress risk appears
- product art cannot be made readable with current asset approach
- signage starts replacing product/fixture visual work

## Phase 6: Lighting, Materials, Density, And Integration Polish

Primary docs:

- `09-density-and-clutter-rules.md`
- `10-signage-branding-and-store-identity-spec.md`
- `11-lighting-materials-and-color-palette-spec.md`
- `12-validation-and-screenshot-checklist.md`

Purpose:

- make the assembled store readable as one coherent place
- tune brightness, material contrast, clutter, and screenshot composition

Build:

- bright store lighting pass
- warmer mall lighting pass
- carpet/walls/panels/fixture material tuning
- demo screen source light
- clutter reduction
- route cleanup
- screenshot target tuning
- validation artifact review notes

Exit criteria:

- store no longer reads as cubes/prototype
- store feels empty and promising, not missing-art empty
- mall/store contrast reads
- products/signs/fixtures remain readable
- stockroom is functional and not customer-facing
- screenshots can be reviewed without editor context

Commit:

- commit polish/integration phase after final screenshots and focused fixes

Validation:

- final game-window screenshots first
- detailed screenshot notes
- focused tests for touched systems
- full `scripts/validate_godot.sh`

Stop conditions:

- screenshot review proves plan is visually wrong
- validation gate fails with blocker
- owner decision is needed before continuing

## Phase 7: Final Review Package

Primary docs:

- `12-validation-and-screenshot-checklist.md`
- `13-agent-work-packet-template.md`

Purpose:

- produce a review package the owner can evaluate without digging through commits

Package includes:

- branch name
- commit range
- phase summary
- screenshots/contact sheet path
- screenshot notes with pass/fail/severity/corrections
- automated validation result
- known residual issues
- owner decision points
- explicit recommendation: approve, revise, or block

Exit criteria:

- final screenshots exist
- screenshot notes are detailed
- automated validation has run for implementation work
- known blockers are not hidden
- owner decisions are concrete

Commit:

- commit review docs/artifact metadata if generated

Validation:

- full gate must be current for implementation review

## Phase 8: Owner Review And Correction Loop

Purpose:

- get owner signoff or corrections on the opening-store baseline

Owner review outcomes:

- Approved: proceed to tester/beta readiness prep
- Revisions: implement corrections, recapture screenshots, rerun validation
- Blocked: stop and resolve specific decision

Correction loop:

1. Record owner correction.
2. Categorize as blocker, major, minor, or note.
3. Implement blocker/major fixes.
4. Capture final screenshots.
5. Run focused tests and full gate.
6. Update review notes.
7. Commit and push.

Do not broaden into beta/tester packaging until blockers and major visual issues are resolved.

## Phase 9: Tester/Beta Readiness Prep

Purpose:

- prepare for external testers only after the opening-store baseline is approved

Required before tester/beta users:

- owner-approved opening store visual baseline
- current full validation pass
- known issues list
- tester instructions
- screenshot/contact sheet available
- clean branch/commit reference
- no unresolved visual blockers
- no unresolved setup/onboarding blocker

Tester package should include:

- build/run instructions
- what to test
- what not to judge yet
- known issues
- feedback form/questions
- screenshot expectations if testers capture issues
- save/reset instructions

Do not ask testers to validate the visual reset if owner has not approved the baseline.

## Commit Cadence

Commit after each phase:

1. packet assembly
2. visual module foundation
3. store shell/layout
4. fixtures/checkout/setup
5. product/signage
6. lighting/materials/density polish
7. review package
8. owner-correction pass
9. tester-readiness package

Each commit should:

- match phase scope
- include docs/tests updates for changed behavior
- avoid unrelated files
- be pushed to the active branch

## Parallelization Rules

Parallel work is allowed when it reduces cycle time without increasing merge/design risk.

Good parallel candidates:

- independent bitmap cover/poster drafts
- material texture variants
- standalone prop modules
- validation note templates
- docs/review package drafting

Lead-owned integration:

- main store scene
- footprint/layout
- stockroom relationship
- fixture placement data
- product catalog data
- status/validation docs
- final review package

If two agents need the same scene/data/status file, do not parallelize without a lead merge plan.

## Stop Gates

Stop and ask owner/lead if:

- the store still reads as cubes/prototype after integration polish
- stockroom cannot be made real without breaking mechanics
- legal/name/trade-dress risk blocks product/signage work
- footprint/layout decision would invalidate later phases
- validation gate fails and cannot be fixed locally
- screenshot review shows the roadmap is targeting the wrong look
- tester readiness would require hiding known blockers

Do not stop for:

- normal material tuning
- normal fixture positioning
- normal screenshot target additions
- fixable validation failures
- slice completion when the next non-conflicting phase can continue

## Beta/Test Readiness Gate

Tester/beta readiness is blocked until all are true:

- owner-approved opening-store screenshots
- current full validation pass
- known issue list updated
- no visual blocker remains
- no setup/onboarding blocker remains
- test instructions exist
- build/run path is documented
- final commit range is recorded

If any item is false, remain in implementation/review correction loop.

## Roadmap Checklist

- [ ] Phase 0 planning lock complete.
- [ ] Phase 1 packets assembled.
- [ ] Phase 2 visual module foundation complete.
- [ ] Phase 3 store shell/layout complete.
- [ ] Phase 4 fixtures/checkout/setup complete.
- [ ] Phase 5 product/signage complete.
- [ ] Phase 6 lighting/materials/density polish complete.
- [ ] Phase 7 final review package complete.
- [ ] Phase 8 owner review complete.
- [ ] Phase 9 tester/beta readiness prep complete.

## Fail Conditions

This roadmap fails if:

- implementation starts without packet/evidence rules
- agents broaden into beta/tester work before visual baseline approval
- owner has to infer what changed from chat history
- automated validation is used to excuse bad screenshots
- commits mix unrelated phases
- tester package is created while visual blockers remain

## Commit Expectation

Commit this roadmap as the final docs-only planning slice with active-doc/status/test-contract updates. Do not run validation for this planning-only document.
