# Phase 0 UI Integrity

Date: 2026-06-02

This note documents the current single-source UI contracts cited by code and
test runner comments.

## Contracts

| ID | Current contract | Code basis |
| --- | --- | --- |
| `P1.3` | Objective text is sourced from `game/content/objectives.json` through `ObjectiveDirector`; tutorial step text is rendered by `TutorialOverlay` through localization keys, so objective copy and tutorial copy are not duplicated. | `game/autoload/objective_director.gd`, `scripts/validate_tutorial_single_source.sh` |
| `P2.1` | The local test runner executes the maintained SSOT tripwires when present and executable: translation key validation, single-store UI residue validation, and tutorial text source validation. | `tests/run_tests.sh`, `scripts/validate_translations.sh`, `scripts/validate_single_store_ui.sh`, `scripts/validate_tutorial_single_source.sh` |
| `MODAL band` | Day summary is a full-screen `CanvasLayer` on the modal band, above first-person HUD, objective rail, and tutorial overlay. | `game/scenes/ui/day_summary.gd`, `game/scripts/ui/ui_layers.gd` |

## Validation

`bash tests/run_tests.sh` runs `validate_translations.sh`,
`validate_single_store_ui.sh`, and `validate_tutorial_single_source.sh` after
the maintained shell validators and GUT path.
