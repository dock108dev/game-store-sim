# Game Store Sim

An illustrated 2.5D early-2000s mall game shop, built in Godot. The active `encounter/` project implements R5: receive, price and allocate three fictional products across four shelf spaces, serve a three-customer wave, close, review per-product results, buy replenishment and advance to another day. The retail-v4 sample is the visual baseline; Kardboard Kings is the composition reference.

**R1–R4 are accepted within scope; R5 owner acceptance remains pending.** Retained R5 technical qualification is not full-game or release approval. See the [master plan](docs/MASTER_PLAN.md) and [R5 delivery record](docs/03-production/r5-delivery.md).

## Run and test

On macOS, install Godot 4.6.2 Standard at `/Applications/Godot.app`. From this repository's root:

```sh
zsh 'encounter/Launch Encounter.command'
```

Click stations/buttons; WASD/arrows walk; E follows the guided action; K saves; L reloads. Launch starts fresh; Reload restores the explicit checkpoint. See [play, saves and comparisons](encounter/README.md).

With Python 3 available, the default isolated headless check is:

```sh
python3 encounter/scripts/validate.py
```

It creates a disposable project and unique save namespace and retains timestamped evidence. It does not require Krita, ffmpeg or a package install. [Local development](docs/02-technical/local-development.md) documents prerequisites, configuration, side effects and optional rendered/capture checks.

## Engineering and status

- [Architecture and schema 5](docs/02-technical/encounter-architecture.md): source map, transaction flow, saves and repository boundaries.
- [Validation](docs/04-validation/local-validation-plan.md): current R5 checks versus historical prototype evidence.
- [Slices](docs/03-production/milestones-and-backlog.md) and [checklist](docs/03-production/visual-first-task-list.md): accepted scope and pending owner decision.
- [Source-of-truth policy](docs/05-reference/source-of-truth-policy.md): current direction versus retained history.

`game/`, root `scripts/`, old guides and sample build reports are historical; they are not the current R5 setup or release workflow. No active network service, database, CI workflow or encounter export pipeline is included.

Current source identity and maintenance checks are recorded in the [master plan](docs/MASTER_PLAN.md). Keep the linked Desktop tracker at `/Users/michaelfuscoletti/Desktop/game_sim_next_steps.md` synchronized with that plan.

## Shared UI design

See [UI design and templates](docs/ui-design.md) before changing this interface. The shared Desktop `UI Templates` folder defines the glass design baseline for future contributors; this repository keeps its own runtime styles and a portable copy of the requirements.
