# Backroom And Stockroom Plan

Implementation plan for the operations side of the opening store: receiving, backstock, manager office, service bench, records, security, and supplier flow.

## Goal

Make the backroom feel like the owner's working operations space. The player should understand that stock arrives, gets checked, moves into backstock, returns to the floor, and is managed from the office computer.

## Design Intent

The backroom should be practical, not mysterious by default. It supports the normal retail loop first:

- Receive supplier orders.
- Check and sort stock.
- Store backstock by category.
- Pull stock back to the sales floor.
- Manage the business from the computer.
- Handle service tickets and records.

Optional hidden-thread surfaces can exist, but they must remain secondary and non-required for normal retail progression.

## References

- `IMG_1040.PNG`: manager office and paperwork density.
- `IMG_1063.PNG`: receiving/backstock utility read.
- `IMG_1064.PNG`: stockroom lane and storage organization.
- `IMG_1070.PNG`: backroom desk, records, and operations context.

## Current Implementation State

Implemented in the current branch:

- Receiving station includes delivery/check/sort workflow cards on the intake surface.
- Backstock has category lanes, overflow storage, and pull-stage labeling.
- Floor arrows connect receiving to pull staging and backstock to sales-floor restock flow.
- Manager office frames the computer with calendar, records shelf, task lighting, and short management task tabs.
- Service bench has parts, disc/ticket cues, ready shelf, and service label.
- Records/safe/security/evidence props are present as secondary optional surfaces.
- Scene tests assert workflow cues are non-colliding and close to their intended routes.
- Office tests assert cues stay near the computer, inside the store footprint, separated from register actions, and depth-safe for labels.

This establishes the opening-store stockroom baseline. Future work can add richer supplier lots and service depth without changing the physical flow.

## Scope

### In Scope

- Receiving intake, invoice/check surface, sorted tray, and workflow cards.
- Physical delivery and supplier-order read.
- Backstock shelves, category lanes, overflow, and pull stage.
- Manager office and backroom computer framing.
- Service bench and ready pickup workflow.
- Records, safe, security, and hidden-thread props as optional secondary surfaces.
- Screenshot acceptance for receiving, supplier delivery, backroom computer, release, and hidden-thread images.

### Out Of Scope

- Large warehouse simulation.
- Complex inventory bin packing.
- Full supplier network.
- Mandatory hidden-story progression.
- Final-art office props.
- Separate service-minigame bench UI beyond the current management computer flow.

## Player Read Contract

From normal player movement:

1. Receiving should read as the place where stock physically arrives.
2. Sorting should read as a workflow, not instant inventory teleportation.
3. Backstock should read as stored capacity by category.
4. Pull staging should explain how stock returns to the sales floor.
5. The backroom computer should read as a manager workstation.
6. Service/records/security should be recognizable but secondary.

## Implementation Plan

### 1. Receiving Station

Build requirements:

- Delivery point or pallet anchors stock arrival.
- Open/sealed box state supports supplier-order fantasy.
- Invoice/check surface explains verification.
- Sort tray and workflow cards show progression from delivery to sorted stock.
- Pickup path stays clear for held items.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scripts/systems/store_session.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_store_session.gd`

Tests:

- Assert receiving box and starter products exist.
- Assert supplier orders deliver to receiving.
- Assert receiving workflow props are non-colliding and near the receiving box.
- Assert receiving routes remain clear.

### 2. Backstock Storage

Build requirements:

- Shelves show category lanes and capacity.
- Overflow storage reads as temporary backroom stock.
- Pull stage explains moving items from storage back toward the sales floor.
- Floor arrows guide workflow without becoming fake gameplay markers.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scripts/systems/store_session.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_store_session.gd`

Tests:

- Assert category lanes and bins exist.
- Assert pull stage is close to receiving, storage, and carry route.
- Assert receiving-to-backstock and backstock-to-retrieval behavior works through `StoreSession`.

### 3. Manager Office

Build requirements:

- Computer desk and chair read as owner workstation.
- Planning board, bills, supplier notes, records shelf, calendar, and task light give business context.
- Short task tabs show dashboard/order/release intent without dense text.
- Register actions must not appear to happen here.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/props/backroom_computer.tscn`
- `game/scripts/store_layout/backroom_computer.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_interaction_contract.gd`

Tests:

- Assert office props are close to the computer and inside the floorprint.
- Assert computer is wired to `StoreSession`.
- Assert computer interaction opens the management panel, not register checkout.

### 4. Backroom Computer Readability

Required management modes:

- Dashboard/day summary.
- Inventory and reorder suggestions.
- Supplier ordering.
- Fixture ordering and placement.
- Release calendar and allocation.
- Service bench workflow.
- Storage/backstock workflow.
- Settings and records.
- Optional hidden-thread records.

Implementation files:

- `game/scenes/ui/day_summary_panel.tscn`
- `game/scripts/ui/day_summary_panel.gd`
- `game/scripts/systems/store_session.gd`
- `game/tests/gut/test_day_summary_panel.gd`
- `game/tests/gut/test_store_session.gd`

Tests:

- Assert tabs exist and switch visibility.
- Assert contextual action groups appear only when relevant.
- Assert supplier, fixture, release, service, storage, and hidden-thread states are formatted distinctly.
- Assert main controls remain visible at 1280x720.

### 5. Service Bench

Build requirements:

- Bench reads as a work surface, not a second register.
- Parts bin, disc/service mat, paperwork, ready shelf, and ticket panel define the service workflow.
- Service pickup should connect to register confirmation without confusing the physical zones.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scripts/systems/store_session.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_store_session.gd`
- `game/tests/gut/test_service_customer.gd`

Tests:

- Assert service bench props exist and stay non-colliding.
- Assert service customer and ledger flow still complete.
- Assert service bench workflow appears in management panel.

### 6. Records, Safe, And Optional Hidden Thread

Build requirements:

- Records, safe, evidence, and security props should read as secondary surfaces.
- Hidden-thread cues should be visible enough for curious players but never required for core retail progression.
- Suspicious supplier/customer/evidence language should avoid implying mandatory crime-story objectives.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scripts/systems/evidence_storage.gd`
- `game/scripts/systems/suspicious_event_log.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_evidence_storage.gd`
- `game/tests/gut/test_suspicious_event_log.gd`
- `game/tests/gut/test_hidden_thread_validation_sync.gd`

Tests:

- Assert optional clues can be recorded without blocking retail progression.
- Assert records/safe/security props are secondary and non-colliding where visual-only.
- Assert hidden-thread choices can be ignored.

## File Impact Matrix

| File | Role | Change Type |
| --- | --- | --- |
| `game/scenes/world/graybox_store.tscn` | Stockroom, receiving, office, service, records props | Primary implementation |
| `game/scenes/props/backroom_computer.tscn` | Computer interaction prop | UI/scene bridge |
| `game/scripts/store_layout/backroom_computer.gd` | Backroom computer interaction | Behavior contract |
| `game/scenes/ui/day_summary_panel.tscn` | Management UI | UI implementation |
| `game/scripts/ui/day_summary_panel.gd` | Management UI behavior | Behavior contract |
| `game/scripts/systems/store_session.gd` | Supplier, release, service, storage, fixture logic | System contract |
| `game/tests/gut/test_graybox_store.gd` | Scene and prop assertions | Required |
| `game/tests/gut/test_day_summary_panel.gd` | Management UI assertions | Required |
| `game/tests/gut/test_store_session.gd` | Business workflow assertions | Required |
| `game/tests/gut/test_hidden_thread_validation_sync.gd` | Optional hidden-thread validation | Required if hidden surfaces change |

## Screenshot Acceptance

### `receiving_area.png`

Pass criteria:

- Shows receiving box, intake/check surface, sorted tray, starter products, and pickup path.
- Workflow cards make delivery/check/sort understandable.
- No sign or prop blocks the action.

Fail criteria:

- Products are hidden.
- Receiving reads as random storage.
- Pickup path is visually blocked.

### `supplier_delivery.png`

Pass criteria:

- Supplier delivery reads as physical stock arrival.
- Delivery/check/sort flow is visible.
- Backstock route is implied.

Fail criteria:

- Delivery looks like instant inventory.
- Supplier context is readable only in UI text.

### `backroom_summary.png`

Pass criteria:

- Manager office and computer read as a workstation.
- Service, records, storage, and receiving zones remain distinguishable.
- Main computer controls are visible.

Fail criteria:

- Backroom reads as a cluttered graybox.
- Computer context is hidden or debug-like.
- Hidden-thread props dominate normal retail work.

### Release/Management Screenshots

Required files:

- `catalog_design_cues.png`
- `upgrade_preview.png`
- `release_calendar.png`
- `release_allocation.png`
- `launch_day.png`

Pass criteria:

- Tab purpose and primary controls are visible.
- Release calendar, allocation, and launch result read as different states.
- Backroom office context supports the UI.

### Hidden-Thread Screenshots

Required files:

- `supplier_message.png`
- `suspicious_customer.png`

Pass criteria:

- Optionality is clear.
- Suspicious content stays secondary to normal retail.
- No hidden-thread surface blocks core store actions.

## Automated Validation

Required:

```text
scripts/validate_godot.sh
```

Relevant GUT surfaces:

- `test_graybox_store.gd`
- `test_day_summary_panel.gd`
- `test_store_session.gd`
- `test_supplier_lot.gd`
- `test_supplier_message.gd`
- `test_service_customer.gd`
- `test_evidence_storage.gd`
- `test_suspicious_event_log.gd`
- `test_hidden_thread_validation_sync.gd`

## Manual Review

Review in this order:

1. `receiving_area.png`
2. `supplier_delivery.png`
3. `backroom_summary.png`
4. `catalog_design_cues.png`
5. `upgrade_preview.png`
6. `release_calendar.png`
7. `release_allocation.png`
8. `launch_day.png`
9. `supplier_message.png`
10. `suspicious_customer.png`

File failures in `docs/production/13-alpha-bug-list.md` with screenshot name, area, failure reason, and required acceptance.

## Risks

- Dense backroom props can make the space feel busy before it reads as workflow.
- Hidden-thread props can accidentally imply a mandatory story route.
- Computer UI can become dense enough that screenshots prove functionality but not readability.
- Receiving/backstock arrows can feel artificial if they are too dominant.

## Completion Criteria

This plan is complete when:

- Receiving and backstock workflows are physically represented and tested.
- Manager office/computer reads as business management.
- Service and records surfaces are visible but secondary.
- Hidden-thread surfaces remain optional.
- Required backroom screenshots exist and are reviewable.
- Full validation passes.
- Owner screenshot review either approves the backroom/stockroom read or files targeted rework.
