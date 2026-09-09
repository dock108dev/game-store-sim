# R3 — meaningful pricing consequences

2026-09-08 local / 2026-09-09 UTC. **Implemented, verified and ready for owner review.** **R3 owner acceptance pending.**

## Owner decision and scope

Owner feedback on R2: **“build on.”** Recorded as bounded acceptance of the repeatable business day and permission to implement R3. R1's prior acceptance remains. Existing animation limitations remain documented. This is not full-game or release acceptance.

R3 retains Curb Circuit 02, physical copies, one daily visitor, the repeatable business day, paid replenishment, existing fixtures and retail-v4 appearance. No new catalog/cast, promotions, reputation, shop expansion or broad animation polish.

## Model and playable behavior

The existing R2 code allowed $1.00–$99.99 backroom labels but every customer bought. R3 gives the sole product a $21.99 reference value and a reproducible five-day willingness schedule: 110%, 125%, 80%, 95%, 140%, rounded down to cents. The cycle is authored and repeats; it has no random or clock-dependent draw. One visitor per day remains. Multiple synthetic customers used in reservation regressions share that day's budget.

At shelf selection, the copy ID, offered price and budget are fixed in the customer record. End-of-browse decisions buy at or below willingness, otherwise decline. The ledger records day/customer/copy/offer/budget/outcome. A replay of the same decision returns its prior result without adding an event. Queued checkout verifies the locked offer, ownership and unsold identity; it cannot silently charge an edited label. All price writes are prep-only.

Initial label printing still prices backroom copies. The new **Apply price to unsold stock** control reprices both backroom and shelf copies in prep; editing the field alone does nothing. This lets a refused copy receive a new price next day without requiring a purchase order. The field shows reference guidance and a live per-sale profit preview. Below-cost loss is supported. The bounded numeric control clamps to $1.00–$99.99; state APIs reject out-of-range, noninteger-cent and nonnumeric values.

A declining visitor releases the reservation, carries no case and walks out. Shelf stock and cash do not change. The restrained “Over my budget” label and bottom feedback explain the reason; the top guide points to review and next-day pricing. Daily reports add price misses alongside sales, revenue, sold-copy cost, gross profit, unsold stock and cash. Closing early without a pricing decision does not count as a price miss.

Schema 3 stores cumulative decision and sale ledgers. Daily reports filter both by day; advancing clears daily customers and counters while preserving cash, orders, decisions and physical inventory. Atomic load validates decision uniqueness, computed budget, outcome, offer and ownership before replacing live data. R1/R2 saves are retained in their separate namespaces; R3 does not migrate them. Animation restores at coherent checkpoints, not exact poses.

## Reproducible tradeoff

The same five visitors are evaluated at every price, with identical budgets and replenishment:

| Price | Sales | Price misses | Revenue | Gross profit | Profit per sale |
| --- | ---: | ---: | ---: | ---: | ---: |
| $16.99 | 5 | 0 | $84.95 | $44.95 | $8.99 |
| $21.99 reference | 3 | 2 | $65.97 | $41.97 | $13.99 |
| $26.99 | 2 | 3 | $53.98 | $37.98 | $18.99 |

The high-price visitor on day 2 still buys at $26.99; the day-3 visitor declines even the reference price. Reference is guidance, not a guaranteed best answer. The small cycle demonstrates consequences but is not calibrated commercial demand. Margin excludes overhead and expenses only sold copies; orders reduce cash once when paid.

## Validation and evidence

Final passing evidence: [validation-20260909T003117983113Z](../../encounter/evidence/validation-20260909T003117983113Z/). Earlier runs and their failures are retained. A JSON numeric-normalization issue and prep-panel overlap were repaired; a world cue was moved to avoid the shelf label. No checks were suppressed.

- 161 pricing/state checks: identical five-day scenarios, inclusive willingness boundary, legal and invalid prices, below-cost loss, locked queued offer, refusal stock/reservations, duplicate decisions/sales, save/reload before offers and before/after decisions, daily accounting and reset, malformed duplicate ledger rejection.
- 20 R1 transaction regressions and 28 R2 replenishment/day checks, including exclusive reservations, sale-after-close, sold references, insufficient funds through legitimate spending, exactly-once charge/receipt/advance, mixed prices and persistent stock.
- 27 baseline encounter checks plus 25 R3 scene checks: actual scene customer routes and controls, buy/decline, refill/day dialogs, keyboard save/reload, repricing a refused shelf copy into a next-day purchase, bounded input and report/control geometry. Headless, normal 1280×720 and Retina 2560×1440 runs remain separate evidence.
- Disposable copied project, fresh asset import and unique save namespace. Context records engine version and every runtime/source hash. Source qualification and owner acceptance remain separate.

## Gameplay and visual assessment — agent

[Actual gameplay movie](../../encounter/evidence/validation-20260909T003117983113Z/r3-gameplay.mp4): 1280×720, 30 fps, 75.73 seconds. The scene runs high-price browsing/refusal, close/report, a paid two-copy order, day advance/receipt, low repricing, purchase and report reload. The final day-2 report has one sale, no price misses, $16.99 revenue, $8 sold cost, $8.99 gross profit, $550.99 cash and three unsold copies. The prior day's refusal remains in the cumulative decision ledger. [Action trace](../../encounter/evidence/validation-20260909T003117983113Z/gameplay-trace.json).

The movie's adapter invokes order/advance/reprice directly; visible controls and dialogs are separately exercised by the normal/Retina tests. This is engine gameplay, not owner input. Agent inspected normal/Retina pricing guidance, refusal, report and next-day repricing captures. Panel text and action controls have no overlap; the fixed bottom refusal cue remains readable while world labels may cross actor artwork. Normal logical text and Retina scaling retain retail-v4 appearance. Native price typing and high-price refusal are additionally recorded in `evidence/r3/native-input.log` and `native-review.md`.

## Preservation, limits and handoff

[Preservation result](../../encounter/evidence/r3/preservation-result.json): 293 historical game/sample/art/source/actor files unchanged. Pre-R3 source archive and hashes are in `encounter/evidence/r3/`. Retained Krita masters, pivots, exports, samples and historical evidence are preserved.

Inherited rigid/deforming legs, abrupt turns/stops, straight reach, possible foot sliding, mirrored lighting, enlargement artifacts, reused/tinted customer rig and no detailed cash handoff remain. Price/carton lettering within world artwork is decorative; the desk is authoritative. No new art or broad polish was added.

[Launch and comparison instructions](../../encounter/README.md). The separate Compare Pricing launcher starts low/reference/high day-1 scenarios with a visible demo label and distinct save files. Ordinary gameplay contains no demo selector. Full five-day comparison is reproduced by validation. No commit, push or publication.
