# Hidden Thread

This document is intentionally spoiler-facing. It should not be used in store-page copy, tutorial text, or early player-facing marketing.

## Narrative Goal

The hidden thread should sit underneath normal retail systems. The player may never discover it. If they do, they should feel like they noticed something through careful operation: strange invoices, mismatched serials, oddly valuable trade-ins, customers who know too much, supplier pressure, cash payments, inventory that should not exist, or law enforcement questions that only make sense in hindsight.

## Core Shape

The store becomes a possible node in a gray-market pipeline. The activity may involve stolen goods, counterfeit collectibles, money laundering through rare items, mod chips, warranty fraud, or inventory laundering through trade-ins and supplier shipments.

The player can become:

- Oblivious operator: never notices, finishes as a normal store owner.
- Reluctant participant: takes suspicious deals for survival.
- Active bad actor: optimizes around illegal profit.
- Whistleblower: gathers evidence and exposes the network.
- Compromised witness: tries to exit after going too far.

## Design Rules

- Do not force discovery.
- Do not label suspicious choices as obviously criminal too early.
- Let normal systems carry the clues: receipts, serials, item condition, supplier names, customer behavior, missing paperwork, cash flow, security footage.
- Keep consequences proportional and delayed.
- Avoid making crime the only optimal path.
- Avoid turning the game into a police or combat game.

## Hidden Variables

Candidate flags:

- `suspicious_supplier_seen`
- `accepted_cash_no_receipt`
- `bought_serial_mismatch_item`
- `sold_counterfeit_as_authentic`
- `reported_suspicious_shipment`
- `destroyed_evidence`
- `kept_hidden_ledger`
- `law_enforcement_contacted`
- `supplier_trust`
- `community_trust`
- `legal_risk`
- `criminal_profit`

## Discovery Channels

Backroom:

- Unlabeled cartons.
- Inventory not matching purchase orders.
- Duplicate serial stickers.
- Locked cabinet.
- Security footage.

Computer:

- Supplier emails.
- Classified listings.
- Ledger discrepancies.
- Deleted messages.
- Price database anomalies.

Customers:

- A regular asks if "the other stock" came in.
- A seller brings too many rare sealed items.
- A collector identifies a fake.
- A parent returns a console reported stolen.
- A quiet buyer wants cash-only bulk purchases.

Register:

- Cash transactions below reporting thresholds.
- Refunds without matching sales.
- Gift card abuse.
- Trade credit manipulation.

## Escalation Stages

Stage 0: Normal operations.

- Suspicious content is absent or indistinguishable from retail noise.

Stage 1: Odd opportunities.

- A supplier offers cheap inventory with vague paperwork.
- A customer pays cash for unusual bulk goods.
- A trade-in item has a serial mismatch.

Stage 2: Pattern recognition.

- Repeated names, boxes, serials, or timing patterns emerge.
- The player can ignore, investigate, report, or profit.

Stage 3: Commitment.

- The player stores evidence, destroys evidence, accepts deeper deals, or contacts outside help.
- Regular retail consequences continue: reputation, cash, demand, rent.

Stage 4: Exposure.

- Police visit, journalist inquiry, supplier threat, customer confrontation, or public accusation.
- Outcome depends on evidence, player involvement, and trust.

## Implementation Approach

The hidden thread should be flag-driven and event-driven:

- Normal systems emit events: item acquired, serial checked, cash sale completed, supplier order received, return processed, customer complaint filed.
- Narrative rules listen for combinations of events.
- Suspicious events become eligible only when prerequisites and probability pass.
- The player discovers content through interactable artifacts and customer dialogue, not cutscenes.

This keeps the thread scalable. New suspicious items, suppliers, documents, and customer encounters can be added as data without rewriting the whole story.

