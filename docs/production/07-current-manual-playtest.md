# Current Manual Playtest

Use this checklist after `scripts/validate_godot.sh` passes.

## Full Loop

1. Start the main scene.
2. Confirm the front door still blocks exit from the playable store.
3. Pick up a `Star Trader` from the receiving box.
4. Open pricing from the held item.
5. Adjust the price, optionally enable apply-to-matching, apply it, and confirm mouse capture returns.
6. On a fresh run or before the sale loop, overprice one `Star Trader` above market tolerance, stock it, and confirm a buyer leaves it on the rack with readable feedback.
7. Stock a fairly priced game in an empty display rack slot.
8. Confirm one buyer walks to the rack, picks up the game, then queues at the register.
9. Repeat pickup, pricing, and stocking with a second fairly priced `Star Trader`.
10. Confirm a second buyer walks to the rack and queues with readable spacing.
11. Ring up the first buyer.
12. Ring up the second buyer.
13. Confirm sold items are gone from the rack and no longer inspectable.
14. Interact with the register when no buyer is queued and review the seller trade-in offer.
15. Confirm the offer panel shows condition, demand, market value, cash offer, and store-credit offer.
16. Use `+ $1` and `- $1` in the trade-in panel and confirm only the cash offer updates.
17. Accept the adjusted cash trade-in and confirm the acquired item appears in the receiving box and can be treated as inventory.
18. On a fresh run, accept the store-credit trade-in and confirm cash does not decrease while the acquired item appears in the receiving box.
19. On a fresh run, decline the trade-in and confirm cash/inventory do not change.
20. Open the backroom computer.
21. Confirm cash, sales count, revenue, cost, profit, trade-in count, trade cash, store credit, recent activity, active inventory summary, and reorder suggestions match the completed sales/trade-in and remaining items.
22. Use `Order Rack` on the backroom computer and confirm cash drops by `$125.00`.
23. Confirm the backroom computer lists `Game Display Rack` under pending placement and does not imply the rack was already placed.
24. Confirm a translucent rack ghost appears on the sales floor as a pending placement preview.
25. Confirm valid placement reads green and invalid placement reads red if the ghost is moved outside allowed bounds by test/debug flow.
26. Confirm rotated and snapped ghost states remain aligned to the floor grid if exercised by test/debug flow.
27. End the day and confirm the summary changes to `Day closed`.

## Visual Checks

- Receiving box contains multiple visible used games without looking cluttered.
- Display rack still reads as a used-game rack, and stocked used games still go into the expected slots.
- Held item stays low/right and does not block navigation.
- Stocked games look upright and intentional.
- Register prompt and sale messages are readable.
- Buyer movement from browsing to rack to register reads clearly and does not clip badly through fixtures.
- Buyer queue spacing is readable and does not overlap the register.
- Overpriced-item refusal feedback is readable and does not look like a register failure.
- Apply-to-matching pricing reads clearly and does not make the direct pricing panel feel like a separate terminal.
- Trade-in seller placement, carried item, offer panel, counteroffer controls, cash accept, store-credit accept, decline controls, prompt, and completion message read clearly at the register.
- Backroom computer reads as the management terminal, not another register.
- Summary panel text and buttons fit in the actual game window.
- Recent activity text is readable and distinguishes sales from trade-ins.
- Store-credit trade-in text is readable and clearly separate from cash trade spend.
- Inventory summary text is readable and matches active receiving/rack items.
- Reorder suggestion text is readable and makes sense after selling stocked games.
- Fixture order text/button are readable and clearly communicate pending placement.
- Fixture ghost preview is visible, translucent, and not confused with a usable placed rack.
- Green valid placement and red invalid placement are visually distinct in the actual window.
- Rotated ghost preview is still visually aligned and readable.

## Automated Screenshot Artifacts

The local gate writes these images under `artifacts/validation/latest/screenshots/`:

- `main_scene.png`
- `receiving_area.png`
- `register_counter.png`
- `customer_queue.png`
- `trade_in_offer.png`
- `backroom_summary.png`
- `fixture_ghost.png`
- `fixture_invalid_ghost.png`
- `fixture_rotated_ghost.png`
