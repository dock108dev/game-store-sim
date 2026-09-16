# Local validation — R5 and retained baseline

## Current R5 encounter

From the repository root, run `python3 encounter/scripts/validate.py` for isolated headless import, `test_assortment.gd`, `test_price_request.gd` and `test_assortment_scene.gd`. See [local development](../02-technical/local-development.md) for requirements, outputs, side effects and optional `--render` / `--capture` checks. Older slice tests are retained, not the current suite selection.

[R5 delivery](../03-production/r5-delivery.md) records the September 9 candidate's 110 state checks, 3 pending-label checks and 54 scene checks in each headless/normal/Retina run. Those are retained results, not a new pass on every checkout. [Current identity reconciliation](../MASTER_PLAN.md#checkout-and-evidence-reconciliation--2026-09-15) distinguishes the candidate manifest, validation context and later capture-tool revision. Owner acceptance remains pending. Headless checks do not establish visual quality, warning-free shutdown or release readiness.

The September 16 tooling cleanup also passed the default headless gate (110 state, 3 pending-label, 54 scene checks) and four Python wrapper tests. See the [maintenance record](../MASTER_PLAN.md#maintenance-cleanup--2026-09-16) for exact evidence and limits. Rendered/capture checks were not repeated.

## Historical first-person baseline

The remaining procedure applies only to `game/` and root `scripts/`, not the active encounter. Read the [recovery review](../03-production/recovery-review-2026-09-07.md) for verified historical scope and four recorded defects. Its validator passes a limited happy path; it is not a complete-game or owner-acceptance gate.

## Safe baseline procedure

Use a disposable archive/copy, not the working project or an owner's save directory. Preserve existing outputs before any rerun: `scripts/validate_local.sh` deletes its copy's `artifacts/validation/latest`.

The recorded temporary checkout path and exact source commit are in [context.json](recovery-evidence-2026-09-07/context.json). The archived project's only settings modification was to add these keys under `[application]`:

```ini
config/use_custom_user_dir=true
config/custom_user_dir_name="GSS-Recovery-<unique-run-id>"
```

Choose a new unique name on each reproduction. Godot logs/saves then use that isolated macOS Application Support directory; do not point it at owner data. The original validator additionally writes its proof save to its own artifact directory.

From the disposable checkout run:

```sh
bash scripts/validate_local.sh
```

Preserve the exit code, validation log, engine/main-scene logs, summary and fixture output in a new evidence directory. Scan import as well as runtime logs for warnings/errors. Passing validates import/resource load, the 15-step one-sale happy path and a brief headless launch. It does not validate rendered graphics, real input feel or production save resilience.

Copy [recovery_probes.gd](recovery-evidence-2026-09-07/recovery_probes.gd) into the disposable `game/` folder, then run with absolute paths substituted:

```sh
GSS_PROBE_RESULTS=/absolute/new-evidence/probe-results.json /Users/michaelfuscoletti/.local/bin/godot --headless --path /absolute/disposable/game --script res://recovery_probes.gd
```

Preserve stdout/stderr and exit status. The recorded baseline returns exit 1: six checks pass and four fail. These probes document gaps rather than weakening the original gate. Do not relabel their failures as successful acceptance tests.

## Launching the historical proof

For an explicitly requested hands-on review, launch the isolated project:

```sh
/Users/michaelfuscoletti/.local/bin/godot --path /absolute/disposable/game
```

WASD movement (forward/backward direction has a recorded defect), click to capture mouse, Escape releases it; E picks up/places/sells, P sets used price to suggested maximum, F performs one preset shelf move, O opens, R closes/shows report, K saves, L loads. This is historical debug interaction, not the chosen restart UI. Headless handler checks are not a manual walkthrough.

Optional export remains a separate operation, not executed in recovery review. An export preset's existence is not an exported-app pass.

## Visual evidence

`run_validation.gd::_write_proof_screenshot` paints pixels and does not capture the scene. Its output is a synthetic fixture. Successful imports, resource loads, PNG dimensions or compressed-byte variation do not establish good graphics. Future visual proof must follow the [V1 contract](../01-design/visual-benchmark-first-0.3.md): actual running-engine motion/captures at gameplay scale, editable sources, inspected alpha, repeatability and separate owner feedback.
