# Screenshot Review

Use this to approve or reject the current prototype/blockout visuals before reopening external alpha playtest.

## Generate

Run:

```text
scripts/validate_godot.sh
```

Screenshots are written to `artifacts/validation/latest/screenshots/`.

Optional contact sheet:

```text
magick montage artifacts/validation/latest/screenshots/*.png -thumbnail 320x180 -label '%t' -background '#1f2328' -fill white -pointsize 18 -geometry 320x220+8+8 artifacts/validation/latest/screenshot-contact-sheet.png
```

## Latest Automated Lock

Generated on June 12, 2026 from `scripts/validate_godot.sh`.

- Full validation passed with 563 GUT tests and 9630 asserts.
- All 23 required screenshot files are present in `artifacts/validation/latest/screenshots/`.
- Screenshot sanity and old-name scan passed.
- Contact sheet: `artifacts/validation/latest/screenshot-contact-sheet.png`.
- Automated evidence is ready for owner review; it does not replace the required real-window readability pass.

## Required Screenshots

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

## Review Criteria

Pass only if:

- The first view reads as a small specialty game shop.
- Storefront, sales floor, register, receiving, stockroom, and backroom zones are distinguishable without reading docs.
- Prompt, reticle, product label, shelf label, and modal text are readable at 1280x720.
- Customers read by silhouette, role prop, queue position, and compact marker before relying on long labels.
- Register, return, trade-in, preorder, and service screenshots show the decision point before confirmation.
- Fixture ghosts clearly distinguish valid, invalid, rotated, and placed states.
- Backroom computer screenshots show tab purpose, primary controls, and current business state without hiding actions below the frame.
- No screenshot has blocked product paths, hidden interaction targets, streamer-reference copy, third-party branding, or unreadable signage.

Fail if:

- The screenshot still reads mainly as graybox.
- A player would need a doc explanation to understand the current action.
- Text is too small, clipped, low contrast, or crowded.
- A prop, sign, customer, fixture, or modal competes with the action target.

## Routing

If all screenshots pass, run `docs/qa/release-package-check.md` and consider reopening `docs/production/15-alpha-playtest-package.md`.

If any screenshot fails, add an entry to `docs/production/13-alpha-bug-list.md` with the screenshot name, priority, failure reason, and acceptance check.
