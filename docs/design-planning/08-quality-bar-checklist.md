# Quality Bar Checklist

Pass/fail checklist for approving the opening store, backroom, full first catalog, and decoration/upgrade surface plan before multi-day playtest implementation.

## Purpose

This document is the owner review protocol. Use it with the latest validation screenshots and contact sheet to decide whether the current opening store is good enough to become the quality bar for the rest of the game.

This checklist does not replace taste judgment. It makes the review concrete enough that failed areas produce targeted implementation work instead of another broad redesign pass.

## Required Evidence

Before review, generate a fresh artifact set:

```text
scripts/validate_godot.sh
magick montage artifacts/validation/latest/screenshots/*.png -thumbnail 320x180 -label '%t' -background '#1f2328' -fill white -pointsize 18 -geometry 320x220+8+8 artifacts/validation/latest/screenshot-contact-sheet.png
```

Required evidence:

- `scripts/validate_godot.sh` passes.
- `artifacts/validation/latest/screenshots/` contains all 23 required screenshots.
- `artifacts/validation/latest/screenshot-contact-sheet.png` exists.
- `docs/status.json` records the current gate.
- `docs/production/13-alpha-bug-list.md` has no unimplemented P0/P1 automated blocker.

Latest automated lock:

- June 10, 2026 `scripts/validate_godot.sh` passed with 563 GUT tests and 9607 asserts after the full first-catalog and decoration/upgrade surface hook implementations were locked.
- All 23 required screenshots were present under `artifacts/validation/latest/screenshots/`.
- Contact sheet was generated at `artifacts/validation/latest/screenshot-contact-sheet.png`.
- Owner screenshot review remains the approval gate before multi-day playtest work.

## Review Method

Use this order:

1. Review the contact sheet for broad failures.
2. Review each screenshot individually at 1280x720 or larger.
3. Mark each section as `pass`, `targeted rework`, or `blocker`.
4. If a screenshot fails, write the exact screenshot name, area, reason, and acceptance check in `docs/production/13-alpha-bug-list.md`.
5. Approve only when all P0/P1 opening-store quality-bar issues are either closed or explicitly accepted by the owner.

Severity routing:

- P0: blocks understanding or validating the opening store.
- P1: blocks quality-bar approval for first-store/backroom readability.
- P2: visible polish issue that can wait until catalog/decor/platform work if it does not undermine the target.
- P3: future art/content nice-to-have.

## Storefront And Spawn

Review screenshots:

- `main_scene.png`
- `storefront_entry.png`

Pass if:

- Store name/identity is readable from the first view.
- Spawn view shows shop identity, register, shelf zone, and backroom hint.
- Ceiling/floor/walls no longer dominate as empty planes.
- Glass, door, threshold, and signage read as a shop entrance.
- Wall trim, ceiling grid, threshold, and rubber mats separate finished surfaces from raw blockout planes.
- Reticle/prompt area is not crowded.

Fail if:

- First view still reads as an empty room or generic blockout.
- The player would need docs to know this is a game store.
- Signage, window props, or threshold cues block playable routes.
- Storefront suggests a supported exterior exit that does not exist.

## Sales Floor

Review screenshots:

- `stocked_aisle.png`
- `customer_queue.png`
- `fixture_placed.png`

Pass if:

- Used-game shelving has visible product density.
- Preorder, staff-pick, new-release, accessory, bargain, and impulse zones are readable as separate retail beats.
- Category signs are short and readable.
- Entry, register, shelf, receiving, and backroom routes remain clear.
- Products look like inventory, not random blocks.
- Fixture density does not hide interaction prompts.
- Customer queue and special-customer arc remain visually separated.

Fail if:

- Shelves still look sparse or abstract.
- Products or fixture props hide prompts, shelf slots, or customers.
- Queue/readability collapses into overlapping markers.
- Placed fixture dominates the screenshot or blocks the store read.

## Fixture Placement

Review screenshots:

- `fixture_ghost.png`
- `fixture_invalid_ghost.png`
- `fixture_rotated_ghost.png`
- `fixture_placed.png`

Pass if:

- Valid ghost, invalid ghost, rotated ghost, and placed fixture are visually distinct.
- Footprint/orientation is clear.
- Invalid placement reads as rejected.
- Placed fixture is grounded and does not read like a camera-blocking slab.

Fail if:

- Fixture states look interchangeable.
- The screenshot proves nonblank rendering but not the named fixture state.
- Preview language conflicts with real fixture/product language.

## Register

Review screenshots:

- `register_counter.png`
- `trade_in_offer.png`
- `preorder_deposit.png`
- `service_request.png`
- `customer_queue.png`

Pass if:

- Counter reads as a checkout command center.
- Sale, return, trade-in, preorder, and service surfaces are physically visible.
- Customer approach marker, scan pad, payment terminal, receipt printer, cash drawer, and workflow cue rail are visible without adding extra interaction targets.
- Register remains one clear interaction target.
- Transaction UI decision points are readable before confirmation.
- Background counter context supports modals without competing with them.

Fail if:

- Counter props imply multiple unsupported workstations.
- Modal decision context is clipped, tiny, or visually crowded.
- Preorder/service/trade-in reads as generic sale.
- Customer bodies/props block register decisions.

## Receiving And Stockroom

Review screenshots:

- `receiving_area.png`
- `supplier_delivery.png`
- `backroom_summary.png`

Pass if:

- Receiving station shows box, invoice, sorted tray, products, and pickup path.
- Delivery/check/sort workflow cards and pull/restock arrows explain stock movement physically.
- Supplier delivery reads as physical stock arrival.
- Backstock shelves show category lanes and capacity.
- Pull/store flow reads as backroom work, not menu teleporting.
- Carry route remains understandable.

Fail if:

- Receiving products are hidden or unreadable.
- Supplier delivery looks like instant inventory.
- Backstock reads as random clutter.
- Stockroom props block routes or interactions.

## Backroom Office

Review screenshots:

- `backroom_summary.png`
- `catalog_design_cues.png`
- `upgrade_preview.png`
- `release_calendar.png`
- `release_allocation.png`
- `launch_day.png`

Pass if:

- Computer reads as manager workstation.
- Computer framing includes calendar, records, task lighting, and short dashboard/order/release cues.
- Dashboard, ordering, releases, services, storage, settings, and records are scan-friendly.
- Service bench and records/safe/security surfaces are readable but secondary.
- Hidden-thread cues remain optional.
- Main controls are visible at 1280x720.

Fail if:

- Backroom computer reads as debug UI instead of management workstation.
- Tabs/screens look interchangeable.
- Important controls sit below frame.
- Optional records/security content looks mandatory.

## Catalog Foundation

Review screenshots:

- `stocked_aisle.png`
- `register_counter.png`
- `trade_in_offer.png`
- `preorder_deposit.png`
- `release_calendar.png`
- `supplier_delivery.png`

Pass if:

- Product and platform names are fictional and coherent.
- Platform families, title rules, supplier lanes, and taxonomy values are documented and test-enforced.
- Full first-catalog data supports the store identity with 60 fictional products, 9 release-calendar entries, and 4 supplier lots.
- Categories and condition/risk language fit receipts, tags, and panels.
- No real IP leakage appears.

Fail if:

- Any name sounds like a real game, console, publisher, or brand.
- Names are too long for shelf tags, receipts, or UI cards.
- Risk/authenticity language makes hidden-thread content feel mandatory.

## Decorations And Upgrades Readiness

Review screenshots:

- `catalog_design_cues.png`
- `upgrade_preview.png`
- `fixture_placed.png`
- `backroom_summary.png`

Pass if:

- Current decor/upgrade UI is understandable as a management catalog.
- Upgrade costs, lock states, and effects are visible.
- Fixture unlock language is clear.
- Decoration and upgrade catalog entries map to stable visible world surfaces without revisiting the opening-store layout.

Fail if:

- Upgrade/decor language looks like debug text.
- Lock states look broken.
- The store does not provide enough stable surfaces for visible decor.

## Hidden-Thread Optionality

Review screenshots:

- `supplier_message.png`
- `suspicious_customer.png`
- `backroom_summary.png`

Pass if:

- Suspicious supplier/customer/evidence cues are visible but secondary.
- Normal retail loop remains understandable without interacting with hidden-thread content.
- Records/safe/security surfaces do not compete with receiving, register, or computer workflows.

Fail if:

- Hidden-thread props dominate the backroom or first store.
- Suspicious content looks like the primary objective.
- Optional clues block retail progression or screenshot readability.

## Validation

Automated pass requires:

- `scripts/validate_godot.sh` passes.
- Product catalog checker passes.
- Screenshot capture and sanity pass.
- Old-name scan passes.
- UI automation and script mapping coverage remain above thresholds.

Manual pass requires:

- `docs/qa/screenshot-review.md` passes.
- This checklist passes.
- No unresolved P0/P1 issue remains for opening-store quality-bar approval.
- Human review confirms the first five minutes feel like a deliberate game store.

## Decision Outcomes

### Approve

Use this if all required areas pass.

Next work:

1. Begin multi-day playtesting from `09-testing-plan.md`.
2. File any failed catalog, decor, economy, or readability surface as targeted rework.
3. Tune only the failed day-loop surfaces before reopening external playtest.

### Targeted Rework

Use this if one or more sections fail but the overall direction is correct.

Required action:

1. File each failure in `docs/production/13-alpha-bug-list.md`.
2. Fix only the named screenshot/surface.
3. Rerun `scripts/validate_godot.sh`.
4. Regenerate contact sheet.
5. Repeat owner review for failed areas only.

### Block

Use this if the opening store still does not read as a game store or the backroom workflow is not understandable.

Required action:

1. Pause catalog/decor/platform work.
2. Reopen `01-opening-store-quality-bar.md` and identify the failed slice.
3. Create a narrow implementation plan for the blocker.
4. Do not reopen external playtest until the blocker is resolved.

## Completion Criteria

This checklist is complete when:

- It can be used as a standalone owner review protocol.
- Every required screenshot has pass/fail criteria.
- Failed review has an explicit routing path.
- Approved review has an explicit next-phase path.
- The latest automated lock is recorded.
- The repo remains green on `scripts/validate_godot.sh`.
