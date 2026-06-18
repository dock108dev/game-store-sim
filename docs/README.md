# Documentation Index

This repo intentionally keeps a small active documentation set.

The previous broad production, beta/playtest-package, stockroom-production, graybox visual, hard-benchmark, and art-kit docs are no longer the active target when they conflict with the new design reset. The source of truth is now the design-source folder plus `docs/status.json`.

## Source Of Truth

- [Current State](CURRENT_STATE.md): current build, blocker, validation snapshot, and next decision.
- [Status JSON](status.json): machine-readable status contract used by tests.
- [Design Source Of Truth](design-source-of-truth/README.md): active design authority.

## Design Source Docs

- [Master Design Source Of Truth](design-source-of-truth/00-master-design-source-of-truth.md): core fantasy, non-negotiables, era, product rules, and design pillars.
- [Vertical Slice Specification](design-source-of-truth/01-vertical-slice-spec.md): first validated slice, starting inventory, day loop, required systems, and out-of-scope boundaries.
- [Store Design And World Building](design-source-of-truth/02-store-design-world-building.md): store personality, layout, density, zones, storytelling, customers, and hidden narrative boundaries.
- [Asset Inventory Roadmap](design-source-of-truth/03-asset-inventory-roadmap.md): implementation phases seeded from the 300-object asset inventory.
- [Validation And Signoff](design-source-of-truth/04-validation-and-signoff.md): owner review, screenshot checks, and implementation cycle.

## Design Implementation Docs

- [Design Implementation Index](design-implementation/README.md): agent operating rules, running document list, dependency model, and slice completion definition.
- [Visual Module System Spec](design-implementation/02-visual-module-system-spec.md): reusable module system, asset workflow, grid, collision, texture, material, and upgradeability rules.
- [Store Shell And Mall Entrance Slice](design-implementation/03-store-shell-and-mall-entrance-slice.md): opening spawn, retail corridor, `Games4U` storefront, open door, and no-NPC first read.
- [Starting Store Layout Spec](design-implementation/04-starting-store-layout-spec.md): footprint flexibility, real stockroom, side-wall checkout, player-driven zones, and minimal starter stock.
- [Fixture Grid Slice](design-implementation/05-fixture-grid-slice.md): starter wall shelves, movable purchasable fixtures, labels, visible capacity slots, and snap placement rules.

## Current Production Docs

- [Backlog](production/04-backlog.md): current work queue and stop conditions.
- [Validation](production/06-validation.md): full local gate and artifact policy.
- [Visual Bug List](production/13-alpha-bug-list.md): current design/visual blockers.

## Current QA

- [QA Index](qa/README.md)
- [Smoke Playtest](qa/smoke-playtest.md)
- [Screenshot Review](qa/screenshot-review.md)
