# Tech Stack And Architecture

## Recommended Stack

Engine: Godot 4.6.3 stable.

Why:

- Strong fit for an indie first-person 3D sim.
- Fast iteration without licensing friction.
- GDScript is productive for data-heavy simulation.
- Scenes/resources map well to fixtures, products, customers, and interactions.
- Built-in UI is good enough for supplier ordering, register, pricing, trade-in, and management screens.
- Export path is straightforward for desktop-first development.

Input target: keyboard/mouse only for the first playable and early production slices. Controller support is intentionally out of scope until the core retail loop is proven.

Supporting tools:

- Blender for simple props, fixtures, boxes, shelves, signage, and store shells.
- Krita, Affinity, or Aseprite for fictional box art, labels, posters, icons, and UI textures.
- Git once the project is initialized.
- Plain text data files or Godot resources for early content.
- GUT or equivalent Godot test framework once systems stabilize.

Avoid initially:

- Networked multiplayer.
- Controller-specific UI or input design.
- Real-time backend services.
- Procedural 3D asset generation.
- Complex ECS frameworks.
- Heavy plugin dependency before core interactions are proven.

## Project Shape

Target structure once implementation begins:

```text
game/
  project.godot
  scenes/
    world/
    player/
    store/
    ui/
    customers/
    props/
  scripts/
    interaction/
    inventory/
    economy/
    customers/
    store_layout/
    save/
    narrative/
  data/
    products/
    fixtures/
    customers/
    dialogue/
    suppliers/
    progression/
  assets/
    models/
    materials/
    textures/
    audio/
  tests/
```

The current repository is pre-code and only contains planning docs plus references. The `game/` folder should be created when we are ready to initialize the engine project.

## Architecture Principles

Data first:

- Products, fixtures, customers, supplier offers, and events should be authored as data.
- Code should interpret systems, not hard-code every content case.

Interaction first:

- Build a small reusable interaction contract before making many objects.
- Every object should expose what the player can do: inspect, pick up, place, scan, price, stock, buy, sell, repair, unlock, or read.

Simulation in layers:

- Inventory layer tracks items and locations.
- Economy layer calculates value, demand, margin, and price effects.
- Customer layer decides goals and actions.
- Store layout layer handles placement, visibility, pathing, and fixture slots.
- Narrative layer observes events and sets flags without owning normal retail logic.

Save early:

- Even prototypes should have a minimal save model once inventory and layout exist.
- Save format should preserve item identity, condition, price, location, store state, cash, day, and narrative flags.

## Core Runtime Systems

Interaction controller:

- Raycast from player camera.
- Highlight target.
- Show action prompt.
- Route input to target action.
- Support held objects and workstation transitions.

Inventory service:

- Owns item instances.
- Moves items between locations.
- Creates items from suppliers or customer trades.
- Retires items on sale, loss, disposal, or evidence handling.

Economy service:

- Calculates market value.
- Updates demand over time.
- Suggests prices.
- Applies event modifiers.
- Records sales history.

Customer director:

- Spawns customers based on time, reputation, events, and store appeal.
- Assigns goals.
- Tracks queue, patience, and satisfaction.
- Emits transaction opportunities.

Store layout service:

- Places fixtures.
- Validates collisions and paths.
- Owns shelf slots.
- Computes visibility and risk modifiers.

Narrative flag service:

- Watches for suspicious triggers.
- Tracks evidence and involvement.
- Unlocks hidden dialogue or documents.
- Never blocks the normal retail loop unless the player chooses to engage or consequences escalate.

## First Technical Risk List

- First-person item handling can feel clumsy if object snapping and prompts are unclear.
- Customer AI can become overbuilt before the retail loop is fun.
- Inventory identity can get messy if item stacks and unique used items are not separated early.
- Store layout can become expensive if pathing updates happen too often.
- UI can sprawl unless workstation screens share components.
- Hidden narrative can become brittle if it is written as one scripted path instead of flag-driven systemic events.

## Recommended Implementation Order

1. Minimal Godot project and first-person controller.
2. Interaction raycast, prompts, inspectable objects.
3. Item instance model and inventory locations.
4. Shelf slot and manual stocking.
5. Register scan and sale.
6. One customer goal: buy a category from a shelf.
7. End-of-day summary.
8. Trade-in appraisal.
9. Fixture placement.
10. Save/load.
