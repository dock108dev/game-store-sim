# Vertical Slice Contract

This document defines the first implementation target. If a feature is not listed here, it is not required for the first playable.

## Slice Name

0.0%-0.3%: Empty Lease To First Close

## Purpose

Prove the core tactile retail loop:

1. receive physical stock
2. price physical stock
3. stock physical shelves
4. open the store
5. serve physical customers
6. complete first sale
7. close the day
8. read report
9. save/load

## Player Starting State

The player starts before opening.

Initial state:

- store is closed
- no customers are inside
- mall concourse exists outside storefront
- starter shipment is in receiving
- store has limited cash
- store has one checkout counter
- store has one backroom computer
- store has several starter fixtures
- shelves are mostly empty
- open/closed sign is closed

## Required Spaces

The first store must include:

- mall concourse frontage
- glass storefront
- player entrance
- sales floor
- checkout counter/register
- receiving/backroom
- backroom computer
- at least two shelf/rack fixture types
- at least one movable fixture

## Required Player Verbs

The slice must support:

- walk
- look
- inspect
- pick up item
- carry item
- place item
- rotate/place fixture in layout mode
- price used item
- stock shelf slot
- open store
- interact with customer/register
- close register
- open daily report
- save game
- load game

## Required Inventory

The slice must include a starter shipment with:

- 10-20 physical game cases
- at least two fictional platforms
- at least one new product with fixed price
- several used products with suggested pricing
- at least one accessory or boxed item if feasible
- one harmless odd detail for atmosphere only

Each physical stock item must have:

- unique item id
- fictional product id
- display name
- platform/category
- condition
- cost basis
- price
- current location
- new/used status

## Required Pricing Rules

Used goods:

- show suggested price
- allow manual price adjustment
- show margin
- warn for below cost
- warn for far above suggested range

New goods:

- fixed price while considered new
- player cannot manually change price in the first playable
- UI should explain through state, not a long lecture

## Required Stocking Rules

Stocking must be physical.

Rules:

- one inventory item is one placed object
- shelves have valid slots
- shelves display approximate physical count
- fixture capacity must be readable
- item can move from box to hand to shelf
- item can move from shelf back to hand
- item location is saved

Shelf states:

- empty
- partially stocked
- stocked
- full

## Required Layout Rules

Layout customization is available immediately.

First playable must support:

- enter layout/edit mode
- move at least one fixture
- rotate fixture
- place fixture on valid floor area
- block invalid placement
- save fixture location
- customer navigation respects fixture placement at basic level

Not required:

- buying new fixtures
- wall editing
- painting
- carpet editing
- neighboring-unit expansion

## Required Customer Behavior

Customers must be physically present.

The first playable needs a minimal but real customer loop:

1. customer spawns from one of multiple mall path points
2. customer walks along mall concourse
3. customer may enter the store based on simple attraction rules
4. entering customer browses one or more shelves
5. customer may pick a product
6. customer queues at register
7. player completes sale
8. customer exits to mall

Minimum customer archetypes:

- Browser
- Target Buyer

Optional first-slice archetype:

- Parent Gift Buyer, if recommendation UI is cheap enough to build cleanly

## Required Register Flow

The register must support:

- customer arrives with selected item
- player interacts with register/customer
- sale summary appears
- player confirms sale
- cash increases by price
- inventory item transfers out of store stock
- transaction is recorded
- customer leaves

Not required:

- returns
- trade-ins
- services
- preorder deposits
- refunds
- receipts as physical props

## Required Day Flow

Day phases:

1. Prep
2. Open
3. Closing
4. Report
5. Next Day Ready

Prep:

- no customers enter
- player can receive, price, stock, move fixtures, save

Open:

- customers spawn
- store systems are active
- layout editing may be restricted or allowed in a limited way depending on implementation complexity

Closing:

- no new customers enter
- customers already inside finish or leave
- player can close register once floor is clear

Report:

- show sales
- show revenue
- show cost basis
- show gross margin
- show inventory remaining
- show simple restock notes

## Required Save/Load

Save/load must preserve:

- cash
- day number
- current day phase
- inventory items
- item prices
- item locations
- fixture positions
- sold item removal
- transactions

Saving during open hours may be allowed if it is technically stable. If not, the first playable may restrict saving to prep/report phases and must clearly communicate that state.

## Harmless Odd Detail

The first playable may include one strange starter-shipment detail:

- mismatched note in a box
- odd serial field
- off-manifest label
- supplier typo

Rules:

- no quest starts
- no secret route starts
- no penalty
- no tutorial callout
- it exists to prove the future mystery tone

## Explicitly Out Of Scope

- employees
- full secret web
- trade-ins
- returns
- services
- supplier reputation
- launch calendar
- rare inventory
- robberies
- inspections
- court outcomes
- neighboring unit expansion
- multi-day balancing beyond first close
- real-world products or brands

## Completion Criteria

The vertical slice is complete when:

- a player can complete the full first-day loop without developer assistance
- at least three customers can enter, browse, and leave or buy
- one sale affects cash, inventory, and report
- placed items and fixture positions survive save/load
- a macOS build runs locally
- validation gate passes
- manual playtest checklist passes

