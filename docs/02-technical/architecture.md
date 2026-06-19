# Technical Architecture

This architecture assumes Godot 4, but the system boundaries should survive if the engine changes.

## Project Layout

Proposed future engine project layout:

```text
game/
  project.godot
  scenes/
    main/
    store/
    fixtures/
    items/
    customers/
    ui/
  scripts/
    autoload/
    systems/
    components/
    ui/
    tests/
  data/
    products/
    platforms/
    starter_shipments/
    fixtures/
    customers/
  assets/
    models/
    materials/
    textures/
    audio/
  tests/
```

Repo-level docs remain outside the engine project in `docs/`.

## Autoloads Or Global Services

Recommended first autoloads:

- `GameState`
- `SaveSystem`
- `EventLog`

Avoid turning every system into a global. Prefer scene-owned systems where possible.

## Major Systems

### InteractionController

Responsibilities:

- raycast target detection
- interaction prompt data
- pick up item
- place item
- inspect item
- enter register interaction
- enter layout interaction

### InventoryManager

Responsibilities:

- create item instances
- track item ids
- move items between locations
- validate sellable state
- expose item data to UI
- mark items sold

### FixtureManager

Responsibilities:

- register fixtures
- expose shelf slots
- validate placement
- update item slot occupancy
- expose browse points

### LayoutEditSystem

Responsibilities:

- select fixture
- show placement ghost
- validate floor placement
- rotate fixture
- commit/cancel placement
- notify navigation/customer systems

### StoreDayManager

Responsibilities:

- track day phase
- open store
- stop new customer entry
- allow close when floor is clear
- advance to report phase

### CustomerDirector

Responsibilities:

- spawn customers at mall path points
- decide enter/pass behavior
- assign archetype
- control customer wave for first playable
- stop new spawns at closing

### CustomerAgent

Responsibilities:

- walk
- browse
- select item
- queue
- checkout
- exit

### RegisterSystem

Responsibilities:

- manage active customer
- display sale details
- confirm transaction
- transfer item out of inventory
- record transaction event

### ReportSystem

Responsibilities:

- read event log
- summarize day
- show daily report UI
- produce next-day notes

### SaveSystem

Responsibilities:

- serialize state
- deserialize state
- version saves
- handle migration later
- validate loaded state

## Event Log

The report system should be event-driven.

Examples:

- `item_received`
- `item_priced`
- `item_stocked`
- `store_opened`
- `customer_entered`
- `item_sold`
- `store_closed`

Events should not replace state. They should support reporting, debugging, and validation.

## Scene Philosophy

Scenes should represent things the player understands:

- store shell
- fixture
- item
- customer
- register
- UI panel

Avoid hiding game concepts inside abstract scene names.

## Testing Philosophy

Core logic should be testable without walking the full 3D scene.

Testable units:

- pricing calculations
- item location transitions
- fixture slot validation
- save/load round trip
- day phase transitions
- register transaction output
- report summaries

3D integration should be covered by smoke tests and screenshot/manual validation.

