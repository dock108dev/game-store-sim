# Documentation Consolidation Audit

## Changed

### `README.md`

- Renamed the local command-line section from "test runs" to "validation" so
  it matches `tests/run_tests.sh`, which runs static guards, optional Godot
  resource integrity, GUT, shell validators, and SSOT tripwires.

### `docs/index.md`

- Tightened the Testing entry to cover validation commands and automation
  flags, not only test execution.
- Made the boundary statement explicit for generated `artifacts/` markdown.
- Clarified that `README.md` is the only maintained root project doc while
  `BRAINDUMP.md` remains customer voice.
- Kept the four `tests/**/README.md` ownership contracts named because
  `tests/validate_gut_config_discovery.sh` requires those exact files.

### `docs/setup.md`

- Renamed "Run tests" to "Run validation" for parity with
  `tests/run_tests.sh`.

### `docs/architecture.md`

- Replaced the generic `EventBus.emit_signal(...)` example with the
  code-backed typed-signal pattern used in the tree:
  `EventBus.signal_name.emit(payload)`.

### `docs/testing.md`

- Renamed the primary command section to "Main validation command".
- Clarified that `tests/run_tests.sh` is the default local gate.
- Replaced the generic "full GUT" nightly wording with the actual nightly
  command surface: `scripts/run_godot_tests.sh` plus
  `scripts/run_fresh_install_smoke.sh`.

### `docs/configuration-deployment.md`

- Added `tests/validate_store_session_naming.sh` to the checked-in validation
  surface because `scripts/run_godot_tests.sh` invokes it before the full GUT
  suite.
- Removed `VALIDATION_GODOT_VERSION` from the environment table because the
  current export workflow declares it but does not read it; release validation
  jobs instead override `GODOT_VERSION` directly to `4.6.2-stable`.
- Added the current `scripts/render_nightly_videos.sh` override environment
  variables (`PROJECT_ROOT`, `OUTPUT_ROOT`, `LOG_ROOT`, `SCENARIO_RUNNER`,
  `TIMEOUT_SECONDS`) and the current `tests/audit_run.sh` audit override
  variables.

### `docs/content-data.md`

- Added `DataLoaderSingleton.get_midday_events()` to the runtime access list
  because `game/autoload/data_loader.gd` exposes the structured beat pool
  loaded from `day_beats.json`.

### `docs/audits/docs-consolidation.md`

- Replaced the previous pass report with this pass's current change record,
  removed-statement list, intentional gaps, validation evidence, and
  escalation status.

## Deleted

- `docs/audits/cleanup-report.md` was removed. It was a transient source
  cleanup report containing code-refactor summaries, future split plans, and
  file-size inventory; those statements are not active project documentation.

## Statements Removed As Unverifiable Or Non-Current

- The previous docs-consolidation report's validation results and old change
  list were removed as current-pass evidence.
- The cleanup report's source-refactor summaries and future split plans were
  removed from `/docs`; they were not durable, code-grounded project docs.
- The architecture event-bus example that implied `emit_signal(...)` as the
  current project pattern was replaced with the typed `Signal.emit(...)`
  pattern used by the GDScript source.
- Generic wording that described `tests/run_tests.sh` as only a test runner was
  replaced with validation wording grounded in the script.
- The environment row for `VALIDATION_GODOT_VERSION` was removed because it is
  not consumed by current scripts or workflow steps.

## Intentional Gaps

- `BRAINDUMP.md` remains untouched because it is customer voice.
- Markdown under `.github/` remains in place because GitHub consumes issue and
  pull-request templates from that directory.
- The four `tests/**/README.md` ownership contracts remain outside `/docs`
  because `tests/validate_gut_config_discovery.sh` requires them at those
  paths. Moving them would require a validator/code change, which this docs-only
  pass explicitly does not perform.
- `addons/gut/LICENSE.md` remains in place because it is vendored third-party
  material.
- Markdown under `.aidlc/` and generated `artifacts/` remains outside the active
  documentation set because it is generated/tooling output, not hand-maintained
  project documentation.
- `artifacts/reports/scenario/runtime_audit/scenario-report.md` remains because
  it is generated runtime output from the audit-report pipeline.
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
  `tests/validate_ci_gate_partition.sh`,
  `scripts/validate_originality.sh`,
  `scripts/validate_translations.sh`,
  `scripts/validate_single_store_ui.sh`,
  `scripts/validate_tutorial_single_source.sh`,
  `tests/validate_store_session_naming.sh`,
  `game/scripts/core/boot.gd`, `game/autoload/automation_runner.gd`,
  `game/autoload/scenario_exit.gd`, `game/autoload/user_data_paths.gd`,
  `game/scripts/core/automation_artifacts.gd`,
  `game/autoload/data_loader.gd`, `game/autoload/content_registry.gd`,
  `game/autoload/game_manager.gd`, `game/autoload/scene_router.gd`,
  `game/scripts/scene_transition.gd`,
  `game/scripts/core/gameplay_shell.gd`,
  `game/scenes/world/game_world.gd`,
  `game/scripts/core/save_manager.gd`,
  `game/autoload/event_log.gd`, and
  `game/scripts/ui/ui_theme_constants.gd`.
- Markdown inventory checked across the repository. Remaining active
  hand-maintained docs are `README.md` and `/docs`; remaining markdown outside
  that boundary is customer voice, GitHub templates, vendored material,
  validator-required test ownership contracts, generated/tooling output, or
  runtime artifacts.
- Link validation over `README.md` and `docs/**/*.md`: passed.
- `bash tests/validate_gut_config_discovery.sh`: passed.
- `bash scripts/validate_export_config.sh`: passed.
- `git diff --check -- README.md docs`: passed.
- `bash tests/run_tests.sh`: passed. GUT reported `Scripts 420`,
  `Tests 4906`, `Passing 4906`; the configured shell validators and SSOT
  tripwires also passed.

## Escalations

None for the active `README.md` plus `/docs` documentation set.
