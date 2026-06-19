# Milestones And Backlog

## Milestone 0: Documentation Baseline

Status: complete.

Done when:

- master plan exists
- vertical slice contract exists
- engine evaluation exists
- technical architecture exists
- validation plan exists
- source-of-truth rules exist

## Milestone 1: Engine Proof

Status: implemented and locally validated.

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
- macOS export can be produced and launched headlessly

## Milestone 2: First 0.3% Visual Benchmark

Status: active next milestone.

Goal:

Make the first 0.3% of the game visually correct before expanding gameplay breadth. The engine proof scene is allowed to be discarded, rebuilt, or used only as technical reference.

Required:

- visual benchmark scene for the opening mall store
- mall concourse and storefront that read immediately
- empty lease that feels understocked, not unfinished
- receiving/backroom that feels operational
- counter/register area with early-2000s retail language
- starter fixtures with correct scale and shelf density
- one-to-one physical case/box visuals that support stock counts
- fictional product-box visual language
- warm nostalgic lighting pass
- camera height/FOV pass for Mac desktop play
- screenshot capture path for named visual targets
- macOS build export and launch
- visual sign-off checklist

Exit criteria:

- required visual benchmark screenshots are captured from the build
- screenshots are nonblank, correctly framed, and show the required spaces/states
- manual visual review marks every required target pass or intentional defer
- no new gameplay breadth has been added outside benchmark needs
- repo docs and task list match the signed-off scaffold

## Milestone 3: 0.0%-0.1% Opening Setup

Goal:

Player can enter closed store, receive shipment, price used stock, and stock shelves.

Required:

- starter shipment
- 10-20 physical item instances
- pricing panel
- shelf slot stocking
- fixture move/rotate/place
- save/load of items and fixtures

## Milestone 4: 0.3% First Sale

Goal:

Player opens the store and completes the first sale with physical customers.

Required:

- customer director
- mall spawn points
- browser behavior
- target buyer behavior
- register sale flow
- transaction recording

## Milestone 5: First Close

Goal:

Player closes the register and reads a useful daily report.

Required:

- closing phase
- floor-clear detection
- report generation
- cash/revenue/cost/margin summary
- inventory remaining summary
- save after close

## Milestone 6: First Playable Polish

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
