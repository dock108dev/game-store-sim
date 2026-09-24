# Game Store Sim

Replay Junction is an illustrated Godot game about the first week running a mall game shop: stock and price games, hire staff, buy used copies, expand displays and pay bills across seven days.

A personal Mac build has completed its recorded technical checks; owner review is in progress and beta acceptance is pending. Current source includes maintenance changes that are not in that frozen app. See the [delivered build identity](docs/03-production/b9-delivery.md) and [owner-review record](docs/03-production/b10-owner-review.md).

## Play or develop

The local [personal Mac app](docs/03-production/b9-delivery.md) uses its own save namespace. See the [prepared owner guide](encounter/MAC-OWNER-GUIDE.md) and [build instructions](encounter/MAC-BUILD.md). The app is a local artifact, not included in a fresh clone. The prepared guide describes the delivered build; the [owner-review record](docs/03-production/b10-owner-review.md) holds current review status.

For development, use Godot 4.6.2 Standard at `/Applications/Godot.app` and run from the repository root:

```sh
zsh 'encounter/Launch Encounter.command'
```

[Player controls and saves](encounter/README.md) · [Local setup, tools and side effects](docs/02-technical/local-development.md)

## Validate

With Python 3, the basic isolated headless checks are:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s encounter/scripts -p 'test_*.py' -v
python3 encounter/scripts/validate.py --ci
```

The larger existing validation selection remains `python3 encounter/scripts/validate.py`. All use synthetic isolated saves. [GitHub CI and current validation evidence](docs/04-validation/ci-readiness.md) describe the exact scope and hosted limits; no signing or packaging runs in ordinary CI.

## Engineering references

- [Architecture](docs/02-technical/encounter-architecture.md) and [SSOT ownership](docs/02-technical/ssot.md)
- [Save recovery](docs/02-technical/error-handling.md) and [local security](docs/02-technical/security.md)
- [UI design](docs/ui-design.md) and [source-of-truth policy](docs/05-reference/source-of-truth-policy.md)

`encounter/` is the active project. `game/`, root `scripts/`, samples and old guides are historical workflows, not current setup commands. Preserve artwork masters, frozen builds and retained evidence. Generated app bundles, ZIPs, videos and raw frame sequences remain local; Git retains source, reports, logs and still screenshots. Keep the master plan synchronized with the linked Desktop tracker. Disposable source-tool bytecode and Godot import caches are ignored; evidence snapshots remain retained.
