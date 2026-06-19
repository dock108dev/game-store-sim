# Decision 0001: Engine And Platform Direction

## Status

Accepted for prototype and first visual benchmark.

## Decision

Target macOS first.

Use Godot 4 as the prototype engine through the first 0.3% visual benchmark.

## Rationale

Godot appears well-suited for:

- first-person indie desktop sim development
- fast iteration
- readable project structure
- local validation
- macOS export
- documentation-heavy repo workflow

The engine proof passed. Full-game engine commitment remains subject to the visual benchmark and next production review.

## Completed Proof

The current proof covers:

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
