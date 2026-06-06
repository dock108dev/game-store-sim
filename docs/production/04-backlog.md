# Backlog

This backlog is intentionally coarse. Detailed tasks should be split when a slice is approved.

## Now

- Initialize the Godot project under `game/`.
- Pin the Godot version.
- Create a graybox store scene.
- Add a keyboard/mouse first-person controller.
- Add a basic interaction raycast and prompt.
- Add one inspectable used-game item.
- Add initial product data shape.
- Add one shelf slot.
- Add one register workstation placeholder.

## First Playable Counter Loop

- Pick up an item from a receiving box.
- Inspect product name, platform, condition, cost, and market value.
- Set a sale price.
- Place the item on a shelf.
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

- Add fixture catalogue.
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

- Add debug test map.
- Add content validation script for product data.
- Add save/load smoke test after persistence exists.
- Add screenshot capture path once visual verification matters.

