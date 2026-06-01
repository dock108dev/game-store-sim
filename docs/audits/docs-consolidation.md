# Documentation Consolidation Audit

Date: 2026-05-31

## Changed

### `docs/audits/abend-handling-audit.md`

- Rewrote the previous line-numbered finding table into a current handled-error
  contract snapshot.
- Removed stale recommendation/backlog language and historical aggregate counts
  that could not be treated as stable documentation after the current code
  changes.
- Kept only behavior that is directly grounded in current scripts, workflows,
  and GDScript owners.

### `docs/index.md`

- Replaced the vague Testing description's "coverage areas" wording with
  "test layout".
- Added the current Abend Handling Audit to the audit-note list.

### `docs/audits/docs-consolidation.md`

- Replaced the prior consolidation report with this current pass record.

## Deleted

- Deleted `docs/audits/cleanup-report.md`. It was a source-cleanup change log
  and future split list, not current project documentation. Keeping it under
  `/docs` conflicted with the rule that every maintained doc must describe
  current code/config/CI truth.

## Re-Verified Without Text Changes

- `README.md` against `project.godot`, `export_presets.cfg`, `game/content/`,
  `.github/workflows/export.yml`, and the checked-in GUT addon.
- `docs/setup.md` against `project.godot`, `scripts/godot_resolver.sh`,
  `scripts/godot_import.sh`, `scripts/godot_exec.sh`, `tests/run_tests.sh`,
  `.gutconfig.json`, and the current repository layout.
- `docs/architecture.md` against `project.godot`,
  `game/scripts/core/boot.gd`, `game/scenes/world/game_world.gd`, the autoload
  roster, and the scene entry files it names.
- `docs/architecture/ownership.md` against the current owner autoloads,
  signals, and validation scripts.
- `docs/content-data.md` against `game/content/`,
  `game/autoload/data_loader.gd`, `game/autoload/content_registry.gd`, and
  `game/resources/`.
- `docs/testing.md` against `tests/run_tests.sh`,
  `scripts/run_godot_tests.sh`, `.gutconfig.json`,
  `.gutconfig.pr-smoke.json`, `game/autoload/automation_runner.gd`,
  `game/autoload/scenario_exit.gd`, `tests/automation/scenarios/`, and the
  validation workflows.
- `docs/configuration-deployment.md` against `project.godot`,
  `export_presets.cfg`, scripts under `scripts/`, `tests/audit_run.sh`, and
  `.github/workflows/*.yml`.
- `docs/style/visual-grammar.md` against
  `game/scripts/ui/ui_theme_constants.gd`, `project.godot`, and the checked-in
  theme resources.
- `tests/automation/README.md`, `tests/baselines/README.md`,
  `tests/flows/README.md`, and `tests/visual/README.md` against
  `tests/validate_gut_config_discovery.sh` and their current directory roles.

## Statements Removed As Unverifiable Or Non-Current

- Removed the cleanup report's future split recommendations and line-count
  backlog.
- Removed abend-audit historical counts for `push_error`, `push_warning`,
  `gdlint:` directives, and sampled file totals.
- Removed abend-audit recommendations that were already implemented or that
  described future observability work instead of current behavior.
- Removed abend-audit line-numbered references that were too brittle for
  maintained documentation in the current dirty worktree.

## Intentional Gaps

- `BRAINDUMP.md` was left untouched because it is customer voice and the pass
  instructions explicitly forbid rewriting it.
- Markdown under `.github/`, `addons/`, `.aidlc`, and `artifacts/` was not
  moved into `/docs`; those files are GitHub templates, vendored material,
  generated/tool output, or platform tooling rather than active maintained game
  documentation.
- The four `tests/*/README.md` ownership markers remain outside `/docs`
  because `tests/validate_gut_config_discovery.sh` requires them.
- Non-Markdown code comments were not edited because this is a docs-only pass.

## Validation

- Markdown placement inventory: active maintained docs are `README.md` plus
  `docs/**/*.md`; the only root Markdown files are `README.md` and the
  preserved `BRAINDUMP.md`; test ownership README files remain for the
  validator.
- `bash tests/validate_gut_config_discovery.sh`: passed.
- `bash scripts/validate_export_config.sh`: passed.
- Active Markdown link check: passed.
- `git diff --check`: passed.

## Escalations

None.
