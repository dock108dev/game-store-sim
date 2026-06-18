# Work Packet: Review Package And Owner Validation

Status: Complete
Owner decision required: Yes
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/12-validation-and-screenshot-checklist.md`
Dependencies: `docs/design-implementation/14-phase-implementation-roadmap.md`, `docs/qa/screenshot-review.md`, all previous work packets
Expected commit scope: final review package, screenshot notes, validation results, known issues, and owner decision path

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `docs/design-implementation/work-packets/00-packet-index.md`
5. `docs/design-implementation/12-validation-and-screenshot-checklist.md`
6. `docs/design-implementation/14-phase-implementation-roadmap.md`
7. `docs/qa/screenshot-review.md`
8. Packets 01-07 final handoffs and decision logs

## Context

- Current problem: the owner and later testers need a clean review package, not scattered commit notes and screenshots.
- Target player-facing result: owner can inspect final screenshots, validation output, known issues, and explicit approve/revise/block recommendation without reconstructing context.
- Existing systems that must keep working: validation gate, screenshot artifacts, status docs, known issue tracking.
- Visual/design docs that define success: validation checklist, roadmap, QA screenshot review, source of truth.
- Known prior failures to avoid: claiming visual success from automated tests, hiding residual blockers, asking for vague approval, moving to beta before owner approval.

## In Scope

- Gather final implementation commit range.
- Gather final screenshot/contact-sheet paths.
- Write screenshot review notes with pass/fail/severity/correction fields.
- Record validation command/result.
- Update visual bug list with resolved/open blockers.
- Update current state/status if the opening-store baseline is ready for owner review.
- Provide explicit owner decision options: approve, revise, or block.
- Define next step after each decision.

## Out Of Scope

- New implementation fixes unless review-package assembly discovers missing required evidence.
- Beta/tester package creation before owner approval.
- Broad catalog/customer/decoration expansion.
- Rewriting prior packet docs except to correct stale evidence links.

## Do Not Do

- Do not claim approval before owner review.
- Do not claim validation passed unless it ran in the current implementation pass.
- Do not hide failed screenshots behind a green validation gate.
- Do not create tester instructions while visual blockers remain.
- Do not ask the owner to infer what changed from chat history.
- Do not broaden into implementation unless a missing evidence blocker must be fixed.

## Implementation Plan

1. Read final handoffs and decision logs for packets 01-07.
2. Confirm final commit range and branch.
3. Confirm final screenshots/contact sheet exist.
4. Write detailed screenshot notes.
5. Run or confirm current full `scripts/validate_godot.sh` from the implementation pass.
6. Update visual bug list and current state.
7. Create review package doc or artifact metadata if repo patterns exist.
8. Commit and push review package updates.
9. Ask owner for approve/revise/block decision with concrete options.

## Likely Files

Scenes:
- none expected unless missing required screenshot evidence forces a fix

Scripts:
- none expected unless validation tooling requires correction

Assets:
- none expected

Data:
- validation artifact paths
- screenshot notes

Tests:
- docs status contract tests if status/active docs change

Docs:
- `docs/CURRENT_STATE.md`
- `docs/status.json`
- `docs/production/13-alpha-bug-list.md`
- `docs/design-implementation/work-packets/*`
- possible review package doc under `docs/production/` or `docs/design-implementation/`

## Validation Required

Implementation review packet:

- Final game-window screenshots must exist.
- Detailed screenshot notes must exist.
- Full `scripts/validate_godot.sh` must have run for the implementation pass.
- Artifacts under `artifacts/validation/latest/` must be referenced.
- Known residual issues must be listed.

If validation cannot run, mark the package blocked and explain the risk.

## Screenshot Evidence

Required final screenshots:

- full contact sheet
- mall approach
- storefront entry
- first interior view
- checkout/register
- stocked fixture/shelf
- product closeup
- stockroom door/employee-only read
- receiving area
- 1280x720 walk-in route

## Tests To Add Or Update

- Update doc status contract if active docs/status metadata changes.
- Add review-package contract tests only if a new required review file becomes part of active docs.

## Tests To Run

- focused docs/status tests if active docs/status change
- `scripts/validate_godot.sh` for final implementation review

## Documentation Updates

- Update `docs/CURRENT_STATE.md` with final review status.
- Update `docs/status.json` if phase/playtest state changes.
- Update visual bug list with resolved/open blockers.
- Add review package path if a package doc is created.

## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
| Owner approval is required before tester/beta readiness prep. | Owner must judge whether the visual reset meets the game-store fantasy. | Yes | Ask for approve, revise, or block after package is ready. |
| Packet 08 recommends targeted revision, not beta readiness. | Screenshots show a stronger opening route, but fixture/counter/mall/receiving silhouettes still read too primitive for the intended visual bar. | Yes | Owner should choose approve, revise, or block. |
| `scripts/validate_godot.sh` and the contact sheet remain regression evidence only. | The graybox-era gate proves the build and screenshot contracts, not final art approval. | No | Use screenshot notes and a real-window walkthrough for design approval. |

## Implementation Notes

- Added `docs/production/14-owner-visual-review-package.md`.
- Recorded branch, commit range, latest implementation commit, validation output, artifact paths, screenshot-level notes, open residual risks, resolved improvements, and owner decision options.
- Updated `docs/status.json`, current state, doc indexes, visual bug list, QA screenshot review, and doc status tests.
- Marked Packet 08 complete and set the current phase to owner visual review.
- Lead recommendation is targeted visual revision before beta/tester packaging.

## Stop Conditions

- Final screenshots are missing or stale.
- Full validation did not run or failed.
- Known visual blocker remains and cannot be corrected locally.
- Owner decision is needed to approve/revise/block.
- Tester readiness would require hiding unresolved blockers.

## Continue Conditions

- Owner approves the opening-store baseline.
- Validation is current.
- Known issues are documented.
- Next work can move to tester/beta readiness or owner-specified corrections.

## Final Handoff Requirements

- Commit hash
- Branch
- Commit range
- Screenshot/contact-sheet paths
- Validation command/result
- Known residual issues
- Recommendation: approve, revise, or block
- Owner decisions needed

## Final Handoff

- Completion commit: the Packet 08 docs/status commit that includes this handoff.
- Branch: `codex/hard-visual-benchmark-implementation`.
- Commit range: `94f7bef6..f87e7260` before this Packet 08 commit.
- Review package: `docs/production/14-owner-visual-review-package.md`.
- Screenshot folder: `artifacts/validation/latest/screenshots/`.
- Contact sheet: `artifacts/validation/latest/screenshot-contact-sheet.png`.
- Validation command/result: `scripts/validate_godot.sh` passed in the current implementation pass with 581 tests and 11809 asserts.
- Known residual issues: primitive fixture/counter silhouettes, sparse mall approach/facade, receiving station still label-heavy, and current contact sheet too small/mixed-purpose for final visual approval.
- Recommendation: revise before beta/tester package.
- Owner decisions needed: approve, revise, or block the current opening-store visual baseline.
