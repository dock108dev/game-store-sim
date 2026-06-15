# Validation

Run this from the repository root before finishing implementation work:

```text
scripts/validate_godot.sh
```

The gate writes artifacts to `artifacts/validation/latest/`.

## Current Gate

The gate runs:

- First-party whitespace checks.
- Godot editor import/load smoke.
- Godot runtime quit smoke.
- Godot main-scene boot smoke.
- GUT tests.
- Coverage policy.
- Product catalog content checks.
- Desktop pack smoke.
- Alpha performance smoke.
- Screenshot capture.
- Screenshot sanity checks.
- Old-name scan.

Current validated baseline:

- 570 GUT tests.
- 10028 GUT asserts.
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

## Validation Data Shape

The validation matrix is split across structured manifests. There is no single active `validation_matrix.json` file.

- Thresholds: `game/tests/validation/thresholds.json`
- UI scenarios: `game/tests/validation/scenarios/*.json`
- Script coverage mapping: `game/tests/validation/script_coverage/production_scripts.json`
- Standalone tool manifests: `game/tests/validation/tool_checks/*.json`

The checker is `scripts/check_validation_coverage.py`.

## Thresholds

- UI validation automation coverage must stay at or above 80% for active scenarios.
- Script test mapping coverage must stay at or above 80% for production scripts.
- Critical scenarios must be automated.
- Manual scenarios must include both `reason` and `owner`.

## Screenshot Artifacts

The gate captures 23 screenshots under `artifacts/validation/latest/screenshots/`. Use `docs/qa/screenshot-review.md` for human approval.

Screenshot sanity confirms dimensions and nonblank image diversity. It does not prove art quality, composition, label readability, or game feel. For the current visual cycle, screenshot capture targets `store_world.tscn`; `main_scene.png`, `storefront_entry.png`, `register_counter.png`, `receiving_area.png`, `backroom_summary.png`, and real-window walk-in screenshots are the first review artifacts for the hard visual benchmark rebuild.

## Manual Review

Manual review is now split into QA runbooks:

- `docs/qa/smoke-playtest.md`
- `docs/qa/full-day-playtest.md`
- `docs/qa/screenshot-review.md`
- `docs/qa/release-package-check.md`

## Completed Validation Sync Markers

These markers remain for historical scenario compatibility:

- Hidden-thread validation sync is complete through Stop 10.6.
- Presentation validation sync is complete through Stop 11.6.
- Release wrapper validation sync is complete through Stop 12.6.
- Alpha playtest package is complete through Stop 13.6.
- Alpha validation sync is complete through Stop 13.7.
