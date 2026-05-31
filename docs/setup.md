# Setup

## Requirements

- A standard Godot 4.6.2 editor build (non-.NET).
- Bash for the helper scripts and test runner.
- No external package manager is required for gameplay code.

`project.godot` declares Godot `4.6` project features. Validation CI installs
Godot `4.6.2-stable`; export CI installs Godot `4.6.2` plus export templates.
Use Godot 4.6.2 locally for parity.

## Open the project

1. Launch Godot.
2. Import `project.godot`.
3. Let Godot import assets.
4. Run the project from the editor.

The configured main scene is `res://game/scenes/bootstrap/boot.tscn`.

## Command-line helpers

### Import assets

Use the import helper on a fresh clone or before headless test/export work:

```bash
bash scripts/godot_import.sh
```

### Run the resolved Godot binary

Use the wrapper when you want the repo's Godot-resolution logic without
repeating it by hand:

```bash
bash scripts/godot_exec.sh --headless --path . --version
```

Both scripts resolve Godot in this order:

1. `GODOT`
2. `GODOT_EXECUTABLE`
3. `godot` on `PATH`
4. `/Applications/Godot.app/Contents/MacOS/Godot`
5. `$HOME/Applications/Godot.app/Contents/MacOS/Godot`

If needed:

```bash
export GODOT=/path/to/Godot
```

## Run validation

```bash
bash tests/run_tests.sh
```

This is the default local gate. See [Testing](testing.md) for the current
runner steps, artifact paths, automation flags, and CI jobs.

## Repository layout

```text
addons/gut/          Checked-in GUT addon
game/autoload/       Autoload singletons from project.godot
game/content/        JSON content scanned at boot
game/resources/      Typed Resource classes populated from content
game/scenes/         Boot, menu, world, store, debug, and UI scenes
game/scripts/        Systems, controllers, and gameplay support scripts
tests/automation/    GUT hooks, scenario helpers, and automation runners
tests/baselines/     Golden manifests, snapshots, and expected outputs
tests/flows/         End-to-end player and store-session route tests
tests/visual/        UI, layout, screenshot, visual-state tests, and
                     display-backed store visual sweep baselines
tests/               Main GUT suite, integration/unit tests, shell validators
game/tests/          Additional GUT coverage included by .gutconfig.json
docs/                Active supporting project docs and audit notes
```

Generated cache directories such as `.godot/` are editor/runtime artifacts, not
source content or project documentation.
