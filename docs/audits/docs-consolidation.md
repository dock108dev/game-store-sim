# Documentation Consolidation Audit

## Changed

### `docs/testing.md`

- Clarified that `tests/run_tests.sh` is the default local validation wrapper
  and writes local GUT output to `artifacts/logs/gut/test_run.log`.
- Added the code-backed CI GUT runner details for `scripts/run_godot_tests.sh`:
  store-session naming validation, resource integrity, `.gutconfig.json`, the
  raw CI log at `artifacts/logs/gut/gut.log`, the `All tests passed` summary
  gate, and unexpected `ERROR:` detection after documented shutdown-noise
  filtering.

### `docs/configuration-deployment.md`

- Tightened the helper-script inventory so `run_godot_tests.sh` is documented
  as the CI GUT/export validation helper, matching `.github/workflows/*.yml`
  and avoiding confusion with the local `tests/run_tests.sh` wrapper.

### `docs/audits/docs-consolidation.md`

- Replaced the stale previous consolidation report with this current pass
  record.

## Deleted

- Deleted `docs/audits/cleanup-report.md`. It was a historical source-cleanup
  report with code-refactor summaries and forward-looking split plans, not an
  active code-grounded project doc. Keeping it under `/docs` violated the
  current rule that every maintained doc must earn its existence from current
  code/config/CI truth.

## Statements Removed As Unverifiable Or Non-Current

- Removed the cleanup report's large-file split plans. They were future work
  recommendations rather than current behavior, configuration, or CI contract.
- Removed the previous docs-consolidation report's old validation results and
  stale change log. Validation claims belong to the pass that actually ran
  them.

## Intentional Gaps

- `BRAINDUMP.md` was left untouched because it is the customer-voice file and
  the pass instructions explicitly said never to rewrite it.
- Markdown under `.github/`, `addons/`, `.aidlc`, `artifacts/`, and `tests/`
  was not moved into `/docs` in this pass. Those files are GitHub templates,
  vendored material, generated/tool output, or validator-required ownership
  markers, not the maintained project-doc set named by `README.md` and
  `docs/index.md`.
- Code comments that reference older design/audit documents were not edited
  because this pass was constrained to Markdown under `README.md` and `/docs`;
  a code-comment cleanup pass that permits non-Markdown edits would bring
  those references in scope.

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

- Markdown placement inventory: active maintained project docs are
  `README.md` and the Markdown files under `/docs`; the repository root
  contains only `README.md` plus preserved `BRAINDUMP.md`.
- Stale-reference scan over `README.md` and `/docs`: no active docs reference
  removed design docs or the deleted cleanup report, except this audit's
  deletion record for `docs/audits/cleanup-report.md`.
- `git diff --check`: passed.
- `bash tests/validate_gut_config_discovery.sh`: passed.
- `bash scripts/validate_export_config.sh`: passed.
- `bash tests/run_tests.sh`: passed. GUT reported `Scripts 421`,
  `Tests 4925`, `Passing 4925`; the configured shell validators and SSOT
  tripwires also passed.

## Escalations

- None.
