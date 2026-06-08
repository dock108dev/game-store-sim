# Current Manual Playtest

Use this checklist after `scripts/validate_godot.sh` passes.

## Full Loop

1. Start the main scene.
2. Confirm the front door still blocks exit from the playable store.
3. Aim the center reticle at multiple `Star Trader` copies in the receiving box, click to pick them up, and confirm the carry stack stays low/right.
4. Click to open pricing from the active held item when no world target is selected.
5. Adjust the price, optionally enable apply-to-matching, apply it, and confirm mouse capture returns.
6. On a fresh run or before the sale loop, overprice one `Star Trader` above market tolerance, click to stock it, and confirm a buyer leaves it on the rack with readable feedback.
7. Click to stock a fairly priced game in an empty display rack slot.
8. Confirm one buyer walks to the rack, picks up the game, then queues at the register.
9. Price and stock the next carried `Star Trader`.
10. Confirm a second buyer walks to the rack and queues with readable spacing.
11. Aim at the register and click to ring up the first buyer.
12. Aim at the register and click to ring up the second buyer.
13. Confirm sold items are gone from the rack and no longer inspectable.
14. Click the register when no buyer is queued and review the seller trade-in offer.
15. Confirm the offer panel shows condition, demand, market value, cash offer, and store-credit offer.
16. Use `+ $1` and `- $1` in the trade-in panel and confirm only the cash offer updates.
17. Accept the adjusted cash trade-in and confirm the acquired item appears in the receiving box and can be treated as inventory.
18. On a fresh run, accept the store-credit trade-in and confirm cash does not decrease while the acquired item appears in the receiving box.
19. On a fresh run, decline the trade-in and confirm cash/inventory do not change.
20. Open the backroom computer.
21. Confirm cash, sales count, revenue, cost, profit, trade-in count, trade cash, store credit, recent activity, active inventory summary, and reorder suggestions match the completed sales/trade-in and remaining items.
22. Confirm the release calendar lists fictional upcoming launches with countdown, platform, wholesale cost, suggested price, allocation limit, and demand tier.
23. Clear the trade-in queue by accepting or declining it, then click the register and take the `Neon Skyline` preorder deposit.
24. Confirm cash increases by `$5.00`, sale count/revenue/profit do not change, and the register message reads as a preorder deposit rather than a sale.
25. Open the backroom computer and confirm preorder count and preorder deposits are readable.
26. Confirm the preorder flow clearly reads as an obligation before launch day, not an immediate sale.
27. Clear the preorder queue, then click the register and complete the `Disc Resurfacing` service request.
28. Confirm the service message names `Disc Resurfacing`, `Scratched Orbit Disc`, and `$3.99` profit.
29. Open the backroom computer and confirm service revenue, service cost, service profit, and recent activity are readable.
30. End the day and confirm the closed-day report includes service count, service revenue, service cost, and service profit.
31. Use `Commit Allocation` on the backroom computer and confirm cash drops by `$32.00`.
32. Confirm the backroom computer lists `Neon Skyline x1 committed $32.00 due day 3` and `Release allocations: 1`.
33. Press `Commit Allocation` up to the `Neon Skyline` allocation limit and confirm it stops accepting commitments after four total copies.
34. Confirm allocation commitment reads as launch planning, not stocked inventory, completed preorder fulfillment, or a launch-day sale.
35. End day 1, start day 2, end day 2, then start day 3 and confirm the launch resolves.
36. Confirm `Neon Skyline` preorders fulfill first, surplus allocation copies sell to launch queue demand, launch cash/profit appears, and reputation remains stable when demand is covered.
37. On a fresh run, commit only one launch allocation before day 3 and confirm missed demand reduces reputation with readable launch-event text.
38. Use `Order Storage Rack` on the backroom computer and confirm cash drops by `$125.00`.
39. Confirm the backroom computer lists `Game Display Rack` under pending storage placement and does not imply the rack was already placed.
40. Confirm a translucent rack ghost appears on the sales floor as a pending storage placement preview.
41. Use `Rack Left`, `Rack Right`, `Rack Fwd`, `Rack Back`, `Rotate Rack`, and `Snap Rack` and confirm the preview moves on the grid, rotates cleanly, and remains readable.
42. Use `Place Storage Rack` and confirm a real game display rack appears where the green ghost was.
43. Reopen the backroom computer and confirm pending storage placement is cleared and the rack is listed as placed.
44. Confirm valid placement reads green and invalid placement reads red if the ghost is moved outside allowed bounds by test/debug flow.
45. Confirm rotated and snapped ghost states remain aligned to the floor grid.
46. Confirm the category demand readout is readable and not crowding the rest of the backroom panel.
47. Confirm the market drift readout is readable and makes sense for active inventory.
48. Use `Order Stock` on the backroom computer and confirm cash drops by `$27.00`.
49. Confirm pending receiving says `Used Game Starter Lot`, due day 2, with 3 items.
50. End the day, then use `Start Day` and confirm delivered stock appears in the receiving box and pending receiving clears.
51. End the day and confirm the summary changes to `Day closed`.
52. Confirm the closed-day report is readable and matches the played day.
53. Confirm no visible hidden-thread UI or interruption appears during the normal store loop.
54. If you inspect the third receiving-box `Star Trader`, confirm the serial mismatch text is readable and the item still works with pickup, pricing, stocking, and sale flow.
55. Read the receiving-box supplier note and confirm it is readable, optional, and does not interrupt normal stocking or sales.
56. Talk to the `Cash Buyer` near the register and confirm the conversation reads as optional suspicious behavior, not a required objective.
57. Confirm normal stocking, pricing, buyer queueing, sales, trade-ins, preorder deposit, service completion, allocation commitment, launch-day resolution, and day summary still work after talking to the `Cash Buyer`.
58. Confirm evidence storage remains invisible during normal play; no new objective, panel, or warning should appear yet.

## Visual Checks

- Receiving box contains multiple visible used games without looking cluttered.
- Display rack still reads as a used-game rack, and stocked used games still go into the expected slots.
- Used-game cases look compact enough on the rack and while carried; they should not read like oversized display panels.
- Held item stack stays low/right and does not block navigation.
- Stocking one carried game leaves the remaining carried games visible and usable.
- Stocked games look upright and intentional.
- Register prompt and sale messages are readable.
- Click prompts and the center reticle are readable in the actual game window.
- Buyer movement from browsing to rack to register reads clearly and does not clip badly through fixtures.
- Buyer queue spacing is readable, uses a clear register lane, and does not overlap special register customers.
- Buyer spawn, rack approach, and register queue pathing read naturally in the current layout.
- Overpriced-item refusal feedback is readable and does not look like a register failure.
- Apply-to-matching pricing reads clearly and does not make the direct pricing panel feel like a separate terminal.
- Trade-in seller placement, compact carried item, offer panel, counteroffer controls, cash accept, store-credit accept, decline controls, prompt, and completion message read clearly at the register; the carried item should read as held, not floating through the seller or counter.
- Buyer, trade-in, preorder, service, and suspicious customers should read as separate people with separate jobs, not as one register pileup.
- Used-game cases should look like compact boxed games on the rack, in the player's hand, and in customer hands; they should not read like oversized posters.
- Backroom computer reads as the management terminal, not another register.
- Backroom receiving, storage, management, service/paperwork, and movement zones are visually distinct from normal player angles.
- Receiving pallet, box stacks, storage shelf, and overflow boxes make supplier-delivered stock read as physical inventory without crowding prompts or navigation.
- Backroom service bench, paperwork stack, disc mat, and management board read as context only and do not imply a separate service terminal.
- Summary panel text and buttons fit in the actual game window.
- Closed-day report text is readable and understandable after ending the day.
- Recent activity text is readable and distinguishes sales from trade-ins.
- Store-credit trade-in text is readable and clearly separate from cash trade spend.
- Inventory summary text is readable and matches active receiving/rack items.
- Reorder suggestion text is readable and makes sense after selling stocked games.
- Release calendar text is readable, fictional, and clearly planning-oriented.
- Preorder customer, register deposit prompt, completion message, and backroom preorder totals are readable.
- Preorder deposit reads as an obligation/deposit, not a completed sale before launch day.
- Service customer placement, register prompt, completion message, and backroom/daily-report service totals are readable.
- Service completion reads as register work, not a sale, trade-in, preorder, or separate-terminal workflow.
- Allocation commitment text/button are readable, reserve cash clearly, enforce the release limit, and do not imply stocked inventory before launch day.
- Launch-day resolution text is readable and explains preorder fulfillment, queue fulfillment, missed demand, cash, profit, and reputation.
- Category demand text is readable and does not crowd the management panel.
- Market drift text is readable and makes the active inventory value movement understandable.
- Receiving order text and `Order Stock` button are readable and make clear that cash is reserved before physical stock appears in the receiving box.
- Delivered supplier stock appears as receiving inventory without crowding or floating around the receiving box.
- Storage fixture order text/buttons are readable and clearly communicate pending storage placement.
- Storage fixture movement, rotation, snap, and placement buttons are readable and fit without crowding the backroom panel.
- Fixture ghost preview is visible, translucent, and not confused with a usable placed rack.
- Placed rack confirmation reads as a deliberate action, and the real rack does not look like another ghost preview.
- Green valid placement and red invalid placement are visually distinct in the actual window.
- Rotated ghost preview is still visually aligned and readable.
- Suspicious event flag infrastructure remains invisible during normal play.
- Optional mismatched serial text is readable when inspecting that copy and does not make the normal store loop feel blocked.
- Supplier note placement and text read as an optional receiving artifact, not a required tutorial or blocking objective.
- Suspicious customer placement and text read as an optional hidden-thread cue, and the customer does not crowd the register queue or trade-in seller.
- Evidence storage remains hidden infrastructure with no visible interruption.

## Backroom Polish Focus

Run these first when manually checking the completed backroom spatial pass:

- Confirm receiving, storage, management, service/paperwork, and movement zones read as separate areas from normal player angles.
- Confirm the receiving pallet, box stacks, storage shelf, and overflow boxes add physical receiving/storage identity without hiding prompts.
- Confirm the supplier note and mismatched serial copy remain optional and readable.
- Confirm the management board, computer desk, service bench, disc mat, paperwork stack, and tool tray read as backroom context.
- Confirm the service props do not imply a new service terminal; service completion should still read as register work.
- Confirm fixture ghost, invalid ghost, rotated ghost, and placed rack screenshots still compose clearly with the backroom props.

## Automated Screenshot Artifacts

The local gate writes these images under `artifacts/validation/latest/screenshots/`:

- `main_scene.png`
- `carry_stack.png`
- `receiving_area.png`
- `supplier_message.png`
- `suspicious_customer.png`
- `register_counter.png`
- `customer_queue.png`
- `trade_in_offer.png`
- `preorder_deposit.png`
- `service_request.png`
- `backroom_summary.png`
- `release_calendar.png`
- `release_allocation.png`
- `launch_day.png`
- `supplier_delivery.png`
- `fixture_ghost.png`
- `fixture_invalid_ghost.png`
- `fixture_rotated_ghost.png`
- `fixture_placed.png`
