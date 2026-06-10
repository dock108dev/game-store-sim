# Game Completion Plan

This plan starts from the current validated prototype and defines the work needed to turn it into an actual buildable game.

The current build has useful systems: first-person movement, click-first interaction, receiving, pricing, stocking, sales, trade-ins, preorders, services, ordering, release allocation, fixture placement, hidden-thread hooks, persistence smoke coverage, and a strong automated validation gate. The screenshots from June 7, 2026 show the gap clearly: the project is still visually and experientially a graybox prototype. This document is the production plan for closing that gap without losing the validated loop.

## Current Diagnosis

The latest screenshots should be treated as a production-direction alarm, not as a failed validation gate.

What is working:

- The game runs.
- The player can move through the store and interact with current systems.
- Core retail flows are already represented in world space.
- The local validation gate protects major gameplay and scenario coverage.
- The project has a clean slice process and commit/push cadence.

What is not yet production quality:

- The store still reads as a sparse graybox, not a believable specialty game shop.
- The first view does not sell the fantasy: storefront, counter, shelves, products, customers, backroom, and signage are not yet composed as a game scene.
- Signs are present but still placeholder-like, with clipping and weak hierarchy from normal camera angles.
- Customers are readable as roles only because of color and props; they still read as placeholder capsules.
- The counter, computer, and backroom props communicate function but not enough tone, scale, detail, or interaction polish.
- Menus and panels are improved but still need a production UI language, stronger hierarchy, better interaction feedback, and repeated-use ergonomics.
- Products need a real content/visual pipeline, not just case cues on a small starter set.
- The game has little animation, audio, VFX, camera feedback, day pacing, or onboarding.
- Economy, progression, store expansion, customer variety, and hidden-thread consequences are still mostly skeletons or first-pass systems.

Production conclusion:

- The current repo is a validated prototype foundation.
- The next major objective is not more random mechanics.
- The next objective is a long game-completion phase that turns the prototype into a coherent playable vertical slice, then expands it toward alpha.

## Product Target

The target game is a first-person specialty video game store simulator.

The player should feel like an owner/operator, not a cursor over a tycoon dashboard. The store should be physically touched: boxes opened, games picked up, products priced, shelves stocked, customers served, trade-ins judged, orders received, fixtures placed, and end-of-day decisions made.

Production pillars:

- Tactile work: the most common actions must feel good in first person.
- Retail clarity: the player must understand what every counter, shelf, box, customer, panel, and sign is for.
- Used-game specificity: condition, platform, rarity, completeness, demand, trade-ins, and collector behavior should make this a game store, not a generic shop.
- Store as game board: fixture placement, product visibility, queue paths, storage, and backroom travel should affect outcomes.
- Customers as pressure: buyers, sellers, collectors, parents, returners, service customers, and suspicious contacts should create decisions.
- Operational progression: new tools, categories, fixtures, services, suppliers, store space, and information systems should unlock new work.
- Hidden thread under normal play: suspicious inventory and cash behavior should emerge from ordinary retail systems, not quest markers.

## Hard Rules

- Keep the game shippable after every slice.
- Do not start the next slice with uncommitted changes from the previous validated slice.
- Update manual validation docs whenever visuals, UI, interaction, scene composition, customer behavior, or player workflow changes.
- Run `scripts/validate_godot.sh` before every implementation commit.
- Commit and push every validated slice before continuing.
- Use fictional products, fictional store branding, and fictional platform/category names.
- Do not use real game, console, publisher, retailer, or platform branding.
- Keep click-first center-reticle interaction consistent unless a documented input slice changes it deliberately.
- Keep the register focused on sales, returns, trade-ins, preorders, services, and checkout.
- Keep the backroom computer focused on management, ordering, inventory, reports, releases, storage, supplier messages, and hidden records.
- Do not hide weak interaction readability with decoration.
- Do not add large systems before the moment-to-moment loop feels intentional.

## Slice Protocol

Every slice must follow this stop pattern:

1. Baseline: inspect the current implementation, screenshots, docs, and tests for the target surface.
2. Plan: write the player-facing outcome, expected files, acceptance checks, validation command, manual notes, commit message, and push requirement.
3. Implement: make the smallest complete change that delivers the outcome.
4. Validate: run `scripts/validate_godot.sh`; for docs-only slices, run `git diff --check` and the full Godot gate unless a showstopper blocks it.
5. Manual sync: update `docs/production/07-current-manual-playtest.md` and `game/tests/validation/scenarios/manual_checks.json` when player-facing behavior or visuals change.
6. Screenshot review: inspect generated screenshots when the slice changes visual composition.
7. Commit: commit the completed slice with a clear message.
8. Sync: push the branch before starting the next slice.

Showstoppers that require stopping for user attention:

- The Godot project cannot open or run because of a toolchain failure that cannot be fixed locally.
- Validation fails for a reason that contradicts the intended design and needs a product decision.
- A slice requires licensed or third-party assets that are not available or not legally safe.
- The current design direction conflicts with new user direction.
- A change would require discarding user-authored uncommitted work.

Non-showstoppers:

- The work is large.
- A slice takes multiple commits.
- Screenshots reveal more polish debt.
- Automated validation catches regressions that can be fixed locally.
- Manual validation still needs a human pass after Codex updates the checklist.

## Milestone 0: Completion Planning Lock

Goal: make the production path explicit before more build work starts.

Status: complete in this docs slice once validated, committed, and pushed.

Stops:

- Stop 0.1: Screenshot diagnosis and production gap. Document why the current build is validated but not production-ready.
- Stop 0.2: Completion phase plan. Define milestones, slice stops, validation requirements, and commit/sync cadence.
- Stop 0.3: Backlog sync. Update the active backlog and doc map so the new plan is the current source of truth.
- Stop 0.4: Manual validation sync. Clarify that the current manual checklist remains valid for the prototype, while future slices must extend it.

Acceptance:

- The repo has one clear plan for moving from prototype to game completion.
- The backlog points to this plan as current.
- The manual checklist is not stale relative to the planning state.
- The docs preserve the completed prototype/polish history instead of rewriting it.

Validation:

- `git diff --check`
- `scripts/validate_godot.sh`

Commit:

- `Plan game completion phase`

## Milestone 1: Production Direction And Target Slice

Goal: decide exactly what the first production-quality slice should look like before replacing large parts of the scene.

This milestone should produce the target for the next playable build: one believable store day in one coherent small store, with production-intent visuals and UI on the core loop.

Stops:

- Stop 1.1: Screenshot teardown board. Done in `12-production-target-contracts.md`.
- Stop 1.2: Art direction contract. Done in `12-production-target-contracts.md`.
- Stop 1.3: Store layout contract. Done in `12-production-target-contracts.md`.
- Stop 1.4: UI direction contract. Done in `12-production-target-contracts.md`.
- Stop 1.5: Content target contract. Done in `12-production-target-contracts.md`.
- Stop 1.6: Production acceptance checklist. Done in `12-production-target-contracts.md`, `07-current-manual-playtest.md`, and `manual_checks.json`.

Acceptance:

- A developer can look at the docs and know what to build first.
- The first production target is scoped to the existing retail loop.
- The target avoids real brands and avoids copying inspiration images.
- Every future visual/UI slice has a concrete standard to validate against.

Likely files:

- `docs/game-design/00-vision.md`
- `docs/game-design/01-inspiration-analysis.md`
- `docs/game-design/02-core-loop-and-systems.md`
- `docs/game-design/03-progression-and-content-roadmap.md`
- `docs/production/04-backlog.md`
- `docs/production/07-current-manual-playtest.md`
- `docs/production/11-game-completion-plan.md`

Commit targets:

- `Document production visual target`
- `Document production UI target`
- `Sync production target validation`

## Milestone 2: Store Environment Production Pass

Goal: replace the graybox store read with a production-intent starter shop.

This milestone should make the first screenshot say "small game store" without relying on prompt text.

Stops:

- Stop 2.1: Storefront and entry. Done as a first production cue pass with front glass, open sign, hours decal, and entry threshold.
- Stop 2.2: Sales floor composition. Done as a first merchandising/readability pass with browse-route, new-release, and staff-picks cues.
- Stop 2.3: Register command center. Done as a first prop pass with scanner, card reader, receipt printer, sleeve stack, impulse rack, customer-side mat, and queue context.
- Stop 2.4: Shelf and fixture kit. Done as a first readable fixture-language pass with used-game rack, bargain bin, accessory peg wall, locked-case placeholder, and category labels.
- Stop 2.5: Backroom production blockout. Done as a first operations-room pass with delivery, receiving invoice, backstock overflow, management desk cues, service ticket, safe/security, and evidence-locker placeholders.
- Stop 2.6: Lighting and postprocess. Done as a bounded explicit-light pass with warmer storefront/shelf/register accents, cooler receiving/backroom task lights, and screenshot-safe energy limits.
- Stop 2.7: Collision and navigation. Done as automated clearance coverage for production storefront, sales floor, register, fixture, and backroom props across entry, rack, register, receiving, storage, and fixture-placement routes.
- Stop 2.8: Environment validation sync. Done with automated environment scene assertions, scenario matrix coverage, current validation baselines, manual screenshot/navigation checks, and manual JSON QA coverage.

Acceptance:

- The main scene no longer reads as a graybox from player spawn.
- The store brand and major zones are visible from normal camera height.
- The player can still complete receiving, stocking, sales, trade-ins, preorders, services, ordering, release allocation, and fixture placement.
- Screenshots are useful as composition evidence, not only nonblank images.

Likely files:

- `game/scenes/main/graybox_store.tscn`
- `game/scenes/props/*`
- `game/scripts/world/*`
- `game/tests/validation/scenarios/store_visual_polish.json`
- `game/tests/validation/scenarios/manual_checks.json`
- `docs/production/07-current-manual-playtest.md`

Commit targets:

- `Build production storefront pass`
- `Recompose production sales floor`
- `Build production register area`
- `Build production fixture kit`
- `Rebuild production backroom blockout`
- `Tune production store lighting`
- `Sync environment production validation`

## Milestone 3: Interaction And Game Feel

Goal: make repeated first-person work feel deliberate, legible, and responsive.

Stops:

- Stop 3.1: Reticle and prompt hierarchy. Done in `Polish reticle prompts`: prompts now expose action, subject, blocked, and feedback tones with matching reticle states; validation covers prompt parsing and manual prompt hierarchy review.
- Stop 3.2: Held item presentation. Done in `Polish held item feel`: carry stacks now use active-item focus, depth spacing, scale falloff, subtle bob/settle motion, and held-silhouette metadata while staying below the center reticle.
- Stop 3.3: Pickup/place feedback. Done in `Polish pickup place feedback`: raycast hover ownership, product and slot hover highlights, incompatible-stock blocked prompts, and stocked-item landing confirmations are implemented and validated.
- Stop 3.4: Workstation transitions. Done in `Polish workstation transitions`: pricing, trade-in appraisal, and backroom computer panels now expose open/closed transition state, enter with visible mouse and focused controls, release focus on close, and restore captured first-person mouse.
- Stop 3.5: Fixture placement feel. Done in `Polish fixture placement controls`: storage placement now includes a backroom `Cancel` control, manager/session cancel flow, cash refund, ghost clear, and automated coverage for manager, session, and panel behavior.
- Stop 3.6: Input/settings baseline. Done in `Add input settings baseline`: added a settings panel, pause/settings access from cancel, sensitivity and invert-look preferences, window-mode toggle request, remappable input binding data, and automated/script coverage.
- Stop 3.7: Interaction validation sync. Done in `Sync interaction validation`: validation scenarios, script mapping, manual checks, and production docs now reflect the completed interaction/game-feel pass through prompts, carry, pickup/place, workstations, fixture placement, and settings.

Acceptance:

- Left click remains the primary interaction.
- The player can tell what will happen before clicking.
- Failure states are readable and not silent.
- UI mode transitions never strand the mouse.
- The held item never blocks the center reticle during normal movement.

Commit targets:

- `Polish reticle prompts`
- `Polish held item feel`
- `Polish pickup place feedback`
- `Polish workstation transitions`
- `Polish fixture placement controls`
- `Add input settings baseline`
- `Sync interaction validation`

## Milestone 4: Menu, Register, And Computer Production UI

Goal: replace prototype panels with a coherent production UI system.

Stops:

- Stop 4.1: UI component language. Done in `Add UI component language`: added a shared UI component library, reusable modal/button/list/stat/receipt/tooltip/alert/disabled/selected tokens, surface accents, and applied the language to pricing, trade-in, and backroom computer panels with automated validation coverage.
- Stop 4.2: Register checkout UI. Done in `Add register checkout UI`: added a register checkout panel, itemized sale cart, subtotal/tax/total, cash tender/change due, sale confirmation, service line, preorder deposit line, original return-scope placeholder, transaction feedback, player modal access, and automated/manual validation coverage.
- Stop 4.3: Trade-in appraisal UI. Done in `Polish trade-in appraisal UI`: trade-in appraisal now shows condition, completeness, authenticity confidence, market value, demand, projected margin, cash/store-credit offer, counteroffer-updated margin, and risk notes with automated/manual validation coverage.
- Stop 4.4: Pricing UI. Done in `Polish pricing decision UI`: pricing now shows cost basis, market price, current price, suggested range, projected margin, demand, apply-to-matching batch scope, and outcome warnings for above-range, below-cost, below-range, and batch-price decisions.
- Stop 4.5: Backroom computer tabs. Done in `Polish backroom computer tabs`: the backroom computer now splits dashboard, inventory, ordering, releases, reports, services, storage, suppliers, settings, and records into task tabs with automated/manual validation coverage.
- Stop 4.6: Supplier ordering UI. Done in `Polish supplier ordering UI`: supplier ordering now shows category, cart size, reserved cost, due day, delivery state, storage requirements, and physical receiving expectations with automated/manual validation coverage.
- Stop 4.7: Daily report UI. Done in `Polish daily report UI`: daily reports now show end-of-day summary, cash, sales, trade-ins, services, preorders, launch activity, reputation, losses, bills, and tomorrow recommendations with automated/manual validation coverage.
- Stop 4.8: UI accessibility pass. Done in `Add UI accessibility floor`: shared UI now enforces text-size, contrast, keyboard/mouse focus, and 1280x720 modal-fit floors across production panels with automated/manual validation coverage.
- Stop 4.9: UI validation sync. Done in `Sync production UI validation`: scenario coverage, manual checklist, validation docs, and milestone status now reflect the completed Stop 4.1 through Stop 4.9 production UI pass.

Acceptance:

- The register and computer are visually distinct surfaces.
- Repeated-use actions are grouped by task, not by implementation order.
- Important business values are visible at decision time.
- Panels fit the current desktop target without clipped text.
- Manual validation can name exact UI surfaces and expected states.

Commit targets:

- `Create production UI components`
- `Build register checkout UI`
- `Build trade in appraisal UI`
- `Build pricing decision UI`
- `Build backroom computer tabs`
- `Build supplier ordering UI`
- `Build daily report UI`
- `Sync production UI validation`

## Milestone 5: Customer Production Pass

Goal: replace placeholder customers with understandable store visitors who create pressure and personality.

Stops:

- Stop 5.1: Customer visual kit. Done in `Build customer visual kit`: buyer, trade-in, preorder, service, and suspicious customer scenes now use modular non-capsule torso, shoulder, arm, leg, headwear, prop, and role-silhouette meshes, with automated role-readability coverage and manual checklist sync.
- Stop 5.2: Animation baseline. Done in `Add customer animation baseline`: customer scenes now share a `CustomerPoseAnimator` component with idle, walk, browse, pick up, queue, talk, pay, hand-over-item, leave-happy, leave-annoyed, and wait-impatient placeholder poses mapped from current customer states, with script coverage, automated pose tests, and manual readability checks.
- Stop 5.3: Queue and browsing behavior. Done in `Polish customer pathing`: customer manager now assigns readable browse points, queue-lane positions, register approach points, and leave targets; buyer customers expose pathing summaries, recover from blocked paths, and leave after completed sales while preserving the validated sale-complete state contract.
- Stop 5.4: Customer feedback. Done in `Add customer feedback bubbles`: customer scenes now include compact world-space feedback bubbles with shared tone handling for purchase intent, price refusal, trade-in response, preorder confirmation, service pickup, and suspicious cues, with automated outcome coverage and manual readability checks.
- Stop 5.5: Archetype data. Done in `Add customer archetype data`: added resource-backed browser, target buyer, parent gift buyer, collector, trade-in seller, return customer, service customer, regular, and suspicious contact archetypes, wired current customer scenes to role archetypes, and covered the data contract in validation/manual checks.
- Stop 5.6: Conversation baseline. Done in `Add customer conversation baseline`: added resource-backed dialogue flows for help requests, recommendations, trade-in pushback, complaints/returns, and hidden-thread probes, linked archetypes to flow IDs, and covered optional hidden-thread probe isolation in validation/manual checks.
- Stop 5.7: Customer validation sync. Done in `Sync customer production validation`: validation docs, manual checks, scenario coverage, and milestone status now reflect the completed Stop 5.1 through Stop 5.7 customer production pass.

Acceptance:

- Customers no longer read as capsules.
- Roles are readable before prompt text.
- Queue and browsing behavior makes sense in the production store layout.
- Customers react to price, wait time, availability, and service outcomes.
- Customer systems remain data-driven enough to expand.

Commit targets:

- `Build customer visual kit`
- `Add customer animation baseline`
- `Polish customer pathing`
- `Add customer feedback bubbles`
- `Add customer archetype data`
- `Add customer conversation baseline`
- `Sync customer production validation`

Validation snapshot:

- `scripts/validate_godot.sh` passes with 374 GUT tests.
- UI scenario automation coverage is 353/426, above the required 80% threshold.
- Production script mapping coverage is 39/39.
- Manual customer-production checks are current for visual kit, animation, pathing, feedback bubbles, archetype data, dialogue data, and validation sync.
- Manual product-content checks are current for Stop 6.1 inventory schema expansion.
- Manual product-visual checks are current for Stop 6.2 visual generation rules.
- Manual starter-catalog checks are current for Stop 6.3 catalog expansion.
- Manual condition/authenticity cue checks are current for Stop 6.4.
- Manual shelf-label/price-tag checks are current for Stop 6.5.

## Milestone 6: Product And Content Pipeline

Goal: make inventory scalable and visibly game-specific.

Stops:

- Stop 6.1: Inventory schema expansion. Done in `Expand inventory schema`: product definitions now expose category, platform family, format, condition, completeness, authenticity, rarity, demand, cost, market value, risk, and default location metadata, with catalog resources, automated schema coverage, and manual content-review checklist updates.
- Stop 6.2: Product visual generation rules. Done in `Build product visual variants`: product visual rules now generate reusable case, disc, cartridge, accessory, console, controller, box, sealed, loose, and service-ticket profiles, and product items apply generated cue meshes from those profiles.
- Stop 6.3: Starter catalog expansion. Done in `Expand starter catalog`: the product catalog now contains 33 fictional products across used games, new games, accessories, hardware, and service tickets, including 30 sellable physical products for several days of rotation.
- Stop 6.4: Condition and authenticity cues. Done in `Add condition authenticity cues`: product visual rules now add visible scratches, missing manual markers, loose media, damaged label, reseal, and suspicious serial-risk cue meshes from condition, completeness, authenticity, risk tags, and serial mismatch state.
- Stop 6.5: Shelf label and price tag system. Done in `Add shelf label price tags`: product items now generate compact category, platform, price, sale, preorder, staff-pick, and bargain tag text without replacing interaction prompts.
- Stop 6.6: Content validation tools. Done in `Add product content validation`: `scripts/check_product_catalog.py` now runs in the local gate and checks unique IDs, fictional names, required fields, category coverage, pricing sanity, sellable depth, and visual variant coverage.
- Stop 6.7: Product pipeline validation sync. Done in `Sync product pipeline validation`: standalone validation tool manifests, validation docs, manual content review, and milestone status now reflect the completed Stop 6 product/content pass.

Acceptance:

- The starter store can stock more than one meaningful category.
- Products are visibly different at receiving, hand, shelf, customer cart, and register scale.
- Product data drives pricing and customer decisions.
- Content can grow without hard-coded branches for every item.

Commit targets:

- `Expand inventory schema`
- `Build product visual variants`
- `Expand starter catalog`
- `Add condition authenticity cues`
- `Add shelf label price tags`
- `Add product content validation`
- `Sync product pipeline validation`

Validation snapshot:

- `scripts/validate_godot.sh` passes with 374 GUT tests.
- UI scenario automation coverage is 353/425, above the required 80% threshold.
- Production script mapping coverage is 39/39.
- Validation tool manifest coverage reports 1 active standalone tool.
- Product catalog content validation passes with 33 products.
- Manual product-content checks are current for schema, visual variants, starter catalog breadth, condition/authenticity cues, shelf labels, price tags, content validation, and validation-manifest sync.

## Milestone 7: Economy, Day Loop, And Progression

Goal: turn isolated systems into a game with pressure and forward motion.

Stops:

- Stop 7.1: Day structure. Done in `Build production day structure`: store sessions now expose opening, setup, customer-hours, closing, report, and tomorrow-planning phases; start-day payloads include opening summaries; daily reports show the phase/plan; save/load preserves the current phase.
- Stop 7.2: Cash pressure. Done in `Add cash pressure systems`: end-of-day close now posts daily rent/utility operating expenses once, reports supplier terms, payroll, repairs, and shrinkage as expandable pressure hooks, tracks reserved obligations, and persists posted expenses.
- Stop 7.3: Reputation. Done in `Add reputation baseline`: reputation events now cover pricing fairness, wait time, preorder outcomes, service outcomes, return handling, suspicious choices, stock variety, and launch shortage consequences, with clamped score changes, summaries, daily report counts, and save/load coverage.
- Stop 7.4: Demand tuning. Done in `Tune demand systems`: category demand now supports contextual shelf visibility, price pressure, rarity, marketing, day-event, and customer-archetype multipliers, with active-inventory backroom summaries while preserving current default category/tier price-limit behavior.
- Stop 7.5: Upgrade path. Done in `Add upgrade path baseline`: store sessions now expose fixture, category, service-tool, computer-tool, signage, storage, and starter-expansion upgrades, with purchase rules, expansion prerequisite, backroom summary, and save/load coverage.
- Stop 7.6: Tutorial/onboarding. Done in `Add onboarding baseline`: store sessions now expose a state-derived owner checklist for receiving, pricing, stocking, checkout, trade-ins, backroom computer use, ordering, and closing, and the backroom dashboard presents it without a separate debug tutorial overlay.
- Stop 7.7: Economy validation sync. Done in `Sync economy progression validation`: scenario coverage and manual docs now cover the cross-flow day-to-day economy, decision feedback, progression goals, owner onboarding, and several-day manual playthrough expectations.

Acceptance:

- A player can play several days and understand why cash, stock, reputation, and obligations changed.
- The player has near-term and medium-term goals.
- Progression unlocks new work, not only numeric upgrades.
- Bad decisions create recoverable pressure.

Commit targets:

- `Build production day structure`
- `Add cash pressure systems`
- `Add reputation baseline`
- `Tune demand systems`
- `Add upgrade path baseline`
- `Add onboarding baseline`
- `Sync economy progression validation`

Validation snapshot:

- Store session tests cover production day structure and phase transitions through customer hours, closing, report, tomorrow planning, and next-day setup.
- Daily report tests cover the production day-plan line.
- Save/load tests preserve the current day phase.
- Manual day-structure checks are current for report readability and owner/operator day-loop language.
- `scripts/validate_godot.sh` passes with 378 GUT tests.
- UI scenario automation coverage is 357/432, above the required 80% threshold.
- Production script mapping coverage is 39/39.
- Validation tool manifest coverage reports 1 active standalone tool.
- Product catalog content validation passes with 33 products.
- Store session tests cover daily cash pressure posting once per close, cash-pressure summary text, and reserved obligations.
- Daily report tests cover operating expenses, reserved obligations, bill language, and cash-pressure text.
- Save/load tests preserve posted operating expenses.
- Manual cash-pressure checks are current for report readability, bill language, gross-profit separation, and recoverable pressure.
- `scripts/validate_godot.sh` passes with 380 GUT tests.
- UI scenario automation coverage is 359/435, above the required 80% threshold.
- Production script mapping coverage is 39/39.
- Validation tool manifest coverage reports 1 active standalone tool.
- Product catalog content validation passes with 33 products.
- Store session tests cover reputation events for pricing, wait time, preorder, service, returns, suspicious choices, stock variety, idempotency, clamping, and launch shortage integration.
- Daily report tests cover reputation event counts.
- Save/load tests preserve reputation events.
- Manual reputation checks are current for consequence readability and recoverability.
- `scripts/validate_godot.sh` passes with 387 GUT tests.
- UI scenario automation coverage is 372/452, above the required 80% threshold.
- Production script mapping coverage is 39/39.
- Validation tool manifest coverage reports 1 active standalone tool.
- Product catalog content validation passes with 33 products.
- Category demand tests cover contextual demand tuning and tuning-signal summaries.
- Store session and day-summary panel tests cover active inventory demand tuning in the backroom computer.
- Manual demand-tuning checks are current for readability and player-understandable demand causes.
- Store session tests cover upgrade catalog availability, purchase rules, storage-to-expansion unlocking, and upgrade summary text.
- Save/load tests preserve purchased upgrades.
- Day-summary panel tests cover the backroom computer upgrade summary.
- Manual upgrade-path checks are current for progression readability and future-work clarity.
- Store session tests cover owner onboarding checklist coverage and state-derived progress from inventory, ledger, order, and closing state.
- Day-summary panel tests cover the owner checklist on the backroom dashboard.
- Manual owner-onboarding checks are current for first-day teaching language and immersion.
- Economy scenario coverage now includes cross-flow day phase, close pressure, next-day setup, decision feedback, progression goals, and manual-doc sync.
- Manual economy progression checks are current for several-day cash, stock, reputation, obligation, upgrade, and tomorrow-planning readability.

## Milestone 8: Backroom Operations

Goal: make the backroom a real physical workflow hub.

Stops:

- Stop 8.1: Receiving workflow. Done in `Build receiving workflow`: supplier delivery now creates pending receiving batches with delivery point, sealed/opened box state, invoice check, sorting destination, completed status, backroom Open Box/Invoice/Sort controls, save/load persistence, and validation/manual checklist coverage.
- Stop 8.2: Storage workflow. Done in `Build storage workflow`: store sessions now move physical product item nodes from receiving into a backstock shelf and back to receiving, track shelf capacity and overflow, expose Store/Pull backroom controls, include storage movement history in save/load, and document manual readability checks.
- Stop 8.3: Service bench workflow. Done in `Build service bench workflow`: store sessions now expose disc resurfacing service tickets, locked cartridge cleaning, console-test placeholder data, ticket parts, queued/in-progress/ready-for-pickup/picked-up states, Start Job/Work Job backroom controls, register pickup integration, save/load persistence, and manual checklist coverage.
- Stop 8.4: Management desk workflow. Done in `Build management desk workflow`: store sessions now expose management desk tasks for supplier messages, bills, inventory search, report review, preorder planning, and upgrade ordering, with Review Desk/Upgrade controls, Computer Analytics upgrade ordering, save/load persistence, and manual checklist coverage.
- Stop 8.5: Security/safe placeholders. Done in `Add security safe placeholders`: EvidenceStorage now exposes cash safe, high-value storage, suspicious goods isolation, and security footage placeholders, StoreSession is wired to EvidenceStorage, Records tab shows inactive security placeholder state, and manual checklist coverage is current.
- Stop 8.6: Backroom validation sync. Done in `Sync backroom operations validation`: validation docs, manual playtest focus, backlog state, and Milestone 8 snapshot now reflect the complete backroom operations pass.

Acceptance:

- Orders and inventory produce physical work in storage or receiving.
- The computer tells the player what exists; it does not teleport normal inventory into solved states.
- Service work happens at the bench but customer completion still fits the register/customer loop.
- Hidden-thread surfaces remain optional.

Commit targets:

- `Build receiving workflow`
- `Build storage workflow`
- `Build service bench workflow`
- `Build management desk workflow`
- `Add security safe placeholders`
- `Sync backroom operations validation`

Validation snapshot:

- `scripts/validate_godot.sh` passes with 437 GUT tests.
- UI scenario automation coverage is 424/519, above the 80% threshold.
- Production script mapping coverage is 43/43.
- Standalone validation tool manifest coverage has 1 active tool.
- Product catalog content check passes with 33 fictional products.
- Focused GUT coverage passes for store session receiving delivery/lifecycle, save/load receiving persistence, and day-summary panel receiving controls.
- Manual receiving workflow checks are current for delivery point, box opening, invoice check, sorting, and pending/completed state readability.
- Focused GUT coverage passes for store session storage movement/retrieval, day-summary panel Store/Pull controls, and save/load storage movement persistence.
- Manual storage workflow checks are current for capacity, overflow, Store/Pull controls, backstock movement, and retrieval readability.
- Focused GUT coverage passes for service bench ticket workflow, day-summary panel Start Job/Work Job controls, register pickup integration, and save/load service ticket persistence.
- Manual service bench checks are current for capabilities, parts, ticket progress, ready pickup, and register completion readability.
- Focused GUT coverage passes for management desk review workflow, day-summary panel Review Desk/Upgrade controls, upgrade ordering, and save/load management review persistence.
- Manual management desk checks are current for supplier messages, bills, inventory search, report review, preorder planning, upgrade ordering, and non-teleporting desk-work readability.
- Focused GUT coverage passes for security placeholder catalog, placeholder records, StoreSession/EvidenceStorage wiring, and Records tab placeholder readout.
- Manual security/safe placeholder checks are current for inactive cash safe, high-value storage, suspicious goods isolation, security footage, and non-objective readability.
- Backroom operations validation is synced through Stop 8.6, with the scenario matrix and manual playtest checklist covering physical receiving, storage, service bench, management desk, and security placeholder operations.

## Milestone 9: Store Building, Decoration, And Expansion

Goal: make store layout and personalization matter.

Stops:

- Stop 9.1: Fixture catalog. Done in `Expand fixture catalog`: the fixture catalog now includes wall shelf, accessory peg wall, bargain bin, locked case, counter rack, demo kiosk placeholder, new-release wall, and backroom rack entries, with slot counts, accepted product categories, placement zones, gameplay tags, upgrade locks, placeholder flags, StoreSession summaries, and backroom computer visibility.
- Stop 9.2: Placement UX. Done in `Polish placement UX`: fixture placement now validates full fixture footprints against placement bounds, protects critical path clearance points, rejects overlap with already placed fixtures, records placement issues, summarizes preview position/rotation/footprint, supports undo for movement/rotation/snap, exposes a compact Undo button, and preserves cancel/refund and confirmation behavior.
- Stop 9.3: Category assignment. Done in `Add fixture category assignment`: StoreSession can assign supported categories to pending or placed fixtures, placed fixture ShelfSlot nodes receive the assigned category, storage summaries list category assignments, the backroom computer exposes a compact Assign Cat action for the first placed rack, unsupported categories are rejected, and assigned shelf slots affect demand tuning through visibility and marketing signals.
- Stop 9.4: Decoration system. Done in `Add decoration baseline`: StoreSession now exposes wall paint, floor material, posters, signage, lights, display props, and clutter-budget decoration entries; the backroom computer applies the starter wall-paint decoration, charges cash, disables repeat purchase, summarizes applied decorations and clutter budget, and save/load preserves purchased decoration state.
- Stop 9.5: Layout effects. Done in `Add layout effects baseline`: StoreSession now summarizes fixture visibility, impulse fixtures, queue space, customer travel distance, and theft-risk placeholder state; category demand includes a layout signal; active inventory demand text shows layout effects; launch-visibility fixtures can increase launch queue demand; crowded, long-walk, and risky layouts can reduce it; and the main scene wires StoreSession to CustomerManager for real queue/travel metrics.
- Stop 9.6: Expansion baseline. Done in `Add starter expansion baseline`: Starter Store Expansion now unlocks after Backroom Storage Bay, purchases as progression state, increases storage capacity to 18 cases, widens fixture placement bounds, expands CustomerManager playable/queue bounds, updates upgrade/storage summaries, and persists through purchased-upgrade save/restore.
- Stop 9.7: Building validation sync. Done in `Sync building validation`: validation docs, backlog state, scenario matrix, manual checklist, baseline counts, and Milestone 9 status now reflect the completed fixture catalog, placement UX, category assignment, decoration, layout effects, and starter expansion pass.
- Stop 10.1: Suspicion rules. Done in `Define suspicion rules`: added a data-first suspicion rule catalog for serial mismatch, suspicious suppliers, cash buyers, impossible provenance, counterfeit goods, and hidden storage, with metadata/node evaluation, scoring, event-log rule creation, scenario coverage, and manual hidden-thread tone checks.
- Stop 10.2: Clue surfaces. Done in `Add hidden clue surfaces`: added a hidden clue-surface catalog for invoices, supplier notes, serial lookup, supplier emails, customer comments, security clips, and backroom artifacts; StoreSession now evaluates available/waiting clue status from store context; Records shows the clue summary without activating objectives.
- Stop 10.3: Choice points. Done in `Add hidden choice paths`: added ignore, document, sell-as-normal, isolate, report, accept-cash, reject-goods, and supplier follow-up choice paths; StoreSession records and deduplicates choices; Records shows available paths and recorded choices; save/load preserves recorded hidden choices.
- Stop 10.4: Consequences. Done in `Add hidden consequences`: added consequence rules for reputation, cash, supplier access, customer trust, inspection risk, and story state; recorded choices now apply consequences once, Records shows consequence summaries, and save/load preserves consequence events and hidden state scores.
- Stop 10.5: Optionality guard. Done in `Guard hidden thread optionality`: StoreSession and Records now explicitly state hidden-thread progression is not required, the retail loop is not blocked, and normal receiving, pricing, stocking, register, ordering, storage, services, reports, and day progression remain available.
- Stop 10.6: Hidden-thread validation sync. Done in `Sync hidden thread validation`: added a validation-sync GUT audit for hidden-thread flags, dedupe, persistence, optionality, and manual clue-readability coverage; validation docs, manual checklist, scenario matrix, and backlog status now reflect the completed Milestone 10 pass.

Acceptance:

- Rearranging the store changes play, not only appearance.
- Decoration improves tone without hiding interactables.
- Placement cannot create broken core paths.
- Expansion creates new operational choices.

Validation snapshot:

- Focused GUT coverage passes for the expanded fixture catalog, fixture metadata, placeable scene paths, StoreSession fixture summaries, upgrade-gated fixture ordering, starter rack order metadata, and backroom computer catalog visibility.
- Focused GUT coverage passes for footprint-aware placement bounds, critical-path clearance rejection, overlap rejection, movement/rotation/snap undo, compact Undo button state, and main-scene path-clearance manager wiring.
- Focused GUT coverage passes for fixture category assignment, supported/unsupported category validation, placed slot category updates, Assign Cat panel flow, and assigned-fixture demand tuning effects.
- Focused GUT coverage passes for decoration catalog entries, starter decoration application, clutter budget text, backroom Apply Decor flow, repeat-purchase disabling, and save/load persistence.
- Focused GUT coverage passes for category-demand layout multipliers, layout-effect summaries, active-inventory layout demand tuning, launch-visibility queue demand effects, and main-scene CustomerManager wiring.
- Focused GUT coverage passes for starter expansion unlock/purchase, expanded storage capacity, placement/customer-manager bounds, upgrade/storage summary text, and save/restore persistence.
- Manual Store Building Focus checks are current for the expanded fixture list, pricing/category/slot/zone readability, upgrade locks, starter rack placement flow, category assignment, demand tuning effects, footprint/path/overlap invalid feedback, undo behavior, demo kiosk placeholder readability, decoration catalog/application/clutter-budget readability, layout-effect readability, starter-expansion readability, and 1280x720 storage/settings/demand-tab fit.
- Building validation is synced through Stop 9.7, with scenario coverage and manual playtest docs matching the completed Milestone 9 behavior.
- Focused GUT coverage passes for the Stop 10.1 suspicion-rules catalog, metadata scoring, supplier/customer/provenance/storage signals, product/supplier/customer node evaluation, and rule-to-event logging.
- Focused GUT coverage passes for the Stop 10.2 clue-surface catalog, context readiness, StoreSession Records summary, and DaySummaryPanel Records-tab display.
- Focused GUT coverage passes for the Stop 10.3 choice catalog, choice availability, choice recording/deduplication, Records-tab choice display, and save/load preservation.
- Focused GUT coverage passes for the Stop 10.4 consequence rules, hidden cash/risk/reputation effects, Records-tab consequence display, and save/load preservation.
- Focused GUT coverage passes for the Stop 10.5 optionality guard, proving hidden-thread content can be ignored without blocking supplier ordering, day close, next-day progression, Records-tab status, or normal retail work.
- Focused GUT coverage passes for the Stop 10.6 validation-sync audit, proving the scenario matrix and manual checklist retain flags, dedupe, persistence, optionality, and clue-readability coverage.
- Manual Hidden Thread Focus checks are current for Stop 10.6 rule tone, clue-surface readability, choice-path readability, consequence readability, optionality, nonblocking behavior, validation sync, and no visible objective escalation.

Commit targets:

- `Expand fixture catalog`
- `Polish placement UX`
- `Add fixture category assignment`
- `Add decoration baseline`
- `Add layout effects baseline`
- `Add store expansion baseline`
- `Sync building validation`

## Milestone 10: Hidden Thread Production Arc

Goal: make suspicious activity a coherent optional layer under retail play.

Stops:

- Stop 10.1: Suspicion rules. Done in `Define suspicion rules`: define risk flags for serial mismatch, suspicious suppliers, cash buyers, impossible provenance, counterfeit goods, and hidden storage.
- Stop 10.2: Clue surfaces. Done in `Add hidden clue surfaces`: add invoices, notes, serial lookup, supplier emails, customer comments, security clips, and backroom artifacts.
- Stop 10.3: Choice points. Done in `Add hidden choice paths`: add ignore, document, sell, isolate, report, accept cash, reject goods, and follow-up paths.
- Stop 10.4: Consequences. Done in `Add hidden consequences`: add reputation, cash, supplier access, customer trust, inspection risk, and story state consequences.
- Stop 10.5: Optionality guard. Done in `Guard hidden thread optionality`: ensure a normal retail player can ignore the thread without blocked progression.
- Stop 10.6: Hidden-thread validation sync. Done in `Sync hidden thread validation`: add tests for flags, dedupe, persistence, optionality, and manual clue readability.

Acceptance:

- Suspicious content feels like retail anomalies, not a separate quest system.
- Choices have consequences but do not hijack the core game.
- Hidden state persists cleanly.
- Optional clue surfaces are discoverable but not mandatory.

Commit targets:

- `Define suspicion rules`
- `Add hidden clue surfaces`
- `Add hidden thread choices`
- `Add hidden thread consequences`
- `Guard hidden thread optionality`
- `Sync hidden thread validation`

## Milestone 11: Audio, VFX, And Presentation Feel

Goal: add sensory feedback that makes the store feel alive.

Stops:

- Stop 11.1: Store ambience. Done in `Add store ambience baseline`: add room tone, HVAC, street muffling, door chime, register area ambience, backroom ambience, and closing quiet.
- Stop 11.2: Interaction sounds. Done in `Add interaction audio baseline`: add pickup, place, stock, scan, register, cash drawer, computer click, button hover/click, box open, shelf bump, and error sounds.
- Stop 11.3: Customer audio placeholders. Done in `Add customer audio placeholders`: add footstep, mumble, greeting, approval, annoyance, and leaving cues without committing to final voice.
- Stop 11.4: VFX and microfeedback. Done in `Add presentation VFX baseline`: add subtle highlights, item settle, sale confirmation, cash/reputation tick, day transition, delivery arrival, and invalid action feedback.
- Stop 11.5: Camera feel. Done in `Tune camera feel`: tune movement bob, held item sway, workstation transition, field of view, and motion comfort.
- Stop 11.6: Presentation validation sync. Done in `Sync presentation validation`: add manual audio/feel checklist and automated asset/load checks where practical.

Acceptance:

- Common actions have readable sensory feedback.
- Feedback supports player understanding rather than noise.
- Audio does not mask UI or prompt comprehension.
- Motion remains comfortable.

Commit targets:

- `Add store ambience baseline`
- `Add interaction audio baseline`
- `Add customer audio placeholders`
- `Add presentation VFX baseline`
- `Tune camera feel`
- `Sync presentation validation`

Validation snapshot:

- Focused GUT coverage passes for the Stop 11.1 store ambience catalog, conservative mix levels, main-scene AudioStreamPlayer3D wiring, and store-zone summary text.
- Focused GUT coverage passes for the Stop 11.2 interaction audio catalog, conservative cue mix levels, player-controller AudioStreamPlayer wiring, cue recording, and action-group summary text.
- Focused GUT coverage passes for the Stop 11.3 customer audio placeholder catalog, conservative cue mix levels, buyer/trade-in/preorder/service/suspicious scene profile wiring, feedback-tone cue mapping, and summary text.
- Focused GUT coverage passes for the Stop 11.4 presentation microfeedback catalog, player-controller CPUParticles3D wiring, result-driven effect mapping, and summary text.
- Focused GUT coverage passes for the Stop 11.5 camera-feel comfort bounds, movement bob, held-item sway, modal/workstation settling, FOV limits, and summary text.
- Focused GUT coverage passes for the Stop 11.6 presentation validation-sync audit covering automated scenario IDs, manual readability/motion-comfort checks, and docs coverage.
- Manual Presentation Feel Focus checks are current for room tone, HVAC, storefront muffle, door chime, register ambience, backroom ambience, closing quiet, pickup/place/stock cues, scan/register/cash cues, computer/button cues, box/shelf/error cues, customer footsteps, mumbles, greetings, approval, annoyance, leaving cues, target highlights, item settle, sale/cash/reputation ticks, day transition, delivery arrival, invalid-action feedback, movement bob, FOV shift, held-item sway, workstation settling, milestone presentation review, and prompt/UI masking risk.

## Milestone 12: Save, Load, Settings, And Release Wrapper

Goal: make the game session durable and presentable outside the editor.

Stops:

- Stop 12.1: Save slot UI. Done in `Add save slot UI`: add new game, continue, save slot list, overwrite, delete, and save metadata.
- Stop 12.2: Save migration policy. Done in `Add save migration policy`: version save data and add migration/failure handling.
- Stop 12.3: Settings menu. Done in `Add settings menu`: add audio, display, controls, mouse, accessibility, and reset defaults.
- Stop 12.4: Pause and main menu. Done in `Add pause main menu`: add pause state, resume, settings, quit, main menu, and safe mouse capture transitions.
- Stop 12.5: Build/export pipeline. Done in `Add desktop export pipeline`: add desktop export settings, template-free pack export smoke, and local build verification script.
- Stop 12.6: Release validation sync. Done in `Sync release wrapper validation`: audit the release-wrapper matrix, desktop export tool manifest, docs coverage, pack-smoke handoff, binary-template fallback, and manual build save/load checklist.

Acceptance:

- A player can start, save, quit, relaunch, and continue without editor/debug paths.
- Settings persist.
- The exported build can run the current vertical slice.
- Validation includes editor and exported-build surfaces.

Commit targets:

- `Add save slot UI`
- `Add save migration policy`
- `Add settings menu`
- `Add pause main menu`
- `Add desktop export pipeline`
- `Sync release wrapper validation`

Validation snapshot:

- Focused GUT coverage passes for the Stop 12.1 file-backed save slot registry, new game slot metadata, accidental overwrite guard, explicit overwrite, delete, continue data, save slot panel modal/accessibility behavior, player-controller panel wiring, and save/load UI component language.
- Manual Save/Load Focus checks are current for slot metadata readability, New Game overwrite protection, explicit overwrite/delete review, continue-scope clarity, and mouse capture restoration.
- Focused GUT coverage passes for the Stop 12.2 current save version, schema ID, version 1 migration defaults, migration history, future-version rejection, malformed JSON failure state, and migration-policy summary text.
- Focused GUT coverage passes for the Stop 12.3 audio/display/mouse/accessibility controls, settings profile persistence, reset bindings/defaults, modal focus, and player settings application.
- Focused GUT coverage passes for the Stop 12.4 pause menu, resume transition, main-menu mode, start-game transition, settings/save-load routing, quit request state, and mouse capture recovery.
- Desktop export pipeline coverage passes for the Stop 12.5 macOS export preset, template-free `.pck` export, pack boot smoke, binary-export fallback message, and release-wrapper manual scenario entries.
- Release wrapper validation sync passes for the Stop 12.6 scenario matrix, desktop export tool manifest, docs coverage, pack-smoke handoff, binary-template fallback, and manual build save/load review checklist.
- Full validation snapshot is `scripts/validate_godot.sh` passing with 552 GUT tests, UI scenario automation coverage 504/624, production script mapping coverage 52/52, 3 active validation tools, 33 catalog products, desktop pack smoke, alpha performance smoke, screenshot sanity checks, and old-name scan.

## Milestone 13: Alpha Hardening

Goal: stabilize a coherent alpha build.

Stops:

- Stop 13.1: Bug triage. Done in `Triage alpha bugs`: create an alpha bug list from automated failures, screenshot review, manual validation, and playtest notes.
- Stop 13.2: Performance pass. Done in `Run alpha performance pass`: profile scene load, frame time, UI panels, customer pathing, save/load, screenshots, and exported build startup.
- Stop 13.3: Test expansion. Done in `Expand alpha regression tests`: add regression tests for rotated fixture placement bounds, visible buyer queue spacing, and screenshot subject coverage for current alpha P1/P2 risks.
- Stop 13.4A: Scene-readability content pass. Done in `Polish alpha scene readability`: improve wall detail, sign framing, special-customer spacing, display-rack profile cues, placed-fixture screenshot framing, and backroom computer first-view controls.
- Stop 13.4B: Content/copy pass. Done in `Fill alpha starter content`: filled customer role text, dialogue staff context, supplier order notes, release planning hooks, daily report readout copy, register return-scope copy, and backroom action labels to alpha quality.
- Stop 13.5: Balance pass. Done in `Tune alpha economy`: centralized alpha balance targets, tuned daily overhead, supplier lot cost, service margins, pricing range, buyer tolerance, and early upgrade costs.
- Stop 13.6: External playtest package. Done in `Prepare alpha playtest package`: added the external package runbook, build/artifact handoff, concise playtest script, known issues, feedback form, rollback plan, scenario matrix coverage, and manual package checks.
- Stop 13.7: Alpha validation sync. Done in `Sync alpha validation`: reran the full gate and desktop pack smoke, synced the validation snapshot, scenario matrix, manual alpha checklist, bug list, backlog state, playtest-package handoff, and completion-plan status.

Acceptance:

- The game can be played from a fresh start through multiple days.
- The core fantasy is visible without explaining future plans.
- Known issues are tracked and not hidden in chat.
- The alpha package is buildable from the repo.

Commit targets:

- `Triage alpha bugs`
- `Run alpha performance pass`
- `Expand alpha regression tests`
- `Fill alpha starter content`
- `Tune alpha economy`
- `Prepare alpha playtest package`
- `Sync alpha validation`

Validation snapshot:

- Stop 13.1 alpha bug triage records no current P0 automated failures, latest full-gate evidence, screenshot-derived P1/P2 issues AH-001 through AH-011, release-package limits, and target slices for performance, regression, content, balance, and playtest-package follow-up.
- Stop 13.2 alpha performance pass records a repeatable baseline for scene load, instantiation, 60-frame stepping, UI panel cycling, customer pathing, save codec roundtrip, screenshot capture, and exported pack startup in `14-alpha-performance-baseline.md`.
- Stop 13.3 alpha regression-test expansion records automated guardrails for fixture placement framing risk, queue/register composition risk, and screenshot subject coverage before the content pass.
- Stop 13.4A alpha scene-readability pass records automated guardrails for wall-detail props, sign framing, customer arc depth, rack profile cues, placed-fixture screenshot composition, and backroom computer first-view action controls.
- Stop 13.4B alpha content/copy pass records automated guardrails for customer copy, dialogue context, supplier order copy, release planning copy, daily report sections, register return-scope copy, and backroom action labels.
- Stop 13.5 alpha balance pass records automated guardrails for starting cash, daily overhead, supplier lot cost/delivery, service margins, pricing range, buyer tolerance, early upgrade costs, updated accounting readouts, and manual multi-day balance review coverage.
- Stop 13.6 alpha playtest package records automated guardrails for package docs, build commands, artifact paths, known issues, feedback form, rollback plan, scenario matrix entries, manual package handoff checks, and the concise external playtest script.
- Stop 13.7 alpha validation sync records automated guardrails for the final alpha-hardening docs, gate snapshot, desktop pack smoke handoff, manual checklist sections, scenario matrix entries, and feedback-triage routing.

## Current Handoff

Milestones 1 through 13 are implemented, validated, committed, and pushed on `codex/let-it-fly`.

The June 9 manual screenshot review supersedes the previous external-playtest handoff. The repo remains mechanically green, readability recovery implementation is complete, and label depth-safety stabilization is complete, but the build still needs the owner recovery screenshot set before it can be sent to external testers.

The playability readability recovery phase in `16-playability-readability-recovery-plan.md` is implemented through Slice 7:

1. Fix camera scale, player framing, and spawn composition.
2. Fix oversized signage, foreground blockers, and receiving sightlines.
3. Fix prompt, reticle, pickup, pricing-entry, and stocking readability.
4. Fix pricing/register/trade-in/preorder/service/save modal legibility.
5. Fix customer role markers and register queue readability.
6. Fix backroom/computer readability.
7. Done: reran the automated gate and kept the external playtest package paused pending the owner recovery screenshot set.
8. Done: stabilized angle-dependent label clipping for panel-backed signs and product price tags.

The stockroom build plan in `17-stockroom-production-plan.md` is mechanically complete through Slice 8 with employees-only boundary, physical receiving, backstock shelving, service/security corners, manager-office computer context, workflow copy, cooler light/material hierarchy, route tape, floor shadows, wall cards, box/paper material variation, validation sync, and external-package gating. External playtest remains paused until owner recovery and stockroom screenshot approval pass.

The first post-stockroom production slice is also mechanically complete: return customers now reach a register `Return Review`, refunds reduce cash, fair handling affects reputation, returned items route to receiving review, daily reports show return refunds, and the validation matrix/script mapping covers the flow. Remaining return/exchange depth is policy/fraud/exchange selection, not the baseline refund loop.

Codex can keep the repo mechanically validated, but it cannot mark controller feel, OS window behavior, mouse-capture feel, economy feel, or long-form playtest readability as human-approved.

## Completion Definition

This phase is mechanically complete when the repo can produce an alpha-quality local desktop build with:

- A production-intent starter store scene.
- A complete first-person day loop.
- Receiving, pricing, stocking, checkout, trade-ins, preorders, services, ordering, fixture placement, and end-of-day reporting working without debug-only steps.
- A production UI language for prompts, register, pricing, appraisal, computer, reports, settings, and save/load.
- Production-intent customer visuals, animation baseline, roles, feedback, and pathing.
- A starter product catalog that supports several days of play.
- A backroom that functions as physical receiving, storage, management, service, and optional hidden-thread space.
- Economy, reputation, progression, and upgrades strong enough to create player decisions.
- Audio, VFX, and camera feedback for common actions.
- Save/load, settings, pause/main menu, and exported-build smoke validation.
- Updated automated tests, screenshot artifacts, and manual validation docs.
- Each completed slice committed and pushed.

Human approval still requires the owner screenshot pass described in `16-playability-readability-recovery-plan.md`, the stockroom screenshot review described in `17-stockroom-production-plan.md` if that phase is implemented before handoff, and the external playtest/manual window pass described in `15-alpha-playtest-package.md`.
