# Full-Day Playtest

Use this for internal QA after the smoke playtest passes.

## Required Start

Run `scripts/validate_godot.sh` first. Do not start manual full-day QA from a failing gate.

## Day-One Retail Loop

1. Start a fresh game.
2. Receive starter stock.
3. Pick up multiple products and confirm the carry stack stays low/right with the reticle clear.
4. Price at least two used games, including one apply-to-matching batch.
5. Stock products into the appropriate fixture slots.
6. Confirm a buyer chooses an acceptable product and ignores mismatched or overpriced stock.
7. Complete a register sale and verify cash, sale count, revenue, cost, and profit.
8. Process one return review and confirm refund, disposition, receiving-review copy, and reputation handling.
9. Process one trade-in and confirm cash/store-credit option language.
10. Process one preorder deposit and confirm it reads as an obligation, not a sale.
11. Process one service customer and confirm service revenue, cost, profit, and pickup state.
12. Open the backroom computer and verify dashboard, inventory, ordering, releases, services, storage, settings, and records.
13. Order a supplier lot, end the day, start the next day, open the delivered box, check invoice, sort stock, store one item, and pull it back.
14. Commit a release allocation, advance to launch day, and confirm preorder fulfillment, launch sales, and reputation consequences.
15. Order, move, rotate, cancel, and place a fixture ghost.
16. Apply a decoration or upgrade when available and confirm cash and world-state changes.
17. Save, load, overwrite, delete a slot, and confirm mouse capture returns correctly.

## Optional Hidden Thread

1. Inspect the mismatched serial product.
2. Read the supplier note.
3. Talk to the suspicious customer.
4. Confirm normal retail work remains available and no hidden objective blocks the day.
5. Open Records and confirm optionality language remains clear.

## Presentation Checks

- Audio cues support actions without masking prompts.
- Camera bob, FOV changes, held-item sway, and workstation settling remain comfortable.
- Customer role cues are readable before relying on label text.
- UI panels do not clip or squeeze at 1280x720.

## Output

Record pass/fail notes against the smallest affected surface: prompt, product, customer, register, backroom computer, fixture placement, save/load, release wrapper, or screenshot composition.
