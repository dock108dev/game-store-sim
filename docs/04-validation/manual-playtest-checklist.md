# Manual Playtest Checklist

Use this checklist for the first playable.

## Session Setup

Record:

- build version:
- date:
- tester:
- Mac model:
- macOS version:
- input device:

## 1. Launch

Pass/fail:

- game launches
- main menu or start state appears
- no visible error overlay
- audio does not blast unexpectedly
- window/fullscreen behavior is acceptable

Screenshot:

- `01-launch.png`

## 2. Enter Store

Pass/fail:

- player starts in or near mall/store context
- mall storefront is readable
- entrance is obvious
- player can walk into store
- camera height feels natural

Screenshot:

- `02-storefront-entry.png`

## 3. Read Empty Lease

Pass/fail:

- store feels understocked, not broken
- counter is identifiable
- receiving/backroom is findable
- shelves have readable empty capacity
- lighting supports navigation

Screenshot:

- `03-empty-store-floor.png`

## 4. Receive Starter Shipment

Pass/fail:

- starter shipment is easy to identify
- box can be opened
- physical stock appears or becomes accessible
- invoice/summary is readable
- harmless odd detail does not start a quest

Screenshot:

- `04-starter-shipment.png`

## 5. Pick Up Item

Pass/fail:

- item can be targeted
- interaction prompt is clear
- pickup feels stable
- carried item does not block view badly
- item can be inspected or identified

Screenshot:

- `05-item-in-hand.png`

## 6. Price Used Item

Pass/fail:

- used item opens pricing UI
- suggested price is visible
- cost basis is visible
- margin is visible
- player can change price
- warning appears for bad price

Screenshot:

- `06-pricing-used-item.png`

## 7. Confirm New Fixed Price

Pass/fail:

- new item shows fixed price
- player cannot edit new price
- UI communicates the state clearly
- this does not feel like a bug

Screenshot:

- `07-new-fixed-price.png`

## 8. Stock Shelf

Pass/fail:

- valid shelf slot highlights
- item snaps/places cleanly
- shelf count becomes visually fuller
- player can stock multiple copies
- item can be removed if needed

Screenshot:

- `08-stocked-shelf.png`

## 9. Move Fixture

Pass/fail:

- layout mode can be entered
- fixture can be selected
- ghost placement is readable
- invalid placement is blocked
- valid placement commits
- fixture location persists after save/load

Screenshot:

- `09-layout-mode-fixture.png`

## 10. Open Store

Pass/fail:

- open action is clear
- open/closed state changes
- customer spawning begins
- mall path still feels outside store

Screenshot:

- `10-open-store.png`

## 11. Customer Enters

Pass/fail:

- customer spawns from mall path
- customer may pass by or enter
- entering customer walks naturally enough
- customer browses a shelf
- customer behavior is understandable without large text

Screenshot:

- `11-customer-browsing.png`

## 12. First Sale

Pass/fail:

- customer selects item
- customer queues at register
- register interaction is clear
- sale confirmation shows item and price
- cash changes
- sold item leaves inventory
- customer exits

Screenshot:

- `12-first-sale.png`

## 13. Close Register

Pass/fail:

- no new customers enter after closing begins
- remaining customers resolve
- close action becomes available
- transition to report is clear

Screenshot:

- `13-close-register.png`

## 14. Daily Report

Pass/fail:

- report shows revenue
- report shows cost/margin
- report shows items sold
- report shows inventory remaining
- report creates at least one useful next-day thought

Screenshot:

- `14-daily-report.png`

## 15. Save And Load

Pass/fail:

- save succeeds
- load succeeds
- cash restored
- items restored
- prices restored
- fixture position restored
- sold items remain sold

Screenshot:

- `15-loaded-store-state.png`

## Final Verdict

Choose one:

- pass
- pass with issues
- fail

Top three issues:

1.
2.
3.

Best moment:

Worst confusion:

