# Local development — R5 encounter

## Requirements and launch

Use macOS with Godot **4.6.2 Standard** (GDScript, Compatibility renderer). The launchers and Python validation tools expect `/Applications/Godot.app/Contents/MacOS/Godot`. Python 3 is needed for validation; its default runner uses only the standard library. No package install, `.env`, credentials, database or service is required. Existing PNG assets are sufficient for play; Krita is only needed to rebuild artwork.

From the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
python3 --version
zsh 'encounter/Launch Encounter.command'
```

Or import `encounter/project.godot` in Godot. For an engine installed elsewhere, launch directly with its executable and `--path /absolute/path/to/game-sim/encounter`. Current encounter wrappers and validation scripts have no `GODOT_BIN` environment override. The root historical scripts support that variable, but target `game/`.

See [play and controls](../../encounter/README.md). Launch starts a new in-memory shift; explicit Reload restores the saved checkpoint. Running a project imports assets and can create/update `.godot` caches. Do not mistake those generated files for source changes.

## Configuration and local state

`encounter/project.godot` defines a 1280×720 logical viewport with 2560×1440 window overrides, canvas-item stretch, HiDPI and `gl_compatibility`. There is no runtime environment-variable configuration. Product costs/reference prices, capacity, customer roster and willingness are constants in `state.gd`.

The project uses a custom Godot user directory. On macOS ordinary Save writes `~/Library/Application Support/game-sim-r5-review-isolated/encounter.json`; launching alone does not load or overwrite that checkpoint. K/Save and L/Reload are explicit. Despite its name, this is a persistent shared review namespace, not a new disposable directory per launch. For development tests use the isolated validator below.

User arguments follow Godot's `--` separator:

| Argument | Effect |
| --- | --- |
| `--assortment-demo=stocked` or `missing` | Prepares the deterministic day-2 comparison; uses `assortment-<mode>.json` in the project namespace. `Compare Assortments.command` prompts for a valid mode. |
| `--pricing-demo=low`, `reference` or `high` | Retained R3/R4 comparison adapter and separate `pricing-demo-<name>.json`; not the R5 comparison gate. |
| `--capture` | Automated scene actions and frame/trace writes under project `evidence/frames`; uses a separate capture checkpoint. Use the isolated validation wrapper for capture. |

Use one comparison mode at a time. These are manual development/review workflows, not automatic background jobs.

## Validation

From the repository root:

```sh
python3 encounter/scripts/validate.py
```

This is the default headless R5 gate. It copies `encounter/` to a unique temporary directory, excluding `.godot`, `evidence` and Python caches, replaces the review save namespace with a unique one, imports assets and runs the three current suites. It writes source hashes/engine version, logs, exit files and results to a new `encounter/evidence/validation-<UTC timestamp>/` directory. The original save namespace is not used. Temporary projects, isolated user directories and evidence are retained, not automatically cleaned up. If the expected custom save-directory settings are missing or changed, the runner stops before invoking Godot.

The wrapper rejects nonzero exits, `SCRIPT ERROR:` and lines beginning with `ERROR:` (including the first line); it does not reject all warnings. Inspect logs for warnings separately. A failed run can leave partial evidence. The historical passing counts are 110 state checks, 3 pending-label checks and 54 scene checks; see [validation scope and evidence](../04-validation/local-validation-plan.md). Source changes need a new applicable check, not an inherited pass.

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

`--render` adds normal and Retina scene runs and screenshots, requiring a graphical session. `--capture` records gameplay and both comparisons and requires `ffmpeg` on PATH with libx264. It retains thousands of temporary frames and checks frame counts, changing frames and comparison report outcomes. Capture uses action adapters and is not owner input or acceptance. Do not run it for ordinary documentation changes.

`capture_full_shift.py` is a separate historical capture tool: it copies Godot into a temporary app, changes its bundle metadata and runs ad-hoc `codesign`, then uses `ffmpeg` and `ffprobe`. It is not a basic test or setup requirement; do not invoke it as a routine docs check. Root `scripts/validate_local.sh` and `scripts/export_macos.sh` target the historical `game/` project; follow the [disposable baseline procedure](../04-validation/local-validation-plan.md) for any intentional reproduction.

## Artwork and operations

`encounter/source/` holds editable Krita masters; `art/` holds runtime exports, rigs and import sidecars. The rebuild launchers require `/Applications/krita.app/Contents/MacOS/kritarunner`, with Krita's Python/PyQt5 modules. They install a runner module under `~/Library/Application Support/kritarunner/pykrita` and overwrite their named masters, exports and roundtrip evidence. `Rebuild Assortment Art.command` targets Tide/Orbit; `Rebuild Art.command` targets the original case/fixtures and reads the retained retail-v4 shelf master. Preserve existing sources/evidence before intentional rebuild work. These are not plain system-Python scripts.

There is no deployed server, scheduled task, account integration or operational service to start/stop. Quit the Godot window to stop local play; explicitly save first if the checkpoint is wanted. There is no R5 export/release workflow in this checkout. Cross-platform execution, distributable packaging and crash recovery have not been established by this documentation pass.
