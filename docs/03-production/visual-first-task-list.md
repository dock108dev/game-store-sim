# Visual First Task List

This is the next-phase task list after the engine proof.

The goal is to make the first 0.3% visually excellent before gameplay breadth expands.

## Phase Rule

No new gameplay systems unless they directly support staging, capturing, or validating the visual benchmark.

Allowed:

- camera/FOV/scale work
- scene composition
- lighting
- materials
- fixture scaffolding
- product visual language
- placeholder customer visual quality
- screenshot capture tooling
- validation updates
- narrow interaction tweaks needed to stage benchmark screenshots

Not allowed:

- trade-ins
- returns
- services
- supplier networks
- launch calendar
- secret web
- employees
- store expansion
- additional customer archetypes beyond benchmark needs

## Task 1: Create Visual Benchmark Scene

Owner: engineering/art.

Output:

- `game/scenes/main/visual_benchmark_03.tscn`, or equivalent agreed path
- scene launches from Godot
- can coexist with engine proof scene during transition

Acceptance:

- scene includes mall concourse, storefront, sales floor, counter, backroom, starter shipment, shelves, physical items, and one customer staging point
- scene can be launched on macOS
- no script load errors

## Task 2: Establish Store Scale

Owner: engineering/art.

Output:

- human-scale reference
- case-size reference
- shelf/counter/backroom scale pass
- camera height/FOV values

Acceptance:

- cases feel handleable
- shelves fit credible rows
- counter height feels usable
- camera does not make the store feel toy-sized or warehouse-sized

## Task 3: Build Mall Storefront Read

Owner: art/design.

Output:

- mall concourse segment
- glass storefront
- entrance threshold
- fictional sign placement
- left/right customer path cues

Acceptance:

- screenshot `01-storefront-from-mall.png` passes visual review
- the store reads as a mall unit immediately

## Task 4: Build Empty Lease Sales Floor

Owner: art/design.

Output:

- sparse but intentional starter floor
- initial fixture arrangement
- counter sightline
- visible receiving/backroom path

Acceptance:

- screenshot `02-empty-sales-floor.png` passes visual review
- empty capacity reads as future growth, not missing art

## Task 5: Build Receiving And Backroom

Owner: art/design.

Output:

- receiving zone
- starter shipment staging
- backroom computer/office cue
- operational clutter rules

Acceptance:

- screenshot `03-receiving-backroom.png` passes visual review
- screenshot `04-starter-shipment-open.png` passes visual review

## Task 6: Define Fictional Product Visual Grammar

Owner: art/design.

Output:

- fictional platform/category color rules
- case-cover blockout style
- new/used visual distinction
- price sticker style
- shelf/category strip style

Acceptance:

- no real IP
- at least 10 physical game cases can appear together and still read
- screenshot `06-stocked-shelf-density.png` passes visual review

## Task 7: Improve Carried Item Presentation

Owner: engineering/art.

Output:

- first-person held case framing
- carried item scale/material pass
- pickup view composition

Acceptance:

- screenshot `05-picked-up-case.png` passes visual review
- carried item supports inspection fantasy without blocking play

## Task 8: Build Counter/Register Visual Standard

Owner: art/design.

Output:

- counter materials
- register object
- small retail-specific clutter
- customer/player side readability

Acceptance:

- screenshot `07-counter-register.png` passes visual review
- counter reads as the business pressure point

## Task 9: Stage Customer Entry Visual

Owner: engineering/art.

Output:

- simple customer body/placeholder with better silhouette than debug capsule
- mall-to-store entry pose/path
- browse/queue staging if cheap

Acceptance:

- screenshot `08-customer-entering-from-mall.png` passes visual review
- customer clearly starts from the mall

## Task 10: Establish Daily Report Presentation Direction

Owner: UI/design.

Output:

- daily report view in business-tool style
- backroom computer or report context
- readable hierarchy

Acceptance:

- screenshot `09-daily-report-view.png` passes visual review
- report does not look like debug text

## Task 11: Add Screenshot Capture Harness

Owner: engineering.

Output:

- one command captures visual benchmark screenshots
- outputs named files under `artifacts/validation/latest/screenshots/visual-benchmark/`
- captures from macOS build or from a scene path that matches build framing

Acceptance:

- all nine required screenshot files are produced
- dimensions are stable
- nonblank sanity passes

## Task 12: Update Validation Gate

Owner: engineering.

Output:

- `scripts/validate_local.sh` checks visual benchmark screenshot presence and sanity once the benchmark scene exists
- export-enabled validation remains green

Acceptance:

- `scripts/validate_local.sh` passes
- `GSS_EXPORT_MACOS=1 scripts/validate_local.sh` passes

## Task 13: Visual Review Pass

Owner: lead/design.

Output:

- review notes for all nine screenshots
- pass/revise/fail/defer decision per screenshot
- explicit sign-off or revision list

Acceptance:

- all required visual targets pass or have intentional deferrals
- next gameplay phase is unblocked only after sign-off

## Task 14: Retire Or Demote Engine Proof Scene

Owner: engineering.

Output:

- keep engine proof as test fixture, or
- replace main scene with visual benchmark scene, or
- archive engine proof under a test/prototype path

Acceptance:

- repo entry point no longer implies placeholder visuals are production baseline
- validation still covers technical proof behavior

## Completion Checklist

- [ ] Visual benchmark scene exists.
- [ ] Store scale is locked for the first slice.
- [ ] Mall storefront screenshot passes.
- [ ] Empty sales floor screenshot passes.
- [ ] Receiving/backroom screenshot passes.
- [ ] Starter shipment screenshot passes.
- [ ] Picked-up case screenshot passes.
- [ ] Stocked shelf density screenshot passes.
- [ ] Counter/register screenshot passes.
- [ ] Customer entering screenshot passes.
- [ ] Daily report screenshot passes.
- [ ] Visual screenshot harness exists.
- [ ] Local validation passes.
- [ ] Export-enabled validation passes.
- [ ] Visual sign-off recorded.

