# Development Process

## Working Style

This project should be built like an indie game that expects scope pressure:

1. Plan the loop.
2. Build the smallest playable version.
3. Test by playing it.
4. Move repeated values into data.
5. Expand one system at a time.
6. Keep the game shippable after every milestone.

The project should avoid long periods where many systems are half-started and nothing is playable.

## Decision Log

Major decisions should be recorded in docs before they become invisible assumptions.

Examples:

- Engine choice.
- Perspective.
- Product naming rules.
- Save format.
- Inventory identity model.
- Customer AI complexity.
- Art style.
- Hidden thread boundaries.

Use short entries:

```text
Decision:
Reason:
Rejected alternatives:
Follow-up risk:
```

## Prototype Discipline

Prototype code is allowed, but prototype direction should still be intentional.

Throwaway prototype:

- Used to answer one question.
- Can be messy.
- Does not become production by accident.

Production slice:

- Has an acceptance checklist.
- Uses the intended architecture where it matters.
- Can be expanded without immediate rewrite.

## Slice Review Cadence

After each slice, answer:

- What did the player do most often?
- Was that action fun, clear, and repeatable?
- What system created the most friction?
- What system created the most interesting decision?
- Which planned feature now looks unnecessary?
- Which data fields were missing?
- What should be built next, and what should wait?

## Backlog Buckets

Keep work grouped by game value:

- Player feel: movement, camera, held items, prompts, feedback.
- Retail loop: stocking, pricing, register, trade-ins, ordering.
- Simulation: customers, demand, economy, theft, reputation.
- Store building: fixtures, layout, decoration, expansion.
- Content: products, categories, events, dialogue, suppliers.
- Persistence: save/load, settings, migration.
- Tooling: debug UI, test maps, validation scripts.
- Narrative: hidden flags, suspicious events, evidence objects.
- Polish: audio, animation, lighting, effects, UX.

## Definition Of Done

A feature is done when:

- It is playable without debug-only steps.
- The player receives feedback for success and failure.
- Important values are data-driven or explicitly accepted as code constants.
- It works across a full in-game day if the day loop exists.
- `scripts/validate_godot.sh` passes locally.
- UI validation automation coverage stays at or above 80% for active scenarios.
- Script test mapping coverage stays at or above 80% for production GDScript files.
- Critical smoke scenarios are automated, not manual-only.
- Any remaining manual validation is listed with the result in the change summary.
- It is documented if it changes the design model.

## Early Playtest Plan

Playtest with very small goals:

- Can a new player figure out what to do with a received box?
- Can they price and stock one item?
- Can they complete checkout without explanation?
- Do they understand why a customer bought or refused?
- Do they notice price, condition, and demand?
- Do they want to rearrange the store?

Do not ask playtesters whether they want huge future features until the first loop is understandable.

## When To Add Complexity

Add a new system only when it sharpens an existing decision.

Examples:

- Add condition grades after trade-ins are understandable.
- Add theft after layout and display value matter.
- Add employees after player travel time becomes a real bottleneck.
- Add preorders after ordering and shelf sales are working.
- Add hidden-thread consequences after normal supplier and inventory flows are established.
