# Agent Work Packet Template

## Goal

Define the standard packet format for future implementation agents.

The packet must let an agent start work without rediscovering project intent, must prevent drift back into graybox/prototype visuals, and must produce enough evidence that future test/beta users are not left guessing what changed, what passed, what failed, or what still needs owner judgment.

This template is intentionally detailed. Agents can work faster when the handoff is strict, the boundaries are explicit, and the required evidence is known before implementation starts.

## Packet Philosophy

Every packet should answer:

- what is being built
- why it matters to the opening-store visual reset
- which docs are authoritative
- what files/systems are likely involved
- what not to do
- how to validate
- what screenshots/evidence to return
- when to keep going
- when to stop and ask

The output should be reviewable by a lead engineer, owner, or later tester without reconstructing context from chat history.

## Required Packet Header

Each packet starts with:

```markdown
# Work Packet: <slice name>

Status: Not started | In progress | Blocked | Ready for review | Complete
Owner decision required: Yes | No
Target branch: <branch>
Primary doc: <path>
Dependencies: <paths>
Expected commit scope: <short description>
```

Status definitions:

- `Not started`: packet is ready but no implementation has begun.
- `In progress`: implementation is active.
- `Blocked`: work cannot continue without owner/lead decision or external fix.
- `Ready for review`: implementation and validation evidence are complete.
- `Complete`: reviewed and accepted into the implementation pass.

## Required Read-First Section

Every implementation packet must include a read-first list.

Minimum required:

```markdown
## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. Current packet primary doc
5. All dependency docs listed below
```

Packet-specific dependencies should be explicit. Do not say “read all docs” when only some are required, but include all docs whose rules affect the work.

For broad opening-store implementation passes, include:

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

## Required Context Section

Each packet must summarize context in concrete terms:

```markdown
## Context

- Current problem:
- Target player-facing result:
- Existing systems that must keep working:
- Visual/design docs that define success:
- Known prior failures to avoid:
```

Context should be specific enough that an agent understands the visual bar, not just the task title.

Example prior failures:

- still reads as cubes/prototype
- too many floating labels
- stockroom reads as a half-wall back area
- future inventory appears physically staged
- products look like colored blocks instead of cases
- signage does the work instead of fixtures/products/architecture

## Scope Section

Each packet must define scope.

```markdown
## In Scope

- ...

## Out Of Scope

- ...
```

Scope rules:

- In scope should be implementable in one focused pass.
- Out of scope must block common drift.
- Do not broaden into catalog/decor/customer/hidden-narrative work unless the packet explicitly says so.
- If an implementation discovers required adjacent work, log it and decide whether it is needed for completion.

## Required Do-Not-Do Section

Every packet must include explicit anti-regression rules.

Required defaults:

- Do not use visible debug labels as final object identity.
- Do not leave raw primitive cubes as final visible assets.
- Do not stage future locked inventory physically on the sales floor.
- Do not add clutter just to fill empty space.
- Do not make fixed category zones that remove player organization unless explicitly required.
- Do not move trade-ins away from the checkout counter.
- Do not make receiving visible from the sales floor.
- Do not hard-lock the store name or palette unless a doc explicitly changes that.
- Do not replace visual review with automated-test success.
- Do not revert unrelated user/agent changes.

Add packet-specific do-not-do rules as needed.

## Implementation Plan Section

Each packet must include a short implementation plan.

```markdown
## Implementation Plan

1. Inspect existing scene/script/data structure.
2. Identify local patterns to reuse.
3. Implement assets/scenes/data changes.
4. Integrate with existing systems.
5. Update docs/tests/status as needed.
6. Capture final screenshots.
7. Run validation gate for implementation work.
8. Commit and push.
```

The plan can be adjusted during implementation, but deviations must be logged in the decision log.

## Likely Files Section

Each packet must list likely file areas.

```markdown
## Likely Files

Scenes:
- ...

Scripts:
- ...

Assets:
- ...

Data:
- ...

Tests:
- ...

Docs:
- ...
```

Agents must still inspect the repo before editing. This section is a map, not permission to blindly rewrite.

## Validation Section

Implementation packets must require validation evidence.

```markdown
## Validation Required

Docs-only packet:
- Do not run `scripts/validate_godot.sh`.
- Update doc/status contract if active docs change.
- Commit docs/status/test-contract changes.

Implementation packet:
- Capture final game-window screenshots first.
- Review screenshots with detailed notes.
- Run focused tests for changed contracts.
- Run `scripts/validate_godot.sh`.
- Confirm artifacts under `artifacts/validation/latest/`.
```

Validation order follows [Validation And Screenshot Checklist](12-validation-and-screenshot-checklist.md):

1. Final game-window screenshots.
2. Detailed screenshot notes.
3. Automated validation.
4. Review package.

Do not claim validation passed unless the relevant command actually ran in the current implementation pass.

## Screenshot Evidence Section

Each packet must define screenshot evidence.

```markdown
## Screenshot Evidence

Required final screenshots:
- ...

Use existing automated screenshots when they already answer the review question.
Add targeted screenshots only when current artifacts miss the design question.
Game-window screenshots are required unless editor mode is explicitly needed.
```

Before/after screenshots are optional. Final state is required.

## Tests Section

Each packet must define expected tests.

```markdown
## Tests To Add Or Update

- ...

## Tests To Run

- focused command(s)
- `scripts/validate_godot.sh` for implementation work
```

If tests cannot be run, the final handoff must explain why and what risk remains.

## Documentation Updates Section

Each packet must state docs/status updates.

```markdown
## Documentation Updates

- Update behavior docs if implementation changes behavior.
- Update design implementation doc if implementation clarifies/changes the slice.
- Update `docs/status.json` only when project status/active docs/validation metadata changes.
- Update doc status contract tests when active docs/status contract changes.
- Do not claim a new validated baseline without running validation.
```

## Decision Log Section

Every packet must include a decision log.

```markdown
## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
|  |  |  |  |
```

Log:

- assumptions made
- local implementation choices
- rejected alternatives
- deviations from the packet
- owner/lead decisions needed

This keeps future testers from asking why the store changed in a certain way.

## Stop Conditions

Every packet must say when to stop.

Default stop conditions:

- implementation cannot satisfy the source-of-truth docs
- a design decision would invalidate later slices
- legal/name/brand risk appears
- core gameplay mechanic must change
- validation exposes a blocker
- screenshots reveal the plan is visually wrong
- owner/lead decision is required before continuing

Do not stop merely because a slice is done if the roadmap says to continue and no decision is needed.

## Continue Conditions

Every packet must say when to continue.

Default continue conditions:

- dependencies are complete
- implementation can preserve existing mechanics
- visual/design rules are clear
- failures are fixable without owner decision
- the next slice is non-conflicting

Agents should keep working until the packet/phase is complete, validation fails, or a real decision point appears.

## Standard Final Handoff

Every implementation agent final response should use this structure:

```markdown
Completed:
- <concrete changes>

Evidence:
- Commit: <hash>
- Branch: <branch>
- Screenshots/contact sheet: <path>
- Validation: <command/result>

Notes:
- <important implementation decisions>
- <known residual issues>

Owner/Lead Decisions Needed:
- None
```

If blocked:

```markdown
Blocked:
- <specific blocker>

Evidence:
- <what was tried>
- <logs/screenshots/commands>

Decision Needed:
- <specific question>
```

Avoid vague final responses such as “done” or “looks better.” The handoff must make review possible without digging.

## Parallel Work Rules

Packets may support multiple agents only when slices are independent.

Allowed parallelization:

- separate docs-only planning docs
- independent asset modules with clear integration contracts
- test/tooling work that does not touch the same scenes/assets
- research/reference capture that does not change implementation files

Avoid parallelization:

- same scene file edits
- same product/catalog data edits
- same validation/status contract edits
- shared store layout/footprint decisions
- work that depends on one visual direction not yet proven

When multiple agents work in parallel, a lead agent must merge, run validation, and produce one final review package.

## Commit And Push Rules

Each completed packet should be committed and pushed.

Rules:

- commit scope should match the packet
- do not include unrelated files
- do not revert unrelated user/agent changes
- include docs/tests updates with implementation changes
- push to the active branch when commit succeeds

For docs-only packet completion, commit docs/status/test-contract updates and push before asking the next questions.

## Template

Copy this for future packets:

```markdown
# Work Packet: <slice name>

Status:
Owner decision required:
Target branch:
Primary doc:
Dependencies:
Expected commit scope:

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `<primary doc>`
5. `<dependency docs>`

## Context

- Current problem:
- Target player-facing result:
- Existing systems that must keep working:
- Visual/design docs that define success:
- Known prior failures to avoid:

## In Scope

- 

## Out Of Scope

- 

## Do Not Do

- Do not use visible debug labels as final object identity.
- Do not leave raw primitive cubes as final visible assets.
- Do not stage future locked inventory physically on the sales floor.
- Do not add clutter just to fill empty space.
- Do not replace visual review with automated-test success.

## Implementation Plan

1. Inspect existing scene/script/data structure.
2. Identify local patterns to reuse.
3. Implement assets/scenes/data changes.
4. Integrate with existing systems.
5. Update docs/tests/status as needed.
6. Capture final screenshots.
7. Run validation gate for implementation work.
8. Commit and push.

## Likely Files

Scenes:
- 

Scripts:
- 

Assets:
- 

Data:
- 

Tests:
- 

Docs:
- 

## Validation Required

Docs-only packet:
- Do not run `scripts/validate_godot.sh`.
- Update doc/status contract if active docs change.

Implementation packet:
- Capture final game-window screenshots first.
- Review screenshots with detailed notes.
- Run focused tests for changed contracts.
- Run `scripts/validate_godot.sh`.
- Confirm artifacts under `artifacts/validation/latest/`.

## Screenshot Evidence

Required final screenshots:
- 

## Tests To Add Or Update

- 

## Tests To Run

- 

## Documentation Updates

- 

## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
|  |  |  |  |

## Stop Conditions

- 

## Continue Conditions

- 

## Final Handoff Requirements

- Commit hash
- Branch
- Screenshot/contact-sheet paths
- Validation command/result
- Known residual issues
- Owner/lead decisions needed
```

## Acceptance Checklist

- [ ] Packet tells agents exactly what to read first.
- [ ] Packet separates scope from out-of-scope.
- [ ] Packet includes explicit do-not-do rules.
- [ ] Packet requires decision logging.
- [ ] Packet requires final screenshot evidence for implementation work.
- [ ] Packet keeps docs-only work validation-free.
- [ ] Packet requires automated validation for implementation work.
- [ ] Packet defines stop and continue conditions.
- [ ] Packet defines final handoff format.
- [ ] Packet supports parallel work only when file ownership and integration risk are clear.

## Fail Conditions

This template fails if:

- agents can complete work without evidence
- future testers cannot tell what changed
- validation status is ambiguous
- decisions are hidden in chat context
- agents can accidentally drift into graybox/prototype shortcuts
- owner is asked to untangle incomplete handoffs

## Commit Expectation

Commit this template as a docs-only slice with active-doc/status/test-contract updates. Do not run validation for this planning-only document.

## Next Document

After this doc, write `14-phase-implementation-roadmap.md` to define the master dependency map from planning through implementation, validation, owner review, and beta/tester readiness.
