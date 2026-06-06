# Validation Strategy

## Required Local Gate

Run this from the repository root before finishing any implementation:

```text
scripts/validate_godot.sh
```

The gate writes logs, GUT results, and screenshots to `artifacts/validation/latest/`. That directory is ignored by Git.

The default Godot binary is `/Applications/Godot.app/Contents/MacOS/Godot`. Use `GODOT_BIN=/path/to/Godot scripts/validate_godot.sh` to override it.

## Automated Checks

The gate currently runs:

- `git diff --check` and `git diff --cached --check` for first-party files.
- Godot editor import/load in headless mode.
- Godot runtime quit smoke in headless mode.
- Godot main-scene boot smoke in headless mode.
- GUT tests under `game/tests/gut/`, with JUnit XML exported to `artifacts/validation/latest/gut-results.xml`.
- UI scenario automation coverage from `game/tests/validation_matrix.json`.
- Production-script test mapping coverage from `game/tests/validation_matrix.json`.
- Main-scene screenshot capture at `1280x720`.
- Screenshot dimension and nonblank pixel checks.
- Old project-name scan outside ignored/generated paths.

## Coverage Policy

Two local thresholds are mandatory:

- UI scenario automation coverage must be at least 80% of active validation scenarios.
- Production GDScript test mapping coverage must be at least 80%.

Critical smoke scenarios must be automated regardless of percentage. This includes main-scene boot, player spawn, floor collision, inspect prompt, and screenshot capture.

Script coverage is measured as tested-script mapping, not true line coverage. Godot does not provide a built-in game GDScript line coverage gate here. If a stable GDScript line/function coverage tool is added later, this policy can be upgraded.

## Manual Validation

Automated checks do not replace player-feel review. For the current graybox stage, manually validate:

- WASD movement feel.
- Mouse-look feel.
- Escape releases mouse capture and mouse click recaptures it.
- Prompt readability in the actual game window.
- Receiving box, display rack, register, and used-game visual placement.
- Held item stays visible without blocking normal navigation.
- Stocked game is visibly upright and intentional in the rack.
- Pricing panel text and controls are readable in the actual window.
- Pricing panel closes back into first-person mouse capture cleanly.
- Screenshot composition is useful, not merely nonblank.

Every implementation summary should say whether these were checked, skipped, or not relevant.

## Maintaining The Matrix

Update `game/tests/validation_matrix.json` whenever a production script or player-facing validation scenario is added.

Use these statuses:

- `automated`: covered by GUT, a validation script, or the local gate.
- `manual`: intentionally human-checked, with `reason` and `owner`.
- `not_applicable`: retained for historical context but excluded from active coverage.

Any new critical scenario must be automated before the gate is allowed to pass.
