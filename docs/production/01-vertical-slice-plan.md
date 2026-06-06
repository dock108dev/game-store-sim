# Vertical Slice Plan

## Slice Goal

Build one playable day in a tiny game store where the player receives a box of used games, prices them, stocks a shelf, serves customers, completes register transactions, and closes the day.

This is the first serious proof. It should be ugly but complete.

## Slice Content

Store:

- One small rectangular storefront.
- Front door.
- Counter/register.
- One shelf.
- One backroom receiving area.
- One backroom computer for day summary and future management actions.

Products:

- 12 fictional used games. Done in the data catalog.
- 3 platforms. Done.
- 4 conditions. Done.
- 3 demand tiers. Done.
- No real names or real brands. Enforced by catalog tests.

Customers:

- 1 browser.
- 2 target buyers for the current queue smoke.
- 1 trade-in seller, if trade-ins are included in the first slice.

Workstations:

- Register.
- Direct held-item pricing for used items.
- Backroom computer.
- Simple inventory list later.

## Required Player Actions

- Walk around store.
- Pick up a boxed item.
- Inspect item.
- Set item price.
- Place item on shelf.
- Interact with customer.
- Scan item at register.
- Complete sale.
- Close store.

## Acceptance Criteria

Functional:

- Player can complete a day from open to close.
- At least one customer buys a stocked item.
- Transaction records sale revenue and profit.
- Stock decreases after sale.
- Price affects recorded profit.
- Customer gives basic feedback. Done for overpriced used-item refusal and checkout messages.

Usability:

- Interaction prompts are readable.
- Held items do not block the whole screen.
- Valid shelf placement is obvious.
- Register flow can be completed without guessing.
- Backroom summary can be opened without guessing.
- UI text fits at common desktop resolutions.

Technical:

- Product definitions are data-driven.
- Item instances can be unique.
- Register does not delete items until sale completion.
- Customer selection queries store inventory rather than hard-coded objects.
- Day summary is derived from recorded transactions.

## Explicit Non-Goals

- No employees.
- No full fixture or decoration ordering system.
- No large store expansion.
- No player-facing save/load slot UI yet; only codec-level persistence smoke exists.
- No complex hidden narrative scene.
- No real-world game brands.
- No polished art pass.

## Prototype Tasks

1. Initialize Godot project. Done.
2. Build graybox store. Done.
3. Add first-person controller. Done.
4. Add interactable base class. Done.
5. Add item data and item instance data. Done.
6. Add pickup/hold/place behavior. Done.
7. Add shelf slot component. Done.
8. Add pricing UI. Done for direct used-item pricing from the held item. No standalone pricing terminal.
9. Add register UI. Done as one-action checkout for a waiting buyer.
10. Add transaction log. Done for in-memory sale records.
11. Add customer spawn and simple buy goal. Done for one deterministic in-store buyer.
12. Add end-of-day summary. Done for in-memory cash, sales, revenue, cost, and profit via the backroom computer.
13. Add simple customer queue. Done for two in-store buyers and three display slots.
14. Add customer movement/path validation. Done with deterministic buyer movement to stocked items, queue movement, and in-store target checks.
15. Add optional apply-to-matching used-item pricing. Done in the direct pricing panel for active matching copies.
16. Add first trade-in seller. Done as a register-reviewed trade-in with condition/market/demand details, cash counteroffer adjustment, store-credit acceptance, decline, and accepted item movement into receiving inventory.
17. Add first product catalog. Done with 12 fictional used games, three platforms, four conditions, three demand tiers, and automated catalog validation.
18. Add first customer price sensitivity. Done with demand-based buyer refusal for overpriced matching used games.
19. Add first persistence smoke. Done as a codec-level save/load roundtrip for session, ledger, active item state, and pending fixture orders.
20. Add first fixture ordering interface. Done as a backroom-computer order action for a pending game display rack.
21. Add first fixture ghost preview. Done as a translucent pending-rack preview after ordering; rotate, snap, validity coloring, and final placement remain later.
22. Add first fixture placement validity state. Done as green valid and red invalid translucent ghost states with bounds validation; rotate, snap, and final placement remain later.
23. Add first fixture rotate and snap controls. Done as manager-level fixed-step rotation and grid movement; player-facing placement confirmation remains later.
24. Add shelf category assignment. Done as explicit slot category assignment and fixture order slot-category metadata for used-game display racks.
25. Add basic customer path validation. Done for customer spawn bounds, queue spacing, display targets, and item approach positions.
26. Add category demand. Done as a category-level demand policy that combines with product demand tiers for buyer price tolerance and backroom demand readouts.
27. Add market drift. Done as deterministic day/category/tier market-value drift surfaced through the backroom computer for active inventory.
28. Add daily report. Done as an explicit closed-day report with cash change, sales/trade-ins, revenue, cost, trade spend/credit, and gross profit.
29. Add suspicious event flags. Done as a hidden, optional event log service with idempotent event flags and no visible normal-loop interruption.
30. Add mismatched serial item. Done as one optional receiving-box copy with serial mismatch metadata and hidden event flag support.
31. Add supplier message artifact. Done as an optional receiving-box note with supplier metadata, inspection text, hidden event flag support, and screenshot coverage.
32. Add optional evidence storage. Done as hidden deduped clue storage for serial mismatch and supplier message records.

## Slice Review Questions

- Is it satisfying to physically stock and sell items?
- Does price setting feel meaningful or busywork?
- Are customers readable enough without large dialogue trees?
- Is shelf placement smooth enough to support more fixtures later?
- Do unique used items create better decisions than generic stacks?
- What did the player do most often, and was that action good?
