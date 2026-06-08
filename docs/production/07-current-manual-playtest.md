# Current Manual Playtest

Use this checklist after `scripts/validate_godot.sh` passes.

Current automated baseline:

- Last full gate in this fixture placement controls pass: `scripts/validate_godot.sh` passed with 306 GUT tests, UI scenario coverage 309/365, and script mapping coverage 31/31.
- Manual controller/window validation is not performed by Codex; every item below remains a human playtest checklist item until manually checked.
- Store environment production pass is implemented through Stop 2.8; manual QA should now review the full storefront, sales floor, register, fixture, backroom, lighting, screenshot, and navigation composition as one pass.
- Interaction prompt hierarchy is implemented through Stop 3.1; manual QA should confirm action prompts, blocked held-item prompts, feedback messages, and the center reticle states are readable in the actual window.
- Held item presentation is implemented through Stop 3.2; manual QA should confirm the carry pose, depth fan, scale falloff, and subtle motion feel natural without covering the reticle.
- Pickup/place feedback is implemented through Stop 3.3; manual QA should confirm hover highlights, incompatible-stock feedback, and stocking confirmation messages are visible without reading as separate interaction targets.
- Workstation transitions are implemented through Stop 3.4; manual QA should confirm pricing, trade-in appraisal, and backroom computer panels enter with usable focus and exit back to captured first-person control.
- Fixture placement controls are implemented through Stop 3.5; manual QA should confirm movement, rotation, snap, cancel, and place controls are readable and that cancel clears the ghost while refunding cash.
- Current production state: this checklist validates the current prototype/polish build. The June 7 screenshot review shows the build still needs a larger game-completion phase before it reads as production quality; that planning is tracked in `11-game-completion-plan.md`.
- Planning-only docs changes do not add new manual gameplay steps. Any future implementation slice that changes visuals, UI, interaction, customer behavior, scene composition, or player workflow must update this checklist before commit.

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
31. Use `Commit Release` on the backroom computer and confirm cash drops by `$32.00`.
32. Confirm the backroom computer lists `Neon Skyline x1 committed $32.00 due day 3` and `Release allocations: 1`.
33. Press `Commit Release` up to the `Neon Skyline` allocation limit and confirm it stops accepting commitments after four total copies.
34. Confirm allocation commitment reads as launch planning, not stocked inventory, completed preorder fulfillment, or a launch-day sale.
35. End day 1, start day 2, end day 2, then start day 3 and confirm the launch resolves.
36. Confirm `Neon Skyline` preorders fulfill first, surplus allocation copies sell to launch queue demand, launch cash/profit appears, and reputation remains stable when demand is covered.
37. On a fresh run, commit only one launch allocation before day 3 and confirm missed demand reduces reputation with readable launch-event text.
38. Use `Order Rack` on the backroom computer and confirm cash drops by `$125.00`.
39. Confirm the backroom computer lists `Game Display Rack` under pending storage placement and does not imply the rack was already placed.
40. Confirm a translucent rack ghost appears on the sales floor as a pending storage placement preview.
41. Use `Left`, `Right`, `Fwd`, `Back`, `Rotate`, and `Snap` under Storage Placement and confirm the preview moves on the grid, rotates cleanly, and remains readable.
42. Use `Cancel` under Storage Placement and confirm the ghost disappears, pending placement clears, and the `$125.00` rack cost is refunded.
43. Order another rack, use `Place Rack`, and confirm a real game display rack appears where the green ghost was.
44. Reopen the backroom computer and confirm pending storage placement is cleared and the rack is listed as placed.
45. Confirm valid placement reads green and invalid placement reads red if the ghost is moved outside allowed bounds by test/debug flow.
46. Confirm rotated and snapped ghost states remain aligned to the floor grid.
47. Confirm the category demand readout is readable and not crowding the rest of the backroom panel.
48. Confirm the market drift readout is readable and makes sense for active inventory.
49. Use `Order Lot` on the backroom computer and confirm cash drops by `$27.00`.
50. Confirm pending receiving says `Used Game Starter Lot`, due day 2, with 3 items.
51. End the day, then use `Start Day` and confirm delivered stock appears in the receiving box and pending receiving clears.
52. End the day and confirm the summary changes to `Day closed`.
53. Confirm the closed-day report is readable and matches the played day.
54. Confirm no visible hidden-thread UI or interruption appears during the normal store loop.
55. If you inspect the third receiving-box `Star Trader`, confirm the serial mismatch text is readable and the item still works with pickup, pricing, stocking, and sale flow.
56. Read the receiving-box supplier note and confirm it is readable, optional, and does not interrupt normal stocking or sales.
57. Talk to the `Cash Buyer` near the register and confirm the conversation reads as optional suspicious behavior, not a required objective.
58. Confirm normal stocking, pricing, buyer queueing, sales, trade-ins, preorder deposit, service completion, allocation commitment, launch-day resolution, and day summary still work after talking to the `Cash Buyer`.
59. Confirm evidence storage remains invisible during normal play; no new objective, panel, or warning should appear yet.

## Visual Checks

- From player spawn, confirm the screenshot still reads as a validated prototype, not final production art; capture obvious graybox gaps as planning follow-up instead of treating them as current-loop validation failures.
- Receiving box contains multiple visible used games without looking cluttered.
- Display rack still reads as a used-game rack, and stocked used games still go into the expected slots.
- Used-game cases look compact enough on the rack and while carried; they should not read like oversized display panels.
- Used-game case spine, platform band, cover block, and price sticker read as product cues without making the item too busy.
- Rack `USED GAMES` header and slot rails read as category/stocking affordances, not extra interaction targets.
- Receiving intake lanes and `INTAKE` label make the receiving box look organized without hiding the three starter items.
- Held item stack stays low/right and does not block navigation.
- Multi-item held stack fans enough to see separate cases, uses clear active-item focus and depth scale, and leaves the center reticle clear.
- Held item motion feels subtle while walking and settling; it should never read as jitter or screen-center clutter.
- Stocking one carried game leaves the remaining carried games visible and usable.
- Stocked games look upright and intentional.
- Register prompt and sale messages are readable.
- Click prompts clearly separate the action from the subject in the actual game window.
- Blocked held-item prompts and short feedback messages read differently from normal action prompts without hiding the center reticle.
- The center reticle remains readable in normal, blocked, and feedback states.
- Hover highlights on used-game cases and shelf slots are visible, nonblocking, and disappear when the reticle moves away.
- Store lighting, material contrast, and signage make the room read as a small specialty game shop rather than a graybox test room.
- Storefront, shelf, register, receiving, and backroom desk lights create readable warm retail and cooler operations zones without washing out text, prompts, or product cases.
- Production storefront, sales floor, register, fixture, and backroom props remain nonblocking and preserve the core route from entry to rack, register, receiving, storage, and fixture placement.
- Front entry glass, open sign, hours decal, and entry floor cue make the storefront read as a shop threshold without implying the player can leave yet.
- Sales floor route, new-release endcap, and staff-picks stand add merchandising context without blocking entry-to-shelf-to-register movement.
- Register counter scanner, card reader, receipt printer/slip, sleeve stack, impulse rack, customer-side mat, and queue mat make the register read as the command center without blocking checkout.
- Accessory peg wall and locked-case placeholder broaden the fixture language without implying those categories are fully implemented yet.
- `SAVE POINT GAMES`, register, backroom, receiving, storage, and display rack signs are readable, fictional, and do not look like real-brand signage.
- Posters, deal tag, bargain bin, register mat, and controller display props add retail context without blocking movement or obscuring prompts.
- Buyer movement from browsing to rack to register reads clearly and does not clip badly through fixtures.
- Buyer queue spacing is readable, uses a clear register lane, and does not overlap special register customers.
- Buyer spawn, rack approach, and register queue pathing read naturally in the current layout.
- Overpriced-item refusal feedback is readable and does not look like a register failure.
- Apply-to-matching pricing reads clearly and does not make the direct pricing panel feel like a separate terminal.
- Trade-in seller placement, compact carried item, offer panel, counteroffer controls, cash accept, store-credit accept, decline controls, prompt, and completion message read clearly at the register; the carried item should read as held, not floating through the seller or counter.
- Buyer, trade-in, preorder, service, and suspicious customers should read as separate people with separate jobs, not as one register pileup.
- Buyer shopping basket, trade-in tag/item, preorder slip, service disc/ticket, and suspicious note/cash cue should make roles readable before clicking.
- Trade-in, preorder, service, and suspicious customers should form a readable register-area arc that stays clear of the buyer queue lane.
- Used-game cases should look like compact boxed games on the rack, in the player's hand, and in customer hands; they should not read like oversized posters.
- Backroom computer reads as the management terminal, not another register.
- Backroom receiving, storage, management, service/paperwork, and movement zones are visually distinct from normal player angles.
- Receiving pallet, delivery door, box stacks, invoice clipboard, storage shelf, backstock overflow, and labels make supplier-delivered stock read as physical inventory without crowding prompts or navigation.
- Backroom service bench, service ticket, paperwork stack, disc mat, management desk cues, and management board read as context only and do not imply a separate service terminal.
- Safe, security monitor, and evidence-locker placeholders read as future operations/hidden-thread surfaces without exposing an active hidden-thread workflow.
- Backroom computer actions are grouped as Supplier, Storage, Release, Day, and Storage Placement controls.
- Summary panel text and buttons fit in the actual game window.
- Pricing, trade-in appraisal, and backroom computer panels open with visible mouse focus and close back into captured first-person control.
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
- `Commit Release` text/button are readable, reserve cash clearly, enforce the release limit, and do not imply stocked inventory before launch day.
- Launch-day resolution text is readable and explains preorder fulfillment, queue fulfillment, missed demand, cash, profit, and reputation.
- Category demand text is readable and does not crowd the management panel.
- Market drift text is readable and makes the active inventory value movement understandable.
- Receiving order text and `Order Lot` button are readable and make clear that cash is reserved before physical stock appears in the receiving box.
- Delivered supplier stock appears as receiving inventory without crowding or floating around the receiving box.
- Storage fixture order text/buttons are readable and clearly communicate pending storage placement.
- Storage fixture movement, rotation, snap, cancel, and placement buttons are grouped under Storage Placement and fit without crowding the backroom panel.
- Fixture ghost preview is visible, translucent, and not confused with a usable placed rack.
- Placed rack confirmation reads as a deliberate action, and the real rack does not look like another ghost preview.
- Green valid placement and red invalid placement are visually distinct in the actual window.
- Rotated ghost preview is still visually aligned and readable.
- Suspicious event flag infrastructure remains invisible during normal play.
- Optional mismatched serial text is readable when inspecting that copy and does not make the normal store loop feel blocked.
- Supplier note placement and text read as an optional receiving artifact, not a required tutorial or blocking objective.
- Suspicious customer placement and text read as an optional hidden-thread cue, and the customer does not crowd the register queue or trade-in seller.
- Evidence storage remains hidden infrastructure with no visible interruption.

## Production Target Contract Focus

Run these when reviewing the current prototype against the new production direction before starting or after finishing a production implementation slice:

- Confirm `main_scene.png` communicates a small game store target only as a goal, not as current achieved production art.
- Confirm the visual target in `12-production-target-contracts.md` matches the intended store tone: stylized realism, readable retail exaggeration, fictional brand language, and no real brands.
- Confirm the starter layout target keeps the store small and physical: storefront, sales floor, register, backroom, receiving, storage, computer, service bench, and hidden clue surfaces.
- Confirm the completed environment pass reads as one coherent starter shop while preserving receiving, stocking, checkout, trade-ins, preorders, services, ordering, releases, fixture placement, screenshots, and navigation.
- Confirm the UI target covers prompt, pricing, register, trade-in appraisal, backroom computer, ordering, releases, and daily report decisions.
- Confirm the content target is broad enough for several days of play while staying data-first and fictional.
- Confirm future implementation slices update this checklist and `manual_checks.json` when they change the visible store, UI, customers, content, or interaction flow.

## Interaction Polish Focus

Run these first when manually checking the completed Stop 3.1 through Stop 3.3 interaction presentation passes:

- Confirm normal prompts such as pickup, stock, price, register, computer, talk, and inspect read as clear click actions with a target subject.
- Confirm blocked prompts such as fixed-price held-item actions use the warning reticle state and are not mistaken for successful feedback.
- Confirm short feedback messages such as pickup, sale, service, and unavailable-action responses use the feedback reticle state and clear themselves normally.
- Confirm prompt color changes remain readable against the sales floor, backroom, receiving box, register, and computer views.
- Confirm no prompt state hides the center reticle or makes the player uncertain what a click will do.
- Confirm the active carried item remains the most readable case in the stack, with older held items fanned behind it.
- Confirm the carry stack bob/settle motion feels subtle while walking, turning, opening pricing, and stocking one item.
- Confirm new held-item depth and scale changes still make used-game cases read as boxed games rather than flat posters.
- Confirm used-game and shelf-slot hover highlights are visible enough to guide the click target but do not look like finished stocked items.
- Confirm incompatible held items produce blocked stock feedback instead of silently inspecting the slot.
- Confirm stocking a valid item produces a clear landing confirmation naming the stocked item and slot.
- Confirm pricing, trade-in appraisal, and backroom computer panels do not strand mouse focus after Apply, Cancel, Close, Accept, Decline, End Day, or Escape.
- Confirm fixture placement `Cancel` clears the ghost preview, restores the reserved cash, and does not look like placing a rack.

## Backroom Polish Focus

Run these first when manually checking the completed backroom spatial pass:

- Confirm receiving, storage, management, service/paperwork, and movement zones read as separate areas from normal player angles.
- Confirm the receiving pallet, delivery door, box stacks, invoice clipboard, storage shelf, backstock overflow, and labels add physical receiving/storage identity without hiding prompts.
- Confirm the supplier note and mismatched serial copy remain optional and readable.
- Confirm the management board, computer desk, keyboard/task-card cues, service bench, service ticket, disc mat, paperwork stack, and tool tray read as backroom context.
- Confirm the safe, security monitor, and evidence-locker placeholders read as future operations/hidden-thread surfaces and do not present a new active objective.
- Confirm the service props do not imply a new service terminal; service completion should still read as register work.
- Confirm fixture ghost, invalid ghost, rotated ghost, and placed rack screenshots still compose clearly with the backroom props.

## Store Visual Polish Focus

Run these first when manually checking the completed store visual pass:

- Confirm the sales floor reads warmer than the backroom while the reticle, prompts, product cases, and shelf slots stay readable.
- Confirm storefront and shelf accent lights help the store read warmer without blooming over labels or the center reticle.
- Confirm receiving and backroom desk lights stay cooler and support backroom readability without flattening the room.
- Confirm wall, floor, counter, and door colors provide enough contrast from normal player angles.
- Confirm the production storefront cues read clearly: glass panels, `OPEN`, `11-8`, and entry floor cue should feel like a shop threshold while the front-door boundary still blocks exit.
- Confirm the sales floor composition reads more like a small shop: browse-route cue, `NEW RELEASES` endcap, and `STAFF PICKS` stand should help without becoming confusing interaction targets.
- Confirm the register command-center props are readable from player and customer angles and do not make the actual register interaction target ambiguous.
- Confirm the accessory peg wall and locked-case placeholder read as future fixture categories without blocking player or customer movement.
- Confirm production props still leave clear movement through entry, rack, register queue, backroom receiving, storage shelf, and fixture placement preview paths.
- Confirm `SAVE POINT GAMES` and zone signage is readable, fictional, and not mistaken for an interaction target.
- Confirm posters, the price tag, bargain bin, register mat, and controller display feel like store dressing without blocking navigation or hiding click targets.
- Confirm screenshot artifacts still compose clearly after lighting, signage, and clutter changes.

## Product And Fixture Polish Focus

Run these first when manually checking the completed product/fixture presentation pass:

- Confirm used-game cases still look compact on the rack, in receiving, and in the held stack after the added case cues.
- Confirm case cues help products read as boxed games without overwhelming prompts or the reticle.
- Confirm rack header and slot rails clarify stocking/category affordance without looking clickable themselves.
- Confirm receiving intake lanes help organize physical stock and do not hide the supplier note or mismatched serial copy.
- Confirm the fanned carry stack keeps multiple held games visible while staying low/right during movement.

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
