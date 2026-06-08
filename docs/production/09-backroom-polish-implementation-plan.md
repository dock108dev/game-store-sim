# Backroom Polish Implementation Plan

This is the implementation plan for priority backlog item 2: backroom spatial and visual identity.

The intent is to make the backroom read as a working retail operations space while preserving the validated first playable loop. This is a visual and spatial pass, not a computer UI rewrite.

## Outcome

After this slice, a player should understand the backroom at a glance:

- Receiving is where supplier stock physically arrives.
- Storage is where ordered fixtures and overflow stock belong before placement.
- The computer is the management terminal.
- Service and paperwork belong in the backroom, but register work still happens at the register.
- Optional hidden-thread clues are discoverable without looking like required objectives.

## Non-Goals

- Do not redesign the backroom computer panel. That is roadmap slice 2.
- Do not add a pricing terminal.
- Do not move sales, returns, trade-ins, preorders, or service completion off the register.
- Do not add final art, branded assets, or real-world product/logos.
- Do not add complex decoration/build-mode systems.
- Do not make hidden-thread content mandatory.

## Current Surfaces To Protect

These surfaces must still work after every implementation stop:

- Center-reticle click-first interaction for receiving pickup, stocking, register work, and backroom computer use.
- Receiving box pickup and supplier-order delivery.
- Supplier note and mismatched serial optional clues.
- Backroom computer opening/closing and mouse-capture return.
- Storage fixture ordering, ghost preview, movement, rotation, snap, and placement.
- Buyer pathing, register queueing, trade-in seller, preorder customer, service customer, and suspicious customer spacing.
- Named validation screenshot capture at `1280x720`.

## Target Layout Read

The backroom should be split into five readable zones.

1. Receiving zone
   - Contains the receiving box and delivered supplier stock.
   - Supplier note is visible nearby but optional.
   - Delivered items look placed, not scattered or floating.

2. Storage zone
   - Contains storage shelves, closed boxes, and space for pending fixture placement identity.
   - Ordered fixture preview still reads as pending placement rather than finished inventory.

3. Management zone
   - Contains the backroom computer and a modest desk/operations surface.
   - Reads as office/management, not a second register.

4. Service and paperwork zone
   - Contains simple repair/service/paperwork props.
   - Supports the idea that service records exist without implying service completion happens here.

5. Movement and sightline zone
   - Keeps a clear player path through the backroom.
   - Keeps prompts readable from normal player height.
   - Keeps screenshots composed around meaningful scene landmarks.

## Slice Stops

Stop after each completed item below. Each stop must be validated, committed, and pushed before the next stop begins.

### Stop 0: Baseline Audit

Work:

- Run the current validation gate before scene edits.
- Inspect current backroom scene nodes, screenshot captures, prompt positions, and manual checks.
- Record any pre-existing issue in the implementation summary rather than fixing unrelated scope.

Acceptance:

- Worktree is clean before edits.
- Current gate result is known.
- Backroom implementation targets are confirmed from the real scene.

Validation:

- `scripts/validate_godot.sh`

Commit/sync:

- No commit is needed if no files changed.

### Stop 1: Backroom Zone Blockout

Work:

- Adjust backroom spatial layout, floor/wall/material separation, and major zone anchors.
- Keep the receiving box, computer, supplier note, hidden clue, and player path readable.
- Use simple graybox props and existing materials only.

Likely files:

- `game/scenes/world/graybox_store.tscn`
- Existing scene scripts or tests only if node names, positions, or screenshots require updates.

Acceptance:

- The backroom reads as distinct from the sales floor.
- Receiving, storage, management, service/paperwork, and clear movement zones are visually separable.
- The player can still reach and click all current interactables.
- Customer/register area spacing is not degraded.

Validation:

- `scripts/validate_godot.sh`
- Manual spot check: backroom zones, computer identity, prompt readability, screenshot composition.

Commit/sync:

- Commit message: `Polish backroom zone layout`
- Push before Stop 2.

### Stop 2: Receiving And Storage Prop Pass

Work:

- Add or reposition boxes, shelves, storage props, and receiving-support props.
- Make delivered supplier stock and pending storage placement read as physical operations.
- Keep supplier note and suspicious serial clue optional and unobtrusive.

Likely files:

- `game/scenes/world/graybox_store.tscn`
- `game/tests/gut/test_graybox_store.gd` or screenshot tests if layout assertions require updates.
- `docs/production/07-current-manual-playtest.md`
- `game/tests/validation/scenarios/manual_checks.json`

Acceptance:

- Delivered stock appears intentionally staged near receiving.
- Storage props add identity without blocking the rack, receiving box, player path, or prompts.
- Hidden-thread artifacts remain optional and nonblocking.
- Fixture ghost preview remains visible and distinguishable from real racks.

Validation:

- `scripts/validate_godot.sh`
- Manual spot check: receiving clutter, storage readability, supplier note optionality, fixture ghost readability.

Commit/sync:

- Commit message: `Polish receiving and storage props`
- Push before Stop 3.

### Stop 3: Management And Service Identity Pass

Work:

- Strengthen computer/desk/management visual identity.
- Add service/paperwork graybox props that support the existing service loop without moving service completion from the register.
- Confirm the computer still reads as the only backroom terminal.

Likely files:

- `game/scenes/world/graybox_store.tscn`
- Existing tests only if positions or screenshots change.
- `docs/production/07-current-manual-playtest.md`
- `game/tests/validation/scenarios/manual_checks.json`

Acceptance:

- Backroom computer reads as management.
- Service/paperwork props read as backroom context, not a new interaction target.
- Register remains the clear surface for sales, trade-ins, preorders, and services.
- Management props do not crowd the panel opening angle or mouse-capture flow.

Validation:

- `scripts/validate_godot.sh`
- Manual spot check: computer placement, service props, register/backroom responsibility split.

Commit/sync:

- Commit message: `Polish backroom management area`
- Push before Stop 4.

### Stop 4: Screenshot And Manual Validation Sync

Work:

- Review named screenshots generated by the gate.
- Update manual checklist wording to match the actual polished backroom.
- Add or rename screenshots only if the current captures no longer prove the intended regression surface.

Likely files:

- `docs/production/06-validation.md`
- `docs/production/07-current-manual-playtest.md`
- `game/tests/validation/scenarios/manual_checks.json`
- Screenshot capture scripts only if necessary.

Acceptance:

- Manual validation explicitly covers the final backroom zones.
- Screenshot composition remains useful, not merely nonblank.
- Automated validation matrix still meets thresholds.

Validation:

- `scripts/validate_godot.sh`
- Human review of `artifacts/validation/latest/screenshots/receiving_area.png`, `supplier_message.png`, `backroom_summary.png`, `fixture_ghost.png`, and `fixture_placed.png`.

Commit/sync:

- Commit message: `Sync backroom polish validation`
- Push before leaving the slice.

## Show Stoppers

Stop and report before continuing if any of these occur:

- `scripts/validate_godot.sh` fails and the failure cannot be fixed narrowly inside the current stop.
- Backroom layout changes break pickup, stocking, register, computer, or fixture placement interactions.
- Backroom props create customer pathing or register spacing regressions.
- Required readability needs a computer UI redesign instead of scene/layout work.
- The pass needs non-graybox art assets before the current goal can be met.
- Manual screenshot review shows a regression that cannot be corrected without broad scene restructuring.

## Final Done Criteria

Item 2 is complete when:

- All slice stops above are either completed or explicitly marked not needed with evidence.
- `scripts/validate_godot.sh` passes at the final stop.
- Manual validation docs and `manual_checks.json` match the implemented backroom.
- Implementation summary says which manual checks were performed, skipped, or deferred.
- The branch is clean, committed, and pushed after the final stop.
