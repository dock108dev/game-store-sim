# Current Manual Playtest

Use this checklist after `scripts/validate_godot.sh` passes.

Current automated baseline:

- Last full gate in this save/load/settings/menu/release-wrapper/alpha-hardening pass: `scripts/validate_godot.sh` passes with 538 GUT tests, UI scenario automation coverage at 492/611, production script mapping coverage at 51/51, 3 active standalone validation tools, and 33 catalog products.
- June 9 manual screenshot review found P0 readability blockers in the actual game window. Treat the alpha package as paused until `16-playability-readability-recovery-plan.md` exits.
- Manual controller/window validation is not performed by Codex; every item below remains a human playtest checklist item until manually checked.
- Store environment production pass is implemented through Stop 2.8; manual QA should now review the full storefront, sales floor, register, fixture, backroom, lighting, screenshot, and navigation composition as one pass.
- Interaction prompt hierarchy is implemented through Stop 3.1; manual QA should confirm action prompts, blocked held-item prompts, feedback messages, and the center reticle states are readable in the actual window.
- Held item presentation is implemented through Stop 3.2; manual QA should confirm the carry pose, depth fan, scale falloff, and subtle motion feel natural without covering the reticle.
- Pickup/place feedback is implemented through Stop 3.3; manual QA should confirm hover highlights, incompatible-stock feedback, and stocking confirmation messages are visible without reading as separate interaction targets.
- Workstation transitions are implemented through Stop 3.4; manual QA should confirm pricing, trade-in appraisal, and backroom computer panels enter with usable focus and exit back to captured first-person control.
- Fixture placement controls are implemented through Stop 3.5; manual QA should confirm movement, rotation, snap, cancel, and place controls are readable and that cancel clears the ghost while refunding cash.
- Input/settings baseline is implemented through Stop 3.6, the expanded settings menu is implemented through Stop 12.3, and pause/main menu is implemented through Stop 12.4; manual QA should confirm Escape opens pause; Resume, Settings, Save/Load, Main Menu, Start Game, and Quit requests are readable; settings still works; and closing menus returns to captured first-person control.
- Interaction validation sync is implemented through Stop 3.7; manual QA should run the Interaction Polish Focus section as one full repeated-workflow review.
- UI component language is implemented through Stop 4.1; manual QA should confirm pricing, trade-in, and backroom computer modals now feel like one production UI family with readable button, panel, disabled, selected, alert, list, stat, and receipt states.
- Register checkout UI is implemented through Stop 4.2; manual QA should confirm sale, preorder, and service checkout panels show itemized lines, subtotal, tax, total, tender, change due, return placeholder, and confirmation feedback before the transaction completes.
- Trade-in appraisal UI is implemented through Stop 4.3; manual QA should confirm condition, completeness, authenticity confidence, market value, demand, projected margin, cash/store-credit offer, counteroffer, and risk notes remain readable.
- Pricing UI is implemented through Stop 4.4; manual QA should confirm cost basis, market price, current price, suggested range, demand, projected margin, apply-to-matching batch scope, and outcome warnings remain readable.
- Backroom computer tabs are implemented through Stop 4.5; manual QA should confirm dashboard, inventory, ordering, releases, reports, services, storage, suppliers, settings, and records tabs are readable and do not hide required actions.
- Supplier ordering UI is implemented through Stop 4.6; manual QA should confirm category, cart, cost, due day, delivery state, storage needs, and receiving expectations stay readable and clearly imply physical receiving stock.
- Daily report UI is implemented through Stop 4.7; manual QA should confirm cash, sales, trade-ins, services, preorders, launch activity, reputation, losses, bills, and tomorrow recommendations fit the report tab.
- UI accessibility pass is implemented through Stop 4.8; manual QA should confirm text size, contrast, keyboard/mouse focus, and 1280x720 panel fit in the actual game window.
- Customer visual-kit, animation baseline, pathing, feedback-bubble, archetype-data, dialogue baseline, and validation sync are implemented through Stop 5.7; manual QA should include the Customer Production Focus checks when reviewing the next playable build.
- Inventory schema expansion is implemented through Stop 6.1; manual QA should confirm product metadata choices read coherently as fictional game-store inventory data while visual differentiation work continues in later Stop 6 slices.
- Product visual generation rules are implemented through Stop 6.2; manual QA should confirm the generated case, disc, cartridge, accessory, console, controller, box, sealed, loose, and service-ticket cues read as distinct physical inventory forms.
- Starter catalog expansion is implemented through Stop 6.3; manual QA should confirm the 33-product fictional catalog feels coherent, broad enough, and not repetitive.
- Condition and authenticity cues are implemented through Stop 6.4; manual QA should confirm scratches, missing manual, loose media, damaged label, reseal, and serial-risk markers read clearly without clutter.
- Shelf label and price tag system is implemented through Stop 6.5; manual QA should confirm category, platform, price, sale, preorder, staff-pick, and bargain tags remain readable without obscuring prompts.
- Product content validation tools are implemented through Stop 6.6; manual QA can rely on the local gate for duplicate IDs, required fields, fictional names, pricing sanity, category coverage, sellable depth, and visual variant coverage before doing human content review.
- Product pipeline validation sync is implemented through Stop 6.7; manual QA should use the Product Content Focus section as the current review surface for schema, visual variants, condition/authenticity cues, shelf tags, catalog breadth, validation manifest coverage, and content tone.
- Production day structure is implemented through Stop 7.1; manual QA should confirm opening, setup, customer-hours, closing, report, and tomorrow-planning language makes the store day feel like an owner/operator loop rather than a debug summary.
- Cash pressure is implemented through Stop 7.2; manual QA should confirm rent reserve, utilities/bills, prepaid supplier terms, payroll/repairs/shrinkage placeholders, operating expenses, and reserved obligations are understandable and do not obscure item gross profit.
- Reputation baseline is implemented through Stop 7.3; manual QA should confirm pricing, wait-time, preorder, service, return, suspicious-choice, stock-variety, and launch-shortage consequences read clearly and feel recoverable.
- Demand tuning is implemented through Stop 7.4; manual QA should confirm shelf visibility, price, rarity, marketing, event, and customer-archetype signals read as understandable demand causes in the backroom panel.
- Upgrade path baseline is implemented through Stop 7.5; manual QA should confirm fixture, category, service, computer, signage, storage, and expansion upgrades read as future work/progression goals rather than cash-only debug options.
- Owner onboarding baseline is implemented through Stop 7.6; manual QA should confirm the backroom dashboard checklist teaches receiving, pricing, stocking, checkout, trade-ins, backroom computer use, ordering, and closing without feeling like debug text.
- Economy progression validation is synced through Stop 7.7; manual QA should run the Economy Progression Focus before treating the milestone as human-approved.
- Receiving workflow is implemented through Stop 8.1; manual QA should confirm delivered supplier batches show delivery point, box state, invoice check, sorting state, pending/completed status, and Open Box/Invoice/Sort controls without feeling like instant inventory teleporting.
- Storage workflow is implemented through Stop 8.2; manual QA should confirm Store/Pull controls, backstock shelf capacity, overflow text, and recent movement history make stock movement feel like backroom work rather than an abstract inventory menu.
- Service bench workflow is implemented through Stop 8.3; manual QA should confirm service capabilities, parts, ticket progress, ready pickup, Start Job/Work Job controls, and register completion read as one physical service workflow.
- Management desk workflow is implemented through Stop 8.4; manual QA should confirm supplier messages, bills, inventory search, report review, preorder planning, upgrade ordering, Review Desk, and Upgrade read as planning work in the backroom records flow.
- Security/safe placeholders are implemented through Stop 8.5; manual QA should confirm cash safe, high-value storage, suspicious goods isolation, and security footage read as inactive backroom/hidden-thread infrastructure, not active objectives.
- Backroom operations validation is synced through Stop 8.6; manual QA should run the Backroom Operations Focus before treating Milestone 8 as human-approved.
- Fixture catalog expansion is implemented through Stop 9.1, placement UX through Stop 9.2, fixture category assignment through Stop 9.3, decoration baseline through Stop 9.4, layout effects through Stop 9.5, starter expansion through Stop 9.6, and building validation sync through Stop 9.7; manual QA should run the Store Building Focus before treating Milestone 9 as human-approved.
- Suspicion rules are implemented through Stop 10.1, clue surfaces through Stop 10.2, choice paths through Stop 10.3, consequences through Stop 10.4, and optionality guards through Stop 10.5; manual QA should run the Hidden Thread Focus checks to confirm the flag catalog, Records-tab clue surfaces, choice paths, consequence effects, and nonblocking guard still read as optional retail anomaly infrastructure rather than active story UI.
- Hidden-thread validation sync is implemented through Stop 10.6; automated checks now audit matrix coverage for flags, dedupe, persistence, optionality, and manual clue-readability checks.
- Store ambience baseline is implemented through Stop 11.1; manual QA should run the Presentation Feel Focus ambience checks to confirm room tone, HVAC, street muffle, door chime, register ambience, backroom ambience, and closing quiet help mood without masking prompts or UI.
- Interaction audio baseline is implemented through Stop 11.2; manual QA should run the Presentation Feel Focus interaction checks to confirm pickup, place, stock, scan, register, cash drawer, computer, button, box, shelf bump, and error cues support actions without becoming noise.
- Customer audio placeholders are implemented through Stop 11.3; manual QA should run the Presentation Feel Focus customer-audio checks to confirm footstep, mumble, greeting, approval, annoyance, and leaving cues add state readability without implying final voice acting.
- Presentation microfeedback is implemented through Stop 11.4; manual QA should run the Presentation Feel Focus microfeedback checks to confirm highlights, item settle, sale confirmation, cash/reputation ticks, day transitions, delivery arrivals, and invalid actions are subtle and semantically clear.
- Camera feel is implemented through Stop 11.5; manual QA should run the Presentation Feel Focus camera checks to confirm movement bob, FOV shift, held-item sway, and workstation settling feel comfortable and do not hide the reticle or prompts.
- Presentation validation sync is implemented through Stop 11.6; automated checks now audit the presentation scenario matrix, manual readability checks, and docs for the completed audio, VFX, and camera-feel pass.
- Save slot UI is implemented through Stop 12.1, and save migration policy is implemented through Stop 12.2; manual QA should run the Save/Load Focus checks to confirm new game, continue, overwrite, delete, metadata readability, compatibility/failure copy, and mouse capture transitions work in the actual window.
- Settings menu is implemented through Stop 12.3; manual QA should run the Settings Focus checks to confirm audio, display, controls, mouse, accessibility, persistence, reset defaults, and modal fit/readability work in the actual window.
- Pause/main menu is implemented through Stop 12.4; manual QA should run the Pause/Main Menu Focus checks to confirm pause mode, main-menu mode, settings/save-load routing, quit request language, and mouse capture recovery work in the actual window.
- Desktop export pipeline is implemented through Stop 12.5; manual QA should run the Release Wrapper Focus checks to confirm pack artifact handoff, binary export template behavior, and future build relaunch/continue expectations are clear.
- Release wrapper validation sync is implemented through Stop 12.6; automated checks now audit the release-wrapper matrix/docs/tool manifest, and manual QA should treat the Release Wrapper Focus section as the current release-readiness checklist.
- Alpha bug triage is implemented through Stop 13.1; manual QA should review `13-alpha-bug-list.md` before treating visual, queue, fixture, backroom-computer, balance, or playtest-package issues as new discoveries.
- Alpha performance pass is implemented through Stop 13.2; manual QA should review `14-alpha-performance-baseline.md` after content-heavy changes and rerun `scripts/measure_alpha_performance.sh --full` before packaging an external playtest.
- Alpha regression-test expansion is implemented through Stop 13.3; automated checks now protect rotated fixture placement bounds, visible buyer-queue spacing, and screenshot scenario coverage for the current alpha P1/P2 bug subjects.
- Alpha scene-readability content pass is implemented as Stop 13.4A; manual QA should review the refreshed screenshot set for store read, sign cropping, special-customer separation, placed-rack framing, and backroom computer first-view controls.
- Alpha content/copy pass is implemented as Stop 13.4B; manual QA should review customer role text, dialogue staff context, supplier order notes, release planning, daily report wording, register return-scope copy, and backroom action labels before treating the alpha copy pass as human-approved.
- Alpha economy balance pass is implemented as Stop 13.5; manual QA should review the tuned $500 starting cash, $10 daily overhead, $30 one-day starter supplier lot, $5.99 disc resurfacing service, buyer tolerance/pricing range, launch allocation, and early upgrade-cost feel before treating balance as human-approved.
- Alpha playtest package is implemented through Stop 13.6 but remains paused until the owner recovery screenshot set passes; manual QA should use `15-alpha-playtest-package.md` only after that owner capture is approved.
- Alpha validation sync is implemented through Stop 13.7; manual QA should treat the gate, pack smoke, package doc, alpha bug list, and this checklist as mechanically current, then run the owner recovery screenshot pass before external playtest.
- Playability readability recovery implementation is complete in `16-playability-readability-recovery-plan.md`; manual QA should review the recovery focus and capture list before approving any new external playtest package.
- Employees-only stockroom production is planned in `17-stockroom-production-plan.md`; manual QA should use the Stockroom Production Focus before and during the next implementation sequence.
- Readability recovery Slice 1 is implemented; manual QA should confirm the fresh spawn, sales-floor route, and backroom entry screenshots now benefit from the wider comfort FOV, taller eye line, farther spawn, and lower/right held-item anchor before moving deeper into signage and UI work.
- Readability recovery Slice 2 is implemented; manual QA should confirm receiving, register, rack, backroom, storage, and retail-callout signs are fixed in-world, compact, and no longer cover starter products or normal register/rack sightlines before moving into interaction and modal legibility.
- Readability recovery Slice 3 is implemented; manual QA should confirm the bottom prompt, center reticle, product hover highlight, shelf slot hover highlight, pickup, pricing-entry, stocking, and lower-priced-copy sale checks are readable before moving into modal/menu legibility.
- Readability recovery Slice 4 is implemented; manual QA should confirm pricing, register checkout, trade-in, preorder/service register states, settings, pause/main menu, and save/load panels use readable text, larger action targets, clear focus, and no clipped tiny controls before moving into customer role readability.
- Readability recovery Slice 5 is implemented; manual QA should confirm buyer, trade-in, preorder, service, and suspicious customer role bubbles stay compact/depth-tested, props remain below head height/off-center, and the register queue does not visually pile up.
- Readability recovery Slice 6 is implemented; manual QA should confirm dashboard, ordering, releases, records, receiving, storage placement, and service bench controls are contextual by tab and no longer crowd every backroom computer screenshot.
- Label depth-safety stabilization is implemented; manual QA should confirm panel-backed signs, receiving/rack labels, and product price tags stay whole when viewed from shallow left and right angles.
- Stockroom planning is implemented; manual QA should confirm future stockroom screenshots prove stock starts behind an employees-only boundary, moves through receiving/backstock, and reaches sales-floor fixtures physically instead of appearing as floor clutter or instant inventory.
- Stockroom Slice 1 is implemented; manual QA should confirm the employees-only threshold, doorway frame, office/service cues, and route floor cue read clearly without blocking carry paths.
- Stockroom Slice 2 is implemented; manual QA should confirm receiving stock sits inside an intentional open-box, invoice, and sorted-tray workflow station rather than reading as products scattered on the floor.
- Stockroom Slice 3 is implemented; manual QA should confirm backstock reads as categorized shelf/bin storage with a pull-stage surface for retrieving products before carrying them to fixtures.
- Stockroom Slice 4 is implemented; manual QA should confirm the backroom computer reads as a manager office workstation with chair, planning board, files, bills, and supplier paperwork context.
- Stockroom Slice 5 is implemented; manual QA should confirm service, safe, security, records, and hold-tray props are readable as secondary support surfaces, not mandatory objectives.
- Current production state: this checklist validates the current prototype/polish build. The June 7 screenshot review shows the build still needs a larger game-completion phase before it reads as production quality; that planning is tracked in `11-game-completion-plan.md`.
- Planning-only docs changes do not add new manual gameplay steps. Any future implementation slice that changes visuals, UI, interaction, customer behavior, scene composition, hidden-thread behavior, or player workflow must update this checklist before commit.
- Every implementation summary should say whether these were checked, skipped, or not relevant.

## Full Loop

1. Start the main scene.
2. Press Escape, confirm the pause menu opens, resume back to play, reopen pause, route into settings, adjust audio/display/mouse/accessibility values, reset defaults, close settings, and confirm first-person mouse capture returns.
3. Confirm the front door still blocks exit from the playable store.
4. Aim the center reticle at multiple `Star Trader` copies in the receiving box, click to pick them up, and confirm the carry stack stays low/right.
5. Click to open pricing from the active held item when no world target is selected.
6. Adjust the price, optionally enable apply-to-matching, apply it, and confirm mouse capture returns.
7. On a fresh run or before the sale loop, overprice one `Star Trader` above market tolerance, click to stock it, and confirm a buyer leaves it on the rack with readable feedback.
8. Click to stock a fairly priced game in an empty display rack slot.
9. Confirm one buyer walks to the rack, picks up the game, then queues at the register.
10. Price and stock the next carried `Star Trader`.
11. Confirm a second buyer walks to the rack and queues with readable spacing.
12. Aim at the register, click to open checkout, review itemized line, subtotal, tax, total, tender, change due, return placeholder, and click Confirm to ring up the first buyer.
13. Aim at the register, click to open checkout, review the same receipt fields, and click Confirm to ring up the second buyer.
14. Confirm sold items are gone from the rack and no longer inspectable.
15. Click the register when no buyer is queued and review the seller trade-in offer.
16. Confirm the offer panel shows condition, demand, market value, cash offer, and store-credit offer.
17. Use `+ $1` and `- $1` in the trade-in panel and confirm only the cash offer updates.
18. Accept the adjusted cash trade-in and confirm the acquired item appears in the receiving box and can be treated as inventory.
19. On a fresh run, accept the store-credit trade-in and confirm cash does not decrease while the acquired item appears in the receiving box.
20. On a fresh run, decline the trade-in and confirm cash/inventory do not change.
21. Open the backroom computer and confirm the dashboard, inventory, ordering, releases, reports, services, storage, suppliers, settings, and records tabs are readable.
22. Use the backroom tabs to confirm cash, sales count, revenue, cost, profit, trade-in count, trade cash, store credit, recent activity, active inventory summary, and reorder suggestions match the completed sales/trade-in and remaining items.
Management desk subcheck: open Records, confirm the management desk lists supplier messages, bill review, inventory search, report review, preorder planning, and upgrade ordering; use `Review Desk` once and confirm the first task becomes reviewed without changing inventory or register state; use `Upgrade` and confirm Computer Analytics is purchased from cash as an upgrade order.
Security placeholder subcheck: in Records, confirm cash safe, high-value storage, suspicious goods isolation, and security footage are listed as placeholders; if a placeholder record exists, confirm it reads as inactive documentation and does not create a register action, inventory teleport, or visible objective.
23. Confirm the release calendar lists fictional upcoming launches with countdown, platform, wholesale cost, suggested price, allocation limit, and demand tier.
24. Clear the trade-in queue by accepting or declining it, then click the register, review the `Neon Skyline` preorder deposit checkout panel, and click Confirm.
25. Confirm cash increases by `$5.00`, sale count/revenue/profit do not change, and the checkout confirmation reads as a preorder deposit rather than a sale.
26. Open the backroom computer and confirm preorder count and preorder deposits are readable.
27. Confirm the preorder flow clearly reads as an obligation before launch day, not an immediate sale.
28. Clear the preorder queue, then click the register, review the `Disc Resurfacing` service checkout panel, and click Confirm.
29. Confirm the service confirmation names `Disc Resurfacing`, `Scratched Orbit Disc`, and `$3.99` profit.
30. Open the backroom computer and confirm service revenue, service cost, service profit, and recent activity are readable.
31. Use `Start Job` on the backroom computer and confirm a `Disc Resurfacing` bench ticket appears with parts, queued state, and `Scratched Orbit Disc`.
32. Use `Work Job` once and confirm the service ticket moves to in-progress with 50% progress.
33. Use `Work Job` again and confirm the service ticket moves to ready-for-pickup with 100% progress and does not complete customer payment from the backroom.
34. Complete the service customer at the register and confirm the service ticket reads as picked up while register service revenue/cost/profit still post normally.
35. End the day and confirm the closed-day report includes service count, service revenue, service cost, and service profit.
36. Use `Commit Release` on the backroom computer and confirm cash drops by `$32.00`.
37. Confirm the backroom computer lists `Neon Skyline x1 committed $32.00 due day 3` and `Release allocations: 1`.
38. Press `Commit Release` up to the `Neon Skyline` allocation limit and confirm it stops accepting commitments after four total copies.
39. Confirm allocation commitment reads as launch planning, not stocked inventory, completed preorder fulfillment, or a launch-day sale.
40. End day 1, start day 2, end day 2, then start day 3 and confirm the launch resolves.
41. Confirm `Neon Skyline` preorders fulfill first, surplus allocation copies sell to launch queue demand, launch cash/profit appears, and reputation remains stable when demand is covered.
42. On a fresh run, commit only one launch allocation before day 3 and confirm missed demand reduces reputation with readable launch-event text.
43. Use `Order Rack` on the backroom computer and confirm cash drops by `$125.00`.
44. Confirm the backroom computer lists `Game Display Rack` under pending storage placement and does not imply the rack was already placed.
45. Confirm a translucent rack ghost appears on the sales floor as a pending storage placement preview.
46. Use `Left`, `Right`, `Fwd`, `Back`, `Rotate`, and `Snap` under Storage Placement and confirm the preview moves on the grid, rotates cleanly, and remains readable.
47. Use `Cancel` under Storage Placement and confirm the ghost disappears, pending placement clears, and the `$125.00` rack cost is refunded.
48. Order another rack, use `Place Rack`, and confirm a real game display rack appears where the green ghost was.
49. Reopen the backroom computer and confirm pending storage placement is cleared and the rack is listed as placed.
50. Confirm valid placement reads green and invalid placement reads red if the ghost is moved outside allowed bounds by test/debug flow.
51. Confirm rotated and snapped ghost states remain aligned to the floor grid.
52. Confirm the category demand readout is readable and not crowding the rest of the backroom panel.
53. Confirm the market drift readout is readable and makes sense for active inventory.
54. Confirm the Settings tab decoration summary lists available decoration categories, surfaces, costs, effects, applied state, and the clutter budget.
55. Use `Apply Decor` and confirm cash drops by `$40.00`, `Savepoint Blue Wall Paint` appears under applied decorations, and `Apply Decor` disables instead of allowing repeat purchase.
56. Confirm the clutter budget still reads as safe after applying the starter wall paint and does not imply props can hide prompts or products.
57. Confirm the demand summary includes `Layout effects` and explains visibility, impulse, queue, travel, and theft placeholder state without crowding the panel.
58. In a test/debug setup with a New Release Wall placed, confirm launch queue demand can increase; in crowded/long/risky layouts, confirm the summary makes the penalty understandable.
59. Confirm `Starter Store Expansion` appears locked before buying `Backroom Storage Bay`, appears available after the storage upgrade is purchased by test/debug setup, and reads as a larger operational footprint.
60. After Starter Store Expansion is purchased in test/debug setup, confirm storage reads as 18 cases and placement/customer layout text implies wider bounds and clearer queue/travel lanes.
61. Use `Order Lot` on the backroom computer and confirm cash drops by `$27.00`.
62. Confirm supplier ordering shows `Used Game Starter Lot`, category, cart size, reserved cost, due day 2, pending delivery state, storage needs, and physical receiving expectations.
63. End the day, then use `Start Day` and confirm delivered stock appears in the receiving box and a pending receiving workflow appears instead of auto-clearing the delivery.
64. Confirm the supplier summary shows delivery point, `Box: sealed`, unchecked invoice count/variance, and sorting waiting state.
65. Use `Open Box` and confirm the box state changes to opened while the batch remains pending receiving.
66. Use `Invoice` and confirm the invoice state changes to checked with expected count, received count, and variance.
67. Use `Sort` and confirm the batch becomes completed, pending receiving clears, and the sorted destination reads as `price_stock`.
68. Use `Store` and confirm one receiving item moves into backstock, the storage summary shows `Backstock: 1 stored / 6 capacity / 0 overflow`, and recent movement reads as stored.
69. Use `Pull` and confirm that item returns to receiving, backstock drops to zero, and recent movement reads as retrieved.
70. Confirm Store/Pull controls disable when there is no valid item for that direction.
71. End the day and confirm the summary changes to `Day closed`.
72. Confirm the closed-day report is readable and matches the played day, including phase, day plan, cash, sales, trade-ins, services, preorders, launch activity, reputation, losses, operating expenses, reserved obligations, bills, and tomorrow recommendations.
73. Confirm no visible hidden-thread UI or interruption appears during the normal store loop.
74. If you inspect the third receiving-box `Star Trader`, confirm the serial mismatch text is readable and the item still works with pickup, pricing, stocking, and sale flow.
75. Read the receiving-box supplier note and confirm it is readable, optional, and does not interrupt normal stocking or sales.
76. Talk to the `Cash Buyer` near the register and confirm the conversation reads as optional suspicious behavior, not a required objective.
77. Confirm normal stocking, pricing, buyer queueing, sales, trade-ins, preorder deposit, service completion, allocation commitment, launch-day resolution, and day summary still work after talking to the `Cash Buyer`.
78. Confirm evidence storage remains invisible during normal play; no new objective, panel, or warning should appear yet.
79. Open Records and confirm the hidden optionality guard says progression is not required, the retail loop is not blocked, and normal receiving, pricing, stocking, register, ordering, storage, services, reports, and day progression remain available.
80. Open the backroom computer settings tab and confirm the upgrade summary lists purchased, available, and locked upgrades clearly.
81. Open the backroom computer dashboard and confirm the owner checklist starts with receiving on a fresh run.
82. As the first-day loop progresses, confirm checklist rows move from `Next`/`Later` to `Done` based on real actions rather than hidden tutorial buttons.
83. Play into the next day and confirm cash, stock, reputation, obligations, upgrade goals, and tomorrow planning read as one connected owner/operator loop.
84. Listen through a normal store loop and confirm room tone, HVAC, storefront muffle, door chime, register bed, backroom bed, and closing quiet remain subtle enough that prompts, modal text, and player decisions are still clear.
85. During pickup, stocking, register, computer, receiving, shelf-blocked, and modal interactions, confirm the interaction sound cue timing makes the action clearer and never implies a different system completed.
86. Listen to buyer, trade-in, preorder, service, and suspicious customers and confirm their placeholder footsteps, mumbles, greetings, approval, annoyance, and leaving cues help distinguish state without covering feedback bubbles or register prompts.
87. Watch target highlights, item settle, sale confirmation, cash/reputation ticks, day transition, delivery arrival, and invalid-action feedback and confirm each reads as the correct kind of event without obscuring prompts or UI.
88. Walk, turn, carry several items, open/close the register, pricing panel, trade-in panel, settings, and backroom computer, and confirm camera bob, FOV shift, held-item sway, and workstation settling remain comfortable and readable.
89. Run a full day loop and confirm ambience, interaction sounds, customer audio placeholders, microfeedback, camera bob, FOV shift, held-item sway, and workstation settling feel like one coherent presentation baseline.
90. Open the save slot panel, create a new game slot, continue from it, overwrite it from an active session, delete it, and confirm each state is clearly labeled before and after the action.
91. Attempt a compatibility or corrupted-save manual smoke when surfaced by the build, and confirm migrated saves load with expected defaults while incompatible or malformed saves fail with clear copy instead of silent data loss.
92. Open settings, adjust audio, display, mouse, and accessibility values, reset bindings/defaults, close and reopen settings, and confirm the saved values and reset language are readable.
93. Open pause, test Resume, Settings, Save/Load, Main Menu, Start Game, and Quit request language, and confirm mouse capture returns after every playable exit path.
94. Run `scripts/verify_desktop_export.sh --pack-smoke`, confirm `artifacts/builds/desktop/game-store-sim.pck` is created and nonempty, and confirm the verifier reports a successful pack boot smoke.
95. Open `docs/production/16-playability-readability-recovery-plan.md`, confirm Slices 1-7 are complete, and do not send the build to a tester until the owner recovery screenshot set passes.
96. Open `docs/production/15-alpha-playtest-package.md`, confirm the package handoff names build commands, artifact paths, known issues, feedback form, rollback plan, and the shorter external playtest script, but treat it as paused pending owner screenshot validation.
97. Confirm `13-alpha-bug-list.md`, `15-alpha-playtest-package.md`, `16-playability-readability-recovery-plan.md`, this checklist, and the latest validation artifacts all describe the same recovery handoff state before sending the build to a tester.

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
- Customer torso, headwear, shoulders, arms, legs, and role silhouette markers should make every customer read as a stylized person rather than a capsule placeholder.
- Customer idle, walk, browse, pickup, queue, talk, payment, handoff, happy-leave, annoyed-leave, and impatient-wait poses should be readable as placeholder animation states rather than static mannequins.
- Customer browse positions, register approach, blocked-path recovery, queue lane, and post-sale leaving should read as one natural store route.
- Customer feedback bubbles for purchase intent, price refusal, impatience, trade-in, preorder, service, and suspicion should be readable without turning into UI clutter.
- Customer archetype data should support browser, target buyer, parent gift buyer, collector, trade-in seller, return customer, service customer, regular, and suspicious contact roles without implying unsupported flows are complete.
- Customer dialogue data should cover help requests, recommendations, trade-in pushback, complaints, and hidden-thread probes without forcing story or return UI into the current register loop.
- Trade-in, preorder, service, and suspicious customers should form a readable register-area arc that stays clear of the buyer queue lane.
- Used-game cases should look like compact boxed games on the rack, in the player's hand, and in customer hands; they should not read like oversized posters.
- Backroom computer reads as the management terminal, not another register.
- Backroom receiving, storage, management, service/paperwork, and movement zones are visually distinct from normal player angles.
- Receiving pallet, delivery door, box stacks, invoice clipboard, storage shelf, backstock overflow, and labels make supplier-delivered stock read as physical inventory without crowding prompts or navigation.
- Backroom service bench, service ticket, paperwork stack, disc mat, management desk cues, and management board read as context only and do not imply a separate service terminal.
- Safe, security monitor, and evidence-locker placeholders read as future operations/hidden-thread surfaces without exposing an active hidden-thread workflow.
- Backroom computer actions are grouped as Supplier, Storage, Release, Day, and Storage Placement controls.
- Backroom computer tabs fit the actual game window and make dashboard, inventory, ordering, releases, reports, services, storage, suppliers, settings, and records feel like task sections rather than one long report.
- Summary panel text and buttons fit in the actual game window.
- Pricing, trade-in appraisal, and backroom computer panels open with visible mouse focus and close back into captured first-person control.
- Closed-day report text is readable and understandable after ending the day, including cash movement, sales, trade-ins, services, preorders, launch activity, reputation, losses, bills, and tomorrow recommendations.
- Day structure text reads as opening, setup, customer-hours, closing, report, and tomorrow-planning phases instead of a loose debug summary.
- Cash pressure text separates gross profit from operating expenses and reserved obligations so the player understands why cash changed after close.
- Reputation event text explains why the score changed and does not hide the link between player decisions and outcomes.
- Demand tuning text explains why visible/featured/rare/discounted/event-relevant inventory is more attractive without replacing the physical stocking and pricing loop.
- Upgrade path text explains fixture, category, service-tool, computer-tool, signage, storage, and expansion progression without making those future systems look already fully implemented.
- Owner checklist text teaches the first-day loop in store-operator language and does not read like debug instructions or a detached tutorial overlay.
- Recent activity text is readable and distinguishes sales from trade-ins.
- Store-credit trade-in text is readable and clearly separate from cash trade spend.
- Inventory summary text is readable and matches active receiving/rack items.
- Reorder suggestion text is readable and makes sense after selling stocked games.
- Release calendar text is readable, fictional, and clearly planning-oriented.
- Preorder customer, register deposit prompt, completion message, and backroom preorder totals are readable.
- Preorder deposit reads as an obligation/deposit, not a completed sale before launch day.
- Service customer placement, register prompt, completion message, and backroom/daily-report service totals are readable.
- Service completion reads as register work, not a sale, trade-in, preorder, or separate-terminal workflow.
- Service bench capabilities, ticket parts, queued/in-progress/ready/picked-up state, Start Job/Work Job controls, and register pickup instruction are readable.
- Backroom service work prepares the ticket but does not bypass customer payment/completion at the register.
- `Commit Release` text/button are readable, reserve cash clearly, enforce the release limit, and do not imply stocked inventory before launch day.
- Launch-day resolution text is readable and explains preorder fulfillment, queue fulfillment, missed demand, cash, profit, and reputation.
- Category demand text is readable and does not crowd the management panel.
- Market drift text is readable and makes the active inventory value movement understandable.
- Receiving order text and `Order Lot` button are readable and make clear that cash is reserved before physical stock appears in the receiving box.
- Supplier ordering category, cart, cost, due day, delivery state, storage needs, and receiving expectation text fit without implying instant inventory teleporting.
- Delivered supplier stock appears as receiving inventory without crowding or floating around the receiving box.
- Receiving workflow text/buttons make delivery point, sealed/opened box state, invoice checked/unchecked state, count variance, sorting destination, pending state, and completion readable.
- `Open Box`, `Invoice`, and `Sort` controls are grouped with supplier receiving work and do not look like register actions.
- Storage workflow text/buttons make receiving-ready count, backstock count, capacity, overflow, and recent Store/Pull movement readable.
- `Store` and `Pull` controls are grouped with storage work and do not look like register actions or a solved inventory menu.
- Storage fixture order text/buttons are readable and clearly communicate pending storage placement.
- Storage fixture movement, rotation, snap, cancel, and placement buttons are grouped under Storage Placement and fit without crowding the backroom panel.
- Fixture ghost preview is visible, translucent, and not confused with a usable placed rack.
- Placed rack confirmation reads as a deliberate action, and the real rack does not look like another ghost preview.
- Green valid placement and red invalid placement are visually distinct in the actual window.
- Rotated ghost preview is still visually aligned and readable.
- Decoration summary, `Apply Decor`, applied-decoration state, and clutter budget fit in the backroom computer and read as store-building choices.
- Decoration choices should not visually hide product cases, shelf slots, register prompts, backroom controls, or customer paths.
- Layout effects text should make it clear when store setup improves visibility/impulse demand or hurts outcomes through tight queues, long walking routes, or open theft-risk placeholders.
- Starter Store Expansion should read as real store growth: more storage, wider fixture placement room, and clearer queue/travel lanes, even before final construction art exists.
- Suspicious event flag infrastructure remains invisible during normal play.
- Optional mismatched serial text is readable when inspecting that copy and does not make the normal store loop feel blocked.
- Supplier note placement and text read as an optional receiving artifact, not a required tutorial or blocking objective.
- Suspicious customer placement and text read as an optional hidden-thread cue, and the customer does not crowd the register queue or trade-in seller.
- Evidence storage remains hidden infrastructure with no visible interruption.
- Store ambience should add a quiet retail bed without making prompts, customer feedback, backroom text, or checkout UI harder to understand.

## Presentation Feel Focus

Run these first when manually checking the completed Stop 11.1 store ambience baseline:

- Confirm room tone and HVAC make the sales floor feel present without creating fatigue during repeated stocking and checkout.
- Confirm the storefront street muffle reads as exterior context near the glass, not a distracting global noise layer.
- Confirm the door chime is short and readable as an entry cue once later trigger playback is enabled.
- Confirm register ambience supports the counter area without masking checkout, trade-in, preorder, or service panel text.
- Confirm backroom ambience reads cooler and more operational than the sales floor while keeping the computer readable.
- Confirm closing quiet feels calmer after the day ends and does not imply the store loop has failed.
- Confirm all ambience remains subordinate to prompts, customer feedback bubbles, and modal UI.
- Confirm pickup/place/stock cues feel like small inventory handling, not sale confirmation.
- Confirm scan/register/cash-drawer cues are distinct enough to separate checkout opening from completed tender.
- Confirm computer and button cues support modal work without making the backroom computer sound like the register.
- Confirm box-open and shelf-bump/error cues communicate receiving or blocked action clearly without sounding like success.
- Confirm interaction cues stay short enough for repeated stocking, pricing, and checkout loops.
- Confirm customer footsteps are subtle enough not to distract from stocking and checkout.
- Confirm customer mumbles and greetings read as nonverbal placeholders, not final voice performance.
- Confirm approval and annoyance cues reinforce visible feedback bubbles without replacing them.
- Confirm leaving cues make completed/abandoned customer flow clearer without masking day-summary or register feedback.
- Confirm suspicious-customer audio remains understated and optional rather than announcing a forced story event.
- Confirm target highlights and item-settle particles are subtle and do not look like extra interactable objects.
- Confirm sale confirmation and cash/reputation ticks are distinct from invalid-action feedback.
- Confirm day transition and delivery-arrival feedback support pacing without hiding report or receiving text.
- Confirm invalid-action feedback reads as blocked/warning feedback and never as a completed sale, delivery, or placement.
- Confirm walking bob is noticeable enough to add motion but subtle enough to avoid discomfort.
- Confirm the movement FOV boost does not distort shelf, register, or backroom-computer reading distance.
- Confirm held-item sway keeps active and stacked items below the center reticle while turning and walking.
- Confirm workstation/modal settling lowers focus smoothly and restores first-person feel after closing the panel.
- Confirm the completed presentation pass supports retail decisions without turning audio, VFX, or camera motion into the focus of play.

## Save/Load Focus

Run these first when manually checking the completed Stop 12.1 save slot UI baseline and Stop 12.2 migration policy:

- Confirm empty slots, saved slots, day number, day phase, cash, reputation, inventory count, and transaction count are readable.
- Confirm New Game does not silently overwrite an existing save.
- Confirm Overwrite and Delete read as deliberate destructive actions.
- Confirm Continue prepares the selected slot and does not imply hidden full-scene restore beyond the current save/load scope.
- Confirm version 1 save data can migrate to the current schema with defaults for newly added arrays and hidden-thread scores when a compatibility smoke is available.
- Confirm future-version or malformed save data fails closed with readable copy and does not load partial or corrupted state.
- Confirm closing the save slot panel restores captured first-person mouse control.

## Settings Focus

Run these first when manually checking the completed Stop 12.3 settings menu:

- Confirm audio rows for master, music, and SFX volume are readable and clamp cleanly.
- Confirm display rows for window mode and render scale are readable and do not imply unsupported graphics options.
- Confirm mouse sensitivity and invert look still feel responsive but bounded.
- Confirm controls summary and Reset Bindings are understandable as defaults, not full remapping UI.
- Confirm accessibility rows for text scale, high contrast, and reduce motion are readable at 1280x720.
- Confirm Reset Defaults restores audio, display, mouse, controls, and accessibility values without unclear destructive copy.
- Confirm settings persist after closing/reopening and closing settings restores captured first-person mouse control.

## Pause/Main Menu Focus

Run these first when manually checking the completed Stop 12.4 pause and main-menu wrapper:

- Confirm Escape opens pause instead of jumping directly to settings.
- Confirm Resume closes pause and restores captured first-person mouse control.
- Confirm Settings and Save/Load route from pause into the correct modal surfaces without leaving overlapping panels.
- Confirm Main Menu switches to a main-menu mode with Start Game, Settings, Save/Load, and Quit readable.
- Confirm Start Game returns to the playable store with captured mouse.
- Confirm Quit communicates a request state clearly without looking like a debug crash/exit.

## Production Target Contract Focus

Run these when reviewing the current prototype against the new production direction before starting or after finishing a production implementation slice:

- Confirm `main_scene.png` communicates a small game store target only as a goal, not as current achieved production art.
- Confirm the visual target in `12-production-target-contracts.md` matches the intended store tone: stylized realism, readable retail exaggeration, fictional brand language, and no real brands.
- Confirm the starter layout target keeps the store small and physical: storefront, sales floor, register, backroom, receiving, storage, computer, service bench, and hidden clue surfaces.
- Confirm the completed environment pass reads as one coherent starter shop while preserving receiving, stocking, checkout, trade-ins, preorders, services, ordering, releases, fixture placement, screenshots, and navigation.
- Confirm the UI target covers prompt, pricing, register, trade-in appraisal, backroom computer, ordering, releases, and daily report decisions.
- Confirm the content target is broad enough for several days of play while staying data-first and fictional.
- Confirm future implementation slices update this checklist and `manual_checks.json` when they change the visible store, UI, customers, content, or interaction flow.

## Product Content Focus

Run these first when manually checking the completed Stop 6.1 through Stop 6.7 product/content pass:

- Confirm product fields now cover category, platform family, format, condition, completeness, authenticity, rarity, demand, cost, market value, risk, and default location.
- Confirm authenticity and risk metadata feel coherent for imperfect used copies, especially loose, missing-manual, poor-condition, and uncertain-origin items.
- Confirm platform-family labels are fictional, consistent, and useful enough to drive later visual rules without resembling real platform branding.
- Confirm generated visual variants cover case, disc, cartridge, accessory, console, controller, box, sealed, loose, and service-ticket forms without becoming visual clutter.
- Confirm product variant cues stay legible at receiving, hand, shelf, customer-held, and register-review scale.
- Confirm the expanded catalog has enough fictional used games, new games, accessories, hardware, and service tickets to support several store days without repeating the same names constantly.
- Confirm new catalog prices and risk/completeness metadata feel plausible before the later economy-balance pass.
- Confirm scratches, missing manual, loose media, damaged label, reseal, and serial-risk cues are readable on relevant products without making every product look damaged.
- Confirm suspicious serial markers read as optional risk cues, not as blocking objectives.
- Confirm category/platform/price labels and sale, preorder, staff-pick, and bargain tags are readable from normal player angles without hiding interaction prompts.
- Confirm tags remain compact when products are in receiving, held, stocked, customer-held, and register-review positions.
- Confirm `scripts/check_product_catalog.py` has passed before manually judging catalog tone, breadth, and price plausibility.
- Confirm `game/tests/validation/tool_checks/product_catalog.json` still describes the active standalone content checker, its covered paths, and its production requirements before adding more product resources.
- Confirm schema updates did not imply that non-used-game categories are already implemented visually; category expansion comes in later product/content slices.

## Economy Progression Focus

Run these first when manually checking the completed Stop 7.1 through Stop 7.7 economy, day-loop, and progression pass:

- Confirm the day structure reads as opening, setup, customer hours, closing, report, and tomorrow planning rather than loose debug state.
- Confirm end-of-day overhead reduces cash once and separates gross profit from operating expenses and reserved obligations.
- Confirm pricing, wait time, preorders, services, returns, suspicious choices, stock variety, and launch shortage reputation changes are understandable and recoverable.
- Confirm demand text explains shelf visibility, price pressure, rarity, marketing, events, and customer archetype signals without replacing physical stocking and pricing decisions.
- Confirm fixture, category, service-tool, computer-tool, signage, storage, and expansion upgrades read as progression goals and future work unlocks.
- Confirm the owner checklist teaches receiving, pricing, stocking, checkout, trade-ins, backroom computer, ordering, and closing in store-operator language.
- Confirm a several-day playthrough makes cash, stock, reputation, obligations, upgrades, and tomorrow planning feel connected.
- Confirm the economy systems create recoverable pressure rather than a dead-end fail state after one bad price, missed sale, or small order.

## Backroom Operations Focus

Run these first when manually checking the completed Stop 8.1 through Stop 8.6 backroom workflows:

- Confirm supplier delivery creates pending receiving work instead of making the order feel solved as soon as the next day starts.
- Confirm delivery point, box state, invoice state, expected/received count, variance, sorting destination, and pending/completed status are readable in the backroom computer.
- Confirm `Open Box`, `Invoice`, and `Sort` buttons enable and disable in a sensible order and fit the supplier/backroom workflow.
- Confirm sorting completion reads as physical backroom work, not register work or an instant inventory menu.
- Confirm storage shelf capacity, backstock count, overflow count, and recent movement history are readable in the storage tab.
- Confirm `Store` moves a receiving item into backstock and `Pull` returns a backstock item to receiving for pricing/stocking.
- Confirm Store/Pull disabled states make sense when there is no receiving item or no backstock item available.
- Confirm service capabilities show disc resurfacing as available, cartridge cleaning as locked, and console test as a placeholder.
- Confirm service ticket parts, progress, ready-for-pickup state, and picked-up state are readable in the Services tab.
- Confirm `Start Job` and `Work Job` controls advance bench work without making the backroom computer feel like the register.
- Confirm customer payment/completion still happens at the register after bench work is ready.
- Confirm the Records tab management desk lists supplier messages, bill review, inventory search, report review, preorder planning, and upgrade ordering as planning tasks.
- Confirm `Review Desk` advances one desk task at a time without moving inventory, completing customer work, or posting register revenue.
- Confirm `Upgrade` purchases Computer Analytics as a cash upgrade order and updates the settings/upgrade summary.
- Confirm management desk text feels like backroom planning, not a standalone register, service terminal, or instant inventory solver.
- Confirm the Records tab lists cash safe, high-value storage, suspicious goods isolation, and security footage as placeholders.
- Confirm security/safe placeholder text stays inactive and does not expose a new hidden-thread objective, warning, register action, or inventory teleport.
- Confirm placeholder records, if present, read as documentation for later hidden-thread work rather than completed security gameplay.

## Store Building Focus

Run these first when manually checking the completed Stop 9.1 through Stop 9.7 store-building pass:

- Confirm the Storage tab lists the expanded fixture catalog: Game Display Rack, Wall Shelf, Accessory Peg Wall, Bargain Bin, Locked Case, Counter Rack, Demo Kiosk, New Release Wall, and Backroom Rack.
- Confirm each fixture entry shows price, broad fixture category, slot count, and placement zone rather than only a debug ID.
- Confirm Accessory Peg Wall and Backroom Rack read as locked behind their upgrade requirements until the related upgrades are purchased.
- Confirm the existing `Order Rack`, preview ghost, placement movement, rotate, snap, cancel, and place flow still works for the Game Display Rack.
- Confirm `Assign Cat` is disabled before a fixture is placed, enables after placement, and assigns the placed rack to `new_game` with readable status text.
- Confirm assigned fixture category text appears in the storage summary and the placed rack's shelf slots accept the assigned category.
- Confirm a matching new-game product on an assigned shelf reads as stronger demand tuning, such as endcap visibility and featured marketing, without replacing physical stocking.
- Confirm unsupported fixture categories are rejected rather than silently changing slot behavior.
- Confirm footprint-aware bounds reject a placement before the full fixture footprint crosses the store placement bounds, not only when the ghost center crosses a line.
- Confirm critical-path clearance and overlap rejection produce readable invalid ghost/issue text instead of allowing a rack to block key routes or stack on another placed fixture.
- Confirm `Undo` stays disabled before an adjustment, enables after movement/rotation/snap, restores the previous preview position or rotation, and disables again when no history remains.
- Confirm ordering a starter rack still reserves cash and creates a pending physical placement, not instant abstract inventory.
- Confirm the demo kiosk reads as a placeholder future gameplay fixture, not a finished playable kiosk objective.
- Confirm the expanded fixture list does not hide storage workflow text, receiving/backstock controls, or placement controls at the target 1280x720 UI size.
- Confirm the fixture catalog reads as store-building planning work in the backroom computer, not register work or customer checkout.
- Confirm the decoration catalog lists wall paint, floor material, posters, signage, lights, display props, and clutter-budget entries with readable costs, surfaces, effects, and applied state.
- Confirm `Apply Decor` applies the starter wall-paint decoration, subtracts cash, updates the applied-decoration summary, and disables after purchase.
- Confirm the clutter budget text reads as a guardrail for future small props, not as permission to hide prompts, stocked products, or movement paths.
- Confirm purchased decoration state persists after save/load or a restored session smoke check.
- Confirm layout effects summarize fixture visibility, impulse fixtures, queue spacing, customer travel distance, and theft-risk placeholder state in store-operator language.
- Confirm placed visibility fixtures and matching fixture categories affect demand text without replacing physical stocking, pricing, and placement work.
- Confirm launch-visibility fixtures can change launch-day queue demand and that crowded, long-walk, or risky layouts read as understandable penalties.
- Confirm main-scene customer queue and travel wiring still reflects the actual CustomerManager pathing rather than a detached abstract score.
- Confirm Starter Store Expansion unlocks only after Backroom Storage Bay and reads as a larger shop footprint rather than an invisible money sink.
- Confirm purchased expansion increases storage capacity to 18 cases and explains wider fixture placement/customer queue/travel lanes.
- Confirm restored saves with Starter Store Expansion preserve the expanded storage and layout state.
- Confirm the validation docs, scenario matrix, and manual checklist all describe the same completed Milestone 9 behavior before moving into hidden-thread production work.

## Hidden Thread Focus

Run these first when manually checking the completed Stop 10.1 through Stop 10.6 hidden-thread baseline:

- Confirm suspicious rule concepts still read as ordinary retail anomalies: serial mismatch, supplier discrepancy, quiet cash buyer, impossible provenance, counterfeit goods, and hidden storage.
- Confirm no new objective marker, warning modal, quest label, or forced progression appears when the existing mismatched serial item, supplier note, suspicious customer, evidence storage, or security placeholders are present.
- Confirm optional hidden-thread artifacts can be inspected or ignored while normal pickup, pricing, stocking, register, supplier ordering, storage, and day-loop work continue.
- Confirm any rule/event summary text shown in debug or future records contexts uses store-operator language and does not expose raw scoring as player-facing quest math.
- Confirm the Records tab lists clue surfaces as invoices, supplier notes, serial lookup, supplier email, customer comment, security clip, and backroom artifact with available/waiting status rather than a required checklist.
- Confirm available clue surfaces line up with normal store context, such as existing supplier notes, mismatched serial stock, suspicious customer comments, security placeholders, and evidence storage.
- Confirm the Records tab lists ignore, document, sell, isolate, report, cash, reject, and supplier follow-up paths as optional choices routed through consequence rules.
- Confirm recording a choice reads as backroom documentation and applies understandable reputation, cash, supplier access, customer trust, inspection risk, and story-state consequences without blocking stock, customer flow, or the day loop.
- Confirm the Records tab optionality guard says progression is not required, the retail loop is not blocked, and normal work remains available.
- Confirm manual validation docs and scenario matrix now describe Stop 10.6 before moving into audio, VFX, and presentation feel.

## Customer Production Focus

Run these first when manually checking the completed Stop 5.1 through Stop 5.7 customer visual-kit, animation baseline, pathing, feedback, archetype-data, dialogue baseline, and validation-sync pass:

- Confirm buyer, trade-in, preorder, service, and suspicious customers read as different people before prompt text appears.
- Confirm customers no longer look like capsule placeholders from the normal player camera.
- Confirm headwear, shoulders, arms, legs, and held props stay readable while customers stand at the register and while buyers walk to the rack.
- Confirm movement, queue, talk, handoff, payment, leave-happy, leave-annoyed, and impatient-wait poses are readable without final art.
- Confirm browsing positions, rack approach, register approach, queue lane, blocked-path recovery, and leaving behavior do not look like teleporting or customers cutting through props.
- Confirm feedback bubbles are readable from normal player angles for price refusal, purchase intent, impatient waiting, trade-in response, preorder confirmation, service pickup, and suspicious cues.
- Confirm the archetype data feels like the right starter customer mix even where future flows such as returns and regulars are still data-only.
- Confirm help, recommendation, trade-in pushback, complaint/return, and hidden-thread probe dialogue has the right tone and stays data-only where UI flows are not implemented yet.
- Confirm the new silhouettes do not hide prompts, stocked games, carried games, or register-counter props.
- Confirm the darker suspicious-customer silhouette reads as optional hidden-thread context without crowding the normal queue.

## Interaction Polish Focus

Run these first when manually checking the completed Stop 3.1 through Stop 3.7 interaction presentation pass:

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
- Confirm settings text/buttons are readable, sensitivity changes feel noticeable but not extreme, invert look reverses vertical mouse movement, and window toggle is understandable.
- Confirm the entire interaction pass reads as one consistent model: center reticle target, left click action, clear blocked feedback, visible carried item, focused modal workstations, and recoverable settings/pause access.

## Menu And Computer UI Focus

Run these first when manually checking the completed Stop 4.1 through Stop 4.9 menu, register, pricing, appraisal, backroom, supplier ordering, report, and accessibility pass:

- Confirm pricing, trade-in, and backroom computer panels read as one UI family while still having distinct pricing, trade-in, and backroom accent identities.
- Confirm button sizes, font sizes, modal frames, disabled controls, hover/pressed/selected states, alert tones, list text, stat headers, and receipt-like readouts remain readable at 1280x720.
- Confirm the shared UI styling does not clip existing pricing, trade-in, fixture placement, release allocation, supplier ordering, or day-summary controls.
- Confirm the register checkout panel reads as the register surface, not the backroom computer, and that Confirm/Close focus returns cleanly to first-person control.
- Confirm sale, preorder, and service checkout variants keep their itemized lines, totals, tender/change, return placeholder, and confirmation feedback readable without clipped text.
- Confirm the trade-in appraisal panel communicates authenticity confidence, projected margin, and risk notes clearly while the counteroffer buttons update the projected margin.
- Confirm the pricing panel communicates current price, suggested range, margin, demand, and warning outcomes clearly while `+ $1`, `- $1`, and apply-to-matching update the decision text.
- Confirm the backroom computer tabs switch cleanly between dashboard, inventory, ordering, releases, reports, services, storage, suppliers, settings, and records without clipping text or making register work look like a backroom action.
- Confirm supplier ordering reads as a small cart/order card with category, item count, reserved cost, due day, delivery state, storage requirement, and physical receiving expectation.
- Confirm the daily report reads as an end-of-day report rather than a raw ledger dump, with cash, sales, trade-ins, services, preorders, launch activity, reputation, losses, bills, and tomorrow recommendations still fitting the report tab.
- Confirm the shared accessibility pass holds up in the actual window: readable text size, sufficient contrast, focusable controls, visible mouse focus, and no clipped production modal at 1280x720.

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

## Release Wrapper Focus

Run these first when manually checking the completed Stop 12.5 desktop export pipeline:

- Run `scripts/verify_desktop_export.sh --pack-smoke` from the repository root and confirm it exports `artifacts/builds/desktop/game-store-sim.pck`.
- Confirm the verifier boots the pack, reports `Desktop pack export smoke passed`, and lists `desktop-export.log` plus `desktop-pack-boot.log`.
- Confirm the pack artifact is nonempty and the artifact path is suitable for release handoff notes.
- Run `scripts/verify_desktop_export.sh --binary` only on a machine with matching Godot 4.6.2 export templates and expected macOS signing state; if templates are missing, confirm the failure message clearly says to install templates or use `--pack-smoke`.
- Once binary export templates are installed, launch the exported app outside the editor and run the start, save, quit, relaunch, and continue loop.
- Confirm settings persistence and pause/main-menu transitions behave the same in the exported build as in the editor-run vertical slice.

## Alpha Bug Triage Focus

Run these first when manually checking the completed Stop 13.1 alpha bug triage:

- Open `docs/production/13-alpha-bug-list.md` and confirm AH-001 through AH-011 still match the latest screenshot artifacts.
- Confirm there are no hidden P0 issues in the latest `scripts/validate_godot.sh` output before starting performance, regression, content, balance, or playtest-package work.
- Confirm each newly found visual/readability/playtest issue is either already covered by AH-001 through AH-011 or is added to the bug list with evidence, priority, target slice, and acceptance.

## Alpha Performance Focus

Run these first when manually checking the completed Stop 13.2 performance pass:

- Run `scripts/measure_alpha_performance.sh --full` and confirm it writes core and shell reports under `artifacts/performance/latest/`.
- Compare current results to `docs/production/14-alpha-performance-baseline.md`; investigate any large change even if the broad threshold still passes.
- After content-heavy work, confirm screenshot capture and exported pack startup remain within the broad alpha thresholds before creating a playtest package.

## Alpha Regression Focus

Run these first when manually checking the completed Stop 13.3 regression-test expansion:

- Confirm the latest full gate reports the rotated fixture placement, buyer queue spacing, and alpha screenshot subject coverage tests as passing before content-heavy scene edits.
- Review `customer_queue.png`, `register_counter.png`, `fixture_placed.png`, `fixture_ghost.png`, `fixture_rotated_ghost.png`, `release_calendar.png`, `release_allocation.png`, and `launch_day.png` after any visual/UI pass and compare them against AH-004, AH-005, and AH-008.
- Treat new queue overlap, fixture framing, or screenshot subject-framing problems as alpha bugs with a documented ID, evidence image, target slice, and acceptance note before packaging a playtest.

## Alpha Scene Readability Focus

Run these first when manually checking the completed Stop 13.4A scene-readability pass:

- Compare `main_scene.png`, `customer_queue.png`, `register_counter.png`, `fixture_placed.png`, and `backroom_summary.png` against AH-001 through AH-007.
- Confirm right-wall and back-wall detail props reduce the blank graybox read without hiding products, customer silhouettes, or navigation space.
- Confirm the smaller register/backroom signs are readable and no longer dominate or crop badly from normal screenshot angles.
- Confirm preorder, service, suspicious, and trade-in customers have clearer depth separation and do not create a label or prop pileup at the register.
- Confirm the placed fixture reads as an intentional rack with visible face/profile cues instead of a camera-blocking slab.
- Confirm the backroom computer first view exposes the major action groups and storage-placement row without relying on hidden lower content.

## Alpha Content Copy Focus

Run these first when manually checking the completed Stop 13.4B content/copy pass:

- Confirm buyer, browser, parent, collector, regular, trade-in, return, service, and suspicious customer copy reads as distinct store visitors rather than generic debug labels.
- Confirm dialogue staff notes reinforce the intended responsibility split: register for sales, returns, trade-ins, preorders, and services; backroom computer for orders, reports, releases, suppliers, storage, and records.
- Confirm supplier ordering explains crate contents, invoice check, shelf plan, receiving box work, and next physical actions without implying instant inventory teleporting.
- Confirm release calendar/planning text makes launch hooks, allocation limits, and new-release wall work clear at 1280x720.
- Confirm daily report sections read as an end-of-day owner readout, with cash drawer, counter work, margin, operating pressure, launch activity, reputation, bills, and tomorrow plan easy to scan.
- Confirm register return-scope copy is clear and does not imply returns are fully implemented.
- Confirm `Order`, `Invoice`, `Category`, `Start Job`, `Work Job`, `Upgrade`, and related backroom controls are readable in the actual window and do not overflow their buttons.

## Alpha Balance Focus

Run these first when manually checking the completed Stop 13.5 balance pass:

- Start from a fresh game and confirm the opening $500 cash, $10 daily overhead, and $30 starter supplier lot make the first day feel pressured but recoverable.
- Price the starter used games within and above the suggested range; confirm buyers still buy fair copies and reject overpriced copies in a way that matches the displayed demand guidance.
- Order the starter supplier lot, close the day, and confirm the one-day delivery, receiving work, and cash movement are understandable.
- Complete the $5.99 disc resurfacing service and confirm the register, report, recent activity, and service bench readouts show revenue, $1.25 parts cost, and $4.74 profit clearly.
- Reserve a Neon Skyline launch allocation and play into launch day; confirm allocation cost, preorder/queue fulfillment, missed-demand reputation changes, and launch cash are understandable.
- Buy early upgrades such as Staff Picks Signage, Computer Analytics, and Backroom Storage Bay; confirm the lower alpha costs feel like reachable goals without making progression trivial.

## Alpha Playtest Package Focus

Run these first when manually checking the completed Stop 13.6 external playtest package:

- Run `scripts/validate_godot.sh` and `scripts/verify_desktop_export.sh --pack-smoke`, then confirm `artifacts/builds/desktop/game-store-sim.pck`, `artifacts/builds/desktop/pack-smoke.log`, `artifacts/validation/latest/gut-results.xml`, and `artifacts/validation/latest/screenshots/` are present.
- If a runnable app is not produced, confirm the package notes clearly name the local Godot export template or macOS signing blocker rather than implying binary export was validated.
- Hand the tester `15-alpha-playtest-package.md` and confirm the shorter script covers fresh start, settings, receiving, pricing, stocking, sale, trade-in, preorder, service, backroom, supplier delivery, launch allocation, save/load, and feedback.
- Confirm the tester feedback form records build, platform, session length, blockers, confusing steps, economy feel, customer behavior, backroom/computer notes, menu/settings/save notes, bugs, screenshots/logs, and whether the tester would play another in-game day.
- Add accepted external feedback to `13-alpha-bug-list.md` with evidence, priority, target slice, and acceptance criteria before implementing follow-up changes.
- Confirm rollback guidance names the known-good Stop 13.5, Stop 13.4B, and Stop 13.4A checkpoints and requires a fresh full gate before sharing another package.

## Alpha Validation Sync Focus

Run these first when manually checking the completed Stop 13.7 alpha validation sync:

- Confirm `scripts/validate_godot.sh` is green for the current branch and reports 538 GUT tests, 492/611 UI scenario automation coverage, 51/51 production script mapping coverage, 3 active standalone validation tools, and 33 catalog products.
- Confirm the latest desktop pack smoke created `artifacts/builds/desktop/game-store-sim.pck` and that `15-alpha-playtest-package.md` still names the same artifact path and known binary-template/signing limits.
- Confirm `13-alpha-bug-list.md` routes AH-009 and AH-010 as done, keeps AH-011 tied to human balance feel, and keeps AH-006/AH-012/AH-013/AH-014/AH-015 routed to owner recovery screenshot validation.
- Confirm this manual checklist includes Alpha Bug Triage, Performance, Regression, Scene Readability, Content Copy, Balance, Playtest Package, and Validation Sync focus sections.
- Treat the alpha-hardening milestone as mechanically validated but not human-approved until the owner recovery screenshot set and the external playtest script are run in real windows.

## Playability Readability Recovery Focus

Run these first before attempting another external alpha playtest:

- Review `docs/production/16-playability-readability-recovery-plan.md` and confirm Slices 1-7 are complete and the owner screenshot pass is the current gate.
- Compare the June 9 manual screenshots `intro_1.png`, `receiveing.png`, `intro_2.png`, and `pricing.png` against AH-012 through AH-015 in `13-alpha-bug-list.md`.
- Confirm the first recovery slice fixes camera scale, ceiling dominance, near-camera prop dominance, and spawn composition before deeper UI polish begins.
- Confirm the player now starts farther from the register/special-customer pileup, sees more of the store at 1280x720, and carries items low/right without blocking the reticle.
- Confirm the second recovery slice keeps oversized signage fixed: starter receiving products remain visible, the `INTAKE` tag stays compact, and rack/register signs do not become foreground slabs.
- Confirm the third recovery slice keeps the larger bottom prompt readable, the reticle visible, hover targets obvious, and lower-priced-copy sale feedback understandable without relying on debug knowledge.
- Confirm the fourth recovery slice keeps pricing, register, trade-in, preorder, service, settings, pause/main menu, and save/load panels comfortably readable in the actual window with clear button hierarchy and mouse focus.
- Confirm the fifth recovery slice keeps buyer, trade-in, preorder, service, and suspicious customer role bubbles compact, consistent, depth-tested, and useful without dominating the store view or crowding the register queue.
- Confirm the sixth recovery slice keeps the backroom dashboard, ordering, releases, records, receiving workflow, storage placement, and service ticket controls contextual by tab so the lower frame is not crowded by unrelated action rows.
- Confirm the label depth-safety stabilization keeps panel-backed signs, receiving/rack labels, and product price tags fully visible from shallow left/right viewing angles; fail the owner screenshot pass if a label loses a side based on camera angle.
- Confirm the backroom entry, dashboard, ordering, releases, records, receiving workflow, and service ticket screens read as operations space rather than dense debug UI.
- Rerun the short recovery screenshot set before reopening `15-alpha-playtest-package.md`; keep the package paused if any capture is still unreadable.

## Stockroom Production Focus

Run these first when manually checking the upcoming employees-only stockroom implementation:

- Review `docs/production/17-stockroom-production-plan.md` and confirm the next implementation slices keep the backroom physical rather than adding another abstract inventory menu.
- Capture `43_stockroom_staff_threshold.png` from the sales-floor side and confirm the player understands the area is employees-only without a giant sign blocking the route.
- Capture `44_stockroom_route_to_sales_floor.png` from just inside the staff threshold and confirm the floor cue gives a clear receiving/backstock-to-sales-floor carry route.
- Capture `45_receiving_intake_station.png` and confirm delivered stock appears in an intentional delivery/pallet/intake station with open-box flaps, invoice cue, and sorted tray, not loose on the floor.
- Capture `04_receiving_box_before_pickup.png` and confirm the starter products are visible inside the receiving box with the compact open/invoice/sort state cards readable from a normal standing angle.
- Capture `32_open_box_invoice_sort.png` and confirm the computer receiving workflow visually matches the world station: open box, invoice clipboard, and sorted destination are all understandable.
- Capture `46_backstock_shelving.png` and confirm stored products read as categorized backstock on shelves, bins, and overflow shelf, not as floor storage.
- Capture `47_backstock_pull_stage.png` and confirm pulled stock has an obvious `PULL` staging surface between the shelf and carry route before the player carries it to sales-floor fixtures.
- Capture `48_manager_office_context.png` and confirm the computer reads as a manager office workstation with chair, planning board, file boxes, bills, and supplier paperwork.
- Capture `20_service_bench_ticket.png` and confirm the service bench reads through disc mat, ticket, tools, parts bin, and ready shelf without requiring the computer panel to explain it.
- Capture `49_service_safe_records_corner.png` and confirm service, safe, security, records files, high-value shelf, and `HOLD` tray props remain secondary and do not look like mandatory objectives.
- Capture `50_storage_tab_physical_flow.png` and confirm the computer copy explains where stock appears and what physical action the player should take next.
- Confirm stockroom lighting/materials stay cooler and operational while preserving prompt, reticle, product-label, and computer readability at 1280x720.
- Keep `15-alpha-playtest-package.md` paused if any stockroom screenshot still reads as floor clutter, debug props, or instant inventory.

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
