# Game Store Sim

First-person specialty video game retail simulator. The mechanical prototype is broad and validated; the active reset is visual quality and store-read authenticity.

## Start Here

Read [docs/CURRENT_STATE.md](docs/CURRENT_STATE.md) first. Machine-readable status lives in [docs/status.json](docs/status.json). Tests should assert that status contract instead of depending on long production-plan prose.

The design canon is [Design Source Of Truth](docs/design-source-of-truth/README.md). It consolidates the owner-provided store/world brief, vertical slice spec, and 300-object asset inventory into repo-owned target docs.

The active object-family art target is [Visual Bible](docs/visual-bible/README.md). It translates the asset inventory and owner answers into MVP + first-store visual rules: Blender-authored meshes, physical fixtures, recognizable product art, readable signage, and a 7.5/10 owner quality bar.

The active implementation entrypoint is [Design Implementation Index](docs/design-implementation/README.md). Agents should start there for execution order, packet rules, validation evidence, and handoff expectations.

Current visual status: the first Visual Bible object-family pass is blocked as a failed visual validation. The isolated [Hero Art Slice Proof](docs/design-implementation/work-packets/05-hero-art-slice-proof.md) now exists and is pending owner review through [Hero Art Slice Review](docs/production/16-hero-art-slice-review.md), backed by [Failed Visual Validation](docs/production/15-failed-visual-validation.md).

Older graybox, broad-production, beta, stockroom-production, hard-benchmark, old slice, and Packet 01-09 docs were removed from active routing when they conflicted with the Visual Bible reset.

## Current Rule

Do not expand broad catalog visuals, customers, decoration breadth, hidden narrative, late-era content, external playtest packaging, mechanics, or playable-store polish until the hero art slice screenshot is approved:

- a small independent 2002-2004 game store
- underfunded but functional
- game-first, with visible used/new/platform sections
- limited starting inventory with a clear growth path
- fictional products and platforms that read without real brands

`scripts/validate_godot.sh` is regression evidence only. It does not define visual progress or approve art quality.

Current art-reset entrypoints:

- [Visual Bible](docs/visual-bible/README.md)
- [MVP Object Implementation Checklist](docs/visual-bible/09-mvp-object-implementation-checklist.md)
- [Design Implementation Index](docs/design-implementation/README.md)
- [Work Packet Index](docs/design-implementation/work-packets/00-packet-index.md)
- [Hero Art Slice Proof](docs/design-implementation/work-packets/05-hero-art-slice-proof.md)
- [Failed Visual Validation](docs/production/15-failed-visual-validation.md)
- [Hero Art Slice Review](docs/production/16-hero-art-slice-review.md)
- [Art Direction Reset And Spike Plan](docs/design-implementation/15-art-direction-reset-and-spike-plan.md)

Use [Design Source Of Truth](docs/design-source-of-truth/README.md) when a packet needs design intent, owner decisions, or quality-bar context.

Use `inspiration/` for stylized game-world scaffold and `new_real_inspiration/` for real early-2000s retail fixture, shelf, product-density, and counter reference.

## Validate

Run the full local gate from the repository root:

```text
scripts/validate_godot.sh
```

The gate writes logs, screenshots, and the contact sheet to `artifacts/validation/latest/`.

Current validation snapshot:

- Current doc-contract expectation: 594 GUT tests and 12286 GUT asserts.
- UI scenario automation coverage: 512/632.
- Production script mapping: 55/55.
- 3 active standalone validation tools.
- 62 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot capture/sanity, contact sheet, old-name scan, and 27 required screenshots pass.

## Active Docs

- [Docs Index](docs/README.md)
- [Current State](docs/CURRENT_STATE.md)
- [Design Source Of Truth](docs/design-source-of-truth/README.md)
- [Visual Bible](docs/visual-bible/README.md)
- [Design Implementation Index](docs/design-implementation/README.md)
- [Art Direction Reset And Spike Plan](docs/design-implementation/15-art-direction-reset-and-spike-plan.md)
- [Backlog](docs/production/04-backlog.md)
- [Validation](docs/production/06-validation.md)
- [Visual Blockers](docs/production/13-visual-blockers.md)
- [Visual Bible Implementation Review](docs/production/14-visual-bible-implementation-review.md)
- [Failed Visual Validation](docs/production/15-failed-visual-validation.md)
- [Hero Art Slice Review](docs/production/16-hero-art-slice-review.md)
- [QA](docs/qa/README.md)
