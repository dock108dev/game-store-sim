# Vertical Slice Specification

## Purpose

The vertical slice validates the core gameplay loop, progression systems, store atmosphere, and long-term retention potential.

It is not feature complete. It should prove that the game can deliver the fantasy of operating and growing an early-2000s specialty video game retailer.

## Slice Goals

The vertical slice must prove:

- the store feels authentic
- the store has obvious room for growth
- buying, stocking, selling, and trade-ins are enjoyable
- progression feels meaningful
- inventory unlocks create long-term goals
- the environment no longer feels like a prototype
- core systems support future expansion

The slice should establish a foundation for the full game rather than attempt to implement every planned feature.

## Starting Store

The starting store progression has two visual states.

Pre-day-one setup starts with:

- one location
- owner-operated
- clean and new
- mostly empty fixture capacity
- a receiving/setup task flow
- a starter pack of roughly two unique games, one console, and one accessory
- no customers and no employees until the player opens the store

The first validated store state grows toward:

- a single location
- owner-operated
- about 1,500-2,000 square feet equivalent
- functional but unfinished
- visibly underfunded
- visibly understocked
- promising rather than empty

Pre-day-one environment targets:

- walls: 5-15% occupied
- floor: 15-30% occupied

First validated slice environment targets:

- walls: 25-40% occupied
- floor: 30-50% occupied

Future mature-store targets:

- walls: 80-95% occupied
- floor: 70-85% occupied

Open space should primarily exist for customer movement. Blank wall and floor areas should feel like growth opportunities, not missing art.

## Required Store Areas

The first-store design must support these areas, but the player does not need all of them fully stocked or fully unlocked on the first morning:

- entrance display
- new releases
- used games
- platform sections for Nova, Vertex, Prism, and Pocket
- checkout counter
- trade-in station at checkout
- one demo area with one kiosk and display screen
- bargain bin
- guides/media area

The mature store can later expand these areas, but the starting store must already communicate the intended business.

## Catalog Availability

The player should not have access to the full catalog at game start.

Starting catalog target after the initial setup:

- 15-25% of total catalog available
- primarily common games
- common accessories
- entry-level hardware

The player should frequently see that more products, distributors, platforms, fixtures, and opportunities exist but are not available yet.

Unlock sources:

- reputation
- distributor trust
- store growth
- industry progression
- special opportunities

Money alone should not unlock everything.

## Starting Visible Inventory

The opening store should be intentionally limited, not bare because art is missing.

Pre-day-one starter pack:

- about two unique game titles
- one console
- one accessory/controller
- one demo/display unit if the implementation packet includes it
- a few setup/receiving boxes

First validated slice target after early receiving and stocking:

- 40-60 games
- 5-10 accessories
- 5-10 guide/media items

This target can be achieved through lightweight visual facings and stocked item instances. It does not require every visual facing to be a fully interactive product on day one, but interactive inventory should align with the current mechanics.

## Required Fixtures

Pre-day-one starter fixtures:

- at least one product shelf/rack with visible empty capacity
- one checkout/trade-in counter
- one receiving/setup area
- one demo/display position if included in starter tasks

First validated slice fixture targets:

- 6 wall shelving units
- 4 gondola shelving units
- 1 checkout counter
- 1 trade-in station
- 1 demo kiosk
- 1 bargain bin

First validated slice decoration targets:

- 8 posters
- 4 promotional signs
- 4 platform signs

## Day Loop

The day loop is:

1. Preparation Phase
2. Open Store
3. Operating Phase
4. End Of Business Day
5. Closing Phase
6. Daily Summary
7. Next Day preparation

### Preparation Phase

The store is closed. Customers cannot enter.

The player may:

- receive shipments
- unpack inventory
- stock shelves
- move products
- reorganize displays
- adjust pricing
- review finances
- place distributor orders
- move fixtures
- prepare promotions

The player decides when the store is ready to open.

### Operating Phase

The player activates the store. The open sign turns on. Customers begin arriving during business hours.

Customers:

- browse
- inspect inventory
- ask for recommendations
- purchase products
- bring trade-ins

Major merchandising work should primarily happen while the store is closed.

### Closing Phase

Customer arrivals stop automatically at scheduled closing time, but the store does not auto-close.

Existing customers:

- continue browsing
- continue shopping
- may complete purchases
- may complete trade-ins already in progress
- eventually leave naturally

After the final customer exits:

- in-game time pauses
- no new customer events occur
- no new purchases occur
- no new trade-ins occur
- the player may keep working without time pressure

The player decides when to close out the register and advance.

## Required Systems

The vertical slice must support:

- inventory management
- product placement
- product purchasing
- customer browsing
- customer purchasing
- trade-ins
- daily finances
- product unlocks
- basic progression

## Required UI

The vertical slice needs:

- Store Dashboard: business overview
- Inventory Screen: inventory management, pricing, organization
- Ordering Screen: distributor ordering, locked inventory visibility, unlock requirements
- Daily Summary Screen: performance review

## Out Of Scope For The Vertical Slice

Not required:

- employees
- console launches
- midnight releases
- multiple store locations
- franchises
- online storefronts
- advanced economic simulation
- rare inventory systems
- hidden mystery progression
- collector networks
- industry contacts
- narrative events
- competitor stores

Some hooks may already exist. They should remain secondary until the store fantasy and core loop are validated.
