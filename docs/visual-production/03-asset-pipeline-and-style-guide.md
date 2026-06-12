# Asset Pipeline And Style Guide

## Goal

Move visual production from CSG placeholder construction to reusable authored assets while preserving gameplay validation.

## Asset Strategy

Use a modular kit:

- Store shell kit: walls, trim, door/window frames, ceiling tiles, floor strips.
- Fixture kit: wall shelves, gondolas, bins, pegboards, glass case, counter modules.
- Product kit: cases, boxes, cartridges, sleeves, tags, stickers.
- Prop kit: register equipment, office items, receiving items, service bench items.
- Customer kit: body silhouettes and role props.

CSG may remain for collision, route blockers, and early layout prototypes. It should not be the long-term visual source.

## File Organization

Recommended future structure:

```text
game/assets/visual/
game/assets/visual/materials/
game/assets/visual/meshes/store_shell/
game/assets/visual/meshes/fixtures/
game/assets/visual/meshes/products/
game/assets/visual/meshes/props/
game/assets/visual/textures/trim/
game/assets/visual/textures/posters/
game/scenes/visual_slices/
```

## Naming

Use direct retail names:

- `shelf_wall_used_games.glb`
- `counter_register_module.glb`
- `product_case_dvd_a.glb`
- `prop_receipt_printer.glb`
- `poster_launch_neon_skyline.png`

Avoid real-world brand fragments in filenames.

## Scale

Keep scale grounded:

- Door: about 2.1m tall.
- Counter: about 0.95m high.
- Wall shelf: products readable at standing eye height.
- DVD case: visible as a case shape in first person, not a tiny plane.
- Customer props: readable from 1.5-3m without becoming billboards.

## Materials

Use a limited material set:

- Painted drywall.
- Scuffed laminate/carpet.
- Powder-coated metal shelf.
- Plastic game cases.
- Paper posters/signage.
- Cardboard boxes.
- Glass/acrylic case.
- Rubber floor mats.
- Cheap counter laminate.

Every material should have a gameplay-safe contrast profile. Prompts and UI cannot disappear against it.

## Collision Separation

Visual meshes and collision must be separate:

- Visual mesh can be detailed.
- Collision should stay simple.
- Interactable target nodes should stay stable.
- Route/path blockers should be validated independently from decorative props.

## Import Rules

Future imported assets should define:

- Source file.
- Godot imported scene path.
- Collision strategy.
- Material ownership.
- Screenshot target.
- Tests or manual QA checks.

No production asset is complete until it appears in a visual slice screenshot and passes the QA checklist.
