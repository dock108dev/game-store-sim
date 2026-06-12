# Register And Counter Slice

## Implementation Status

Implemented for owner review. Current scene surfaces include register counter trim, workflow rail, transaction trays, cash drawer cues, preorder/service/return/trade-in counter props, and first-open checklist cue.

## Goal

Make the register counter a final-quality visual anchor.

The counter should communicate business function, era, and tone without needing labels to explain every object.

## Scope

In scope:

- Counter body and employee/customer sides.
- Register equipment.
- Trade-in inspection area.
- Preorder and service paperwork.
- Impulse rack.
- Counter lighting.
- Customer approach sightline.

Out of scope:

- New register mechanics.
- Multiple checkout stations.
- Full UI redesign.

## Assets Needed

- Counter module with bevels and laminate/material detail.
- Cash drawer.
- Barcode scanner.
- Receipt printer.
- Card terminal.
- Bag/sleeve stack.
- Trade-in tray.
- Preorder binder or card stack.
- Service pickup ticket tray.
- Impulse rack with small accessories.
- Pen cup, tape, small clutter props.

## Implementation Files

Likely affected:

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/store_layout/register_workstation.tscn`
- `game/scripts/store_layout/register_workstation.gd` only if node paths change.
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_interaction_contract.gd`

## Acceptance Screenshots

- `register_counter.png`
- `customer_queue.png`
- `trade_in_offer.png`
- `preorder_deposit.png`
- `service_request.png`

## Pass Criteria

- Counter reads as one clear workstation.
- Sale, return, trade-in, preorder, and service are visible as counter workflows.
- Equipment silhouettes are recognizable.
- Role props and counter props do not crowd modal UI.
- Customer side and employee side are clear.
- Mid-00s retail era is visible through equipment, paperwork, and materials.

## Fail Criteria

- Counter still looks like stacked boxes.
- Workflow identity depends on large labels.
- Props imply unsupported extra workstations.
- Modal backgrounds become noisy or unreadable.
