# Catalog And Platform Identity Plan

Implementation plan for fictional titles, platforms, suppliers, products, releases, fixtures, and naming rules after the opening-store quality bar.

## Goal

Before deeper day-loop playtesting, make the products feel like a coherent fictional game-store catalog. The catalog should support stocking, pricing, receipts, trade-ins, supplier orders, preorders, launch planning, and fixture/decor decisions without real-world IP leakage.

## Design Intent

The catalog is the texture of the game. It should feel specific enough that players believe the store, but structured enough that tests can protect it.

The catalog should communicate:

- The shop sells a coherent set of fictional platforms.
- Product names are memorable but short enough for tags, receipts, and UI cards.
- Product taxonomy drives gameplay, not just flavor.
- Supplier identities make ordering and delivery feel physical.
- Releases and preorders connect to platform identity.
- Decor and fixture names belong to the same retail world.

## Current Implementation State

Implemented in the current branch:

- `scripts/check_product_catalog.py` validates platform-family mappings, taxonomy vocabularies, service names, short title rules, and platform IP leakage.
- `test_product_catalog.gd` mirrors platform/taxonomy/title rules after loading real Godot resources.
- Starter catalog has 33 products across used games, new games, accessories, hardware, and service tickets.
- Platform families are currently locked to Nova Cube, Orbit 64, Pocket Star, and Service Bench.

This is a foundation, not the full catalog. Future catalog growth must update docs, data, Python checks, and GUT tests together.

## Scope

### In Scope

- Fictional platform families and allowed formats.
- Product title rules.
- Product taxonomy values.
- Product data schema and validation.
- Supplier identity lanes.
- New-release naming and preorder context.
- Fixture/decor naming style.
- Starter-to-full-catalog implementation sequence.

### Out Of Scope

- Real console names, real publisher names, real game titles, or real trade dress.
- Large narrative lore bible.
- Hundreds of products before day-loop playtesting proves need.
- Final cover art generation.
- Procedural title generation without validation.

## Platform Families

Use a small, coherent fictional platform set until the full catalog pass proves the store needs more.

| Family | Platform | Primary use | Allowed formats |
| --- | --- | --- | --- |
| `nova_disc` | Nova Cube | Modern disc shelf, new releases, controllers | `disc`, `accessory`, `controller` |
| `orbit_classic` | Orbit 64 | Retro cartridge shelf and refurb console work | `cartridge`, `accessory`, `console` |
| `pocket_handheld` | Pocket Star | Handheld shelf, portable accessories, boxed handhelds | `cartridge`, `accessory`, `console` |
| `service_bench` | Service Bench | Repair and cleaning tickets | `service_ticket` |

Implementation rules:

- Product `platform_family`, `platform`, and `format` must match this table.
- Platform names must stay fictional and must not use real console/company fragments.
- New platform families require a same-slice update to this doc, `scripts/check_product_catalog.py`, `test_product_catalog.gd`, and relevant product visual rules.

## Title Naming Rules

Product names:

- 28 characters or less.
- No subtitle punctuation such as `:` until a future title-system pass explicitly needs it.
- No `The ...` prefix for starter catalog names.
- No real-world IP fragments.
- Should read as compact genre prompts, not direct parody.

Category style:

- Used/new games: two to three short words with a playable fantasy, such as `Star Trader` or `Neon Skyline`.
- Hardware: platform name plus object state, such as controller, console, handheld, or refurb unit.
- Accessories: platform name plus practical object, such as memory card, cable, pouch.
- Service: plain work-order language.

Allowed service names:

- `Cartridge Cleaning Ticket`
- `Controller Test Ticket`
- `Disc Resurfacing Ticket`

## Product Taxonomy

These values are locked by `scripts/check_product_catalog.py` and `game/tests/gut/test_product_catalog.gd`.

| Field | Allowed values |
| --- | --- |
| `category` | `used_game`, `new_game`, `accessory`, `hardware`, `service` |
| `condition` | `new`, `excellent`, `good`, `fair`, `poor`, `refurbished`, `service` |
| `completeness` | `sealed`, `complete`, `box_only`, `manual_missing`, `loose`, `ticket` |
| `authenticity` | `verified`, `trusted`, `uncertain`, `needs_review` |
| `rarity` | `common`, `uncommon`, `rare`, `collector`, `standard`, `launch` |
| `demand_tier` | `low`, `medium`, `high` |
| `risk_level` | `low`, `medium`, `high` |

Implementation rules:

- Keep authenticity and risk separate. Authenticity is provenance confidence; risk is operational handling pressure.
- Use `risk_tags` only when the product creates a visible store/workflow reason to inspect it.
- `suggested_price_cents` must be positive, no higher than market value, and no lower than cost basis.
- Non-service products should be player-priceable unless a future system explicitly makes them fixed-price.
- Add new taxonomy values only after updating this plan, the Python checker, and GUT tests in the same slice.

## Product Resource Schema

Every product resource should support:

- `product_id`
- `display_name`
- `category`
- `platform`
- `platform_family`
- `condition`
- `completeness`
- `format`
- `authenticity`
- `rarity`
- `demand_tier`
- `cost_basis_cents`
- `market_value_cents`
- `suggested_price_cents`
- `risk_level`
- `risk_tags`
- `default_location_id`
- `player_priceable`

Implementation files:

- `game/data/products/*.tres`
- `game/scripts/inventory/product_definition.gd`
- `game/tests/gut/test_product_catalog.gd`
- `game/tests/gut/test_product_item.gd`
- `scripts/check_product_catalog.py`

## Supplier Identity

Starter supplier:

- `North Dock Wholesale`: used-game starter lot supplier with ordinary retail credibility.

Planned supplier lanes:

| Lane | Purpose | Naming Style | Risk |
| --- | --- | --- | --- |
| Used-game wholesale | Starter and restock used lots | Local/regional business names | Low to medium |
| New-release distributor | Launch allocations and preorder pressure | Clean distributor names | Low |
| Accessory/hardware supplier | Controllers, memory cards, refurb consoles | Practical parts/vendor names | Low to medium |
| Service-parts supplier | Repair and cleaning materials | Workbench/repair-oriented names | Low |
| Gray-market hook | Optional suspicious stock | Plausible but slightly off local names | Medium to high |

Implementation rules:

- Supplier names should read as businesses, not real brands.
- Suspicious supplier language stays optional and secondary.
- Supplier lots must list product resources that pass the catalog checker.
- UI should show supplier purpose and risk without long lore copy.

Implementation files:

- `game/data/suppliers/*.tres`
- `game/scripts/suppliers/supplier_lot.gd`
- `game/scripts/systems/store_session.gd`
- `game/tests/gut/test_supplier_lot.gd`
- `game/tests/gut/test_store_session.gd`

## Release And Preorder Identity

Release products should:

- Belong to a locked platform family.
- Have launch-day rarity where appropriate.
- Use names that look like featured titles, not real-game parodies.
- Support release calendar, preorder deposit, allocation, launch result, and shortage/reputation flow.

Implementation files:

- `game/data/releases/*.tres`
- `game/data/products/new_*.tres`
- `game/scripts/systems/store_session.gd`
- `game/tests/gut/test_new_release.gd`
- `game/tests/gut/test_store_session.gd`

## Fixture And Decor Naming Style

Fixture and decor names should sound like retail objects:

- `Game Display Rack`
- `Accessory Peg Wall`
- `New Release Wall`
- `Counter Rack`
- `Backroom Rack`
- `Locked Case`

Future decor names should follow the same plain retail style:

- Wall/floor material names describe visible finish.
- Lighting package names describe mood or utility.
- Poster/display names stay fictional and platform-aligned.
- Upgrade names describe business effect before flavor.

Implementation files:

- `game/data/fixtures/*.tres`
- future `game/data/decorations/*.tres`
- `game/scripts/store_layout/fixture_definition.gd`
- `game/tests/gut/test_fixture_catalog.gd`

## Full First-Catalog Pass

Target shape before long-form multi-day playtesting:

- At least 60 products total.
- At least 36 used games.
- At least 9 new releases.
- At least 9 accessories/hardware items.
- At least 3 service tickets.
- At least 4 supplier lots.
- Platform spread across Nova Cube, Orbit 64, and Pocket Star.
- Demand spread across low, medium, and high.
- Risk spread across low, medium, and high.

Batch sequence:

1. Expand used titles by platform and demand tier.
2. Add new releases with launch calendar coverage.
3. Add accessories and hardware that support visible shelf/peg/counter zones.
4. Add supplier lots that deliver coherent batches.
5. Add receipt/tag/readability review for long names and platform strings.
6. Run three-day playtest to check repetition, pricing, and stocking feel.

## File Impact Matrix

| File | Role | Change Type |
| --- | --- | --- |
| `game/data/products/*.tres` | Product resources | Primary implementation |
| `game/data/releases/*.tres` | New-release calendar resources | Primary implementation |
| `game/data/suppliers/*.tres` | Supplier lots | Primary implementation |
| `game/data/fixtures/*.tres` | Fixture catalog naming | Secondary implementation |
| `game/scripts/inventory/product_definition.gd` | Product schema | Behavior/data contract |
| `game/scripts/suppliers/supplier_lot.gd` | Supplier lot schema | Behavior/data contract |
| `game/scripts/systems/store_session.gd` | Catalog usage across economy and UI | Integration contract |
| `scripts/check_product_catalog.py` | Python catalog gate | Required with catalog expansion |
| `game/tests/gut/test_product_catalog.gd` | Godot resource catalog tests | Required |
| `game/tests/gut/test_product_visual_rules.gd` | Visual profile rules | Required if formats/categories change |

## Screenshot Acceptance

Catalog language appears in:

- `stocked_aisle.png`
- `register_counter.png`
- `trade_in_offer.png`
- `preorder_deposit.png`
- `release_calendar.png`
- `release_allocation.png`
- `launch_day.png`
- `supplier_delivery.png`
- `catalog_design_cues.png`

Pass criteria:

- Product/platform strings are fictional and coherent.
- Names fit visible tags, receipts, and UI cards.
- Platform names read as one shared world.
- Supplier/release copy is short and practical.
- Risk/condition language is clear without becoming lore-heavy.

Fail criteria:

- Any real IP fragment appears.
- Names are clipped or too long in tags/receipts.
- Products feel like random jokes rather than store inventory.
- Supplier or risk language implies a mandatory hidden-story route.

## Automated Validation

Required:

```text
python3 scripts/check_product_catalog.py
scripts/validate_godot.sh
```

Relevant GUT surfaces:

- `test_product_catalog.gd`
- `test_product_item.gd`
- `test_product_visual_rules.gd`
- `test_supplier_lot.gd`
- `test_new_release.gd`
- `test_store_session.gd`
- `test_register_checkout_ui.gd`

## Manual Review

Review:

1. Product names in shelf/tag screenshots.
2. Receipt and checkout line names.
3. Trade-in condition/risk names.
4. Supplier lot names and delivery context.
5. Release calendar and launch result names.
6. Fixture/decor names in management UI.

Failures should be filed in `docs/production/13-alpha-bug-list.md` with the exact string, surface, and replacement requirement.

## Risks

- Catalog expansion can create UI clipping before it creates gameplay value.
- Real-world platform parody can slip in through "obvious" retro naming.
- Risk/authenticity tags can confuse normal retail flow if they read as required story objectives.
- Supplier lots can become economy balance changes, not just content changes.
- More products can make multi-day play feel repetitive unless demand and platform spread are intentional.

## Completion Criteria

This plan is complete when:

- Platform families and taxonomy are documented and enforced.
- Starter catalog passes Python and GUT validation.
- Full-catalog target shape is explicit.
- Future product additions have file/test/screenshot requirements.
- Full validation passes after catalog changes.
- Owner review approves that current catalog language supports the opening-store quality bar.
