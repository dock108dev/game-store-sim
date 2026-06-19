# Visual Bible Index

Status: Active
Source inventory: `docs/design-implementation/game_store_sim_300_object_asset_inventory.xlsx`
Scope: MVP + first-store visual rebuild
Target quality: 7.5/10 owner visual read before beta/playtest expansion

## Purpose

This folder is the visual production bible for the reset after Packet 09. The previous implementation docs proved mechanics and some layout direction, but the owner review still reads the store as too primitive. These docs replace vague object descriptions like "shelf," "box," or "poster" with family-level art rules and implementation recipes.

The goal is not to document every one of the 300 inventory rows in full immediately. The goal is to define the MVP + first-store object families strongly enough that agents can build a store that reads as a real, clean, open, early/mid-2000s video game shop instead of a collection of cubes, rods, and labels.

## Authority

If this folder conflicts with older graybox or Packet 01-09 visual assumptions, this folder wins for future art implementation.

If this folder conflicts with core gameplay mechanics, preserve the mechanics and raise the visual/design conflict.

## Locked Direction

- Use Markdown docs as the source of truth for art direction.
- Cover MVP + first-store assets first; do not detail all 300 rows before implementation.
- Target owner visual score is 7.5/10 before broad playtest/beta expansion.
- Blender-authored meshes are expected for close-camera objects.
- Legally safe third-party low-poly/stylized asset packs are allowed when they match the art direction.
- Runtime can remain Godot; the issue is current asset production quality, not proven engine failure.
- Push more polished stylized indie rather than strict PS2 nostalgia.
- Interior mall store baseline: clean, open, new, carpeted, and understocked but promising.
- Walls are mostly drywall; product should live on physical shelves, racks, counters, bins, and displays, not wall-hook spam.
- Product fixtures should commonly hold 10-30 items and show visible empty capacity.
- Day-one state is pre-open starter setup with enough goods for only a handful of sales.
- Main game packaging is DVD-case language; handheld goods may use carts/smaller boxes.
- Product art must be recognizable in first person without relying on floating labels.
- `Games4U` remains the default store name, but store identity must be editable later.

## Required Bible Docs

| Doc | Purpose |
| --- | --- |
| `01-store-shell-architecture.md` | Mall interior shell, clean drywall, carpet, ceiling, storefront, and fixed structural rules. |
| `02-fixtures-and-displays.md` | Physical shelves, racks, bins, display cases, capacity rules, empty-slot readability, and no primitive shelf shortcuts. |
| `03-product-art-and-packaging.md` | Game cases, console boxes, accessory boxes, duplicate stacks, price stickers, and product fidelity. |
| `04-fictional-platforms-and-games.md` | Legal-safe platform/game identity, starter titles, art direction, and naming expectations. |
| `05-counter-register-and-trade-in.md` | Straight counter, combined checkout/trade-in station, register/scanner detail, and behind-counter emptiness. |
| `06-stockroom-receiving-office.md` | Clean receiving area, office/storage backroom, stockroom racks, and starter delivery state. |
| `07-signage-marketing-and-store-identity.md` | Minimal readable signage, grand-opening restraint, editable identity, and poster/marketing rules. |
| `08-art-production-pipeline.md` | Blender/asset-pack/texture workflow, mesh quality bar, import expectations, and validation output. |
| `09-mvp-object-implementation-checklist.md` | MVP + first-store object checklist mapped to spreadsheet IDs and validation needs. |

## How Agents Should Use This Folder

1. Read `docs/CURRENT_STATE.md`.
2. Read this index.
3. Read the object-family doc for the slice being implemented.
4. Read `09-mvp-object-implementation-checklist.md` for IDs and acceptance rules.
5. Build assets from the family bible first, not from old graybox object shapes.
6. Update screenshots and validation docs when the visual target changes.

## Global Do/Don't Rules

Do:

- Use authored silhouettes, bevels, material breaks, and bitmap/atlas detail.
- Use physical store objects that can plausibly hold inventory.
- Keep the first store clean, open, new, and promising.
- Use legal-safe fictional brands and games.
- Make player-placeable/configurable the default for inventory/fixture-origin objects.
- Let cover art, shape, material, and arrangement communicate the object before labels.

Do not:

- Build final-facing fixtures as rectangles with four lines attached.
- Use wall hooks/pegs as the main product system for games.
- Substitute random text labels for art direction.
- Fill the day-one store with future inventory.
- Overdecorate walls before the store has real inventory.
- Treat validation scripts or contact sheets as art approval by themselves.
