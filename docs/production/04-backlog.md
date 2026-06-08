# Backlog

This backlog is the active production view. The historical first-playable checklist remains in `01-vertical-slice-plan.md`.

## Current Phase

Production polish and readability.

Goal: keep the validated retail loop intact while making the store, backroom, customers, computer, and menus read like an intentional game instead of a test harness.

Active roadmap: `08-polish-roadmap.md`.

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

1. Production polish planning reset. Done in this docs slice.
2. Backroom spatial and visual identity pass.
3. Backroom computer/menu information architecture pass.
4. Customer readability and role silhouette pass.
5. Store lighting, materials, signage, and retail clutter pass.
6. Product and fixture presentation pass.
7. Validation/manual QA tightening for the full polish pass.

## Backroom Polish

- Make the backroom visually distinct from the sales floor.
- Separate receiving, storage, computer, service/repair, paperwork, and optional hidden-thread cues.
- Make supplier-delivered stock placement read as physical receiving, not UI inventory teleporting.
- Make storage fixture ordering and placement read as a backroom/operations workflow.
- Keep the backroom computer readable as a management terminal, not another register.

## Computer And Menu Polish

- Split the backroom computer into clearer sections instead of one long mixed summary.
- Create predictable grouping for reports, inventory, supplier orders, fixtures, release planning, and day controls.
- Improve button labels, state text, disabled states, and status messages.
- Make dense text fit at the actual game resolution.
- Preserve all current accounting and session behavior while changing presentation.

## Customer Polish

- Improve customer silhouettes and role readability.
- Make buyer, trade-in seller, preorder customer, service customer, and suspicious customer visually distinct.
- Improve register-area spacing and facing.
- Improve customer prompts and feedback text presentation.
- Keep customers mechanically separated from hidden-thread infrastructure unless explicitly engaged.

## Store Visual Polish

- Establish a warmer specialty-store lighting pass.
- Add readable signage and fictional store identity without real brands.
- Improve wall/floor material contrast and sales-floor/backroom zoning.
- Add controlled retail clutter: posters, price signs, bins, display tags, boxes, and small props.
- Keep product and interaction state readable; clutter must not hide shelf slots or prompts.

## Product And Fixture Polish

- Make used-game cases, shelf slots, display racks, receiving boxes, and carried items more intentional.
- Keep products compact enough for rack, carry stack, and customer carry.
- Add clearer shelf-slot/category affordances.
- Make fixture ghost preview and placed fixture states visually distinct.

## Completed First-Playable Scope

Compressed summary of completed validated systems:

- First-person movement, click-first interaction, prompt, and reticle.
- Receiving pickup, multi-item carry, held-item pricing, shelf stocking, and apply-to-matching pricing.
- Product catalog, fictional product validation, item identity, price, cost basis, condition, market value, serial metadata, and active inventory summary.
- Buyer customer manager, buyer movement, price sensitivity, lower-priced copy selection, register queue, sale completion, and transaction ledger.
- Trade-in seller, offer panel, cash/store-credit acceptance, counteroffer adjustment, decline, and acquired inventory.
- Service customer and register-completed service accounting.
- Backroom computer summaries, daily report, recent activity, reorder suggestions, demand readout, market drift, supplier ordering, release calendar, allocation commitment, launch-day resolution, and fixture controls.
- Fixture ordering, ghost preview, valid/invalid state, movement, rotation, snap, placement confirmation, and save-smoke coverage.
- Supplier orders with due-day receiving-box delivery.
- Preorder deposit and launch-day fulfillment/reputation outcome.
- Hidden event log, mismatched serial item, supplier message, optional suspicious customer, and hidden evidence storage.
- Mandatory validation gate, GUT tests, validation scenario matrix, script mapping, persistence smoke, and named screenshots.

## Not Current Scope

These remain future phases unless explicitly selected:

- Theft and shrinkage systems.
- Returns and exchanges.
- Rich customer archetypes beyond current role stubs.
- Player-facing save/load slot UI.
- Employees and staff assignment.
- Larger store expansion.
- Decoration/build-mode beyond current fixture placement.
- Complex hidden-thread consequences.
- Full audio, animation, VFX, and art-production pass.
