# Backlog

This is the active production backlog. For current status, validation numbers, and playtest gating, read `docs/CURRENT_STATE.md` first.

## Current Phase

Scene architecture modularization.

Goal: stop broadening `graybox_store.tscn` as the production world by introducing a production scene and reusable modules before the next visual-content pass.

Status: Alpha hardening is complete through Stop 13.7, and the first phase 0-4 visual pass failed owner screenshot review. The active implementation resets the opening composition: the player starts on a second-floor mall concourse, faces a branded glass storefront, walks through an open threshold, and enters an empty pre-open shop with customer actors hidden but still mechanically wired. The first opening visual asset pass now replaces key blockout/box-label graphics on that route with authored modular mall, storefront, starter-product, and first-corner pieces. The next implementation pass is architectural: create `store_world.tscn`, extract reusable modules, separate systems from visual modules, and keep `graybox_store.tscn` as a legacy reference until parity is validated.

## Next Decision

1. Run `scripts/validate_godot.sh`.
2. Review `docs/visual-production/17-scene-architecture-modularization.md`.
3. Approve or revise the production scene/module boundaries.
4. If the plan passes, implement Phase 1B before product/fixture or broader sales-floor work.
5. If the plan fails, revise ownership boundaries before changing scene assets.

## Current Rules

- Keep the game shippable after every slice.
- Update `docs/status.json`, `docs/CURRENT_STATE.md`, and the relevant QA runbook before updating historical production plans.
- Run `scripts/validate_godot.sh` before every commit.
- Keep click-first prompts, center-reticle interaction, and mouse-capture behavior consistent.
- Keep the register focused on sales, returns, trade-ins, preorders, and services.
- Keep the backroom computer focused on management, ordering, reports, inventory, releases, fixture/storage work, and records.
- Keep hidden-thread content optional and nonblocking until a deliberate escalation phase.

## Active Work

1. Owner scene architecture modularization plan signoff.
2. Production world skeleton implementation.
3. Opening-route module extraction.
4. Systems/interaction wiring separation.
5. Main-scene promotion after parity validation.
6. Product/fixture and broader sales-floor rebuild after production scene promotion.
7. External alpha playtest: paused until opening review, interior rebuild, screenshot review, and release-package check pass.

## Completed Baselines

- Store environment production pass. Done through Milestone 2.
- Interaction and game-feel production pass. Done through Milestone 3.
- Menu, register, and computer production UI. Done through Milestone 4.
- Customer production pass. Done through Milestone 5.
- Product and content pipeline. Done through Milestone 6.
- Economy, day loop, progression, backroom operations, store building, hidden-thread infrastructure, presentation feel, save/load/settings/release wrapper, and alpha hardening are mechanically validated.
- Alpha hardening. Complete through Stop 13.7.
- Playability readability recovery. Implementation complete; owner screenshot validation remains required before external playtest.
- Employees-only stockroom production. Mechanically complete through Slice 8; owner screenshot validation remains required before external playtest.
- Returns/exchanges baseline. Complete for first-pass register refund, receiving-review routing, cash/reputation accounting, daily-report readout, scene wiring, validation coverage, and manual checklist updates.
- Production visual overhaul. Mechanically complete through Slice 14 in `18-production-visuals-plan.md`; owner screenshot review remains required before external playtest.

## Historical Plans

Historical implementation records are retained in `docs/production/` and classified in `docs/archive/README.md`. They should not be used as the active next-step source unless `docs/CURRENT_STATE.md` points to a specific section.
