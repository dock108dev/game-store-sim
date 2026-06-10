# Game Store Sim

First-person specialty video game retail simulator. The player runs a small game shop by receiving stock, pricing used games, stocking fixtures, serving customers, handling returns/trade-ins/services/preorders, planning supplier and launch allocations, and optionally noticing suspicious activity under the normal retail loop.

## Current State

Read [Current State](docs/CURRENT_STATE.md) first. It is the authoritative human-readable handoff for what is playable, what is validated, what remains blocked by human review, and which docs are active.

Machine-readable status lives in [docs/status.json](docs/status.json). Tests should assert that status contract instead of depending on long production-plan prose.

## Validate

Run the full local gate from the repository root:

```text
scripts/validate_godot.sh
```

The gate writes logs and screenshots to `artifacts/validation/latest/`.

Current validated baseline:

- 553 GUT tests.
- UI scenario automation coverage: 508/628.
- Production script mapping: 52/52.
- 3 active standalone validation tools.
- 33 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot capture/sanity, and old-name scan pass.

## Active Docs

- [Current State](docs/CURRENT_STATE.md): source of truth for current status and next review decision.
- [Validation](docs/production/06-validation.md): local gate, scenario manifests, thresholds, and artifacts.
- [Smoke Playtest](docs/qa/smoke-playtest.md): short playable sanity run.
- [Full-Day Playtest](docs/qa/full-day-playtest.md): internal full retail-loop QA.
- [Screenshot Review](docs/qa/screenshot-review.md): review the 23 validation screenshots.
- [Release Package Check](docs/qa/release-package-check.md): pack smoke and external handoff readiness.
- [Backlog](docs/production/04-backlog.md): short current backlog and next decision.
- [Alpha Bug List](docs/production/13-alpha-bug-list.md): current issue priorities.
- [Alpha Playtest Package](docs/production/15-alpha-playtest-package.md): paused external tester handoff.

## Reference Docs

Long production plans are retained as historical slice records, not active instructions. See [Archive Index](docs/archive/README.md) for the current classification.

The Employees-Only Stockroom Production Plan remains available as a completed historical record for the physical stockroom, receiving, backstock, office computer, service/security corners, and validation sync.
