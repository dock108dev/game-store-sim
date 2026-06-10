# Smoke Playtest

Use this after `scripts/validate_godot.sh` passes when you need a short playable sanity check.

Target time: 15 to 20 minutes.

## Setup

1. Launch the Godot project from `game/project.godot`.
2. Use keyboard/mouse desktop play.
3. Confirm the window is readable at 1280x720 or larger.
4. Confirm Escape releases or opens pause, and clicking returns to captured first-person control.

## Flow

1. Start a fresh game and look from spawn.
2. Confirm the space reads as `SAVE POINT GAMES`, not a blank debug room.
3. Pick up products from receiving.
4. Open the pricing panel for a used game.
5. Set a fair price and apply it.
6. Stock the item on the used-game rack.
7. Let a buyer select an item and queue at the register.
8. Complete one sale at the register.
9. Complete one return, trade-in, preorder deposit, or service checkout if the relevant customer is waiting.
10. Open the backroom computer.
11. Review dashboard, inventory, ordering, releases, records, and settings tabs for readable text.
12. Close the day and confirm the day report is readable.
13. Open pause, settings, save/load, and return to play.

## Pass

- The loop can be completed without confusion or broken controls.
- Prompts and UI are readable in the real window.
- No path, product, customer, or modal blocks the main loop.
- Any issue can be described by screenshot name and short failure reason.

## Fail

File the issue in `docs/production/13-alpha-bug-list.md` if a player cannot understand or complete the loop without prior repo knowledge.
