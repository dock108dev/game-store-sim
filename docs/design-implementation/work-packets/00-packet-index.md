# Work Packet Index

Status: Ready for review
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/14-phase-implementation-roadmap.md`
Dependencies: `docs/design-implementation/13-agent-work-packet-template.md`
Expected commit scope: docs-only implementation packet assembly

## Purpose

This folder is the implementation packet queue for the visual reset.

Agents start here after reading `docs/CURRENT_STATE.md` and `docs/design-implementation/README.md`. Each packet converts the design implementation docs into a concrete, reviewable work unit with scope, likely files, validation, screenshot evidence, and stop conditions.

## Execution Rules

- Complete packets in dependency order unless the packet index says parallel work is safe.
- Commit and push after each completed implementation packet.
- Keep main scene/layout integration lead-owned and sequential.
- Do not treat standalone asset exploration as complete until it is integrated and reviewed in final game-window screenshots.
- Do not broaden into catalog breadth, customer visuals, hidden narrative, later-era content, or beta packaging until packet 08 approves the opening-store baseline.

## Packet Queue

| Order | Packet | Status | Purpose |
| ---: | --- | --- | --- |
| 1 | `01-visual-module-foundation.md` | Not started | Establish reusable materials, modules, anchors, naming, and no-raw-cube visual foundation. |
| 2 | `02-store-shell-mall-entrance-stockroom.md` | Not started | Build the mall approach, storefront, entrance, real stockroom, receiving area, and first-read layout. |
| 3 | `03-fixtures-and-placement-systems.md` | Not started | Build starter fixtures, snap/placement visuals, shelf labels, capacity slots, and empty/stocked states. |
| 4 | `04-checkout-trade-in-and-day-one-setup.md` | Not started | Build the checkout/trade-in counter, queue support, behind-counter intake, and day-one setup tasks. |
| 5 | `05-product-platform-and-price-language.md` | Not started | Build fictional product cases, platform/genre signals, cover art, price/condition stickers, and starter titles. |
| 6 | `06-signage-promotions-and-required-zones.md` | Not started | Build store identity, required signs, posters, shelf labels, and zone readability without debug labels. |
| 7 | `07-lighting-density-and-integration-polish.md` | Not started | Integrate lighting, materials, density, clutter rules, route cleanup, and screenshot composition. |
| 8 | `08-review-package-and-owner-validation.md` | Not started | Package final screenshots, validation, notes, blockers, and owner approve/revise/block path. |

## Dependency Model

Sequential dependencies:

1. Packet 01 must finish before broad store assembly.
2. Packet 02 must finish before fixtures and checkout placement are final.
3. Packet 03 must finish before product placement can be validated.
4. Packet 04 depends on packet 02 layout and packet 03 fixture scale.
5. Packet 05 depends on packet 03 stocking surfaces and packet 04 day-one setup flow.
6. Packet 06 depends on packet 02 storefront/stockroom, packet 03 fixture labels, and packet 05 product language.
7. Packet 07 depends on packets 01-06.
8. Packet 08 depends on packet 07.

Parallel-safe work:

- bitmap cover/poster drafts after packet 05 rules are read
- standalone material tests after packet 01 rules are read
- review-note templates for packet 08
- small prop modules that do not touch the main store scene

Not parallel-safe without a lead merge plan:

- main store scene edits
- store footprint/layout
- stockroom placement
- product/catalog data edits
- validation/status contract edits
- final screenshot/review package

## Lead-Owned Files And Decisions

The lead implementer owns:

- active scene integration
- layout/footprint decisions
- store shell and stockroom relationship
- product catalog data
- `docs/status.json`
- doc status contract tests
- final validation notes
- commit ordering

## Docs To Read Before Any Packet

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `docs/design-implementation/13-agent-work-packet-template.md`
5. `docs/design-implementation/14-phase-implementation-roadmap.md`
6. Current packet
7. Packet-specific dependencies

## Packet Completion Definition

A packet is complete when:

- implementation scope is done
- mechanics touched by the packet still work
- docs/tests/status are updated if behavior changed
- required screenshots exist for implementation work
- focused tests for changed contracts pass
- `scripts/validate_godot.sh` passes for implementation work
- a commit is created and pushed
- residual issues and decisions are logged

Docs-only packet assembly does not require `scripts/validate_godot.sh`.

## Current Next Step

Start packet 01: `01-visual-module-foundation.md`.

Do not begin broad store shell work until packet 01 has established the module/material rules and file structure needed to avoid another raw primitive rebuild.
