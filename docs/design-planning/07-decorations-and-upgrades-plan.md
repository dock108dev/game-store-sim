# Decorations And Upgrades Plan

Implementation plan for decorations, upgrades, and visible store customization after the opening-store quality bar.

## Goal

Make upgrades and decorations visible, coherent, and meaningful before expanding long-form play.

## Build Tasks

1. Decoration categories.
   - Wall paint.
   - Floor material.
   - Sign trim.
   - Posters/cards.
   - Lighting package.
   - Display props.
   - Backroom organization.

2. Upgrade categories.
   - Storage capacity.
   - Computer analytics.
   - Fixture unlocks.
   - Service capability.
   - Signage/marketing.
   - Expansion footprint.

3. Visual state.
   - Each purchased decor should have a visible world change.
   - Each upgrade should explain why it matters.
   - Locked items should read as future goals, not broken buttons.

4. Catalog UI.
   - Card layout.
   - Cost.
   - Requirement.
   - Effect summary.
   - Preview or swatch.
   - Purchased/locked/available state.

## Files To Expect

- `game/scripts/systems/store_session.gd`
- `game/scripts/ui/day_summary_panel.gd`
- `game/scenes/ui/day_summary_panel.tscn`
- `game/scripts/store_layout/fixture_definition.gd`
- `game/data/fixtures/*.tres`
- `game/tests/gut/test_store_session.gd`
- `game/tests/gut/test_day_summary_panel.gd`

## Acceptance

- Decoration and upgrade lists are understandable without docs.
- Changes are visible in the world.
- Upgrade costs and effects support early-game goals.
- No decor hides prompts, product labels, or paths.

## Test

- Run store session and day summary tests.
- Run `scripts/validate_godot.sh`.
- Review `catalog_design_cues.png` and `upgrade_preview.png`.
