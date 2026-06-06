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
- One office computer placeholder.

Products:

- 12 fictional used games.
- 3 platforms.
- 4 conditions.
- 3 demand tiers.
- No real names or real brands.

Customers:

- 1 browser.
- 1 target buyer.
- 1 trade-in seller, if trade-ins are included in the first slice.

Workstations:

- Register.
- Pricing screen.
- Simple inventory list.

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
- Cash increases after sale.
- Stock decreases after sale.
- Price affects profit.
- Customer gives basic feedback.

Usability:

- Interaction prompts are readable.
- Held items do not block the whole screen.
- Valid shelf placement is obvious.
- Register flow can be completed without guessing.
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
- No real save/load requirement until after the first loop works, unless implementation makes it cheap.
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
8. Add pricing UI. In progress: direct used-item pricing from the held item. No standalone pricing terminal.
9. Add register UI.
10. Add transaction log.
11. Add customer spawn and simple buy goal.
12. Add end-of-day summary.

## Slice Review Questions

- Is it satisfying to physically stock and sell items?
- Does price setting feel meaningful or busywork?
- Are customers readable enough without large dialogue trees?
- Is shelf placement smooth enough to support more fixtures later?
- Do unique used items create better decisions than generic stacks?
- What did the player do most often, and was that action good?
