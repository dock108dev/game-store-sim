# Game Store Sim — first-week beta master plan

Updated 2026-09-23. **B1–B9 technically complete; B10 owner review in progress on the frozen B9 app; owner acceptance pending.**

Current engineering source is local and remote `main`, worked directly at `/Users/michaelfuscoletti/Desktop/game-sim`. At the owner’s request, the completed maintenance work has been consolidated onto main; do not create separate branches or checkouts unless requested. The dated maintenance records below retain their original execution context. The B9 app remains an older packaged artifact; these source changes do not rebuild it.

## Authoritative plan

The [Desktop path to beta](/Users/michaelfuscoletti/Desktop/game_sim_next_steps.md) owns current scope, implemented/missing capabilities, issues, backlog, proposed seven-day pacing and B0–B10 completion conditions. It supersedes the former plan ending at R5 review. B2–B6 runtime/UI work and isolated checks were separately authorized and delivered. B10 was subsequently authorized and is recorded in [the owner review record](03-production/b10-owner-review.md); preserve its candidate.

Confirmed target: the first week owning one expandable, rearrangeable shop; employees for stocking/checkout; rent and wages with bankruptcy risk; condition-based used-game buying/resale with haggling only when customers sell to the shop; new releases without preorders. Retain the illustrated retail-v4 style and improve animation. Seven in-game days is the planning interpretation of the owner's first-week request.

Godot 4.6.2 Standard/GDScript/Compatibility and retained Krita masters remain the current workflow. The active runtime is `encounter/`; historical first-person material does not define the beta.

## Current implementation and acceptance

R1–R4 remain accepted within scope. R5 three-product assortment has retained technical qualification; R5 owner acceptance remains pending. B2 adds shared layout, preparation-only rack purchase/movement and four/eight slots. B3 adds growth, bills/failure and a seven-day endpoint. B4 adds employees and actual wage commitments. B5 adds seller negotiation, condition-bearing copies and actual-cost resale; B6 now supplies releases and the complete authored week. Retained [R4 delivery](03-production/r4-delivery.md), [R5 delivery](03-production/r5-delivery.md) and [R1–R5 checklist](03-production/visual-first-task-list.md) describe bounded historical scope.

B1 is complete: the [first-week implementation packet](03-production/first-week-implementation-packet.md) specifies all eight deliverables, initial content/economy, a reconciled surviving and failed business, and the exact B2 layout work order. B2 is implemented with [its own delivery/evidence](03-production/b2-delivery.md); [B3 growth/economy delivery](03-production/b3-delivery.md) is complete; [B4 employees](03-production/b4-delivery.md) is complete; [B5 used trading](03-production/b5-delivery.md) is complete; [B6 releases and breadth](03-production/b6-delivery.md) is complete; [B7 experience/presentation](03-production/b7-delivery.md) is complete; [B8 balance evaluation](03-production/b8-delivery.md) is complete without numerical tuning; [B9 personal Mac delivery](03-production/b9-delivery.md) is technically complete; B10 whole-week owner review is now in progress on the frozen B9 candidate. Do not request another scope decision for confirmed requirements. Technical checks and prior slice approval do not imply beta acceptance.

## Historical delivery identities and retained limits

B3 starts from the delivered uncommitted B2 tree, retained under `encounter/evidence/b3-20260922/incoming-b2/`. HEAD remains the same; the [B3 delivery](03-production/b3-delivery.md) manifest identifies resulting uncommitted runtime, documentation and root tracker bytes. B6 now uses schema 10 in its separate development namespace, preserving the complete B1–B5 input snapshot. Historical artwork, evidence and owner saves are preserved. Technical completion is separate from owner acceptance.

B2 began on `main` at `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9` with the uncommitted B1 packet, milestone and master-plan documents already present. Their incoming bytes are retained under `encounter/evidence/b2-20260922/incoming-b1/`. The final source is HEAD plus uncommitted changes; [B2 delivery](03-production/b2-delivery.md) identifies the complete manifest, isolated validation and rendered movement/input evidence. Owner saves, historical evidence and editable/exported artwork were preserved. No commit, push or publication occurred.

B2’s queue geometry was corrected through moving-customer verification; static validity alone had missed the passing-lane problem. B7 experience/motion is technically delivered. B9 packaging/audio/ordinary exits are technically qualified; B10 owner review remains. The B8 walking stall was reproduced and repaired in B9 without rebalancing. B8 records profitable alternatives and recovery, weak survival-only pressure, and a walking stall with ordinary keyboard clearance; it does not establish owner fun or comfortable workload. R5 and B2–B6 owner acceptance remain pending; there is no beta acceptance.

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

Current packaged source and evidence: [B9 delivery](03-production/b9-delivery.md). B9 technical completion does not supply B10 owner acceptance.

## Separate error-handling maintenance — 2026-09-23

The current Desktop tracker records B10 owner review in progress, superseding older “B10 next / stop before B10” text above. This source pass starts from clean `8b84f8f621af0613b08fbb9051ee6aec0548d51c` in `/Users/michaelfuscoletti/.codex/worktrees/abend-handling/game-sim`, isolated from the review checkout and B9 artifact. [Error handling and recovery](02-technical/error-handling.md) records implemented behavior, repository review boundaries, focused passing checks and remaining limitations. No replacement app, commit, push or owner acceptance is implied. Continue the existing B10 review against its frozen candidate.

## Security hardening — 2026-09-23

This extends the preceding uncommitted error-handling work in the same isolated checkout. [Local security](02-technical/security.md) maps the actual file/argument/tool trust boundaries, fixes bounded input handling and release-mode isolation, records passing focused checks and separates remaining same-account filesystem and public-distribution decisions. B10 remains on its unchanged B9 artifact; no source substitution or packaging occurred.

## CI setup — 2026-09-23

[CI readiness](04-validation/ci-readiness.md): new `Encounter checks` workflow and a shared basic validator selection are locally passing. Hosted execution of this uncommitted source remains unverified; managed CodeQL passes only on older hosted main. No required checks or rulesets are currently configured. B9/B10 candidate unchanged; no push, signing or settings changes.

## Repository cleanup — 2026-09-23

The same isolated maintenance checkout removes nine tracked disposable Python bytecode files from source-tool directories (plus six untracked generated files), with scoped ignore rules preventing recurrence. Evidence-snapshot bytecode remains untouched. Root README now provides one concise run/test/reference entry; local development links to player/architecture rules rather than repeating employee instructions and correctly identifies `week_content.gd` as content owner. The capture pacing encoder has expanded imports/statements/calls, verified to preserve its parsed behavior; no module extraction or gameplay change. Nine Python tests, in-memory syntax compilation, edited-link checks and whitespace checks pass. The previous CI Godot result remains prior evidence for unchanged runtime, not a new cleanup build. No engine/capture/packaging run was needed for these Python-formatting/docs/cache changes. Cohesive state/scene retention and historical workflow preservation remain as documented; hosted CI and packaging qualification are separate follow-ups.

## Documentation accuracy — 2026-09-23

Active player/setup/architecture/validation guides now distinguish basic headless `--ci` checks from the larger default selection (which includes graphical native-exit checks), and mark B4–B9 results as candidate-specific history. Repository-root commands replace paths that would launch the original checkout accidentally. Ordinary development launches still share the configured v10 namespace across worktrees; only the validator isolates saves. App links lead to the portable B9 delivery record instead of an absent ignored artifact. The frozen owner guide is preserved as delivery-time material; the B10 record owns current review status. CLI help, launcher syntax, 95 local link targets and whitespace were checked. No executable source changed and no application/test/package run occurred for this documentation pass. Hosted CI, stronger malformed-save qualification, filesystem races and later replacement-package review remain the already documented separate follow-ups.

## Authorized main publication repair — 2026-09-23

The owner authorized rebuilding the three unpublished commits after generated evidence prevented normal GitHub publication. Their complete original history remains under local recovery ref `refs/archive/main-before-publish-20260923` (`52bb8117413e4a0df9d7b62bbac32c3f8ea2c49f`); `.git/publish-recovery-20260923.json` records excluded paths. Only new generated app bundles, ZIPs, videos and raw pace/frame sequences were excluded from Git tracking; every file remains on disk. Source, editable masters, existing remote history, reports/logs and still screenshots remain tracked. A fresh clone cannot reproduce local-only media links without the retained local evidence. Main now contains the latest consolidated source; no force push or app rebuild is required. Earlier unpublished hashes identify retained historical execution, not the new publication commit.

## Source presentation cleanup — September 23

The authorized clarity pass updates the active encounter HUD, price-entry order, copy list, supplier feedback and financial summary using Starter 02 guidance. [Matched views and checks](ui-verification.md#september-23-clarity-review) identify synthetic source evidence and remaining keyboard verification. Business rules, persistence and artwork remain unchanged. No package replacement, owner-save access, commit, push or B10 acceptance occurred.
