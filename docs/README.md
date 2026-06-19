# Documentation Index

This repo now uses a compact active documentation set for the visual reset.

Current visual status: the first Visual Bible object-family implementation pass is visually rejected. The next allowed implementation is one isolated hero art slice proof, not broad mechanics or playable-store work.

The broad graybox, art-kit, hard-benchmark, old alpha/beta, and Packet 01-09 implementation docs are no longer active. Those docs were removed when their decisions were either superseded by the Visual Bible or already captured in current status. Do not reconstruct implementation direction from deleted packet history.

## Routing Rules

Agents start here:

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/visual-bible/README.md`
4. `docs/production/15-failed-visual-validation.md`
5. `docs/design-implementation/README.md`
6. `docs/design-implementation/work-packets/00-packet-index.md`
7. `docs/design-implementation/work-packets/05-hero-art-slice-proof.md`

Authority order:

1. `docs/design-source-of-truth/`: game fantasy, era, scope, and owner decisions.
2. `docs/visual-bible/`: active object-family art direction and MVP asset quality bar.
3. `docs/design-implementation/`: implementation packet rules and next-work assembly.
4. `docs/production/`: current blockers, validation baseline, and review package.
5. `docs/qa/`: evidence procedures only.

If status or validation numbers conflict, `docs/status.json` and `docs/CURRENT_STATE.md` win.

## Source Of Truth

- [Current State](CURRENT_STATE.md): current build, blocker, validation snapshot, and next decision.
- [Status JSON](status.json): machine-readable status contract used by tests.
- [Design Source Of Truth](design-source-of-truth/README.md): design canon and owner-decision authority.
- [Visual Bible](visual-bible/README.md): active object-family visual production bar.
- [Design Implementation Index](design-implementation/README.md): active agent execution entrypoint.
- [Failed Visual Validation](production/15-failed-visual-validation.md): active blocker and hero-slice pivot.

## Design Source Docs

- [Master Design Source Of Truth](design-source-of-truth/00-master-design-source-of-truth.md): core fantasy, non-negotiables, era, product rules, and design pillars.
- [Vertical Slice Specification](design-source-of-truth/01-vertical-slice-spec.md): first validated slice, starter state, day loop, required systems, and out-of-scope boundaries.
- [Store Design And World Building](design-source-of-truth/02-store-design-world-building.md): store personality, layout, density, zones, storytelling, customers, and hidden narrative boundaries.
- [Asset Inventory Roadmap](design-source-of-truth/03-asset-inventory-roadmap.md): implementation phases seeded from the 300-object asset inventory and Visual Bible.
- [Validation And Signoff](design-source-of-truth/04-validation-and-signoff.md): owner review, screenshot checks, and implementation cycle.

## Visual Bible Docs

- [Visual Bible Index](visual-bible/README.md): locked visual reset, target quality, agent usage, and global do/don't rules.
- [Store Shell And Architecture](visual-bible/01-store-shell-architecture.md): mall interior shell, clean drywall, carpet, quiet ceiling, storefront, and fixed structural rules.
- [Fixtures And Displays](visual-bible/02-fixtures-and-displays.md): physical shelves, racks, bins, display cases, capacity rules, and anti-primitive fixture requirements.
- [Product Art And Packaging](visual-bible/03-product-art-and-packaging.md): DVD cases, console boxes, accessory packaging, duplicate stacks, price stickers, and product fidelity.
- [Fictional Platforms And Games](visual-bible/04-fictional-platforms-and-games.md): legal-safe platform/game identity, starter titles, art direction, and naming expectations.
- [Counter Register And Trade-In](visual-bible/05-counter-register-and-trade-in.md): straight counter, combined checkout/trade-in station, POS/scanner detail, and behind-counter emptiness.
- [Stockroom Receiving Office](visual-bible/06-stockroom-receiving-office.md): clean receiving area, office/storage backroom, stockroom racks, and starter delivery state.
- [Signage Marketing And Store Identity](visual-bible/07-signage-marketing-and-store-identity.md): minimal readable signage, grand-opening restraint, editable identity, and poster/marketing rules.
- [Art Production Pipeline](visual-bible/08-art-production-pipeline.md): Blender/asset-pack/texture workflow, mesh quality bar, import expectations, and validation output.
- [MVP Object Implementation Checklist](visual-bible/09-mvp-object-implementation-checklist.md): MVP + first-store object checklist mapped to spreadsheet IDs and validation needs.

## Design Implementation Docs

- [Design Implementation Index](design-implementation/README.md): agent operating rules, packet assembly policy, completion definition, and current next step.
- [Visual Module System Spec](design-implementation/02-visual-module-system-spec.md): retained module/grid/collision rules; superseded by the Visual Bible for visible object quality.
- [Agent Work Packet Template](design-implementation/13-agent-work-packet-template.md): strict implementation packet format.
- [Phase Implementation Roadmap](design-implementation/14-phase-implementation-roadmap.md): current path from Visual Bible packet assembly through validation and owner review.
- [Art Direction Reset And Spike Plan](design-implementation/15-art-direction-reset-and-spike-plan.md): historical block decision and why Packet 09 is reference only.
- [Work Packet Index](design-implementation/work-packets/00-packet-index.md): current Visual Bible packet queue and deleted legacy packet policy.
- [MVP Product Art Kit](design-implementation/work-packets/01-mvp-product-art-kit.md): starter products, cover art, packaging, prices, and legal-safe names.
- [MVP Fixture And Display Kit](design-implementation/work-packets/02-mvp-fixture-display-kit.md): shelves/racks/displays, capacity, and stocking compatibility.
- [Store Shell Counter Backroom Kit](design-implementation/work-packets/03-shell-counter-backroom-kit.md): shell, counter, register/trade-in, stockroom, receiving, and office modules.
- [Playable Store Integration Review](design-implementation/work-packets/04-playable-store-integration-review.md): failed integration evidence and owner review record.
- [Hero Art Slice Proof](design-implementation/work-packets/05-hero-art-slice-proof.md): active next implementation packet.

## Current Production Docs

- [Backlog](production/04-backlog.md): current work queue and stop conditions.
- [Validation](production/06-validation.md): full local gate and artifact policy.
- [Visual Blockers](production/13-visual-blockers.md): current design/visual blockers.
- [Visual Bible Implementation Review](production/14-visual-bible-implementation-review.md): failed object-family review record.
- [Failed Visual Validation](production/15-failed-visual-validation.md): active failed-pass record and hero-slice pivot.

## Current QA

- [QA Index](qa/README.md)
- [Smoke Playtest](qa/smoke-playtest.md)
- [Screenshot Review](qa/screenshot-review.md)
