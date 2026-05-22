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
- [Testing](testing.md) — local test entry points, GUT configuration, coverage
  areas, and CI validation jobs.
- [Configuration and Deployment](configuration-deployment.md) — project
  settings, user data paths, export presets, and checked-in automation.
- [Maintenance Follow-up](maintenance/cleanup-follow-up.md) — tracked
  oversized files that need deliberate follow-up refactors.

## Style

- [Visual Grammar](style/visual-grammar.md) — current UI color, accent,
  semantic, and font-size constants exposed by `UIThemeConstants` and the
  checked-in theme resources.

## Audit notes

- [`docs/audits/docs-consolidation.md`](audits/docs-consolidation.md) records
  the most recent documentation review pass.

`tests/audit_run.sh` can generate dated `docs/audits/YYYY-MM-DD-audit.md`
interaction tables during local or CI audit runs. Generated audit tables are
not part of the hand-maintained docs set.

## Boundary

`README.md` is the only active project doc at the repository root.
Markdown under `.github/`, `addons/`, `.aidlc/`, and similar folders is
configuration, vendored material, generated run output, or platform tooling
rather than the active game documentation set.
