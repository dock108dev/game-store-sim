# Game Store Sim — Path to Personal Beta

Updated: 2026-09-22. Status: **PLAYABLE PROTOTYPE; B1 IMPLEMENTATION PACKET COMPLETE; B2 HANDOFF READY; NOT BETA READY.**

This is the entry point for the complete path to beta, replacing a tracker that ended at the next small owner review. Planning is authorized; this document does not start implementation or supply owner acceptance. The current R5 build remains available for focused feedback. A beta must deliver the agreed sustained shop experience, not merely pass the encounter checks.

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
| Repeatable days | Close, finalize reports, pay for replenishment, advance and receive next day | R2 accepted within scope |
| Pricing consequences | Per-product prices, fixed customer budgets, locked offers, price refusal | R3 accepted within scope; small authored demand model |
| Several customers | Three visitors, browsing, reservations, FIFO service and closing/draining | R4 accepted: “yes”; not a scaled customer simulation |
| Assortment choices | Three fictional games, four shelf spaces, backroom stock, returns, mixed orders and per-product reports | R5 engineering verified; owner acceptance PENDING |
| Persistent state | Explicit save/reload of inventory, cash, orders, customers and shift phases | Prototype checkpoint workflow; no autosave, backup rotation or prior-schema migration |
| Visual production | Retained illustrated fixtures/rigs and editable product-art masters | Existing motion/reuse limitations remain; does not prove expanded-shop production quality |

Products: Curb Circuit 02, Tidebound Atlas and Orbit Orchard. Current evidence demonstrates price and stock misses, retained inventory, exactly-once transactions and meaningful differences between two small assortments. It does not establish a satisfying long-term business game.

## To implement or establish before beta

These are the required gaps between the current prototype and the confirmed first-week beta. B1 now specifies these systems in the [implementation packet](game-sim/docs/03-production/first-week-implementation-packet.md); runtime implementation has not started.

- **First week — REQUIRED:** seven integrated days, visible shop development, a meaningful end-of-week result and an explicit bankruptcy outcome. Repeating the same small wave seven times is insufficient.
- **Shop development — REQUIRED:** grow and rearrange the shop over many days. Deliver editable fixture placement, capacity/growth progression and meaningful spatial consequences. Keep growth within one shop. Default to rearrangement during preparation, valid walkable placement and a purchasable capacity/space upgrade; use the exact layout controls and upgrade costs now specified in the implementation packet.
- **Employees — REQUIRED:** hire staff and assign stocking and checkout duties. Integrate their work with physical inventory, customer queues and the player’s own actions without duplicate transactions. Wages are required business costs. Start with simple hiring and role assignments; deep scheduling, training and employee personalities are backlog candidates, not hidden prerequisites. No employee implementation is claimed.
- **Used-game buying and resale — REQUIRED:** customers can sell games to the shop and the shop can resell acquired copies. Track purchase cost, inventory ownership and resale proceeds consistently with the existing ledger. Condition must affect acquisition and resale value. Permit negotiation only while acquiring stock from customer sellers, including refusal and insufficient cash. Purchasers accept or refuse the shelf price without haggling. Use cash purchases as a planning default; trade-in credit and repair/refurbishment are backlog candidates. No implementation is claimed.
- **New game releases — REQUIRED:** introduce newly available fictional titles as days progress, with purchasing, stocking, pricing and reporting integrated into ordinary play. Design a readable release cadence and demand information. No customer preorder system.
- **Retail breadth:** choose the smallest catalog, visitor variety and demand behavior that support different viable stocking/pricing decisions over the agreed experience.
- **Economy — REQUIRED:** rent, wages, cash constraints and bankruptcy. Explain bills and their due dates before commitments, distinguish cash from operating profit and inventory value, and avoid charging twice after reload. Proposed timing: wages at day close and rent at the week-end bill; B1 now specifies exact initial amounts and insolvency rules with independently checked arithmetic. Current gross profit excludes overhead.
- **Ordinary player flow:** onboarding, readable interactions and reports, clear new/continue/save behavior, and recovery without developer explanation.
- **Presentation — REQUIRED:** retain the current illustrated style, improve walking/turning/stopping/reaching and staff/customer readability, and verify coherent added fixtures/products. A full style redesign is not requested; actual revised motion still needs review.
- **Runnable Mac beta:** establish an active encounter build/export and usable launch path. Historical first-person export tooling does not package this project.
- **Complete experience evidence:** exercise the agreed full beta journey, persistence across sessions, materially different decisions and owner usefulness/fun. Required content must exist before declaring this only a testing problem.

## Backlog and explicit exclusions

Proposed post-beta backlog: reputation systems, promotions, multi-item baskets, product substitution, special events beyond required new releases, large catalogs/casts, employee training/deep scheduling/personalities, trade-in credit, refurbishment, hidden narratives and wider platform/distribution support. These additions are not necessary to deliver the confirmed week unless implementation reveals a concrete dependency.

Excluded from this beta by owner direction: customer preorders, shopper-side price haggling, and additional shop locations. Keep live inventory reservations for ordinary shoppers; those existing transaction protections are not preorders. Retain the art style. Longer campaigns/endless continuation and a style overhaul are not part of this first-week plan.

## Known issues and uncertainties

| Issue | Consequence / disposition |
| --- | --- |
| Three products, four shelf spaces, three authored visitors | Suitable for a mechanic review; insufficient evidence of sustained variety or progression |
| Required systems are mostly absent | First-week scope is now defined, but layout/growth, employees, rent/wages/bankruptcy, used condition/negotiation and releases still require implementation |
| Initial economy/content specified, balance unproven | B1 proposes five titles/two releases, two staff, three conditions, fixture/expansion costs and bill rules. Arithmetic supports a $570.40 surviving finish and a separate $80 rent shortfall; B8 still owes observed viable alternatives and recovery |
| Rigid/deforming legs, abrupt turns/stops, straight reach, sliding risk, mirrored lighting, enlargement artifacts, reused rigs | Retain style and improve motion; direction approval does not accept these defects |
| No detailed cash handoff | Presentation limitation; decide importance through experience review |
| Explicit checkpoint-only saving; no old-schema migration | Needs a deliberate beta save/resume and compatibility policy |
| Recorded capture-exit ObjectDB leak warning | Unresolved; determine ordinary-play relevance before beta qualification |
| Catalog/demand and scene logic are concentrated in current source | Assess changes needed for selected breadth; no generic rewrite or file-size refactor assumed |
| No active encounter export preset or CI workflow recorded | Packaging path missing; select checks appropriate to a personal Mac beta rather than inheriting historical tooling |
| R5 owner verdict pending | Preserve as pending; do not convert planning discussion into gameplay acceptance |

## Full proposed route to beta

The required features and first-week endpoint are confirmed; initial quantities and economic rules are now specified in the B1 packet and remain subject to B8 balancing. This sequence is the proposed execution order, not implementation already in progress. Integrate each feature into the same shop/save/economy rather than creating disconnected demos. Relevant art, controls and saves are part of every stage.

| Stage | Work and dependencies | Exit condition | State |
| --- | --- | --- | --- |
| B0 — Agree the full experience | First week; one growing/rearrangeable shop; staff; rent/wages/bankruptcy; condition-based used trading; seller-side haggling; new releases; retained art style with better motion | Owner decisions recorded above; seven-day interpretation and proposed pacing explicit | SCOPE RECORDED |
| B1 — First-week implementation packet | Source/evidence reconciliation, concrete content/economy, layout, transactions, staff/trades, save policy and B2 work order | [Packet complete](game-sim/docs/03-production/first-week-implementation-packet.md); arithmetic and document links checked; R1–R4 acceptance preserved and R5 verdict pending | COMPLETE — documentation only |
| B2 — Shop layout | Buy/place/move required fixtures, model capacity and traversable routes, integrate stocking/customer/employee destinations | Layout visibly changes space/capacity; blocked placements rejected clearly; stocked inventory survives moves and reload | TO IMPLEMENT |
| B3 — Growth and business progression | Deliver one-shop expansion, costs, milestones, rent/wages and explicit insolvency/restart behavior; depends on layout and existing ledger | Earn, reinvest and reach a meaningful shop upgrade through ordinary multi-day play; costs and cash reconcile | TO IMPLEMENT |
| B4 — Employees | Hiring, staffing cost model, assignment to stocking/checkout, pathing, work ownership and player handoff; uses B2/B3 | Staff do useful work, queues/inventory stay consistent, player remains able to act; staffing survives quit/resume | TO IMPLEMENT |
| B5 — Used-game business | Customer sale intake, condition-based valuation and acquisition-only haggling, individual copies and fixed-price resale; shares cash and inventory | Buy a used copy, pay correctly, stock/reprice/resell it and report its actual cost/profit; refusal and insufficient cash handled | TO IMPLEMENT |
| B6 — New releases and retail breadth | Release calendar/availability, supplier catalog, chosen customer/demand variety and sufficient content to exercise all prior systems | Ordinary days introduce new titles and meaningful stocking decisions; new and used inventory remain understandable; no preorders | TO IMPLEMENT |
| B7 — Complete experience and presentation | Integrate onboarding, menus, reports, comfortable controls, selected visual/motion fixes, clear saves/continue/recovery | Fresh player can run and grow the shop across sessions without developer instructions; all promised content exists | PENDING; work alongside B2–B6 |
| B8 — Balance the sustained game | Tune workload, demand, prices, staffing, bills and reachable growth across all seven days | Different viable decisions and recoverable setbacks demonstrated; repetition and obvious dominant strategies assessed | PENDING |
| B9 — Package and qualify | Active Mac encounter export/build, one identified candidate, applicable regression, visual, persistence and complete-run checks | Launch/quit/resume and complete agreed progression work; no blocking defects; honest known-issue record | PENDING |
| B10 — Owner beta review and repairs | Play the complete promised experience; assess fun, agency, progression, clarity and presentation; repair actual findings | Explicit owner beta-readiness decision for the resulting candidate; affected paths revisited after changes | NOT READY |

### Execution rules and slice handoffs — September 22

The B0–B10 table is the sequence; the contracts below make each stage actionable. B1 is complete as documentation; its packet is the implementation specification. B2–B9 are future engineering slices, not started or authorized by this documentation update. Each implementation slice must deliver its ordinary player interaction, persistent state, useful feedback and relevant verification together. Do not defer all UI/save work to B7 or replace the existing game with separate feature demos.

At the start of each slice, inspect the current checkout and this tracker; preserve unrelated work, editable art, saves and retained evidence. At completion, record source identity (including uncommitted changes), changed behavior, evidence paths, remaining issues and the next slice here. A source revision requires applicable new evidence. Do not mark owner acceptance from engineering results. Routine technical work need not wait for another broad owner interview; isolate a specific unresolved experience question if it actually affects the slice.

### B1 — First-week implementation packet

**Completed September 22:** [eight-section packet and B2 work order](game-sim/docs/03-production/first-week-implementation-packet.md). The contract below is retained as its completion criteria. B2 has not started.

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

- B1 completion September 22: inspected `main` at `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9`, initially clean. This delivery leaves uncommitted planning documents only. All September 21 validation-context encounter hashes still match; the older 119-entry R5 manifest differs in `main.gd`, `README.md` and `scripts/validate.py`. Retained exits/results were read, not rerun. Integer-cent budgets and links were checked; no gameplay, owner saves, runtime/art edits, commit or push. See [packet source inventory](game-sim/docs/03-production/first-week-implementation-packet.md#1-current-source-inventory).

- September 22 read-only inspection: `main`, clean, HEAD `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9`. This includes the later shared UI changes; earlier source-match statements below are historical. No fresh application validation or owner session was run for this planning update. See the September 21 [UI verification](game-sim/docs/ui-verification.md) for its separate retained evidence.

- Historical read-only checkout inspection September 21: `main`, clean, HEAD `ac4dfcb27cbed6c7c4ea2cb3d83421b426516fdf`. This supersedes the old tracker checkout identity; no new runtime qualification is claimed.
- R5 retained qualification: [delivery](game-sim/docs/03-production/r5-delivery.md), [September 9 evidence](game-sim/encounter/evidence/validation-20260909T020530374063Z/), [September 16 headless/tooling maintenance](game-sim/docs/MASTER_PLAN.md).
- Before the later shared UI changes, September 21 review confirmed only `encounter/README.md` and `encounter/scripts/validate.py` differ among the 119 R5 manifest encounter entries. Gameplay/art remain consistent with retained R5 evidence; rendered/capture modes were not rerun for the later wrapper changes.
- [Current architecture and actual limitations](game-sim/docs/02-technical/encounter-architecture.md); [player instructions](game-sim/encounter/README.md).
- [Launch R5](game-sim/encounter/Launch%20Encounter.command). No running window or fresh owner session is claimed by this planning update.
- [Previous tracker snapshot](game-sim/docs/03-production/tracker-history/game-sim-next-steps-20260921-before-beta-plan.md) preserves earlier details; it is historical, not the active next action.

## Immediate next action

The next engineering task is **B2: preparation-only fixture purchase/movement and derived capacity**, using [packet section 8](game-sim/docs/03-production/first-week-implementation-packet.md#8-b2-handoff-and-remaining-risks). It specifies schema 6, stable fixture/slot identities, one shared geometry/routing helper, controls, transaction contracts, art work and acceptance cases. B2 must introduce fixture expense accounting and an isolated development save namespace; full bills/expansion remain B3. B1 stops here; B2 is not started or authorized by this documentation completion. No settled product questions need repeating.

Remaining gates: proposed geometry and multi-actor access need B2/B4 execution; arithmetic is not B8 balance or observed play; motion remains B7; export and the historical exit warning remain B9; R5 owner verdict is still pending and B10 must obtain a separate complete-week decision.

## Shared glass UI — September 21, 2026

Owner-authorized presentation update applied to working source. [Design/template guidance](game-sim/docs/ui-design.md) and [verification](game-sim/docs/ui-verification.md). Earlier candidate/release/owner evidence remains bound to its recorded source; this styling change does not grant new acceptance.
