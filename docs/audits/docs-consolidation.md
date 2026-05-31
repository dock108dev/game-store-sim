# Documentation Consolidation Audit

## Changed

### `README.md`

- Re-verified the root README against `project.godot`, `export_presets.cfg`,
  `game/content/`, `.github/workflows/export.yml`, and the checked-in GUT
  addon. No text changes were required.

### `docs/setup.md`

- Removed the duplicated step-by-step summary of `tests/run_tests.sh`; the
  current runner contract now lives only in `docs/testing.md`.
- Kept setup focused on requirements, opening the project, command-line helper
  use, the local validation command, and repository layout.

### `docs/testing.md`

- Removed the broad "current coverage areas" feature list. The test layout,
  `.gutconfig*.json` discovery rules, runner steps, automation flags, scenario
  exit codes, and CI jobs remain documented from code/config.

### Re-verified docs

- Re-verified `docs/index.md`, `docs/architecture.md`,
  `docs/architecture/ownership.md`, `docs/content-data.md`,
  `docs/configuration-deployment.md`, and
  `docs/style/visual-grammar.md` against the current code/config/CI surfaces
  listed below. No text changes were required.

### `docs/audits/docs-consolidation.md`

- Replaced the stale previous consolidation report with this current pass record.

## Deleted

- Deleted untracked `docs/audits/cleanup-report.md`. It was a historical source-cleanup
  report with code-refactor summaries and forward-looking split plans, not an
  active code-grounded project doc. Keeping it under `/docs` violated the
  current rule that every maintained doc must earn its existence from current
  code/config/CI truth.

## Statements Removed As Unverifiable Or Non-Current

- Removed the cleanup report's large-file split plans. They were future work
  recommendations rather than current behavior, configuration, or CI contract.
- Removed the previous docs-consolidation report's stale validation results and
  change log. Validation claims belong to the pass that actually ran them.
- Removed the setup page's duplicate runner-step list; duplicated procedural
  descriptions make the docs easier to drift from `tests/run_tests.sh`.
- Removed the testing page's broad feature-coverage list because it summarized
  intent across many tests instead of a compact, directly enforced contract.

## Intentional Gaps

- `BRAINDUMP.md` was left untouched because it is the customer-voice file and
  the pass instructions explicitly said never to rewrite it.
- Markdown under `.github/`, `addons/`, `.aidlc`, `artifacts/`, and `tests/`
  was not moved into `/docs` in this pass. Those files are GitHub templates,
  vendored material, generated/tool output, or validator-required ownership
  markers, not the maintained project-doc set named by `README.md` and
  `docs/index.md`.
- Code comments that reference older design/audit documents were not edited
  because this pass was constrained to Markdown documentation. A code-comment
  cleanup pass that permits non-Markdown edits would bring those references in
  scope.

## Source Files Inspected

- Project/config: `project.godot`, `export_presets.cfg`, `.gutconfig.json`,
  `.gutconfig.pr-smoke.json`.
- CI: `.github/workflows/validate.yml`, `.github/workflows/nightly.yml`,
  `.github/workflows/nightly-videos.yml`, `.github/workflows/export.yml`.
- Local/CI scripts: `tests/run_tests.sh`, `scripts/run_godot_tests.sh`,
  `scripts/godot_resolver.sh`, `scripts/godot_import.sh`,
  `scripts/godot_exec.sh`, `scripts/setup_godot.sh`,
  `scripts/run_fresh_install_smoke.sh`, `scripts/run_store_visual_sweep.sh`,
  `scripts/render_nightly_videos.sh`, `scripts/validate_export_config.sh`,
  `tests/audit_run.sh`, `tests/validate_gut_config_discovery.sh`.
- Runtime/code truth: `game/scripts/core/boot.gd`,
  `game/scenes/world/game_world.gd`, `game/autoload/game_manager.gd`,
  `game/autoload/automation_runner.gd`, `game/autoload/scenario_exit.gd`,
  `game/autoload/user_data_paths.gd`, `game/scripts/core/save_manager.gd`,
  `game/autoload/data_loader.gd`, `game/autoload/content_registry.gd`,
  `game/scripts/ui/ui_theme_constants.gd`, and the checked-in
  `game/content/` tree.

## Validation

- Markdown placement inventory: maintained project docs are `README.md` plus
  Markdown under `docs/`. The only root Markdown files are `README.md` and the
  preserved customer-voice `BRAINDUMP.md`; the four `tests/*/README.md`
  ownership markers remain because `tests/validate_gut_config_discovery.sh`
  requires them.
- `git diff --check`: passed.
- `bash tests/validate_gut_config_discovery.sh`: passed.
- `bash scripts/validate_export_config.sh`: passed.
- `bash tests/run_tests.sh`: passed. GUT reported `Scripts 425`,
  `Tests 4971`, `Passing 4971`; the maintained shell validators and SSOT
  tripwires also passed.

## Escalations

- None.
