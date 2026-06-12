# Customers And Role Silhouettes

## Implementation Status

Implemented for owner review. Current customer scenes use modular body kits, distinct body widths/colors, role props, compact role silhouettes, and separate buyer/trade-in/preorder/service/suspicious props below head height.

## Goal

Make customers readable by body shape, pose, carried prop, and spatial behavior before prompt text appears.

## Roles

Required roles:

- Buyer.
- Trade-in seller.
- Preorder customer.
- Service customer.
- Suspicious customer.

## Visual Rules

Each role needs:

- Distinct carried item or prop.
- Distinct waiting/approach posture.
- Compact visual cue below or near torso.
- Clear separation from other roles at the register.
- Optional text prompt only as support.

Avoid:

- Giant floating labels.
- Oversized props that block faces or UI.
- Role colors as the only difference.
- Crowding all special customers into one visual lane.

## Role Props

Buyer:

- Small bag, wallet, or browsed case.

Trade-in seller:

- Box of used games, console bundle, or stack of cases.

Preorder customer:

- Reservation slip, receipt, or launch-card flyer.

Service customer:

- Disc sleeve, controller, or repair ticket.

Suspicious customer:

- Cash envelope, odd package, or folded invoice.

## Implementation Files

Likely affected:

- `game/scenes/customers/*.tscn`
- `game/scripts/customers/*.gd`
- `game/tests/gut/test_customer_role_visuals.gd`
- `game/tests/gut/test_customer_pose_animator.gd`
- `game/tests/gut/test_graybox_store.gd`

## Acceptance Screenshots

- `customer_queue.png`
- `trade_in_offer.png`
- `preorder_deposit.png`
- `service_request.png`
- `suspicious_customer.png`

## Pass Criteria

- Role is guessable before interaction.
- Props stay compact and anchored.
- Register queue remains readable.
- Modals keep focus.

## Fail Criteria

- Role depends on prompt text.
- Props visually collide with heads, torso, or UI.
- Special customers dominate the queue.
