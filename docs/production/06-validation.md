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
- Product catalog validation for fictional names, unique IDs, pricing sanity, and platform/condition/demand variety.
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

Current polish-pass baseline:

- `scripts/validate_godot.sh` passes with 288 GUT tests.
- UI scenario automation coverage is 291/346, above the required 80% threshold.
- Production script mapping coverage is 31/31.
- New critical production-polish scenarios added in this pass are automated; remaining manual scenarios are intentionally human visual/controller checks.

## Manual Validation

Automated checks do not replace player-feel review. For the current graybox stage, manually validate:

- WASD movement feel.
- Mouse-look feel.
- Escape releases mouse capture and mouse click recaptures it.
- Left click is the primary center-reticle interaction for pickup, stocking, held-item pricing, register work, and backroom computer use.
- Front door opening blocks the player from leaving the playable store until exits are implemented.
- Prompt readability in the actual game window.
- Center reticle readability in the actual game window.
- Receiving box, display rack, register, and compact used-game visual placement.
- Display rack slots still behave like used-game slots after category assignment changes.
- Held item stack stays visible without blocking normal navigation.
- Stocking one carried game leaves the remaining carried games visible and usable.
- Stocked game is visibly upright and intentional in the rack.
- Pricing panel text and controls are readable in the actual window.
- Pricing opens from the held used item, not a standalone pricing terminal.
- Apply-to-matching pricing option is readable and understandable when pricing a used item.
- The only current visible terminals are the register and the backroom computer.
- Pricing panel closes back into first-person mouse capture cleanly.
- Stocking `Star Trader` causes the buyer to wait at the register.
- Overpricing `Star Trader` above buyer tolerance leaves it on the rack and produces readable customer feedback.
- Stocking multiple `Star Trader` copies causes multiple buyers to queue in a clear lane without overlapping special register customers.
- Buyers visibly walk from browsing to the rack and then to the register without confusing clipping.
- Customer spawn, item approach, buyer queue lane, and special-customer positions read naturally in the current layout.
- Register click prompt and sale completion message are readable.
- Trade-in seller and compact carried item are readable at the register and do not look detached from the seller.
- Trade-in register prompt and completion message are readable.
- Trade-in offer panel condition, demand, market, cash, store-credit, and accept/decline controls are readable.
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
- Backroom release allocation commitment is readable, reserves launch wholesale cash, and stays clearly separate from launch-day fulfillment.
- Starting launch day resolves `Neon Skyline` preorders first, sells surplus allocations to launch queue demand, and reports launch cash, launch profit, and reputation clearly.
- Underallocating for launch day produces a readable missed-demand/reputation consequence.
- Backroom `Order Lot` button is readable and reserves cash clearly.
- Pending receiving order shows due day and item count clearly.
- Starting the next day delivers the used-game starter lot into the receiving box and clears pending receiving.
- Delivered supplier games look intentionally placed and do not crowd the receiving box, display rack, trade-in seller, or customer flow.
- Backroom `Order Rack` and `Place Rack` controls show the game display rack option, cash reservation, and pending storage placement clearly.
- Backroom pending storage fixture `Left`, `Right`, `Fwd`, `Back`, `Rotate`, and `Snap` controls are readable and fit the panel.
- Ordered fixture ghost preview is visible, translucent, and reads as a pending storage placement rather than a finished rack.
- Fixture ghost valid and invalid states read clearly as green allowed and red blocked placement previews.
- Fixture ghost rotate and snap behavior feels predictable through the backroom placement controls.
- Placing a pending storage rack through the backroom computer reads as a deliberate confirmation step, creates a real rack, and clears pending storage placement.
- Suspicious event flags, supplier notes, and optional suspicious-customer conversations do not visibly interrupt normal store progression.
- Backroom summary panel closes back into first-person mouse capture cleanly.
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
- `scenarios/product_catalog.json`: fictional product catalog count, uniqueness, pricing sanity, and variety checks.
- `scenarios/backroom_polish.json`: backroom zone anchors, receiving/storage props, and management/service prop existence checks.
- `scenarios/customer_sale.json`: customer manager, buyer movement, buyer path validation, buyer queue, price sensitivity/refusal, register checkout, and transaction ledger checks.
- `scenarios/customer_polish.json`: customer role prop, silhouette, and register-area spacing polish checks.
- `scenarios/store_visual_polish.json`: store material contrast, lighting layers, fictional signage, and nonblocking retail clutter checks.
- `scenarios/product_fixture_polish.json`: used-game case cue, rack category, carry stack, and receiving intake polish checks.
- `scenarios/economy.json`: category demand defaults, demand normalization, buyer price-limit wiring, market drift math, and backroom economy readout checks.
- `scenarios/trade_in.json`: trade-in seller, carried item, offer review panel, counteroffer controls, cash accept, store-credit accept, decline, receiving inventory, and tender accounting checks.
- `scenarios/day_summary.json`: store session cash/accounting totals, explicit daily report, store-credit trade-in activity, recent activity history, active inventory summary, reorder suggestions, backroom computer, and day summary panel checks.
- `scenarios/supplier_ordering.json`: supplier lot data, backroom supplier ordering, cash reservation, due-day delivery, receiving-box delivery, panel state, and persistence coverage.
- `scenarios/release_calendar.json`: fictional new-release data, countdown text, sorted/upcoming filtering, and backroom release-calendar readout checks.
- `scenarios/preorder_deposit.json`: preorder customer, register deposit prompt, preorder ledger/session accounting, backroom summary, persistence, and screenshot coverage.
- `scenarios/services.json`: first service customer, disc resurfacing request, register service prompt/completion, ledger/session accounting, recent activity, daily report totals, and screenshot coverage.
- `scenarios/release_allocation.json`: release allocation commitment, allocation-limit enforcement, cash reservation, backroom readout, persistence, and screenshot coverage.
- `scenarios/launch_day.json`: launch-day preorder fulfillment, launch queue fulfillment, reputation shortage, backroom readout, persistence, and save/restore coverage.
- `scenarios/hidden_thread.json`: hidden suspicious event log existence, flag recording, deduplication, input normalization, optional mismatched serial checks, optional supplier message checks, optional suspicious customer checks, and optional evidence storage checks.
- `scenarios/persistence.json`: codec-level session, ledger, active inventory, and JSON roundtrip checks.
- `scenarios/store_layout.json`: fixture catalog, fixture ordering, slot-category metadata, cash reservation, pending storage placement, ghost preview, valid/invalid placement state, rotate/snap controls, placement confirmation, insufficient-cash rejection, and persistence coverage.
- `scenarios/screenshots.json`: named screenshot capture and image sanity checks.
- `scenarios/manual_checks.json`: manual-only checks with owner and reason.

Script test mappings live in `script_coverage/production_scripts.json`, and thresholds live in `thresholds.json`.

Use these statuses:

- `automated`: covered by GUT, a validation script, or the local gate.
- `manual`: intentionally human-checked, with `reason` and `owner`.
- `not_applicable`: retained for historical context but excluded from active coverage.

Any new critical scenario must be automated before the gate is allowed to pass.
