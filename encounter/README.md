# Replay Junction — R5 assortment

R4 owner feedback **“yes”** accepts handling several customers within scope. R5 adds three fictional games and stocking decisions. R5 owner acceptance remains pending.

## Play

Double-click **Launch Encounter.command**, or run:

```sh
'/Users/michaelfuscoletti/Desktop/game-sim/encounter/Launch Encounter.command'
```

Receive one prepaid copy of each game. Choose each product in the shift desk, enter its price and press **Label / reprice this product**. Open **Assortment** to add individual copies to the four shelf spaces. **Return 1** puts an unsold copy in the backroom with its identity, price and purchase cost intact. Open the shop, serve the numbered queue, close admission, finish admitted visitors, then finalize the report.

| Game | Purchase cost | Reference price | Package |
| --- | --- | --- | --- |
| Curb Circuit 02 | $8.00 | $21.99 | Blue / road |
| Tidebound Atlas | $12.00 | $27.99 | Teal / sailboat |
| Orbit Orchard | $5.00 | $14.99 | Plum / ringed fruit |

The reference is guidance, not a promised sale. Prices can be $1–$99.99. Editing the field alone changes no copy; confirming changes unsold copies of the selected product. Below purchase cost produces a loss. Shelf capacity includes copies temporarily reserved by shoppers; refused copies return to their reserved space. Excess inventory stays in the backroom and is unavailable to shoppers.

At the finalized report, **Per-product report** shows sales, price misses, stock misses, revenue, sold-copy cost and gross profit for each game. Then **Order replenishment** lets you choose 0–6 of each product, previews total and remaining cash, and accepts one nonempty mixed order per day. Advance and receive that paid shipment exactly once. Buying stock reduces cash immediately; its historical cost enters gross profit when the copy sells. Unsold stock and prices carry forward.

Click stations/buttons; WASD/arrows walk; E follows the guided action; K saves; L reloads. Closing stops admission but lets existing customers finish. Finalize is available only after the floor and FIFO queue clear. Report locks all transactions except replenishment and day advance.

## Reproducible assortment comparison

Use **Compare Assortments.command**, separately from ordinary gameplay. Choose `stocked` or `missing`. Each reaches day 2 through the same completed first day and paid two-of-each shipment. Both fill all four shelf spaces at the same prices: Curb $21.99, Tide $19.99, Orbit $12.99. Separate checkpoint files keep the comparison out of ordinary play.

Day 2: Alex seeks Tide, Blair seeks Orbit and Casey seeks Curb. Their budgets are $34.98, $14.24 and $24.18. Serve the queue, close admission, finish admitted customers and finalize:

| Setup | Sales | Stock misses | Revenue | Sold-copy cost | Gross profit |
| --- | --- | --- | --- | --- | --- |
| 2 Curb / 1 Tide / 1 Orbit | 3 | 0 | $54.97 | $25.00 | $29.97 |
| 2 Curb / 2 Tide; Orbit in backroom | 2 | 1 Orbit | $41.98 | $20.00 | $21.98 |

The unavailable copy is retained, not lost. Both have zero price misses. To see a price refusal separately, use ordinary prep with Tide at its $27.99 reference on day 1: Blair declines the locked offer and releases the Tide copy.

Day `d`, visitor index `i`: sought product is `[curb, tide, orbit][(d-1+i) mod 3]`; budget is the sought product's reference times `[110,125,80,95,140][(d-1+2i) mod 5]`, truncated to cents. No random or clock inputs. Each visitor seeks one product and makes one decision. No free shelf copy of that product at selection means a stock miss, with no price evaluation. Otherwise the visitor reserves the oldest available copy, locks its price and buys at or below budget; a higher offer is a price miss. No substitution, retries or multi-item baskets.

The retained **Compare Pricing.command** is historical R3/R4 tooling; use the R5 assortment comparison for this candidate.

## Save and reload

R5 uses `~/Library/Application Support/game-sim-r5-review-isolated/encounter.json`. Prior save namespaces remain untouched. Launch starts fresh; Reload restores the last explicit Save checkpoint. Schema 5 persists physical copies, product identities, historical costs, orders and line costs, roster preferences/budgets, offers, decisions, arrivals, positions, browse progress, FIFO order, phase and ledgers. No reroll or duplicate receiving/decisions occurs on reload. Restoring an earlier checkpoint replays later unsaved events naturally. Unconfirmed order-dialog edits are not saved orders. No earlier-schema migration.

Animation poses and player routes are not saved. Active-shift reload places Rowan at the cashier. New practice shift discards unsaved progress after confirmation and preserves the saved checkpoint.

## Validation and artwork

```sh
cd '/Users/michaelfuscoletti/Desktop/game-sim/encounter'
python3 scripts/validate.py --render --capture
```

This creates a disposable project and unique save namespace, exercises R5 state and scene suites, normal 1280×720 and Retina 2560×1440 controls, and records engine footage of two days plus both assortment comparisons with an explicit draw before every recorded frame, including when the window is occluded. The two-day footage alone can be reproduced with `python3 scripts/capture_full_shift.py`; it checks frame counts and changing pixels. Scene tests run at 3× simulation time. Capture uses an action adapter, including prep allocation and report/order/advance operations; it is agent footage. See [R5 delivery](../docs/03-production/r5-delivery.md) for qualification status and exact evidence.

Retail-v4 source masters, samples, old exports, fixtures and rigs are retained. New `source/case-tide.kra` and `source/case-orbit.kra` are three-layer editable Krita masters with transparent `art/` exports. Rebuild only these two with **scripts/Rebuild Assortment Art.command**. `build_assortment_art.py` extends the existing native painted package recipe; it saves/reopens each master and verifies identical PNG exports. Both are 152×208 (4× the logical 38×52 case). Import: lossless sRGB straight RGBA, alpha-border correction, no mipmaps, linear filtering; `.import` sidecars are retained. The original **Rebuild Art.command** remains for the unchanged fixtures and original case.

Inherited limits remain: rigid/deforming legs, abrupt turns/stops, straight reach, possible foot sliding, mirrored lighting, enlargement artifacts, reused/tinted rig and no detailed cash handoff. Decorative world lettering is not authoritative; essential product names and prices are in the shift desk/dialogs. The recorded capture-exit `ObjectDB instances leaked at exit` warning remains unresolved. Krita's retained Fontconfig/profile/swap/tile warnings are not claimed resolved by successful exports.
