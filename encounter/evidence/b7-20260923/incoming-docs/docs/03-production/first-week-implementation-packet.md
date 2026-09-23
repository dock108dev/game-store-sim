# B1 — First-week implementation packet

September 22, 2026 · **B1 planning complete. B2–B6 are subsequently implemented; [B6 delivery](b6-delivery.md) owns current technical evidence. B7 is next.**

The [root tracker](/Users/michaelfuscoletti/Desktop/game_sim_next_steps.md) owns confirmed scope and authorization. This packet chooses implementation defaults within that scope. At B1 publication, counts, prices, schedules, geometry and rules below were **proposed initial design values**, not observed balance or owner-approved numbers. B2–B6 subsequently implement them as reconciled below. B8 still tunes them with evidence. No further broad owner interview is needed. B1 inspected source and retained evidence only; no gameplay, application tests, owner saves, runtime changes, art generation, commit or push.

## 1. Current source inventory

Inspection started on `main`, full HEAD `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9`, with a clean working tree. This delivery adds this packet and edits planning pointers only; HEAD alone does not include these uncommitted documents. Active project: `encounter/`, Godot 4.6.2 Standard/GDScript/Compatibility, 1280×720 logical viewport, 2560×1440 window override and HiDPI. Historical `game/` and root export scripts are not encounter implementation.

| Inspected seam | Current behavior and constraint | Required change / owner slice |
| --- | --- | --- |
| [state.gd](../../encounter/state.gd): `reset`, `PRODUCTS`, `CATALOG`, `receive`, `order`, `advance` | Schema 5; $550 cash; three prepaid starter copies; three titles; one paid report-phase order/day, next-day receiving; unlimited days | B3 seven-day endpoint/economy; B6 five-title content and release-day purchasing |
| `CAPACITY`, `shelf_used`, `stock`, `unstock`, `valid` | Global capacity four, including reserved copies; no fixture/slot identity | B2 physical fixture/slot ownership and derived capacity; B3 expansion |
| `reserve`, `decide`, `queue`, `sale`, `release` | Copy-exclusive reservation, locked offer, FIFO, exactly-once sale and reference clearing | Preserve; B2 location-aware selection; B4 job claim arbitration; B5 condition-specific copies |
| `close`, `can_finalize`, `finalize`, `report` | Stop admission, drain admitted buyers, lock finalized sales; gross margin excludes overhead | B3 expense settlement/terminal outcomes; B4 jobs and B5 sellers join drain rules |
| `valid`, `save_to`, `load_from` | Exact expected copy identities, catalog costs, three customer keys, fixed coordinate bounds and $550 + sales − orders cash formula; validated candidate load and temp-file rename | B2 schema 6/layout/fixture expenses; B3–B6 extend actual event provenance and validation, not just UI |
| [main.gd](../../encounter/main.gd): `_ready`, `BLOCKS`, `BROWSE_SPOTS`, `QUEUE_SPOTS`, `station`, `route` | Independently hard-coded artwork, four package sprites, obstacles, destinations and 10px AStar grid | B2 one layout-derived view/navigation contract; B4 worker destinations |
| `request_action`, `perform`, `refresh`, `show_assortment`, `restore_view`, `update_wave` | Pending price/product snapshot; three actors, movement/selection timers, dynamic avoidance, explicit checkpoint controls | B2 capture fixture/copy/slot/revision as well; B4 contention; B5 seller UI; B6 roster; B7 ordinary new/continue/report flow |
| [actor.gd](../../encounter/actor.gd): `pose`, `reach`, `build_rig`, `pose_feet` | Illustrated front/side/back rigs; speed 110, 1.5s reach; motion limitations remain | B4 role readability; B7 walk/turn/stop/reach improvements, no style replacement |
| [project.godot](../../encounter/project.godot), [validator](../../encounter/scripts/validate.py) | R5 persistent review namespace; isolated temporary validation copies; no encounter export preset | B2 separate development save namespace and isolation update; B9 active Mac export/launch/quit/resume |

A “used-game shelf” label in `main.gd` is presentation text only: there is no seller intake, condition, negotiation, employee, rent, bankruptcy, layout editing or release calendar in current state.

**Retained technical evidence:** all files listed in the [September 21 source context](../../encounter/evidence/validation-20260921T161936955273Z/context.json) match current encounter bytes. Its four recorded process exits are zero; retained result sets contain 110 state, 3 pending-price and 54 scene checks. This is manifest reconciliation, not a new execution. Of 119 encounter entries in the [R5 candidate manifest](../../encounter/evidence/r5/candidate-manifest.json), only `main.gd`, `README.md`, and `scripts/validate.py` differ today. The later shared glass UI explains why the old gameplay-source match must not be repeated verbatim. See [UI verification](../ui-verification.md), [R5 delivery](r5-delivery.md), [architecture](../02-technical/encounter-architecture.md), [local development](../02-technical/local-development.md) and [validation policy](../04-validation/local-validation-plan.md).

**Owner acceptance:** R1–R4 remain accepted only within their recorded scope. R5 owner verdict remains pending. Neither source matching nor this packet accepts R5, animation, fun or beta readiness.

## 2. Concrete first-week content and economy

### Initial parameters and ordinary choices

Start day 1 with $550 spendable cash, two prepaid new copies of each original title (six copies, $50 historical inventory cost), one four-slot rack, fixed receiving and checkout stations. The starting stock is an opening asset, not a second day-1 cash charge. Backroom limit: 64 physical copies; paid inbound copies reserve backroom capacity. Two purchasable staff candidates become available in day-3 prep. One space upgrade becomes available in day-5 prep without a revenue gate. Bills and the upgrade date/price are visible from day 1.

| ID / title | Supplier cost | New reference / default label | Available |
| --- | ---: | ---: | --- |
| `curb` / Curb Circuit 02 | $8 | $20 | Day 1 |
| `tide` / Tidebound Atlas | $12 | $26 | Day 1 |
| `orbit` / Orbit Orchard | $5 | $14 | Day 1 |
| `signal` / Signal Harbor | $16 | $30 | Day 4 release |
| `rally` / Pocket Rally Club | $10 | $24 | Day 6 release |

Five fictional titles total; two new editable cover masters and exports in B6. Original names/art remain. These deliberately change R5 reference prices in the final week ruleset; historical R5 checks retain their original evidence. Prices remain integer cents, $1–$99.99; loss pricing is allowed. New/used condition groups have separate labels, with individual-copy overrides; no live reservation may be repriced.

B6 replaces overnight-only buying with **one confirmed mixed supplier order per day during prep**, 0–6 copies per released title, paid immediately and received at the receiving station that prep. No open-phase supplier order. Unreceived order blocks opening, as now; repeated receive is inert. Backroom-capacity and cash checks happen before payment. This explicit change makes release-day purchasing possible without advance orders. Release calendar information appears from day 1; unreleased titles are disabled in both state and UI. No deposits, preorders or future-delivery promise. B2 retains the current report-order timing; B6 owns this change and its tests.

| Day | Shopper count / ordered desired new-title sequence | Sellers | Available decisions |
| --- | --- | --- | --- |
| 1 | 3: C,T,O | 0 | Price starter stock, choose four-slot allocation or buy second rack, arrange/open/serve/report |
| 2 | 4: C,T,O,T | 1: C good | Negotiate first used acquisition, refuse freely, retain for next prep |
| 3 | 5: C,T,O,C,O | 1: O fair | Hire either/both staff, assign roles; sell yesterday's C; replenish |
| 4 | 6: C,T,O,S,O,T | 1: T good | Buy released S, choose display allocation, sell used O |
| 5 | 7: C,T,O,S,T,C,O | 1: C fair | Buy $100 expansion with third rack; rearrange; sell used T |
| 6 | 8: C,T,O,S,R,C,T,O | 1: O good | Buy released R, choose second employee vs cash cushion; sell used C |
| 7 | 8: C,T,O,S,R,O,C,T | 1: R worn | Sell used O; optionally buy/refuse late seller; settle wages/rent and review week |

C/T/O/S/R denote catalog IDs in table order. Each shopper buys at most one copy, without substitution or haggling. The first three visitors retain Alex/Blair/Casey presentation; add three distinct customer appearances/names (Devon, Ellis, Frankie) in B6, cycle appearances for the seventh/eighth visitor with unique IDs. IDs are `buyer:<run>:<day>:<ordinal>`, never reused as transaction keys across days. Shopper arrivals are 18 simulation seconds apart; hold admission outside when three buyers are active. No queue impatience for beta; player can close early. Seller arrives at 30 seconds, waits at a dedicated intake point, and does not occupy the buyer checkout FIFO.

Authored budgets: each day's first occurrence of each title has 110% of its new reference; subsequent occurrences alternate 90%, 80% of that reference (floor to cents). Repeat buyers accept new or any used grade; first occurrences seek new copies. Select oldest eligible copy by acquisition sequence, then ID; reserve at that rack's browse point and retain the offer. Preferences/budgets/arrivals are snapshotted at opening and never rerolled. Show expected interests and release demand before opening, not hidden exact future sales. The example below sells only the enumerated copies; extra shoppers may miss stock or refuse prices. This is a small authored first-week model, not a commercial demand forecast.

| Commitment | Proposed amount / rule |
| --- | --- |
| Extra four-slot rack | $60, max two racks in base room including starter; B2 purchase |
| Same-shop expansion | $100 once from day 5, opens north bay and includes a third four-slot rack; capacity 8 → 12 if second rack owned, otherwise 4 → 8; B3 |
| Staff | Morgan and Jules, maximum two; no hiring fee; each $12 per employed day from day 3; stocking or checkout, one role at a time |
| Rent | $150 due at day-7 close, visible from day 1 |
| Conditions | Good: suggested resale 80% of new reference; fair 60%; worn 40%, floor cents; no repair |
| Used offers | Seller reservation floor and bounded counters in section 5; accepted price becomes that copy's cost |

### Worked surviving week — feasibility arithmetic, not play evidence

Buy the $60 second rack day 1. Hire Morgan day 3 and Jules day 6; one staff member can stock during prep and switch to checkout during opening. Buy expansion day 5. Sell one new C/T/O every day, one new S days 4–7, and one new R days 6–7. Sell yesterday's acquired used copy on days 3–7: C good $16, O fair $8.40, T good $20.80, C fair $12, O good $11.20. Refuse the day-7 R seller. All used offers here are accepted at the disclosed negotiation floors: $8, $4, $10, $5, $6.

Supplier quantities: days 1–2 none (use prepaid stock); day 3 one C/T/O ($25); day 4 one C/T/O and two S ($57); day 5 one C/T/O ($25); day 6 one C/T/O, two S, two R ($77); day 7 one C/T/O ($25). Each order respects the six-per-title cap and available cash. New purchases total $209. Sell the older S first; the second day-4 S sells day 5, and the second day-6 S/R sell day 7. All required sales fit eight slots before expansion and twelve after it; peak available inventory before opening is eight copies, plus the current day's used intake kept in backroom. No sale depends on open-phase stock replenishment.

Amounts below are dollars. Acquisition columns are actual cash paid that day, not cost of sales.

| Day | Opening cash | Sales | New stock | Used stock | Rack | Expansion | Wages | Rent | Closing cash |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 550.00 | 60.00 | 0 | 0 | 60 | 0 | 0 | 0 | 550.00 |
| 2 | 550.00 | 60.00 | 0 | 8 | 0 | 0 | 0 | 0 | 602.00 |
| 3 | 602.00 | 76.00 | 25 | 4 | 0 | 0 | 12 | 0 | 637.00 |
| 4 | 637.00 | 98.40 | 57 | 10 | 0 | 0 | 12 | 0 | 656.40 |
| 5 | 656.40 | 110.80 | 25 | 5 | 0 | 100 | 12 | 0 | 625.20 |
| 6 | 625.20 | 126.00 | 77 | 6 | 0 | 0 | 24 | 0 | 644.20 |
| 7 | 644.20 | 125.20 | 25 | 0 | 0 | 0 | 24 | 150 | 570.40 |
| Total | — | 656.40 | 209 | 33 | 60 | 100 | 84 | 150 | 570.40 |

Reconciliation: $550 + $656.40 − $209 − $33 − $60 − $100 − $84 − $150 = **$570.40**. Thirty-two sold copies: 21 original-title new, four S, two R, five used. Cost of sales = $50 prepaid + $209 new purchases + $33 used = $292; ending inventory is zero. Gross margin = $364.40; operating result after $84 wages and $150 rent = **$130.40**. Fixture/expansion spending is shown separately as $160 investment; no depreciation system. Cash change is $20.40 = operating result $130.40 + reduction in inventory cost $50 − investment $160. Profit and cash are deliberately different.

### Separate deliberate-failure example

Keep all stock off shelves; buy six each C/T/O on days 1 and 2 ($150/day) and the second rack day 1 ($60). Starter six plus 36 acquired copies = 42 copies, below the 64 backroom limit. Hire both workers day 3 and retain through day 7; no sales, used purchases or expansion. Day-1 cash $340; day 2 $190; days 3–6 close at $166/$142/$118/$94. Day-7 wages $24 settle first, leaving **$70**. Rent $150 cannot settle: **$80 shortfall**, no partial rent payment, terminal bankruptcy with cash $70 and rent payable $150. Inventory at historical cost $350 cannot pay the bill. Cash check: $550 − $300 − $60 − $120 = $70. Gross margin zero; operating result including incurred unpaid rent is −$270. New releases and expansion remain available on schedule; this failed business simply chose not to use them. The separate surviving route must still be demonstrated in B8/B9.

Insolvency is tested only at due-bill settlement after floor/job drain, never merely because cash is zero. Reject unaffordable discretionary spending without mutation. Do not reserve rent cash invisibly, lend money, liquidate automatically, or offer an unlimited overdraft. UI shows current cash, committed wages and upcoming rent before spending. At settlement, pay wage events by staff ID, then rent; first unpaid obligation ends the run and records all remaining due liabilities. No further buying/selling/day advance after bankruptcy. Restart creates a new run; terminal save remains available. Surviving day-7 settlement ends the week, even if cash is exactly zero; there is no day 8.

## 3. Layout and growth contract

B2 owns purchase/movement; B3 owns the same-shop north bay. Choose translation-only placement, no rotation or construction editor. Coordinates below are logical pixels and proposed floor footprints, not old sprite bounds. Grid snapping is 10px. Actor foot clearance radius is 12px; placement/routing use the same inflated footprints and four-neighbor grid. Tall artwork is depth-sorted separately from floor collision.

| Identity / type | Initial footprint (x,y,w,h) | Ports / slots | Movement |
| --- | --- | --- | --- |
| `receiving-01` / receiving | (270,430,80,40) | receive/label/backroom port (370,450) | Fixed |
| `checkout-01` / counter | (690,470,200,80) | cashier (660,500), buyer (800,570), seller intake (850,420) | Fixed |
| `rack-0001` / four-slot rack | (440,330,260,40) | slots 0–3; front browse/work ports at origin +(60,70), +(180,70) | Movable |
| `rack-0002` / purchased rack | Suggested preview (400,430,260,40) | Same local slots/ports | Movable; $60 |
| `rack-0003` / expansion rack | (440,230,260,40) when upgrade confirms | Same local slots/ports | B3 included purchase, movable in expanded area |

Slot artwork uses four local anchors at (65,−34), (105,−34), (145,−34), (185,−34) relative to rack footprint origin, aligned to the retained illustrated rack during B2 visual inspection. Do not assume texture dimensions are collision dimensions. Base legal floor rectangle: [180,900) × [300,610); expanded: [180,900) × [220,610). Base starter is only rack-0001; rack-0002 is a suggested purchase preview, not free stock capacity. Permanent stations remain fixed. Layout counts are two racks maximum before expansion, three after. Expansion adds rack-0003 even when rack-0002 is absent; later second-rack purchase still costs $60. B3 previews the entire expanded layout and validates the included rack before charging; if a moved rack blocks its proposed ports, instruct the player to rearrange during prep and retry, with no debit on rejection. No fixture removal/sale.

Entry/exit is (210,580); player spawn (400,550); queue targets are (800,570), (720,570), (640,570). Protect an entry aisle [190,250) across the legal floor and bottom circulation strip [180,900) × [560,610) from fixture footprints. Keep seller intake and all station/queue/fixture ports clear with actor clearance. No snapping to a blocked endpoint. `layout_check` must prove entry ↔ every browse port, each browse port ↔ checkout queue head, all queue positions ↔ exit, player spawn ↔ receiving/cashier/every stock port, and receiving ↔ each stock port ↔ cashier for future workers. Require paths both ways using the same grid; actual worker contention remains B4. Reject even a geometrically nonoverlapping placement if it disconnects any required route.

Preparation-only **Arrange shop** opens a ghost preview. Click a rack or choose Buy rack; click floor to position, arrows nudge 10px; Enter/Confirm applies, Escape/Cancel discards. Show price, total capacity, green/red ghost plus text (“Overlaps checkout”, “Outside shop”, “Blocks route to rack-0001”, “Not enough cash”, “Rack limit reached”). Confirmation rechecks current phase, layout revision, cash and connectivity. Preview moves neither live fixtures nor money; cancel/reset/load closes the draft. Disable Open while a draft is active and explain why. No movement while trading, closing or reporting, or while any prep work claim is active. Player route/action finishes or cancels before editor entry; B4 workers pause and release uncommitted claims before arranging.

Every display copy owns `(fixture_id, slot_index)` in addition to copy ID. Reserved customer copies retain their original slot until sale; refusal returns to exactly that slot. Sold/backroom copies have no slot. One slot has at most one displayed or reserved copy. Moving a stocked rack preserves IDs, costs, labels, slot indices and total capacity. `stock(copy_id, fixture_id, slot_index)` chooses an explicit free destination; assortment UI defaults to the lowest free slot of the selected rack. No global array index may become a persistent identity. Open-phase customers select only reachable eligible shelf copies, using persisted browse destinations; a rack can serve two browsing actors, others wait at admission until an endpoint is free.

B2 exercised the proposed geometry and corrected the queue from y=580 to y=570. At y=580 the first sold buyer could not pass the waiting queue inside the floor bounds. Shared routing now uses 28px buyer center separation (12px foot radius each plus 4px spacing), leaving a usable passing lane at y=600. This revision applies equally to the counter buyer port, queue targets, runtime and scene assertions. Foot separation does not claim improved character animation.

Static path existence is necessary, not sufficient for multiple actors. B2 retains three active buyers, validates customer avoidance on altered layouts, and returns “Waiting for aisle” for temporary blockage. Queue occupants get priority over incoming browsers; exiting actors get priority over both. Never teleport, sell remotely, or perform a pending action merely because its path is empty. B4 extends this arbitration to workers, and B6 increases total arrivals without increasing the three-buyer active cap. B2 now supplies isolated rendered and native-input evidence for these coordinates and the queue correction. Worker contention remains B4 and animation acceptance remains B7/owner review.

## 4. State and transaction contract

B2 starts **schema 6 / ruleset b2-layout-1**. Keep R5 business rules/content initially, add layout and fixture expenses now. Later incompatible contracts bump schema 7 (B3 economy), 8 (B4 staff), 9 (B5 used), 10 (B6 week content); B7–B9 bump again only for incompatible persisted meaning. This is a staged plan, not a promise to load all intermediate builds.

| Record | Required fields / invariant |
| --- | --- |
| Run | `run_id`, `version`, `ruleset_id`, `day`, `phase`, `opening_cash`, `cash`, `layout_revision`, `next_fixture_id`, `next_event_seq`; counters persist |
| Layout | `space_level` 0/1; fixture map of stable ID → type, grid origin, slot count derived from type; no duplicated mutable capacity total |
| Copy | Existing product/location/customer owner/price/cost; add fixture/slot nullable, acquisition event ID/sequence; B5 adds `kind=new/used`, `condition=new/good/fair/worn`; copy cost immutable |
| Events | Unique ID, kind, day, amount cents, references; supplier, used purchase, sale, fixture purchase, expansion, wage, rent; status due/paid where applicable |
| Staff/jobs | Staff ID, employment dates, assignment, daily wage commitment; job ID, actor ID, copy/order ID, destination slot/port, layout revision, claimed/committed/cancelled status |
| Day content | Released catalog IDs derived from ruleset/day and validated; materialized roster, offers/budgets, seller negotiation progress and resolved flags |
| Completion | Finalized-day IDs and reports; terminal result null/survived/bankrupt with day, due event, shortfall, unpaid liabilities, week summary |

Use integer cents and exact integer quantities. State methods build a candidate transition, validate all preconditions, then atomically publish cash/inventory/layout/ledger changes. The scene is never the financial authority. Event keys include run: `fixture:<run>:<fixture-id>`, `expansion:<run>:1`, `supplier:<run>:<day>`, `trade:<run>:<day>:<seller>`, `sale:<run>:<day>:<buyer>`, `wage:<run>:<day>:<staff>`, `rent:<run>:7`, `finalize:<run>:<day>`. A repeated committed command returns already-applied status without new charge/copy. IDs for canceled previews are not consumed; confirming twice with the same request ID cannot buy another rack. Capture requested arguments and expected revision before walking/dialog confirmation; stale commands reject with useful feedback.

Extend `valid()` to reconstruct expected copies from starter definitions and committed acquisition events, not just `case-*`/order patterns. Reject orphan/duplicate slots, invalid fixture types/positions, unknown conditions, incorrect costs, unreachable required ports, duplicate event IDs, mismatched sale provenance and invalid job ownership. Normalize integral JSON numbers only after full candidate validation. Validate cash as opening cash + paid sales − paid supplier/used/fixture/expansion/wage/rent events; never subtract the same order in both old and new ledgers. Existing orders/sales may remain detail records referencing their single authoritative cash event.

Report separately: receipts, inventory cash purchases, cost of sold copies, gross margin, incurred wages/rent, operating result, paid overhead, unpaid liabilities, investment outlays, ending inventory at historical cost, and cash. Operating result subtracts incurred overhead including unpaid terminal rent; cash subtracts paid events only. Fixture/expansion investment is not merchandise cost or recurring expense; show total separately without depreciation or claiming statutory accounting.

Phases: prep → open → closing → settling → report (days 1–6) or week_complete/bankrupt. Closing cancels unadmitted buyers/sellers, drains admitted buyer sales, cancels unaccepted seller dialogs and uncommitted stock jobs, finishes or releases checkout claims, then permits settlement. `settling` is one atomic synchronous transition: post daily obligations, pay wages then day-7 rent, freeze report or terminal outcome. Save cannot capture a half-debit. Repeated finalize or reload cannot accrue/charge twice. Day advance only from a settled report with expected day; preserve unsold copies/layout/staff/ledgers and reset daily admissions. Terminal phases reject business mutations; allow save/view/restart/return only.

## 5. Staff and used-trade rules

Morgan and Jules are available from day-3 prep. Hire/dismiss only in prep before opening; confirm the $12 daily commitment when hiring. A hire owes that day's wage even if immediately dismissed or never assigned; next-day dismissal before opening avoids that next day's wage. Existing employees commit the new day's wage when Open is confirmed. Pause/unassign/reassign never cancels an already committed wage. Default role is unassigned; warn before opening with paid idle staff. Assignment can change during prep/open after current uncommitted job is canceled. No deep schedules, skill levels, personalities, training or commission.

Stock jobs claim one priced backroom copy and one reachable free slot; reserve both without changing physical location. Worker walks to receiving, then the destination, reaches, and commits once. Cancellation/unassignment/close releases claims; copy stays backroom until commit. Destination-full or blocked status causes no cash or item mutation. Checkout jobs claim only the settled FIFO head and cashier port, then walk/reach/commit through the same `sale` rules as the player. One cashier actor at a time; player request may cancel a worker's uncommitted claim using an explicit Take over action, then must travel normally. It cannot reverse a committed sale. Customer reservation ownership and worker execution claims are separate fields. Whoever obtains the state-layer claim first owns the work; no scene-frame race may duplicate it. Player keeps both duties available. B4 permits new priced-copy stock jobs in prep/open; closing cancels uncommitted stock jobs and starts none; prep-only label/layout edits remain. Prefer checkout drain over other work.

Seller transaction is separate from buyer queue. Inspect product, condition, suggested resale and asking price before offering. Grade does not change through negotiation. One initial offer and at most one counteroffer from the shop; seller counters once. Seller remains pending until accepted/refused/canceled; no auto-purchase. Generic asking price = floor(70% of condition resale reference), minimum accepted = floor(50% of condition resale reference). On first below-floor offer, reveal that floor as the seller counter; accept counter or submit one final offer, otherwise seller leaves. Offers range $1–asking price; an offer at or above the floor is accepted at the player's offered amount, never silently replaced with a cheaper amount. Round all computed values down to cents.

For the authored five example sellers, override ask/floor respectively to C-good $11/$8, O-fair $6/$4, T-good $14/$10, C-fair $8/$5, O-good $8/$6; day-7 R-worn uses generic $6.72/$4.80 on $9.60 suggested resale. These values satisfy condition-sensitive resale and acquisition. Override values are visible via asking/counter behavior and saved in the seller record, not rerolled. Seller IDs are `seller:<run>:<day>:1`; acquired copy ID is `used:<run>:<day>:1`.

On accepted-offer confirmation, capture seller/condition/offer cents/revision; recheck cash and reserved backroom capacity; atomically debit and create exactly one unpriced backroom copy with accepted cost, mark seller completed and append purchase event. If cash or space is insufficient, keep the disclosed offer pending with an explanation; no payment or copy. Cancel/refuse/close releases intake and creates nothing. Accepted purchases cannot be canceled or repeated. A full display does not block acquisition if backroom has room. Newly bought used stock is labeled/allocated next prep; no player is promised same-day resale. Buyers pay its fixed shelf offer or decline; no shopper haggling, trade credit, repair or preorders.

## 6. Save and recovery policy

Preserve the R5 namespace and every existing checkpoint untouched. B2 switches project default to `game-sim-first-week-dev-v6`; subsequent incompatible development versions use their own suffixed namespace. B9 freezes a separate personal-beta namespace tied to the supported schema. Update validator isolation matching alongside project configuration; it must still fail closed before invoking Godot if isolation cannot be established. Never browse/import the owner's R5 saves to construct tests.

**Compatibility choice: no R5 or intermediate-schema migration for this beta.** New/Continue UI explains supported version. Wrong-version or malformed files are rejected without replacing live state or overwriting that file; offer New run separately. Use synthetic schema-5 fixtures for incompatibility checks. B7 must provide this ordinary error/recovery flow, while every earlier slice exposes clear load failure text.

Explicit Save is supported in prep/open/closing/report/terminal states between atomic commands. Preview and unconfirmed dialog edits are discarded, not saved. Save pauses simulation for snapshot validation/write; persist customer reservations/offers/queue/progress, fixture slots, bills, staff commitments and resolved sellers. Active work claims are saved but **canceled on restoration before resuming**, retaining original backroom copies and customer reservations; reconstruct routes and reassign work from current state. Completed events stay completed. Restore player at a legal fixed cashier/prep point, workers at receiving access, and buyers at saved validated positions; stagger worker departures to avoid overlapping spawns. No animation pose or path array is authoritative save data.

B3 adds checkpoint autosave after settlement/day advance/confirmed expansion; B7 adds Save and quit plus clear unsaved-progress warning. Explicit saves remain. Write validated temp then atomic rename; write failure leaves previous checkpoint and live state intact, shows failure, and does not claim saved. Financial commits remain live if saving fails; retries must not reapply them. Continue loads only the last successful checkpoint and names its day/phase. No backup rotation/cloud/recovery framework required; retain one terminal result file per run before starting over, and block automatic overwrite if that preservation fails. A previous checkpoint can replay later unsaved actions; this is not a duplicate inside one persisted history. Crash-durability beyond this protocol requires evidence, not claims.

## 7. Implementation and evidence map

Every remaining beta requirement has a responsible stage below. Ordinary UI, applicable saves, assets and focused verification ship with each system; B7 is integration/polish, not permission to leave invisible mechanisms until later.

| Stage / dependencies | Source seams and required work | Completion evidence |
| --- | --- | --- |
| B2 after B1 | New `encounter/layout.gd`; `state.gd` fixture/slot state, expense identity, validator/save; `main.gd` placement, sprites/ports/navigation; project namespace and validator; fixture art alignment | Cases in section 8; purchase/move/cancel/blocked feedback through ordinary controls, altered-layout customer routes and save/reload |
| B3 after B2 | `state.gd` finalize/advance/report/valid; `layout.gd` north bay; `main.gd` upgrade/bills/terminal UI; opening assets and ledger | Atomic $100 expansion, rent/wage-event primitive, zero-cash survival, insufficient due bill, no duplicate finalize/charge, seven-day stop; recheck real wages after B4 |
| B4 after B2/B3 | State job/employee/commitment methods; `main.gd` work dispatch/actors/role controls; `actor.gd` role readability | Both jobs visibly useful, contested copy/slot/FIFO head, player takeover, blocked work, cancellation/close, quit/resume and real wage reconciliation |
| B5 after B3/B4 | State seller/copy/value/acquisition validation; scene intake/dialog/condition labels and reports | Each grade, bounded counters, refusal/full backroom/insufficient cash, duplicate acceptance, new/used coexistence, actual cost on staff and player resale, reload at negotiation and acquisition |
| B6 after B3–B5 | New `encounter/week_content.gd` for the five-title ruleset/roster/calendar; adapt `state.gd` catalog/preference/order/open/valid; `main.gd` supplier/arrival/receiving; two cover masters plus three additional customer appearances | Both release boundaries reject early purchases, same-day receiving, no advance charge, preserved owned stock, authored seller/buyer days, stable demand on reload, mixed stock/staff/report integration |
| B7 incremental with B2–B6, finish after B6 | `main.gd` menus/onboarding/save/continue/restart/reports; `glass_ui.gd`; `actor.gd`/rigs and new art | Ordinary seven-day controls without developer adapters; readable bills/conditions/roles; normal/Retina dialogs; walk/turn/stop/reach video, no style overhaul; save-error and compatibility recovery |
| B8 after integrated B2–B7 | Tune `week_content.gd` and relevant economy constants, without unrelated rewrites | Two materially different surviving weeks (including different stock/staff choices), accessible growth and every system, recoverable setback, separate bankruptcy, all closes financially reconciled; simulation and observed play separate |
| B9 after B8 | New encounter export preset and encounter-specific Mac launch/build instructions; `project.godot`, isolated validation runner, candidate manifest | Personal Mac artifact opens without editor, writable isolated save path, packaged assets, quit/resume across days, complete surviving and failure paths; determine ordinary-play relevance of historical exit warning |
| B10 after B9 | Tracker, candidate-specific owner review and scoped repairs | Explicit owner judgment of complete week's clarity/agency/progression/motion/fun and beta readiness; affected checks/review after changes; pending R5 field never filled from tests |

Retain and extend [state suite](../../encounter/scripts/test_assortment.gd), [scene suite](../../encounter/scripts/test_assortment_scene.gd), [pending-price suite](../../encounter/scripts/test_price_request.gd) and isolated validator. Add focused layout and later system suites as needed; select them explicitly. Update intended current assertions for capacity/roster/price changes rather than forcing obsolete R5 values forever, but preserve their underlying ownership/phase/cash protections. Historical evidence is immutable. Source hashes, ruleset, test parameters, logs, actual outputs and failures belong in a new evidence directory for each engineering candidate. Counts are not a completion goal.

B1 packaging assessment: no `encounter/export_presets.cfg` exists; retained Godot settings/assets provide a plausible Compatibility Mac export starting point, not a demonstrated runnable package. B9 needs matching installed export templates, an encounter-specific preset and local artifact validation; template availability, ordinary exit behavior and OS launch handling remain unverified. No public signing/distribution pipeline is required by B1 or silently inherited from `game/`.

## 8. B2 handoff and remaining risks

**Next work order: implement preparation-only rack purchase and rearrangement in the existing encounter, preserving ordinary receiving/pricing/stocking/buyer/queue/closing flow.** B1 supplied the completed prerequisite. The owner separately authorized B2 runtime/UI work and isolated verification on September 22; see [B2 delivery](b2-delivery.md). The sequence below remains the implemented contract and acceptance map, not authorization for B3.

### Exact implementation sequence and contracts

1. Add `encounter/layout.gd` as a pure shared geometry helper; keep business state in `state.gd`. Implement `fixture_definition(type)`, `capacity(layout)`, `slot_ids(layout)`, `obstacles(layout)`, `ports(layout, fixture_id)`, `queue_ports(layout)`, `floor_bounds(space_level)` and `check(layout)`. `check` returns `{ok, reason, fixture_id, port_id}` and performs section-3 clearance/connectivity using the same grid rules as scene routing. B2 supports space level 0 only; reject level 1 until B3. No file-size-driven general architecture rewrite.
2. In `state.gd` `reset`, add schema-6 fields, one starter rack and fixed stations, preserving R5 $550/three-copy/three-title rules until their named later stages. Add `preview_fixture(command)` and `commit_fixture(command)`: command contains request ID, expected phase/day/layout revision, operation `buy` or `move`, type/fixture ID and snapped origin. Preview is pure. Commit uses the same validation plus current cash and returns `{ok, code, fixture_id, revision}`. Revision increments only on successful layout mutation. Buy assigns rack-0002 and records the $60 expense once; move is free. Persist fulfilled request IDs/event identity. Reject noninteger coordinates, unknown IDs, stale revisions, illegal phases, fixed-station moves and third-rack purchases.
3. Replace `CAPACITY` uses in `stock`, `shelf_used`, `valid` and UI with derived rack slots. Implement `stock_copy(copy_id, fixture_id, slot_index, expected_revision)` and `return_copy(copy_id)`; preserve `stock(product, quantity)` as a deterministic adapter to free slots for existing controls/tests until converted. Reserved copies keep slots. `sale` frees one slot; `release` restores the same one. All failed commands leave the full state unchanged. Derive copy presentation from slot identity, not dictionary iteration.
4. In `main.gd` `_ready`/`restore_view`, build fixture sprites and package sprites from layout; remove independent authoritative `BLOCKS`/`BROWSE_SPOTS`/`QUEUE_SPOTS` constants. `station(action, fixture_id)` resolves the shared ports. `request_action` captures fixture/copy/slot/revision and original price/product. `perform` rechecks claim/revision and physical arrival. `route` returns an explicit unreachable result; `_process` must not interpret no path as arrival. `update_wave` reserves/free browse ports, uses layout queue ports and preserves dynamic buyer avoidance. `refresh` shows selected rack occupancy/total capacity. Rebuild navigation only on successful revision/load, not on ghost movement.
5. Add Arrange/Buy/select-rack controls alongside existing `show_assortment`; implement pointer/arrow/Enter/Escape semantics from section 3 and preserve glass UI readability. Draft cancel is local UI-only; disable unrelated actions while previewing. Reject layout entry while pending action/claim remains, with Finish/cancel current action guidance. On successful edit, clear stale paths and keep player at a reachable position (reject placement covering current player foot clearance). B4 consumes this pause contract later.
6. Update `valid`, `save_to`/`load_from` numeric normalization, `project.godot` namespace and isolation matching in `scripts/validate.py` plus its synthetic wrapper test as necessary. Existing atomic load failure remains. Change current suites only where intended layout/schema behavior differs; add `scripts/test_layout.gd` and `scripts/test_layout_scene.gd` to explicit runner selection. Preserve all old evidence and art masters.
7. Visually align retained rack, receiving and counter exports to proposed collision/port data. Reuse original art at its intended scale; save any necessary alignment/export revision as new assets/masters rather than overwriting retained sources. B2 requires ghost/selection/slot overlays and readable overlap feedback; no new product art, employee rigs or broad motion rebuild. Add only new fixture art if retained art cannot represent the specified footprint coherently, and document the change.

### Required B2 acceptance cases

| Case | Required result |
| --- | --- |
| Fresh schema 6 | Four slots, three R5 starter copies, fixed receiving/counter; zero fixture expense; valid cash |
| Buy confirmation | $550 → $490, rack-0002, eight slots, one $60 event; same request again changes nothing |
| Cancel / reject | Cancel preview, insufficient cash, overlap, bounds, reserved aisle, blocked port/route, fixed-station move, stale command, third rack: no cash/layout/copy/event change; distinct useful reason |
| Stocked move | Move rack-0001 from (440,330) to proposed legal (430,330); same copy IDs/costs/prices/slots before/after and after reload; render and routes use new origin |
| Capacity | Four/eight occupancy boundary; a held reservation still occupies its slot; sale frees one; return frees one; refusal restores original slot; no slot double use |
| Ordinary altered-layout day | Receive, label, select/stock both racks, open, browse, reserve, queue, serve, close/drain, report, order/advance/receive again via normal controls; no fixture intersections or buyer overlap |
| Routing | Nonoverlapping but disconnected layout rejected; entry/browse/queue/exit and receiving/work/cashier connectivity checked; temporary occupied aisle waits without remote transaction |
| Pending action | Later dropdown/price/fixture changes cannot retarget already requested work; invalidated revision rejects; empty path does not trigger perform |
| Phase/save | Editing only prep; draft excluded from save; stocked layout and expense reload exactly; malformed/old schema rejected without live replacement; duplicate purchase after reload cannot debit again |
| Visual interaction | Normal and Retina preview, selected slots, bought rack and moved stocked rack readable; keyboard cancel/confirm and real pointer placement work; screenshots plus actual moving customer inspection |

Suggested legal coordinates are starting test inputs, not a reason to weaken route checks if visual inspection exposes a genuine flaw. Any necessary geometry adjustment must update the shared contract, checks and documented defaults together. B2's output must identify the resulting source (including uncommitted changes), retain isolated technical/visible evidence, name limits and hand off B3; it does not claim employees or expansion implemented.

**Later consumers:** B3 changes `space_level` and adds rack-0003 through the same validator/commit mechanism; B4 claims `slot_ids` and work/cashier ports; B5 uses backroom/slot provenance for unique used copies and intake port; B6 uses rack browse ports for expanded roster; B7 styles these ordinary interactions; B8 tunes prices/counts only with updated evidence; B9 packages their shared project. Fixture purchase's small expense ledger must land in B2 because cash validation already depends on it; full bills/insolvency stay B3. This is a concrete dependency refinement, not an additional feature slice.

**Exclusions:** no fixture selling/removal, arbitrary rotation, general construction tools, additional shop locations, worker simulation in B2, expansion purchase in B2, seller trading/releases in B2, preorders, shopper negotiation, baskets/substitution/reputation, trade credit/repair, endless day 8, cloud saves, historical-game rewrite, public release or Git publication.

**Remaining risks and gates:**

- B2 exercised relocated racks and queues and corrected the passing lane, as documented in its delivery. Static reachability alone was insufficient. B4 still must test worker contention; B2 evidence does not accept animation or expanded-shop play.
- The viable budget is exact arithmetic, not proven workload/demand/fun. B8 must establish two viable paths and recovery with real integrated content; figures can change with recorded recalculation.
- Current `valid()` embeds old catalog/cost/roster/order assumptions. Each schema stage must replace those assumptions deliberately and retain copy/cash provenance; weakening validation to pass new data is unacceptable.
- Starting stock, release purchases and references change in B3/B6, not accidentally during layout work. Intermediate B2 is not the final first-week economy.
- Rigid/deforming legs, abrupt stops/turns, reach/slide/mirrored-lighting/reuse artifacts remain B7 presentation work. R5 verdict remains pending independently; no technical B2 blocker requires repeating settled scope questions.
- Historical capture-exit ObjectDB leak warning remains unresolved. B9 must determine ordinary-play impact and repair blockers; absence from a retained log is not resolution.
- Export templates, Mac artifact launch, writable packaged saves and full-week quit/resume are still unverified B9 dependencies. No beta or owner acceptance is supplied here.

B1 verification: 46 local documentation links (including section anchors) resolved; integer-cent calculations independently reproduced all seven closing balances, purchase/sale quantities, inventory availability and display capacity, gross/operating results, and the failure shortfall. Retained September 21 source hashes still match after these documentation edits; whitespace checks passed. These checks are limited to source/evidence inspection, documentation, scope mapping and arithmetic. **Historical B1 stop: B2 handoff. B2 subsequently received separate authorization; stop after B2, before B3.**

## B3 implementation reconciliation — September 22

The separately authorized [B3 delivery](b3-delivery.md) now implements schema 7 / `b3-growth-1`, six prepaid copies, 64-copy backroom/inbound capacity, day-5 north-bay expansion, rent, settlement, terminal results and checkpoint/restart policy. References, three shoppers and overnight supplier timing remain unchanged until B6. Ordinary B3 creates no employees/wages. The observed B3 $325 survivor and $110 shortfall are separate from this packet’s prospective full-content $570.40/$80 examples. B4 consumes the wage-accounting seam and must add actual employment, workers and job drain. Historical B1/B2 stop instructions above describe their own deliveries; the current stop is after B3, before B4.


## B4 implementation reconciliation — September 22

The separately authorized [B4 delivery](b4-delivery.md) implements schema 8 / `b4-employees-1` and its separate development namespace. Morgan/Jules employment, commitments, physical stocking/checkout, execution claims, takeover, cancellation/restoration and real wage settlement now extend B3. Earlier stop instructions above remain historical delivery boundaries. Current stop: after B4, before B5. No used trading, release, wider customer or supplier-timing changes are included; no owner or audio acceptance is inferred.

## B5 implementation reconciliation — September 22

The separately authorized [B5 delivery](b5-delivery.md) implements schema 9 / `b5-used-1` in `game-sim-first-week-dev-v9`, preserving the B1–B4 input and evidence. Section 2’s five-title references, authored seller overrides, additional buyers, releases and same-day supplier plan remain prospective B6 content. B5 deliberately uses the current three references and generic section-5 condition/70%-ask/50%-floor rules; days 2–7 offer C-good, O-fair, T-good, C-fair, O-good and T-worn. No unreleased title is introduced to reproduce future examples. Used-copy buyer budgets scale by the same condition percentage at selection and lock alongside the fixed offer. B6 may change the roster/references under schema 10 while preserving immutable acquisition cost/provenance and transaction limits.

Separate physical intake and inspection, bounded persisted offers, exact explicit purchase confirmation, next-prep individual labels and existing player/worker stocking/checkout/reporting now operate together. `layout.gd` adds protected Rowan inspection at (810,420), beside seller intake (850,420); fixed cashier/buyer ports remain. Closing cancels unpaid accepted or unaccepted trades, drains visible seller departure and buyer/checkout work, then settles. Completed purchases survive closure/restoration. Earlier stop instructions above are historical. Current stop: after B5, before B6. Technical checks are not owner acceptance or audio qualification.


## B6 implementation reconciliation — September 22

[B6 delivery](b6-delivery.md) implements sections 2 and 4–7 under schema 10 / `b6-retail-1` in its separate v10 development namespace. The final five references, releases, authored buyers and seller overrides now replace B5’s interim rotation, condition-scaled budgets, generic seller terms and overnight supplier flow. All original evidence remains bound to its historical ruleset. Event-based acquisition ordering preserves actual paid costs; daily content materializes once and survives reload. The worked routes are attempted against both state and integrated ordinary scene controls; actual arithmetic and any discrepancies are recorded in the delivery. No specification value was changed to force the worked examples. Technical completion does not establish B8 balance or owner acceptance. Current stop: after B6, before B7.
