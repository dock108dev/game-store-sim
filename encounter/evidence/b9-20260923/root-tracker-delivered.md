# Game Store Sim — Path to Personal Beta

Updated: 2026-09-23 UTC. Status: **B9 PERSONAL MAC DELIVERY TECHNICALLY COMPLETE; B10 OWNER REVIEW NEXT; OWNER ACCEPTANCE PENDING; NOT BETA READY.**

This is the entry point for the complete path to beta, replacing a tracker that ended at the next small owner review. The September 22 tasks authorized and implemented B2–B7 runtime/UI changes and isolated verification. B8 subsequently completed isolated balance evaluation without numerical tuning. B9 now delivers and qualifies the identified encounter Mac app, with a bounded navigation repair. Stop before B10 or an owner session; technical deliveries do not supply owner acceptance. Historical R5 evidence remains available for focused comparison. A beta must deliver the agreed sustained shop experience, not merely pass the encounter checks.

## Product direction and decisions

Confirmed foundation: an illustrated 2.5D early-2000s mall game shop, retaining the retail-v4 visual baseline and hands-on retail interaction. Current development is in `game-sim/encounter/`. The older first-person game and its extensive design documents are historical; their feature lists are not automatically requirements or implemented features of this restart.

The owner requests a complete beta path with implemented work, remaining work, backlog and issues. The first-week target and core requirements below are now confirmed. Numeric balancing and production details are planning decisions, not missing owner permission. Ask grouped short questions only if a consequential choice cannot be resolved within this direction.

| Decision | Confirmed scope |
| --- | --- |
| Beta experience | “call it the first week of owning the store or something”; use seven in-game days as the planning interpretation, not seven real days or a fixed session duration |
| Shop | One expandable shop is enough; growth and rearranging the layout are essential |
| Employees | Hire employees for stocking and checkout; player can continue hands-on work |
| Business pressure | Rent and wages create real bankruptcy risk |
| Used games | Buy games from customers and resell them; condition affects acquisition/resale value |
| Negotiation | Only when customers sell to the shop; shoppers buying stock do not haggle |
| New game releases | Required during the playable week |
| Preorders | Excluded from beta; do not add advance customer deposits or future-release promises |
| Presentation | Retain the current illustrated art style and improve animation; this is direction approval, not acceptance of current motion defects |
| Platform | Personal Mac beta remains the working baseline; public distribution is separate |

## First-week beta promise

Start with a small shop and enough resources for a viable opening. Over seven in-game days, arrange the space, buy and price new/used stock, serve shoppers, negotiate purchases from sellers, hire and direct staff, respond to new releases, pay wages/rent and reinvest in the same shop. End with a clear first-week result showing whether the business survived, how it changed and what drove its finances.

A successful ordinary playthrough must make every required system meaningfully available during that week, including an affordable growth opportunity. It need not force every player to hire, expand or buy a particular title. Bad choices can lead to a clearly explained bankruptcy outcome. A tested failure path is separate from the full surviving-week review; failure must not conceal undelivered later content.

### Proposed pacing — adjustable implementation plan

These are design defaults to implement and tune, not further questions or previously observed gameplay. Introduce choices without turning each day into a locked tutorial.

| Day | Experience focus | What must be available / intelligible |
| --- | --- | --- |
| 1 | Open and understand the shop | Arrange fixtures, receive/price/stock, serve, close/report/save; explain upcoming bills from the start |
| 2 | Build a used-game margin | Sellers bring condition-graded games; inspect, make/counter/refuse offers, pay and acquire; fixed-price resale |
| 3 | Delegate routine work | Hire and assign stocking/checkout; see wage cost and actual worker contribution; keep player actions available |
| 4 | Respond to a new release | A new title becomes purchasable on release; demand and stock choices matter; no preorders |
| 5 | Reinvest in the shop | A viable route to one capacity/space upgrade and a useful layout change within the same premises |
| 6 | Run the combined business | New/used mix, staff, queues, bills and remaining cash create competing choices; preserve recovery options |
| 7 | Close the first week | Settle scheduled bills, show sales/costs/wages/rent/cash and growth, explain survival or bankruptcy, retain the save |

There is no promised day-eight campaign in this beta. Provide a clear end-of-week review and restart/return path; do not silently add an endless mode. Prototype content targets: enough titles to make shelf allocation consequential; at least one genuinely new release during the week; sellers with more than one meaningful condition grade; customers with varied preferences/budgets; one reachable upgrade; and staff demonstrably able to perform both required roles. B1 now records exact initial counts and prices for tuning in B8; no fixed catalog number is claimed as owner-approved.

## Implemented and supported by evidence

| Capability | What exists | Acceptance / limits |
| --- | --- | --- |
| Hands-on illustrated shop | Movement, stations, receiving, labeling, stocking and serving | R1 accepted within scope; animation quality not accepted |
| Repeatable days | Close, finalize reports and advance; B6 buys/receives replenishment during preparation | R2 acceptance remains historical; B6 technical evidence covers final timing |
| Pricing consequences | Per-product prices, fixed customer budgets, locked offers, price refusal | R3 accepted within scope; small authored demand model |
| Several customers | Three visitors, browsing, reservations, FIFO service and closing/draining | R4 accepted: “yes”; not a scaled customer simulation |
| Assortment choices | Three fictional games, four shelf spaces, backroom stock, returns, mixed orders and per-product reports | R5 engineering verified; owner acceptance PENDING |
| Shop layout and capacity | Preparation-only rack purchase/movement; pointer and keyboard preview/confirm/cancel; stable slots; four/eight capacity; shared geometry and routes | B2 technical evidence in [delivery](game-sim/docs/03-production/b2-delivery.md); owner acceptance pending; expansion stays B3 |
| Growth and first-week finances | Day-5 $100 north bay/rack-0003, $150 day-7 rent, exactly-once settlement, liabilities/bankruptcy, seven-day result and preserved restart | [B3 delivery](game-sim/docs/03-production/b3-delivery.md); intermediate content, no employees; owner acceptance pending |
| Employees | Morgan/Jules hiring, $12 daily commitments, stocking/checkout claims and physical work, explicit takeover and restoration | [B4 delivery](game-sim/docs/03-production/b4-delivery.md); isolated technical evidence, owner acceptance pending |
| Used-game business | Physical seller intake, condition-sensitive saved negotiation, exact payment, individual used labels and fixed-price resale through player/staff claims | [B5 delivery](game-sim/docs/03-production/b5-delivery.md); technical evidence, owner acceptance pending |
| New releases and first-week breadth | Five titles, day-4/day-6 releases, day-1 calendar, same-prep orders, authored daily buyers/sellers and stable new/used eligibility | [B6 delivery](game-sim/docs/03-production/b6-delivery.md); integrated technical week, owner acceptance pending |
| Persistent state | Schema 10 in its separate development namespace; settlement, advance and expansion autosaves; explicit save/reload and retry | Terminal files preserved before restart; no backup rotation, prior-schema migration or power-loss guarantee |
| Visual production | Retained illustrated fixtures/rigs and editable product-art masters | Existing motion/reuse limitations remain; does not prove expanded-shop production quality |

Products: Curb Circuit 02, Tidebound Atlas, Orbit Orchard, Signal Harbor (day 4) and Pocket Rally Club (day 6). B6 implements final references, authored 3/4/5/6/7/8/8 buyer rosters, six appearances, same-prep supplier orders and final seller terms. Full-week technical completion remains distinct from B8 balance and owner fun acceptance.

## Requirements and remaining acceptance before beta

B1 specifies the systems in the [implementation packet](game-sim/docs/03-production/first-week-implementation-packet.md). B2–B6 implement the required retail systems and technical seven-day journey. The requirements below remain the acceptance contract; B7 experience/presentation, B8 balance evaluation and B9 personal Mac delivery are technically delivered; B10 owns the remaining owner-review gate.

- **First week — REQUIRED:** seven integrated days, visible shop development, a meaningful end-of-week result and an explicit bankruptcy outcome. Repeating the same small wave seven times is insufficient.
- **Shop development — REQUIRED:** grow and rearrange the shop over many days. B2 delivers editable fixture placement and four/eight-slot capacity; B3 adds north-bay expansion and seven-day financial progression. Keep growth within one shop. B2 delivers preparation-only rearrangement, valid walkable placement and the $60 second rack. B3 delivers the $100 north bay and included third rack from day-5 preparation.
- **Employees — REQUIRED:** hire staff and assign stocking and checkout duties. Integrate their work with physical inventory, customer queues and the player’s own actions without duplicate transactions. Wages are required business costs. Start with simple hiring and role assignments; deep scheduling, training and employee personalities are backlog candidates, not hidden prerequisites. B4 implements this bounded employee scope; see its delivery for evidence and limitations.
- **Used-game buying and resale — REQUIRED:** customers can sell games to the shop and the shop can resell acquired copies. Track purchase cost, inventory ownership and resale proceeds consistently with the existing ledger. Condition must affect acquisition and resale value. Permit negotiation only while acquiring stock from customer sellers, including refusal and insufficient cash. Purchasers accept or refuse the shelf price without haggling. Use cash purchases as a planning default; trade-in credit and repair/refurbishment are backlog candidates. B5 implements the transaction scope; B6 replaces its interim content with final references, authored terms and reference-based buyer budgets. Both deliveries retain their own evidence.
- **New game releases — REQUIRED:** introduce newly available fictional titles as days progress, with purchasing, stocking, pricing and reporting integrated into ordinary play. Design a readable release cadence and demand information. B6 implements both releases and same-prep purchase/receiving, with a day-1 calendar. No customer preorder system.
- **Retail breadth — IMPLEMENTED, OWNER JUDGMENT PENDING:** B6 supplies five titles, six appearances, authored daily buyers and sellers. B8 records profitable alternatives and recovery; B10 judges whether they are satisfying.
- **Economy — REQUIRED:** rent, actual employee wages, cash constraints and bankruptcy. B3 implements rent, constraints, settlement and bankruptcy; B4 adds actual employment and wages. Explain bills and their due dates before commitments, distinguish cash from operating profit and inventory value, and avoid charging twice after reload. Proposed timing: wages at day close and rent at the week-end bill; B1 now specifies exact initial amounts and insolvency rules with independently checked arithmetic. B3 separates merchandise margin, incurred/paid overhead, liabilities, stock purchases, investment and cash.
- **Ordinary player flow:** onboarding, readable interactions and reports, clear new/continue/save behavior, and recovery without developer explanation.
- **Presentation — REQUIRED:** retain the current illustrated style, improve walking/turning/stopping/reaching and staff/customer readability, and verify coherent added fixtures/products. A full style redesign is not requested; actual revised motion still needs review.
- **Runnable personal Mac app — DELIVERED:** B9 exports the active encounter with a separate personal save namespace; see the exact artifact and source in B9 delivery. Personal-beta acceptance remains B10.
- **Complete experience evidence:** exercise the agreed full beta journey, persistence across sessions, materially different decisions and owner usefulness/fun. Required content must exist before declaring this only a testing problem.

## Backlog and explicit exclusions

Proposed post-beta backlog: reputation systems, promotions, multi-item baskets, product substitution, special events beyond required new releases, large catalogs/casts, employee training/deep scheduling/personalities, trade-in credit, refurbishment, hidden narratives and wider platform/distribution support. These additions are not necessary to deliver the confirmed week unless implementation reveals a concrete dependency.

Excluded from this beta by owner direction: customer preorders, shopper-side price haggling, and additional shop locations. Keep live inventory reservations for ordinary shoppers; those existing transaction protections are not preorders. Retain the art style. Longer campaigns/endless continuation and a style overhaul are not part of this first-week plan.

## Known issues and uncertainties

| Issue | Consequence / disposition |
| --- | --- |
| Five titles, four/eight/twelve slots, 3–8 authored daily visitors | Implemented and technically exercised across seven days; balance, replay value and fun remain unaccepted |
| First-week systems technically integrated; beta gates remain | B2–B6 layout, finances, staff, used trading, releases and breadth are implemented. B7 experience/motion and B8 balance evaluation are technically delivered; B9 packaging is technically complete; B10 owner judgment remains |
| Economy/content evaluated; owner design judgment pending | B8 records viable growth, lean and recovery policies, weak survival-only pressure and optional investment/staff tradeoffs. B9 packaged growth/lean/failure reproduce $570.40, $795.20 and an $80 rent shortfall without rebalancing |
| Residual cutout turns, generic reaches, foot sliding, mirrored lighting and reused rigs | B7 adds distance-driven gait, bounded leg stretch and smoother settling; remaining limits and moving comparisons are in B7 delivery. Owner motion acceptance remains pending |
| No detailed cash handoff | Presentation limitation; decide importance through experience review |
| Separate personal save namespace; no migration | B9 qualifies ordinary packaged save/quit/relaunch, invalid-save preservation, write-failure retry and terminal restart. Hard power-loss is not newly qualified; owner/development namespaces remain untouched |
| Recorded capture-exit ObjectDB leak warning | Unresolved; determine ordinary-play relevance before beta qualification |
| Catalog/demand and scene logic are concentrated in current source | Assess changes needed for selected breadth; no generic rewrite or file-size refactor assumed |
| Active encounter Mac export and repeatable build delivered | B9 includes frozen source, template/tool hashes and local ad-hoc signed app. No public-distribution or CI infrastructure added |
| R5 owner verdict pending | Preserve as pending; do not convert planning discussion into gameplay acceptance |

## Full proposed route to beta

The required features and first-week endpoint are confirmed; initial quantities and economic rules are now specified in the B1 packet and remain subject to B8 balancing. B1–B9 are technically complete within their documented scope; B9 changes packaging, the blocked-buyer yield rule and a report label, preserving schema-10 business meaning. The sequence below governs the remaining work. Integrate each feature into the same shop/save/economy rather than creating disconnected demos. Relevant art, controls and saves are part of every stage.

| Stage | Work and dependencies | Exit condition | State |
| --- | --- | --- | --- |
| B0 — Agree the full experience | First week; one growing/rearrangeable shop; staff; rent/wages/bankruptcy; condition-based used trading; seller-side haggling; new releases; retained art style with better motion | Owner decisions recorded above; seven-day interpretation and proposed pacing explicit | SCOPE RECORDED |
| B1 — First-week implementation packet | Source/evidence reconciliation, concrete content/economy, layout, transactions, staff/trades, save policy and B2 work order | [Packet complete](game-sim/docs/03-production/first-week-implementation-packet.md); arithmetic and document links checked; R1–R4 acceptance preserved and R5 verdict pending | COMPLETE — documentation only |
| B2 — Shop layout | Buy/place/move required fixtures, derived capacity, shared traversable geometry and preserved stock/reservations | [B2 delivery](game-sim/docs/03-production/b2-delivery.md) maps technical evidence to every acceptance case; no owner acceptance inferred | TECHNICALLY COMPLETE — owner acceptance pending |
| B3 — Growth and business progression | Deliver one-shop expansion, costs, milestones, rent/wages and explicit insolvency/restart behavior; depends on layout and existing ledger | [B3 delivery](game-sim/docs/03-production/b3-delivery.md) records expansion, settlement, actual-rule survivor/failure and rendered interactions; real wages/full content remain later | TECHNICALLY COMPLETE — owner acceptance pending |
| B4 — Employees | Hiring, staffing cost model, assignment to stocking/checkout, pathing, work ownership and player handoff; uses B2/B3 | Staff do useful work, queues/inventory stay consistent, player remains able to act; staffing survives quit/resume | TECHNICALLY COMPLETE — owner acceptance pending |
| B5 — Used-game business | Customer sale intake, condition-based valuation and acquisition-only haggling, individual copies and fixed-price resale; shares cash and inventory | Buy a used copy, pay correctly, stock/reprice/resell it and report its actual cost/profit; refusal and insufficient cash handled | TECHNICALLY COMPLETE — owner acceptance pending |
| B6 — New releases and retail breadth | Release calendar/availability, supplier catalog, chosen customer/demand variety and sufficient content to exercise all prior systems | Ordinary days introduce new titles and meaningful stocking decisions; new and used inventory remain understandable; no preorders | TECHNICALLY COMPLETE — owner acceptance pending |
| B7 — Complete experience and presentation | Integrate onboarding, menus, reports, comfortable controls, selected visual/motion fixes, clear saves/continue/recovery | Fresh player can run and grow the shop across sessions without developer instructions; all promised content exists | TECHNICALLY COMPLETE; [B7 delivery](game-sim/docs/03-production/b7-delivery.md); owner acceptance pending |
| B8 — Balance the sustained game | Evaluate workload, demand, prices, staffing, bills and reachable growth; tune only with evidence | [B8 delivery](game-sim/docs/03-production/b8-delivery.md): profitable alternatives, recovery, bankruptcy, low-effort comparison and normal-speed evidence; no numerical tuning | TECHNICALLY COMPLETE — owner judgment pending |
| B9 — Package and qualify | Active Mac encounter export/build, one identified candidate, regression, visual, persistence and complete-run checks | [B9 delivery](game-sim/docs/03-production/b9-delivery.md): identified local app, isolated saves, repaired navigation, ordinary CoreAudio/exits, packaged survival/failure and retained limits | TECHNICALLY COMPLETE — B10 owner judgment pending |
| B10 — Owner beta review and repairs | Play the complete promised experience; assess fun, agency, progression, clarity and presentation; repair actual findings | Explicit owner beta-readiness decision for the resulting candidate; affected paths revisited after changes | NOT READY |

### Execution rules and slice handoffs — September 22

The B0–B10 table is the sequence; the contracts below make each stage actionable. B1 is complete as documentation; its packet is the implementation specification. B2 was separately authorized and is technically complete. B3 was subsequently authorized and is technically complete. B4–B9 were subsequently authorized and completed within their recorded technical boundaries; B10 remains a separate owner review. Each implementation slice must deliver its ordinary player interaction, persistent state, useful feedback and relevant verification together. Do not defer all UI/save work to B7 or replace the existing game with separate feature demos.

At the start of each slice, inspect the current checkout and this tracker; preserve unrelated work, editable art, saves and retained evidence. At completion, record source identity (including uncommitted changes), changed behavior, evidence paths, remaining issues and the next slice here. A source revision requires applicable new evidence. Do not mark owner acceptance from engineering results. Routine technical work need not wait for another broad owner interview; isolate a specific unresolved experience question if it actually affects the slice.

### B1 — First-week implementation packet

**Completed September 22:** [eight-section packet and B2 work order](game-sim/docs/03-production/first-week-implementation-packet.md). The contract below retains B1 completion criteria; B2 was subsequently implemented under separate authorization.

**Outcome:** one source-grounded specification that makes B2 directly implementable and gives B3–B9 concrete parameters and dependencies. This is a bounded design/engineering assessment, not another scope interview or a claim that the beta is implemented.

**Read:** this tracker; `game-sim/docs/MASTER_PLAN.md`; `docs/02-technical/encounter-architecture.md`; `docs/02-technical/local-development.md`; `docs/04-validation/local-validation-plan.md`; `docs/03-production/r5-delivery.md`; the UI design/verification notes; and the actual `encounter/state.gd`, `main.gd`, `actor.gd`, project settings and selected validator suites. Repository-relative paths in this list are under `game-sim/`. Inspect further files only as needed to resolve a concrete dependency.

**Deliverable:** create `game-sim/docs/03-production/first-week-implementation-packet.md`, with these sections:

1. **Current source inventory.** Record branch, full commit and working-tree state. Map every beta requirement to existing code, missing behavior and the responsible slice. The September 22 inspection found global `CAPACITY = 4`, fixed scene obstacles/browse/queue positions, per-copy inventory and an existing transaction/save validator. Inspect these seams before proposing changes; a shelf label saying “USED” is not evidence of implemented condition or seller negotiation.
2. **Concrete first-week content and economy.** Choose and label initial design values: starting funds/stock, catalog and release day(s), daily visitor mix, seller arrivals, condition grades, fixture costs/capacities, expansion price, staff count/roles/wages, rent/due dates and exact insolvency timing. Describe each day's available decisions. Reconcile a worked surviving-week budget and a separate deliberate-failure example, including inventory acquisition, fixture/expansion spending and overhead. These are feasibility examples, not observed play, balance acceptance or owner-approved numeric requirements.
3. **Layout and growth contract.** Specify fixture identities, footprints, legal placement area, capacity/slot ownership, interaction points, movement controls, confirmation/cancel, occupied-fixture moves and when editing is allowed. Define route checks from player/customer entry to required stations and back to exit; reserve worker access requirements for B4. B2 owns fixture purchase/movement; B3 owns enlarging the same shop. Choose a simple usable placement interaction, not a general construction editor.
4. **State and transaction contract.** Define required schema changes for fixtures, copies/condition/cost, expense events, staff/jobs, releases and terminal week outcomes. Preserve integer-cent money and exactly-once cash/inventory changes. Explain cash versus gross margin versus operating result, and how fixture/expansion outlays appear without inventing depreciation machinery. Specify event identities and phase rules for day close, wages, rent, failure and reload.
5. **Staff and used-trade rules.** Specify hiring, assignment/unassignment, wage commitments and the player/worker ownership rule for each stock or checkout job. Define seller inspection, offers/counteroffers/refusal, accepted-price capture, payment and copy creation as one transaction; resale remains fixed-price. Set bounded negotiation rules and explain insufficient cash, full stock destinations, canceled actions and day closure.
6. **Save and recovery policy.** Choose versioning, supported save moments and recovery behavior. Preserve R5 owner saves; use a separate beta/development namespace. Explicitly choose migration of copied saves or clear incompatibility handling, never silent reset/overwrite. Specify how layout, pending work, reservations, bills and completed days restore. Do not make old-schema migration or elaborate backup infrastructure an automatic personal-beta requirement.
7. **Implementation and evidence map.** Name the files/seams likely to change for each slice and specify focused state/scene checks plus visible interaction proof where appropriate. Include integration checks for day transitions, player/worker contention, used/new stock, releases, cash reconciliation and quit/resume. Use the existing isolated validation route, evolving its assertions for intended behavior; preserve historical evidence rather than requiring obsolete four-slot constants forever.
8. **B2 handoff and remaining risks.** Give the exact B2 work order, chosen data/control contracts, necessary art changes, acceptance cases and exclusions. Identify how later slices consume its fixture and routing interfaces. Record the pending R5 verdict and known motion/exit-warning issues separately from technical blockers. No extra owner answer is needed for already-settled scope.

**B1 done:** every required feature maps to a slice; initial numeric/content choices and arithmetic are explicit; B2 has no unresolved schema, interaction or capacity decision; later dependencies are named; all estimates/proposals are labeled; tracker and master-plan pointers agree. A list of unanswered design questions alone is not a completed packet. If source inspection reveals a consequential choice outside confirmed scope, isolate it while completing independent work.

**B1 boundary:** documentation and read-only source/evidence inspection only. No game launch, owner-save access, runtime modification, new art generation, qualification campaign, commit, push or publication. Arithmetic checks and documentation/link checks are appropriate; application tests are not necessary for this slice. Stop after delivering the packet and B2 handoff.

### B2–B6 — Integrated feature contracts

| Slice and dependency | Concrete deliverable | Required completion evidence |
| --- | --- | --- |
| **B2 — Layout/capacity; after B1** | Preparation-only buy/place/move flow with preview, confirm/cancel and useful invalid-placement feedback; stable fixture IDs/slots; capacity derived from fixtures; scene art, collision, interaction points and routes derived from the same layout. Moving stocked fixtures preserves copy identity, cost and price. No selling/removing fixtures required unless B1 identifies a necessity. | Valid stocked move and reload; overlap/out-of-bounds/blocked essential-route rejection; canceled or unaffordable purchase changes no cash/layout; confirmed purchase charges once; stock respects derived capacity; receive/price/open/browse/queue/serve/close still work with altered layout. Test customer routes now; actual employee behavior is B4. |
| **B3 — Growth/economy; after B2** | One purchasable same-shop space/capacity upgrade; dated visible bill schedule; shared expense ledger and B1 wage rules ready for B4; day-close/week-end settlement; explicit insolvency and seven-day terminal result/restart. Staff wages must use actual employment once B4 lands; do not fabricate employees to claim the feature complete. | Upgrade price charged once and layout retained; cash equals opening cash plus receipts minus actual cash outflows; bills cannot repeat after reload; unaffordable discretionary purchase preserves state; due-bill failure is explained; day 7 ends clearly without silently opening day 8. Recheck wages and full-week results after B4–B6. |
| **B4 — Employees; after B2/B3** | Simple hiring and stocking/checkout assignment, visible worker movement/work, job ownership, player handoff, wage disclosure/settlement and saved employment. Define pause/unassign handling without adding deep scheduling. | Both duties demonstrated in ordinary play; player and worker cannot move/sell the same copy or serve the same order twice; canceled/interrupted jobs release ownership; blocked or unavailable work reports honestly; close drains or cancels jobs consistently; save/reload preserves wages and restores/reconciles work. |
| **B5 — Used trading; after B3, integrate with B4** | Seller arrival/intake and inspection; condition-sensitive valuation; bounded acquisition-side negotiation; refusal/cancel; atomic accepted-price payment and individually tracked used-copy acquisition; stocking/pricing/fixed-price resale and cost/profit reporting. | At least two meaningful condition grades affect acquisition/resale value; accepted purchase charges and creates stock once; refusal/cancel/insufficient funds creates neither charge nor copy; used/new copies coexist without cost confusion; reload cannot repeat acquisition; staff/player sale reports original acquisition cost correctly. |
| **B6 — Releases/content; after B3–B5** | Implement B1 catalog, release schedule, visitor/seller variety and day progression; release information visible before useful purchase decisions; availability enforced at supplier as well as UI; preserve existing owned copies. | At least one new title unavailable before release becomes buyable on the correct day; no advance charge/preorder; purchasing/receiving/pricing/staffing/resale/reporting work with expanded catalog; distinct week-day choices exist; release and visitor state survive reload without duplicate events. |

### B7–B10 — Complete experience, delivery and review

| Slice and dependency | Concrete deliverable | Required completion evidence |
| --- | --- | --- |
| **B7 — Experience/presentation; incremental from B2, complete after B6** | Finish onboarding, new/continue/save/restart, bill and trade explanations, readable queues/worker roles, daily/week reports and chosen walk/turn/stop/reach improvements. Retain illustrated art and shared UI guidance. Integrate new art throughout B2–B6, preserving editable masters. | All required controls/content accessible through ordinary play; interrupted sessions resume coherently; changed motion inspected in movement, not only screenshots; UI remains legible at supported window sizes; failures have useful next actions. No developer commands needed for the week. |
| **B8 — Balance; after B2–B7 integration** | Tune existing parameters using complete seven-day runs, including materially different stocking/pricing/staffing choices, a recoverable setback and separate bankruptcy path. | An ordinary viable route can afford meaningful growth and access every required system; at least two different viable decision patterns; cash/inventory/expenses reconcile at each close; no later content concealed by early failure. Automated arithmetic/simulation evidence remains distinct from observed play and owner fun. |
| **B9 — Mac delivery; packaging feasibility assessed in B1, finish after B8** | Active `encounter/` export configuration and launchable personal Mac artifact; exact source/build identity; applicable regression/render/persistence and packaged complete-journey checks. Resolve whether the historical exit warning affects ordinary play. | Launch from delivered artifact, quit/resume across day boundaries and finish the week; packaged assets and writable save location work; existing owner saves remain preserved; explicit known limits. Do not reuse historical `game/` export scripts as encounter proof or add public-distribution infrastructure by default. |
| **B10 — Owner beta review; after B9** | Owner plays the complete week and judges clarity, agency, progression, motion and fun; record neutral feedback and repair real blockers within scope. | Explicit resulting-build beta decision. Changed builds receive affected checks/review; technical pass cannot fill R5 or beta verdict fields. Publication remains separate. |

These contracts are required behavior, not arbitrary test-count targets. B1 may refine implementation order for concrete dependencies, recording why; it must preserve every confirmed requirement. B8/B9 integrate and verify delivered functionality rather than discovering missing required systems for the first time.

### What beta-ready must mean

- Growing and rearranging the shop, employees, used buying/resale and new releases are all playable together in the ordinary game.
- All seven days and their meaningful first-week result are playable without debug controls; a viable path includes opportunities to use every required system.
- Condition affects used-game value; haggling is acquisition-only. Rent/wages affect finances and a separate deliberate failure check proves clear bankruptcy behavior. No preorders.
- Inventory, cash, expenses and staffing remain understandable and consistent across multiple days and save/resume.
- The visual standard and ordinary controls support the complete shop experience.
- A usable Mac build and focused evidence support the actual candidate; outstanding nonblocking limits are explicit.
- The owner has judged the complete experience ready for personal beta. Technical checks and short slice approvals cannot supply that verdict.

Public release/distribution remains separate. No commercial infrastructure, arbitrary test-count target or generic rewrite is a beta requirement by default.

## Current build and retained evidence

- B3 September 22: same HEAD plus resulting uncommitted changes, with incoming B1/B2 sources preserved. [B3 delivery](game-sim/docs/03-production/b3-delivery.md) identifies the source, schema 7 namespace, ruleset, isolated normal/Retina verification and B4 handoff. Ordinary B3 survivor: $325; separate rent failure: $40 cash, $150 unpaid, $110 shortfall. Neither uses employees or claims B1’s future $570.40/$80 examples. No commit, push, publication, owner-save access or artwork overwrite.

- B2 September 22: `main` at `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9` plus uncommitted runtime, UI, tests and documentation. Incoming B1 documents were preserved before extension. [B2 delivery](game-sim/docs/03-production/b2-delivery.md) records the source manifest, isolated checks, rendered input/movement evidence, queue-geometry correction and remaining limits. Schema 6 uses `game-sim-first-week-dev-v6`; no owner saves, historical evidence or artwork masters were altered. No commit, push or publication.

- B1 completion September 22: inspected `main` at `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9`, initially clean. That B1 delivery left uncommitted planning documents only; B2 subsequently extended them. All September 21 validation-context encounter hashes still match; the older 119-entry R5 manifest differs in `main.gd`, `README.md` and `scripts/validate.py`. Retained exits/results were read, not rerun. Integer-cent budgets and links were checked; no gameplay, owner saves, runtime/art edits, commit or push. See [packet source inventory](game-sim/docs/03-production/first-week-implementation-packet.md#1-current-source-inventory).

- September 22 read-only inspection: `main`, clean, HEAD `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9`. This includes the later shared UI changes; earlier source-match statements below are historical. No fresh application validation or owner session was run for this planning update. See the September 21 [UI verification](game-sim/docs/ui-verification.md) for its separate retained evidence.

- Historical read-only checkout inspection September 21: `main`, clean, HEAD `ac4dfcb27cbed6c7c4ea2cb3d83421b426516fdf`. This supersedes the old tracker checkout identity; no new runtime qualification is claimed.
- R5 retained qualification: [delivery](game-sim/docs/03-production/r5-delivery.md), [September 9 evidence](game-sim/encounter/evidence/validation-20260909T020530374063Z/), [September 16 headless/tooling maintenance](game-sim/docs/MASTER_PLAN.md).
- Before the later shared UI changes, September 21 review confirmed only `encounter/README.md` and `encounter/scripts/validate.py` differ among the 119 R5 manifest encounter entries. Gameplay/art remain consistent with retained R5 evidence; rendered/capture modes were not rerun for the later wrapper changes.
- [Current architecture and actual limitations](game-sim/docs/02-technical/encounter-architecture.md); [player instructions](game-sim/encounter/README.md).
- [Launch current first-week development build](game-sim/encounter/Launch%20Encounter.command). No running window or fresh owner session is claimed by this planning update.
- [Previous tracker snapshot](game-sim/docs/03-production/tracker-history/game-sim-next-steps-20260921-before-beta-plan.md) preserves earlier details; it is historical, not the active next action.

## Immediate next action

B9 is technically complete; **stop before B10 or an owner session**. The next actor is the owner beginning a separate whole-week review of [Replay Junction Personal Beta.app](game-sim/artifacts/b9-personal-mac/Replay%20Junction%20Personal%20Beta.app), following the [owner guide](game-sim/encounter/MAC-OWNER-GUIDE.md) and [B9 evidence/handoff](game-sim/docs/03-production/b9-delivery.md).

Delivered ZIP SHA-256: `e257220d7c7c4c0081551375b10b6288b35d4bd6823c59eb2d9ab886c254c391`. Exact uncommitted source is archived with the app; HEAD alone does not identify it. Personal namespace `game-sim-personal-beta-v10` is empty after archiving all B9 synthetic saves. Schema 10 / `b6-retail-1`, copy costs/identities, saved budgets/offers/wages and all previous namespaces/artwork/evidence are preserved.

B9 reproduced the B8 walking deadlock at 1× in a labeled packaged fixture, repaired the blocked-buyer yield rule and requalified the changed runtime. Final packaged weeks use no helper detours. The daily label now says Sold-copy cost without changing math. Ordinary delivered-app CoreAudio startup and menu/native-close/relaunch are qualified; source-harness ObjectDB warnings remain disclosed but did not reproduce in ordinary package exits. The locally launchable app is ad-hoc signed, not notarized or distribution-approved.

B10 must judge weak survival-only pressure, optional expansion/staff returns, manual workload, residual animation, comprehension and fun across the complete week. Prior R5/B2–B7 owner judgments remain pending; no B9 result supplies beta acceptance. No B10 session has started.

### Historical B4 delivery — September 22

[B4 Employees delivery](game-sim/docs/03-production/b4-delivery.md) identifies the B4 candidate, including uncommitted B1–B3 input, and retained state/scene/movement evidence. The [B4 source manifest](game-sim/encounter/evidence/b4-20260922/source-manifest.json) records exact uncommitted bytes; [final validation](game-sim/encounter/evidence/validation-20260922T211118646937Z/) records isolated engine and rendered results. Schema 8 / `b4-employees-1` uses `game-sim-first-week-dev-v8`; prior namespaces and evidence remain intact. Morgan/Jules are available from day-3 preparation. Hiring commits $12 immediately for that day; returning staff commit on Open. Dismissal before a later opening avoids that new day's wage. Roles and inactivity do not refund commitments.

State-owned copy/slot and FIFO/cashier claims arbitrate player and workers. Stocking physically visits receiving and the destination; checkout physically visits the cashier. Employees shows assignments and explicit Take over. Layout editing pauses workers/releases unfinished claims, closing releases stock and drains checkout, and reload cancels unfinished saved work while preserving inventory, reservations, employment, wages and completed events. The existing B3 economy settles actual wages and retains unpaid wages/rent on insolvency.

Engineering evidence uses isolated saves and Dummy audio. Scripted controls, movement traces and normal/Retina rendering do not supply owner acceptance or audio qualification. R5/B2/B3/B4 owner judgments remain pending; animation quality, balance, packaging and full-content beta acceptance remain later work. No commit, push, publication or owner-save access. **Historical B4 boundary: stop before B5; B5 was subsequently authorized separately.**

**Historical B5 handoff:** implement individual used-copy acquisition, condition-sensitive cost/value and bounded seller-side negotiation from packet sections 4–6. Feed those copies through the same claim, stock, sale, wage and reporting paths; preserve schema-8 saves and use B5's separate schema namespace. Keep releases, broader customers and supplier timing in B6. The subsequent B5 work order supplies its separate authorization.

### B5 delivery — September 22

[B5 Used-game Business delivery](game-sim/docs/03-production/b5-delivery.md) identifies HEAD plus the complete uncommitted candidate, input preservation, isolated evidence and B6 handoff. Schema 9 / `b5-used-1` uses `game-sim-first-week-dev-v9`. Sellers arrive from day 2 at separate intake; inspect, offer, counter once, confirm the exact accepted amount or refuse/cancel. New copies and individually labeled good/fair/worn used copies retain separate identity, cost and provenance. Acquisitions unlock next preparation, then use existing player/employee work claims and fixed-price checkout.

Observed isolated arithmetic: base day-2 good Curb purchase $12.31, day-3 resale $17.59, cost of sales $12.31, merchandise margin $5.28; two wages $24, closing cash $531.28. Expanded day-5 fair Curb purchase $6.59, day-6 chosen label/resale $10, cost of sales $6.59, margin $3.41; $100 expansion and two wages $24 give closing cash $429.41. The same fair copy at its $13.19 reference can legitimately be declined by a $10.55-budget buyer. These are bounded mechanic runs after synthetic empty-day preludes, not B1’s future balanced week or owner acceptance.

Final source/evidence identity is in the delivery’s manifest and reconciliation. Earlier B1–B4 evidence and artwork are retained. Dummy audio does not qualify sound. No owner-save access, commit, push or publication. **Historical B5 boundary: stop before B6; B6 was subsequently authorized separately.**


### B6 delivery — September 22

[B6 New Releases and Retail Breadth](game-sim/docs/03-production/b6-delivery.md) identifies the complete uncommitted source, incoming B1–B5 archive, isolated technical checks and B7 handoff. Schema 10 / `b6-retail-1` uses `game-sim-first-week-dev-v10`. Signal Harbor releases day 4 and Pocket Rally Club day 6; the calendar is visible day 1. One mixed supplier order is paid and received during preparation. No early payment, preorders, report/open ordering or overnight supplier flow remains.

B6 replaces B5’s rotating roster, condition-scaled budgets and generic interim seller terms. Authored daily buyers retain unique identities, reference-based budgets, first-occurrence new-only eligibility and repeat used acceptance. All paid copies keep actual historical cost and stable event-based acquisition ordering. Two editable cover masters/exports and three accessory/outfit appearances extend the preserved illustrated assets.

The B1 worked survivor and deliberate bankruptcy routes are attempted with actual outcomes in the delivery. The integrated seven-day run exercises ordinary controls, staffing, used trade, releases, expansion, wages/rent, terminal result and save/resume. Separate stress/regression probes and their setup boundaries are retained. This is technical completion, not B8 balance or owner fun acceptance. Dummy audio does not qualify sound. No owner-save access, commit, push or publication. **Historical B6 boundary: B7 was subsequently authorized separately.**

## B7 delivery — September 22 local / September 23 UTC

[B7 delivery](game-sim/docs/03-production/b7-delivery.md) binds the exact uncommitted source, preserved input, current B6 regression matrix, revised seven-day flow, isolated recovery tests and before/after moving evidence. New/Continue/help/Quit, contextual guidance, guarded reload, save failure/retry, terminal-preserving restart, clearer finances and actor-label/header placement are implemented. Walking uses actual traveled distance, bounded leg stretch and smoother settling while retaining the illustrated rigs and all physical transaction rules. Schema 10 and B6 rules remain unchanged.

Technical checks do not establish owner comprehension, fun or motion acceptance. Residual cutout turning, mirrored lighting, generic reaches and some foot sliding remain documented; scripted exits can emit an ObjectDB warning. B9 still owns packaged ordinary-exit/audio qualification. No owner-save access, commit, push, publication or B8 work. **Historical B7 stop: B8 was subsequently authorized and evaluated separately.**

## B8 delivery — September 22 local / September 23 UTC

[B8 delivery](game-sim/docs/03-production/b8-delivery.md) retains eight screened policies, complete control-driven seven-day growth/lean/recovery/one-worker/failure runs, daily cash/cost/inventory/expense/investment arithmetic, action and queue observations, selected 1× clips and the current normal/Retina/movement/recovery regression matrix. No runtime parameters or saved rules changed; earlier $570.40/$80 evidence remains historical and is independently reproduced.

Profitable finishes: delegated growth $570.40 cash / $130.40 operating result; lean manual $795.20 / $255.20; pricing recovery $760.80 / $220.80. Bankruptcy retains $70 cash, $150 unpaid rent and an $80 shortfall after correct wages. No selling survives on starting capital while losing $150; one worker yields the same tested growth sales for $24 less than two. The second rack is useful; this route leaves north-bay capacity unused. These are explicit tradeoffs, not a claim that survival-only motivation or workload is fun.

A normal-speed return walk stalled at a busy rack. The failed attempt is retained; a fresh complete week uses logged ordinary S-key steps and reclicks to clear the aisle. No game navigation fix or automatic-path recovery is claimed. Cutout turns, mirrored lighting, generic reaches/foot sliding, some label crowding and daily “Inventory cost” terminology remain presentation/comprehension limits. No owner-save access, commit, push or publication. **Historical B8 boundary: stop before B9. B9 was subsequently authorized and completed separately. Not beta ready.**

## B9 delivery — September 23 UTC

[B9 delivery](game-sim/docs/03-production/b9-delivery.md) identifies the active encounter’s universal personal Mac app, frozen uncommitted source and matching Godot/templates. The actual delivered app passes ordinary launch/New/Continue, day-boundary quit/resume, native close, malformed-save preservation, controlled write-failure retry and terminal-preserving restart. It initializes real CoreAudio; existing content intentionally remains silent. Separate instrumented release packages bind byte-identical compiled runtime/art to the final artifact and complete growth, manual lean and bankruptcy without automatic helper detours. Their setup and acceleration remain labeled. All current source regression processes pass; the two scripted exit warnings remain disclosed.

The busy-rack stall is retained before repair and passes the same normal-speed packaged fixture afterward. B9 does not rebalance the B6 economics. Growth finishes $570.40, lean $795.20; bankruptcy retains $70 cash, $150 rent due and an $80 shortfall. All 103 original artwork/master files and business sources are preserved. No owner-save access, migration, commit, push or publication. **B9 technically complete; stop before B10 owner review. Not beta accepted.**
