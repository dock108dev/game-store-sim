# Game Store Sim — first-week beta master plan

Updated 2026-09-21. **Playable R5 prototype; first-week beta requirements defined; NOT BETA READY.**

## Authoritative plan

The [Desktop path to beta](/Users/michaelfuscoletti/Desktop/game_sim_next_steps.md) owns current scope, implemented/missing capabilities, issues, backlog, proposed seven-day pacing and B0–B10 completion conditions. It supersedes the former plan ending at R5 review. This update is planning only; no beta runtime work has started.

Confirmed target: the first week owning one expandable, rearrangeable shop; employees for stocking/checkout; rent and wages with bankruptcy risk; condition-based used-game buying/resale with haggling only when customers sell to the shop; new releases without preorders. Retain the illustrated retail-v4 style and improve animation. Seven in-game days is the planning interpretation of the owner's first-week request.

Godot 4.6.2 Standard/GDScript/Compatibility and retained Krita masters remain the current workflow. The active runtime is `encounter/`; historical first-person material does not define the beta.

## Current implementation and acceptance

R1–R4 remain accepted within scope. R5 three-product assortment has retained technical qualification; R5 owner acceptance remains pending. Layout/growth, employees, used trading, full business expenses/failure and releases are future implementation, not features proven by R5 tests. Retained [R4 delivery](03-production/r4-delivery.md), [R5 delivery](03-production/r5-delivery.md) and [R1–R5 checklist](03-production/visual-first-task-list.md) describe bounded historical scope.

Current planning action is B1: a concrete first-week implementation packet, followed by integrated layout, economy/growth, staff, used trading, releases/content, presentation, balancing, packaging and whole-week owner review. Do not request another scope decision for confirmed requirements. Technical checks and prior slice approval do not imply beta acceptance.

## Current checkout and limits

Before this planning edit, September 21 checkout was `main` at `ac4dfcb27cbed6c7c4ea2cb3d83421b426516fdf`, with an untracked preserved tracker snapshot. This edit changes planning documents only. No runtime tests, launch, commit, push or publication were performed. Preserve saves, masters and retained evidence; the motion and exit-warning limitations below remain unresolved.

The following dated records retain prior qualification and maintenance context. Their old checkout identities and narrow scope do not override the current beta plan.

## Checkout and evidence reconciliation — 2026-09-15

The checkout began clean on `main` at `40bab387b85291ef4d408c16d0e33dae9b098c84`. Earlier references to incoming HEAD `4b91108fa3cd8d9a2829524c6cf5baed55a236d0` and uncommitted R5 work describe the September 9 delivery, not current Git status. The retained [candidate manifest](../encounter/evidence/r5/candidate-manifest.json) remains immutable: all 119 listed encounter files matched before this documentation pass. This pass changes documentation only, including the encounter README; runtime, art, tooling and historical evidence remain unchanged.

The final validation context in `encounter/evidence/validation-20260909T020530374063Z/context.json` matches current encounter runtime/assets. Its only source-map difference before this pass was `scripts/capture_full_shift.py`; that later tooling version matches the candidate manifest. Do not describe the entire current checkout as freshly tested or assign the final validator's results to that different capture-tool revision. No application suites or captures were rerun for these documentation-only edits. R5 owner acceptance remains pending.

Current engineering references: [local development](02-technical/local-development.md), [encounter architecture and schema](02-technical/encounter-architecture.md), and [validation](04-validation/local-validation-plan.md). Historical technical proposals remain labeled and preserved.

## Maintenance cleanup — 2026-09-16

This implementation pass started with the September 15 documentation edits and two new engineering guides already present, on the same `main` HEAD above. It preserves and extends that work. The root README now delegates checkout detail here instead of repeating it.

`encounter/scripts/validate.py` now has named isolation, context, process and capture helpers plus an import-safe entry point. Suite selection, evidence names, timeout and capture thresholds are unchanged. Two guard fixes reject an `ERROR:` on the first log line and stop before launching Godot if the expected custom save-directory settings cannot be isolated. Four standard-library tests cover failure logs/exit records, warning handling, disposable project isolation and unexpected save settings.

Fresh default headless validation passed import, 110 state checks, 3 pending-label checks and 54 scene checks; all four processes exited zero. Evidence: [validation-20260916T040214438478Z](../encounter/evidence/validation-20260916T040214438478Z/context.json). No warnings or errors were found in these logs. The four wrapper tests passed. Python syntax, documentation paths/links and whitespace were checked. Rendered/capture modes were not rerun; their helper refactor has no new visual qualification. The historical capture-exit warning remains unresolved.

Of the 119 encounter entries in the immutable R5 manifest, only `encounter/README.md` and `encounter/scripts/validate.py` now differ; `test_validation_runner.py` and the new validation evidence are additions. Gameplay sources, art, launchers and historical evidence remain unchanged. The new source context records the runner tested here; later prose updates do not alter executable code. No commit, push, signed build, publication or owner-save access was performed. R5 owner acceptance is still pending. Runtime extraction, motion issues and packaging remain separate work; see the [architecture maintenance decision](02-technical/encounter-architecture.md).
