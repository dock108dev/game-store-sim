# Work Packet: Fixtures And Placement Systems

Status: Complete
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/05-fixture-grid-slice.md`
Dependencies: `docs/design-implementation/04-starting-store-layout-spec.md`, `docs/design-implementation/08-required-zones-slice.md`, `docs/design-implementation/09-density-and-clutter-rules.md`, `docs/design-implementation/work-packets/02-store-shell-mall-entrance-stockroom.md`
Expected commit scope: starter fixture modules, snap placement visuals, stocking slots, labels, and empty/stocked fixture states

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `docs/design-implementation/work-packets/00-packet-index.md`
5. `docs/design-implementation/05-fixture-grid-slice.md`
6. `docs/design-implementation/04-starting-store-layout-spec.md`
7. `docs/design-implementation/08-required-zones-slice.md`
8. `docs/design-implementation/09-density-and-clutter-rules.md`

## Context

- Current problem: products and labels cannot carry the store fantasy until fixtures read as intentional retail surfaces instead of primitive stands.
- Target player-facing result: the player can buy/place starter shelves or racks, see snap intent, label the fixture, and understand where products will physically appear.
- Existing systems that must keep working: fixture placement, stocking, product pickup/carry, pricing, save/load, player organization, route movement.
- Visual/design docs that define success: fixture grid slice, layout, required zones, density rules.
- Known prior failures to avoid: fixed category zones, invisible capacity, shelves that look like boxes, labels replacing physical products, clutter dumped into empty areas.

## In Scope

- Starter wall shelf/rack module family using cheap laminate/metal visual language.
- Fixture snap-to placement visuals.
- Visible product slots/capacity markers that do not look like debug overlays.
- Empty fixture state.
- Stocked fixture state using placeholder product slot geometry until packet 05 finalizes cases.
- Editable or default shelf labels that support player organization.
- Save/load preservation for placed fixtures if touched.
- Basic collision and route clearance.

## Out Of Scope

- Full product cover art pass.
- Broad bins/tables/demos beyond starter needs.
- Fixed genre/platform zones that remove player organization.
- Console floor-display breadth.
- Decoration-only fixtures.
- Customer browsing behavior changes unless required by route preservation.

## Do Not Do

- Do not make shelves only labels with no product slots.
- Do not force one global layout organization.
- Do not add bins just to fill empty space.
- Do not put locked/future inventory on fixtures.
- Do not leave visible raw cube fixtures as final assets.
- Do not break fixture movement, replacement, or upgradeability.
- Do not move checkout/trade-in work into this packet.

## Implementation Plan

1. Inspect current fixture placement and stocking systems.
2. Identify what fixture data drives placement, inventory, save/load, and screenshot tests.
3. Implement starter wall shelf/rack visual modules.
4. Add snap placement visuals and capacity/slot representation.
5. Integrate empty/stocked states with existing stocking logic.
6. Preserve player-defined labels and organization.
7. Update tests/docs if fixture data or behavior changes.
8. Capture empty and stocked fixture screenshots.
9. Run focused fixture/stocking/save-load tests and full validation.
10. Commit and push.

## Likely Files

Scenes:
- fixture scenes
- active store scene fixture anchors
- visual module scenes

Scripts:
- fixture placement scripts
- stocking scripts
- save/load fixture serializers
- interaction scripts

Assets:
- fixture materials
- shelf/rack modules
- label materials

Data:
- fixture catalog/configuration
- placement grid metadata

Tests:
- fixture placement tests
- stocking tests
- save/load tests
- screenshot target tests if changed

Docs:
- `docs/design-implementation/05-fixture-grid-slice.md`
- `docs/design-implementation/08-required-zones-slice.md`
- `docs/production/13-alpha-bug-list.md` if blockers change

## Validation Required

Implementation packet:

- Capture final game-window screenshots first.
- Review screenshots for fixture readability before and after stocking.
- Run focused fixture/stocking/save-load tests.
- Run `scripts/validate_godot.sh`.
- Confirm artifacts under `artifacts/validation/latest/`.

## Screenshot Evidence

Required final screenshots:

- empty starter shelf/rack in sales floor
- same fixture stocked with visible product slots
- fixture label close enough to read
- placement/snap preview if visible during gameplay
- route clearance around placed fixtures

## Tests To Add Or Update

- Fixture visual/config load tests if new fixture data is introduced.
- Fixture placement tests if snap rules change.
- Stocking tests if product slot behavior changes.
- Save/load tests if fixture serialization changes.

## Tests To Run

- focused fixture placement tests
- focused stocking tests
- focused save/load tests if touched
- `scripts/validate_godot.sh`

## Documentation Updates

- Update fixture slice doc if final fixture types, slot counts, labels, or snap rules change.
- Log any fixture ownership or player-organization assumptions.

## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
| Starter fixture set favors wall shelves/racks. | Owner preferred shelves first, bins/tables later as unlocks. | No | Add bins/tables only in later expansion packet. |
| Starter shelf uses cheap laminate edges, dark supports, three ledges, and visible empty capacity ticks. | This improves fixture read without changing stocking, placement, save/load, or product catalog behavior. | No | Product packet can replace placeholder product art while keeping the same slots. |
| Capacity cues are nonblocking visual children under each shelf slot. | Slot geometry should explain stockable space without creating collision or route problems. | No | Keep this pattern for later bins, wall racks, and tables. |

## Stop Conditions

- Existing placement/save-load cannot support movable fixtures.
- Stocked products cannot be made visible without changing core inventory model.
- Fixture visuals still read as raw boxes.
- Route or interaction blocking cannot be fixed locally.
- Validation exposes a blocker.

## Continue Conditions

- Starter shelves/racks are placeable.
- Visible slots make stocked products readable.
- Player can label/organize fixtures.
- Checkout and product packets can build on fixture positions.

## Final Handoff Requirements

- Commit hash
- Branch
- Screenshot/contact-sheet paths
- Validation command/result
- Fixture paths/config names
- Known residual issues
- Owner/lead decisions needed

## Completion Notes

Completed implementation:

- Updated `game/scenes/props/placeholder_shelf.tscn` so the starter `GameDisplayRack` reads as a cheap laminate retail fixture instead of only raw box panels.
- Added `TopLedge`, `BackPanelLaminateEdge`, `BottomLaminateEdge`, `MiddleLaminateEdge`, and `TopLaminateEdge`.
- Added `SlotEmptyBackdrop` plus `SlotCapacityTickA`, `SlotCapacityTickB`, and `SlotCapacityTickC` to each starter shelf slot.
- Updated the placement ghost with matching ledges and slot ticks so the snap preview reads like the placed starter fixture.
- Preserved the existing three `ShelfSlot` nodes, stocking API, placement footprint, slot category behavior, and hover frame behavior.
- Added focused fixture tests in `game/tests/gut/test_shelf_slot.gd`.
- Updated validation baseline to 573 GUT tests and 11019 asserts.

Validation evidence:

- Focused/full GUT command: `"$GODOT_BIN" --headless --path game --script res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit`
- Result: 573/573 tests passed, 11019 asserts.
- Full production gate: `scripts/validate_godot.sh` passed and regenerated screenshot artifacts at `artifacts/validation/latest/`.

Residual issues:

- The starter shelf is still a CSG-authored placeholder asset, not a final modeled asset.
- Product cover/price visual quality still belongs to packet 05.
- Checkout/counter prop cleanup still belongs to packet 04.
