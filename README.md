# Game Store Sim

First-person specialty video game retail simulator. The mechanical prototype is broad and validated; the active reset is design, world-building, visual quality, and store-read authenticity.

## Start Here

Read [docs/CURRENT_STATE.md](docs/CURRENT_STATE.md) first. Machine-readable status lives in [docs/status.json](docs/status.json). Tests should assert that status contract instead of depending on long production-plan prose.

The design canon is [Design Source Of Truth](docs/design-source-of-truth/README.md). It consolidates the owner-provided store/world brief, vertical slice spec, and 300-object asset inventory into repo-owned target docs.

The active implementation entrypoint is [Design Implementation Index](docs/design-implementation/README.md). Agents should start there for execution order, packet rules, validation evidence, and handoff expectations.

Older graybox, broad-production, beta, stockroom-production, hard-benchmark, and art-kit docs are not the active target if they disagree with the design source of truth or design implementation docs.

## Current Rule

Do not expand broad catalog visuals, customers, decoration breadth, hidden narrative, late-era content, or external playtest packaging until the opening store satisfies the design source of truth:

- a small independent 2002-2004 game store
- underfunded but functional
- game-first, with visible used/new/platform sections
- limited starting inventory with a clear growth path
- fictional products and platforms that read without real brands

Current art-reset entrypoints:

- [Design Implementation Index](docs/design-implementation/README.md)
- [Work Packet Index](docs/design-implementation/work-packets/00-packet-index.md)
- [Art Direction Reset And Spike Plan](docs/design-implementation/15-art-direction-reset-and-spike-plan.md)
- [Art Direction Spike Packet](docs/design-implementation/work-packets/09-art-direction-spike.md)

Use [Design Source Of Truth](docs/design-source-of-truth/README.md) when a packet needs design intent, owner decisions, or quality-bar context.

Use `inspiration/` for stylized game-world scaffold and `new_real_inspiration/` for real early-2000s retail fixture, shelf, product-density, and counter reference.

## Validate

Run the full local gate from the repository root:

```text
scripts/validate_godot.sh
```

The gate writes logs, screenshots, and the contact sheet to `artifacts/validation/latest/`.

Current validation snapshot:

- Current doc-contract expectation: 587 GUT tests and 11865 GUT asserts.
- UI scenario automation coverage: 512/632.
- Production script mapping: 54/54.
- 3 active standalone validation tools.
- 62 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot capture/sanity, contact sheet, old-name scan, and 27 required screenshots pass.

## Active Docs

- [Docs Index](docs/README.md)
- [Current State](docs/CURRENT_STATE.md)
- [Design Source Of Truth](docs/design-source-of-truth/README.md)
- [Design Implementation Index](docs/design-implementation/README.md)
- [Art Direction Reset And Spike Plan](docs/design-implementation/15-art-direction-reset-and-spike-plan.md)
- [Backlog](docs/production/04-backlog.md)
- [Validation](docs/production/06-validation.md)
- [Visual Bug List](docs/production/13-alpha-bug-list.md)
- [Owner Visual Review Package](docs/production/14-owner-visual-review-package.md)
- [QA](docs/qa/README.md)
