# Catalog And Platform Identity Plan

Implementation plan for the fictional titles, platforms, suppliers, and product rules that should follow the opening-store quality bar.

## Goal

Before deeper day-loop playtesting, make the products feel like a coherent fictional game-store catalog.

## Build Tasks

1. Platform families.
   - Home console family.
   - Handheld family.
   - Retro family.
   - Accessory ecosystem.
   - Service-compatible media formats.

2. Product title rules.
   - Fictional, memorable, non-IP names.
   - Clear genre/category signal.
   - Short enough for tags and receipts.
   - Distinct new/used/hardware/accessory/service naming.

3. Product taxonomy.
   - Category.
   - Platform.
   - Format.
   - Condition.
   - Completeness.
   - Authenticity/risk.
   - Demand tier.
   - Rarity.

4. Supplier identity.
   - Starter used lot supplier.
   - New-release distributor.
   - Accessory/hardware supplier.
   - Service-parts supplier.
   - Suspicious/gray-market supplier hook.

5. Full first-catalog pass.
   - Enough used titles for several days.
   - Enough new releases for launch planning.
   - Starter accessories and hardware.
   - Service SKUs.
   - Decor/fixture catalog names aligned with store brand.

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
