# Backlog

This backlog is intentionally coarse. Detailed tasks should be split when a slice is approved.

## Now

- Keep used-game pricing distinct from fixed-price new game/hardware rules.
- Keep validation coverage current as the sale loop changes.
- Use the 12-item fictional product catalog when expanding inventory sources.
- Use the backroom computer as the home for inventory and management features.

## First Playable Counter Loop

- Pick up an item from a receiving box. Done.
- Inspect product name, platform, condition, cost, and market value.
- Set a sale price. Done for used items.
- Optionally apply a used-item sale price to active matching copies. Done from the direct pricing panel.
- Place the item on a shelf/display rack. Done.
- Spawn one target buyer customer. Done.
- Let the customer find the item and queue at the register. Done, deterministic in-store claim.
- Support multiple waiting buyers. Done for two in-store buyers through `CustomerManager`.
- Add customer movement/path validation so buyers feel less scripted. Done with deterministic buyer movement from rack to register and bounded target checks.
- Ring up the item at the register. Done.
- Complete sale. Done.
- Record transaction. Done.
- Show end-of-day cash and profit summary. Done for in-memory sales via the backroom computer.
- Show active inventory summary. Done on the backroom computer from scene item instances.

## Trade-In Slice

- Add customer-carried used item. Done for one in-store trade-in seller.
- Add condition inspection UI. Done in the register trade-in offer panel.
- Add market value and demand lookup. Done in the register trade-in offer panel.
- Add cash/store-credit offer. Done for cash offers plus fixed store-credit offers.
- Add accept/counter/decline customer response. Done for cash accept, cash counteroffer adjustment, store-credit accept, and decline.
- Add acquired item to inventory. Done for accepted trade-ins moving into the receiving box.

## Store Layout Slice

- Add fixture and equipment ordering interface. Done for ordering a pending game display rack from the backroom computer.
- Add fixture ghost placement. Done as a translucent pending-rack preview after ordering.
- Add valid/invalid placement state. Done as green valid and red invalid translucent ghost states with bounds validation.
- Add rotate and snap controls. Done as manager-level fixed-step rotation and grid movement.
- Add shelf category assignment. Done as explicit slot category assignment and fixture order slot-category metadata for used-game display racks.
- Add basic customer path validation. Done for customer spawn bounds, queue spacing, display targets, and item approach positions.

## Economy Slice

- Add demand per category. Done as category-level multipliers that feed buyer price tolerance and the backroom demand readout.
- Add price sensitivity. Done for buyer refusal of overpriced matching used games.
- Add sales history. Done as recent sale/trade-in activity on the backroom computer.
- Add market drift. Done as deterministic day/category/tier market-value drift on the backroom computer for active inventory.
- Add daily report. Done as an explicit closed-day report with cash change, sales/trade-ins, revenue, cost, trade spend/credit, and gross profit.
- Add reorder suggestions. Done as simple backroom suggestions from sales versus active inventory.

## Hidden Thread Slice

- Add suspicious event flags. Done as a hidden, optional event log service with idempotent event flags and no visible normal-loop interruption.
- Add mismatched serial item. Done as one receiving-box used-game copy with serial metadata, mismatch detection, and optional suspicious-event flagging.
- Add supplier message artifact. Done as an optional receiving-box supplier note with metadata, inspection text, hidden-event flagging, and validation screenshot coverage.
- Add optional evidence storage.
- Add one suspicious customer encounter.
- Keep all hidden-thread content optional and avoid blocking normal store progression.

## Tooling

- Maintain the mandatory local validation gate in `scripts/validate_godot.sh`.
- Keep modular validation files under `game/tests/validation/` current as UI scenarios and scripts are added.
- Report manual QA for held-item visibility, upright stocked item placement, pricing panel readability, day summary readability, prompt readability, mouse capture, and rack/register/backroom/receiving-box composition after every interaction-loop change.
- Keep named validation screenshots current for main scene, receiving area, register counter, customer queue, trade-in offer, backroom summary, fixture ghost preview, invalid fixture ghost preview, and rotated fixture ghost preview.
- Do not add a standalone pricing terminal. Pricing belongs on used-item inspection/held-item actions; terminals are reserved for register sales/returns/trade-ins and future backroom management.
- Add debug test maps only when they are called by the validation gate or a documented manual checklist.
- Extend product data validation inside the local gate as product resources become more complex. Started with catalog count, uniqueness, variety, pricing sanity, and fictional-name checks.
- Add save/load smoke tests to the local gate after persistence exists. Done for the first codec-level session, ledger, and active-inventory roundtrip.
