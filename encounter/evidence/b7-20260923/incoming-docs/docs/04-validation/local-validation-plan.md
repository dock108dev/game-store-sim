# Local validation — B6 and retained baselines

## Current B6 encounter

From the repository root, run `python3 encounter/scripts/validate.py` for isolated headless import, `test_assortment.gd`, `test_price_request.gd` `test_assortment_scene.gd`, `test_layout.gd`, `test_layout_scene.gd`, `test_growth.gd`, `test_growth_scene.gd`, `test_employees.gd`, `test_employees_scene.gd`, `test_used.gd` and `test_used_scene.gd`. See [local development](../02-technical/local-development.md) for requirements, outputs, side effects and optional `--render` / `--capture` checks. Older slice tests are retained, not the current suite selection.

[B6 delivery](../03-production/b6-delivery.md) is the current technical evidence and acceptance-case map; [B2 delivery](../03-production/b2-delivery.md) remains its retained baseline. Growth verification includes actual-rule survivor/bankruptcy, synthetic wage accounting, frozen reports, exactly-once rent/expansion, write failure/retry, terminal preservation and expanded-room normal/Retina interaction. Layout tests include nonoverlapping disconnected placement, exactly-once expenses, slot ownership, stocked move/reload, stale/unreachable work, real UI input and moving customer traces. Technical success does not accept the product for the owner.

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


B4 adds `test_employees.gd` and `test_employees_scene.gd`: employment reconstruction, idempotent commitments, claims, takeover, unfinished save restoration, actual overhead and insolvency; physical receiving/rack/cashier work, shared movement arbitration and layout/close cancellation. The renderer retains normal/Retina images plus normal motion video and sampled actor/job traces. Empty-day preludes, paused snapshot boundaries and blocked-navigation injection are explicitly synthetic engineering setup/probes. Dropdown choices use the ordinary selection signal; buttons use viewport mouse input. All checks use Dummy audio and cannot qualify sound or owner acceptance.

B5 adds state coverage for condition-derived terms/budgets, asking/counter/final acceptance, refusal/cancel/limits, stale/duplicate confirmation, restored negotiation/acquisition/claims, cash/capacity preflight, full displays, immutable mixed inventory provenance, worker/player contention, real cost-of-sales arithmetic and terminal rejection. Its scene suite uses seller arrival, intake inspection, offers, separate confirmation, save/reload, next-day copy labeling and player/worker resale through ordinary controls in base/expanded shops. Motion sampling checks all actors for fixture clearance and separation. Numeric fields are set through the UI controls; button events use viewport mouse input. Empty-day prelude and paused reload boundaries remain synthetic setup; cash/inbound-capacity corruption is explicitly a fault probe. Technical evidence and muted render passes supply neither sound qualification nor owner acceptance.


## B6 current evidence contract

`validate.py` selects B6 week state/regressions, the pending-price seam, and full-week/base-shop breadth scene suites. The broad B2–B5 standalone suites retain their earlier content assumptions and are historical, not an implicit current pass. B6 rechecks atomic layout expense/slots, expansion, real employment/wages, exclusive claims/takeover/restoration, fixed offers/refusals, seller limits and exact payments, historical acquisition costs, close/terminal boundaries, failed save/retry and preserved terminal restart under schema 10.

B6 adds day-4/day-6 release boundaries, no early payment, same-prep ordering/receiving, quantity/cash/64-copy capacity rejection, no duplicate orders/receipts, persisted daily identities/terms/budgets, eligibility and stable acquisition ordering. The complete control-driven seven-day scene and scripted surviving/failure routes retain actual arithmetic. Base eight-arrival contention includes two workers, the separate seller and player new/used work. Source identity includes dirty/untracked source, not HEAD alone. Normal/Retina screenshots and motion traces support technical visual checks only; Dummy audio never qualifies audio. Preserve all failed attempts and distinguish scripted setup from ordinary interaction. B7 polish, B8 alternatives/recovery/balance, B9 packaging and B10 owner judgment remain separate.
