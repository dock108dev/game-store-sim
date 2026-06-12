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

## Global Fail Criteria

Fail if:

- The scene relies on text labels for identity.
- The main read is flat wall/floor/counter primitives.
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
