# Backlog

This backlog is the active production view. The historical first-playable checklist remains in `01-vertical-slice-plan.md`.

## Current Phase

Game completion planning and alpha production setup.

Goal: turn the validated prototype into a production-directed game build without losing the protected retail loop.

Status: the prototype and first polish pass are validated, but the June 7 screenshot review shows the game still reads as a graybox. The active work is now the completion plan that defines how to move from validated prototype to alpha-quality game; economy/day-loop progression is synced through Milestone 7, backroom operations are complete through Milestone 8, store building, decoration, layout effects, and starter expansion are complete through Milestone 9, the hidden-thread production arc is complete through Milestone 10, audio, VFX, and presentation feel are complete through Milestone 11, save/load/settings/release-wrapper work is complete through Milestone 12, and Alpha hardening is complete through Stop 13.7.

Historical polish roadmap: `08-polish-roadmap.md`.

Completed polish implementation plan: `10-polish-execution-plan.md`.

Current completion plan: `11-game-completion-plan.md`.

## Current Rules

- Keep the game shippable after every slice.
- Update `07-current-manual-playtest.md` and `game/tests/validation/scenarios/manual_checks.json` whenever a slice changes visual, UI, interaction, or manual validation expectations.
- Run `scripts/validate_godot.sh` before every commit.
- Commit and push each validated slice before starting another.
- Keep click-first prompts, center-reticle interaction, and mouse-capture behavior consistent.
- Keep the register focused on sales, returns, trade-ins, preorders, and services.
- Keep the backroom computer focused on management, ordering, reports, inventory, releases, and fixture/storage work.
- Do not add a standalone pricing terminal.
- Keep hidden-thread content optional and nonblocking until a deliberate escalation phase.

## Priority Backlog

1. Completion planning lock. Done in `11-game-completion-plan.md`.
2. Production direction and target slice. Done in `12-production-target-contracts.md`.
3. Store environment production pass.
4. Interaction and game-feel production pass.
5. Menu, register, and computer production UI.
6. Customer production pass.
7. Product and content pipeline.
8. Economy, day loop, and progression. Done through Milestone 7.
9. Backroom operations. Done through Milestone 8.
10. Store building, decoration, and expansion. Done through Milestone 9.
11. Hidden-thread production arc. Done through Milestone 10.
12. Audio, VFX, and presentation feel. Done through Milestone 11.
13. Save/load, settings, and release wrapper. Complete through Stop 12.6.
14. Alpha hardening. Complete through Stop 13.7; next checkpoint is human external playtest and feedback triage.

## Completed Polish Scope

The following polish items remain valid historical checkpoints:

1. Production polish planning reset. Done.
2. Backroom spatial and visual identity pass. Done.
3. Backroom computer/menu information architecture pass. Done.
4. Customer readability and role silhouette pass. Done.
5. Store lighting, materials, signage, and retail clutter pass. Done.
6. Product and fixture presentation pass. Done.
7. Validation/manual QA tightening for the full polish pass. Done.

## Backroom Polish

- Done: made the backroom visually distinct from the sales floor with explicit zone anchors.
- Done: separated receiving, storage, management, service/repair, paperwork, and optional hidden-thread cues.
- Done: added receiving pallet, box stacks, storage shelf, management board, service bench, disc mat, paperwork, and tool tray as graybox identity props.
- Done: kept supplier-delivered stock placement readable as physical receiving, not UI inventory teleporting.
- Done: kept storage fixture ordering and placement readable as a backroom/operations workflow.
- Done: kept the backroom computer readable as a management terminal, not another register.
- Done: added a receiving workflow state for supplier deliveries with delivery point, sealed/opened box state, invoice check, sorting destination, pending/completed status, backroom controls, save/load coverage, and manual validation coverage.
- Done: added storage workflow state for receiving-to-backstock movement, backstock retrieval, shelf capacity, overflow summary, Store/Pull backroom controls, movement history, save/load coverage, and manual validation coverage.
- Done: added service bench workflow state for disc resurfacing tickets, locked/placeholder future services, parts, queued/in-progress/ready/picked-up progress, Start Job/Work Job controls, register pickup integration, save/load coverage, and manual validation coverage.
- Done: added management desk workflow state for supplier-message review, bills, inventory search, report review, preorder planning, upgrade ordering, Review Desk/Upgrade controls, save/load coverage, and manual validation coverage.
- Done: added security/safe placeholder state for cash safe, high-value storage, suspicious goods isolation, security footage, Records tab readout, StoreSession/EvidenceStorage wiring, and manual validation coverage.
- Done: synced the backroom operations validation snapshot, scenario matrix, manual checks, and milestone status after the Stop 8 pass.

## Computer And Menu Polish

- Done: split the backroom computer into dashboard, activity, inventory, market, releases, and operations sections.
- Done: grouped actions as Supplier, Storage, Release, Day, and Storage Placement controls.
- Done: shortened button labels while keeping grouped context clear.
- Done: preserved current accounting and session behavior while changing presentation.
- Remaining polish risk: dense text still uses the same source strings and can be improved further during later menu polish if tabs become necessary.

## Customer Polish

- Done: improved customer role readability with distinct colors and role props.
- Done: added buyer shopping basket, trade-in tag/item, preorder slip, service disc/ticket, and suspicious note/cash cues.
- Done: improved register-area special customer spacing into a readable arc away from the buyer queue lane.
- Done: kept customers mechanically separated from hidden-thread infrastructure unless explicitly engaged.
- Remaining polish risk: customer prompt and feedback copy can still be refined in a future copy pass.

## Store Visual Polish

- Done: established a warmer specialty-store lighting pass with separate sales/register and backroom light layers.
- Done: added readable fictional `SAVE POINT GAMES` identity signage plus register, backroom, receiving, storage, and display rack labels.
- Done: improved wall/floor/counter material contrast while preserving sales-floor/backroom zoning.
- Done: added controlled retail clutter: posters, price sign, bargain bin, queue mat, and controller display props.
- Done: kept clutter noninteractive and away from interaction hotspots, shelf slots, prompts, and navigation-critical spaces.
- Remaining polish risk: human screenshot review should confirm the new signs and clutter compose well from normal player camera angles.

## Store Building And Expansion

- Done: expanded the fixture catalog with wall shelf, accessory peg wall, bargain bin, locked case, counter rack, demo kiosk placeholder, new-release wall, and backroom rack entries.
- Done: added fixture metadata for slot count, accepted product categories, placement zone, gameplay tags, upgrade locks, placeholder status, and catalog summaries.
- Done: kept the existing starter rack order/place flow intact while exposing locked future fixtures as planning options.
- Done: improved placement UX with footprint-aware bounds, critical-path clearance anchors, overlap rejection against placed fixtures, adjustment undo, placement issue text, and compact Undo controls.
- Done: added fixture category assignment with `Assign Cat` storage control, supported-category validation, placed fixture slot updates, category assignment summaries, and demand tuning effects for assigned shelf slots.
- Done: added a decoration system baseline with wall paint, floor material, posters, signage, lights, display props, a safe clutter budget, backroom `Apply Decor` action, save/load coverage, and manual readability checks.
- Done: added layout effects for fixture visibility, impulse fixtures, queue spacing, customer travel distance, theft-risk placeholder state, demand tuning, launch queue demand, and main-scene CustomerManager wiring.
- Done: added a starter expansion baseline that unlocks after Backroom Storage Bay, increases storage capacity, widens placement bounds, expands customer playable/queue bounds, updates upgrade/storage summaries, and persists through save/restore.
- Done: synced the final building validation snapshot, scenario matrix, manual checks, backlog state, and Milestone 9 status after the Stop 9 pass.
- Remaining polish risk: the next production milestone is hidden-thread production; store-building art-visible remodel depth remains later expansion work beyond this baseline.

## Hidden Thread Production

- Done: added a data-first suspicion rules catalog for serial mismatch, suspicious supplier, cash buyer, impossible provenance, counterfeit goods, and hidden storage.
- Done: added metadata and existing-node evaluation for product items, supplier messages, and suspicious customers without creating visible objectives.
- Done: added event-log rule event creation so later clue surfaces and choices can reuse the same flagged anomaly data.
- Done: added hidden clue surfaces for receiving invoices, supplier notes, serial lookup, supplier emails, customer comments, security clips, and backroom artifacts.
- Done: surfaced available/waiting clue status in the backroom Records tab without activating hidden-thread objectives.
- Done: added hidden choice paths for ignore, document, sell-as-normal, isolate, report, accept-cash, reject-goods, and supplier follow-up.
- Done: StoreSession records/deduplicates hidden choices, Records shows available paths and recorded choices, and save/load preserves recorded choices.
- Done: added hidden consequences for reputation, cash, supplier access, customer trust, inspection risk, and story state.
- Done: StoreSession applies hidden consequences once per recorded choice, Records shows consequence summaries, and save/load preserves consequence events and hidden state scores.
- Done: added an optionality guard that explicitly says hidden-thread progression is not required, the retail loop is not blocked, and normal work remains available.
- Done: added a validation-sync GUT audit proving the scenario matrix and manual checklist cover flags, dedupe, persistence, optionality, and manual clue readability.
- Done: synced hidden-thread scenario coverage, manual Hidden Thread Focus checks, validation baselines, backlog state, and Milestone 10 status for Stop 10.6.
- Remaining polish risk: the next production milestone is audio, VFX, and presentation feel.

## Audio, VFX, And Presentation Feel

- Done: added a store ambience baseline catalog for room tone, HVAC, street muffle, door chime, register area ambience, backroom ambience, and closing quiet.
- Done: wired conservative placeholder AudioStreamPlayer3D nodes into the main scene under `StoreAmbience`.
- Done: synced presentation scenario coverage, script mapping, validation baselines, and manual ambience readability checks for Stop 11.1.
- Done: added an interaction audio cue catalog and player-controller wiring for pickup, place, stock, scan, register, cash drawer, computer clicks, UI buttons, box open, shelf bump, and errors.
- Done: synced presentation scenario coverage, script mapping, validation baselines, and manual interaction-audio readability checks for Stop 11.2.
- Done: added customer audio placeholder profiles for buyer, trade-in, preorder, service, and suspicious customers, covering footstep, mumble, greeting, approval, annoyance, and leaving cues.
- Done: synced presentation scenario coverage, script mapping, validation baselines, and manual customer-audio readability checks for Stop 11.3.
- Done: added presentation microfeedback placeholders for target highlights, item settle, sale confirmation, cash/reputation ticks, day transition, delivery arrival, and invalid actions.
- Done: synced presentation scenario coverage, script mapping, validation baselines, and manual microfeedback readability checks for Stop 11.4.
- Done: tuned camera feel for subtle movement bob, held-item sway, workstation/modal settling, comfort FOV bounds, and motion comfort.
- Done: synced presentation scenario coverage, validation baselines, and manual camera-feel readability checks for Stop 11.5.
- Done: synced presentation validation coverage, validation baselines, manual milestone review checks, and production docs for Stop 11.6.
- Remaining polish risk: the next production milestone is save/load, settings, and release wrapper.

## Save, Load, Settings, And Release Wrapper

- Done: added file-backed save slot registry with new game slot creation, continue data, overwrite/delete behavior, and save metadata.
- Done: added save slot panel with New Game, Continue, Overwrite, Delete, slot list, metadata readout, modal focus, mouse capture transition, and player-controller wiring.
- Done: synced persistence scenario coverage, script mapping, validation baselines, and manual save-slot UI readability checks for Stop 12.1.
- Done: added save versioning, schema ID, version 1 migration defaults, migration history, future-version rejection, malformed-save failure state, and migration/failure validation coverage for Stop 12.2.
- Done: expanded the settings menu with audio, display, controls, mouse, accessibility, reset bindings, reset defaults, file-backed settings persistence, player preference application, and manual validation coverage for Stop 12.3.
- Done: added pause/main-menu panel support with Resume, Start Game, Settings, Save/Load, Main Menu, Quit request state, pause/main menu modes, and safe mouse capture transitions for Stop 12.4.
- Done: added the macOS desktop export preset, local pack export/boot smoke verifier, validation tool manifest, gate integration, and manual release-wrapper checks for Stop 12.5.
- Done: synced release-wrapper validation coverage, docs coverage, desktop export tool manifest audit, pack-smoke handoff, binary-template fallback, and manual build save/load review checklist for Stop 12.6.
- Remaining polish risk: the next production milestone is alpha hardening.

## Alpha Hardening

- Done: created `13-alpha-bug-list.md` from the latest full gate, screenshot artifacts, current manual validation checklist, and release-wrapper limits for Stop 13.1.
- Current P1 alpha risks: store still reads graybox, signage clips/loses hierarchy, customer roles remain placeholder-heavy, register queue composition is crowded, placed fixture framing can block the camera, and backroom computer screens are dense.
- Done: added `scripts/measure_alpha_performance.sh`, the Godot performance metric collector, validation tool manifest, gate integration, and `14-alpha-performance-baseline.md` for Stop 13.2.
- Current alpha performance baseline: main scene resource load 141 ms, instantiate 23 ms, 60-frame step 413 ms, UI panel cycle 43 ms, customer pathing 4 ms, screenshot capture 930 ms, and exported pack startup 413 ms.
- Done: added regression coverage for rotated fixture placement bounds/history, visible buyer queue spacing against special register customers, and screenshot scenario coverage for current P1/P2 alpha bug subjects for Stop 13.3.
- Done: added a Stop 13.4A alpha scene-readability pass for wall detail, sign framing, special-customer spacing, display-rack profile cues, placed-fixture screenshot framing, and backroom computer first-view controls.
- Done: added a Stop 13.4B alpha content/copy pass for customer role copy, dialogue staff context, supplier order notes, release planning hooks, daily report readouts, register return-scope copy, and backroom action labels.
- Done: added `15-alpha-playtest-package.md`, an alpha package scenario matrix, manual package checks, and validation-sync coverage for Stop 13.6.
- Done: synced alpha validation docs, scenario matrix, manual checklist, bug list, backlog state, and full-gate evidence for Stop 13.7.
- Remaining alpha-hardening work: human external playtest and feedback triage before implementing post-alpha follow-up.

## Product And Fixture Polish

- Done: made used-game cases more intentional with spine, platform, and price-sticker cues.
- Done: kept products compact enough for rack, carry stack, and customer carry.
- Done: added clearer display-rack category header and slot rails.
- Done: added receiving-box intake lanes and label to make intake placement read as organized physical inventory.
- Done: tuned carried item stack fanning so multiple held cases stay visible without blocking the center view.
- Done: added data-driven product visual rules for case, disc, cartridge, accessory, console, controller, box, sealed, loose, and service-ticket cue variants.
- Done: expanded the starter product catalog to 33 fictional products across used games, new games, accessories, hardware, and service tickets.
- Done: added generated condition/authenticity cues for scratches, missing manual, loose media, damaged labels, reseals, and serial risk.
- Done: added generated product label/price tag text for category, platform, price, sale, preorder, staff-pick, and bargain cues.
- Done: added standalone product catalog content validation for IDs, fictional names, required fields, category coverage, pricing sanity, sellable depth, and visual variant coverage.
- Done: synced the product/content pipeline validation manifest, manual review checklist, and milestone status after the Stop 6 pass.
- Remaining polish risk: fixture ghost/placed fixture state can still get a dedicated art pass later, but the current automated checks preserve valid/invalid ghost distinction and placed-rack behavior.

## Completed First-Playable Scope

Compressed summary of completed validated systems:

- First-person movement, click-first interaction, prompt, and reticle.
- Receiving pickup, multi-item carry, held-item pricing, shelf stocking, and apply-to-matching pricing.
- Product catalog, fictional product validation, multi-day starter product depth, item identity, category, platform family, format, price, cost basis, condition, completeness, authenticity, rarity, demand, market value, risk, default location, data-driven visual variant profile, generated condition/authenticity cue meshes, shelf/price tag text, serial metadata, and active inventory summary.
- Buyer customer manager, buyer movement, price sensitivity, lower-priced copy selection, register queue, sale completion, and transaction ledger.
- Trade-in seller, offer panel, cash/store-credit acceptance, counteroffer adjustment, decline, and acquired inventory.
- Service customer and register-completed service accounting.
- Service bench ticket preparation with register-completed customer pickup/accounting.
- Management desk reviews for supplier messages, bills, inventory search, report review, preorder planning, and upgrade ordering.
- Security/safe placeholders for cash storage, high-value storage, suspicious goods isolation, and security footage without activating a hidden-thread objective.
- Backroom computer summaries, daily report, recent activity, reorder suggestions, demand readout, market drift, supplier ordering, release calendar, allocation commitment, launch-day resolution, and fixture controls.
- Fixture ordering, ghost preview, valid/invalid state, movement, rotation, snap, placement confirmation, and save-smoke coverage.
- Supplier orders with due-day receiving-box delivery, pending receiving workflow, and backstock storage/retrieval for delivered inventory.
- Preorder deposit and launch-day fulfillment/reputation outcome.
- Hidden event log, mismatched serial item, supplier message, optional suspicious customer, and hidden evidence storage.
- Mandatory validation gate, product content checker, validation tool manifest, GUT tests, validation scenario matrix, script mapping, persistence smoke, and named screenshots.

## Economy, Day Loop, And Progression

- Done: added production day structure phases for opening, setup, customer hours, closing, report, and tomorrow planning, with daily report, save/load, and validation coverage.
- Done: added daily cash pressure with rent reserve, utilities/bills, prepaid supplier terms, payroll/repairs/shrinkage placeholders, reserved-obligation summaries, daily report accounting, save/load, and validation coverage.
- Done: added reputation baseline events for pricing fairness, wait times, fulfilled/missed preorders, service success/failure, return handling, suspicious choices, stock variety, launch shortage integration, daily reports, save/load, and validation coverage.
- Done: added contextual demand tuning for shelf visibility, price pressure, rarity, marketing, day events, and customer archetype signals, with active-inventory backroom summaries and validation coverage.
- Done: added a baseline upgrade path for fixtures, category unlocks, service tools, computer tools, signage, storage, and starter expansion, with purchase rules, expansion prerequisite, backroom summary, save/load, and validation coverage.
- Done: added owner onboarding checklist coverage for receiving, pricing, stocking, checkout, trade-ins, backroom computer, ordering, and closing, with dashboard presentation and validation coverage.
- Done: synced economy/progression validation across day structure, cash pressure, reputation, demand, upgrades, onboarding, manual playtest, and milestone docs.

## Not Current Scope

These remain future phases unless explicitly selected:

- Theft and shrinkage systems.
- Returns and exchanges.
- Final product art beyond the current generated cue-mesh variants.
- Stocking fixtures for every expanded starter category beyond the current used-game display rack.
- Player-facing save/load slot UI.
- Employees and staff assignment.
- Larger store expansion.
- Later expansion depth beyond the current starter expansion baseline, such as art-visible remodels, construction timing, and multi-room shop growth.
- Complex hidden-thread consequences.
- Full audio, animation, VFX, and art-production pass.
