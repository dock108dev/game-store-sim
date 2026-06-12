# Backlog

This is the active production backlog. For current status, validation numbers, and playtest gating, read `docs/CURRENT_STATE.md` first.

## Current Phase

Opening visual asset pass owner validation.

Goal: approve or correct the implemented opening asset-replacement slice before broadening the interior visual rebuild.

Status: Alpha hardening is complete through Stop 13.7, and the first phase 0-4 visual pass failed owner screenshot review. The active implementation resets the opening composition: the player starts on a second-floor mall concourse, faces a branded glass storefront, walks through an open threshold, and enters an empty pre-open shop with customer actors hidden but still mechanically wired. The first opening visual asset pass now replaces key blockout/box-label graphics on that route with authored modular mall, storefront, starter-product, and first-corner pieces. External alpha playtest remains paused until owner screenshot validation and the follow-up interior visual rebuild pass.

## Next Decision

1. Run `scripts/validate_godot.sh`.
2. Review `docs/visual-production/README.md` and the latest screenshot contact sheet.
3. Review `docs/visual-production/16-opening-visual-asset-pass.md`.
4. Approve or revise the implemented opening route: mall spawn, storefront, threshold, first interior view.
5. If the asset pass passes, use it as the benchmark for product/fixture and sales-floor work.
6. If the asset pass fails, revise the rejected route pieces before changing broader scene assets.

## Current Rules

- Keep the game shippable after every slice.
- Update `docs/status.json`, `docs/CURRENT_STATE.md`, and the relevant QA runbook before updating historical production plans.
- Run `scripts/validate_godot.sh` before every commit.
- Keep click-first prompts, center-reticle interaction, and mouse-capture behavior consistent.
- Keep the register focused on sales, returns, trade-ins, preorders, and services.
- Keep the backroom computer focused on management, ordering, reports, inventory, releases, fixture/storage work, and records.
- Keep hidden-thread content optional and nonblocking until a deliberate escalation phase.

## Active Work

1. Owner opening visual asset pass signoff.
2. Owner opening mall/storefront screenshot review.
3. Owner walk-in empty-store review.
4. Owner day-one owned-stock and catalog/unlock/receiving review.
5. Product/fixture and broader sales-floor rebuild after opening asset pass signoff.
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

## Historical Plans

Historical implementation records are retained in `docs/production/` and classified in `docs/archive/README.md`. They should not be used as the active next-step source unless `docs/CURRENT_STATE.md` points to a specific section.
