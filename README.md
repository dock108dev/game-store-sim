# Replay Junction

An illustrated Godot game about the first week running a mall game shop: stock and price games, hire staff, buy used copies, expand displays and pay bills across seven days.

## Play from source

Use Godot **4.6.2 Standard**. On macOS, with Godot installed at `/Applications/Godot.app`, run from the repository root:

```sh
zsh 'encounter/Launch Encounter.command'
```

Alternatively, import `encounter/project.godot` in Godot. `encounter/` is the active game; `game/` and the root scripts contain earlier prototypes.

See [controls and saves](encounter/README.md), [local development](docs/02-technical/local-development.md), and [Mac build instructions](encounter/MAC-BUILD.md). App bundles are not included in a fresh clone. The game currently has no sound content.

## Validate

Requires Python 3 and the installed Godot engine:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s encounter/scripts -p 'test_*.py' -v
python3 encounter/scripts/validate.py --ci
```

The validator uses isolated synthetic saves. See [local development](docs/02-technical/local-development.md#validation) for the larger check set, engine overrides and output locations.

## Development guides

- [Architecture](docs/02-technical/encounter-architecture.md) and [module ownership](docs/02-technical/ssot.md)
- [Save recovery](docs/02-technical/error-handling.md) and [security](docs/02-technical/security.md)
- [UI design](docs/ui-design.md)

Source assets are versioned. Generated app bundles, videos, raw frame sequences and import caches stay local.
