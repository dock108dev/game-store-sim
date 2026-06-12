# Screenshot Review

Use this to approve or reject the current prototype/blockout visuals before reopening external alpha playtest. The first phase 0-4 visual pass was rejected on June 12, 2026; the second-floor mall opening/storefront reset is directionally better, and the scene architecture is accepted as infrastructure. Visual quality is still not approved. The active review target is now the prototype visual language cleanup pass.

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

- Full validation passed with 570 GUT tests and 9961 asserts.
- All 23 required screenshot files are present in `artifacts/validation/latest/screenshots/`.
- Screenshot sanity and old-name scan passed.
- Contact sheet: `artifacts/validation/latest/screenshot-contact-sheet.png`.
- Automated evidence is ready for owner review; it does not replace the required real-window readability pass.
- Current visual evidence is not art-approved. It is captured from the promoted `store_world.tscn` production scene, but still has too many labels, debug-like callouts, random clutter, and a weak backroom boundary.

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
- The opening screenshot starts outside the shop on a second-floor mall concourse and the entry route is walkable.
- The opening state has no visible customers or employees before business begins.
- `main_scene.png` and `storefront_entry.png` do not read as raw boxes with labels.
- `register_counter.png`, `receiving_area.png`, and `backroom_summary.png` do not read as label-driven prototype staging.
- The backroom reads as a staff-only room or threshold, not a floor line.
- Storefront, sales floor, register, receiving, stockroom, and backroom zones are distinguishable without reading docs.
- Prompt, reticle, product label, shelf label, and modal text are readable at 1280x720.
- Customers read by silhouette, role prop, queue position, and compact marker before relying on long labels.
- Register, return, trade-in, preorder, and service screenshots show the decision point before confirmation.
- Fixture ghosts clearly distinguish valid, invalid, rotated, and placed states.
- Backroom computer screenshots show tab purpose, primary controls, and current business state without hiding actions below the frame.
- No screenshot has blocked product paths, hidden interaction targets, streamer-reference copy, third-party branding, or unreadable signage.

Fail if:

- The screenshot still reads mainly as graybox.
- Opening-route objects still look like blockout boxes unless they are intentionally cardboard boxes.
- The store still depends on labels or debug-like signs to explain most objects.
- The backroom is still separated only by a line, marker, or label.
- Boxes, papers, and props look randomly dumped instead of staged for receiving, sorting, display, or backstock.
- A player would need a doc explanation to understand the current action.
- Text is too small, clipped, low contrast, or crowded.
- A prop, sign, customer, fixture, or modal competes with the action target.

## Routing

Before broadening visual work beyond the opening route, review `docs/visual-production/18-prototype-visual-language-cleanup.md` and confirm the cleanup pass has removed the label/debug/clutter/backroom-line read. If cleanup fails review, keep iterating there before adding product, fixture, or customer visual breadth.

If all screenshots pass, run `docs/qa/release-package-check.md` and consider reopening `docs/production/15-alpha-playtest-package.md`.

If any screenshot fails, add an entry to `docs/production/13-alpha-bug-list.md` with the screenshot name, priority, failure reason, and acceptance check.
