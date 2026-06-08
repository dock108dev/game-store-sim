# Validation Strategy

## Required Local Gate

Run this from the repository root before finishing any implementation:

```text
scripts/validate_godot.sh
```

The gate writes logs, GUT results, and screenshots to `artifacts/validation/latest/`. That directory is ignored by Git.

The default Godot binary is `/Applications/Godot.app/Contents/MacOS/Godot`. Use `GODOT_BIN=/path/to/Godot scripts/validate_godot.sh` to override it.

## Automated Checks

The gate currently runs:

- `git diff --check` and `git diff --cached --check` for first-party files.
- Godot editor import/load in headless mode.
- Godot runtime quit smoke in headless mode.
- Godot main-scene boot smoke in headless mode.
- GUT tests under `game/tests/gut/`, with JUnit XML exported to `artifacts/validation/latest/gut-results.xml`.
- UI scenario automation coverage from modular scenario files under `game/tests/validation/scenarios/`.
- Production-script test mapping coverage from `game/tests/validation/script_coverage/production_scripts.json`.
- Standalone validation tool manifest coverage from `game/tests/validation/tool_checks/`.
- Standalone product catalog content checks through `scripts/check_product_catalog.py`.
- Product catalog validation for fictional names, unique IDs, pricing sanity, complete inventory schema fields, multi-day starter content depth, and category/platform/condition/format/demand/authenticity/rarity/risk/location variety.
- Codec-level save/load smoke tests for session state, transactions, and active inventory.
- Named validation screenshot capture at `1280x720` for main scene, carry stack, receiving area, supplier message, suspicious customer, register counter, customer queue, trade-in offer, preorder deposit, service request, backroom summary, release calendar, release allocation, launch day, supplier delivery, fixture ghost preview, invalid fixture ghost preview, rotated fixture ghost preview, and placed fixture.
- Screenshot dimension and nonblank pixel checks for each named screenshot.
- Old project-name scan outside ignored/generated paths.

## Coverage Policy

Two local thresholds are mandatory:

- UI scenario automation coverage must be at least 80% of active validation scenarios.
- Production GDScript test mapping coverage must be at least 80%.

Critical smoke scenarios must be automated regardless of percentage. This includes main-scene boot, player spawn, floor collision, inspect prompt, and screenshot capture.

Script coverage is measured as tested-script mapping, not true line coverage. Godot does not provide a built-in game GDScript line coverage gate here. If a stable GDScript line/function coverage tool is added later, this policy can be upgraded.

Current hidden-thread baseline:

- `scripts/validate_godot.sh` passes with 428 GUT tests.
- UI scenario automation coverage is 416/509, above the 80% threshold.
- Production script mapping coverage is 41/41.
- New critical production-polish scenarios added in this pass are automated; remaining manual scenarios are intentionally human visual/controller checks.
- Product inventory schema now includes category, platform family, format, condition, completeness, authenticity, rarity, demand, cost, market value, risk, and default location metadata.
- Product visual rules cover case, disc, cartridge, accessory, console, controller, box, sealed, loose, and service-ticket variants, with product items applying generated cue meshes from data.
- Starter product catalog includes 33 fictional products across used games, new games, accessories, hardware, and service tickets, with 30 sellable physical products for several days of rotation.
- Product condition/authenticity cues show scratches, missing manual, loose media, damaged label, reseal, and suspicious serial-risk markers through generated product-item meshes.
- Product shelf/price tags show compact category, platform, price, sale, preorder, staff-pick, and bargain text without replacing core interaction prompts.
- `scripts/check_product_catalog.py` validates product IDs, fictional names, required schema fields, category coverage, pricing sanity, sellable depth, and visual variant coverage as part of the local gate.
- `game/tests/validation/tool_checks/product_catalog.json` declares the product catalog standalone checker as an active validation tool and keeps its command, covered paths, and requirements auditable.
- Store sessions expose production day structure phases for opening, setup, customer hours, closing, report, and tomorrow planning; daily reports and save/load preserve the current phase.
- Daily cash pressure posts rent/utility operating expenses once at close, reports reserved obligations separately from gross profit, and keeps supplier terms/payroll/repairs/shrinkage visible as expandable pressure hooks.
- Reputation events track pricing fairness, wait time, preorder outcomes, service outcomes, return handling, suspicious choices, stock variety, and launch shortage consequences with clamped score changes and save/load coverage.
- Demand tuning connects shelf visibility, price pressure, rarity, marketing, day events, and customer archetypes while preserving default category/tier customer-price behavior.
- Upgrade path coverage verifies fixture, category, service-tool, computer-tool, signage, storage, and starter-expansion goals; purchase rules; the storage prerequisite for expansion; backroom summary text; and save/load persistence.
- Owner onboarding coverage verifies the receiving, pricing, stocking, checkout, trade-in, backroom computer, ordering, and closing checklist; state-derived progress; and backroom dashboard presentation.
- Economy progression sync verifies cross-flow day phase, close pressure, next-day setup, decision feedback, goals, and manual playtest coverage through Stop 7.7.
- Receiving workflow coverage verifies supplier delivery creates pending receiving batches with delivery point, sealed/opened box state, invoice check, expected/received count variance, sorting destination, completed status, backroom controls, and save/load persistence.
- Storage workflow coverage verifies receiving-to-backstock movement, backstock retrieval, shelf capacity, overflow summary, Store/Pull backroom controls, movement history, and save/load persistence.
- Service bench workflow coverage verifies service capabilities, repair tickets, parts, queued/in-progress/ready/picked-up state, Start Svc/Work Svc backroom controls, register pickup integration, and save/load persistence.
- Management desk workflow coverage verifies supplier-message review, bill review, inventory search, report review, preorder planning, upgrade ordering, Review Desk/Buy Upg controls, and save/load persistence.
- Security/safe placeholder coverage verifies cash safe, high-value storage, suspicious goods isolation, security footage, placeholder recording, StoreSession/EvidenceStorage wiring, and Records tab readout without active hidden-thread UI.
- Store-building coverage verifies expanded fixture catalog metadata, footprint-aware placement, category assignment, demand tuning effects, decoration catalog, backroom decoration application, clutter-budget limits, layout-effect summaries, fixture visibility, impulse fixtures, queue spacing, customer travel distance, theft-risk placeholder state, launch queue demand effects, starter expansion purchase/capacity/bounds, and fixture/decoration/expansion save-load persistence.
- Suspicion-rules coverage verifies the Stop 10.1 risk flag catalog, severity/score metadata, serial mismatch, suspicious supplier, cash buyer, impossible provenance, counterfeit goods, hidden storage, node evaluation for existing hidden-thread props, and event-log rule event creation without visible objectives.
- Hidden clue-surface coverage verifies invoices, supplier notes, serial lookup, supplier emails, customer comments, security clips, and backroom artifacts as available/waiting Records-tab surfaces without active hidden objectives.

## Manual Validation

Automated checks do not replace player-feel review. For the current graybox stage, manually validate:

- WASD movement feel.
- Mouse-look feel.
- Escape opens the settings panel, and closing settings returns to captured first-person mouse control.
- Settings sensitivity, invert look, and fullscreen/window controls are readable and understandable.
- Remappable input binding data lists core movement, interaction, and pause/settings actions.
- The completed interaction polish pass needs a manual repeated-workflow review across prompts, carry, placement, workstations, and settings.
- Pricing, trade-in, and backroom computer modal surfaces share readable production UI button, modal, list, stat, alert, disabled, and selected-state language.
- Register checkout uses a receipt-style panel with itemized sale, subtotal, tax, total, tender, change due, service line, preorder deposit line, return placeholder, and confirmation feedback.
- Trade-in appraisal shows condition, completeness, authenticity confidence, market value, demand, projected margin, cash/store-credit offer, counteroffer, and risk notes.
- Pricing shows cost basis, market price, current price, suggested range, demand, projected margin, apply-to-matching batch scope, and outcome warnings.
- Product visual variants for case, disc, cartridge, accessory, console, controller, box, sealed, loose, and service-ticket cues read clearly in receiving, hand, shelf, customer, and register contexts.
- Product condition and authenticity cues read clearly without overwhelming case, platform, price, and variant identity.
- Product shelf labels and price tags are readable without crowding pickup, stocking, pricing, customer-held, or register-review contexts.
- Backroom computer tabs split dashboard, inventory, ordering, releases, reports, services, storage, suppliers, settings, and records into readable task sections.
- Supplier ordering shows category, cart, cost, due day, delivery state, storage needs, and receiving expectations while keeping ordered stock physical.
- Daily report shows end-of-day cash, sales, trade-ins, services, preorders, launch activity, reputation, losses, bills, and tomorrow recommendations.
- UI accessibility floors enforce readable text size, contrast, focusable controls, and modal fit at the 1280x720 target.
- Menu, register, pricing, trade-in, backroom computer, supplier ordering, daily report, settings, accessibility, customer visual-kit, customer animation, customer pathing, customer feedback, customer archetype, customer dialogue, product content, day structure, cash pressure, reputation, demand-tuning, upgrade-path, owner-onboarding, economy-progression, receiving-workflow, storage-workflow, service-bench, management-desk, security-placeholder, backroom-operations, fixture-catalog, placement-UX, fixture-category, decoration-baseline, layout-effects, starter-expansion, building-validation, suspicion-rules, and clue-surface validation are synced through Stop 10.2.
- Upgrade path validation is synced through Stop 7.5; manual QA should confirm upgrade choices read as future work/progression goals rather than cash-only debug options.
- Owner onboarding validation is synced through Stop 7.6; manual QA should confirm the checklist teaches the first-day loop without feeling like debug tutorial text.
- Economy progression validation is synced through Stop 7.7; manual QA should run the Economy Progression Focus before treating the milestone as human-approved.
- Left click is the primary center-reticle interaction for pickup, stocking, held-item pricing, register work, and backroom computer use.
- Front door opening blocks the player from leaving the playable store until exits are implemented.
- Prompt readability in the actual game window.
- Prompt hierarchy readability in the actual game window, including action, subject, blocked, and feedback states.
- Center reticle readability in normal, blocked, and feedback states in the actual game window.
- Hover highlights for pickup items and shelf slots are readable without implying separate targets.
- Receiving box, display rack, register, and compact used-game visual placement.
- Display rack slots still behave like used-game slots after category assignment changes.
- Invalid stocking attempts give clear blocked feedback instead of silent failure.
- Stocking a valid item gives a clear landing confirmation.
- Held item stack stays visible without blocking normal navigation.
- Held item stack active focus, depth fan, scale falloff, and subtle motion feel natural while moving.
- Stocking one carried game leaves the remaining carried games visible and usable.
- Stocked game is visibly upright and intentional in the rack.
- Pricing panel text and controls are readable in the actual window.
- Pricing opens from the held used item, not a standalone pricing terminal.
- Apply-to-matching pricing option is readable and understandable when pricing a used item.
- Pricing panel opens with visible mouse focus and closes back into captured first-person control.
- The only current visible terminals are the register and the backroom computer.
- Pricing panel closes back into first-person mouse capture cleanly.
- Stocking `Star Trader` causes the buyer to wait at the register.
- Overpricing `Star Trader` above buyer tolerance leaves it on the rack and produces readable customer feedback.
- Stocking multiple `Star Trader` copies causes multiple buyers to queue in a clear lane without overlapping special register customers.
- Buyers visibly walk from browsing to the rack and then to the register without confusing clipping.
- Customer idle, walk, browse, pickup, queue, talk, payment, handoff, leave, and impatient placeholder poses read clearly.
- Customer spawn, item approach, buyer queue lane, and special-customer positions read naturally in the current layout.
- Customer browsing points, register approach, blocked-path recovery, and post-sale leaving behavior read naturally.
- Customer feedback bubbles for purchase intent, price refusal, trade-in, preorder, service, and suspicious cues are readable without cluttering the player view.
- Customer archetype data covers browser, target buyer, parent gift buyer, collector, trade-in seller, return customer, service customer, regular, and suspicious contact roles.
- Customer dialogue-flow data covers help requests, recommendations, trade-in pushback, complaints/returns, and hidden-thread probes.
- Register click prompt and sale completion message are readable.
- Trade-in seller and compact carried item are readable at the register and do not look detached from the seller.
- Customer torso, headwear, arms, legs, props, and role silhouettes read as stylized people rather than placeholder capsules.
- Trade-in register prompt and completion message are readable.
- Trade-in offer panel condition, demand, market, cash, store-credit, and accept/decline controls are readable.
- Trade-in appraisal opens with visible mouse focus, moves focus to close after a decision, and closes back into captured first-person control.
- Trade-in counteroffer `- $1` and `+ $1` controls are readable and update only the accepted cash offer amount.
- Backroom computer placement is readable and does not look like a second register.
- Backroom receiving, storage, management, service/paperwork, and movement zones are visually distinct.
- Receiving and storage props make delivered supplier stock read as physical inventory without crowding prompts or player movement.
- Backroom service bench, paperwork stack, disc mat, and management board support the existing service theme without implying a separate service terminal.
- Backroom summary opens after a sale and shows matching cash, revenue, cost, and profit.
- Closed-day report is readable and matches the played day.
- Backroom recent activity shows sale and trade-in entries with readable prices.
- Backroom category demand text remains readable and does not crowd the management panel.
- Backroom market drift text remains readable and makes clear how active inventory values are moving.
- Backroom inventory summary is readable and matches active receiving/shelf inventory.
- Backroom reorder suggestions are readable and reflect sales versus active inventory.
- Backroom release calendar is readable and shows fictional upcoming launch timing, wholesale cost, suggested price, allocation limit, and demand tier.
- Backroom `Commit Release` button is readable and reserves release-allocation cash clearly.
- Register preorder customer and fixed deposit flow are readable, and the deposit clearly does not count as a sale yet.
- Backroom preorder count and preorder-deposit total are readable after taking a preorder.
- Register service customer, service completion prompt, service completion message, backroom service totals, recent activity, and daily-report service totals are readable.
- Service completion reads as register work and does not imply a separate service terminal, sale, trade-in, preorder, or inventory item.
- Backroom service bench shows available, locked, and placeholder service capabilities, ticket parts, progress, ready-for-pickup state, and pickup instructions.
- Backroom `Start Svc` and `Work Svc` controls advance bench work without bypassing register customer completion.
- Backroom release allocation commitment is readable, reserves launch wholesale cash, and stays clearly separate from launch-day fulfillment.
- Starting launch day resolves `Neon Skyline` preorders first, sells surplus allocations to launch queue demand, and reports launch cash, launch profit, and reputation clearly.
- Underallocating for launch day produces a readable missed-demand/reputation consequence.
- Backroom `Order Lot` button is readable and reserves cash clearly.
- Pending receiving order shows due day and item count clearly.
- Starting the next day delivers the used-game starter lot into the receiving box and creates pending receiving work.
- Backroom receiving workflow shows delivery point, sealed/opened box state, unchecked/checked invoice state, expected count, received count, variance, sorting destination, and pending/completed state.
- Backroom `Open Box`, `Check Inv`, and `Sort` controls are readable and enable/disable in a sensible order for the pending receiving batch.
- Backroom storage workflow shows receiving-ready count, backstock count, shelf capacity, overflow, recent storage movement, and Store/Pull controls.
- Moving stock to backstock and pulling it back to receiving preserves item identity, inventory summary visibility, and save/load movement history.
- Delivered supplier games look intentionally placed and do not crowd the receiving box, display rack, trade-in seller, or customer flow.
- Backroom `Order Rack` and `Place Rack` controls show the game display rack option, cash reservation, and pending storage placement clearly.
- Backroom pending storage fixture `Left`, `Right`, `Fwd`, `Back`, `Rotate`, `Snap`, and `Cancel` controls are readable and fit the panel.
- Canceling a pending fixture clears the ghost and refunds reserved fixture cash.
- Ordered fixture ghost preview is visible, translucent, and reads as a pending storage placement rather than a finished rack.
- Fixture ghost valid and invalid states read clearly as green allowed and red blocked placement previews.
- Fixture ghost rotate and snap behavior feels predictable through the backroom placement controls.
- Decoration summary, `Apply Decor` action, applied-decoration text, and clutter budget fit the backroom computer and read as store-building choices that do not hide interactables.
- Layout-effect summary explains fixture visibility, impulse fixtures, queue space, travel distance, and theft-risk placeholder state as store-building outcomes rather than abstract debug values.
- Starter Store Expansion reads as a larger operational footprint with expanded storage capacity, wider placement bounds, and clearer customer queue/travel lanes after Backroom Storage Bay.
- Building validation is synced through Stop 9.7; manual QA should run Store Building Focus before treating Milestone 9 as human-approved.
- Placing a pending storage rack through the backroom computer reads as a deliberate confirmation step, creates a real rack, and clears pending storage placement.
- Suspicious event flags, supplier notes, and optional suspicious-customer conversations do not visibly interrupt normal store progression.
- Suspicion rule flags read as retail anomalies under normal inventory, supplier, customer, and storage play rather than active quest objectives.
- Hidden clue surfaces in Records read as optional invoices, notes, lookup, emails, comments, clips, and artifacts instead of a required quest list.
- Backroom summary panel closes back into first-person mouse capture cleanly.
- Backroom computer opens with visible mouse focus and closes back into captured first-person control.
- After checkout, the stocked game is gone from the rack and no longer available for inspection.
- Screenshot composition is useful, not merely nonblank.

Every implementation summary should say whether these were checked, skipped, or not relevant.

## Planning And Docs-Only Slices

Planning-only slices still need validation discipline:

- Run `git diff --check`.
- Run `scripts/validate_godot.sh` unless the slice is explicitly blocked by a local toolchain showstopper.
- Update `04-backlog.md` when the active phase changes.
- Update `07-current-manual-playtest.md` when the planning decision changes how future manual validation should be interpreted.
- Do not mark gameplay manual checks as performed when the slice only changed docs.

The game-completion plan in `11-game-completion-plan.md` is the active source of truth for moving from validated prototype to alpha production. Each implementation slice from that plan must keep automated validation, screenshot review, manual checklist updates, commit, and push in the same stop.

## Maintaining The Matrix

Update `game/tests/validation/` whenever a production script or player-facing validation scenario is added.

Scenario files are intentionally split by slice:

- `scenarios/core_smoke.json`: main scene, player, input, floor, and front-door boundary smoke checks.
- `scenarios/receiving_stocking.json`: receiving box, item state, pickup, bounded carry stack, hold, shelf slot category assignment, and stocking checks.
- `scenarios/pricing.json`: direct held-item pricing, apply-to-matching pricing, pricing panel, and fixed-price rejection checks.
- `scenarios/product_catalog.json`: fictional product catalog count, uniqueness, pricing sanity, complete inventory schema, multi-day starter depth, and variety checks.
- `scenarios/backroom_polish.json`: backroom zone anchors, receiving/storage props, and management/service prop existence checks.
- `scenarios/customer_sale.json`: customer manager, buyer movement, buyer path validation, buyer queue, price sensitivity/refusal, register checkout, and transaction ledger checks.
- `scenarios/customer_polish.json`: customer role prop, silhouette, and register-area spacing polish checks.
- `scenarios/store_visual_polish.json`: store material contrast, lighting layers, fictional signage, and nonblocking retail clutter checks.
- `scenarios/product_fixture_polish.json`: used-game case cue, product visual variant rules, generated cue meshes, condition/authenticity cues, shelf/price tags, rack category, carry stack, and receiving intake polish checks.
- `scenarios/economy.json`: category demand defaults, demand normalization, buyer price-limit wiring, market drift math, and backroom economy readout checks.
- `scenarios/trade_in.json`: trade-in seller, carried item, offer review panel, counteroffer controls, cash accept, store-credit accept, decline, receiving inventory, and tender accounting checks.
- `scenarios/day_summary.json`: store session cash/accounting totals, explicit daily report, store-credit trade-in activity, recent activity history, active inventory summary, reorder suggestions, backroom computer, and day summary panel checks.
- `scenarios/supplier_ordering.json`: supplier lot data, backroom supplier ordering, cash reservation, due-day delivery, receiving-box delivery, pending receiving batch state, box opening, invoice check, sorting completion, panel controls, and persistence coverage.
- `scenarios/release_calendar.json`: fictional new-release data, countdown text, sorted/upcoming filtering, and backroom release-calendar readout checks.
- `scenarios/preorder_deposit.json`: preorder customer, register deposit prompt, preorder ledger/session accounting, backroom summary, persistence, and screenshot coverage.
- `scenarios/services.json`: first service customer, disc resurfacing request, service bench ticket workflow, register service prompt/completion, ledger/session accounting, recent activity, daily report totals, save/load service tickets, and screenshot coverage.
- `scenarios/release_allocation.json`: release allocation commitment, allocation-limit enforcement, cash reservation, backroom readout, persistence, and screenshot coverage.
- `scenarios/launch_day.json`: launch-day preorder fulfillment, launch queue fulfillment, reputation shortage, backroom readout, persistence, and save/restore coverage.
- `scenarios/hidden_thread.json`: hidden suspicious event log existence, flag recording, deduplication, input normalization, optional mismatched serial checks, optional supplier message checks, optional suspicious customer checks, optional evidence storage checks, suspicion rule catalog checks, metadata evaluation, node evaluation, rule-to-event logging, hidden clue-surface catalog coverage, store-context readiness, and Records-tab readout.
- `scenarios/persistence.json`: codec-level session, ledger, active inventory, and JSON roundtrip checks.
- `scenarios/store_layout.json`: expanded fixture catalog, fixture metadata, upgrade-gated fixture orders, fixture ordering, slot-category metadata, category assignment, demand tuning effects, decoration catalog, decoration application, clutter-budget limits, layout-effect demand signal, fixture visibility, impulse fixtures, queue spacing, travel distance, theft-risk placeholder state, launch queue demand effects, starter expansion purchase/capacity/bounds/persistence, cash reservation, pending storage placement, ghost preview, footprint-aware bounds, critical-path clearance, overlap rejection, valid/invalid placement state, move/rotate/snap/undo controls, placement confirmation, receiving/backstock movement, storage retrieval, insufficient-cash rejection, and persistence coverage.
- `scenarios/screenshots.json`: named screenshot capture and image sanity checks.
- `scenarios/manual_checks.json`: manual-only checks with owner and reason.

Script test mappings live in `script_coverage/production_scripts.json`, standalone tool manifests live in `tool_checks/*.json`, and thresholds live in `thresholds.json`.
Standalone non-Godot validation tools live under `scripts/`; `scripts/check_product_catalog.py` is run by `scripts/validate_godot.sh` after scenario coverage and before screenshot capture.

Use these statuses:

- `automated`: covered by GUT, a validation script, or the local gate.
- `manual`: intentionally human-checked, with `reason` and `owner`.
- `not_applicable`: retained for historical context but excluded from active coverage.

Any new critical scenario must be automated before the gate is allowed to pass.
