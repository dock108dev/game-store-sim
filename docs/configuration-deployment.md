# Configuration and Deployment

## Project configuration

Key current settings in `project.godot`:

- application name: `Shelf Life` (internal-build label; external-facing
  product name `Mallcore Sim` lives in the export presets — see below)
- description: `Shelf Life — a small used-media store sim.`
- version: `0.1.0`
- main scene: `res://game/scenes/bootstrap/boot.tscn`
- project features: `4.6` with `Forward Plus`
- icon: `res://icon.svg`
- custom theme: `res://game/themes/game_theme.tres`
- translations: English and Spanish translation resources
- enabled editor plugin: `res://addons/gut/plugin.cfg`

The autoload list is documented in [Architecture](architecture.md).

## Input and runtime settings

`project.godot` currently defines action groups for:

- in-store movement (`move_forward`, `move_back`, `move_left`, `move_right`,
  `sprint`) and interaction (`interact`)
- shelf restocking shortcut (`quick_stock`)
- debug overlay (`toggle_debug`, F3) and the debug overhead/orbit camera
  toggle (`toggle_debug_camera`, F1)
- panel toggles for inventory, orders, staff, and pricing
  (`toggle_inventory`, `toggle_orders`, `toggle_staff`, `toggle_pricing`)
- build mode (`toggle_build_mode`) and fixture rotation (`rotate_fixture`)
- time speed (`time_speed_1`, `time_speed_2`, `time_speed_4`) and pause
  (`time_toggle_pause`)
- end-of-day close (`close_day`), pause menu (`pause_menu`), and overview
  toggle (`toggle_overview`)
- mall navigation zone shortcuts (`nav_zone_1` … `nav_zone_5`)

Use `project.godot` as the source of truth for exact bindings. The
`debug/walkable_mall` flag (default `false`) gates the optional walkable mall
hub variant; the shipping configuration is hub/card-based.

## User data and persistence

Runtime persistence uses Godot `user://` paths:

- settings: `user://settings.cfg` (owned by `Settings` autoload —
  `game/autoload/settings.gd`)
- tutorial progress: `user://tutorial_progress.cfg`
- save index: `user://save_index.cfg`
- saves: `user://save_slot_<n>.json`
- automation test runs: `user://test_runs/<run_id>/`

`UserDataPaths` (`game/autoload/user_data_paths.gd`) is the path resolver for
normal play and isolated automation runs. When an automation root is active,
settings, tutorial progress, the save index, save slots, and backups are routed
under `user://test_runs/<run_id>/`.

`SaveManager` (`game/scripts/core/save_manager.gd`) currently:

- supports one auto-save slot (slot `0`) plus three manual slots
  (`MAX_MANUAL_SLOTS = 3`)
- caps save-file reads at `10 MiB` (`MAX_SAVE_FILE_BYTES = 10485760`)
- writes save files atomically by writing to a `.tmp` companion file,
  flushing, closing, and renaming over the destination

## Checked-in integrations

The checked-in integrations documented in this repository are:

- Godot editor/runtime through `project.godot`
- GUT through `addons/gut/` and `.gutconfig.json`
- helper scripts in `scripts/` for Godot resolution/import/execution
  (`godot_resolver.sh`, `godot_import.sh`, `godot_exec.sh`,
  `setup_godot.sh`), artifact path resolution (`artifact_paths.sh`),
  test/export validation (`run_godot_tests.sh`,
  `run_fresh_install_smoke.sh`, `validate_resource_integrity.sh`,
  `validate_static_repo_guards.sh`, `validate_export_config.sh`), SSOT
  tripwires (`validate_translations.sh`, `validate_single_store_ui.sh`,
  `validate_tutorial_single_source.sh`), originality checks
  (`validate_originality.sh`), store-session naming checks
  (`tests/validate_store_session_naming.sh`), visual/video review
  (`run_store_visual_sweep.sh`, `render_nightly_videos.sh`), audit report
  generation (`generate_audit_scenario_report.py`,
  `audit_report_writers.py`), and advisory review report generation
  (`generate_advisory_review_report.gd`)
- GitHub Actions workflows for PR/main validation, weekly scenario review,
  weekly scenario-video rendering, release-candidate exports, and tagged
  release publishing
- `gdtoolkit` linting in CI

## Environment variables

| Name | Used by | Effect |
| --- | --- | --- |
| `GODOT` / `GODOT_EXECUTABLE` | local scripts and test runners | Selects the Godot editor binary before falling back to `godot` on `PATH` and common macOS install paths. |
| `GODOT_VERSION` | CI setup and visual sweep | Pins the Linux Godot install in validation/nightly workflows and names the default visual-baseline bucket. |
| `MALLCORE_ARTIFACT_DIR` | automation, tests, CI uploads | Overrides the repo-local `artifacts/` root. |
| `MALLCORE_SKIP_IMPORT` | resource/GUT wrappers | Skips duplicate import work after assets have already been imported. |
| `MALLCORE_VISUAL_BASELINE_DIR` | `scripts/run_store_visual_sweep.sh` | Overrides the default reviewed-PNG baseline directory. |
| `FPS` / `SCENARIO` | `scripts/render_nightly_videos.sh` | Sets Movie Maker FPS and optionally limits rendering to one scenario. |
| `PROJECT_ROOT` / `OUTPUT_ROOT` / `LOG_ROOT` / `SCENARIO_RUNNER` / `TIMEOUT_SECONDS` | `scripts/render_nightly_videos.sh` | Override the project path, output/log roots, Movie Maker runner scene, and per-scenario timeout. |
| `AUDIT_LOG` / `AUDIT_REQUIRED_FILE` / `AUDIT_METADATA_FILE` / `AUDIT_SCENARIO_ID` / `AUDIT_SCENARIO_SEED` / `AUDIT_KNOWN_FAIL_FILE` / `AUDIT_SKIP_RUN` | `tests/audit_run.sh` | Override audit inputs, scenario metadata, known-fail file selection, or skip the Godot run when gating an existing log. |

## Export presets

`export_presets.cfg` currently defines:

| Preset | Export path in preset | Notes |
| --- | --- | --- |
| `Windows Desktop` | `exports/windows/MallcoreSim.exe` | x86_64, embedded PCK, built-in code signing disabled. |
| `macOS` | `exports/macos/MallcoreSim.zip` | universal architecture, minimum macOS `10.15`, built-in code signing disabled. |
| `Linux/X11` | `exports/linux/MallcoreSim.x86_64` | Linux desktop preset, embedded PCK. |

All current presets exclude `.aidlc`, `docs`, `tests`, `game/tests`,
`addons/gut`, `game/addons/gut`, `.godot`, Markdown, text files, `.gitignore`,
and `.gutconfig.json` from export payloads.

## Local export

From the editor:

1. Open `project.godot`.
2. Confirm export templates are installed for your Godot version.
3. Open **Project -> Export**.
4. Select the target preset.
5. Export a release build.

For command-line export, import assets first with:

```bash
bash scripts/godot_import.sh
```

Then use Godot's `--export-release` with the preset name.

## GitHub Actions workflows

### PR validation workflow

`.github/workflows/validate.yml` is the PR and `main` push gate. It runs static
repo guards, GDScript linting, Godot resource/autoload integrity, the full GUT
suite through `scripts/run_godot_tests.sh`, and the fresh-install smoke.
Failure uploads use the repo-local artifact tree where those runners produce
logs, reports, screenshots, and manifests.

### Weekly scenario-review workflow

`.github/workflows/nightly.yml` is scheduled at `17 8 * * 1` UTC and can be
dispatched manually. It runs the interaction audit, soft visual snapshot
review, and the long-day soak lane. The visual snapshot lane is
`continue-on-error` so it remains advisory until baseline policy is
deliberately promoted.

### Weekly video workflow

`.github/workflows/nightly-videos.yml` runs on the `17 8 * * 1` UTC schedule
and by manual dispatch. It installs Godot `4.6.2-stable`, runs
`scripts/render_nightly_videos.sh` through `xvfb-run`, and uploads generated
scenario videos plus logs with 14-day retention.

### Export workflow

`.github/workflows/export.yml` runs on version tags matching `v*` and by manual
dispatch for release-candidate artifacts. Manual dispatch exports and uploads
candidate builds plus the playtest checklist but does not publish a GitHub
release. Tag pushes publish only after the validation, audit, export, and
playtest-manifest jobs pass.

The workflow currently:

1. validates the trigger and `export_presets.cfg` (version tag shape,
   preset names,
   Windows/macOS icon paths,
   x86_64 Windows, disabled built-in code signing, no absolute export paths,
   no local macOS paths, no hardcoded code-signing identity/password, no
   obvious secrets, ETC2 ASTC import support in `project.godot`)
2. runs static repo guards, GDScript lint, full GUT, fresh-install smoke, and
   interaction audit
3. installs Godot plus export templates via `chickensoft-games/setup-godot@v2`
4. imports project assets
5. exports Windows, macOS, and Linux release artifacts in parallel jobs
6. uploads release-candidate build artifacts and the generated playtest
   checklist
   (`mallcore-sim-{windows,macos,linux}.{zip,zip,tar.gz}`)
7. creates a GitHub release from tagged artifacts only on version tag pushes;
   manual workflow dispatch stops at uploaded release-candidate artifacts plus
   the playtest manifest

## Godot version

`project.godot` declares Godot `4.6` features. `validate.yml` installs
`4.6.2-stable`; `export.yml` passes `4.6.2` to
`chickensoft-games/setup-godot@v2`. Use Godot 4.6.2 locally for builds and
tests to match CI.
