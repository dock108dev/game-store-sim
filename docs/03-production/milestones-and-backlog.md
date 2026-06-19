# Milestones And Backlog

## Milestone 0: Documentation Baseline

Status: current milestone.

Done when:

- master plan exists
- vertical slice contract exists
- engine evaluation exists
- technical architecture exists
- validation plan exists
- source-of-truth rules exist

## Milestone 1: Engine Proof

Goal:

Prove the engine can support the core physical loop on macOS.

Required:

- create engine project
- basic mall/store shell
- first-person movement
- one pickup-able game case
- one shelf with valid slot
- one movable fixture
- one customer spawn path
- one save/load proof
- local validation script

Exit criteria:

- local Mac build runs
- validation script passes
- no script load errors
- screenshot proves nonblank store view

## Milestone 2: 0.0%-0.1% Opening Setup

Goal:

Player can enter closed store, receive shipment, price used stock, and stock shelves.

Required:

- starter shipment
- 10-20 physical item instances
- pricing panel
- shelf slot stocking
- fixture move/rotate/place
- save/load of items and fixtures

## Milestone 3: 0.3% First Sale

Goal:

Player opens the store and completes the first sale with physical customers.

Required:

- customer director
- mall spawn points
- browser behavior
- target buyer behavior
- register sale flow
- transaction recording

## Milestone 4: First Close

Goal:

Player closes the register and reads a useful daily report.

Required:

- closing phase
- floor-clear detection
- report generation
- cash/revenue/cost/margin summary
- inventory remaining summary
- save after close

## Milestone 5: First Playable Polish

Goal:

The 0.0%-0.3% slice is coherent enough for manual playtest.

Required:

- sound placeholders
- readable UI
- stable controls
- basic customer animation states
- Mac build packaging
- manual checklist pass

## Backlog After First Playable

Potential next systems:

- first supplier reorder
- multi-day progression
- trade-ins
- returns
- service counter
- launch calendar
- customer memory
- reputation
- supplier trust
- records integrity
- secret-web seed rules
- store expansion

## Backlog Discipline

A feature should not move into implementation unless it has:

- design owner
- build scope
- required data
- validation path
- definition of done

