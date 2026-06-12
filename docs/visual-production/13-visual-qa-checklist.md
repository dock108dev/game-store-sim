# Visual QA Checklist

## Purpose

Judge whether visual work is actually moving toward the art target.

Automated tests prove the game still works. This checklist judges whether the store looks like the intended mid-00s independent game shop.

## Review Inputs

Required:

- Latest `scripts/validate_godot.sh` artifacts.
- Latest screenshot contact sheet.
- First-person screenshots from the changed visual slice.
- This checklist.

Optional:

- Editor overview screenshot for spatial critique.
- Asset contact sheet.
- Material/texture sheet.

## Global Pass Criteria

Pass only if:

- Object identity is readable before labels.
- Store era is visible.
- Materials and lighting feel authored.
- Product density is intentional.
- Day-one product density matches the current progression state.
- Gameplay prompts and routes remain clear.
- Fictional names avoid real IP leakage.
- The screenshot does not read as CSG blockout.
- Visible opening-route assets are not raw boxes unless they are intentionally cardboard boxes.
- Backroom boundaries read as real architecture, not only floor lines, color zones, or signs.
- Labels are secondary details, not the primary way to understand the store.
- Clutter is grouped into believable retail workflows.

## Global Fail Criteria

Fail if:

- The scene relies on text labels for identity.
- Giant signs, floating labels, or debug callouts explain objects that should be readable by shape.
- The backroom is separated only by a line or flat marker.
- Props look randomly dumped instead of staged for display, receiving, sorting, or backstock.
- The main read is flat wall/floor/counter primitives.
- Mall, storefront, product, fixture, or signage identity is carried by box graphics with labels.
- Objects look randomly scaled.
- Props hide prompts, products, customers, or UI.
- Lighting is editor-flat or visually noisy.
- The image would compare poorly to a basic indie shop-sim screenshot.
- The day-one shop looks fully stocked enough that progression has no visual room left.

## Slice Review Questions

For each changed screenshot, answer:

1. What is the intended subject?
2. Can the subject be identified without reading labels?
3. What mid-00s detail is visible?
4. What material sells the object?
5. Does the amount of visible stock match the intended progression stage?
6. What is still blockout?
7. Does anything block gameplay readability?
8. Is this ready to propagate to other zones?

## Severity

- P0: visual change breaks gameplay validation or blocks core interaction.
- P1: visual target fails for a required first-view/core-loop surface.
- P2: visible polish issue that can wait within the current visual phase.
- P3: future art/content improvement.

## Approval Rule

Do not approve a visual phase because it has more objects. Approve it only when the screenshot looks closer to the target art direction.

## Current Cleanup Priority

The next implementation pass must be judged against these five screenshots first:

- `main_scene.png`
- `storefront_entry.png`
- `register_counter.png`
- `receiving_area.png`
- `backroom_summary.png`

For this pass, fail any screenshot where the main read is still labels, debug-like signs, random clutter, or a line pretending to be room architecture.
