# Decorations And Upgrades Plan

Implementation plan for decorations, upgrades, fixture unlocks, and visible store customization after the opening-store quality bar.

## Goal

Make upgrades and decorations visible, coherent, and meaningful before expanding long-form play. Customization should help the player understand business progress, not just change numbers in a menu.

## Design Intent

Decorations and upgrades are the player's long-term proof that the store is improving. Every purchase should answer at least one of these questions:

- What changed in the store?
- Why does it matter to the business?
- Where can I see it?
- What does it unlock next?
- Does it keep the store readable and navigable?

The system should favor small, legible, shop-specific upgrades over abstract stat boosts.

## Current Implementation State

Implemented in the current branch:

- `StoreSession` has an upgrade catalog, purchased-upgrade state, unlock requirements, and upgrade summary text.
- `StoreSession` has a decoration catalog, purchased-decoration state, clutter budget, and decoration summary text.
- `DaySummaryPanel` can buy the management upgrade and apply the starter decoration.
- Fixture ordering and fixture unlocks already support upgrade-gated placement.
- Save/load codec persists purchased upgrades and decorations.
- Tests cover management upgrade purchase, decoration application, fixture ordering/placement, fixture unlocks, and save/load persistence.
- Decoration catalog entries now declare visible scene node hooks, and `StoreSession` exposes decoration surface state/summary APIs for preview vs applied review.
- Upgrade catalog entries now declare visible surfaces, and scene tests verify every decoration/upgrade hook resolves to a real world node.

This is now a functional world-state foundation. Future work can replace preview anchors with final art or dynamic material toggles without changing the catalog contract.

## Scope

### In Scope

- Decoration categories and visible state rules.
- Upgrade categories and unlock structure.
- Catalog UI card requirements.
- World-state hooks for purchased decor/upgrades.
- Clutter budget and readability constraints.
- Save/load persistence.
- Screenshot acceptance for `catalog_design_cues.png`, `upgrade_preview.png`, fixture screenshots, and opening-store review images.

### Out Of Scope

- Full interior-design mode.
- Freeform prop placement.
- Arbitrary player-authored signage.
- Cosmetic microtransactions or real-world brands.
- Store expansion outside the current fixture/footprint system.
- Final art for every decor item.

## Decoration Categories

| Category | Purpose | Visible Surface | Risk |
| --- | --- | --- | --- |
| Wall paint | Shift store mood and reduce graybox read | Sales walls, backroom accent walls | Can become one-note palette |
| Floor material | Make paths and zones feel finished | Entry, sales floor, backroom | Can hide route contrast |
| Sign trim | Improve hierarchy and store identity | Storefront, category signs, counter signs | Can over-clutter text |
| Posters/cards | Add catalog/platform personality | Sales wall, window, office board | Can imply real IP if unmanaged |
| Lighting package | Improve zone contrast and warmth | Sales floor, stockroom, office | Can hurt readability if too dramatic |
| Display props | Add retail density | Window, counter, shelves | Can block prompts/pathing |
| Backroom organization | Clarify operations | Receiving, backstock, office | Can dominate hidden-thread surfaces |

Implementation rules:

- Every purchased decoration needs a visible world change.
- Decorations must fit a surface and clutter budget.
- Decoration names should describe the visible finish before flavor.
- Decorations must not obscure prompts, product labels, shelf slots, customers, or carry routes.

## Upgrade Categories

| Category | Purpose | Example Current/Future IDs |
| --- | --- | --- |
| Storage capacity | Increase backroom or shelf handling | `upgrade_backroom_storage` |
| Computer analytics | Improve management information | `upgrade_computer_analytics` |
| Fixture unlocks | Unlock new fixture types or placement flexibility | `upgrade_fixture_peg_wall` |
| Service capability | Expand service workflow value | future service bench upgrades |
| Signage/marketing | Improve demand or launch visibility | `upgrade_signage_staff_picks` |
| Expansion footprint | Add more store space or placement area | `upgrade_store_expansion` |

Implementation rules:

- Upgrade label should explain the business effect.
- Upgrade summary should list available, locked, and purchased states.
- Locked upgrades should show requirements, not appear broken.
- Upgrade purchase should reserve/spend cash through `StoreSession`.
- Upgrade effects should be visible in either world props, UI summaries, or fixture availability.

## Decoration Data Shape

Current decoration dictionaries should remain compatible with:

- `decoration_id`
- `label`
- `category`
- `surface`
- `cost_cents`
- `clutter_points`
- `effect`

Future dedicated resources, if added, should preserve those fields and add only tested fields such as:

- `preview_scene_path`
- `applied_node_path`
- `required_upgrade_id`
- `palette_id`
- `screenshot_tags`

Implementation files:

- `game/scripts/systems/store_session.gd`
- future `game/data/decorations/*.tres`
- `game/scripts/save/store_save_codec.gd`
- `game/tests/gut/test_store_session.gd`
- `game/tests/gut/test_store_save_codec.gd`

## Upgrade Data Shape

Upgrade dictionaries/resources should support:

- `upgrade_id`
- `label`
- `cost_cents`
- `summary`
- `requirements`
- `effect`
- `unlock_tags`
- `visible_surface`

Implementation files:

- `game/scripts/systems/store_session.gd`
- future `game/data/upgrades/*.tres`
- `game/scripts/save/store_save_codec.gd`
- `game/tests/gut/test_store_session.gd`
- `game/tests/gut/test_day_summary_panel.gd`

## Catalog UI Requirements

The management UI should show:

- Name/label.
- Cost.
- Requirement or lock reason.
- Effect summary.
- Available/purchased/locked state.
- Surface or preview hint.
- Clutter budget impact for decorations.
- Fixture/storage impact for upgrades.

Implementation files:

- `game/scenes/ui/day_summary_panel.tscn`
- `game/scripts/ui/day_summary_panel.gd`
- `game/tests/gut/test_day_summary_panel.gd`

UI rules:

- Avoid long paragraph descriptions.
- Keep cards grouped by business function.
- Keep primary action buttons visible at 1280x720.
- Lock text should say what is missing.
- Purchased text should say what changed.

## World-State Requirements

Decorations and upgrades should map to visible outcomes:

- Wall/floor/sign/lighting decor should alter material or show a dedicated prop.
- Poster/display props should appear in fixed safe points.
- Backroom organization should add or update office/stockroom props.
- Storage upgrades should alter capacity summaries and visible storage read.
- Fixture unlocks should alter fixture catalog availability.
- Computer analytics should alter management summary content.
- Expansion upgrades should alter placement/footprint language and eventually world bounds.

Implementation files:

- `game/scenes/world/graybox_store.tscn`
- `game/scripts/systems/store_session.gd`
- `game/scripts/store_layout/fixture_placement_manager.gd`
- `game/tests/gut/test_graybox_store.gd`
- `game/tests/gut/test_store_session.gd`

## Implementation Sequence

1. Stabilize current catalog text.
   - Confirm all existing decoration and upgrade labels are readable.
   - Confirm current tests cover purchase/apply/save/load.

2. Add visible state hooks.
   - Tie starter decoration to an actual world material/prop state.
   - Tie selected upgrades to visible office, fixture, or storage changes.
   - Add scene tests for visible applied state.

3. Add preview/readability UI.
   - Show surface, cost, clutter, and effect in compact cards.
   - Keep lock requirements visible.
   - Update day-summary tests.

4. Expand catalog.
   - Add 2 to 3 options per category.
   - Keep clutter budget small.
   - Add screenshot review for each visible surface group.

5. Run day-loop review.
   - Verify upgrade pacing across several days.
   - Confirm purchases feel meaningful but not mandatory before core loop is understood.

## File Impact Matrix

| File | Role | Change Type |
| --- | --- | --- |
| `game/scripts/systems/store_session.gd` | Decoration/upgrade catalog, purchase logic, effects | Primary implementation |
| `game/scripts/ui/day_summary_panel.gd` | Management UI actions and summary text | Primary implementation |
| `game/scenes/ui/day_summary_panel.tscn` | Upgrade/decor UI layout | UI implementation |
| `game/scenes/world/graybox_store.tscn` | Visible applied decoration/upgrade state | World implementation |
| `game/scripts/store_layout/fixture_definition.gd` | Fixture unlock metadata | Data contract |
| `game/data/fixtures/*.tres` | Fixture names/costs/requirements | Data implementation |
| `game/scripts/save/store_save_codec.gd` | Persistence | Required if data shape changes |
| `game/tests/gut/test_store_session.gd` | Purchase/apply/effect tests | Required |
| `game/tests/gut/test_day_summary_panel.gd` | UI action/layout tests | Required |
| `game/tests/gut/test_store_save_codec.gd` | Persistence tests | Required if state changes |
| `game/tests/gut/test_graybox_store.gd` | Visible world-state tests | Required for applied props |

## Screenshot Acceptance

### `catalog_design_cues.png`

Pass criteria:

- Decoration/upgrade catalog reads as grouped choices.
- Costs, lock states, and effects are visible.
- Names fit the store's fictional retail world.

Fail criteria:

- Catalog looks like debug text.
- Lock reasons are unclear.
- Names imply unsupported features.

### `upgrade_preview.png`

Pass criteria:

- Upgrade preview shows what will change.
- Available/locked/purchased state is clear.
- Primary action remains visible at 1280x720.

Fail criteria:

- Upgrade effect is only abstract text.
- Button/action is below the visible frame.
- Preview conflicts with fixture placement language.

### World Screenshots

Relevant screenshots:

- `main_scene.png`
- `stocked_aisle.png`
- `register_counter.png`
- `backroom_summary.png`
- `fixture_placed.png`

Pass criteria:

- Applied decor/upgrades improve identity without hiding prompts.
- Decor stays in safe points.
- Store remains navigable.

## Automated Validation

Required:

```text
scripts/validate_godot.sh
```

Relevant GUT surfaces:

- `test_store_session.gd`
- `test_day_summary_panel.gd`
- `test_store_save_codec.gd`
- `test_fixture_catalog.gd`
- `test_fixture_placement_manager.gd`
- `test_graybox_store.gd`

## Manual Review

Review:

1. Decoration catalog text and lock states.
2. Upgrade catalog text and requirements.
3. Applied decoration visible state in screenshots.
4. Fixture unlock/placement flow.
5. Save/load after purchased decor/upgrades.
6. Three-day pacing after catalog expansion.

File failures in `docs/production/13-alpha-bug-list.md` or the current backlog with the exact decoration/upgrade ID.

## Risks

- Decorations can become pure menu text if not tied to visible world changes.
- Too many decor props can lower readability.
- Upgrade effects can alter economy pacing and require balance review.
- Lock states can feel broken if requirements are not clear.
- Save/load migrations become necessary if state shape changes after external playtest.

## Completion Criteria

This plan is complete when:

- Decoration and upgrade categories are documented.
- Existing mechanical catalog is covered by tests.
- Visible-state requirements are explicit.
- Future data shape and file impacts are defined.
- Screenshot acceptance covers catalog UI and world changes.
- Full validation passes after any decor/upgrade implementation.
- Owner review confirms upgrades/decorations should be the next phase after opening-store approval.
