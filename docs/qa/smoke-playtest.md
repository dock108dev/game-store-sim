# Smoke Playtest

Use this after focused implementation work when you need a short playable sanity check.

Target time: 10 to 15 minutes.

## Setup

1. Run `scripts/validate_godot.sh` if the production scene changed.
2. Launch the Godot project from `game/project.godot`.
3. Use keyboard/mouse desktop play.
4. Confirm the window is readable at 1280x720 or larger.

## Flow

1. Start at the mall/storefront spawn.
2. Walk through the storefront threshold.
3. Pick up a product from receiving or starter stock.
4. Open pricing for a used game.
5. Stock an item on a shelf/rack.
6. Complete one register transaction if a customer is present for the tested state.
7. Open the backroom computer.
8. Confirm pause/settings/save/load still work.

## Pass

- Controls, prompts, and core interactions work.
- The player can move through the opening route.
- Register, receiving, and backroom computer remain interactable.
- No new visual module blocks the core route.

## Fail

Record the exact area and screenshot name in `docs/production/13-alpha-bug-list.md`.
