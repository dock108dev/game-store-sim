# Backlog

This backlog is intentionally coarse. Detailed tasks should be split when a slice is approved.

## Now

- Add trade-in seller slice after the multi-buyer sale loop gets manual approval.
- Keep used-game pricing distinct from fixed-price new game/hardware rules.
- Add optional "apply to all matching used items" pricing once multiple instances of the same product exist.
- Keep validation coverage current as the sale loop changes.

## First Playable Counter Loop

- Pick up an item from a receiving box. Done.
- Inspect product name, platform, condition, cost, and market value.
- Set a sale price. Done for used items.
- Place the item on a shelf/display rack. Done.
- Spawn one target buyer customer. Done.
- Let the customer find the item and queue at the register. Done, deterministic in-store claim.
- Support multiple waiting buyers. Done for two in-store buyers through `CustomerManager`.
- Add customer movement/path validation so buyers feel less scripted. Done with deterministic buyer movement from rack to register and bounded target checks.
- Ring up the item at the register. Done.
- Complete sale. Done.
- Record transaction. Done.
- Show end-of-day cash and profit summary. Done for in-memory sales via the backroom computer.

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
- Keep modular validation files under `game/tests/validation/` current as UI scenarios and scripts are added.
- Report manual QA for held-item visibility, upright stocked item placement, pricing panel readability, day summary readability, prompt readability, mouse capture, and rack/register/backroom/receiving-box composition after every interaction-loop change.
- Keep named validation screenshots current for main scene, receiving area, register counter, customer queue, and backroom summary.
- Do not add a standalone pricing terminal. Pricing belongs on used-item inspection/held-item actions; terminals are reserved for register sales/returns/trade-ins and future backroom management.
- Add debug test maps only when they are called by the validation gate or a documented manual checklist.
- Extend product data validation inside the local gate as product resources become more complex.
- Add save/load smoke tests to the local gate after persistence exists.
