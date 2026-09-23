# B3 — Growth and business progression

September 22, 2026. **B3 technically complete. Stop before B4. Owner acceptance pending; not beta ready.**

B3 extends the ordinary shop with north-bay expansion, visible commitments, rent, atomic daily settlement, seven-day results, checkpoint retries and preserved terminal restarts. It preserves B2’s shared slots, routing and corrected queue geometry. No hiring, employees, used trading, releases, expanded visitor roster or supplier-timing change is implemented here.

## Delivered source and preservation

Branch `main`, HEAD `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9`, **plus uncommitted changes**. HEAD alone identifies neither incoming B2 nor delivered B3. The [incoming B1/B2 snapshot](../../encounter/evidence/b3-20260922/incoming-b2/manifest.json) preserves source, documentation and external root tracker bytes before extension. The [B3 source manifest](../../encounter/evidence/b3-20260922/source-manifest.json) identifies the resulting source and documentation; the [source snapshot](../../encounter/evidence/b3-20260922/source-snapshot.tar.gz) retains those bytes, including untracked files and the external tracker; the [validation context](../../encounter/evidence/validation-20260922T201832905104Z/context.json) identifies the exact copied encounter and Godot 4.6.2 engine. [Preservation/reconciliation](../../encounter/evidence/b3-20260922/preservation-check.json) checks executable identity and retained artwork.

Owner save directories were neither inspected nor modified. R5/schema-6 namespaces, historical evidence, source artwork and exports remain intact. B3 uses only retained fixture assets; the north floor extension is drawn in the scene, without overwriting an image or editable master. No commit, push, publication or export occurred.

## Explicit B3 ruleset

**Schema 7 / `b3-growth-1`**, separate namespace **`game-sim-first-week-dev-v7`**. Incompatible saves are rejected without migration, live-state replacement or overwrite. Integral JSON numbers are validated before normalization, including settlement records and reports.

| Rule | Implemented B3 behavior |
| --- | --- |
| Opening assets | $550 cash; six prepaid copies, two per original title; $50 historical inventory cost, no additional cash charge; one four-slot rack. |
| Prices/content | Original costs $8/$12/$5 and references $21.99/$27.99/$14.99. Three original titles and three rotating-preference visitors with existing budget multipliers. B6 owns changed references, releases and expanded content. |
| Supplier | One report-phase order per day, 0–6 copies/title, immediate full payment, next-day receiving. No day-7 terminal order. B6 owns same-day preparation ordering. |
| Storage | At most 64 backroom plus paid inbound copies; order/return checks precede mutation. Shelf capacity is separately derived from fixture slots. |
| Second rack | B2’s $60 rack-0002 remains available during prep, including after expansion. |
| Growth | From day-5 prep, $100 buys space level 1 and rack-0003 at (440,230). Eight slots without rack-0002, twelve with it. Whole candidate layout, ports, routes, phase, cash, revision and player clearance checked before commit. |
| Rent | Visible from day 1; $150 due at day-7 close. No invisible cash reserve, loan, automatic liquidation or partial bill payment. |
| Wages | No ordinary B3 wage commitments. The state-only B4 accounting seam can commit $12/staff/day from day 3; only explicitly synthetic tests use it. |
| End | Settle after customers drain. First unpaid bill ends the business; all remaining due bills remain full liabilities. Fully paid day 7 survives, including at exactly $0. No day 8 or terminal business commands. |

Expansion uses the shared fixture command/preview/commit path and stable `expansion:<run>:1` event. A repeated request is inert, including after reload; another expansion request rejects. A moved rack at (440,310) blocks the proposed new rack’s browse ports: expansion rejects without charge until the player rearranges it. Included rack placement is fixed for purchase, then movable through ordinary Arrange controls. Shared expanded bounds are [180,900) × [220,610); B2’s queue remains (800,570), (720,570), (640,570), with 28px buyer-center separation and the y=600 passing lane.

## Settlement, reports and save contract

`economy.gd` supplies pure settlement/reconstruction and financial summaries. `state.gd` publishes the synchronous candidate transition once after `can_finalize()` confirms no queued or admitted customers remain. It posts wage obligations sorted by staff ID, then day-7 rent; pays full bills until the first failure and marks that and every remaining obligation due. Unique event IDs, sequence bounds and one `finalize:<run>:<day>` record prevent duplicate settlement. Validation reconstructs every close and terminal result from the paid/due ledger and commitments, rejecting missing/edited reports, events, status, cash and terminal metadata.

Reports distinguish receipts, inventory cash purchases, historical cost of sold copies, merchandise margin, incurred overhead, paid overhead, unpaid liabilities, investment, inventory at historical cost (including paid inbound stock) and cash. Operating result includes incurred unpaid rent. Fixture/expansion outlays are investment, not merchandise costs or recurring overhead. **Finances** shows live daily cash reconciliation and week totals. **Daily closes** shows immutable settlement snapshots; report-phase supplier purchases occur afterward and appear in live daily cash, without rewriting the close.

Checkpoint autosaves follow settlement, day advance and confirmed expansion. Validated JSON is written/flushed to a sibling temporary file, then renamed atomically. Failure retains the previous checkpoint and the committed live transaction, shows **SAVE FAILED / Retry save**, and does not report success. Retry writes state only; it never repeats a charge, day advance or settlement. Explicit Save/Reload remain; the Reload tooltip names the last successful saved day/phase. A restored older checkpoint may replay later unsaved actions in that restored history; this is distinct from duplication inside a persisted history. Power-loss durability is not claimed.

Confirmed **Restart week** first preserves terminal state as `terminal-<run-id>.json`. An unwritable destination or conflicting existing terminal result blocks restart; live terminal state remains. Only after preservation does restart create and checkpoint a new run. Earlier namespaces and terminal archives are not automatically imported or overwritten. A terminal archive is an ordinary supported schema-7 file, verified by reload tests; a browsable archive picker remains presentation work.

## Verification and actual B3 examples

Final isolated [validation](../../encounter/evidence/validation-20260922T201832905104Z/) passes **14 engine processes**, all exit 0, without logged script/engine errors or warnings. Suites: **113 assortment state, 52 layout state, 84 growth/economy state, 3 pending-price, 54 assortment scene, 48 layout scene, 39 growth scene** checks. Each scene suite runs headless, normal 1280×720 and Retina 2560×1440. [Four wrapper tests](../../encounter/evidence/b3-20260922/wrapper-tests.log) also pass, including refusal of schema-6/R5 namespaces or ambiguous/disabled isolation.

| Case | Retained result |
| --- | --- |
| Expansion | Day 1/4 rejects; day 5 succeeds; pure/canceled preview; blocked new browse port; rearrange/retry; insufficient cash; duplicate request and reload; expansion before/after rack-0002; later paid rack purchase. [State checks](../../encounter/evidence/validation-20260922T201832905104Z/results/growth-state.json). |
| Expanded ordinary shop | Pointer/key preview/cancel/confirm; stock two products on rack-0003; buy rack-0002 afterward; move stocked north rack; actual browsing/queue/checkout/drain; no sampled fixture intersections or buyer overlaps. [Scene checks](../../encounter/evidence/validation-20260922T201832905104Z/results/growth-scene-normal.json), [movement trace](../../encounter/evidence/validation-20260922T201832905104Z/results/growth-motion-normal.json). |
| Financial state | Daily reconciliation and frozen snapshots; repeated finalize/reload; full paid day 7; rent bankruptcy; zero-cash survival; terminal mutation rejection; archive preservation and restart; malformed and prior-schema rejection. |
| Write failure/retry | Injected temporary-path write failure after expansion, settlement, day advance and paid day-7 rent; retained prior checkpoint, live commit, false success prevented, repeat command inert, retry succeeds without another debit/advance. Expanded-room scene exercises the visible Retry save control at both sizes. |
| B4 interface only | Synthetic commitment idempotency, staff-ID ordering, paid wages before unpaid rent, first unpaid wage leaving all remaining wages/rent due, and reload. No employee contribution, job, hiring or actual wage-play claim. |
| B2 regressions | Stocked movement/slot identity, insufficient fixture cash, malformed saves, price snapshot, stale revision, unreachable work, occupied-aisle waiting, shared navigation and corrected dynamic queue drain. Six-copy assertions were intentionally updated; historical B2 evidence is unchanged. |

The [growth state result](../../encounter/evidence/validation-20260922T201832905104Z/results/growth-state.json) retains complete resulting example states, not just expected arithmetic:

| Actual-rule example | Receipts | Supplier spending | Investment | Paid rent | Unpaid rent | Final cash | Merchandise margin / operating result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Seven-day survivor | $210 | $125 | $160 | $150 | $0 | **$325** | $35 / −$115 |
| Separate failure | $0 | $450 | $60 | $0 | $150 | **$40** | $0 / −$150 |

Survivor: label each title $10, sell one of each daily, use six prepaid copies for days 1–2, buy one of each at reports 2–6, buy rack-0002 day 1 and expansion day 5. Twenty-one sales, $175 cost of sales, no ending inventory; $550 + $210 − $125 − $160 − $150 = $325. This surviving business consumes starting capital and has a negative operating result; it is not claimed profitable or balanced.

Failure: no displayed stock/sales, buy rack-0002 and six of each title at reports 1–3. Sixty owned copies, $500 inventory at historical cost; $550 − $450 − $60 = $40. Full $150 rent stays unpaid, shortfall **$110**, no partial debit. Both examples use zero wages and the actual B3 content. **They do not reproduce B1’s prospective full-content $570.40 survivor or $80 shortfall.**

The separate rendered scene uses a documented state-command prelude through empty days 1–4, then ordinary controls to expand, stock/browse/serve day 5, close days 6–7, save/reload and restart. Its sparse survivor finishes at **$270** ($30 receipts, $160 investment, $150 rent); it is not the $325 state-run example. Its separate bankruptcy reaches the same $40/$110 outcome using actual stock/rack spending. [Normal/Retina images](../../encounter/evidence/validation-20260922T201832905104Z/results/), [B3 interaction video](../../encounter/evidence/validation-20260922T201832905104Z/b3-interaction.mp4) and [B2 regression video](../../encounter/evidence/validation-20260922T201832905104Z/b2-interaction.mp4) retain input and movement. Scripted viewport input runs at 3× simulation time; preludes/fault probes are engineering checks, not a fresh owner playthrough.

## Failures, limitations and B4 handoff

Earlier attempts are retained under [B3 evidence](../../encounter/evidence/b3-20260922/) and their dated validation directories. Initial JSON roundtrip checks exposed integer/float dictionary-comparison rejection; numeric equivalence/normalization fixed it. A scene assertion initially expected all three day-5 buyers at inherited labels, but the Curb buyer correctly refused $21.99 against a $20.89 budget; the test now intentionally labels $10 through ordinary controls. Earlier failure-exit warnings remain recorded rather than relabeled as passes. Final visual inspection also corrected toolbar/bill placement and terminal text. The final candidate is tied to its own fresh evidence.

All isolated engine runs use **Dummy audio**. Muted rendering/input/movement evidence does **not** qualify audio. Retained motion, rigid/deforming legs, abrupt turns/stops, reach/slide, mirrored lighting and reused rigs remain B7/owner concerns. B3 adds a functional room extension using retained art; it does not claim final environment-art or animation acceptance. Historical capture-exit warnings still require B9 ordinary-play investigation; clean final logs here do not close that issue. Mac packaging, cross-session packaged behavior and complete-content balance remain later gates.

**B4 next, after separate authorization:** implement actual Morgan/Jules hiring, dismissal and jobs; connect hire/open commitments to `commit_wage()` exactly once per staff/day. Existing next-day employees should commit on Open; hire owes that day even if dismissed; dismissal before the next opening avoids that next wage. B4 must distinguish copy reservations from worker claims, arbitrate stock slots/FIFO cashier ownership, preserve player takeover, cancel/finish jobs before settlement, and reconcile claims after reload. The current customer-only drain is not worker qualification. Recheck real wages and reports with actual employment. B4’s planned schema 8 needs its own namespace. Keep releases, expanded customer content and supplier timing in B6.

**Technical B3 completion is separate from R5/B2/B3 owner acceptance and B10 beta acceptance. No B4 implementation is running.**
