# Work Packet: Product Platform And Price Language

Status: Complete
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/07-product-and-platform-visual-language-spec.md`
Dependencies: `docs/design-implementation/05-fixture-grid-slice.md`, `docs/design-implementation/08-required-zones-slice.md`, `docs/design-implementation/10-signage-branding-and-store-identity-spec.md`, `docs/design-implementation/work-packets/03-fixtures-and-placement-systems.md`, `docs/design-implementation/work-packets/04-checkout-trade-in-and-day-one-setup.md`
Expected commit scope: fictional product case language, starter titles, platform/genre signals, price/condition stickers, and visible stocked products

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `docs/design-implementation/work-packets/00-packet-index.md`
5. `docs/design-implementation/07-product-and-platform-visual-language-spec.md`
6. `docs/design-implementation/05-fixture-grid-slice.md`
7. `docs/design-implementation/08-required-zones-slice.md`
8. `docs/design-implementation/10-signage-branding-and-store-identity-spec.md`

## Context

- Current problem: products must stop reading as colored blocks or labels and start reading as legal-safe game cases, console boxes, and accessory packaging.
- Target player-facing result: a shelf with two day-one games, one console, and one accessory reads as a real early-2000s game-store product set with platform, genre, condition, and price cues.
- Existing systems that must keep working: catalog data, inventory source, receiving, stocking, pricing, trade-ins, used/new conditions, save/load.
- Visual/design docs that define success: product/platform spec, fixture grid, required zones, signage identity.
- Known prior failures to avoid: real-world brand mimicry, label-only identity, products too tiny to read, future inventory physically staged, used/new indistinguishable.

## In Scope

- Case/box visual language for Nova, Vertex, Prism, and Pocket.
- Two-tone product signal: platform plus genre.
- Starter products including `Footy 2002` and one anchor franchise placeholder.
- New/used visual variants with used sticker/condition cue.
- Case price stickers such as `New $49.99` or `Used $5.99`.
- Starter console box and accessory packaging.
- Product visuals placed on fixtures from packet 03.
- Basic cover art shapes/bitmap-style panels that avoid legal/trade-dress risk.

## Out Of Scope

- Full 300-object catalog art.
- Real brand references.
- Advanced rarity/collector grading.
- Broad used inventory generation beyond trade-ins/bulk used systems already planned.
- Future platform era visuals.
- Customer browsing changes.

## Do Not Do

- Do not use real console, game, publisher, or retailer trade dress.
- Do not make products readable only through floating labels.
- Do not put locked/future inventory physically in the store.
- Do not create fixed store categories that prevent player organization.
- Do not use repeated boxes for all small media if cases can show as cases.
- Do not hide price/condition information in UI only when the case should carry it.
- Do not break catalog, pricing, stocking, or trade-in systems.

## Implementation Plan

1. Inspect product catalog, product visual spawning, stocking, and pricing systems.
2. Identify where visual style data belongs without duplicating catalog truth.
3. Implement case/box materials and simple cover panels.
4. Implement platform/genre color mapping.
5. Implement price and condition sticker visuals.
6. Add starter title/product visuals and map them to day-one stock.
7. Integrate visible products with fixture slots.
8. Capture product closeups and stocked shelf screenshots.
9. Run focused catalog/stocking/pricing/trade-in tests and full validation.
10. Commit and push.

## Likely Files

Scenes:
- product/case scenes
- fixture stocked-state scenes
- active store scene if starter stock positions are placed

Scripts:
- product visual factory/scripts
- catalog/product data scripts
- pricing/condition scripts
- stocking scripts

Assets:
- case materials
- cover panels/bitmap textures
- price sticker textures/materials
- platform/genre color resources

Data:
- product catalog
- platform/genre metadata
- starter stock data

Tests:
- catalog validation
- product visual mapping tests
- pricing/condition tests
- stocking tests

Docs:
- `docs/design-implementation/07-product-and-platform-visual-language-spec.md`
- `docs/design-implementation/08-required-zones-slice.md`
- `docs/production/13-alpha-bug-list.md` if blockers change

## Validation Required

Implementation packet:

- Capture final game-window screenshots first.
- Review screenshots for product readability, platform/genre signal, price/condition sticker readability, and legal-safe distinctiveness.
- Run focused catalog/product/pricing/stocking tests.
- Run `scripts/validate_godot.sh`.
- Confirm artifacts under `artifacts/validation/latest/`.

## Screenshot Evidence

Required final screenshots:

- closeup of starter game case front
- closeup showing platform/genre two-tone signal
- used case with used sticker and used price
- new case with new price
- starter console box/accessory package
- stocked fixture shelf from normal player distance

## Tests To Add Or Update

- Product data tests for platform/genre/condition mappings.
- Catalog tests if starter products or visual metadata changes.
- Pricing tests if visible price stickers read from product price data.
- Stocking tests if product scene spawning changes.

## Tests To Run

- focused catalog tests
- focused pricing/condition tests
- focused stocking tests
- `scripts/validate_godot.sh`

## Documentation Updates

- Update product visual spec if platform/genre color mapping or starter titles change.
- Update status only if catalog counts or validation metadata change after running validation.
- Log legal-safe naming and visual assumptions.

## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
| Starter product set stays small. | Owner wants day one to start with two games, one console, and one accessory, then unlock more. | No | Expansion comes after opening baseline approval. |
| `Footy 2002` and `Aether Quest` are working implementation names, not cleared ship names. | The owner approved using working names for planning/implementation, but legal/name clearance is still a later review step. | No | Keep name-clearance review before final ship packaging. |
| Platform naming preserves current code schema. | Current data and tests use `Nova Cube`, `Orbit 64`, `Pocket Star`, and `Service Bench`; renaming to the broader planning labels would be a larger taxonomy migration. | No | Later taxonomy pass can align display aliases if needed. |

## Stop Conditions

- Product visuals risk real-world brand/trade-dress confusion.
- Products still read as blocks after case/cover pass.
- Platform/genre signals cannot coexist legibly.
- Catalog/pricing/stocking systems would need core redesign.
- Validation exposes a blocker.

## Continue Conditions

- Starter products read as cases/boxes from player distance.
- New/used/price cues are visible.
- Fixture stocking surfaces can show products clearly.
- Signage/required-zone packet can use product language without rework.

## Final Handoff Requirements

- Commit hash
- Branch
- Screenshot/contact-sheet paths
- Validation command/result
- Starter product names and visual mappings
- Known residual issues
- Owner/lead decisions needed

## Completion Notes

Completed implementation:

- Added `franchise_id` and `genre_id` product metadata with safe inference for existing catalog entries.
- Added day-one starter product definitions for `Footy 2002` and `Aether Quest`.
- Added data-driven platform and genre color rules to `ProductVisualRules`.
- Updated `ProductItem` so case body, cover panel, platform band, genre accent, cover-detail marks, used sticker, title, and case price label render from product data.
- Updated the authored day-one display cases in `store_world.tscn` so the starter sports/RPG cases have physical title and price cues.
- Preserved catalog, pricing, stocking, trade-in, receiving, and sale mechanics.
- Added coverage for starter catalog metadata, platform/genre color separation, new/used sticker behavior, case price labels, and day-one display labels.

Validation evidence:

- Focused/full GUT command: `"$GODOT_BIN" --headless --path game --script res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit`
- Result before full gate: 578/578 tests passed, 11582 asserts.
- Full production gate passed with regenerated screenshot artifacts before commit.

Residual issues:

- Cover art is still code-authored blockout geometry, not final bitmap cover art.
- The starter product names are implementation placeholders pending name/legal review.
- The broader store still contains several sign/label surfaces that packet 06 must convert from utility labels into believable retail signage.
