# Current Manual Playtest

Use this checklist after `scripts/validate_godot.sh` passes.

## Full Loop

1. Start the main scene.
2. Confirm the front door still blocks exit from the playable store.
3. Pick up a `Star Trader` from the receiving box.
4. Open pricing from the held item.
5. Adjust the price, apply it, and confirm mouse capture returns.
6. Stock the game in an empty display rack slot.
7. Confirm one buyer walks to the rack, picks up the game, then queues at the register.
8. Repeat pickup, pricing, and stocking with a second `Star Trader`.
9. Confirm a second buyer walks to the rack and queues with readable spacing.
10. Ring up the first buyer.
11. Ring up the second buyer.
12. Confirm sold items are gone from the rack and no longer inspectable.
13. Open the backroom computer.
14. Confirm cash, sales count, revenue, cost, and profit match the completed sales.
15. End the day and confirm the summary changes to `Day closed`.

## Visual Checks

- Receiving box contains multiple visible used games without looking cluttered.
- Held item stays low/right and does not block navigation.
- Stocked games look upright and intentional.
- Register prompt and sale messages are readable.
- Buyer movement from browsing to rack to register reads clearly and does not clip badly through fixtures.
- Buyer queue spacing is readable and does not overlap the register.
- Backroom computer reads as the management terminal, not another register.
- Summary panel text and buttons fit in the actual game window.

## Automated Screenshot Artifacts

The local gate writes these images under `artifacts/validation/latest/screenshots/`:

- `main_scene.png`
- `receiving_area.png`
- `register_counter.png`
- `customer_queue.png`
- `backroom_summary.png`
