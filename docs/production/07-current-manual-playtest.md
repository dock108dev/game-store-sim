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
22. Confirm the release calendar lists fictional upcoming launches with countdown, platform, wholesale cost, suggested price, allocation limit, and demand tier.
23. Clear the trade-in queue by accepting or declining it, then interact with the register and take the `Neon Skyline` preorder deposit.
24. Confirm cash increases by `$5.00`, sale count/revenue/profit do not change, and the register message reads as a preorder deposit rather than a sale.
25. Open the backroom computer and confirm preorder count and preorder deposits are readable.
26. Confirm the preorder flow does not imply allocation commitments, launch-day fulfillment, or reputation consequences yet.
27. Use `Order Rack` on the backroom computer and confirm cash drops by `$125.00`.
28. Confirm the backroom computer lists `Game Display Rack` under pending placement and does not imply the rack was already placed.
29. Confirm a translucent rack ghost appears on the sales floor as a pending placement preview.
30. Use `Place Rack` and confirm a real game display rack appears where the green ghost was.
31. Reopen the backroom computer and confirm pending placement is cleared and the rack is listed as placed.
32. Confirm valid placement reads green and invalid placement reads red if the ghost is moved outside allowed bounds by test/debug flow.
33. Confirm rotated and snapped ghost states remain aligned to the floor grid if exercised by test/debug flow.
34. Confirm the category demand readout is readable and not crowding the rest of the backroom panel.
35. Confirm the market drift readout is readable and makes sense for active inventory.
36. Use `Order Games` on the backroom computer and confirm cash drops by `$27.00`.
37. Confirm pending delivery says `Used Game Starter Lot`, due day 2, with 3 items.
38. End the day, then use `Start Day` and confirm delivered stock appears in the receiving box and pending delivery clears.
39. End the day and confirm the summary changes to `Day closed`.
40. Confirm the closed-day report is readable and matches the played day.
41. Confirm no visible hidden-thread UI or interruption appears during the normal store loop.
42. If you inspect the third receiving-box `Star Trader`, confirm the serial mismatch text is readable and the item still works with pickup, pricing, stocking, and sale flow.
43. Read the receiving-box supplier note and confirm it is readable, optional, and does not interrupt normal stocking or sales.
44. Talk to the `Cash Buyer` near the register and confirm the conversation reads as optional suspicious behavior, not a required objective.
45. Confirm normal stocking, pricing, buyer queueing, sales, trade-ins, preorder deposit, and day summary still work after talking to the `Cash Buyer`.
46. Confirm evidence storage remains invisible during normal play; no new objective, panel, or warning should appear yet.

## Visual Checks

- Receiving box contains multiple visible used games without looking cluttered.
- Display rack still reads as a used-game rack, and stocked used games still go into the expected slots.
- Used-game cases look compact enough on the rack and while carried; they should not read like oversized display panels.
- Held item stays low/right and does not block navigation.
- Stocked games look upright and intentional.
- Register prompt and sale messages are readable.
- Buyer movement from browsing to rack to register reads clearly and does not clip badly through fixtures.
- Buyer queue spacing is readable and does not overlap the register.
- Buyer spawn, rack approach, and register queue pathing read naturally in the current layout.
- Overpriced-item refusal feedback is readable and does not look like a register failure.
- Apply-to-matching pricing reads clearly and does not make the direct pricing panel feel like a separate terminal.
- Trade-in seller placement, carried item, offer panel, counteroffer controls, cash accept, store-credit accept, decline controls, prompt, and completion message read clearly at the register; the carried item should read as held, not floating through the seller or counter.
- Backroom computer reads as the management terminal, not another register.
- Summary panel text and buttons fit in the actual game window.
- Closed-day report text is readable and understandable after ending the day.
- Recent activity text is readable and distinguishes sales from trade-ins.
- Store-credit trade-in text is readable and clearly separate from cash trade spend.
- Inventory summary text is readable and matches active receiving/rack items.
- Reorder suggestion text is readable and makes sense after selling stocked games.
- Release calendar text is readable, fictional, and clearly planning-oriented.
- Preorder customer, register deposit prompt, completion message, and backroom preorder totals are readable.
- Preorder deposit reads as an obligation/deposit, not a completed sale, and should not imply allocation commitment or launch-day fulfillment yet.
- Category demand text is readable and does not crowd the management panel.
- Market drift text is readable and makes the active inventory value movement understandable.
- Supplier delivery text and `Order Games` button are readable and make clear that cash is reserved before delivery.
- Delivered supplier stock appears as receiving inventory without crowding or floating around the receiving box.
- Fixture order text/button are readable and clearly communicate pending placement.
- Fixture ghost preview is visible, translucent, and not confused with a usable placed rack.
- Placed rack confirmation reads as a deliberate action, and the real rack does not look like another ghost preview.
- Green valid placement and red invalid placement are visually distinct in the actual window.
- Rotated ghost preview is still visually aligned and readable.
- Suspicious event flag infrastructure remains invisible during normal play.
- Optional mismatched serial text is readable when inspecting that copy and does not make the normal store loop feel blocked.
- Supplier note placement and text read as an optional receiving artifact, not a required tutorial or blocking objective.
- Suspicious customer placement and text read as an optional hidden-thread cue, and the customer does not crowd the register queue or trade-in seller.
- Evidence storage remains hidden infrastructure with no visible interruption.

## Automated Screenshot Artifacts

The local gate writes these images under `artifacts/validation/latest/screenshots/`:

- `main_scene.png`
- `receiving_area.png`
- `supplier_message.png`
- `suspicious_customer.png`
- `register_counter.png`
- `customer_queue.png`
- `trade_in_offer.png`
- `preorder_deposit.png`
- `backroom_summary.png`
- `release_calendar.png`
- `supplier_delivery.png`
- `fixture_ghost.png`
- `fixture_invalid_ghost.png`
- `fixture_rotated_ghost.png`
- `fixture_placed.png`
