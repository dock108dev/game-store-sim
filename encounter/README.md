# Replay Junction — R3 pricing consequences

Owner R2 feedback **“build on.”** accepts the bounded repeatable business day and authorizes R3. R3 acceptance remains pending; automated evidence is separate from owner judgment. Existing animation limits remain.

## Play

Double-click **Launch Encounter.command**, or run:

```sh
'/Users/michaelfuscoletti/Desktop/game-sim/encounter/Launch Encounter.command'
```

Receive → choose price → print labels → stock → open → watch the visitor browse → complete a purchase, or watch a price refusal → close and review. During prep, **Apply price to unsold stock** relabels both shelf and backroom copies. Printing initial labels still affects backroom copies only. Changing the field alone changes no stock. The input bounds are $1.00–$99.99; the bounded number control clamps out-of-range numeric input. The state rejects invalid, fractional-cent and nonnumeric prices. The price field previews profit per sale; its tooltip explains below-cost loss and demand risk.

At the report, optionally order 1–6 copies at $8 each within cash, advance, receive once, and make your next pricing decision. Unsold copies remain; the next visitor takes the oldest available copy. One visitor per day remains the bounded scope. Click controls/stations; WASD/arrows walk; E interacts; K saves; L reloads. New practice shift confirms discarding unsaved progress and retains the save.

R3 saves use `~/Library/Application Support/game-sim-r3-review-isolated/encounter.json`. R1/R2 saves and all prior samples/evidence remain untouched. Launch starts fresh; Reload is explicit. Schema 3 saves do not migrate earlier schemas.

## Short pricing comparison

Double-click **Compare Pricing.command** and enter `low`, `reference`, or `high`. Each starts the same fresh day-1 visitor, visibly marked PRICING DEMO, using separate demo save files. Repeat receive → label → stock → open for each choice. Low $16.99 and reference $21.99 buy; high $26.99 declines. Close to compare margin and price misses. In the high run, advance without ordering, enter $16.99, apply it to unsold stock, and open: the retained copy can now sell. Ordinary gameplay has no scenario selector or demand overrides.

For a broader reproducible comparison, validation runs the same five daily visitor scenarios at each price. Budgets are $24.18, $27.48, $17.59, $20.89 and $30.78; the cycle repeats. At $16.99: 5 sales, $84.95 revenue, $44.95 margin. At $21.99: 3 sales, $65.97 revenue, $41.97 margin. At $26.99: 2 sales, $53.98 revenue, $37.98 margin. High-price buyers earn $18.99 per sale versus $8.99 at low price. This is a small authored demand model, not a calibrated economic simulation; reference price is not a guaranteed optimum.

## Demand, accounting and persistence

Curb Circuit 02 has reference value $21.99. The daily visitor's willingness is reference value × a repeating 110%, 125%, 80%, 95%, 140% schedule, rounded down to cents. No random draw or wall-clock input is used. At shelf selection, the physical copy, offered price and willingness become fixed and are saved. At the end of browsing, offer ≤ willingness buys; a higher offer declines. The decision ledger stores one outcome per day/customer. Repeating a decision does not append another event. All price changes are prep-only, and checkout verifies the locked offer. A refusal releases the copy's reservation, leaves stock and cash unchanged, and sends the customer out without a case.

Daily results show completed sales, price misses, revenue, sold-copy cost, gross profit, remaining stock and cash. Price misses count actual price refusals, not customers dismissed by early closing. Gross profit is revenue minus $8 per copy sold, before overhead. Cash is $550 plus all sales minus paid orders; starter copies are prepaid. Unsold inventory is not expensed. Daily counts reset on advancement; decisions, sales, orders, cash and unsold physical copies persist. Saves validate ledger identity, exclusive ownership and exactly-once events before replacing live state. Walking/animation resumes from coherent checkpoints, not exact poses.

## Evidence and reproduction

```sh
cd '/Users/michaelfuscoletti/Desktop/game-sim/encounter'
python3 scripts/validate.py --render --capture
```

Validation imports a disposable project and unique save namespace; it runs R1/R2 regressions, five-scenario pricing/state tests and actual scene interactions at normal and Retina resolutions. Capture records the actual engine's high-price refusal, day transition, repricing and purchase. Recording uses an action adapter; it is agent-generated gameplay, not owner input. Exact identity, preservation and evidence pointers are in `evidence/r3/` and the [R3 delivery report](../docs/03-production/r3-delivery.md).

## Art workflow

Retail-v4 directional cutouts, context and pivots are copied unchanged into `art/`. Their editable masters and production recipe remain in `../samples/b-retail-v4/source/masters/` and `../samples/b-retail-v4/scripts/Rebuild Art.command`. Both standalone samples and the historical game are preserved.

New layered masters: `source/counter.kra`, `case.kra`, `shipment.kra`, and `retail-shelf-empty.kra`. The latter derives from the retained shelf master by hiding its decorative case layer; the physical cases are separate runtime sprites. Rebuild using `scripts/Rebuild Art.command`; `scripts/build_art.py` is the deterministic native Krita recipe. It saves and reopens every new master, exports PNG, and verifies identical bytes. Run in a disposable copy when retaining prior build logs is important.

PNG: sRGB, straight RGBA, lossless Godot import, linear filtering, mipmaps off, alpha-border correction on; committed-style `.import` sidecars are retained as uncommitted files. Source assets are authored at 4× logical size. Environment props display at .25; case display is .17 on shelf and .085 in hand. Shelf root (640,390), image offset (-125,-115); counter root (785,540), offset (-100,-110); shipment root (310,455), offset (-39,-62). Character feet and limb pivots are in `art/rig.json`, scaled to 110 logical pixels high. `actor.gd` adapts the existing directional rig/pose implementation to separate actors. The old authored-frame comparison remains only in the preserved samples.

Known limits: rigid/deforming legs, abrupt turns/stops, straight-arm reach, possible foot sliding, mirrored lighting and enlarged outline/hidden-surface artifacts. The single customer reuses Rowan's rig with a warm tint and role label; distinct customer identity is deferred. Hands do not animate a detailed cash/register exchange. Shelf/case lettering is decorative; essential price/stock/report text is 18+ logical pixels (world labels 16–17). Krita emits retained Fontconfig/profile/swap/tile warnings; successful reopened exports establish the bounded production result, not warning-free Krita operation.
