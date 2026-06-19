# Validation

Run this from the repository root before finishing implementation work:

```text
scripts/validate_godot.sh
```

The gate writes artifacts to `artifacts/validation/latest/`.

Important: this gate is regression evidence only. It does not define visual progress, approve art quality, or unblock beta/tester work.

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
- alpha performance smoke, retained as a legacy performance label in the current script
- screenshot capture
- screenshot sanity checks
- screenshot contact-sheet generation
- old-name scan

Current validation snapshot:

- Current doc-contract expectation: 592 GUT tests and 12273 GUT asserts.
- UI scenario automation coverage: 512/632, or 81.0%.
- Production script mapping coverage: 55/55, or 100.0%.
- 3 active standalone validation tools.
- 62 catalog products.
- Desktop pack export smoke passed.
- Alpha performance smoke passed.
- Screenshot sanity passed.
- 27 required screenshots captured.
- Screenshot contact sheet generated at `artifacts/validation/latest/screenshot-contact-sheet.png`.
- Old-name scan passed.

## Design-Reset Validation

For the current design reset, automated validation is necessary but insufficient. The last object-family pass passed automation and still failed visual review. The pass is not approved unless owner review confirms that the opening store delivers the fantasy documented in `docs/design-source-of-truth/` and the object-family quality documented in `docs/visual-bible/`.

`scripts/validate_godot.sh` and the generated contact sheet are regression evidence. They do not approve the design reset by themselves because the previous screenshot set and pass/fail logic were created for graybox-era checks.

Current visual approval gate:

- build one isolated hero art slice
- capture one screenshot at 1280x720 or larger
- review it against `docs/production/15-failed-visual-validation.md`
- owner explicitly approves or rejects the visual method

Required evidence:

- focused tests for changed scene/doc contracts
- full `scripts/validate_godot.sh` for production-route integration only when the production route changes
- regenerated contact sheet or replacement review board for changed visual routes
- manual 1280x720 walk-in review from entrance to checkout
- implementation evidence review against `docs/production/14-visual-bible-implementation-review.md`
- screenshot review against `docs/qa/screenshot-review.md`
- source-of-truth checklist review against `docs/design-source-of-truth/04-validation-and-signoff.md`

## Validation Data Shape

- Thresholds: `game/tests/validation/thresholds.json`
- UI scenarios: `game/tests/validation/scenarios/*.json`
- Script coverage mapping: `game/tests/validation/script_coverage/production_scripts.json`
- Standalone tool manifests: `game/tests/validation/tool_checks/*.json`

The checker is `scripts/check_validation_coverage.py`.
