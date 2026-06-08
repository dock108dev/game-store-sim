# Production Polish Execution Plan

This is the active execution plan after the completed backroom spatial pass. It breaks the remaining polish backlog into validated, committable slices.

Every slice follows the same rule:

1. Implement the smallest player-facing improvement.
2. Update tests and manual validation docs in the same slice.
3. Run `scripts/validate_godot.sh`.
4. Commit.
5. Push.
6. Continue to the next slice unless a showstopper blocks progress.

## Current Completed Slice

Backroom spatial and visual identity is complete.

Completed commits:

- `689c635` Polish backroom zone layout
- `683dfbd` Polish receiving and storage props
- `af817ff` Polish backroom management area
- `65e85b6` Sync backroom polish validation

## Slice 3: Backroom Computer And Menu Information Architecture

Status: complete.

Goal: make the backroom computer read as a management interface instead of a long debug summary.

### Stop 3.0: Computer IA Baseline

Work:

- Inspect the current `DaySummaryPanel` scene/script and tests.
- Confirm current screenshot composition.
- Identify text/actions that belong to dashboard, inventory, ordering, releases, storage, and day controls.

Acceptance:

- No behavior changes.
- Current gate status is known.

Validation:

- `scripts/validate_godot.sh` if any docs/tests change.

Commit:

- No commit if no files changed.

### Stop 3.1: Sectioned Management Readout

Work:

- Add clear section headings or grouped blocks for dashboard, activity, inventory, market, supplier, releases, and storage.
- Keep the existing panel compact enough for `1280x720`.
- Preserve current accounting text and existing data sources.

Likely files:

- `game/scenes/ui/day_summary_panel.tscn`
- `game/scripts/ui/day_summary_panel.gd`
- `game/tests/gut/test_day_summary_panel.gd`

Acceptance:

- The panel no longer reads as one undifferentiated text stream.
- Existing summary, report, activity, inventory, demand, market, release, supplier, and fixture information is still present.
- Panel opens/closes with mouse capture unchanged.

Validation:

- `scripts/validate_godot.sh`
- Screenshot spot check: `backroom_summary.png`, `release_calendar.png`, `release_allocation.png`, `launch_day.png`.

Commit:

- `Section backroom computer readouts`

### Stop 3.2: Action Grouping And Button Copy

Work:

- Group actions by operation: supplier, storage, release planning, day control.
- Shorten or clarify button labels and disabled-state context where needed.
- Keep register-only flows out of the backroom computer.

Likely files:

- `game/scenes/ui/day_summary_panel.tscn`
- `game/scripts/ui/day_summary_panel.gd`
- `game/tests/gut/test_day_summary_panel.gd`
- `docs/production/07-current-manual-playtest.md`
- `game/tests/validation/scenarios/manual_checks.json`

Acceptance:

- Supplier ordering, rack ordering/placement, release allocation, and day advance controls are visually separable.
- Fixture movement controls still fit.
- Buttons remain testable and current behavior is unchanged.

Validation:

- `scripts/validate_godot.sh`
- Manual doc focus: button labels, disabled states, mouse capture, no register confusion.

Commit:

- `Group backroom computer actions`

### Stop 3.3: Computer IA Validation Sync

Work:

- Add or update validation scenarios for sectioned computer readout and action grouping.
- Mark roadmap/backlog item 3 complete.
- Update implementation notes with validation and manual status.

Acceptance:

- Manual checklist matches the final UI.
- Automated matrix includes relevant computer IA evidence.
- Roadmap points to item 4 as next target.

Validation:

- `scripts/validate_godot.sh`

Commit:

- `Sync backroom computer validation`

### Slice 3 Result

Completed commits:

- `3063007` Section backroom computer readouts
- `b6d9a91` Group backroom computer actions

Validation:

- `scripts/validate_godot.sh` passed after readout sectioning.
- `scripts/validate_godot.sh` passed after action grouping.
- Screenshot spot review covered `backroom_summary.png`, `release_calendar.png`, `release_allocation.png`, and `fixture_ghost.png`.

Manual validation status:

- Manual checklist and `manual_checks.json` are updated for the grouped computer controls.
- Human controller/window validation is not performed by Codex; check button grouping, mouse capture, disabled states, and no register/backroom responsibility confusion during manual playtest.

## Slice 4: Customer Readability And Role Silhouettes

Goal: make customer roles readable before interaction.

### Stop 4.1: Role Color And Prop Pass

Work:

- Adjust buyer, trade-in seller, preorder customer, service customer, and suspicious customer visual treatment.
- Add simple role props where useful: trade-in item, preorder slip, service disc, suspicious cash cue.
- Keep prompts and interactions unchanged.

Validation:

- Customer, register spacing, screenshot, and manual checks.

Commit:

- `Polish customer role silhouettes`

### Stop 4.2: Register Area Spacing And Facing

Work:

- Tune special-customer placements and facing.
- Keep buyer queue clear and readable.
- Preserve existing spacing tests or tighten them if useful.

Validation:

- `scripts/validate_godot.sh`
- Screenshot spot check: `register_counter.png`, `customer_queue.png`, `trade_in_offer.png`, `preorder_deposit.png`, `service_request.png`, `suspicious_customer.png`.

Commit:

- `Polish register customer spacing`

### Stop 4.3: Customer Validation Sync

Work:

- Update manual checks and scenario matrix.
- Mark roadmap/backlog item 4 complete.

Commit:

- `Sync customer polish validation`

## Slice 5: Store Lighting, Materials, Signage, And Retail Clutter

Goal: make the sales floor read as a small specialty game shop without hiding interactions.

### Stop 5.1: Lighting And Material Contrast

Work:

- Tune store light warmth and wall/floor contrast.
- Keep reticle, prompts, shelf slots, and product cases readable.

Commit:

- `Polish store lighting and materials`

### Stop 5.2: Fictional Signage And Zone Labels

Work:

- Add fictional store identity signage.
- Add readable world signage for register, backroom, receiving, and display areas.
- Avoid real brands.

Commit:

- `Add fictional store signage`

### Stop 5.3: Controlled Retail Clutter

Work:

- Add posters, bins, price signs, display tags, and small props.
- Keep clutter noninteractive unless explicitly needed.
- Do not obscure shelf slots or prompts.

Commit:

- `Add readable retail clutter`

### Stop 5.4: Store Visual Validation Sync

Work:

- Update manual checklist and scenario matrix.
- Mark roadmap/backlog item 5 complete.

Commit:

- `Sync store visual validation`

## Slice 6: Product And Fixture Presentation

Goal: make product cases, racks, receiving, carried items, and fixture states more intentional.

### Stop 6.1: Used-Game Case Polish

Work:

- Improve case material contrast and cover-label readability.
- Keep case size compact for rack, carry, receiving, and customer hands.

Commit:

- `Polish used game cases`

### Stop 6.2: Shelf Slot And Rack Polish

Work:

- Add clearer slot/category affordances.
- Improve placed rack versus ghost readability.

Commit:

- `Polish shelf and rack presentation`

### Stop 6.3: Carry And Receiving Presentation

Work:

- Tune carried stack and receiving-box item placement if visual polish changed readability.

Commit:

- `Polish carry and receiving presentation`

### Stop 6.4: Product Validation Sync

Work:

- Update manual checklist and scenario matrix.
- Mark roadmap/backlog item 6 complete.

Commit:

- `Sync product polish validation`

## Slice 7: Full Polish Validation Tightening

Goal: make the manual checklist and validation matrix fully current after the polish pass.

### Stop 7.1: Manual Playtest Checklist Audit

Work:

- Remove stale wording.
- Group manual playtest by workflow and polish focus.
- Make skipped/not-performed status explicit.

Commit:

- `Audit manual polish checklist`

### Stop 7.2: Scenario Matrix Audit

Work:

- Ensure new visual/UI scenarios are represented.
- Automate critical checks where practical.
- Keep manual-only checks justified.

Commit:

- `Audit polish validation matrix`

### Stop 7.3: Final Phase Exit Sync

Work:

- Mark completed roadmap items.
- Summarize validation evidence and remaining risks.
- Confirm next backlog phase.

Validation:

- `scripts/validate_godot.sh`
- Manual playtest status noted as performed, skipped, or deferred.

Commit:

- `Complete production polish validation sync`

## Showstoppers

Stop and ask for direction only if:

- The validation gate fails and cannot be fixed narrowly inside the active slice.
- A visual/menu change requires a product decision outside the current docs.
- The next useful improvement requires non-graybox art assets that do not exist.
- A required UI redesign conflicts with the current register/backroom responsibility split.
- Manual validation reveals a player-feel issue that needs direct user preference before continuing.
