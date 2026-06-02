# Documentation Consolidation Audit

Date: 2026-06-02

## Changed

### `docs/audits/cleanup-report.md`

- Rewrote the file from a source-cleanup pass changelog into a durable
  current-state reference.
- Kept only code-backed justifications for the large source files and broad
  visual suites currently cited by source comments.
- Added current LOC evidence for the grouped production files.
- Removed prior-pass validation claims from this file; validation for this
  documentation pass is recorded below instead.

### `docs/audits/security-report.md`

- Added the missing section targets currently cited by code comments:
  `§1`, `§2`, `§3`, and `§4`.
- Kept the existing finding IDs `F1`, `F2`, `F-09`, and `F-87`, with each row
  grounded in current code and tests.
- Clarified the current bounds for boot-error BBCode escaping, employment
  persisted ids, hidden-thread save collections, settings numeric values,
  tutorial progress data, save numeric hardening, and ambient-moment dedupe.

### `docs/audits/error-handling-report.md`

- Added the missing section and finding targets currently cited by code
  comments: `§2`, `§3`, `§4`, `F2`, `F-56`, and `F-97`.
- Reorganized the report by current code surface: runtime assertions, content
  and world metadata, UI invariants, checkout/register, typed autoload access,
  and early-boot/test seams.
- Preserved existing code-backed IDs (`EH-*`, `F-*`, and `J*`) while removing
  no-longer-helpful prose around them.

### `docs/audits/docs-consolidation.md`

- Replaced the previous consolidation record with this pass record.
- Recorded the actual Markdown edits, statements removed, intentional gaps,
  and validation results for this pass.

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
- `docs/index.md` against the maintained Markdown set.
- `docs/audit/pass-fail-matrix.md` against
  `tests/audit_required_checkpoints.txt` and `tests/audit_run.sh`.
- `docs/research/canvas-layer-z-order-conflicts.md` against
  `game/scripts/ui/ui_layers.gd` and
  `tests/gut/test_canvas_layer_bands_issue_007.gd`.
- `docs/research/store-ready-contract-examples.md` against
  `game/scripts/stores/store_ready_contract.gd`.
- `docs/decisions/0007-remove-sneaker-citadel.md` against
  `game/autoload/store_registry.gd`,
  `game/content/stores/store_definitions.json`, and
  `tests/validate_issue_019_store_registry.sh`.
- `docs/roadmap.md` against `tests/validate_issue_032.sh`,
  `game/assets/shaders/outline_highlight.gdshader`,
  `game/assets/shaders/mat_outline_highlight.tres`, and
  `game/scripts/components/interactable.gd`.
- `tests/automation/README.md`, `tests/baselines/README.md`,
  `tests/flows/README.md`, and `tests/visual/README.md` against
  `tests/validate_gut_config_discovery.sh`.

## Statements Removed As Unverifiable Or Non-Current

- Removed the cleanup report's code-pass changelog as active documentation.
  The deleted-test and lint-fix claims belong to a source-cleanup pass, not a
  durable docs reference.
- Removed stale validation result claims from
  `docs/audits/cleanup-report.md`. This pass records its own validation below.
- Removed vague split recommendations from the cleanup report where they were
  phrased as future work instead of current ownership rationale.

## Intentional Gaps

- `BRAINDUMP.md` was left untouched because it is customer voice.
- Markdown under `.github/` was not moved into `/docs`; those files are GitHub
  issue/PR templates and need to remain in `.github/` to function.
- The four `tests/*/README.md` ownership markers remain outside `/docs`
  because `tests/validate_gut_config_discovery.sh` requires them.
- Markdown under `addons/`, `.aidlc`, `artifacts/`, and `inspiration/` was not
  rewritten because those trees are vendored material, generated/tool output,
  or customer/reference material rather than active maintained project docs.
- Non-Markdown source comments that reference historical design material such
  as `DESIGN.md`, `BRAINDUMP`, or old research names were not edited because
  this pass is Markdown-only. A source-comment cleanup pass would bring those
  comments into scope.

## Validation

- Maintained Markdown inventory checked: active project docs are `README.md`
  plus `docs/**/*.md`; root Markdown remains `README.md` and preserved
  `BRAINDUMP.md`; validator-required test README files remain in `tests/`.
- Active Markdown link check: passed.
- Code-comment doc target check: passed for cited `docs/**/*.md` files and
  section IDs covered by this pass.
- `bash tests/validate_gut_config_discovery.sh`: passed.
- `bash scripts/validate_export_config.sh`: passed.
- `git diff --check`: passed.
- `bash tests/run_tests.sh`: passed. GUT reported `Scripts 445`,
  `Tests 5183`, `Passing 5183`; maintained shell validators and SSOT
  tripwires also passed.

## Escalations

None.
