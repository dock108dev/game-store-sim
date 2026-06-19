# Work Packet: MVP Fixture And Display Kit

Status: Visually rejected as baseline
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/visual-bible/02-fixtures-and-displays.md`
Dependencies: `docs/visual-bible/09-mvp-object-implementation-checklist.md`, `docs/design-implementation/02-visual-module-system-spec.md`
Expected commit scope: starter shelf/rack/display assets, visible capacity, stocking compatibility, fixture tests, and fixture screenshot/review notes

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/visual-bible/README.md`
4. `docs/visual-bible/02-fixtures-and-displays.md`
5. `docs/visual-bible/09-mvp-object-implementation-checklist.md`
6. `docs/design-implementation/02-visual-module-system-spec.md`
7. `docs/design-implementation/13-agent-work-packet-template.md`

## Context

- Current problem: shelves, racks, and display surfaces still read too much like primitive rectangles/rods.
- Target player-facing result: fixtures look like physical retail objects with meaningful empty capacity and visible stocked states.
- Existing systems that must keep working: shelf slots, stocking, category assignment, fixture placement, collision/route clearance, and fixture catalog.
- Visual/design docs that define success: fixture/display bible and MVP checklist.
- Known prior failures to avoid: wall-hook product display, tiny three-item shelves, labels carrying object identity, future inventory staged as owned stock.

## In Scope

- Starter wall shelf/rack or display fixture.
- 10-30 item capacity language where scale supports it.
- Visible empty capacity slots.
- Stocked and empty states.
- Shelf label/header strip.
- Material breaks, bevels, rails, supports, trim, and nonprimitive silhouette.
- Fixture/shelf tests.

## Out Of Scope

- Product cover-art internals.
- Store shell, counter, or backroom geometry.
- Broad mature-store fixture catalog.
- Locked/glass premium case implementation unless needed as a minimal display proof.

## Acceptance Checklist

- [x] Fixture reads as a store fixture before labels.
- [x] Empty slots look intentional and useful.
- [x] Stocked products land cleanly in visible capacity.
- [x] Movement, stocking, and placement still work.
- [x] Focused fixture/shelf tests pass.
- [x] Full validation runs before completion if game assets/scenes changed.

## Implementation Evidence

- Added reusable shelf-slot scene: `res://scenes/objects/shelf_slot.tscn`.
- Upgraded `res://scenes/props/placeholder_shelf.tscn` into a twelve-slot stockable display with rails, dividers, laminate edges, plinth, cap, and readable empty capacity.
- Updated fixture data resources for wall shelf, game display rack, and new-release wall.
- Wired shelf-slot paths into `res://scenes/world/store_world.tscn`.
- Updated fixture, shelf-slot, placement, store-session, and graybox/store-world tests.
- Review screenshot: `artifacts/validation/latest/screenshots/stocked_aisle.png`.

## Validation

Latest full gate:

```text
scripts/validate_godot.sh
```

Result: passed with 592 GUT tests, 12273 asserts, and screenshot sanity.

Owner visual signoff failed. This fixture work is regression/mechanics context only and must not be treated as the accepted visual baseline.

Future fixture art must be proven inside `05-hero-art-slice-proof.md` before broad integration.

## Stop Conditions

- A fixture improvement breaks stocking or placement mechanics.
- Capacity requirements cannot fit the current store scale without layout changes.
- The fixture still reads as rectangles/rods after the pass.
