# Art Production Pipeline

Status: Active visual bible
Scope: MVP + first-store asset production method

## Purpose

The owner feedback is clear: the game is still around 4.5/10 visually because too much of the store reads as primitive geometry. The next implementation work must change asset production, not just place more shapes.

## Production Standard

Close-camera visible objects should be built as authored assets:

- Blender-authored meshes are expected.
- Legally safe third-party low-poly/stylized asset packs are allowed.
- Godot procedural generation is acceptable for hidden collision, layout helpers, distant/simple shells, or generated texture variants.
- Godot primitives are not acceptable as final-facing MVP fixtures/products/counters when they read as primitives.

## Asset Sources

Allowed:

- custom Blender models
- custom bitmap textures/atlases
- generated legal-safe bitmap cover art/signs
- licensed low-poly retail/mall/office/prop packs
- kitbashed assets when license allows modification/use

Required:

- track source/license for third-party packs
- avoid real IP, real logos, real platform marks, real rating icons, and real game art
- keep visual scale and style consistent

## Asset Quality Bar

Tier A MVP objects need:

- authored silhouette
- bevels or rounded edges where physically expected
- material breaks
- UV/texture support
- player-distance readability
- stocked/empty state support if inventory-facing
- collision shape separate from visual mesh where needed
- validation screenshot

Tier B support objects need:

- readable silhouette
- at least one material/texture cue
- correct scale
- no debug-label dependency

Tier C background objects can be simpler:

- quiet ceiling panels
- distant mall fixtures
- non-interactive trim
- background wall panels

## Texture/Bitmap Rules

Use bitmap/atlas detail for:

- game cover art
- console box fronts/sides
- accessory packaging
- store signage
- posters
- price stickers
- fictional rating/genre/platform/store icons
- carpet/floor/wall subtle material variation

Do not build cover art from many tiny 3D rectangles.

## Godot Integration Rules

Imported assets should expose stable anchors:

- placement anchor
- collision root
- stocked item anchors/slots where relevant
- optional material override hooks
- screenshot-friendly node names for tests

Future agents should preserve existing mechanics:

- carrying
- stocking
- receiving
- pricing
- register/trade-in
- fixture placement
- save/load

Visual assets may replace current primitive modules as long as interaction contracts stay intact.

## Implementation Order

Recommended logical order:

1. MVP product art kit: starter DVD cases, starter console box, starter accessory package.
2. MVP fixture kit: starter shelf/rack/display that holds 10-30 products and shows empty capacity.
3. Store shell pass: drywall/carpet/ceiling/storefront as authored mall interior.
4. Counter/register/trade-in pass: straight counter and POS cluster.
5. Stockroom/receiving/office pass: receiving boxes, racks, office desk/computer/calendar.
6. Signage/store identity pass: readable `Games4U`, grand-opening sign, minimal day-one signs.
7. Integration pass: replace primitive store visuals while preserving mechanics.
8. Validation pass: screenshots plus full regression gate.

This order prioritizes the objects that currently make the scene look primitive.

## Validation

Validation must include:

- family-specific screenshots
- normal player-height shots
- close shots for Tier A objects
- final review board
- full `scripts/validate_godot.sh` after integration

Do not use a passing validation gate as art approval. The gate proves the build is mechanically healthy; owner review proves the visual direction.

## Stop Conditions

Stop and ask if:

- a desired object cannot be made legal-safe without owner naming/art direction
- a third-party asset license is unclear
- a visual replacement would break core mechanics
- target quality cannot plausibly reach 7.5/10 with the current production method
