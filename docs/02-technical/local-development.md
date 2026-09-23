# Local development — current encounter source

## Requirements and launch

Use macOS with Godot **4.6.2 Standard** (GDScript, Compatibility renderer). The launchers and Python validation tools expect `/Applications/Godot.app/Contents/MacOS/Godot`. Python 3 is needed for validation; its default runner uses only the standard library. No package install, `.env`, credentials, database or service is required. Existing PNG assets are sufficient for play; Krita is only needed to rebuild artwork.

From the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
python3 --version
zsh 'encounter/Launch Encounter.command'
```

Or import `encounter/project.godot` in Godot. For an engine installed elsewhere, launch directly with its executable and `--path /absolute/path/to/game-sim/encounter`. The validator accepts `--engine /absolute/path/to/Godot`; it has no `GODOT_BIN` environment override. The root historical scripts support that variable, but target `game/`.

See [play and controls](../../encounter/README.md). Launch offers New week or Continue from the last successful checkpoint. Running a project imports assets and can create/update `.godot` caches. Do not mistake those generated files for source changes.

## Configuration and local state

`encounter/project.godot` defines a 1280×720 logical viewport with 2560×1440 window overrides, canvas-item stretch, HiDPI and `gl_compatibility`. There is no runtime environment-variable configuration. Product costs/reference prices, customer roster and budgets come from `week_content.gd`, exposed through `state.gd`; capacity and geometry derive from `layout.gd`.

The project uses a custom Godot user directory. On macOS ordinary Save writes `~/Library/Application Support/game-sim-first-week-dev-v10/encounter.json`; launching alone does not load or overwrite that checkpoint. K/Save and L/Reload remain explicit; settlement, advance and expansion autosave. Failed saves expose Retry save without replaying the transaction. Terminal restart first preserves a per-run result. Despite its name, this is a persistent development namespace, not a new disposable directory per launch. A separate Git checkout does not isolate this development save directory: ordinary launches from different checkouts share it. For development tests use the isolated validator below.

User arguments follow Godot's `--` separator:

| Argument | Effect |
| --- | --- |
| `--assortment-demo=stocked` or `missing` | Prepares the deterministic day-2 comparison; uses `assortment-<mode>.json` in the project namespace. `Compare Assortments.command` prompts for a valid mode. |
| `--capture` | Automated scene actions and frame/trace writes under project `evidence/frames`; uses a separate capture checkpoint. Use the isolated validation wrapper for capture. |

Use one comparison mode at a time. These are manual development/review workflows, not automatic background jobs.

## Validation

For ordinary source changes, run the basic headless selection from the repository root:

```sh
python3 encounter/scripts/validate.py --ci
```

The runner uses a temporary `game-sim-b6-*` project and unique save namespace. The basic selection imports assets and runs week state/shared regressions, SSOT/security/storage, pending-price, presentation and restart checks. Without `--ci`, the larger selection also runs native exit/relaunch and integrated-week/base-shop breadth scenes; it requires a graphical session for native exit checks. It retains context hashes (including uncommitted source), logs, process exits, results and generated media in a fresh `encounter/evidence/validation-<timestamp>/` directory. It fails closed before engine launch if the expected v10 custom namespace is missing, duplicated or disabled; old namespaces including v9 are rejected. It never reads owner saves.

The wrapper rejects nonzero exits, `SCRIPT ERROR:` and lines beginning with `ERROR:` (including the first line); it does not reject all warnings. Inspect logs for warnings separately. A failed run can leave partial evidence. See [current CI scope and evidence](../04-validation/ci-readiness.md) for the basic selection and [validation history](../04-validation/local-validation-plan.md) for older results. Source changes need a new applicable check, not an inherited pass.

For changes to the Python runner itself, run its focused standard-library tests:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s encounter/scripts -p test_validation_runner.py -v
```

These use temporary synthetic projects and mocked engine output to check isolation and failure reporting; they do not launch Godot.

Optional, more expensive checks:

```sh
python3 encounter/scripts/validate.py --render
python3 encounter/scripts/validate.py --render --capture
```

`--render` adds normal and Retina full-week/breadth scene runs, screenshots and interaction videos; it requires a graphical session and `ffmpeg`. `--capture` selects the same B6 rendered scenarios. Tests use `--audio-driver Dummy`: muted checks do not qualify sound. Full-week controls use viewport input plus ordinary field/dropdown signals and paused save/resume boundaries. The separate breadth scenario explicitly records its empty-day state setup. Neither is owner play, B8 balance exploration or B10 acceptance.

`capture_full_shift.py` is a separate historical capture tool: it copies Godot into a temporary app, changes its bundle metadata and runs ad-hoc `codesign`, then uses `ffmpeg` and `ffprobe`. It now uses the same fail-closed `isolate_project` helper as the validator; its signed-app capture path was not run for B6. It is not a basic test or setup requirement; do not invoke it as a routine docs check. Root `scripts/validate_local.sh` and `scripts/export_macos.sh` target the historical `game/` project; follow the [disposable baseline procedure](../04-validation/local-validation-plan.md) for any intentional reproduction.

## Artwork and operations

`encounter/source/` holds editable Krita masters; `art/` holds runtime exports, rigs and import sidecars. The rebuild launchers require `/Applications/krita.app/Contents/MacOS/kritarunner`, with Krita's Python/PyQt5 modules. They install a runner module under `~/Library/Application Support/kritarunner/pykrita` and overwrite their named masters, exports and roundtrip evidence. `Rebuild Assortment Art.command` targets Tide/Orbit; `Rebuild Art.command` targets the original case/fixtures and reads the retained retail-v4 shelf master. Preserve existing sources/evidence before intentional rebuild work. These are not plain system-Python scripts.

There is no deployed server, scheduled task, account integration or operational service to start/stop. Quit the Godot window to stop local play; explicitly save first if the checkpoint is wanted. The current personal export is documented in the B9 section below. Public distribution and power-loss recovery remain unqualified.


## Gameplay and retained slice tests

Employee controls, used trading and daily reports are documented in the [player guide](../../encounter/README.md). State ownership and physical job rules are documented in [architecture](encounter-architecture.md); this setup guide does not duplicate those rules.

B5's state/scene suites and evidence remain historical. B6 replaces their interim content assertions with `test_week.gd`, `test_week_regressions.gd`, `test_week_scene.gd` and `test_breadth_scene.gd`, retaining pending-price verification. Consult [B6 delivery](../03-production/b6-delivery.md) for the selected current checks, failure investigations and exact evidence.

## B7 session verification

The isolated validator includes presentation recovery at normal/Retina sizes, guarded reload, save retry, mid-day process quit/relaunch and terminal restart probes in addition to the current B6 suites. It never launches against the owner namespace. `active-week.txt` is a presentation locator for separately created `week-*.json` files, not a schema change. See [B7 delivery](../03-production/b7-delivery.md).

### B8 isolated balance evaluation

`python3 encounter/scripts/evaluate_balance.py --screen` screens eight policies. `--strategy lean --mode normal --pace` demonstrates a complete manual week with normal-speed days 1 and 6; `--strategy recovery --mode retina` demonstrates the pricing setback and surviving finish. Supported scene strategies also include `growth`, `one_worker` and `bankruptcy`. Each run retains exact source/parameters, unique copied-project namespace, logs, snapshots, action/queue telemetry and screenshots; pacing runs encode timestamped sampled clips. See [B8 delivery](../03-production/b8-delivery.md) for the final evidence and failed attempt. No runtime parameters changed. The controller's ordinary keyboard aisle correction is explicit; it is not an automatic navigation repair. That B8 record predates B9 package qualification; current B10 owner judgment remains pending.

## B9 personal Mac delivery

The encounter-specific [export preset](../../encounter/export_presets.cfg) and [build instructions](../../encounter/MAC-BUILD.md) produce the local personal app. Feature `personal_beta` overrides only the app name and save namespace to `game-sim-personal-beta-v10`; development remains v10 in its own namespace. No schema or business migration occurs. B9’s [delivery](../03-production/b9-delivery.md) distinguishes the frozen release app, source launches and instrumented package probes, including actual local security/audio behavior.

## September 23 error-handling maintenance

See [error handling and recovery](error-handling.md) for storage diagnostics, locator partial-success behavior, timeout/interruption records and focused source validation. The default validator now includes `test_storage.gd`; its expected failure diagnostics are checked by assertions. This separate source checkout does not replace the B9 app in the ongoing B10 review.

## Security boundaries

The personal export ignores development fixture/capture arguments. Development accepts only the documented mode names. Checkpoints are capped at 8 MiB, locator reads at 256 bytes, and the pacing encoder requires numeric PNG basenames within its own evidence folder. See [security findings, tests and roadmap](security.md). The new limits preserve rejected originals; do not truncate owner data to force a load.

## Authoritative paths

See [SSOT ownership and removals](ssot.md). The retired pricing comparison launcher has been removed; `--pricing-demo=...` fails explicitly in development. Use ordinary product labels with `week_content.gd` catalog references. Historical evidence is preserved, but does not make retired modes supported. Assortment comparison and capture remain explicit development workflows; the personal export disables them.

## Basic CI selection

Run `python3 encounter/scripts/validate.py --ci` for import and focused headless regressions only. It requires the qualified Godot 4.6.2 build and excludes native exit/relaunch, full-week scenes and captures. `--output /new/evidence/directory` retains results at an explicit new location. The default command retains its larger selection. See [GitHub CI](../04-validation/ci-readiness.md) for exact checks, installation and hosted status.
