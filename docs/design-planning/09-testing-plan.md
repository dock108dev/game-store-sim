# Testing Plan

Testing plan for the opening-store quality bar.

## Automated Gate

Run after every implementation slice:

```text
scripts/validate_godot.sh
```

The gate must remain the finish line. Do not call a visual slice done if this fails.

## Focused Test Areas

### Storefront And Entry

- Scene assertions for signage, glass, threshold, and spawn composition.
- Screenshot scenarios: `main_scene.png`, `storefront_entry.png`.

### Sales Floor

- Scene assertions for shelf density, category zones, path clearance, and fixture placement.
- Customer manager path/queue spacing tests.
- Screenshot scenarios: `stocked_aisle.png`, `customer_queue.png`, `fixture_placed.png`.

### Register

- Register checkout tests.
- Return, trade-in, preorder, and service state tests.
- Screenshot scenarios: `register_counter.png`, `trade_in_offer.png`, `preorder_deposit.png`, `service_request.png`.

### Backroom And Stockroom

- Store session and day summary tests.
- Hidden-thread optionality tests.
- Screenshot scenarios: `receiving_area.png`, `supplier_delivery.png`, `backroom_summary.png`, `release_calendar.png`, `release_allocation.png`, `launch_day.png`.

### Catalog Foundation

- Product catalog checker.
- Product catalog GUT tests.
- Product visual rules tests.
- Fictional-name/no-IP review.

## Human Review

Use:

- `docs/qa/smoke-playtest.md`
- `docs/qa/screenshot-review.md`
- `docs/design-planning/08-quality-bar-checklist.md`

The most important human question is whether a new player can understand the opening store without reading design docs.

## Evidence Bundle

For each slice, keep:

- Gate result.
- Updated screenshot names.
- Short pass/fail note.
- Any bug-list entry added or closed.

## Exit Criteria

The phase exits only when:

- Full validation passes.
- Screenshot review passes.
- Quality bar checklist passes.
- P0/P1 visual/readability bugs are closed.
- The next phase can focus on full catalog, decorations, consoles/platforms, and multi-day playtesting.
