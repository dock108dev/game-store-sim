# Design Source Of Truth

This folder is the design canon for the game.

The current gameplay functionality is broadly useful. The reset is about design, world-building, visual goals, asset priorities, and validation criteria.

Use this folder to understand what the game must feel like and what owner decisions are locked. Do not use this folder as the day-to-day implementation queue. Active execution starts in `docs/design-implementation/README.md`, which slices this canon into agent-ready implementation work.

If another doc disagrees with this folder on fantasy, era, store identity, product rules, or quality bar, update the older doc or treat it as historical. If implementation sequencing disagrees, follow `docs/design-implementation/` unless it violates this canon.

## Canon Docs

- [Master Design Source Of Truth](00-master-design-source-of-truth.md): core fantasy, non-negotiables, era, product rules, and design pillars.
- [Vertical Slice Specification](01-vertical-slice-spec.md): what the first validated slice must prove and what stays out of scope.
- [Store Design And World Building](02-store-design-world-building.md): store personality, layout, density, zones, storytelling, customers, and hidden narrative boundaries.
- [Asset Inventory Roadmap](03-asset-inventory-roadmap.md): implementation phases seeded from the 300-object asset inventory.
- [Validation And Signoff](04-validation-and-signoff.md): how implementation passes are accepted, corrected, or rejected.

## Source Inputs

These docs consolidate three owner-provided inputs:

- Store Design & World Building Brief v1.0.
- Vertical Slice Build Specification v4.0.
- `game_store_sim_300_object_asset_inventory.xlsx`.

The source inputs are no longer treated as loose attachments. Their decisions are captured here as repo-owned production docs.
