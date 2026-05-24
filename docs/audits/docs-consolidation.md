# Documentation Consolidation Pass - 2026-05-23

## Changed

### `README.md`

- Tightened the root README to the required surface: repository identity,
  local run steps, test command pointer, deployment basics, and links into
  `docs/`.
- Removed the stale maintenance follow-up link.

### `docs/index.md`

- Removed the stale maintenance follow-up entry.
- Added the beta code-to-screen audit to the audit notes.

### `docs/content-data.md`

- Added `game/content/visuals/store_visual_layouts.json` to the documented
  content layout.
- Added `store_visual_layout_catalog` to the recognized `DataLoader` ignored
  route list.
- Documented store visual layout data as non-resource content.

### `docs/configuration-deployment.md`

- Expanded the export-workflow validation summary to include the icon-path,
  local macOS path, and code-signing password checks currently present in
  `.github/workflows/export.yml` and `scripts/validate_export_config.sh`.

### `docs/testing.md`

- Removed the process-advice section about when changes should include tests;
  it was policy guidance, not a statement owned by code/config.

## Deleted

- `docs/audits/cleanup-report.md` — untracked code-cleanup report. It
  documented source/test refactor work rather than active project
  documentation.
- `docs/maintenance/cleanup-follow-up.md` — stale LOC inventory and refactor
  recommendation list. It was drift-prone and duplicated information that can
  be regenerated from the current tree.
- The obsolete route-readiness audit was removed. The current route proof
  contract lives under store-session scripts and tests.

## Statements Removed As Unverifiable Or Non-Current

- The cleanup report's source-refactor summary and test-count claims.
- The cleanup follow-up's old large-file line counts and open-ended refactor
  recommendations.
- The obsolete beta audit's stale route proof and roadmap/build-decision
  recommendations.
- The testing doc's general advice about when changes should come with tests.

## Intentional Gaps

- Markdown under `.github/` remains in place because GitHub consumes the issue
  and pull-request templates from that location.
- Markdown under `addons/` remains in place because it is vendored GUT
  material.
- Markdown under `.aidlc/` remains in place because it is generated/tooling run
  output outside the active docs boundary.
- `BRAINDUMP.md` remains untouched because it is customer voice.
- Existing non-doc dirty-tree changes were left untouched because this was a
  docs-only consolidation pass.

## Validation

- Source of truth inspected: `project.godot`, `export_presets.cfg`,
  `.github/workflows/validate.yml`, `.github/workflows/export.yml`,
  `.gutconfig.json`, `tests/run_tests.sh`, `tests/audit_run.sh`,
  `scripts/godot_import.sh`, `scripts/godot_exec.sh`,
  `scripts/run_godot_tests.sh`, `scripts/validate_export_config.sh`,
  `game/scripts/core/boot.gd`, `game/autoload/data_loader.gd`,
  `game/autoload/content_registry.gd`, `game/autoload/game_manager.gd`,
  `game/scenes/world/game_world.gd`, `game/autoload/store_director.gd`,
  `game/autoload/scene_router.gd`, `game/autoload/input_focus.gd`,
  `game/autoload/modal_queue.gd`, `game/autoload/event_bus.gd`,
  `game/autoload/audit_log.gd`, `game/autoload/camera_authority.gd`,
  `game/scripts/core/save_manager.gd`,
  `game/scripts/ui/ui_theme_constants.gd`,
  `game/scripts/store_session/store_code_to_screen_proof_contract.gd`,
  `game/scripts/store_session/manual_day_one_route_capture.gd`,
  `game/scripts/store_session/store_session_controller.gd`,
  `game/scripts/store_session/register_screen_state.gd`,
  `game/scripts/store_session/store_carried_stock_marker.gd`, and
  `game/scripts/store_session/store_inventory_count_adapter.gd`.
- Markdown link check over `README.md` and `docs/**/*.md`: passed
  (`Markdown links OK`).
- `bash scripts/validate_export_config.sh`: passed
  (`Export config validation: OK`).
- `git diff --check -- README.md docs`: passed.
- `bash tests/run_tests.sh`: passed. GUT reported `Scripts 387`,
  `Tests 4644`, `Passing 4644`; the configured shell validators also passed.

## Escalations

None for the active `README.md` plus `docs/` documentation set.
