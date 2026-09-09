# R5 — small assortment and stocking decisions

**Implemented, verified and ready for owner review. R5 owner acceptance remains pending.**

## Owner authority and boundary

Owner R4 feedback: **“yes”**, confirming that handling several customers is clear and enjoyable enough to build on. This accepts R4 within scope and authorizes R5. R1–R3 acceptance remains. It does not accept R5, animation quality, the full game or a release.

Three original fictional games total; the existing illustrated retail-v4 shop, four visible shelf positions and three-person wave. No expansion, large catalog, substitution, multi-item baskets, promotions, reputation, employees or broad animation reconstruction. No commit, push or publication.

## Product and transaction contract

| Product | Purchase cost | Reference | Package |
| --- | --- | --- | --- |
| Curb Circuit 02 | $8.00 | $21.99 | Retained blue road design |
| Tidebound Atlas | $12.00 | $27.99 | New teal sailboat design |
| Orbit Orchard | $5.00 | $14.99 | New plum ringed-fruit design |

Starter shipment contains one prepaid copy of each product. The report permits one nonempty mixed order per day, 0–6 copies per product, only within available cash. Payment is atomic. The order stores quantities and unit purchase costs; next-day receiving creates unique order/day/product/copy IDs exactly once. A sold copy contributes its stored historical cost to gross profit. Repricing never changes cost or past sales.

During prep, select a product and apply its price to unsold copies; editing the field alone does not alter labels. Prices are $1–$99.99, with below-cost losses permitted. The Assortment dialog compares costs/reference prices and lets the player stock or return one copy at a time. Four physical spaces are shared across products. Reserved copies still occupy capacity until sold or released. Excess stays in the backroom; opening with retained backroom stock is legal. Returning an unsold shelf copy is prep-only and preserves identity, price and cost.

The three stable visitors keep staggered arrivals, exclusive reservations, locked offers and persisted FIFO. Each seeks exactly one identified product. For day d and visitor index i, preference is `[curb,tide,orbit][(d-1+i)%3]`. Budget is that product's reference times the retained `[110,125,80,95,140][(d-1+2i)%5]` percent, truncated to cents. No randomness, time-dependent input or reroll. This is a small authored model, not a calibrated commercial forecast.

At selection, no free shelf copy of the sought product records exactly one **stock miss** with no offer or price evaluation. A backroom copy does not satisfy demand. Otherwise reserve the oldest free copy of that product, lock its identity and price, then buy at or below the fixed budget. A higher offer records exactly one **price miss** and releases the reservation back to the shelf. No substitution, retry or basket expansion. Checkout checks product, owner, locked offer and settled queue head before recording a sale once.

The accepted R4 phase contract remains: closing cancels unadmitted visitors but allows existing browsing and purchases; finalization requires a clear floor/queue and locks sales. Report shows per-product sales, both miss types, revenue, sold-copy cost and gross profit before replenishing. Product sums reconcile to daily totals; cash includes cumulative revenue less paid orders. Gross profit excludes overhead.

Schema 5 persists copies/products/costs, mixed orders, preferences, budgets, arrivals/clock, positions, browse progress, offers, decisions, FIFO, phase and ledgers in a separate R5 namespace. Save/Reload restores the explicit checkpoint, never rerolls demand. Unconfirmed order-dialog edits are not orders or saved state. Earlier checkpoints can naturally replay later unsaved actions. Animation poses/player paths remain unsaved; active reload restores Rowan at the cashier. No old-save migration.

## Qualification

[Final state and rendered qualification](../../encounter/evidence/validation-20260909T020530374063Z/): **110 state checks**, and **54 scene checks in each of headless, normal 1280×720 and Retina 2560×1440 runs**, Godot 4.6.2 / Apple M3 Pro. Scene simulation uses 3× time. Runtime source and asset hashes are reconciled separately from documentation/tooling.

State coverage: independent product prices, unique copies and costs; mixed quantity/payment limits; insufficient cash atomicity; exactly-once receiving; four-space capacity/backroom overflow; return and reallocation; persisted preferences and selection; stock-miss precedence; refusal release; locked product/offer and reservation ownership; FIFO/duplicate-sale rejection; closing/report boundaries; five-day inclusive budgets; malformed-load atomic rejection; ordering, receiving, stocking, selection, queue and closing reloads; two-day cash and per-product totals.

Scene coverage: visible receiving/label/assortment buttons, return/add controls, queue actions, close/drain, report/order/advance dialogs, Save/Reload keyboard controls at business boundaries, mixed two-day inventory, full-shelf exchange, missing product and price refusal. Scene field values/dropdown selection use adapters; native review additionally used the actual dropdown and typed pricing. Three additional targeted checks verify that pending label requests retain the product and price chosen when clicked, even if selection or the input changes while Rowan walks. The suite continuously checks accounting/ownership and customer/fixture separation. Normal/Retina screenshots of prep, packages, allocation, checkout, order, refusal and reports were inspected. Essential names and offers remain readable in UI; tiny package lettering is decorative.

[Native review](../../encounter/evidence/r5/native-review.md) records real Retina input in a separate development app identity, preserving earlier windows. A saved R5 checkpoint was retained when relaunching final source. The final running ordinary shift has Alex/Curb $21.99, Blair/Tide $19.99 and Casey/Orbit $14.99 queued, with $550 cash and Serve Alex available. This is agent operation, not owner acceptance.

Failures remain retained. Mixed-order reload initially preserved JSON numeric types differently; line quantities/costs now normalize on load. A scene-input adapter initially missed embedded-dialog coordinates; root-window offsets corrected it. A day-2 test incorrectly expected an Orbit purchase at $14.99 despite the deterministic $14.24 budget; its expected result now includes the required price miss. One rendered input run lost its dialog during overlapping native launch; isolated final rendered runs passed. Visual QA caught the wrong selected-product price field after reload; it now restores the selected product's label. A pending label action could also follow a later product selection while Rowan walked; it now captures the original product and cents at request time. Rendered test screenshots now force a draw instead of waiting indefinitely for an occluded macOS window to repaint. No functional gate was suppressed.

## Reproducible comparison and footage

**Compare Assortments.command** is separate from ordinary gameplay and uses separate saved checkpoints. Both scenarios reach day 2 through the same completed day-1 transactions and paid two-of-each order. They start with six unsold copies, $556.97 cash, the same three visitors and four occupied shelf spaces. Day-2 offers: Curb $21.99, Tide $19.99, Orbit $12.99. Alex seeks Tide, Blair Orbit, Casey Curb.

| Allocation | Sales | Stock misses | Revenue | Sold cost | Gross profit |
| --- | --- | --- | --- | --- | --- |
| 2 Curb / 1 Tide / 1 Orbit | 3 | 0 | $54.97 | $25.00 | $29.97 |
| 2 Curb / 2 Tide; Orbit backroom | 2 | 1 Orbit | $41.98 | $20.00 | $21.98 |

Both have zero price misses. The unavailable Orbit copies remain in the backroom. [Stocked movie](../../encounter/evidence/validation-20260909T020530374063Z/r5-stocked.mp4) is 71.000000 seconds; [missing movie](../../encounter/evidence/validation-20260909T020530374063Z/r5-missing.mp4) is 59.000000 seconds. Both are actual 1280×720 engine frames encoded at 30 fps, including the final per-product report. Their traces and verified JSON reports bind the inputs/results, including four occupied spaces.

The initial raw two-day capture completed its state trace but stopped producing rendered frames while obscured; its retained 62.3-second movie is **partial footage**, not proof of the whole two-day loop. Native movie-writer experiments also captured frozen background pixels; their frame-count pass was rejected by visual review. The final capture tools explicitly force a scene draw before reading each frame and reject recordings without substantial changing-frame content. All failed recordings and logs remain retained. Action routing and direct prep/report/order/advance adapters are disclosed; this is engine footage, not owner input.

The final [full two-day movie](../../encounter/evidence/validation-20260909T020530374063Z/r5-gameplay.mp4) is 142.866667 seconds, 1280×720 at 30 fps. It contains prep, three first-day sales, final per-product report, paid mixed replenishment, next-day receiving/stocking, a product-specific price refusal, two closing sales and the final day-2 per-product report. Final day 2: $41.98 revenue, $20 sold-copy cost, $21.98 gross profit, $598.95 cash, four unsold copies, one Orbit price miss and no stock misses. Final-frame captures were visually inspected against the traces. All three movies passed changing-frame and report-result checks. The earlier recorded exit warning remains an unresolved limit; the final capture logs did not repeat it.

## Art and retained limits

New three-layer editable masters: `encounter/source/case-tide.kra`, `case-orbit.kra`; lossless straight-RGBA exports in `encounter/art/`. They extend the established native painted package system, with distinct dominant colors and silhouette motifs. `Rebuild Assortment Art.command` and `build_assortment_art.py` reproduce only these additions. Both saved masters reopened and exported byte-identical PNGs; [roundtrip proof](../../encounter/evidence/r5/art-roundtrip.json). Images are 152×208 (4× logical 38×52). Import sidecars retain lossless compression, no mipmaps, alpha-border correction and no premultiplication; runtime uses linear filtering. All existing masters, exports, samples, fixtures and rigs are unchanged.

Inherited rigid/deforming legs, abrupt turns/stops, straight reach, possible foot sliding, mirrored lighting, enlargement artifacts, reused/tinted rigs and no detailed cash handoff remain. The recorded `ObjectDB instances leaked at exit` warning is explicitly unresolved. Successful state/render tests and movie capture do not establish warning-free shutdown. Krita warning logs are retained and not described as resolved.

## Identity and handoff

Branch `main`, preserved incoming HEAD `4b91108fa3cd8d9a2829524c6cf5baed55a236d0` with two existing local commits. Incoming files match the R4 manifest exactly. Pre-R5 hashes/source archive and tracker snapshot are under `encounter/evidence/r5/`. Final candidate identity includes uncommitted source/assets and is not represented by HEAD alone. Preservation reconciliation binds unchanged earlier evidence and samples; current docs/tracker record only bounded R4 acceptance and R5 readiness supported by final evidence.

Launch and complete instructions: [encounter README](../../encounter/README.md). R5 requires its own owner decision.
