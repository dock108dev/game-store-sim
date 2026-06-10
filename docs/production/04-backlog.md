# Backlog

This is the active production backlog. For current status, validation numbers, and playtest gating, read `docs/CURRENT_STATE.md` first.

## Current Phase

Production visual screenshot review.

Goal: decide whether the mechanically validated production-blockout build is readable enough to reopen the external alpha playtest package.

Status: the prototype and first polish pass are validated, Alpha hardening is complete through Stop 13.7 as a mechanical gate, readability recovery implementation plus label depth-safety stabilization are complete, employees-only stockroom production is mechanically complete through Slice 8, the first post-stockroom returns baseline is implemented, and the production visual overhaul baseline is mechanically complete through Slice 14 in `18-production-visuals-plan.md`. External alpha playtest remains paused until the owner captures and reviews the recovery screenshot set, stockroom screenshot set, and production-visual review set in a real 1280x720 window.

## Next Decision

1. Run `scripts/validate_godot.sh`.
2. Review `artifacts/validation/latest/screenshots/` using `docs/qa/screenshot-review.md`.
3. If screenshots pass, run `docs/qa/release-package-check.md` and reopen `15-alpha-playtest-package.md`.
4. If screenshots fail, add the smallest actionable issue to `13-alpha-bug-list.md`, fix only that surface, and rerun the gate.

## Current Rules

- Keep the game shippable after every slice.
- Update `docs/status.json`, `docs/CURRENT_STATE.md`, and the relevant QA runbook before updating historical production plans.
- Run `scripts/validate_godot.sh` before every commit.
- Keep click-first prompts, center-reticle interaction, and mouse-capture behavior consistent.
- Keep the register focused on sales, returns, trade-ins, preorders, and services.
- Keep the backroom computer focused on management, ordering, reports, inventory, releases, fixture/storage work, and records.
- Keep hidden-thread content optional and nonblocking until a deliberate escalation phase.

## Active Work

1. Screenshot review: owner recovery, stockroom, and production-visual screenshot sets.
2. Release package check: pack smoke plus manual build/save/load relaunch review.
3. External alpha playtest: paused until the above pass.

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
