# Backroom And Stockroom Plan

Implementation plan for the operations side of the opening store.

## Goal

Make the backroom feel like the owner's working operations space: receiving, backstock, office, service, records, safe/security, and supplier flow.

## References

- `IMG_1040.PNG`
- `IMG_1063.PNG`
- `IMG_1064.PNG`
- `IMG_1070.PNG`

## Build Tasks

1. Receiving station.
   - Delivery point.
   - Open/sealed box state.
   - Invoice/check surface.
   - Sort tray.
   - Route to shelf and backstock.

2. Backstock shelves.
   - Category lanes.
   - Capacity read.
   - Overflow visual language.
   - Pull stage.

3. Manager office.
   - Computer desk.
   - Chair.
   - Planning board.
   - Bills/paperwork.
   - Supplier notes.
   - Calendar/release planning context.

4. Service and records.
   - Service bench.
   - Parts bins.
   - Ready pickup area.
   - Records shelf.
   - Safe/security/evidence props as secondary optional surfaces.

5. Computer readability.
   - Dashboard should summarize the day.
   - Ordering should scan like catalog cards.
   - Releases should separate calendar, commitment, and launch result.
   - Records should not look like an active mandatory story objective.

## Files To Expect

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/props/backroom_computer.tscn`
- `game/scripts/store_layout/backroom_computer.gd`
- `game/scenes/ui/day_summary_panel.tscn`
- `game/scripts/ui/day_summary_panel.gd`
- `game/scripts/systems/store_session.gd`
- `game/tests/gut/test_day_summary_panel.gd`
- `game/tests/gut/test_store_session.gd`
- `game/tests/gut/test_graybox_store.gd`

## Acceptance

- `receiving_area.png` shows products, intake, and pickup path clearly.
- `supplier_delivery.png` shows delivery workflow, not instant inventory.
- `backroom_summary.png` shows a readable manager workstation.
- Release and launch screenshots are scan-friendly.
- Hidden-thread surfaces stay optional and secondary.

## Implemented Evidence

- Receiving station includes delivery/check/sort workflow cards on the intake surface.
- Backstock has category lanes, overflow storage, and pull-stage labeling.
- Floor arrows connect receiving to pull staging and backstock to sales-floor restock flow.
- `test_graybox_store.gd` asserts all workflow cues are non-colliding and close to their intended route.

## Test

- Run store session, day summary, hidden-thread, and scene tests.
- Run `scripts/validate_godot.sh`.
- Review receiving/backroom screenshots at 1280x720.
