# Game Store Sim

First-person specialty video game retail simulator. The mechanical prototype is broad and validated; the active reset is design, world-building, visual quality, and store-read authenticity.

## Start Here

Read [docs/CURRENT_STATE.md](docs/CURRENT_STATE.md) first. Machine-readable status lives in [docs/status.json](docs/status.json). Tests should assert that status contract instead of depending on long production-plan prose.

The active design authority is [Design Source Of Truth](docs/design-source-of-truth/README.md). It consolidates the owner-provided store/world brief, vertical slice spec, and 300-object asset inventory into repo-owned implementation docs.

Older graybox, broad-production, beta, stockroom-production, hard-benchmark, and art-kit docs are not the active target if they disagree with the design source of truth.

## Current Rule

Do not expand broad catalog visuals, customers, decoration breadth, hidden narrative, late-era content, or external playtest packaging until the opening store satisfies the design source of truth:

- a small independent 2002-2004 game store
- underfunded but functional
- game-first, with visible used/new/platform sections
- limited starting inventory with a clear growth path
- fictional products and platforms that read without real brands

The next implementation pass starts with:

- [Master Design Source Of Truth](docs/design-source-of-truth/00-master-design-source-of-truth.md)
- [Vertical Slice Specification](docs/design-source-of-truth/01-vertical-slice-spec.md)
- [Asset Inventory Roadmap](docs/design-source-of-truth/03-asset-inventory-roadmap.md)
- [Validation And Signoff](docs/design-source-of-truth/04-validation-and-signoff.md)

## Validate

Run the full local gate from the repository root:

```text
scripts/validate_godot.sh
```

The gate writes logs, screenshots, and the contact sheet to `artifacts/validation/latest/`.

Current validation snapshot:

- Current doc-contract expectation: 570 GUT tests and 10823 GUT asserts.
- UI scenario automation coverage: 508/628.
- Production script mapping: 53/53.
- 3 active standalone validation tools.
- 60 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot capture/sanity, contact sheet, old-name scan, and 23 required screenshots pass.

## Active Docs

- [Docs Index](docs/README.md)
- [Current State](docs/CURRENT_STATE.md)
- [Design Source Of Truth](docs/design-source-of-truth/README.md)
- [Backlog](docs/production/04-backlog.md)
- [Validation](docs/production/06-validation.md)
- [Visual Bug List](docs/production/13-alpha-bug-list.md)
- [QA](docs/qa/README.md)
