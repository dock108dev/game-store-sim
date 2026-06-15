# Screenshot Review

This is the current visual approval gate.

The question is not whether the project is mechanically complete. The question is whether the opening route reads as a simple authored game shop instead of a collection of cubes with labels.

## Generate

Run:

```text
scripts/validate_godot.sh
```

Screenshots are written to `artifacts/validation/latest/screenshots/`.

Contact sheet:

```text
artifacts/validation/latest/screenshot-contact-sheet.png
```

## Primary Review Targets

- `main_scene.png`
- `storefront_entry.png`
- `register_counter.png`
- `receiving_area.png`
- `backroom_summary.png`

## Pass Criteria

Pass only if:

- the first view reads as a game shop before labels
- storefront identity comes from facade, glass, trim, sign housing, and mall context
- register/counter reads from silhouette, equipment, material, and grouped props
- shelf/product identity comes from rows, cases, boxes, stickers, posters, and fixture design
- receiving reads as staged workflow, not dumped blocks
- backroom threshold reads as staff architecture, not a line or sign
- large explanatory labels are gone from the visual read
- flat gray walls/floors/ceilings no longer dominate the route
- the 1280x720 real-window walk-in does not expose stale cube-heavy angles

## Fail Criteria

Fail if:

- the scene still reads as raw CSG/cube geometry
- text labels are required to understand primary objects
- props look like scattered rectangles
- product/fixture identity is not readable before labels
- the route still feels like a debug blockout
- a visual module blocks movement or interaction

## Routing

If the review fails, keep work inside the art-language rebuild. Do not expand catalog, customer, decoration, or external-playtest work.
