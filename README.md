# Shelf Life / Mallcore Sim

This repository is a Godot/GDScript retail sim. `project.godot` names the
running project `Shelf Life`; the checked-in desktop export presets name the
exported product `Mallcore Sim` and write `MallcoreSim` artifacts. Boot content
loads from JSON under `game/content/`, and tests use the checked-in GUT addon.

## Run locally

1. Install a standard non-.NET Godot 4.6.2 editor build.
2. Import `project.godot`.
3. Let Godot import project assets.
4. Run the project with F5.

The configured entry scene is `res://game/scenes/bootstrap/boot.tscn`.

For command-line test runs:

```bash
bash tests/run_tests.sh
```

See [Testing](docs/testing.md) for the full local and CI test gates.

## Deployment basics

`export_presets.cfg` defines checked-in local export presets for:

- `Windows Desktop` -> `exports/windows/MallcoreSim.exe`
- `macOS` -> `exports/macos/MallcoreSim.zip`
- `Linux/X11` -> `exports/linux/MallcoreSim.x86_64`

Pushes of version tags matching `v*` run the export workflow, which validates
the release ref and export configuration, runs the release gates, exports
Windows, macOS, and Linux builds, uploads short-retention build artifacts, and
creates a GitHub release. Manual dispatch of the same workflow uploads
release-candidate artifacts and the playtest checklist without publishing a
release.

## Documentation

Supporting project docs live under `docs/`:

- [Docs Index](docs/index.md)
- [Setup](docs/setup.md)
- [Architecture](docs/architecture.md)
- [Content and Data](docs/content-data.md)
- [Testing](docs/testing.md)
- [Configuration and Deployment](docs/configuration-deployment.md)
- [Visual Grammar](docs/style/visual-grammar.md)
