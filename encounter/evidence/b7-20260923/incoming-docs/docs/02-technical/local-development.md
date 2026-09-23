# Local development — B6 encounter

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

`encounter/project.godot` defines a 1280×720 logical viewport with 2560×1440 window overrides, canvas-item stretch, HiDPI and `gl_compatibility`. There is no runtime environment-variable configuration. Product costs/reference prices, customer roster and willingness remain in `state.gd`; capacity and geometry derive from `layout.gd`.

The project uses a custom Godot user directory. On macOS ordinary Save writes `~/Library/Application Support/game-sim-first-week-dev-v10/encounter.json`; launching alone does not load or overwrite that checkpoint. K/Save and L/Reload remain explicit; settlement, advance and expansion autosave. Failed saves expose Retry save without replaying the transaction. Terminal restart first preserves a per-run result. Despite its name, this is a persistent development namespace, not a new disposable directory per launch. For development tests use the isolated validator below.

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

The runner uses a temporary `game-sim-b6-*` project and unique save namespace. It imports assets, runs the B6 authored-week state suite, the B2–B5 shared-invariant regression suite, pending-price requests, then integrated-week and base-shop breadth scene checks. It retains context hashes (including uncommitted source), logs, process exits, results and generated media in a fresh `encounter/evidence/validation-<timestamp>/` directory. It fails closed before engine launch if the expected v10 custom namespace is missing, duplicated or disabled; old namespaces including v9 are rejected. It never reads owner saves.

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

`--render` adds normal and Retina full-week/breadth scene runs, screenshots and interaction videos; it requires a graphical session and `ffmpeg`. `--capture` selects the same B6 rendered scenarios. Tests use `--audio-driver Dummy`: muted checks do not qualify sound. Full-week controls use viewport input plus ordinary field/dropdown signals and paused save/resume boundaries. The separate breadth scenario explicitly records its empty-day state setup. Neither is owner play, B8 balance exploration or B10 acceptance.

`capture_full_shift.py` is a separate historical capture tool: it copies Godot into a temporary app, changes its bundle metadata and runs ad-hoc `codesign`, then uses `ffmpeg` and `ffprobe`. It now uses the same fail-closed `isolate_project` helper as the validator; its signed-app capture path was not run for B6. It is not a basic test or setup requirement; do not invoke it as a routine docs check. Root `scripts/validate_local.sh` and `scripts/export_macos.sh` target the historical `game/` project; follow the [disposable baseline procedure](../04-validation/local-validation-plan.md) for any intentional reproduction.

## Artwork and operations

`encounter/source/` holds editable Krita masters; `art/` holds runtime exports, rigs and import sidecars. The rebuild launchers require `/Applications/krita.app/Contents/MacOS/kritarunner`, with Krita's Python/PyQt5 modules. They install a runner module under `~/Library/Application Support/kritarunner/pykrita` and overwrite their named masters, exports and roundtrip evidence. `Rebuild Assortment Art.command` targets Tide/Orbit; `Rebuild Art.command` targets the original case/fixtures and reads the retained retail-v4 shelf master. Preserve existing sources/evidence before intentional rebuild work. These are not plain system-Python scripts.

There is no deployed server, scheduled task, account integration or operational service to start/stop. Quit the Godot window to stop local play; explicitly save first if the checkpoint is wanted. There is no R5 export/release workflow in this checkout. Cross-platform execution, distributable packaging and crash recovery have not been established by this documentation pass.


## B4 employees

Morgan and Jules are available from day-3 preparation via **Employees**. Confirm **Hire · $12 today**, then choose Unassigned, Stocking or Checkout. Hiring owes that day's $12 even if dismissed immediately. Existing staff owe a new day's wage when Open is confirmed; dismiss during preparation before opening to avoid it. Reassignment and idle time never cancel an existing commitment. Opening with unassigned staff displays a warning.

Stocking uses one priced backroom copy and a free shelf slot in prep/open. Workers walk through receiving and then the rack before committing. Checkout claims the settled FIFO head and cashier, then walks/reaches before selling. Keep aisles and work ports clear; Rowan blocks workers just as other bodies do. **Stock** keeps player stocking available while open. **Employees → Take over** transfers unfinished work to Rowan, who must travel normally. A completed sale cannot be reversed.

Arrangement pauses workers and releases unfinished jobs. Closing releases unfinished stock jobs and starts no new ones; checkout staff keep draining. Reload preserves employment, wage commitments, inventory and buyer reservations, cancels saved unfinished execution claims and rebuilds routes from legal separated spawns. Finances and Daily closes include actual wages, paid overhead and full unpaid wage/rent liabilities. Technical evidence, source identity and limitations are in [B4 delivery](../03-production/b4-delivery.md).

B5's state/scene suites and evidence remain historical. B6 replaces their interim content assertions with `test_week.gd`, `test_week_regressions.gd`, `test_week_scene.gd` and `test_breadth_scene.gd`, retaining pending-price verification. Consult [B6 delivery](../03-production/b6-delivery.md) for the selected current checks, failure investigations and exact evidence. Stop before B7.
