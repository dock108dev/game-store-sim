# Documentation Index

This is the active project documentation set for the current Godot project.

## Core docs

- [Setup](setup.md) — local editor setup, helper scripts, and repository
  layout.
- [Architecture](architecture.md) — boot flow, scene entry points, and the
  autoload roster.
- [Ownership Matrix](architecture/ownership.md) — single-owner responsibilities
  (scene transitions, store lifecycle, camera, input focus, etc.).
- [Content and Data](content-data.md) — how JSON content is discovered, typed,
  validated, and accessed at runtime.
- [Testing](testing.md) — local validation entry points, GUT configuration,
  test layout, automation flags, and CI validation jobs.
- [Configuration and Deployment](configuration-deployment.md) — project
  settings, user data paths, export presets, and checked-in automation.

## Style

- [Visual Grammar](style/visual-grammar.md) — current UI color, accent,
  semantic, and font-size constants exposed by `UIThemeConstants` and the
  checked-in theme resources.

## Audit notes

- [Abend Handling Audit](audits/abend-handling-audit.md) — current
  fail-loud, warning, fallback, and soft-gate contracts.
- [Cleanup Report](audits/cleanup-report.md) — current justifications for
  oversized source files and broad visual suites that are intentionally kept
  grouped.
- [Error Handling Report](audits/error-handling-report.md) — section-id
  reference for handled-error contracts cited by code comments.
- [Security Report](audits/security-report.md) — section-id reference for
  current file-size, dictionary-bound, numeric, and dedupe hardening.
- [Phase 0 UI Integrity](audits/phase0-ui-integrity.md) — objective/tutorial
  SSOT, UI tripwire, and modal-layer contracts.
- [Runtime Audit Pass/Fail Matrix](audit/pass-fail-matrix.md) — executable
  audit checkpoint roster and gate behavior.
- [`docs/audits/docs-consolidation.md`](audits/docs-consolidation.md) records
  the most recent documentation review pass.

`tests/audit_run.sh` writes runtime audit logs and scenario reports under the
artifact tree. Hand-maintained audit notes stay under `docs/audits/`.

## Decisions And References

- [Decision 0007](decisions/0007-remove-sneaker-citadel.md) — data-driven
  store registry and single-store residue guard.
- [Canvas Layer Z-Order Bands](research/canvas-layer-z-order-conflicts.md) —
  current `UILayers` constants and scene-layer validation surface.
- [Store Ready Contract Examples](research/store-ready-contract-examples.md) —
  current `StoreReadyContract` invariants.
- [Roadmap](roadmap.md) — narrow maintenance roadmap entries required by
  legacy validators.

## Boundary

`README.md` is the only maintained project doc at the repository root.
`BRAINDUMP.md` is preserved as customer voice, not rewritten into project
documentation. Markdown under `.github/`, `addons/`, `.aidlc`, `artifacts/`,
and similar folders is configuration, vendored material, generated run output,
or platform tooling rather than the active game documentation set. The four
validator-required test ownership contracts remain at
`tests/automation/README.md`, `tests/baselines/README.md`,
`tests/flows/README.md`, and `tests/visual/README.md` because
`tests/validate_gut_config_discovery.sh` requires them. Visual-baseline policy
lives in [Testing](testing.md).
