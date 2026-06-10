# Catalog And Platform Identity Plan

Implementation plan for the fictional titles, platforms, suppliers, and product rules that should follow the opening-store quality bar.

## Goal

Before deeper day-loop playtesting, make the products feel like a coherent fictional game-store catalog.

## Platform Families

Use a small, coherent fictional platform set until the full catalog pass proves the store needs more.

| Family | Platform | Primary use | Allowed formats |
| --- | --- | --- | --- |
| `nova_disc` | Nova Cube | Modern disc shelf, new releases, controllers | `disc`, `accessory`, `controller` |
| `orbit_classic` | Orbit 64 | Retro cartridge shelf and refurb console work | `cartridge`, `accessory`, `console` |
| `pocket_handheld` | Pocket Star | Handheld shelf, portable accessories, boxed handhelds | `cartridge`, `accessory`, `console` |
| `service_bench` | Service Bench | Repair and cleaning tickets | `service_ticket` |

Implementation rule:

- Product `platform_family`, `platform`, and `format` must match this table.
- Platform names must stay fictional and must not use real console/company fragments.

## Title Naming Rules

- Product names are short shelf-tag titles: 28 characters or less.
- Avoid subtitle punctuation such as `:` until a later full-catalog naming pass needs it.
- Avoid `The ...` prefixes so tags and receipt rows scan quickly.
- Used/new game titles should feel like compact genre prompts, not parody of real IP.
- Hardware and accessories may use the platform name plus a retail object.
- Service names must stay plain work-order names: `Cartridge Cleaning Ticket`, `Controller Test Ticket`, `Disc Resurfacing Ticket`.

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

Implementation rule:

- Keep authenticity and risk separate. Authenticity is provenance confidence; risk is operational handling pressure.
- Use `risk_tags` only when the product creates a visible store/workflow reason to inspect it.
- Add new taxonomy values only after updating this plan, the Python checker, and the GUT tests in the same slice.

## Supplier Identity

Starter supplier identity currently anchors the opening loop:

- `North Dock Wholesale`: used-game starter lot supplier with ordinary retail credibility.

Planned supplier lanes:

- New-release distributor: clean launch-day allocations, preorder pressure, low risk.
- Accessory/hardware supplier: fixtures, controllers, memory cards, refurb stock.
- Service-parts supplier: repair supplies and tickets, low shelf presence.
- Gray-market hook: optional suspicious stock, never required for normal retail progression.

Implementation rule:

- Supplier names should read as local/regional businesses, not real brands.
- Suspicious supplier language stays secondary and optional.

## Full First-Catalog Pass

- Expand used titles enough for repeated stocking over several days.
- Add more new releases with launch timing, platform spread, and preorder appeal.
- Add starter accessories and hardware that make sense for the three platform families.
- Add service SKUs only when they connect to visible service bench work.
- Align decor and fixture names with the shop brand and physical store zones.

## Implemented Evidence

- `scripts/check_product_catalog.py` now validates platform-family mappings, taxonomy vocabularies, service names, short title rules, and platform IP leakage.
- `test_product_catalog.gd` mirrors the same platform/taxonomy/title rules after loading real Godot resources.
- Existing starter catalog remains at 33 products across used games, new games, accessories, hardware, and service tickets.

## Files To Expect

- `game/data/products/*.tres`
- `game/data/releases/*.tres`
- `game/data/suppliers/*.tres`
- `game/data/fixtures/*.tres`
- `game/scripts/inventory/product_definition.gd`
- `game/scripts/suppliers/supplier_lot.gd`
- `scripts/check_product_catalog.py`
- `game/tests/gut/test_product_catalog.gd`
- `game/tests/gut/test_product_visual_rules.gd`

## Acceptance

- Product names and platform names feel like one fictional retail world.
- No real-world IP, real console names, or trade dress.
- Catalog has enough depth for early multi-day play.
- Product tags, receipts, pricing panel, supplier UI, and release calendar all remain readable.

## Test

- Run product catalog tests.
- Run `python3 scripts/check_product_catalog.py`.
- Run `scripts/validate_godot.sh`.
- Play at least three in-game days after the quality-bar visuals pass.
