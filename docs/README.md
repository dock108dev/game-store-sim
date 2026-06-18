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
- [Checkout And Trade-In Counter Slice](design-implementation/06-checkout-and-trade-in-counter-slice.md): shared sales/trade-in station, clean register setup, one-line queue, and behind-counter hold/intake storage.
- [Product And Platform Visual Language Spec](design-implementation/07-product-and-platform-visual-language-spec.md): fictional platform/product language, two-tone case signals, cover art, used stickers, case prices, and starter titles.
- [Required Zones Slice](design-implementation/08-required-zones-slice.md): inventory-source new/used rules, player-organized labels, demo placement, hardware/receiving roles, and first-use guidance.
- [Density And Clutter Rules](design-implementation/09-density-and-clutter-rules.md): empty-promising day-one density, setup clutter, stockroom planning desk, console box stacks, mall atmosphere, and visual-review rules.
- [Signage Branding And Store Identity Spec](design-implementation/10-signage-branding-and-store-identity-spec.md): editable store name, mall storefront signage, shelf labels, posters, neighboring signs, and copy tone.
- [Lighting Materials And Color Palette Spec](design-implementation/11-lighting-materials-and-color-palette-spec.md): bright retail lighting, warmer mall contrast, commercial carpet, editable color panels, fixture materials, and palette rules.
- [Validation And Screenshot Checklist](design-implementation/12-validation-and-screenshot-checklist.md): screenshot-first review, final game-window artifacts, detailed notes, explicit fail language, and docs-only skip rules.
- [Agent Work Packet Template](design-implementation/13-agent-work-packet-template.md): strict implementation packet format with read-first docs, scope, validation evidence, decision log, final handoff, and parallel-work rules.
- [Phase Implementation Roadmap](design-implementation/14-phase-implementation-roadmap.md): master path from planning lock through implementation phases, validation, owner review, correction loop, and tester readiness.

## Current Production Docs

- [Backlog](production/04-backlog.md): current work queue and stop conditions.
- [Validation](production/06-validation.md): full local gate and artifact policy.
- [Visual Bug List](production/13-alpha-bug-list.md): current design/visual blockers.

## Current QA

- [QA Index](qa/README.md)
- [Smoke Playtest](qa/smoke-playtest.md)
- [Screenshot Review](qa/screenshot-review.md)
