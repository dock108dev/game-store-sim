# Validation

Run this from the repository root before finishing implementation work:

```text
scripts/validate_godot.sh
```

The gate writes artifacts to `artifacts/validation/latest/`.

## Current Gate

The gate runs:

- whitespace checks
- Godot editor import/load smoke
- Godot runtime quit smoke
- Godot main-scene boot smoke
- GUT tests
- coverage policy
- product catalog content checks
- desktop pack smoke
- alpha performance smoke
- screenshot capture
- screenshot sanity checks
- screenshot contact-sheet generation
- old-name scan

Current validated baseline after the first art-kit implementation:

- 570 GUT tests.
- 10791 GUT asserts.
- UI scenario automation coverage: 508/628, or 80.9%.
- Production script mapping coverage: 53/53, or 100.0%.
- 3 active standalone validation tools.
- 60 catalog products.
- Desktop pack export smoke passed.
- Alpha performance smoke passed.
- Screenshot sanity passed.
- 23 required screenshots captured.
- Screenshot contact sheet generated at `artifacts/validation/latest/screenshot-contact-sheet.png`.
- Old-name scan passed.

## Visual-Rebuild Validation

For the current art-language rebuild, automated validation is necessary but insufficient. The pass is not approved unless the owner review confirms that the opening route no longer reads as cubes with labels.

Required evidence:

- focused tests for changed scene/doc contracts
- full `scripts/validate_godot.sh` for production-route integration
- regenerated contact sheet
- manual 1280x720 walk-in review from mall spawn to register view
- screenshot review against `docs/qa/screenshot-review.md`
- optional sandbox capture through `game/tests/tools/capture_art_benchmark_screenshot.gd`

## Validation Data Shape

- Thresholds: `game/tests/validation/thresholds.json`
- UI scenarios: `game/tests/validation/scenarios/*.json`
- Script coverage mapping: `game/tests/validation/script_coverage/production_scripts.json`
- Standalone tool manifests: `game/tests/validation/tool_checks/*.json`

The checker is `scripts/check_validation_coverage.py`.
