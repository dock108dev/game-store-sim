# FP Roam Validation

The FP roam harness is the recurring visual validation loop for store-session
work. Use it before and after visual phases so screenshots are compared from
the same camera stops instead of from ad hoc playthrough angles.

## Workflow

1. Capture the current baseline before a scoped phase change:

```bash
bash scripts/run_fp_roam_validation.sh control
```

2. Implement a scoped visual or HUD change.

3. Capture the candidate:

```bash
bash scripts/run_fp_roam_validation.sh candidate
```

4. Review the candidate manifest, comparison manifest, and contact sheet:

- `artifacts/fp_roam_validation/control/current`
- `artifacts/fp_roam_validation/candidate/current`
- `artifacts/fp_roam_validation/compare`
- `artifacts/fp_roam_validation/*/review_manifest.json`
- `artifacts/fp_roam_validation/compare/compare_manifest.json`
- `artifacts/fp_roam_validation/compare/contact_sheet.png`

For archived phase-to-phase comparisons, set `MALLCORE_ARTIFACT_DIR` to a
named artifact root, then compare the prior candidate against the new candidate
with `tests/visual/compare_fp_roam_validation.py --common-only`. The normal
control/candidate path should not use `--common-only`, because it must fail if
the current manifest has missing captures.

## Route Stops

The route is defined in `tests/visual/fp_roam_validation_manifest.gd`.
Current stops cover spawn, checkout, starter display, stockroom threshold,
stockroom interior, exit threshold, a wide back-of-store sanity view, and close
reads for storefront identity, shelf-wall density, checkout detail, and the
starter display table.

Add new rows to the manifest when a new failure mode appears. Keep old rows
stable unless the route itself becomes invalid, because control/candidate
comparison depends on identical stop names and filenames.

## Checks

Every capture validates:

- ObjectiveRail hidden in first-person mode.
- FP validation overlay shows the single objective sentence in the
  `WorkSurfaceLayout.FP_SENTENCE_RECT` slot.
- InteractionPrompt only appears on focused stops.
- Required route anchors exist and are visible.
- Captures are display-backed, nonblank 1280x720 PNGs.
- Per-stop image metrics stay within configured limits such as near-white ratio.
- FP status panel width and background alpha stay within readability limits.

The display-backed capture uses a lightweight FP validation overlay so the route
can run as a stable `--script` harness. The full HUD scene contract remains
covered by the focused GUT tests named in each review manifest.
