# Game Store Sim — current master plan

Updated 2026-09-16 (validation tooling cleanup; product scope unchanged). Illustrated 2.5D early-2000s mall game shop. Kardboard Kings is the composition reference; **B-ROWAN-01 / retail-v4** is the visual baseline. Godot 4.6.2 Standard/GDScript/Compatibility and retained Krita masters remain the workflow.

## Owner decision

Owner R4 feedback: **“yes”**, confirming that handling several customers is clear and enjoyable enough to build on. R4 accepted within scope; R1–R3 acceptance remains. R5 — three products and stocking decisions — is authorized. No animation, full-game or release acceptance is implied.

## Current slice

R5 has retained technical qualification and is ready for owner review; owner acceptance remains pending. Three fictional products, the existing four-position shelf and three-customer wave. Separate prices, mixed paid orders, prep returns, retained backroom stock and per-product reporting. Preserve exclusive reservations, locked offers, FIFO and the R4 closing/report contract.

[Active checklist](03-production/visual-first-task-list.md), [slice plan](03-production/milestones-and-backlog.md), [R4 delivery](03-production/r4-delivery.md), and [R5 delivery](03-production/r5-delivery.md) govern current work.

## Boundaries

Full-shop expansion, large catalogs/casts and broad V2 animation polish remain later work. The inherited rigid/deforming legs, abrupt turns/stops, straight reach, possible sliding, mirrored lighting, enlargement artifacts and reused customer rig remain documented.

Preserve historical game, samples, prior evidence and unrelated work. No commit, push or publication. Automated qualification, agent visual assessment and owner acceptance are separate.

## Checkout and evidence reconciliation — 2026-09-15

The checkout began clean on `main` at `40bab387b85291ef4d408c16d0e33dae9b098c84`. Earlier references to incoming HEAD `4b91108fa3cd8d9a2829524c6cf5baed55a236d0` and uncommitted R5 work describe the September 9 delivery, not current Git status. The retained [candidate manifest](../encounter/evidence/r5/candidate-manifest.json) remains immutable: all 119 listed encounter files matched before this documentation pass. This pass changes documentation only, including the encounter README; runtime, art, tooling and historical evidence remain unchanged.

The final validation context in `encounter/evidence/validation-20260909T020530374063Z/context.json` matches current encounter runtime/assets. Its only source-map difference before this pass was `scripts/capture_full_shift.py`; that later tooling version matches the candidate manifest. Do not describe the entire current checkout as freshly tested or assign the final validator's results to that different capture-tool revision. No application suites or captures were rerun for these documentation-only edits. R5 owner acceptance remains pending.

Current engineering references: [local development](02-technical/local-development.md), [encounter architecture and schema](02-technical/encounter-architecture.md), and [validation](04-validation/local-validation-plan.md). Historical technical proposals remain labeled and preserved.

## Maintenance cleanup — 2026-09-16

This implementation pass started with the September 15 documentation edits and two new engineering guides already present, on the same `main` HEAD above. It preserves and extends that work. The root README now delegates checkout detail here instead of repeating it.

`encounter/scripts/validate.py` now has named isolation, context, process and capture helpers plus an import-safe entry point. Suite selection, evidence names, timeout and capture thresholds are unchanged. Two guard fixes reject an `ERROR:` on the first log line and stop before launching Godot if the expected custom save-directory settings cannot be isolated. Four standard-library tests cover failure logs/exit records, warning handling, disposable project isolation and unexpected save settings.

Fresh default headless validation passed import, 110 state checks, 3 pending-label checks and 54 scene checks; all four processes exited zero. Evidence: [validation-20260916T040214438478Z](../encounter/evidence/validation-20260916T040214438478Z/context.json). No warnings or errors were found in these logs. The four wrapper tests passed. Python syntax, documentation paths/links and whitespace were checked. Rendered/capture modes were not rerun; their helper refactor has no new visual qualification. The historical capture-exit warning remains unresolved.

Of the 119 encounter entries in the immutable R5 manifest, only `encounter/README.md` and `encounter/scripts/validate.py` now differ; `test_validation_runner.py` and the new validation evidence are additions. Gameplay sources, art, launchers and historical evidence remain unchanged. The new source context records the runner tested here; later prose updates do not alter executable code. No commit, push, signed build, publication or owner-save access was performed. R5 owner acceptance is still pending. Runtime extraction, motion issues and packaging remain separate work; see the [architecture maintenance decision](02-technical/encounter-architecture.md).
