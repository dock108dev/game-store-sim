# Documentation Consolidation Pass - 2026-05-21

## Changed

### `docs/architecture/ownership.md`

- Corrected the input-focus row so it matches current code: `ModalQueue`
  coordinates queued `ModalPanel` instances, while direct-open panel scripts
  still pair their own `InputFocus.push_context(CTX_MODAL)` /
  `pop_context()` calls.
- Corrected the audit-log row so `AuditLog` is the only structured audit
  checkpoint owner and `tests/audit_run.sh` accepts only `AUDIT: PASS/FAIL`
  lines.
- Reworded the cross-system eventing row from an overbroad "sole permitted
  route" claim to the current owner/mirror model: `EventBus` is the typed
  gameplay signal hub, while owner autoload APIs still handle command-style
  operations.

### `docs/audits/docs-consolidation.md`

- Replaced the stale 2026-05-20 report with this pass record.
- Removed unrelated code-cleanup pass content that had been appended to the
  documentation consolidation report.

## Deleted

- `docs/audits/cleanup-report.md` — an untracked code-cleanup pass record.
  It documented source/test changes, not active project documentation, and
  duplicated content that had also been appended into
  `docs/audits/docs-consolidation.md`.

## Statements Removed As Unverifiable Or Non-Current

- The claim that all modal panels route through `ModalQueue` rather than
  directly pushing `CTX_MODAL`.
- Legacy `[AUDIT]` / `AuditOverlay` checkpoint compatibility in the audit
  runner.
- The claim that `EventBus` is the sole permitted cross-system route and that
  all direct owner/autoload lookups are forbidden.
- The prior appended cleanup-report content about source-code refactors and
  file-size inventory; that material is outside this docs-only pass.

## Intentional Gaps

- Markdown under `.github/` remains in place because GitHub consumes the issue
  and pull-request templates from that location.
- Markdown under `addons/` remains in place because it is vendored GUT
  material.
- Markdown under `.aidlc/` remains in place because it is generated/tooling
  run output outside the active docs boundary.
- Existing non-doc dirty-tree changes were left untouched because this was a
  docs-only consolidation pass.

## Validation

- Source of truth inspected: `project.godot`, `export_presets.cfg`,
  `.github/workflows/validate.yml`, `.github/workflows/export.yml`,
  `.gutconfig.json`, `tests/run_tests.sh`, `tests/audit_run.sh`,
  `scripts/godot_import.sh`, `scripts/godot_exec.sh`,
  `scripts/run_godot_tests.sh`, `scripts/validate_export_config.sh`,
  `scripts/validate_originality.sh`, `scripts/validate_translations.sh`,
  `scripts/validate_single_store_ui.sh`,
  `scripts/validate_tutorial_single_source.sh`,
  `game/scripts/core/boot.gd`, `game/autoload/data_loader.gd`,
  `game/autoload/content_registry.gd`, `game/autoload/game_manager.gd`,
  `game/scenes/world/game_world.gd`, `game/autoload/store_director.gd`,
  `game/autoload/scene_router.gd`, `game/autoload/input_focus.gd`,
  `game/autoload/modal_queue.gd`, `game/autoload/event_bus.gd`,
  `game/autoload/audit_log.gd`, `game/autoload/audit_overlay.gd`,
  `game/autoload/beta_hud.gd`, `game/autoload/event_log.gd`,
  `game/scripts/core/save_manager.gd`,
  `game/scripts/player/interaction_ray.gd`,
  `game/scripts/ui/objective_rail.gd`, `game/scenes/ui/hud.gd`,
  `game/scripts/beta/beta_right_panel.gd`,
  `game/scripts/beta/beta_event_log_panel.gd`,
  `game/scripts/ui/ui_theme_constants.gd`, and
  `game/content/visuals/retro_games_product_visual_catalog.json`.
- Markdown link check over `README.md` and `docs/**/*.md`: passed
  (`Markdown links OK`).
- `bash scripts/validate_export_config.sh`: passed
  (`Export config validation: OK`).
- `git diff --check -- README.md docs`: passed.
- `bash tests/run_tests.sh`: passed. GUT reported `Scripts 380`,
  `Tests 4593`, `Passing 4593`; the configured shell validators also passed.

## Escalations

None for the active `README.md` plus `docs/` documentation set.
