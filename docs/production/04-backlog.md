# Backlog

This backlog is intentionally coarse. Detailed tasks should be split when a slice is approved.

## Now

- Add held-item pricing workstation and pricing panel.
- Keep used-game pricing distinct from fixed-price new game/hardware rules.
- Keep validation coverage current as the pricing loop changes.

## First Playable Counter Loop

- Pick up an item from a receiving box. Done.
- Inspect product name, platform, condition, cost, and market value.
- Set a sale price. In progress.
- Place the item on a shelf/display rack. Done.
- Spawn one target buyer customer.
- Let the customer find the item and queue at the register.
- Scan the item.
- Complete sale.
- Record transaction.
- Show end-of-day cash and profit summary.

## Trade-In Slice

- Add customer-carried used item.
- Add condition inspection UI.
- Add market value and demand lookup.
- Add cash/store-credit offer.
- Add accept/counter/decline customer response.
- Add acquired item to inventory.

## Store Layout Slice

- Add fixture and equipment ordering interface.
- Add fixture ghost placement.
- Add valid/invalid placement state.
- Add rotate and snap controls.
- Add shelf category assignment.
- Add basic customer path validation.

## Economy Slice

- Add demand per category.
- Add price sensitivity.
- Add sales history.
- Add market drift.
- Add daily report.
- Add reorder suggestions.

## Hidden Thread Slice

- Add suspicious event flags.
- Add mismatched serial item.
- Add supplier message artifact.
- Add optional evidence storage.
- Add one suspicious customer encounter.
- Keep all hidden-thread content optional and avoid blocking normal store progression.

## Tooling

- Maintain the mandatory local validation gate in `scripts/validate_godot.sh`.
- Keep `game/tests/validation_matrix.json` current as UI scenarios and scripts are added.
- Report manual QA for held-item visibility, upright stocked item placement, pricing panel readability, prompt readability, mouse capture, and rack/register/receiving-box/pricing-workstation composition after every interaction-loop change.
- Keep pricing workstation visuals distinct from the register so the register slice remains readable.
- Add debug test maps only when they are called by the validation gate or a documented manual checklist.
- Extend product data validation inside the local gate as product resources become more complex.
- Add save/load smoke tests to the local gate after persistence exists.
