# B6 — New Releases and Retail Breadth

September 22, 2026 (local date; final evidence timestamps use UTC). **B6 technically complete. Stop before B7. Owner acceptance pending; not beta ready.**

The complete authored first week now runs through one shop, shared inventory, staff, seller intake and financial ledger. Signal Harbor releases on day 4 and Pocket Rally Club on day 6. Preparation supports one paid mixed supplier order received that same preparation. B6 replaces B5’s interim references, rotating buyers, condition-scaled budgets, seller terms/timing and overnight ordering together.

## Candidate and preservation

Branch `main`, HEAD `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9`, **plus all incoming and resulting uncommitted files**. HEAD alone does not identify this candidate. Before editing, B6 retained the [incoming manifest](../../encounter/evidence/b6-20260922/incoming-manifest.json), [B1–B5 source/document/tracker archive](../../encounter/evidence/b6-20260922/incoming-b1-b5.tar.gz) and [working-tree status](../../encounter/evidence/b6-20260922/incoming-status.txt). Earlier deliveries, evidence, samples and artwork/masters remain intact.

The [final source manifest](../../encounter/evidence/b6-20260922/source-manifest.json), [source snapshot](../../encounter/evidence/b6-20260922/source-snapshot.tar.gz) and [preservation/verification reconciliation](../../encounter/evidence/b6-20260922/preservation-check.json) identify the exact delivered runtime, tests, artwork, documents and external root tracker. Final [isolated validation context](../../encounter/evidence/validation-20260923T003918484574Z/context.json) binds execution to source bytes, including uncommitted assets and scripts. Finalized documentation is separately identified. No owner-save access, commit, push or publication occurred.

## Final rules and B5 transition

**Schema 10 / `b6-retail-1`; development namespace `game-sim-first-week-dev-v10`.** Older namespaces remain untouched. Wrong-schema/ruleset files cannot replace live state or be overwritten by Save. No migration is claimed. The wrapper rejects older namespaces, missing/duplicate settings and disabled isolation before launching Godot.

| Area | B6 behavior |
| --- | --- |
| Catalog | Curb $8 cost / $20 reference; Tide $12 / $26; Orbit $5 / $14; Signal $16 / $30 from day 4; Rally $10 / $24 from day 6. Six prepaid original-title copies retain their $50 historical cost. |
| Release controls | Day-1 calendar shows both release dates and daily interests. Unreleased supplier quantities and product dropdown entries are disabled. State rejects early purchases before debit. No preorders, deposits or open/report purchases. |
| Supplier | Receive opening assets, then confirm at most one mixed order per preparation; integer 0–6 per released title and at least one total. Cash and 64-copy backroom plus inbound capacity checked before debit. One payment/event, same-day receiving, repeated receive inert; unpaid draft excluded from save. Unreceived orders block opening. |
| Daily buyers | Counts 3/4/5/6/7/8/8 and exact B1 title sequences. First occurrences seek new at 110% of new reference; repeats accept new or any used grade at alternating 90%/80%, floor cents. **No condition-scaled buyer budget remains.** No substitution or shopper negotiation. |
| Identity and arrival | `buyer:<run>:<day>:<ordinal>`, 18-second intervals starting at zero, at most three active buyers including departing bodies. Alex/Blair/Casey plus Devon/Ellis/Frankie; appearances cycle for seventh/eighth arrivals. Opening snapshots every day’s titles, budgets, eligibility, appearances and timing in persistent `daily_content`. |
| Selection and reservations | Stable acquisition-event sequence, then copy ID. Buyers wait for the oldest eligible copy’s rack rather than choosing a newer rack when its browse ports are occupied. Selection at the rack locks copy, slot, label, budget and decision. Live reservations cannot be relabeled or returned. |
| Sellers | Separate 30-second seller arrival from day 2, outside buyer FIFO. Days 2–7: C-good, O-fair, T-good, C-fair, O-good, R-worn. First five ask/floor overrides: $11/$8, $6/$4, $14/$10, $8/$5, $8/$6. Worn Rally: $9.60 suggested resale, $6.72 ask, $4.80 floor. Terms and timing persist. |
| Acquisition | Preserved inspection, one initial and at most one final shop offer, one seller counter, separate exact-payment confirmation, stale/duplicate protection and cash/capacity preflight. Actual accepted payment becomes immutable copy cost. New used stock unlocks next preparation; late day-7 stock cannot resell within this week. |
| Ordinary inventory | Five-title labels, shelf art, supplier lines, assortment/report rows, individual new/used copy labels, exact-copy Shelf +1 and Return. Sold rows leave the editable-copy list but remain in sales/financial history. New-product labels do not alter used labels. Player and employees share stock/sale claims and actual-cost reporting. |
| Financial history | Starter and new/used costs never change with references or resale labels. Event-based acquisition ordering replaces B5’s separate used-sequence range. Frozen closes include same-prep spending; no post-close supplier flow. Wages, rent, unpaid liabilities, investment and stock-at-cost remain separate. |

`week_content.gd` owns the catalog/calendar and authored buyer definitions. `state.gd` owns materialization, availability, orders, reservations, copy identity and validation. `used.gd` applies final seller terms; `staff.gd` validates buyer jobs against their own run/day roster. Eight scene presentation slots rekey on advance/reload; only three buyers are admitted. Workers and the seller remain separate physical bodies.

## Artwork and visible behavior

Two new 152×208 cover exports extend the retained illustrated package style: [Signal master](../../encounter/source/case-signal.svg) / [export](../../encounter/art/case-signal.png), [Rally master](../../encounter/source/case-rally.svg) / [export](../../encounter/art/case-rally.png). SVG groups keep case/platform, illustration and title independently editable. These are new vector masters; the existing Krita masters and their exports are preserved.

Devon’s spectacles/purple clothing, Ellis’s cream knit cap/green clothing and Frankie’s copper headphones/warm clothing use nine editable front/side/back SVG overlays and PNG exports with the original illustrated rigs. [Art round-trip evidence](../../encounter/evidence/b6-20260922/art-roundtrip.json) verifies all eleven masters re-export to identical PNG bytes. A separate [appearance contact sheet](../../encounter/evidence/b6-20260922/appearances-probe.png) inspects front/side/back overlays using scripted actor placement; it is a synthetic art probe, distinct from the ordinary moving-actor scene evidence. `scripts/build_week_art.py` rebuilds only these new assets. Reused rig, body proportions and existing animation limitations remain B7 work, not newly accepted character animation.

The base-shop stress run exposed reciprocal route oscillation and stale click-to-walk paths. Automatic player/worker travel now yields to nearby queued/exiting buyers, click-to-walk replans around live bodies, and shortcuts past a nearby grid waypoint require segment clearance. This is a bounded B6 arrival-drain repair; it does not change walk/reach animation. No teleport or remote transaction was introduced. Visible floor-name labels can still crowd the expansion control and nearby names; broad label placement and motion polish remain B7 limitations. Primary controls, financial headings and dialogs remain readable.

## Verification and actual arithmetic

Final [validation directory](../../encounter/evidence/validation-20260923T003918484574Z/) retains import, state, regression, pending-price and both scene suites in headless, normal 1280×720 and Retina 2560×1440 modes. It uses Godot 4.6.2, disposable projects/save namespaces and Dummy audio. State suites contain 706 week checks, 86 shared regressions and 3 pending-price checks; scene suites contain 307 integrated-week and 98 breadth checks per mode. Exact counts, process exits, warnings, source matches and visual review are recorded in the reconciliation. [Four wrapper tests](../../encounter/evidence/b6-20260922/wrapper-tests.log) cover isolation and error handling.

| Required case | Evidence / outcome |
| --- | --- |
| Releases / ordering | [Week state](../../encounter/evidence/validation-20260923T003918484574Z/results/week-state.json): before/on/after day 4 and day 6, unchanged cash/state on early purchase, same-prep payment/receive, pending reload, duplicate order/receipt, open/report rejection and preserved copies. |
| Capacity / rejected commands | [Regressions](../../encounter/evidence/validation-20260923T003918484574Z/results/week-regressions.json): invalid/fractional/negative/oversize quantities, unaffordable order, legitimate paid 64-copy backroom/inbound boundary, seller capacity rejection and accepted-offer preservation. Separate injected insufficient-cash/inbound probes are labeled in the state script. |
| Demand / sellers / costs | Exact daily materialization and restored terms; no rerolls; first-new/repeat-used eligibility, budget refusal, stock misses, immutable live offers, oldest acquisition/copy selection, authored floors, exact above-floor payments, refused final offer, explicit refusal, cancellation, stale fields, duplicate payment and tampered provenance rejection. |
| B2–B5 shared regressions | Invalid layout nonpayment, idempotent rack expense, stocked move/slots/reload, expansion, exclusive copy/slot/cashier claims, receiving prerequisite, explicit takeover, restore cancellation, FIFO reservation and worker commits, actual wages, close/terminal sealing, save failure/retry and terminal archive. Older broad slice suites retain interim content assumptions and are historical; they are not claimed as current passes. |
| Integrated ordinary week | [Normal week](../../encounter/evidence/validation-20260923T003918484574Z/results/week-scene-normal.json), [Retina week](../../encounter/evidence/validation-20260923T003918484574Z/results/week-scene-retina.json): fresh run, rack, both releases, same-day orders, five used purchases/resales, Morgan day 3/Jules day 6, expansion day 5, actual wages/rent, all 41 buyers, separate sellers, daily closes, terminal result and save/resume including live release-day progress. |
| Unexpanded contention / player resale | [Normal breadth](../../encounter/evidence/validation-20260923T003918484574Z/results/breadth-scene-normal.json), [Retina breadth](../../encounter/evidence/validation-20260923T003918484574Z/results/breadth-scene-retina.json): eight day-6 arrivals, two workers, separate seller, five-title new/used allocation, exact-copy return, player used stocking/resale and release-title sale; no expansion. Active-cap, actor separation, fixture clearance and continuous validity sampled. |
| Visual checks | [Full-week video](../../encounter/evidence/validation-20260923T003918484574Z/week-interaction.mp4), [base-shop video](../../encounter/evidence/validation-20260923T003918484574Z/breadth-interaction.mp4), normal/Retina screenshots and motion traces, with [visible review](../../encounter/evidence/b6-20260922/visible-work-review.json). Controls, calendar, release quantities, labels, shelf artwork, extra appearances and moving actor work are checked. |

B1’s surviving strategy was attempted, not made an asserted target that altered code. The scripted state route and ordinary scene route both produced these actual results:

| Day | Sales receipts | New purchases | Used purchases | Investment | Wages | Rent | Closing cash |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | $60 | $0 | $0 | $60 | $0 | $0 | $550 |
| 2 | $60 | $0 | $8 | $0 | $0 | $0 | $602 |
| 3 | $76 | $25 | $4 | $0 | $12 | $0 | $637 |
| 4 | $98.40 | $57 | $10 | $0 | $12 | $0 | $656.40 |
| 5 | $110.80 | $25 | $5 | $100 | $12 | $0 | $625.20 |
| 6 | $126 | $77 | $6 | $0 | $24 | $0 | $644.20 |
| 7 | $125.20 | $25 | $0 | $0 | $24 | $150 | **$570.40** |

Total receipts **$656.40**, new purchases $209, used purchases $33, investment $160, wages $84, rent $150. Thirty-two sales, $292 historical cost of sales, zero ending inventory, **$364.40 merchandise margin** and **$130.40 operating result**. Cash: $550 + $656.40 − $209 − $33 − $160 − $84 − $150 = $570.40. Nine shoppers miss stock; their existence does not guarantee a sale.

The separate scripted B1 failure route bought 36 new copies over days 1–2, kept inventory off shelves, bought the rack and hired both staff from day 3. Closing cash: **$340, $190, $166, $142, $118, $94, $70**. Day-7 wages settle first; $150 rent remains fully unpaid, producing **$80 shortfall**, $350 inventory at historical cost and −$270 incurred operating result. No partial rent payment or automatic liquidation. No specification correction was required; the implemented arithmetic agrees with both examples.

The focused unexpanded day-6 allocation produces **$126 receipts**, $56 sold-copy cost, $70 merchandise margin and **$555 ending cash** after two wages. It sells fair Curb at $12 with its actual $5 acquisition cost through Rowan. Retained earlier attempts left an older new Curb available; the repeat buyer correctly chose it and refused its $20 label against an $18 budget. The final ordinary allocation returns that specific extra new copy before opening. This is a documented player stocking choice, not a budget/selection rule change or a forced positive result.

## Evidence boundaries and retained failures

State suites execute scripted transitions, physical-port setup and explicitly labeled faults; they are not ordinary play. The integrated scene starts fresh and uses ordinary buttons, walking, numeric controls and dropdown signals. Test simulation runs at 3×, with paused boundaries for exact save/reload checks. The breadth scenario uses an explicit empty-day state prelude to reach day 5; its trading, allocation, movement and resale use controls. Motion traces accompany rendered work; screenshots alone do not prove physical completion. **All engine checks are muted; none qualifies audio.**

Earlier probes remain under `encounter/evidence/b6-20260922/probe*`, and earlier validation directories remain retained. They exposed JSON roster integer normalization, the old staff buyer-ID validator, overlapping new toolbar/header controls, the valid oldest-new budget refusal, the routing stalls described above, accessories assigned too late during rig initialization, and clothing tint affecting exposed hands. The final rig sets appearance before construction and tints the torso only. Long worker labels now show a short role; detailed status uses shopper names rather than raw transaction identities. Native replay also exposed missed mouse activations when mouse-down and mouse-up were separated by simulation frames; the final replay sends each click together and checks actual button activation, with bounded retries through the same input path. It never emits button actions directly. Interim rendered validations were stopped when source changed or failed; they are not final qualification. Initial failure exits also reported ObjectDB/resource cleanup warnings. Final clean exits, if observed, do not resolve the broader historical packaged/ordinary-exit question.

The authored week provides used original titles and a day-7 worn Rally offer. It provides no used Signal seller, and no next-day resale for a day-7 acquisition. Shared copy controls and reports support all five IDs without special-case resale code; no artificial ordinary used-Signal transaction or eighth day is claimed. No additional seller schedule, location, campaign, preorder, shopper haggling or unrelated system was added.

## B7 handoff and stop

B6 is a technically integrated first week, **not B8 balance exploration, owner fun acceptance or beta readiness**. B7 may now improve onboarding, ordinary new/continue/save/quit flow, menu/report comfort, and broad walk/turn/stop/reach presentation. Preserve the final catalog/release/supplier contract, reference-based eligibility/budgets, materialized identities, exact seller payments, historical acquisition costs, shared claims and schema-10 namespace. Keep all existing masters and evidence.

B8 still owes materially different viable strategies and recovery/balance evidence. B9 owns the Mac package, packaged save/resume, audio and ordinary-exit qualification. B10 owns whole-week owner judgment. R5/B2–B6 owner acceptance remains pending. **B6 ends here; no B7 implementation is included or running.**
