# Backlog

This backlog is the active production view. The historical first-playable checklist remains in `01-vertical-slice-plan.md`.

## Current Phase

Game completion planning and alpha production setup.

Goal: turn the validated prototype into a production-directed game build without losing the protected retail loop.

Status: the prototype and first polish pass are validated, but the June 7 screenshot review shows the game still reads as a graybox. The active work is now the completion plan that defines how to move from validated prototype to alpha-quality game.

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
2. Production direction and target slice.
3. Store environment production pass.
4. Interaction and game-feel production pass.
5. Menu, register, and computer production UI.
6. Customer production pass.
7. Product and content pipeline.
8. Economy, day loop, and progression.
9. Backroom operations.
10. Store building, decoration, and expansion.
11. Hidden-thread production arc.
12. Audio, VFX, and presentation feel.
13. Save/load, settings, and release wrapper.
14. Alpha hardening.

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

## Product And Fixture Polish

- Done: made used-game cases more intentional with spine, platform, and price-sticker cues.
- Done: kept products compact enough for rack, carry stack, and customer carry.
- Done: added clearer display-rack category header and slot rails.
- Done: added receiving-box intake lanes and label to make intake placement read as organized physical inventory.
- Done: tuned carried item stack fanning so multiple held cases stay visible without blocking the center view.
- Remaining polish risk: fixture ghost/placed fixture state can still get a dedicated art pass later, but the current automated checks preserve valid/invalid ghost distinction and placed-rack behavior.

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
