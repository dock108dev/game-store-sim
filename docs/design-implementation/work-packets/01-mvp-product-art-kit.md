# Work Packet: MVP Product Art Kit

Status: Ready for owner review
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/visual-bible/03-product-art-and-packaging.md`
Dependencies: `docs/visual-bible/04-fictional-platforms-and-games.md`, `docs/visual-bible/09-mvp-object-implementation-checklist.md`
Expected commit scope: starter product art, packaging, legal-safe platform/game language, product tests, and product screenshot/review notes

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/visual-bible/README.md`
4. `docs/visual-bible/03-product-art-and-packaging.md`
5. `docs/visual-bible/04-fictional-platforms-and-games.md`
6. `docs/visual-bible/09-mvp-object-implementation-checklist.md`
7. `docs/design-implementation/13-agent-work-packet-template.md`

## Context

- Current problem: product cases, console boxes, and accessory packaging are not yet strong enough to carry the store fantasy at first-person distance.
- Target player-facing result: the player can look at day-one merchandise and immediately read game cases, cover art, platform/genre signals, price stickers, and console/accessory packaging without relying on debug labels.
- Existing systems that must keep working: product catalog loading, product item scene generation, pricing, stocking, receiving, register sales, and catalog validation.
- Visual/design docs that define success: product art bible, fictional platforms/games bible, MVP checklist.
- Known prior failures to avoid: colored blocks, rejected starter names, legally risky parody, unreadable tiny text, day-one overstocking.

## In Scope

- Starter DVD-style game case visual language.
- `Footy 2002` starter cover direction.
- One legal-safe sequel-ready adventure/RPG starter title.
- Starter console packaging.
- Starter accessory/controller packaging.
- Platform/genre color language.
- New/used/price sticker language.
- Duplicate stack visual language.
- Product tests and catalog checks.

## Out Of Scope

- Full 300-object catalog art.
- Real brand/game references.
- Broad customer, employee, decoration, hidden narrative, or later-era visuals.
- Store shell/fixture/counter/backroom modeling.

## Acceptance Checklist

- [x] Product close-up reads as game merchandise before labels.
- [x] Starter game cover art is recognizable at first-person distance.
- [x] Console/accessory packages read as boxed retail products.
- [x] Day-one inventory stays limited.
- [x] Catalog validation stays green.
- [x] Focused product tests pass.
- [x] Full validation runs before completion if game assets/scenes changed.

## Implementation Evidence

- Added `res://scripts/inventory/product_day_one_set.gd` and `res://scenes/world/kits/products/product_day_one_set.tscn`.
- Replaced old starter product resources with the Vortex starter console/controller/accessory set and `Critter Quest II`.
- Expanded product visual rules for DVD cases, cover panels, spines, platform/genre bands, price stickers, hardware boxes, accessory packs, and starter stacks.
- Updated product catalog and product visual tests.
- Review screenshot: `artifacts/validation/latest/screenshots/product_closeup.png`.

## Validation

Latest full gate:

```text
scripts/validate_godot.sh
```

Result: passed with 592 GUT tests, 12263 asserts, 55/55 production script mappings, and 62 catalog products.

Owner visual signoff is still required before treating this as art-approved.

## Stop Conditions

- A name or cover concept risks real-world trademark/copyright confusion.
- Product visuals require changing core inventory mechanics.
- Product work needs fixture/store integration before it can be validated.
