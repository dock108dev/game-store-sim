# Register Counter Plan

Implementation plan for the register command center: checkout, returns, trade-ins, preorder deposits, service pickup, and counter readability.

## Goal

Make the counter physically explain the supported transactions before the player opens any UI. The register should read as one clear workstation, not a cluster of unrelated buttons.

## Design Intent

The register is the player's conversion point. Every sales-floor loop eventually resolves here, so the counter must communicate:

- Where the player stands.
- Where the customer approaches.
- Where items are scanned/inspected.
- Which transaction modes are supported.
- Which UI decision is about to happen.

The physical counter should support the UI, not compete with it.

## References

- `IMG_1039.PNG`: compact counter shape and service-side read.
- `IMG_1060.PNG`: checkout equipment cluster.
- `IMG_1061.PNG`: return/trade review surface language.
- `IMG_1062.PNG`: customer approach and counter organization.
- `IMG_1067.PNG`: preorder/service paperwork cues.
- `IMG_1072.PNG`: register counter density and queue framing.
- `IMG_1073.PNG`: small accessory/impulse merchandising near checkout.

## Current Implementation State

Implemented in the current branch:

- Register counter includes scanner, scan pad, payment terminal, receipt printer/slip, cash drawer, sleeve stack, customer approach marker, impulse rack, and queue/customer mats.
- Transaction-specific surfaces cover sale, return, trade-in, preorder, and service pickup.
- `RegisterModeCueRail` gives the five workflow states a physical read without adding extra interaction nodes.
- Scene tests lock the prop set, labels, proximity to the register, and non-colliding visual-only behavior.

This is the opening-store command-center baseline. Future work should improve art, animation, and UI polish while preserving the single-register interaction contract.

## Scope

### In Scope

- Owner-side register props.
- Customer-side queue/approach props.
- Transaction-mode physical cues.
- Register checkout, return, trade-in, preorder, and service screenshots.
- UI/physical alignment for decision-before-confirm flows.

### Out Of Scope

- Multiple active registers.
- Standalone pricing workstation.
- Standalone return desk.
- Cash-handling minigames.
- Fully animated scanner/payment terminal.
- Real payment networks, receipts, or third-party brands.

## Player Read Contract

Before opening UI:

1. The counter should read as the store's checkout point.
2. A held item should visually make sense on a scan/review surface.
3. Customer approach and player position should be clear.
4. Sale/return/trade/preorder/service modes should read as workflow states, not separate interactables.
5. The register should remain one obvious interaction target.

## Implementation Plan

### 1. Owner-Side Counter

Build requirements:

- Scanner/scan pad anchors the sale action.
- Payment terminal and receipt printer imply checkout completion.
- Cash drawer gives the counter a real retail mass.
- Work mat/rail organizes the owner-side surface.
- Equipment stays below sightline enough to avoid blocking UI screenshots.

Implementation files:

- `game/scenes/props/register_workstation.tscn`
- `game/scenes/world/graybox_store.tscn`
- `game/scripts/store_layout/register_workstation.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_interaction_contract.gd`

Tests:

- Assert the register remains interactable.
- Assert equipment nodes exist and stay near the register.
- Assert visual-only props do not add new collisions or targets.

### 2. Customer-Side Counter

Build requirements:

- Queue mat and approach marker show where customers stand.
- Sleeve/bag stack and impulse shelf sell the checkout retail fantasy.
- Customer-side props should not block buyer queue or special-customer arc.
- Register prompt should remain readable from the player's normal approach.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scripts/systems/customer_manager.gd`
- `game/tests/gut/test_customer_manager.gd`
- `game/tests/gut/test_graybox_store.gd`

Tests:

- Assert register-area customer positions are spaced.
- Assert buyer queue lane stays clear of special customers.
- Assert customer approach marker sits near register but does not collide.

### 3. Transaction-Specific Surfaces

Required physical cues:

- Sale: scan pad/scanner.
- Return: return review tray.
- Trade-in: inspection pad.
- Preorder: slip stack or reservation paperwork.
- Service pickup: service marker/ticket cue.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/props/register_workstation.tscn`
- `game/tests/gut/test_graybox_store.gd`

Tests:

- Assert all five mode cues exist.
- Assert mode labels are short and fictional.
- Assert mode cues are non-colliding and clustered around the register.

### 4. UI/Physical Alignment

UI requirements:

- Sale panel shows itemized sale before confirmation.
- Return panel shows refund/disposition before confirmation.
- Trade-in panel shows condition, market value, offer, margin, and risk before confirmation.
- Preorder deposit shows reservation context, not a normal sale.
- Service request/pickup shows work order context, not a normal sale.

Implementation files:

- `game/scenes/ui/register_checkout_panel.tscn`
- `game/scripts/ui/register_checkout_panel.gd`
- `game/scenes/ui/trade_in_offer_panel.tscn`
- `game/scripts/ui/trade_in_offer_panel.gd`
- `game/tests/gut/test_register_checkout_panel.gd`
- `game/tests/gut/test_register_checkout_ui.gd`
- `game/tests/gut/test_trade_in_offer_panel.gd`

Tests:

- Assert modal opens with expected fields.
- Assert confirmation disables repeated actions.
- Assert return, preorder, service, and trade-in transaction summaries differ from ordinary sale copy.
- Assert mouse/focus behavior remains stable.

## File Impact Matrix

| File | Role | Change Type |
| --- | --- | --- |
| `game/scenes/props/register_workstation.tscn` | Register workstation geometry and interaction root | Primary implementation |
| `game/scenes/world/graybox_store.tscn` | Counter-zone props and customer approach layout | Primary implementation |
| `game/scripts/store_layout/register_workstation.gd` | Register interaction behavior | Behavior contract |
| `game/scenes/ui/register_checkout_panel.tscn` | Checkout/return/preorder/service UI | UI implementation |
| `game/scripts/ui/register_checkout_panel.gd` | Checkout/return/preorder/service behavior | Behavior contract |
| `game/scenes/ui/trade_in_offer_panel.tscn` | Trade-in UI | UI implementation |
| `game/scripts/ui/trade_in_offer_panel.gd` | Trade-in behavior | Behavior contract |
| `game/tests/gut/test_graybox_store.gd` | Counter scene assertions | Required |
| `game/tests/gut/test_register_checkout_panel.gd` | Modal behavior | Required if checkout UI changes |
| `game/tests/gut/test_register_checkout_ui.gd` | Transaction summary formatting | Required |
| `game/tests/gut/test_trade_in_offer_panel.gd` | Trade-in offer behavior | Required |

## Screenshot Acceptance

### `register_counter.png`

Pass criteria:

- Counter reads as a working checkout surface before UI opens.
- Scanner/scan pad/payment/receipt/cash cues are visible.
- Customer approach marker and queue lane are readable.
- Register remains one obvious interaction target.

Fail criteria:

- Counter reads as a pile of generic boxes.
- Visual props imply unsupported separate interactions.
- Customer markers or props block the register prompt.

### `trade_in_offer.png`

Pass criteria:

- Trade-in modal shows condition, value, offer, margin, and decision buttons.
- Background counter context is visible but not competing.
- Customer/held-item context remains understandable.

Fail criteria:

- Modal hides the relevant decision information.
- Background props or customer bodies compete with the modal.
- The transaction reads as a normal sale.

### `preorder_deposit.png`

Pass criteria:

- Deposit/reservation context is clear.
- Launch/release obligation is visible before confirmation.
- Counter and customer context support the workflow.

Fail criteria:

- Preorder reads as an ordinary sale.
- Deposit amount or launch context is hidden.

### `service_request.png`

Pass criteria:

- Service ticket/work order context is clear.
- Service pickup/repair language is distinct from sale/preorder.
- UI decision is visible before confirmation.

Fail criteria:

- Service reads as generic checkout.
- Important service cost/status text is clipped or crowded.

## Automated Validation

Required:

```text
scripts/validate_godot.sh
```

Relevant GUT surfaces:

- `test_graybox_store.gd`
- `test_interaction_contract.gd`
- `test_register_checkout_panel.gd`
- `test_register_checkout_ui.gd`
- `test_trade_in_offer_panel.gd`
- `test_trade_in_customer.gd`
- `test_return_customer.gd`
- `test_preorder_customer.gd`
- `test_service_customer.gd`
- `test_customer_manager.gd`

## Manual Review

Review in this order:

1. `register_counter.png`
2. `trade_in_offer.png`
3. `preorder_deposit.png`
4. `service_request.png`
5. `customer_queue.png`

For failures, file the screenshot name, transaction mode, and blocked decision in `docs/production/13-alpha-bug-list.md`.

## Risks

- Adding transaction props can accidentally imply multiple interactable stations.
- Counter density can obscure customer roles and queue spacing.
- UI copy can drift from physical props, making transactions feel disconnected.
- Trade-in/return/service/preorder can collapse into generic sale language if screenshots are not reviewed separately.

## Completion Criteria

This plan is complete when:

- Register props physically support all five transaction modes.
- Register remains one interaction target.
- Transaction UI decisions are readable before confirmation.
- Queue/approach positions remain clear.
- Required register screenshots exist and pass owner review or produce targeted bug-list entries.
- Full validation passes.
