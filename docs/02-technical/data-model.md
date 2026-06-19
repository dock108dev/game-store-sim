# Data Model

This document defines the first-pass data model. Field names are provisional but should guide implementation.

## Platform Definition

```json
{
  "platform_id": "foxbox",
  "display_name": "FoxBox",
  "generation_band": "opening_era",
  "fictional": true
}
```

## Product Definition

A product is the catalog identity. It is not a physical copy.

```json
{
  "product_id": "sky_cart_rally",
  "display_name": "Sky Cart Rally",
  "platform_id": "foxbox",
  "category": "game_case",
  "release_state": "used_catalog",
  "base_market_value": 24.99,
  "new_fixed_price": null,
  "fictional_publisher": "Northstar Byteworks",
  "tags": ["racing", "family_safe", "opening_era"]
}
```

## Item Instance

An item instance is a physical stock item.

```json
{
  "item_id": "item_000001",
  "product_id": "sky_cart_rally",
  "condition": "good",
  "new_or_used": "used",
  "cost_basis": 8.00,
  "current_price": 19.99,
  "suggested_price_min": 17.99,
  "suggested_price_max": 22.99,
  "fixed_price_until_day": null,
  "location": {
    "type": "fixture_slot",
    "fixture_id": "used_wall_shelf_01",
    "slot_id": "slot_03"
  },
  "provenance_state": "normal",
  "is_sellable": true,
  "is_sold": false
}
```

## Fixture Definition

```json
{
  "fixture_type_id": "wall_game_shelf",
  "display_name": "Wall Game Shelf",
  "accepted_categories": ["game_case"],
  "slot_count": 24,
  "browse_point_count": 2,
  "movable": true
}
```

## Fixture Instance

```json
{
  "fixture_id": "used_wall_shelf_01",
  "fixture_type_id": "wall_game_shelf",
  "position": [4.0, 0.0, -2.0],
  "rotation_degrees": [0.0, 90.0, 0.0],
  "slots": {
    "slot_01": "item_000001",
    "slot_02": null
  }
}
```

## Shipment

```json
{
  "shipment_id": "starter_shipment_day_0",
  "supplier_id": "starter_supplier",
  "arrival_day": 0,
  "state": "in_receiving",
  "item_ids": ["item_000001", "item_000002"],
  "invoice_note": "Starter lease opening stock.",
  "odd_detail_id": "starter_manifest_typo"
}
```

## Customer Archetype

```json
{
  "archetype_id": "browser",
  "display_name": "Browser",
  "base_patience_seconds": 90,
  "entry_weight": 1.0,
  "buy_probability_modifier": 0.5,
  "price_sensitivity": 0.8
}
```

## Customer Instance

```json
{
  "customer_id": "customer_0001",
  "archetype_id": "browser",
  "state": "browsing",
  "target_product_id": null,
  "target_category": "game_case",
  "selected_item_id": null,
  "patience_remaining": 74.5
}
```

## Transaction

```json
{
  "transaction_id": "txn_0001",
  "day": 1,
  "type": "sale",
  "customer_id": "customer_0001",
  "item_ids": ["item_000001"],
  "gross_revenue": 19.99,
  "cost_basis": 8.00,
  "gross_margin": 11.99
}
```

## Save Game

```json
{
  "save_version": 1,
  "day": 1,
  "phase": "prep",
  "cash": 550.00,
  "items": {},
  "fixtures": {},
  "shipments": {},
  "transactions": [],
  "event_log": []
}
```

## Data Rule

Simulation state must never depend only on visuals.

The visible case on a shelf is the representation of an item instance. The item instance is the source of truth.

