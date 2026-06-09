# Employees-Only Stockroom Production Plan

This is the next active implementation plan after readability recovery. The goal is to turn the current working backroom/receiving mechanics into a believable employees-only stockroom and office: incoming stock should arrive in an organized operations space, the player should physically bring products out to the sales floor, and the computer should live in a small office/management zone instead of feeling like a debug terminal in a graybox room.

External alpha playtest remains paused until the owner screenshot pass is readable. This plan is the next build direction, not a playtest reopen.

## Current Audit

What is working:

- Supplier orders, receiving batches, invoice checks, sorting, backstock storage, shelf stocking, service tickets, management readouts, and the backroom computer are mechanically validated.
- The click-first carry, pricing, stocking, register, and day-loop paths are protected by the full gate.
- The readability recovery pass fixed the worst camera, prompt, modal, customer-label, and label-clipping blockers.

What still reads wrong:

- Incoming stock still reads too much like objects placed in the room or on the floor, not like a controlled employees-only workflow.
- The backroom is functional, but it is not yet a convincing stock room with receiving, sorting, backstock, office, service, safe/security, and staff-only boundaries.
- The computer UI is task-grouped, but the computer's world context should read as a manager desk/office with paperwork, not a generic floating backroom terminal.
- The sales-floor/backroom relationship is not yet strong enough: stock should clearly start behind the staff boundary and get physically brought to fixtures.

## Source References

Use these existing docs as constraints:

- `docs/game-design/01-inspiration-analysis.md`: office/backroom, supplier ordering, storage, repair, paperwork, and suspicious artifacts.
- `docs/production/12-production-target-contracts.md`: receiving/storage/office targets and the rule that physical inventory appears in receiving/storage for the player to handle.
- `docs/production/07-current-manual-playtest.md`: manual QA remains the active real-window checklist.
- `docs/production/16-playability-readability-recovery-plan.md`: recovery constraints remain active for camera, prompt, label, and modal readability.

## Non-Negotiables

- Keep the register focused on customer-facing sales, returns, trade-ins, preorders, and services.
- Keep the backroom computer focused on management, ordering, inventory, reports, releases, suppliers, storage, records, settings, and office planning.
- Supplier orders and backstock movement must create physical work in stockroom/receiving surfaces; do not turn them into instant sales-floor inventory.
- Do not add new gameplay systems during this pass unless needed to support the physical stockroom flow.
- Keep every slice validated, committed, and pushed before starting the next slice.
- Update `07-current-manual-playtest.md` and `game/tests/validation/scenarios/manual_checks.json` when a slice changes what the player sees or validates.

## Target Layout

The employees-only area should read as one compact but coherent operations suite:

- Staff threshold: clear doorway/signage from sales floor into employees-only stockroom, with the player route unobstructed.
- Receiving lane: delivery door or roll-up/pallet zone, sealed cartons, open intake table, invoice clipboard, and sorted-stock staging.
- Backstock wall: labeled shelving, bins, category lanes, overflow shelf, and clear pull/store affordance.
- Manager office: desk, computer, chair, file boxes, schedule/ordering board, invoices, bills, and low-clutter wall detail.
- Service bench: disc mat, small tools, ticket tray, parts bin, and ready-pickup shelf.
- Security/safe corner: safe, high-value shelf, suspicious-goods isolation, and security monitor as optional hidden-thread surfaces.
- Physical route: receiving to backstock to sales-floor fixtures should be readable while carrying items.

## Slice 0: Docs, Audit, And Validation Lock

Status: complete in `Plan stockroom production phase`.

Goal: make the next production phase explicit and remove stale "recovery is next" wording.

Work:

- Add this plan as the current active next-stage implementation plan.
- Update README, backlog, completion plan, decision log, validation docs, and manual checklist pointers.
- Add validation scenario coverage for stockroom planning docs and manual checklist sync.
- Preserve old plans as historical checkpoints instead of deleting useful validated slice evidence.

Acceptance:

- The active docs point to this plan for the next implementation sequence.
- Recovery docs remain complete/historical and still gate external playtest with owner screenshot validation.
- The manual checklist names the stockroom/office screenshots and real-window checks that should be captured during implementation.

Validation:

- `git diff --check`
- `scripts/validate_godot.sh`

Commit target:

- `Plan stockroom production phase`

## Slice 1: Stockroom Shell And Staff Boundary

Status: implemented in `Build stockroom staff boundary`; pending owner screenshot validation.

Goal: make the backroom read as an employees-only room before adding more props.

Work:

- Reframe the staff doorway/entry from the sales floor.
- Add concise `EMPLOYEES ONLY`, receiving, office, storage, and service zone cues without returning to oversized sign slabs.
- Establish wall/floor/material difference between sales floor, stockroom, and office nook.
- Preserve collision paths for player carry, customer queue, and fixture placement.

Acceptance:

- `22_backroom_entry_view.png` reads as a staff-only operations threshold.
- The stockroom is visibly separate from the sales floor without feeling like an unrelated warehouse.
- The route from receiving to backstock to sales-floor fixtures is clear.

Manual screenshots:

- `22_backroom_entry_view.png`
- `43_stockroom_staff_threshold.png`
- `44_stockroom_route_to_sales_floor.png`

Commit target:

- `Build stockroom staff boundary`

## Slice 2: Receiving And Intake Stations

Goal: replace the "stock on floor" read with a proper incoming-stock workflow.

Work:

- Add a delivery door/pallet zone, sealed box stack, open-box intake surface, invoice clipboard, and sorted-stock staging tray.
- Keep supplier-delivered products visible and pickable, but place them in intentional receiving containers or trays.
- Ensure Open Box, Invoice, and Sort states map to visible world props where practical.
- Keep the center-reticle prompt readable around intake products.

Acceptance:

- `04_receiving_box_before_pickup.png` and `32_open_box_invoice_sort.png` show products in an organized receiving station, not floor clutter.
- Sealed/opened/sorted states are visually distinct enough for manual review.
- Product labels remain whole from shallow left/right angles.

Manual screenshots:

- `04_receiving_box_before_pickup.png`
- `32_open_box_invoice_sort.png`
- `45_receiving_intake_station.png`

Commit target:

- `Build stockroom receiving station`

## Slice 3: Backstock Shelving And Pull/Store Flow

Goal: make backstock look like stored inventory that the player can pull from and bring to the sales floor.

Work:

- Add labeled category shelves, storage bins, overflow shelf, and a pull/stage surface.
- Recompose backstock products so they sit on shelves/bins rather than the floor.
- Ensure Store and Pull computer actions still read as physical backroom work.
- Keep carried-item route and shelf-stocking route clear.

Acceptance:

- Backstock count and storage movement are readable in the computer and supported by world shelves.
- Pulling stock implies "go get it from the stockroom" rather than instant sales-floor inventory.
- `10_stocked_rack_readability.png` still reads after moving stockroom surfaces.

Manual screenshots:

- `46_backstock_shelving.png`
- `47_backstock_pull_stage.png`
- `10_stocked_rack_readability.png`

Commit target:

- `Build stockroom backstock shelves`

## Slice 4: Manager Office And Computer World Context

Goal: make the computer feel like the manager's office workstation.

Work:

- Move/recompose the backroom computer into a small office/desk zone with chair, keyboard, paperwork, file boxes, supplier notes, and wall planning board.
- Keep the computer interactable, readable, and reachable.
- Keep dashboard, ordering, releases, records, storage, services, suppliers, settings, and reports task tabs unchanged unless layout polish is necessary.
- Ensure the office does not visually compete with receiving or service areas.

Acceptance:

- `24_backroom_dashboard.png`, `26_ordering_tab.png`, `27_releases_tab.png`, and `29_records_tab.png` read as screens opened from an office computer.
- World background reinforces office context without fighting modal readability.
- Register work still stays out of the computer.

Manual screenshots:

- `24_backroom_dashboard.png`
- `26_ordering_tab.png`
- `27_releases_tab.png`
- `29_records_tab.png`
- `48_manager_office_context.png`

Commit target:

- `Build stockroom manager office`

## Slice 5: Service, Safe, And Records Corners

Goal: keep service and optional hidden-thread surfaces physically present but secondary.

Work:

- Recompose service bench ticket, parts, disc mat, ready shelf, safe, security monitor, and suspicious-goods isolation.
- Keep service bench controls connected to backroom computer state, with register pickup still customer-facing.
- Keep hidden-thread props subtle and optional.

Acceptance:

- `20_service_bench_ticket.png` reads as a service bench, not a random table.
- Safe/security/records cues are visible but do not look like active objectives.
- Service flow remains understandable from computer to register pickup.

Manual screenshots:

- `20_service_bench_ticket.png`
- `49_service_safe_records_corner.png`

Commit target:

- `Build stockroom service and security corner`

## Slice 6: Stockroom Computer Workflow Copy And Controls

Goal: make the computer language match the new physical stockroom.

Work:

- Tune dashboard next-action, ordering, storage, receiving, and records copy to name physical stockroom actions.
- Keep buttons short and near relevant rows.
- Confirm supplier ordering explains where stock will appear and what the player must physically do next.
- Avoid adding register-facing actions to the computer.

Acceptance:

- Ordering and storage tabs clearly say when work happens in receiving/backstock.
- The owner checklist teaches "bring stock from the stockroom" without debug phrasing.
- Manual QA can understand the flow without reading code or chat.

Manual screenshots:

- `24_backroom_dashboard.png`
- `26_ordering_tab.png`
- `32_open_box_invoice_sort.png`
- `50_storage_tab_physical_flow.png`

Commit target:

- `Polish stockroom workflow copy`

## Slice 7: Stockroom Lighting, Materials, And Prop Density

Goal: make the stockroom visually richer while keeping the game readable.

Work:

- Add cooler utility lighting, shelf shadows, floor markings, box/paper material variation, and restrained wall detail.
- Keep product labels, prompts, and computer UI readable.
- Avoid visual clutter that hides carry routes or interactables.

Acceptance:

- Stockroom screenshots read as an operations space, not a graybox prop pile.
- Prompt, reticle, and labels remain readable at 1280x720.
- Sales floor remains warmer and more customer-facing than the stockroom.

Manual screenshots:

- `43_stockroom_staff_threshold.png`
- `45_receiving_intake_station.png`
- `46_backstock_shelving.png`
- `48_manager_office_context.png`

Commit target:

- `Polish stockroom lighting and materials`

## Slice 8: Validation Sync And External Package Decision

Goal: close the stockroom phase without confusing it with external playtest approval.

Work:

- Rerun the full automated gate.
- Review generated screenshots and update the manual checklist.
- Update `13-alpha-bug-list.md` with remaining stockroom/readability risks.
- Keep `15-alpha-playtest-package.md` paused unless the owner screenshot pass and stockroom screenshots both pass.

Acceptance:

- Full gate passes.
- Stockroom screenshots are ready for human review.
- Docs clearly separate "repo mechanically green" from "owner approved for external playtest."

Manual screenshots:

- `43_stockroom_staff_threshold.png`
- `45_receiving_intake_station.png`
- `46_backstock_shelving.png`
- `48_manager_office_context.png`
- `50_storage_tab_physical_flow.png`

Commit target:

- `Sync stockroom production validation`

## User Review Order

Review these docs in this order before implementation starts:

1. `docs/production/17-stockroom-production-plan.md`
2. `docs/production/12-production-target-contracts.md`
3. `docs/production/04-backlog.md`
4. `docs/production/11-game-completion-plan.md`
5. `docs/production/07-current-manual-playtest.md`
6. `docs/production/16-playability-readability-recovery-plan.md`

What to check:

- The stockroom is employees-only and physical, not a new abstract inventory menu.
- Incoming supplier stock appears in receiving/backstock surfaces for the player to carry.
- The computer belongs in an office/manager area.
- Service, safe, records, and hidden-thread props support the stockroom without taking over.
- The slice order starts with layout/sightlines before detailed prop density.
