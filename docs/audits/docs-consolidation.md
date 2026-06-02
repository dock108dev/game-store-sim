# Documentation Consolidation Audit

Date: 2026-06-02

## Changed

### `docs/audits/cleanup-report.md`

- Rewrote the source-cleanup changelog into a current-state cleanup reference.
- Removed broad future extraction plans and old validation result claims.
- Kept only the current large-file and broad-suite justifications that are
  cited by file-level code comments.

### `docs/audits/error-handling-report.md`

- Added the missing audit reference file for current code comments that cite
  `EH-AS-1`, `EH-*`, `F-*`, and `J*` handled-error contracts.
- Grounded every row in the current code location that implements or tests the
  behavior.

### `docs/audits/security-report.md`

- Added the missing hardening reference file for current comments/tests that
  cite tutorial progress bounds, save numeric hardening, and ambient-moment
  dedupe bounds.

### `docs/audits/phase0-ui-integrity.md`

- Added the missing UI SSOT reference file for objective/tutorial copy
  separation, the local SSOT tripwires, and the modal canvas-layer contract.

### `docs/audit/pass-fail-matrix.md`

- Added the missing runtime-audit matrix referenced by `tests/audit_run.sh` and
  `tests/audit_required_checkpoints.txt`.
- Documented the executable checkpoint manifest and gate behavior instead of
  inventing a second source of truth.

### `docs/research/canvas-layer-z-order-conflicts.md`

- Added the missing CanvasLayer band table referenced by `UILayers`, the CRT
  overlay, and canvas-layer GUT coverage.

### `docs/research/store-ready-contract-examples.md`

- Added the missing store-ready invariant reference cited by
  `StoreReadyContract`.

### `docs/decisions/0007-remove-sneaker-citadel.md`

- Added the missing decision note cited by StoreRegistry tests and validators.
- Documented the current data-driven store roster and residue guard.

### `docs/roadmap.md`

- Added a narrow maintenance roadmap because `tests/validate_issue_032.sh`
  validates that the custom shader item is marked complete.
- Limited the file to the completed, code-backed shader acceptance item.

### `docs/index.md`

- Updated the index to include the new audit, decision, research, and
  maintenance reference docs.

## Re-Verified Without Text Changes

- `README.md` against `project.godot`, `export_presets.cfg`, and
  `.github/workflows/export.yml`.
- `docs/setup.md` against `project.godot`, `scripts/godot_resolver.sh`,
  `scripts/godot_import.sh`, `scripts/godot_exec.sh`, `tests/run_tests.sh`,
  and the current repository layout.
- `docs/architecture.md` against `project.godot`,
  `game/scripts/core/boot.gd`, `game/scenes/world/game_world.gd`,
  `game/autoload/event_bus.gd`, `game/autoload/scene_router.gd`,
  `game/autoload/store_director.gd`, and named scene/script files.
- `docs/architecture/ownership.md` against owner autoloads, emitted signals,
  state-machine code, and validation scripts.
- `docs/content-data.md` against `game/content/`,
  `game/autoload/data_loader.gd`, `game/autoload/content_registry.gd`,
  `game/scripts/visuals/store_visual_layout.gd`, and the visual contract
  validators.
- `docs/testing.md` against `tests/run_tests.sh`,
  `scripts/run_godot_tests.sh`, `.gutconfig.json`,
  `.gutconfig.pr-smoke.json`, `.github/workflows/validate.yml`,
  `.github/workflows/nightly.yml`, `.github/workflows/nightly-videos.yml`,
  `.github/workflows/export.yml`, and the automation scenario code.
- `docs/configuration-deployment.md` against `project.godot`,
  `export_presets.cfg`, `scripts/`, `tests/audit_run.sh`, and
  `.github/workflows/*.yml`.
- `docs/style/visual-grammar.md` against
  `game/scripts/ui/ui_theme_constants.gd`, `project.godot`, and the checked-in
  theme resources.
- `tests/automation/README.md`, `tests/baselines/README.md`,
  `tests/flows/README.md`, and `tests/visual/README.md` against
  `tests/validate_gut_config_discovery.sh`.

## Statements Removed As Unverifiable Or Non-Current

- Removed the cleanup report's broad future split inventory. Those entries were
  not required to explain a current ownership contract and read like a backlog.
- Removed old validation claims from `docs/audits/cleanup-report.md`; this
  documentation pass re-runs its own validation instead of preserving previous
  pass results as current truth.
- Replaced the old docs-consolidation claim that
  `docs/audits/cleanup-report.md` was deleted. The file exists in the current
  working tree and current code comments cite it.

## Intentional Gaps

- `BRAINDUMP.md` was left untouched because it is customer voice.
- Markdown under `.github/` was not moved into `/docs`; those files are GitHub
  issue/PR templates and need to remain in `.github/` to function.
- The four `tests/*/README.md` ownership markers remain outside `/docs`
  because `tests/validate_gut_config_discovery.sh` requires them.
- Markdown under `addons/`, `.aidlc`, `artifacts/`, and `inspiration/` was not
  rewritten because those trees are vendored material, generated/tool output,
  or customer/reference material rather than active maintained project docs.
- Existing non-markdown code comments that reference audit section ids were
  left in place; this pass added the missing markdown targets instead of
  changing code.

## Validation

- Maintained markdown inventory checked: active project docs are `README.md`
  plus `docs/**/*.md`; root markdown remains `README.md` and preserved
  `BRAINDUMP.md`; validator-required test README files remain in `tests/`.
- Active markdown link check: passed.
- Code-comment doc target check: passed for referenced `docs/**/*.md` paths.
- `bash tests/validate_gut_config_discovery.sh`: passed.
- `bash scripts/validate_export_config.sh`: passed.
- `git diff --check`: passed.
- `bash tests/run_tests.sh`: passed. GUT reported `Scripts 446`,
  `Tests 5191`, `Passing 5191`; maintained shell validators and SSOT
  tripwires also passed.

## Escalations

None.
