# Backlog

This is the active production backlog. For current status, validation numbers, and playtest gating, read `docs/CURRENT_STATE.md` first.

## Current Phase

Prototype visual language cleanup.

Goal: remove the remaining prototype visual language before the next visual-content breadth pass.

Status: Alpha hardening is complete through Stop 13.7, and the first phase 0-4 visual pass failed owner screenshot review. The active implementation resets the opening composition: the player starts on a second-floor mall concourse, faces a branded glass storefront, walks through an open threshold, and enters an empty pre-open shop with customer actors hidden but still mechanically wired. Scene architecture modularization is accepted as infrastructure: `store_world.tscn` is the production main scene, module manifests exist under `game/scenes/world/modules/`, screenshot/tools target the production scene, and `graybox_store.tscn` remains as a compatibility wrapper. Visual quality is not approved: the store still has too many labels, debug-like callouts, random clutter, and a backroom boundary that reads as a line instead of a room.

## Next Decision

1. Run `scripts/validate_godot.sh`.
2. Review `docs/visual-production/18-prototype-visual-language-cleanup.md`.
3. Implement label purge, backroom threshold, front sales-floor benchmark, and receiving clutter cleanup.
4. If the cleanup screenshots pass owner review, implement product/fixture visual-kit work on top of `store_world.tscn`.
5. If the cleanup screenshots fail, continue cleanup before adding broader catalog visuals.

## Current Rules

- Keep the game shippable after every slice.
- Update `docs/status.json`, `docs/CURRENT_STATE.md`, and the relevant QA runbook before updating historical production plans.
- Run `scripts/validate_godot.sh` before every commit.
- Keep click-first prompts, center-reticle interaction, and mouse-capture behavior consistent.
- Keep the register focused on sales, returns, trade-ins, preorders, and services.
- Keep the backroom computer focused on management, ordering, reports, inventory, releases, fixture/storage work, and records.
- Keep hidden-thread content optional and nonblocking until a deliberate escalation phase.

## Active Work

1. Prototype visual language cleanup implementation.
2. Owner latest screenshot/contact-sheet review for the cleanup pass.
3. Product/fixture visual-kit implementation after cleanup validation.
4. Broader sales-floor rebuild after product/fixture visual-kit approval.
5. Deeper module child-node extraction only where the cleanup pass needs it.
6. External alpha playtest: paused until opening review, interior rebuild, screenshot review, and release-package check pass.

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
- Scene architecture modularization. Implemented with `store_world.tscn`, module manifests, production-scene promotion, validation/tool reference updates, and legacy `graybox_store.tscn` compatibility wrapper; accepted as infrastructure for the cleanup pass.

## Historical Plans

Historical implementation records are retained in `docs/production/` and classified in `docs/archive/README.md`. They should not be used as the active next-step source unless `docs/CURRENT_STATE.md` points to a specific section.
