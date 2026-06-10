# Alpha Playtest Package

This is the Stop 13.6 external playtest handoff. It is intentionally shorter than the full manual checklist in `07-current-manual-playtest.md`; use it when giving a tester one readable alpha run instead of the full internal QA matrix.

## Current Package State

Paused pending owner recovery screenshot validation, stockroom screenshot validation, and production-visual screenshot validation.

The package remains useful as the intended external tester script, but it should not be handed to testers until the owner recovery screenshot set in `16-playability-readability-recovery-plan.md`, the stockroom screenshot set in `17-stockroom-production-plan.md`, and the production-visual review set in `18-production-visuals-plan.md` pass. Readability recovery, stockroom production, and production visual baseline implementation are complete and the full automated gate is green; the remaining blocker is real-window human review, not a known automated failure.

Before reopening this package, capture the recovery screenshot set listed in `16-playability-readability-recovery-plan.md`, capture the stockroom screenshot set listed in `17-stockroom-production-plan.md`, complete the production-visual review set in `18-production-visuals-plan.md`, keep `13-alpha-bug-list.md` current, rerun `scripts/validate_godot.sh`, and confirm the build can be read in a real 1280x720 window. Keep the package paused if the employees-only receiving/backstock/office flow still reads as floor clutter, debug props, or instant inventory, or if the store still reads as graybox after the production-visual pass.

## Package Scope

After owner screenshot validation passes, the alpha package will cover the local desktop build on `codex/let-it-fly` after the full gate passes. It is meant to prove the first-person store loop from fresh start through receiving, pricing, stocking, checkout, trade-ins, preorders, services, backroom planning, day close, save/load, and feedback capture.

This is not a final art/audio/content release. Known graybox and manual release-wrapper limits remain listed below so they are visible to testers instead of buried in chat.

## Build Commands

Run these commands from the repository root before sharing a package:

```text
scripts/validate_godot.sh
scripts/verify_desktop_export.sh --pack-smoke
```

The full gate already runs the pack smoke, but running the export verifier again is a clear package handoff step.

Expected local artifacts:

- `artifacts/builds/desktop/game-store-sim.pck`
- `artifacts/builds/desktop/pack-smoke.log`
- `artifacts/validation/latest/gut-results.xml`
- `artifacts/validation/latest/screenshots/`
- `artifacts/performance/latest/` after `scripts/measure_alpha_performance.sh --full`

If macOS Godot export templates and signing are installed locally, a runnable app can be produced from `game/export_presets.cfg`. If those templates or signing are missing, ship the pack-smoke artifact and record the template/signing blocker in the feedback notes.

## Tester Start

Give the tester these files or links:

- the runnable app if binary export is available, otherwise the `.pck` artifact plus launch instructions for the local Godot runtime
- `docs/production/15-alpha-playtest-package.md`
- the latest screenshot folder if you want visual-composition comments
- a feedback document using the form below

Recommended test duration: 25 to 45 minutes.

## Playtest Script

1. Start a fresh game and spend one minute looking around from the player spawn.
2. Press Escape, open settings, close settings, return to play, and confirm mouse control feels normal.
3. Pick up the starter `Star Trader` copies from receiving with the center reticle and left click.
4. Open pricing from the held item, set one fair price, and stock it on the used-game rack.
5. Overprice another matching copy, stock it, and watch whether customers pick the lower-priced copy instead of treating all copies as rejected.
6. Ring up a buyer at the register and confirm the receipt, tender, change, and confirmation are readable.
7. Review a trade-in offer at the register, adjust the cash offer once, then accept or decline it.
8. Take the preorder deposit and confirm it reads as a future obligation rather than a completed sale.
9. Complete the service customer at the register, then use the backroom service controls to start and work the bench ticket.
10. Open the backroom computer and review dashboard, inventory, ordering, releases, reports, services, storage, suppliers, settings, and records.
11. Order the starter supplier lot, close the day, start the next day, and confirm stock appears as physical receiving work.
12. Use Open Box, Invoice, Sort, Store, and Pull to confirm the backroom flow reads as physical inventory handling.
13. Reserve one `Neon Skyline` allocation, play into launch day if time allows, and review launch cash/reputation results.
14. Save, return to the main/pause flow, continue from the save, and confirm the store state is understandable.
15. Write feedback using the form below before starting any second run.

## Known Issues

- The current visuals are still alpha/graybox quality. Report readability problems, but do not expect final art, animation, or audio.
- Desktop pack smoke is automated. Full binary app export and start-save-quit-relaunch-continue review still depend on local Godot export templates, macOS signing state, and a human desktop run.
- Controller feel, OS window behavior, mouse capture feel, and long-form comfort are manual checks; Codex cannot mark those as human-approved.
- Returns have a baseline register refund flow with receiving-review routing, cash/reputation accounting, and daily-report totals. Full exchanges, receipt/fraud policy, and multi-item return decisions remain future scope.
- Hidden-thread content remains optional and should not block normal store progression.
- Expanded category fixtures, theft/shrinkage, final product art, and final customer animation are outside this alpha package unless explicitly selected for a later slice.

## Feedback Form

Use this structure for every tester:

```text
Build:
Commit or branch:
Platform and hardware:
Session length:
Fresh start or continued save:

Blockers:

Confusing steps:

Most readable store-owner moment:

Least readable store-owner moment:

Economy feel:

Customer behavior notes:

Backroom/computer notes:

Menu/settings/save notes:

Visual/audio comfort notes:

Bugs with reproduction steps:

Screenshots or logs attached:

Would you play one more in-game day? Why:
```

## Triage Rules

- P0: build does not launch, save corrupts, first-person control cannot be recovered, or the core sale loop cannot complete.
- P1: receiving, pricing, stocking, checkout, backroom ordering, day transition, or save/load works only with developer explanation.
- P2: readable but weak visuals, copy, economy feel, customer behavior, menu flow, or composition issues.
- P3: future-content requests outside the current alpha scope.

Every accepted feedback item should be added to `13-alpha-bug-list.md` with evidence, priority, target slice, and acceptance criteria before implementation.

## Rollback Plan

Known-good pushed checkpoints for this alpha hardening run:

- Stop 13.5 balance checkpoint: `813fa0b`
- Stop 13.4B content/copy checkpoint: `8558f36`
- Stop 13.4A scene-readability checkpoint: `60aabc3`

If the playtest-package slice breaks release handoff only, revert the package commit and keep the Stop 13.5 build as the current playable alpha candidate. If a later code/content slice breaks gameplay, revert that specific commit on `codex/let-it-fly`, rerun `scripts/validate_godot.sh`, and push the repaired branch before sharing another package.

Do not hide local-template export failures by skipping validation. If binary export is blocked by templates or signing, keep the pack-smoke artifact, document the local blocker, and continue with the manual tester script only after the full gate remains green.
