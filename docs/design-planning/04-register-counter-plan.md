# Register Counter Plan

Implementation plan for the register command center.

## Goal

Make the counter physically explain the supported transactions: sale, return, trade-in, preorder, and service pickup.

## References

- `IMG_1039.PNG`
- `IMG_1060.PNG`
- `IMG_1061.PNG`
- `IMG_1062.PNG`
- `IMG_1067.PNG`
- `IMG_1072.PNG`
- `IMG_1073.PNG`

## Build Tasks

1. Owner-side counter.
   - Scanner.
   - Payment terminal.
   - Receipt printer.
   - Cash drawer.
   - Work rail or counter mat.

2. Customer-side counter.
   - Queue mat.
   - Bag/sleeve stack.
   - Impulse shelf or small accessory cue.
   - Clear customer approach point.

3. Transaction-specific surfaces.
   - Return review tray.
   - Trade-in inspection pad.
   - Preorder slip stack.
   - Service pickup marker.

4. UI/physical alignment.
   - Sale panel shows itemized sale before confirm.
   - Return panel shows refund/disposition before confirm.
   - Trade-in panel shows condition, value, offer, margin, and risk.
   - Preorder/service states read as obligations/workflows, not ordinary sales.

## Files To Expect

- `game/scenes/props/register_workstation.tscn`
- `game/scripts/store_layout/register_workstation.gd`
- `game/scenes/ui/register_checkout_panel.tscn`
- `game/scripts/ui/register_checkout_panel.gd`
- `game/scenes/ui/trade_in_offer_panel.tscn`
- `game/tests/gut/test_register_checkout_panel.gd`
- `game/tests/gut/test_register_checkout_ui.gd`
- `game/tests/gut/test_trade_in_offer_panel.gd`

## Acceptance

- `register_counter.png` reads as a working counter before UI opens.
- `trade_in_offer.png`, `preorder_deposit.png`, and `service_request.png` show clear decision context.
- Register remains one interaction target.
- Physical props do not add fake buttons or unsupported interactions.

## Implemented Evidence

- Register counter includes scanner, scan pad, payment terminal, receipt printer/slip, cash drawer, sleeve stack, customer approach marker, impulse rack, and queue/customer mats.
- Transaction-specific surfaces cover sale, return, trade-in, preorder, and service pickup.
- `RegisterModeCueRail` gives the five workflow states a physical read without adding new interaction nodes.
- `test_graybox_store.gd` locks the prop set, labels, proximity to the register, and non-colliding visual-only behavior.

## Test

- Run register, trade-in, return, service, and preorder tests.
- Run `scripts/validate_godot.sh`.
- Review register screenshots at 1280x720.
