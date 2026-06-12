# Backlog

This is the active production backlog. For current status, validation numbers, and playtest gating, read `docs/CURRENT_STATE.md` first.

## Current Phase

Visual production phases 0-4 owner validation.

Goal: validate the first five visual phases before Phase 5 lighting/polish and all-screenshot approval.

Status: Alpha hardening is complete through Stop 13.7, and visual phases 0-4 are implemented for owner review: visual reset planning, target storefront/register/shelf slice, product/fixture kit cues, backroom operations kit cues, and customer role silhouettes. The latest implementation adds owned starter stock, catalog/design planning surfaces for locked inventory, paid-arrivals receiving lane, and explicit empty-capacity shelf cues. External alpha playtest remains paused until owner screenshot validation and Phase 5 polish pass.

## Next Decision

1. Run `scripts/validate_godot.sh`.
2. Review `docs/visual-production/README.md` and the latest screenshot contact sheet.
3. Approve or revise phases 0-4: target slice, day-one stock, catalog/unlock/receiving, products/fixtures, backroom operations, and customer role visuals.
4. If phases 0-4 pass, continue to Phase 5 lighting/material/camera polish.
5. If a phase fails, patch that phase before broadening visual work.

## Current Rules

- Keep the game shippable after every slice.
- Update `docs/status.json`, `docs/CURRENT_STATE.md`, and the relevant QA runbook before updating historical production plans.
- Run `scripts/validate_godot.sh` before every commit.
- Keep click-first prompts, center-reticle interaction, and mouse-capture behavior consistent.
- Keep the register focused on sales, returns, trade-ins, preorders, and services.
- Keep the backroom computer focused on management, ordering, reports, inventory, releases, fixture/storage work, and records.
- Keep hidden-thread content optional and nonblocking until a deliberate escalation phase.

## Active Work

1. Owner visual phases 0-4 screenshot review.
2. Owner day-one owned-stock and catalog/unlock/receiving review.
3. Phase 5 lighting/material/camera polish after approval.
4. External alpha playtest: paused until phase review, Phase 5 polish, screenshot review, and release-package check pass.

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
