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
- Stop 2.4: Shelf and fixture kit. Create reusable production-intent shelves, display racks, bargain bins, locked case placeholders, peg walls, and category labels.
- Stop 2.5: Backroom production blockout. Rebuild receiving, storage, computer desk, service bench, paperwork, safe/security placeholder, and hidden clue surfaces as one coherent operations room.
- Stop 2.6: Lighting and postprocess. Establish warm retail lighting, cooler backroom lighting, readable prompt contrast, and screenshot-safe exposure.
- Stop 2.7: Collision and navigation. Ensure props do not block core paths, queue lanes, stocking, receiving, fixture placement, or screenshot capture.
- Stop 2.8: Environment validation sync. Add or update automated scene assertions and manual screenshot checks.

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

- Stop 3.1: Reticle and prompt hierarchy. Replace placeholder prompts with a consistent visual system for inspect, pickup, place, price, stock, register, computer, talk, and blocked actions.
- Stop 3.2: Held item presentation. Improve carry pose, stack spacing, item bob/settle, hand-space framing, and item-specific held silhouettes.
- Stop 3.3: Pickup/place feedback. Add hover highlights, target confirmation, invalid feedback, item landing feedback, and clear failure messages.
- Stop 3.4: Workstation transitions. Make pricing, register, appraisal, computer, and summary panels enter/exit cleanly with mouse capture and focus rules.
- Stop 3.5: Fixture placement feel. Improve ghost controls, rotation, snap, valid/invalid presentation, placement confirmation, and cancel path.
- Stop 3.6: Input/settings baseline. Add remappable input data, mouse sensitivity, invert look, fullscreen/window controls, and pause/settings access.
- Stop 3.7: Interaction validation sync. Update automation and manual checks for all changed input flows.

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

- Stop 4.1: UI component language. Establish reusable button, tab, list, stat, receipt, modal, tooltip, alert, disabled, and selected states.
- Stop 4.2: Register checkout UI. Add itemized cart, subtotal/tax/total, tender method, change due, sale confirmation, service line, preorder deposit line, return placeholder, and transaction feedback.
- Stop 4.3: Trade-in appraisal UI. Add condition, completeness, authenticity confidence, market value, demand, margin, cash/store-credit offer, counteroffer, and risk notes.
- Stop 4.4: Pricing UI. Add cost basis, market price, current price, suggested range, margin, demand, apply-to-matching, and price outcome warnings.
- Stop 4.5: Backroom computer tabs. Split dashboard, inventory, ordering, releases, reports, services, storage, suppliers, settings, and optional hidden records.
- Stop 4.6: Supplier ordering UI. Add categories, due days, cart, cost, delivery state, storage requirements, and receiving expectations.
- Stop 4.7: Daily report UI. Add end-of-day summary, cash, sales, trade-ins, services, preorders, launch activity, reputation, losses, bills, and tomorrow recommendations.
- Stop 4.8: UI accessibility pass. Validate text size, contrast, keyboard/mouse focus, panel fit, and 1280x720 readability.
- Stop 4.9: UI validation sync. Update scenario coverage and manual checklist.

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

- Stop 5.1: Customer visual kit. Create a modular stylized customer body set with readable heads, clothing palettes, carried props, and role-specific silhouettes.
- Stop 5.2: Animation baseline. Add idle, walk, browse, pick up, queue, talk, pay, hand-over-item, leave-happy, leave-annoyed, and wait-impatient animations or animation placeholders.
- Stop 5.3: Queue and browsing behavior. Improve pathing, browse points, queue lane, register approach, blocked-path recovery, and leave behavior.
- Stop 5.4: Customer feedback. Add speech bubbles or compact world/UI feedback for price refusal, purchase intent, impatience, trade-in response, preorder confirmation, service pickup, and suspicion cues.
- Stop 5.5: Archetype data. Add browser, target buyer, parent gift buyer, collector, trade-in seller, return customer, service customer, regular, and suspicious contact data.
- Stop 5.6: Conversation baseline. Add simple dialogue flow for help requests, recommendations, trade-in pushback, complaints, and hidden-thread probes.
- Stop 5.7: Customer validation sync. Add automated role/path assertions and manual readability checks.

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

## Milestone 6: Product And Content Pipeline

Goal: make inventory scalable and visibly game-specific.

Stops:

- Stop 6.1: Inventory schema expansion. Extend product data for category, platform family, format, condition, completeness, authenticity, rarity, demand, cost, market value, risk, and location.
- Stop 6.2: Product visual generation rules. Create reusable case, disc, cartridge, accessory, console, controller, box, sealed, loose, and service-ticket variants.
- Stop 6.3: Starter catalog expansion. Add enough fictional products to support multiple days without repetition.
- Stop 6.4: Condition and authenticity cues. Add visible scratches, missing manual markers, loose media, damaged labels, resealed packaging, and suspicious serial markers.
- Stop 6.5: Shelf label and price tag system. Show category, platform, price, sale tags, preorder tags, staff pick tags, and bargain tags without cluttering interactions.
- Stop 6.6: Content validation tools. Add checks for unique IDs, fictional names, category coverage, pricing sanity, and visual variant coverage.
- Stop 6.7: Product pipeline validation sync. Update automation and manual content review.

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

## Milestone 7: Economy, Day Loop, And Progression

Goal: turn isolated systems into a game with pressure and forward motion.

Stops:

- Stop 7.1: Day structure. Define opening, setup, customer hours, closing, report, bills, deliveries, events, and tomorrow planning.
- Stop 7.2: Cash pressure. Add rent, bills, supplier terms, payroll placeholder, repairs, shrinkage placeholder, and reserve obligations.
- Stop 7.3: Reputation. Track pricing fairness, wait times, fulfilled preorders, service success, return handling, suspicious choices, and stock variety.
- Stop 7.4: Demand tuning. Connect shelf visibility, category demand, price, rarity, marketing, events, and customer archetypes.
- Stop 7.5: Upgrade path. Add unlocks for fixtures, categories, service tools, computer tools, signage, storage, and store expansion.
- Stop 7.6: Tutorial/onboarding. Teach receiving, pricing, stocking, checkout, trade-in, computer, ordering, and closing without visible debug explanations.
- Stop 7.7: Economy validation sync. Add scenario coverage for day-to-day outcomes and manual progression checks.

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

## Milestone 8: Backroom Operations

Goal: make the backroom a real physical workflow hub.

Stops:

- Stop 8.1: Receiving workflow. Add delivery points, box opening, invoice checks, sorting, and pending receiving state.
- Stop 8.2: Storage workflow. Add storage shelves, overflow, backstock retrieval, and stock movement between receiving, storage, shelf, and register.
- Stop 8.3: Service bench workflow. Add disc resurfacing, cartridge cleaning, console test placeholder, repair tickets, parts, completion, and customer pickup.
- Stop 8.4: Management desk workflow. Add supplier messages, bills, inventory search, report review, preorder planning, and upgrade ordering.
- Stop 8.5: Security/safe placeholders. Add cash storage, high-value storage, suspicious goods isolation, and security footage placeholder.
- Stop 8.6: Backroom validation sync. Update tests and manual checks for physical operations.

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

## Milestone 9: Store Building, Decoration, And Expansion

Goal: make store layout and personalization matter.

Stops:

- Stop 9.1: Fixture catalog. Add shelves, peg wall, bargain bin, locked case, counter rack, demo kiosk placeholder, new-release wall, and backroom rack.
- Stop 9.2: Placement UX. Improve ghost placement, rotate, snap, collision, path validation, affordability, cancel, undo, and confirmation.
- Stop 9.3: Category assignment. Let fixtures have categories and product slots that affect browsing and demand.
- Stop 9.4: Decoration system. Add wall paint, floor material, posters, signage, lights, display props, and clutter budget.
- Stop 9.5: Layout effects. Connect fixture visibility, queue space, theft risk placeholder, impulse buys, and travel distance to outcomes.
- Stop 9.6: Expansion baseline. Add one larger footprint or backroom expansion option after the starter store loop is proven.
- Stop 9.7: Building validation sync. Update automation and manual layout checks.

Acceptance:

- Rearranging the store changes play, not only appearance.
- Decoration improves tone without hiding interactables.
- Placement cannot create broken core paths.
- Expansion creates new operational choices.

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

- Stop 10.1: Suspicion rules. Define risk flags for serial mismatch, suspicious suppliers, cash buyers, impossible provenance, counterfeit goods, and hidden storage.
- Stop 10.2: Clue surfaces. Add invoices, notes, serial lookup, supplier emails, customer comments, security clips, and backroom artifacts.
- Stop 10.3: Choice points. Add ignore, document, sell, isolate, report, accept cash, reject goods, and follow-up paths.
- Stop 10.4: Consequences. Add reputation, cash, supplier access, customer trust, inspection risk, and story state consequences.
- Stop 10.5: Optionality guard. Ensure a normal retail player can ignore the thread without blocked progression.
- Stop 10.6: Hidden-thread validation sync. Add tests for flags, dedupe, persistence, optionality, and manual clue readability.

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

- Stop 11.1: Store ambience. Add room tone, HVAC, street muffling, door chime, register area ambience, backroom ambience, and closing quiet.
- Stop 11.2: Interaction sounds. Add pickup, place, stock, scan, register, cash drawer, computer click, button hover/click, box open, shelf bump, and error sounds.
- Stop 11.3: Customer audio placeholders. Add footstep, mumble, greeting, approval, annoyance, and leaving cues without committing to final voice.
- Stop 11.4: VFX and microfeedback. Add subtle highlights, item settle, sale confirmation, cash/reputation tick, day transition, delivery arrival, and invalid action feedback.
- Stop 11.5: Camera feel. Tune movement bob, held item sway, workstation transition, field of view, and motion comfort.
- Stop 11.6: Presentation validation sync. Add manual audio/feel checklist and automated asset/load checks where practical.

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

## Milestone 12: Save, Load, Settings, And Release Wrapper

Goal: make the game session durable and presentable outside the editor.

Stops:

- Stop 12.1: Save slot UI. Add new game, continue, save slot list, overwrite, delete, and save metadata.
- Stop 12.2: Save migration policy. Version save data and add migration/failure handling.
- Stop 12.3: Settings menu. Add audio, display, controls, mouse, accessibility, and reset defaults.
- Stop 12.4: Pause and main menu. Add pause state, resume, settings, quit, main menu, and safe mouse capture transitions.
- Stop 12.5: Build/export pipeline. Add desktop export settings and a local build verification script.
- Stop 12.6: Release validation sync. Add launch-from-build smoke, save/load smoke, and manual release checklist.

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

## Milestone 13: Alpha Hardening

Goal: stabilize a coherent alpha build.

Stops:

- Stop 13.1: Bug triage. Create an alpha bug list from automated failures, screenshot review, manual validation, and playtest notes.
- Stop 13.2: Performance pass. Profile scene load, frame time, UI panels, customer pathing, save/load, screenshots, and exported build startup.
- Stop 13.3: Test expansion. Add regression tests for critical bug fixes and high-risk systems.
- Stop 13.4: Content pass. Fill starter catalog, customer text, supplier orders, daily events, signs, and report copy to alpha quality.
- Stop 13.5: Balance pass. Tune prices, margins, buyer tolerance, demand, rent, bills, supplier delivery, launch allocations, services, and upgrade costs.
- Stop 13.6: External playtest package. Produce a build, playtest script, known-issues list, feedback form, and rollback plan.
- Stop 13.7: Alpha validation sync. Run the full gate, exported build smoke, and manual alpha checklist.

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

## Immediate Next Work After This Planning Slice

The next implementation phase should begin with Milestone 1, not with random art edits.

Priority order:

1. Stop 1.1: screenshot teardown board.
2. Stop 1.2: art direction contract.
3. Stop 1.3: store layout contract.
4. Stop 1.4: UI direction contract. Done.
5. Stop 1.5: content target contract. Done.
6. Stop 1.6: production acceptance checklist. Done.
7. Milestone 2 store environment production pass.

The reason to start with direction contracts is practical: the current screenshots show every surface needs work. Without a locked target, environment, customer, UI, and menu polish will fight each other and produce more intermediate graybox churn.

## Completion Definition

This phase is complete when the repo can produce an alpha-quality local desktop build with:

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
