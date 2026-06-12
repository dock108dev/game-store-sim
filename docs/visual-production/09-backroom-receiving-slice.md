# Backroom Receiving Slice

## Implementation Status

Mechanically present, but superseded for visual approval by the opening mall/storefront reset. Current scene surfaces include receiving pallet/table, invoice/clipboard/sort cues, paid-arrivals lane, owned starter-stock crate, backstock shelf/bin lanes, pull route, service bench, office computer, and catalog planning cards; these should be rebuilt or re-framed after the opening composition passes.

## Goal

Make receiving and backstock feel like real physical retail operations.

The player should understand stock arrives in boxes, gets checked, sorted, staged, stored, and moved to the sales floor.

## Scope

In scope:

- Receiving station.
- Delivery boxes.
- Invoice/check surface.
- Sorted tray.
- Pull stage.
- Backstock shelving.
- Stock cart/hand truck.
- Office threshold view.

Out of scope:

- Large warehouse simulation.
- Complex bin-packing visuals.
- Mandatory hidden-thread focus.

## Assets Needed

- Cardboard box variants.
- Shipping labels.
- Packing tape.
- Box cutter/tape roll.
- Invoice clipboard.
- Plastic sorting trays.
- Stock cart or hand truck.
- Metal backstock shelf.
- Category bins.
- Overstuffed but readable overstock boxes.

## Implementation Files

Likely affected:

- `game/scenes/world/graybox_store.tscn`
- `game/scenes/props/receiving_box.tscn`
- `game/scripts/systems/store_session.gd` if visible states are exposed.
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_store_session.gd`

## Acceptance Screenshots

- `receiving_area.png`
- `supplier_delivery.png`
- `backroom_summary.png`

## Pass Criteria

- Receiving reads as an operational station before text.
- Supplier delivery looks physical.
- Backstock shelves have category organization.
- Pull-stage workflow is visible without giant arrows as the main read.
- Hidden-thread details are secondary.

## Fail Criteria

- Receiving looks like random boxes.
- Supplier delivery looks like UI teleportation.
- Backstock props block routes.
- Hidden-thread props dominate the normal retail flow.
