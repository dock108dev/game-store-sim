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
- Named validation screenshot capture at `1280x720` for main scene, receiving area, register counter, customer queue, trade-in offer, backroom summary, fixture ghost preview, invalid fixture ghost preview, and rotated fixture ghost preview.
- Screenshot dimension and nonblank pixel checks for each named screenshot.
- Old project-name scan outside ignored/generated paths.

## Coverage Policy

Two local thresholds are mandatory:

- UI scenario automation coverage must be at least 80% of active validation scenarios.
- Production GDScript test mapping coverage must be at least 80%.

Critical smoke scenarios must be automated regardless of percentage. This includes main-scene boot, player spawn, floor collision, inspect prompt, and screenshot capture.

Script coverage is measured as tested-script mapping, not true line coverage. Godot does not provide a built-in game GDScript line coverage gate here. If a stable GDScript line/function coverage tool is added later, this policy can be upgraded.

## Manual Validation

Automated checks do not replace player-feel review. For the current graybox stage, manually validate:

- WASD movement feel.
- Mouse-look feel.
- Escape releases mouse capture and mouse click recaptures it.
- Front door opening blocks the player from leaving the playable store until exits are implemented.
- Prompt readability in the actual game window.
- Receiving box, display rack, register, and used-game visual placement.
- Display rack slots still behave like used-game slots after category assignment changes.
- Held item stays visible without blocking normal navigation.
- Stocked game is visibly upright and intentional in the rack.
- Pricing panel text and controls are readable in the actual window.
- Pricing opens from the held used item, not a standalone pricing terminal.
- Apply-to-matching pricing option is readable and understandable when pricing a used item.
- The only current visible terminals are the register and the backroom computer.
- Pricing panel closes back into first-person mouse capture cleanly.
- Stocking `Star Trader` causes the buyer to wait at the register.
- Overpricing `Star Trader` above buyer tolerance leaves it on the rack and produces readable customer feedback.
- Stocking multiple `Star Trader` copies causes multiple buyers to queue without overlapping.
- Buyers visibly walk from browsing to the rack and then to the register without confusing clipping.
- Customer spawn, item approach, and queue positions read naturally in the current layout.
- Register prompt and sale completion message are readable.
- Trade-in seller and carried item are readable at the register.
- Trade-in register prompt and completion message are readable.
- Trade-in offer panel condition, demand, market, cash, store-credit, and accept/decline controls are readable.
- Trade-in counteroffer `- $1` and `+ $1` controls are readable and update only the accepted cash offer amount.
- Backroom computer placement is readable and does not look like a second register.
- Backroom summary opens after a sale and shows matching cash, revenue, cost, and profit.
- Backroom recent activity shows sale and trade-in entries with readable prices.
- Backroom category demand text remains readable and does not crowd the management panel.
- Backroom inventory summary is readable and matches active receiving/shelf inventory.
- Backroom reorder suggestions are readable and reflect sales versus active inventory.
- Backroom fixture ordering shows the game display rack option, cash reservation, and pending placement clearly.
- Ordered fixture ghost preview is visible, translucent, and reads as a pending placement rather than a finished rack.
- Fixture ghost valid and invalid states read clearly as green allowed and red blocked placement previews.
- Fixture ghost rotate and snap behavior feels predictable once exposed through player-facing placement controls.
- Backroom summary panel closes back into first-person mouse capture cleanly.
- After checkout, the stocked game is gone from the rack and no longer available for inspection.
- Screenshot composition is useful, not merely nonblank.

Every implementation summary should say whether these were checked, skipped, or not relevant.

## Maintaining The Matrix

Update `game/tests/validation/` whenever a production script or player-facing validation scenario is added.

Scenario files are intentionally split by slice:

- `scenarios/core_smoke.json`: main scene, player, input, floor, and front-door boundary smoke checks.
- `scenarios/receiving_stocking.json`: receiving box, item state, pickup, hold, shelf slot category assignment, and stocking checks.
- `scenarios/pricing.json`: direct held-item pricing, apply-to-matching pricing, pricing panel, and fixed-price rejection checks.
- `scenarios/product_catalog.json`: fictional product catalog count, uniqueness, pricing sanity, and variety checks.
- `scenarios/customer_sale.json`: customer manager, buyer movement, buyer path validation, buyer queue, price sensitivity/refusal, register checkout, and transaction ledger checks.
- `scenarios/economy.json`: category demand defaults, demand normalization, buyer price-limit wiring, and backroom demand readout checks.
- `scenarios/trade_in.json`: trade-in seller, carried item, offer review panel, counteroffer controls, cash accept, store-credit accept, decline, receiving inventory, and tender accounting checks.
- `scenarios/day_summary.json`: store session cash/accounting totals, store-credit trade-in activity, recent activity history, active inventory summary, reorder suggestions, backroom computer, and day summary panel checks.
- `scenarios/persistence.json`: codec-level session, ledger, active inventory, and JSON roundtrip checks.
- `scenarios/store_layout.json`: fixture catalog, fixture ordering, slot-category metadata, cash reservation, pending placement, ghost preview, valid/invalid placement state, rotate/snap controls, insufficient-cash rejection, and persistence coverage.
- `scenarios/screenshots.json`: named screenshot capture and image sanity checks.
- `scenarios/manual_checks.json`: manual-only checks with owner and reason.

Script test mappings live in `script_coverage/production_scripts.json`, and thresholds live in `thresholds.json`.

Use these statuses:

- `automated`: covered by GUT, a validation script, or the local gate.
- `manual`: intentionally human-checked, with `reason` and `owner`.
- `not_applicable`: retained for historical context but excluded from active coverage.

Any new critical scenario must be automated before the gate is allowed to pass.
