# Core Loop And Systems

## Primary Loop

1. Open the store.
2. Review cash, stock, orders, pending preorders, and today events.
3. Receive or order inventory.
4. Price, sort, and stock items.
5. Serve customers through browsing, questions, trade-ins, checkout, returns, and negotiations.
6. Adjust layout, displays, and prices based on demand and problems.
7. Close the store, reconcile register, inspect losses, pay bills, and plan tomorrow.

This loop should work before broad content exists. If selling one fictional used game from one shelf to one customer is not fun, adding fifty categories will not fix it.

## Player Modes

Explore mode:

- First-person movement.
- Inspect objects.
- Pick up, carry, place, and rotate stock or fixtures.
- Talk to customers.
- Use terminals, register, safe, and backroom tools.

Workstation mode:

- Register checkout.
- Trade-in appraisal.
- Product pricing.
- Catalogue ordering.
- Inventory search.
- Store report.
- Hidden records, if discovered.

Build mode:

- Place fixtures.
- Assign shelf categories.
- Edit signage, wall paint, flooring, lights, and decorations.
- Validate customer pathing and register queue space.

## Customer System

Customers should be data-driven agents with a small number of clear goals.

Core customer types:

- Browser: wanders, may buy based on shelf appeal.
- Target buyer: wants a specific item or category.
- Parent gift buyer: has vague constraints and needs recommendations.
- Collector: cares about rarity, condition, completeness, and authenticity.
- Trade-in seller: brings items and negotiates.
- Return customer: tests policy, mood, and reputation.
- Regular: develops memory of past experiences.
- Suspicious contact: appears normal unless the hidden thread advances.

Customer state:

- Budget.
- Patience.
- Knowledge level.
- Desired categories.
- Price sensitivity.
- Trust in store.
- Suspicion or risk flags.
- Memory of prior interactions.

Core decisions:

- Enter or skip store.
- Browse path.
- Ask for help.
- Join queue.
- Buy, abandon, haggle, or complain.
- Sell/trade, accept offer, counter, or leave.

## Inventory System

Inventory should be one unified model. New games, used games, consoles, cards, accessories, and suspicious goods should be different item types on top of the same base data.

Base item fields:

- Item id.
- Display name.
- Category.
- Platform or product family.
- Condition.
- Completeness.
- Authenticity confidence.
- Cost basis.
- Market value.
- Current price.
- Demand score.
- Rarity score.
- Legal/risk flags.
- Location: box, backroom, shelf slot, display case, register, customer cart, repair bench.

Derived values:

- Suggested price.
- Expected days to sell.
- Margin.
- Theft risk.
- Collector appeal.
- Trade-in offer range.
- Reputation impact if mispriced or misrepresented.

## Register System

The register is a full interaction surface, not just a sell button.

Minimum version:

- Scan items.
- Show cart lines, subtotal, tax, total.
- Accept cash/card.
- Calculate change.
- Complete sale.

Later:

- Returns and exchanges.
- Trade credit.
- Store memberships.
- Preorders and deposits.
- Warranty/cleaning add-ons.
- Manual discounts.
- Suspicious cash transactions.
- Register balancing at close.

## Trade-In System

Trade-ins are a signature loop.

Player steps:

1. Inspect item.
2. Identify product.
3. Check condition and completeness.
4. Detect obvious fake/damaged goods.
5. See market value and internal demand.
6. Offer cash or store credit.
7. Customer accepts, counters, or leaves.

The fun should come from judgment under imperfect information. Early game can provide obvious condition cues. Later upgrades can add disc resurfacing, cartridge testing, authenticity tools, price databases, and staff expertise.

## Shelf And Layout System

Fixtures are functional:

- Shelf: general products.
- Locked case: high-value items, lower theft, slower browsing.
- Peg wall: accessories and small items.
- Bargain bin: high throughput, low margin, messy.
- Counter rack: impulse buys.
- Demo kiosk: drives demand but takes space and can break.
- Backroom rack: storage, receiving, hidden thread opportunities.

Layout effects:

- Product visibility.
- Customer pathing.
- Queue friction.
- Theft opportunity.
- Staff/player travel time.
- Category adjacency bonuses.
- Decoration/reputation modifiers.

## Store Computer

The computer is the player-facing management hub:

- Ordering.
- Price database.
- Inventory search.
- Sales reports.
- Bills and rent.
- Preorders.
- Supplier messages.
- Local forums/classifieds.
- Repair tickets.
- Security footage.
- Hidden ledgers or suspicious communications, if discovered.

## Data-First Content

The implementation should make new content cheap. Product families, customer archetypes, fixtures, events, suppliers, and dialogue should live in data resources or external data files before they become hard-coded branches.

Early data categories:

- `products`
- `product_conditions`
- `fixtures`
- `customer_archetypes`
- `dialogue_nodes`
- `daily_events`
- `suppliers`
- `store_upgrades`
- `narrative_flags`

