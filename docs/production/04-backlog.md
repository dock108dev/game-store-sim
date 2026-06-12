# Backlog

This is the active production backlog. For current status, validation numbers, and playtest gating, read `docs/CURRENT_STATE.md` first.

## Current Phase

Visual production reset.

Goal: reset the visual direction around a mid-00s independent game shop, then build one final-quality visual slice before more broad store or day-loop work.

Status: the prototype and first polish pass are validated, Alpha hardening is complete through Stop 13.7 as a mechanical gate, readability recovery implementation plus label depth-safety stabilization are complete, employees-only stockroom production is mechanically complete through Slice 8, the first post-stockroom returns baseline is implemented, and the production visual overhaul baseline is mechanically complete through Slice 14 in `18-production-visuals-plan.md`. The latest visual review rejected the CSG/label-heavy blockout as the wrong production bar. External alpha playtest remains paused until the visual reset and first final-quality visual slice are approved.

## Next Decision

1. Run `scripts/validate_godot.sh`.
2. Review `docs/visual-production/README.md`.
3. Approve or revise the visual reset, art direction, inventory checklist, asset pipeline, and first-slice roadmap.
4. If the visual reset passes, implement the first final-quality visual slice.
5. If the visual reset fails, revise docs before scene or asset changes.

## Current Rules

- Keep the game shippable after every slice.
- Update `docs/status.json`, `docs/CURRENT_STATE.md`, and the relevant QA runbook before updating historical production plans.
- Run `scripts/validate_godot.sh` before every commit.
- Keep click-first prompts, center-reticle interaction, and mouse-capture behavior consistent.
- Keep the register focused on sales, returns, trade-ins, preorders, and services.
- Keep the backroom computer focused on management, ordering, reports, inventory, releases, fixture/storage work, and records.
- Keep hidden-thread content optional and nonblocking until a deliberate escalation phase.

## Active Work

1. Visual production reset review.
2. First final-quality visual slice selection.
3. Screenshot review after the first visual slice exists.
4. External alpha playtest: paused until the visual reset, first final-quality visual slice, screenshot review, and release-package check pass.

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
