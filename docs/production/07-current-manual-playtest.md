# Current Manual Playtest

This file is now an index. The old monolithic checklist was split into focused QA runbooks so current validation is easier to run and review.

Use this order:

1. `scripts/validate_godot.sh`
2. `docs/qa/smoke-playtest.md`
3. `docs/qa/screenshot-review.md`
4. `docs/qa/full-day-playtest.md`
5. `docs/qa/release-package-check.md`

Current automated baseline:

- 570 GUT tests.
- 10026 GUT asserts.
- UI scenario automation coverage: 508/628.
- Production script mapping coverage: 53/53.
- 3 active standalone validation tools.
- 60 catalog products.
- 23 required screenshots and contact sheet generated.

External alpha playtest remains paused until owner recovery, opening mall/storefront, stockroom, and production-visual screenshot review pass in a real 1280x720 window.

Every implementation summary should say whether these were checked, skipped, or not relevant.

## Smoke Playtest

Run `docs/qa/smoke-playtest.md` first when checking whether the current build is basically playable.

## Full-Day Playtest

Run `docs/qa/full-day-playtest.md` when checking the full retail loop, economy feel, hidden-thread optionality, save/load, settings, and day progression.

## Screenshot Review

Run `docs/qa/screenshot-review.md` to approve or reject the current production-blockout visuals before reopening the alpha package.

## Release Package Check

Run `docs/qa/release-package-check.md` only after screenshot review passes.

## Focus Sections

The following focus names are retained so older validation scenario references still resolve to an active review surface:

### Alpha Bug Triage Focus

Use `docs/production/13-alpha-bug-list.md`.

### Alpha Performance Focus

Use `scripts/measure_alpha_performance.sh` and `docs/production/14-alpha-performance-baseline.md`.

### Alpha Regression Focus

Use the full gate and current screenshot artifacts.

### Alpha Scene Readability Focus

Use `docs/qa/screenshot-review.md`.

### Alpha Content Copy Focus

Review prompts, customer text, product text, supplier copy, release copy, daily report copy, and backroom computer labels during the smoke and full-day playtests.

### Alpha Balance Focus

Review cash pressure, buyer tolerance, supplier ordering, services, launch allocations, upgrades, and multi-day recovery during the full-day playtest.

### Alpha Playtest Package Focus

Alpha playtest package is implemented through Stop 13.6. Use `docs/production/15-alpha-playtest-package.md`, but keep it paused until screenshot review and release package check pass.

### Alpha Validation Sync Focus

Alpha validation sync is implemented through Stop 13.7. Use `docs/status.json` and `docs/production/06-validation.md` as the current status contract.

### Stockroom Production Focus

Use `docs/qa/screenshot-review.md` and the stockroom screenshots. Historical stockroom screenshot names remain:

- `43_stockroom_staff_threshold.png`
- `45_receiving_intake_station.png`
- `48_manager_office_context.png`
- `50_storage_tab_physical_flow.png`

### Production Visuals Focus

Use `docs/qa/screenshot-review.md`. Keep `15-alpha-playtest-package.md` paused if any production-visual screenshot still reads as graybox, streamer-reference copy, hidden interaction clutter, unreadable signage, obstructed product paths, or UI text squeezed into the frame.

### Release Wrapper Focus

Release wrapper validation sync is implemented through Stop 12.6. Use `docs/qa/release-package-check.md`.

### Presentation Feel Focus

Presentation validation sync is implemented through Stop 11.6. Review ambience, interaction audio, customer audio placeholders, microfeedback, camera bob, FOV shift, held-item sway, and workstation settling during full-day playtest.

### Hidden Thread Focus

Hidden-thread validation sync is implemented through Stop 10.6. Confirm hidden-thread cues remain optional and normal retail work is never blocked.

## Automated Screenshot Artifacts

The local gate writes these images under `artifacts/validation/latest/screenshots/`:

- `main_scene.png`
- `storefront_entry.png`
- `stocked_aisle.png`
- `carry_stack.png`
- `receiving_area.png`
- `supplier_message.png`
- `suspicious_customer.png`
- `register_counter.png`
- `customer_queue.png`
- `trade_in_offer.png`
- `preorder_deposit.png`
- `service_request.png`
- `backroom_summary.png`
- `catalog_design_cues.png`
- `upgrade_preview.png`
- `release_calendar.png`
- `release_allocation.png`
- `launch_day.png`
- `supplier_delivery.png`
- `fixture_ghost.png`
- `fixture_invalid_ghost.png`
- `fixture_rotated_ghost.png`
- `fixture_placed.png`
