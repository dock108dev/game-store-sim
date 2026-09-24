# Replay Junction — first-week retail

Run a game shop for seven days: arrange and expand displays, price new and used games, serve shoppers, negotiate seller purchases, hire staff, order stock and pay wages and rent. The five-title catalog includes new releases during the week. Technical delivery and owner acceptance are separate; the [owner-review record](../docs/03-production/b10-owner-review.md) holds the pending beta decision.

## Personal Mac delivery

The identified [personal Mac app](../docs/03-production/b9-delivery.md) is the frozen candidate for the ongoing owner review. Read the [prepared owner guide](MAC-OWNER-GUIDE.md), [build instructions](MAC-BUILD.md) and [package qualification record](../docs/03-production/b9-delivery.md). Technical checks do not establish beta acceptance. The launcher below runs the separate development source.

## Play

Double-click **Launch Encounter.command**, or run from the root of the checkout you intend to use:

```sh
zsh 'encounter/Launch Encounter.command'
```

Receive two prepaid copies of each original title (six total, $50 historical cost; no cash charge). Choose each product in the shift desk, enter its price and press **Label / reprice this product**. Select a rack by clicking it or using the rack menu, then open **Assortment** to choose a copy. Rowan walks to that rack to stock it; each rack has four slots. **Return 1** puts an unsold copy in the backroom with its identity, price and purchase cost intact. Open the shop, serve the numbered queue, close admission, finish admitted visitors, then finalize the report.

| Game | Purchase cost | Reference price | Package |
| --- | --- | --- | --- |
| Curb Circuit 02 | $8.00 | $20.00 | Blue / road |
| Tidebound Atlas | $12.00 | $26.00 | Teal / sailboat |
| Orbit Orchard | $5.00 | $14.00 | Plum / ringed fruit |
| Signal Harbor · day 4 | $16.00 | $30.00 | Slate / lighthouse |
| Pocket Rally Club · day 6 | $10.00 | $24.00 | Terracotta / rally car |

The reference is guidance, not a promised sale. Prices can be $1–$99.99. Editing the field alone changes no copy; confirming changes unsold NEW copies of the selected product; used copies have individual labels in Copies / labels. Below purchase cost produces a loss. Shelf capacity includes copies temporarily reserved by shoppers; refused copies return to their reserved space. Excess inventory stays in the backroom and is unavailable to shoppers.

During preparation, **Supplier** lets you choose 0–6 of each released title, previews total and remaining cash, and accepts one nonempty mixed order per day. Receive it that preparation before opening. Unreleased titles are disabled; state rejects early payment too. Reports and open trading permit no supplier purchases. Buying stock reduces cash immediately; its historical cost enters margin when the copy sells. Unsold stock and labels carry forward. **Release calendar** is available from day 1, including expected daily interests. **Assortment / Per-product report** shows sales, price misses, stock misses, revenue, sold-copy cost and margin for all five titles.

Click stations/buttons; WASD/arrows walk; E follows the guided action; K saves visibly; L asks before reload; F1 opens help; Escape opens Menu / Quit. Closing stops admission but lets existing customers finish. Finalize is available only after the floor and FIFO queue clear. Reports on days 1–6 allow day advance; the next preparation allows replenishment. At day-7 close, pay $150 rent. If a due bill cannot be paid in full, the business ends bankrupt, retaining cash and the full unpaid liability. Exactly zero cash after paying bills still survives. No day 8. **Finances** distinguishes merchandise margin, incurred/paid overhead, liabilities, stock purchases, investment and cash; **Daily closes** shows frozen snapshots. Employees hired from day 3 incur $12 each per committed day; wages settle before rent. Backroom plus paid inbound copies cannot exceed 64.

## Arrange the shop

During preparation, select a rack and press **Arrange shop**, or choose **Buy rack · $60**. Click the floor to position the preview (pointer centers the rack footprint); arrows adjust by 10px. Green means valid; red explains the rejection. **Enter / Confirm** applies and **Escape / Cancel** discards it. Buying adds rack-0002 once, changes $550 to $490, and raises total capacity from four to eight slots. Moving is free, including stocked racks. The toolbar shows selected occupancy and total shop capacity.

Finish walking/reaching before arranging. Click clear floor to cancel a pending action. During a preview, confirm or cancel before other business actions. The receiving station, checkout, entry aisle, bottom circulation strip and required routes must stay clear. Layout editing is preparation-only. From day-5 preparation, **North bay · $100** previews the entire enlarged room with rack-0003 at (440,230). Confirm once to buy; blocked routes/ports or insufficient cash reject without payment. Rearrange obstructing racks and retry. Expansion works before or after buying rack-0002; capacity is eight without it, twelve with it. The expanded toolbar moves below the room.

## First-week demand

Days 1–7 bring 3, 4, 5, 6, 7, 8 and 8 shoppers, spaced 18 simulation seconds apart with at most three active buyers. A separate seller arrives at 30 seconds from day 2. Alex, Blair and Casey are joined by Devon (glasses), Ellis (knit cap) and Frankie (headphones); appearances repeat for visitors seven and eight, with separate run/day/ordinal identities.

The first occurrence of each title seeks NEW with 110% of its new reference budget. Repeat occurrences accept new or any used grade and alternate 90%, 80% of the new reference, rounded down to cents. Condition does not scale that budget. A buyer selects the oldest eligible acquisition, then copy ID, locks its price and buys or declines. No substitution, shopper haggling, retries or multi-item baskets. Materialized content persists without rerolls. The assortment comparison remains a development fixture; its earlier numerical results are historical, not current qualification. The retired pricing comparison launcher is removed from maintenance source; ordinary product labels remain supported.

## Save and reload

Schema **10 / b6-retail-1** uses `~/Library/Application Support/game-sim-first-week-dev-v10/encounter.json`. Earlier assortment and schema-6–9 namespaces are untouched. Launch offers New week or Continue and does not automatically load a checkpoint; **Reload** restores the last successful checkpoint; its tooltip names the saved day and phase. Saves persist layout, physical copies, prices/costs, paid events, wage-interface commitments, settlements, terminal results, customer positions/decisions/offers and FIFO order. Earlier schemas are rejected without migration or overwrite.

Settlement, day advance and confirmed expansion automatically checkpoint. Explicit K/Save and L/Reload remain. A failed write leaves the last checkpoint intact and the completed business transaction live; **Retry save** retries persistence only. It never charges again. Reloading an older successful checkpoint discards later unsaved actions; those actions can then be replayed in that restored history. Temporary-file flush and atomic rename are implemented; power-loss durability is not claimed.

**Restart week** asks for confirmation. A terminal run must first be saved as `terminal-<run-id>.json` in the same development namespace; failure blocks restart. A conflicting existing terminal file is never replaced. Successful restart creates a fresh run and checkpoints it. Nonterminal restart discards unsaved progress. Animation poses and player paths are not authoritative save data; reload places Rowan at the legal cashier point. Unconfirmed previews are discarded.

## Validation and artwork

For setup, the basic headless command, tool dependencies and output locations, see [local development](../docs/02-technical/local-development.md). For code and save-schema details, see [encounter architecture](../docs/02-technical/encounter-architecture.md). The following command runs from the repository root. It is an optional rendered/capture check, not required for ordinary documentation changes.

```sh
python3 encounter/scripts/validate.py --render
```

This creates a disposable project and unique save namespace, runs first-week state/regression and pending-price checks, then the integrated seven-day and unexpanded-shop breadth scenes. `--render` adds normal 1280×720 and Retina 2560×1440 controls, screenshots, motion traces and videos. `--capture` also selects these first-week renders. Buttons use viewport input; numeric/dropdown controls use their ordinary signals. State suites are scripted setup; the breadth scene labels its empty-day prelude explicitly. The integrated week starts fresh and uses ordinary controls throughout, with paused save/resume boundaries. Tests use 3× simulation time and Dummy audio: no sound or owner qualification. Older standalone suites remain historical; the selected first-week regression suite rechecks their shared invariants under the final content rules.

Retail-v4 source masters, samples, old exports, fixtures and rigs are retained. New `source/case-tide.kra` and `source/case-orbit.kra` are three-layer editable Krita masters with transparent `art/` exports. Rebuild only these two with **scripts/Rebuild Assortment Art.command**. `build_assortment_art.py` extends the existing native painted package recipe; it saves/reopens each master and verifies identical PNG exports. Both are 152×208 (4× the logical 38×52 case). Import: lossless sRGB straight RGBA, alpha-border correction, no mipmaps, linear filtering; `.import` sidecars are retained. The original **Rebuild Art.command** remains for the unchanged fixtures and original case.

Artwork includes layered editable `source/case-signal.svg` and `source/case-rally.svg` masters with 152×208 PNG exports, plus nine editable front/side/back accessory overlays for Devon, Ellis and Frankie. `scripts/build_week_art.py` rebuilds only these new vector assets using the bundled Sharp runtime. Existing Krita masters/exports are preserved.

Inherited limits remain: rigid/deforming legs, abrupt turns/stops, straight reach, possible foot sliding, mirrored lighting, enlargement artifacts, reused/tinted rig and no detailed cash handoff. Decorative world lettering is not authoritative; essential product names and prices are in the shift desk/dialogs. The recorded capture-exit `ObjectDB instances leaked at exit` warning remains unresolved. Krita's retained Fontconfig/profile/swap/tile warnings are not claimed resolved by successful exports.


## Employees

Morgan and Jules are available from day-3 preparation via **Employees**. Confirm **Hire · $12 today**, then choose Unassigned, Stocking or Checkout. Hiring owes that day's $12 even if dismissed immediately. Existing staff owe a new day's wage when Open is confirmed; dismiss during preparation before opening to avoid it. Reassignment and idle time never cancel an existing commitment. Opening with unassigned staff displays a warning.

Stocking uses one priced backroom copy and a free shelf slot in prep/open. Workers walk through receiving and then the rack before committing. Checkout claims the settled FIFO head and cashier, then walks/reaches before selling. Keep aisles and work ports clear; Rowan blocks workers just as other bodies do. **Stock** keeps player stocking available while open. **Employees → Take over** transfers unfinished work to Rowan, who must travel normally. A completed sale cannot be reversed.

Arrangement pauses workers and releases unfinished jobs. Closing releases unfinished stock jobs and starts no new ones; checkout staff keep draining. Reload preserves employment, wage commitments, inventory and buyer reservations, cancels saved unfinished execution claims and rebuilds routes from legal separated spawns. Finances and Daily closes include actual wages, paid overhead and full unpaid wage/rent liabilities. Technical evidence, source identity and limitations are in [Employment delivery record](../docs/03-production/b4-delivery.md).

## Seller intake and used copies

From day 2, one seller arrives per opening, after 30 shop seconds and a clear entrance. **Seller intake** becomes available once they reach the counter’s upper side, away from the buyer queue. Rowan walks to inspection. Read title, condition, suggested resale and asking price. Send one initial offer; below the floor, the seller discloses one counter. Accept it or send one final offer. A final below-floor offer is refused. **Confirm purchase** pays exactly the accepted amount; no offer automatically buys a copy. Insufficient cash or committed backroom space leaves that accepted amount pending for retry. **Leave pending** preserves the trade; **Cancel trade**, **Refuse seller**, or closing cancels unpaid trades. Completed purchases remain owned.

The new copy is unpriced in backroom and unlocks next preparation. Open **Copies / labels** to see each new/used condition, unique copy ID, actual cost, location and label (hover for acquisition event). Set and apply that copy’s label; Rowan visits receiving. **Shelf +1** targets that exact copy and selected rack; **Return** takes that exact unreserved copy back. Sold copies remain in financial history and are hidden from the editable copy list. Employees use the same claims and can stock or sell eligible used copies. New-product pricing never changes used labels. Used buyers pay the fixed label or decline; there is no shopper haggling.

Days 2–7 offer Curb good, Orbit fair, Tide good, Curb fair, Orbit good and Rally worn. Suggested resale is 80%/60%/40% of the final new reference. Authored ask/floor pairs are $11/$8, $6/$4, $14/$10, $8/$5 and $8/$6. Day-7 worn Rally uses $9.60 resale, $6.72 ask and $4.80 floor. Acquisitions preserve the exact accepted payment. The late day-7 copy cannot be resold within this week. No authored seller brings Signal; generic copy/label/report paths accept all catalog IDs, but ordinary used Signal resale is not an available first-week route.

Finances separates inventory cash spending from the actual acquisition cost of sold stock and merchandise margin. Daily used acquisition does not itself create a merchandise loss. Saves retain disclosed terms and completed trades; reload cancels unfinished employee/player execution claims while preserving copies and buyer reservations. Reloading an older checkpoint discards later unsaved progress, as before. Full displays do not block buying when the 64-copy backroom (including paid inbound reservations) has room. No trade credit, refurbishment or preorders. [First-week delivery](../docs/03-production/b6-delivery.md) records the exact source and isolated evidence. The [personal Mac delivery](../docs/03-production/b9-delivery.md) retains these economic rules; owner acceptance remains pending.

## Player flow

Launch opens New week, Continue (last successful checkpoint), Controls/help and Quit. F1 reopens optional guidance; Escape opens Menu / Quit. K saves visibly; L asks before reload. Save and quit and the window close button preserve progress or offer retry. Malformed/incompatible originals are retained; a separate new week has an active-file locator. Schema 10 and the first-week economy remain unchanged. See [player-flow verification](../docs/03-production/b7-delivery.md), [balance evaluation](../docs/03-production/b8-delivery.md) and [package qualification](../docs/03-production/b9-delivery.md) for exact evidence and limits. Sound content remains intentionally absent; owner review is pending.

## Balance evidence and limits

The unchanged first week supports a delegated growth route ($570.40 cash, $130.40 operating profit), a manual discount route ($795.20 / $255.20), and recovery from poor opening prices ($760.80 / $220.80). No selling can still survive on starting capital while losing $150; survival is not profit. One worker is cheaper than two for the same tested growth sales. The second rack is useful capacity; the tested route does not need the north bay's extra slots.

Automatic movement yields only when a nearby queued or exiting shopper can actually move. This prevents a blocked shopper from freezing the player or worker needed to clear the route. WASD still cancels a trip and permits manual movement; repeated detours should be reported as defects. [Package qualification](../docs/03-production/b9-delivery.md) retains the failure, repair and packaged-play evidence. Complete-week owner judgment remains pending.

## Source maintenance: failure recovery

The separate September 23 source checkout keeps Save and quit open if the checkpoint succeeds but the Continue locator fails, preserves the restart warning, and explains a failed Continue attempt. Save/load diagnostics identify the failed stage without logging checkpoint contents. See [error handling and recovery](../docs/02-technical/error-handling.md). The frozen personal Mac app under owner review does not include these source changes.
