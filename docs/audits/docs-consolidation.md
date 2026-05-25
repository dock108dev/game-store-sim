# Documentation Consolidation Pass - 2026-05-25

## Changed

### `docs/architecture.md`

- Updated the boot flow to include the `boot_scene_ready` audit checkpoint and
  the `AutomationRunner` takeover path after successful boot.
- Updated the autoload roster to match the current `project.godot` order,
  including `RandomStreamIds`, `GameRandom`, `UserDataPaths`, `ScenarioExit`,
  and `AutomationRunner`.

### `docs/configuration-deployment.md`

- Added `tutorial_progress.cfg`, `user://test_runs/<run_id>/`, and
  `UserDataPaths` to the persistence model.
- Added the current CI/helper script surface:
  `scripts/run_godot_tests.sh`, `scripts/run_fresh_install_smoke.sh`, and
  `scripts/render_nightly_videos.sh`.
- Updated the validation workflow summary to include the fresh-install smoke
  step.
- Added the scheduled/manual nightly scenario-video workflow.

### `docs/index.md`

- Replaced the stale claim that `tests/audit_run.sh` generates dated
  `docs/audits/YYYY-MM-DD-audit.md` tables. Current audit logs and reports are
  artifact-tree outputs.
- Documented that the four test-tree ownership README files are an intentional
  validator-backed exception to the active docs boundary.

### `docs/setup.md`

- Kept the test log path aligned with the current artifact tree.
- Folded the test-subdirectory ownership notes into the repository layout.

### `docs/testing.md`

- Kept the full `.gutconfig.json` and `.gutconfig.pr-smoke.json` descriptions
  aligned with the current configs.
- Removed the stale `tests/gut_pre_run.gd` compatibility claim; the active GUT
  pre-run script is `res://tests/automation/gut_pre_run.gd`.
- Added the fresh-install smoke step and the nightly scenario-video workflow to
  the CI validation section.

## Deleted

- `docs/audits/cleanup-report.md` — a cleanup-pass record with source-refactor
  summaries and large-file plans. It was not active project documentation and
  duplicated transient code-review history.

## Statements Removed As Unverifiable Or Non-Current

- The stale `tests/audit_run.sh` dated-doc generation claim.
- The stale `tests/gut_pre_run.gd` compatibility entry.
- The cleanup report's code-refactor summaries, test-count claims, and
  future split recommendations.

## Intentional Gaps

- `README.md` needed no rewrite this pass: it already contains the required
  repository identity, local run steps, deployment basics, and `/docs` pointer.
- `BRAINDUMP.md` remains untouched because it is customer voice.
- Markdown under `.github/` remains because GitHub consumes the issue and
  pull-request templates from that location.
- `tests/automation/README.md`, `tests/baselines/README.md`,
  `tests/flows/README.md`, and `tests/visual/README.md` remain because
  `tests/validate_gut_config_discovery.sh` treats them as required ownership
  contract files. Moving that contract under `/docs` would require changing the
  validator, which is outside this docs-only pass.
- Markdown under `addons/` remains because it is vendored GUT material.
- Markdown under `.aidlc/` remains because it is generated/tooling output
  outside the active docs boundary.
- Existing non-doc dirty-tree changes were left untouched because this was a
  docs-only consolidation pass.

## Validation

- Source of truth inspected: `project.godot`, `export_presets.cfg`,
  `.github/workflows/validate.yml`, `.github/workflows/export.yml`,
  `.github/workflows/nightly-videos.yml`, `.gutconfig.json`,
  `.gutconfig.pr-smoke.json`, `tests/run_tests.sh`,
  `scripts/run_godot_tests.sh`, `tests/audit_run.sh`,
  `scripts/artifact_paths.sh`, `scripts/run_fresh_install_smoke.sh`,
  `scripts/render_nightly_videos.sh`, `scripts/validate_export_config.sh`,
  `game/scripts/core/boot.gd`, `game/autoload/automation_runner.gd`,
  `game/autoload/user_data_paths.gd`, `game/autoload/data_loader.gd`,
  `game/autoload/content_registry.gd`, `game/autoload/game_manager.gd`,
  `game/scenes/world/game_world.gd`, `game/autoload/store_director.gd`,
  `game/autoload/scene_router.gd`, `game/autoload/camera_authority.gd`,
  `game/scripts/core/save_manager.gd`, and
  `game/scripts/ui/ui_theme_constants.gd`.
- Markdown file inventory checked for active docs outside `README.md` and
  `docs/`; only GitHub templates, required test ownership contracts,
  vendored/addon material, generated/tooling output, and customer voice remain
  outside the active docs set.
- Markdown link check over `README.md` and `docs/**/*.md`: passed
  (`Markdown links OK`).
- `bash scripts/validate_export_config.sh`: passed
  (`Export config validation: OK`).
- `bash tests/validate_gut_config_discovery.sh`: passed
  (`GUT config discovery OK`).
- `git diff --check -- README.md docs tests/automation/README.md
  tests/baselines/README.md tests/flows/README.md tests/visual/README.md`:
  passed.
- `bash tests/run_tests.sh`: passed. GUT reported `Scripts 406`,
  `Tests 4782`, `Passing 4782`; configured shell validators and SSOT tripwires
  also passed.

## Escalations

None for the active `README.md` plus `docs/` documentation set.
