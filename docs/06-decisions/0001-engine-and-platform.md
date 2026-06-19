# Decision 0001: Engine And Platform Direction

## Status

Provisional.

## Decision

Target macOS first.

Use Godot 4 as the default prototype engine unless the engine proof shows it is a poor fit for the core game.

## Rationale

Godot appears well-suited for:

- first-person indie desktop sim development
- fast iteration
- readable project structure
- local validation
- macOS export
- documentation-heavy repo workflow

The team is not permanently committed until the engine proof passes.

## Required Proof

Before fully committing:

- first-person store shell
- physical item pickup
- shelf slot placement
- movable fixture
- physical customer spawn
- register sale
- save/load
- macOS build
- local validation command

## Consequences

- technical docs may assume Godot for now
- engine-specific code should not be written before the proof
- if Godot fails the proof, evaluate Unity next

