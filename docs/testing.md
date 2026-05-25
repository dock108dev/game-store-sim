# Testing

The project uses the checked-in GUT addon plus a set of shell validators under
`tests/`.

## Main test command

```bash
bash tests/run_tests.sh
```

`tests/run_tests.sh` currently does the following:

1. Runs `scripts/validate_static_repo_guards.sh`.
2. Resolves Godot from `GODOT`, `GODOT_EXECUTABLE`, `godot` on `PATH`, or common
   macOS install paths.
3. Runs a headless import.
4. Runs `scripts/validate_resource_integrity.sh` when Godot is available.
5. Seeds the GUT editor environment through `res://tests/setup_gut_env.gd`.
6. Runs GUT with `res://addons/gut/gut_cmdln.gd`.
7. Runs `res://game/tests/run_tests.gd` when that file exists.
8. Writes the combined GUT output stream to
   `artifacts/logs/gut/test_run.log`.
9. Runs maintained shell validators under `tests/`. Archived one-off
   acceptance scripts can still be run directly, but are not part of the
   default regression gate.
10. Runs the SSOT tripwires under `scripts/`
   (`validate_translations.sh`, `validate_single_store_ui.sh`,
   `validate_tutorial_single_source.sh`) when present and executable.

The artifact root resolves from `MALLCORE_ARTIFACT_DIR`, then
`$GITHUB_WORKSPACE/artifacts` in CI, then the repository's `artifacts/`
directory. Godot-only automation falls back to `user://artifacts` only when no
repo root can be resolved.

Stable automation artifact subpaths:

| Output | Path |
| --- | --- |
| GUT logs | `artifacts/logs/gut/` |
| static validator logs | `artifacts/logs/static-validation/` |
| scenario logs | `artifacts/logs/scenario/` |
| scenario screenshots | `artifacts/screenshots/scenario/<scenario>/` |
| visual sweep screenshots | `artifacts/screenshots/visual_sweep/<suite>/` |
| gallery screenshots | `artifacts/screenshots/gallery/<gallery>/` |
| scenario reports | `artifacts/reports/scenario/<scenario>/` |
| visual sweep reports | `artifacts/reports/visual_sweep/<suite>/` |
| visual sweep current captures / diffs | `artifacts/visual_sweep/<suite>/` |
| JUnit XML | `artifacts/junit/` |
| scenario videos | `artifacts/videos/scenario/` |
| aggregate manifest | `artifacts/manifests/artifact_manifest.json` |

Manual F10/debug screenshots remain under `user://screenshots`.

If no Godot binary can be resolved and neither `GODOT` nor `GODOT_EXECUTABLE`
is set, the Godot-backed import, resource-integrity, and GUT steps are skipped;
static repo guards, maintained shell validators, and tripwires still run. If
either env var is set but does not point at an executable binary, the runner
exits with an error.

## GUT configuration

`.gutconfig.json` currently points GUT at the full local/CI regression suite:

- `res://tests/`
- `res://tests/gut/`
- `res://tests/unit/`
- `res://tests/flows/`
- `res://tests/visual/`
- `res://game/tests/`

`.gutconfig.pr-smoke.json` is the smaller pull-request smoke layout. It uses
explicit `tests` entries for high-signal boot, content, store-session, save,
HUD, and UI smoke coverage.

The current config also uses:

- `prefix: "test_"`
- `suffix: ".gd"`
- `should_exit: true`
- `should_exit_on_success: true`
- `pre_run_script: "res://tests/automation/gut_pre_run.gd"`
- `post_run_script: "res://tests/automation/gut_post_run.gd"` in the full
  `.gutconfig.json`

## Test layout

```text
tests/automation/  Runners, GUT hooks, scenario helpers, validators, CI helpers
tests/unit/        Isolated script/resource tests
tests/integration/ Multi-system tests with controlled fixtures; migrate into
                   full discovery only as files are stabilized
tests/flows/       End-to-end player and store-session route tests
tests/visual/      UI, layout, readability, screenshot, visual-state tests,
                   and store visual sweep baselines
tests/baselines/   Golden fixtures and expected outputs shared across tests;
                   no executable tests
tests/gut/         Legacy broad gameplay and scene-oriented GUT coverage
game/tests/        Runtime-adjacent game tests included in .gutconfig
tests/validate_*.sh Shell validators for structure and targeted checks
```

`tests/setup_gut_env.gd` and `tests/run_tests.sh` remain compatibility entry
points around the automation tree.
`tests/validate_gut_config_discovery.sh` verifies that the full and PR-smoke
GUT configs do not double-discover the same script.

## Automation CLI

Automation mode is owned by `AutomationRunner` and requires `--test-mode`.
Supported scenario IDs are `bad_state_resistance`,
`economy_loop_seed_001`, `fresh_install_smoke`, `layout_torture`,
`long_day_soak`, `save_reload_smoke`, `smoke`, and `tutorial_full`.

Supported user flags:

| Flag | Effect |
| --- | --- |
| `--scenario=<id>` | Selects a supported scenario; defaults to `fresh_install_smoke`. |
| `--seed=<value>` | Enables deterministic test-mode random streams with that seed. |
| `--fresh-save[=<id>]` | Routes persistence under `user://test_runs/<id>/`; an omitted id is derived from scenario and seed. |
| `--record-screenshots` | Enables scenario screenshot capture where the runner supports it. |
| `--record-video` | Parsed but rejected for standard automation; video capture is handled by the Movie Maker runner. |
| `--exit-on-complete` | Quits through `ScenarioExit` after the scenario completes. |
| `--speed=1x|2x|3x|4x|6x` | Applies an automation speed tier; `2x` clamps to `3x`, and `4x` clamps to `6x`. |

## Current coverage areas

The checked-in tests currently cover:

- boot flow, content loading, and content registry rules
- time, economy, difficulty, checkout, haggling, pricing, and reporting
- inventory, ordering, suppliers, stock, and save/load behavior
- store state, store transitions, hallway/storefront flow, and build mode
- customer spawning, NPC systems, queueing, and purchase flow
- milestones, unlocks, upgrades, completion, onboarding, and endings
- retro-games store mechanics (testing station, refurbishment queue,
  hold-shelf flow, manifest/poster/featured-display interactables) plus the
  store-session Day 1 critical-path smoke
- settings, audio, camera, environment, tooltips, and UI panels

## Automation scenario exit codes

`ScenarioExit` owns process status for automation scenarios and is inert unless
an automation runner arms it. Scenario logs use stable `SCENARIO: PASS`,
`SCENARIO: FAIL`, and `SCENARIO: EXIT` lines.

| Code | Meaning |
| --- | --- |
| `0` | success |
| `10` | boot/content validation failure |
| `11` | scenario assertion/checkpoint failure |
| `12` | required audit checkpoint missing |
| `13` | unexpected runtime error or `push_error` gate |
| `14` | scenario timeout |
| `15` | scenario runner misuse or configuration error |
| `20` | save/load scenario failure |
| `21` | economy/session scenario failure |
| `22` | UI interaction scenario failure |
| `70` | internal scenario runner exception |

## CI validation

`.github/workflows/validate.yml` is the fast PR gate. It runs static repo
guards, `gdlint`, Godot resource/autoload integrity, and the explicit
`.gutconfig.pr-smoke.json` GUT smoke set.

`.github/workflows/nightly.yml` is the full validation gate. It runs the same
static/lint surface plus full GUT, fresh-install smoke, interaction audit, the
soft visual snapshot sweep, and the long-day soak scenario. Visual snapshot
review is advisory until baselines are intentionally promoted.

`scripts/run_store_visual_sweep.sh` reads reviewed PNG baselines from
`tests/visual/baselines/retro_games_day_one/<godot-version>/linux/` by default
or from `MALLCORE_VISUAL_BASELINE_DIR` when set. If the baseline bucket is
absent, the diff step writes current captures and reports missing baselines
without failing because the nightly visual lane is advisory.

`.github/workflows/nightly-videos.yml` is the scheduled/manual video lane. It
renders Movie Maker scenario videos and uploads video/log artifacts from
`artifacts/videos/scenario/nightly/` and
`artifacts/logs/scenario/nightly-videos/`.

Tagged and manual release-candidate exports are handled by
`.github/workflows/export.yml`, which runs release validation, exports Windows,
macOS, and Linux artifacts, uploads a playtest checklist, and publishes only on
version tag pushes.
