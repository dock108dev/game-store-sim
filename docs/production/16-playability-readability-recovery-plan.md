# Playability Readability Recovery Plan

This is the active next implementation plan after the June 9 manual screenshot review.

The automated alpha gate is still valuable: movement, pickup, pricing, stocking, customers, register flows, services, ordering, storage, fixture placement, save/load, and package smoke remain mechanically protected. The manual evidence changes the release state: the build is not ready for external playtest because a player cannot reliably read the room, signs, prompts, customer roles, or pricing UI from normal play angles.

## Evidence

Manual screenshots reviewed on June 9, 2026:

- `/Users/michaelfuscoletti/Desktop/intro_1.png`
- `/Users/michaelfuscoletti/Desktop/receiveing.png`
- `/Users/michaelfuscoletti/Desktop/intro_2.png`
- `/Users/michaelfuscoletti/Desktop/pricing.png`

Observed blockers:

- Camera scale and framing make the ceiling, counter, signs, and nearby props dominate normal player view.
- Oversized signs and foreground boards occlude receiving items, racks, register context, and sightlines.
- The pricing modal and bottom prompt are too small and low-contrast for comfortable 1280x720 play.
- Floating customer labels are inconsistent in size and hierarchy, with `Trade-in?` dominating the scene while other role cues are tiny.
- Receiving is functional but visually cluttered; starter products, labels, signs, and props compete for the same screen space.
- The store still reads like debug-layout pieces despite many completed mechanical and polish passes.

## Current Decision

Pause external alpha playtest.

The next objective is not new mechanics. The next objective is to make the existing alpha loop human-validateable in a real window.

Recovery exit criteria:

- A fresh player can stand at spawn and identify the store, register, receiving, racks, customers, and backroom direction without explanation.
- A player can pick up, price, and stock a starter product without signs, props, prompts, or camera scale fighting the action.
- Pricing, register, trade-in, preorder, service, save/load, and backroom computer panels are readable at 1280x720.
- Customer role markers help orientation without becoming the main visual object in the scene.
- The backroom and receiving workflows read as physical work, not dense debug UI.
- The short screenshot capture set can be completed without stopping because the build is unreadable.

## Recovery Rules

- Do not add new gameplay systems during this phase.
- Do not solve readability by adding more labels over unclear scene composition.
- Favor camera, scale, placement, contrast, hierarchy, and layout fixes over decorative detail.
- Keep the click-first center-reticle interaction model.
- Keep the register/backroom responsibility split.
- Keep every slice shippable, validated, committed, and pushed before continuing.
- Update `07-current-manual-playtest.md`, `13-alpha-bug-list.md`, and this plan whenever a recovery slice changes manual expectations.
- Run `scripts/validate_godot.sh` before each implementation commit.
- Review screenshots after each visual/UI slice, even when automated validation passes.

## Slice 0: Recovery Planning And Docs Lock

Status: active in this docs slice.

Goal: make the manual blocker and next recovery sequence explicit before editing gameplay files.

Work:

- Mark external playtest as paused until readability recovery exits.
- Add P0/P1 readability blocker entries to the alpha bug list.
- Make the backlog and completion plan point to this recovery plan.
- Keep the existing alpha package as a paused handoff artifact, not the next action.

Acceptance:

- Docs agree that the repo is mechanically green but manually blocked for external playtest.
- Review order is explicit for the user.
- No gameplay behavior is claimed as fixed by this docs slice.

Validation:

- `git diff --check`
- `scripts/validate_godot.sh`

Commit target:

- `Plan readability recovery phase`

## Slice 1: Camera, Player Scale, And Spawn Composition

Status: implemented in `Fix alpha camera scale`.

Goal: make the first view and normal walking scale readable before touching detailed UI.

Work:

- Audit player camera height, FOV, near clip, collision capsule, and spawn rotation.
- Reduce ceiling dominance from normal view.
- Reframe spawn so the player sees the register, receiving/rack direction, and backroom direction without immediate occlusion.
- Establish a blocker budget for near-camera props and signs.

Acceptance:

- `01_spawn_first_view.png` reads as a store at a glance.
- Walking around the register and receiving area does not put large props or ceiling planes into most of the screen.
- The held item stack and reticle remain visible after scale changes.
- Automated coverage now locks the wider comfort FOV, tighter near clip, taller head height, lower/right held-item anchor, and spawn distance away from the register/special-customer pileup.

Manual screenshots:

- `01_spawn_first_view.png`
- `03_sales_floor_route.png`
- `22_backroom_entry_view.png`

Commit target:

- `Fix alpha camera scale`

## Slice 2: Signage, Prop Scale, And Receiving Sightlines

Status: implemented in `Fix alpha signage sightlines`.

Goal: remove the giant-label/foreground-blocker problem while preserving useful zone cues.

Work:

- Resize and relocate receiving, register, rack, backroom, storage, and sale signs.
- Keep signs readable but outside core sightlines and interaction lanes.
- Recompose receiving so starter items, intake label, optional note, and customer/prop context do not overlap.
- Recheck display rack and counter prop scale from normal camera height.

Acceptance:

- `04_receiving_box_before_pickup.png` shows the starter items without a sign covering them.
- Register and rack signage help orientation without becoming foreground slabs.
- Product labels and signs do not fight the reticle prompt.
- Automated coverage now locks the main zone signs as fixed in-world labels under the new pixel-size budget and keeps the receiving `INTAKE` tag compact and non-billboarded.

Manual screenshots:

- `04_receiving_box_before_pickup.png`
- `10_stocked_rack_readability.png`
- `12_register_queue_spacing.png`

Commit target:

- `Fix alpha signage sightlines`

## Slice 3: Core Interaction Readability

Status: implemented in `Fix alpha interaction readability`.

Goal: make pickup, pricing entry, stocking, and lower-priced-copy validation readable enough to perform repeatedly.

Work:

- Increase prompt text size, contrast, and anchoring for the real game window.
- Ensure reticle/feedback states remain visible against sales floor, receiving, racks, and backroom surfaces.
- Tune product hover/slot hover readability after sign and scale changes.
- Recheck lower-priced-copy buying behavior in the actual scene.

Acceptance:

- A player can identify click action and target subject without squinting.
- Pickup, pricing, and stocking feedback stay readable while moving.
- `09_buyer_selects_lower_price.png` can be captured without needing debug knowledge.
- Automated coverage now locks the larger bottom prompt card, larger center reticle, prompt panel contrast, product hover highlight, shelf slot hover highlight, and lower-priced-copy customer selection behavior.

Manual screenshots:

- `05_held_item_stack.png`
- `06_pricing_panel_fair_price.png`
- `09_buyer_selects_lower_price.png`

Commit target:

- `Fix alpha interaction readability`

## Slice 4: Modal And Menu Legibility

Status: implemented in `Fix alpha modal legibility`.

Goal: make required decision panels readable at 1280x720.

Work:

- Enlarge or re-layout pricing, register, trade-in, preorder, service, settings, and save/load panels where needed.
- Increase contrast and control hierarchy for modal text and buttons.
- Ensure panels dim or de-emphasize background clutter without disorienting the player.
- Preserve mouse focus and first-person capture recovery.

Acceptance:

- Pricing details, suggested range, current price, and Apply controls are readable.
- Register receipts, trade-in appraisal, preorder deposit, service ticket, settings, and save slots fit without clipped or tiny text.
- Manual capture can proceed past pricing instead of stopping.
- Automated coverage now locks larger runtime font sizes, panel dimensions, scroll heights, button hit targets, and shared UI language preserving scene-specific readable font overrides for pricing, register, trade-in, save/load, pause, and settings surfaces.

Manual screenshots:

- `06_pricing_panel_fair_price.png`
- `13_register_sale_panel.png`
- `16_trade_in_offer_panel.png`
- `17_preorder_register_panel.png`
- `42_save_slots.png`

Commit target:

- `Fix alpha modal legibility`

## Slice 5: Customer Role And Queue Readability

Goal: make customers readable as roles without giant floating labels or register crowding.

Work:

- Replace inconsistent billboard dominance with compact, consistent role markers.
- Recheck buyer, trade-in, preorder, service, and suspicious customer positions.
- Keep role props visible without overlapping heads, counters, or prompts.
- Preserve queue spacing and special-customer separation.

Acceptance:

- Customers read as different roles before clicking.
- Role labels do not dominate the scene or shrink below readability.
- Buyer queue, trade-in seller, preorder, service, and suspicious customer do not form a visual pileup at the register.

Manual screenshots:

- `12_register_queue_spacing.png`
- `16_trade_in_offer_panel.png`
- `17_preorder_register_panel.png`
- `19_service_register_panel.png`

Commit target:

- `Fix alpha customer readability`

## Slice 6: Backroom And Computer Readability

Goal: make the backroom usable as operations space instead of a dense debug room.

Work:

- Recompose backroom entry, receiving, storage, service bench, management desk, and computer sightlines.
- Improve backroom computer dashboard, ordering, releases, records, services, storage, and supplier workflow hierarchy.
- Confirm Open Box, Invoice, Sort, Store, Pull, Start Job, Work Job, and release allocation controls are visible and grouped.

Acceptance:

- Backroom entry reads as a physical operations room.
- Computer tabs fit and differ visually enough to review.
- Receiving workflow controls are readable without hidden lower-frame actions.

Manual screenshots:

- `22_backroom_entry_view.png`
- `24_backroom_dashboard.png`
- `26_ordering_tab.png`
- `27_releases_tab.png`
- `29_records_tab.png`
- `32_open_box_invoice_sort.png`

Commit target:

- `Fix alpha backroom readability`

## Slice 7: Recovery Validation And Playtest Reopen

Goal: prove the build is ready to resume the external alpha playtest package.

Work:

- Run the short capture set again.
- Update `13-alpha-bug-list.md` with fixed/remaining status for the recovery blockers.
- Update `15-alpha-playtest-package.md` from paused to active only if the capture set is readable.
- Sync validation docs and manual checklist.

Acceptance:

- Full gate passes.
- The required screenshot set is readable enough for human review.
- The alpha package is either reopened or remains explicitly blocked with remaining evidence.

Manual screenshots:

- `01_spawn_first_view.png`
- `04_receiving_box_before_pickup.png`
- `06_pricing_panel_fair_price.png`
- `09_buyer_selects_lower_price.png`
- `12_register_queue_spacing.png`
- `13_register_sale_panel.png`
- `16_trade_in_offer_panel.png`
- `17_preorder_register_panel.png`
- `20_service_bench_ticket.png`
- `22_backroom_entry_view.png`
- `24_backroom_dashboard.png`
- `26_ordering_tab.png`
- `27_releases_tab.png`
- `29_records_tab.png`
- `32_open_box_invoice_sort.png`
- `37_fixture_invalid_red_ghost.png`
- `39_closed_day_report.png`
- `42_save_slots.png`

Commit target:

- `Sync readability recovery validation`

## User Review Order

Review these docs in this order before implementation starts:

1. `docs/production/16-playability-readability-recovery-plan.md`
2. `docs/production/13-alpha-bug-list.md`
3. `docs/production/04-backlog.md`
4. `docs/production/11-game-completion-plan.md`
5. `docs/production/07-current-manual-playtest.md`
6. `docs/production/15-alpha-playtest-package.md`

What to check:

- The recovery slices match the actual pain from the four screenshots.
- The slice order starts with camera/scale before UI detail.
- The plan pauses external playtest instead of pretending the alpha is readable.
- The screenshot list is short enough to rerun between slices.
- No slice adds new systems before the existing loop is readable.
