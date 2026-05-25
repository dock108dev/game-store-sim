# Documentation Consolidation Pass - 2026-05-25

## Changed

### `README.md`

- Updated deployment basics to distinguish version-tag release publishing from
  manual release-candidate dispatches in `.github/workflows/export.yml`.

### `docs/index.md`

- Tightened the documentation boundary language around the four
  validator-required test ownership README files.
- Moved visual-baseline policy ownership to `docs/testing.md`.

### `docs/setup.md`

- Updated the local test-runner sequence to include static repo guards,
  resource integrity, GUT environment seeding, and the current shell-validator
  order from `tests/run_tests.sh`.
- Updated the test layout summary to include display-backed store visual sweep
  baselines.

### `docs/testing.md`

- Updated `tests/run_tests.sh` behavior to match the current runner:
  static repo guards first, Godot import/resource integrity when available,
  GUT environment seeding, GUT, optional `game/tests/run_tests.gd`, maintained
  shell validators, and SSOT tripwires.
- Added the full `.gutconfig.json` `post_run_script`.
- Added current automation CLI ownership, supported scenario IDs, flags, and
  speed-clamping behavior from `AutomationRunner`.
- Folded the store visual sweep baseline contract into the active testing doc,
  including the default
  `tests/visual/baselines/retro_games_day_one/<godot-version>/linux/` path,
  `MALLCORE_VISUAL_BASELINE_DIR`, and the missing-baseline advisory behavior.
- Added `artifacts/visual_sweep/<suite>/` to the artifact-path table.
- Tightened the CI validation summaries to match the current PR, nightly,
  video, and export workflows.

### `docs/configuration-deployment.md`

- Expanded the checked-in integration list to include current helper scripts:
  Godot setup/resolution, artifact paths, static/resource/export validation,
  fresh-install smoke, visual sweep, nightly videos, audit reports, and
  advisory review report generation.
- Added an environment-variable table for the active local/CI controls:
  `GODOT`, `GODOT_EXECUTABLE`, `GODOT_VERSION`,
  `VALIDATION_GODOT_VERSION`, `MALLCORE_ARTIFACT_DIR`,
  `MALLCORE_SKIP_IMPORT`, `MALLCORE_VISUAL_BASELINE_DIR`, `FPS`, and
  `SCENARIO`.
- Updated PR/export workflow descriptions to match current job boundaries and
  manual dispatch release-candidate behavior.

### `docs/content-data.md`

- Added `customer_profile` to the entry-route documentation.
- Added the current scene-path rejection for `..` segments and empty path
  components.
- Split platform data and product visual catalog data into separate
  non-resource content statements.

### `tests/visual/README.md`

- Kept the validator-required ownership contract, but corrected its expected
  output statement to acknowledge that reviewed store-sweep PNG baselines live
  under `tests/visual/baselines`.

## Deleted

- `docs/audits/cleanup-report.md` — a transient source-refactor report with
  code-change summaries and future split recommendations, not active project
  documentation.
- `tests/visual/baselines/README.md` — non-required test-tree documentation.
  Its code-backed baseline details were folded into `docs/testing.md`.

## Statements Removed As Unverifiable Or Non-Current

- The old docs-consolidation report's prior-pass change summary as the current
  record for this pass.
- The stale implication that all test-tree README files were validator-required.
  Only four are enforced by `tests/validate_gut_config_discovery.sh`.
- The visual test README's statement that reusable visual expected output
  belongs only under `tests/baselines`; the current visual sweep reads
  reviewed PNG baselines from `tests/visual/baselines` by default.
- The cleanup report's code-refactor summaries, large-file inventory, and
  future split recommendations.

## Intentional Gaps

- `BRAINDUMP.md` remains untouched because it is customer voice.
- Markdown under `.github/` remains because GitHub consumes the issue and
  pull-request templates from that location.
- The four `tests/**/README.md` ownership contracts remain outside `/docs`
  because `tests/validate_gut_config_discovery.sh` requires them. Changing
  that location would require a validator change, which is outside this
  docs-only pass.
- Markdown under `addons/` remains because it is vendored GUT material.
- Markdown under `.aidlc/` remains because it is generated/tooling output
  outside the active docs boundary.
- Markdown under `artifacts/` remains generated runtime output, not
  hand-maintained project documentation.
- Existing non-doc dirty-tree changes were left untouched because this was a
  docs-only consolidation pass.

## Validation

- Source of truth inspected: `project.godot`, `export_presets.cfg`,
  `.github/workflows/validate.yml`, `.github/workflows/nightly.yml`,
  `.github/workflows/nightly-videos.yml`, `.github/workflows/export.yml`,
  `.gutconfig.json`, `.gutconfig.pr-smoke.json`, `tests/run_tests.sh`,
  `tests/validate_gut_config_discovery.sh`, `tests/audit_run.sh`,
  `tests/automation/run_pr_smoke.sh`, `scripts/artifact_paths.sh`,
  `scripts/godot_resolver.sh`, `scripts/godot_import.sh`,
  `scripts/godot_exec.sh`, `scripts/setup_godot.sh`,
  `scripts/run_godot_tests.sh`, `scripts/run_fresh_install_smoke.sh`,
  `scripts/run_store_visual_sweep.sh`, `scripts/render_nightly_videos.sh`,
  `scripts/validate_static_repo_guards.sh`,
  `scripts/validate_resource_integrity.sh`,
  `scripts/validate_export_config.sh`,
  `scripts/generate_advisory_review_report.gd`,
  `game/scripts/core/boot.gd`, `game/autoload/automation_runner.gd`,
  `game/autoload/user_data_paths.gd`,
  `game/scripts/core/automation_artifacts.gd`,
  `game/autoload/data_loader.gd`, `game/autoload/content_registry.gd`,
  `game/autoload/game_manager.gd`, `game/autoload/scene_router.gd`,
  `game/scripts/scene_transition.gd`,
  `game/scripts/core/gameplay_shell.gd`,
  `game/scenes/world/game_world.gd`,
  `game/scripts/core/save_manager.gd`,
  `game/autoload/event_log.gd`, and
  `game/scripts/ui/ui_theme_constants.gd`.
- Markdown inventory checked outside `addons/`, `.aidlc/`, `.git`, and
  generated `artifacts/`; remaining hand-maintained markdown outside `/docs`
  is limited to `README.md`, GitHub templates, `BRAINDUMP.md`, and the four
  validator-required test ownership contracts.
- Markdown link check over `README.md` and `docs/**/*.md`: passed
  (`Markdown links OK`).
- `bash scripts/validate_export_config.sh`: passed
  (`Export config validation: OK`).
- `bash tests/validate_gut_config_discovery.sh`: passed
  (`GUT config discovery OK`).
- `git diff --check -- README.md docs tests/visual/README.md`: passed.
- `bash tests/run_tests.sh`: passed. GUT reported `Scripts 411`,
  `Tests 4827`, `Passing 4827`; configured shell validators and SSOT
  tripwires also passed.

## Escalations

None for the active `README.md` plus `/docs` documentation set.
