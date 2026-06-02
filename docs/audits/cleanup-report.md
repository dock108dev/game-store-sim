# Cleanup Report

Date: 2026-06-02

This note exists because current code comments cite it for the few oversized
source files and broad visual suites that intentionally remain grouped. It is
not a backlog. Each row below is grounded in an existing file-level comment or
test-suite comment in the current tree.

## Current Large-File Justifications

| File | Current reason to keep grouped |
| --- | --- |
| `game/scripts/store_session/store_session_controller.gd` | The Day 1 store-session chain owns stage state, customer event loading, panels, stock flow, close-day handling, and visual helpers in one controller. Its file-level note keeps these presenter slices together until they can be extracted together without splitting one route across competing owners. |
| `game/scripts/store_session/store_visual_sweep.gd` | The sweep still owns capture target selection, manifest assembly, acceptance row evaluation, screenshot paths, and closeout reporting. Splitting only one of those pieces would make the visual-review contract harder to audit against `scripts/run_store_visual_sweep.sh` and `tests/visual/capture_store_visual_sweep.gd`. |
| `game/scripts/visuals/store_visual_kit.gd` | The generated-store visual kit owns material families, mesh helpers, prop construction, and decoration factories that share the same token/material vocabulary documented in `docs/style/visual-grammar.md`. |
| `game/scripts/systems/checkout_system.gd` | Queue, payment, checkout-panel, haggle-panel, and transaction view-model adaptation remain in one runtime owner so customer sale state cannot diverge between systems during a register flow. |
| `tests/gut/test_visual_overhaul_validation_gate.gd` | The suite is route-wide by design: it checks the same visual-overhaul acceptance surface used by the visual sweep and should fail as one gate when the route-level composition contract drifts. |
| `tests/gut/test_expandable_store_boot_shell.gd` | The suite keeps shell bootstrap, floor-plan, generated geometry, and visual-role assertions together because each assertion depends on the same booted shell fixture. |
| `tests/gut/test_stockroom_working_back_room_dressing.gd` | The suite keeps stockroom room-contract and dressing assertions together because both are derived from the same generated stockroom scene setup. |

## Current Consolidations

- Vector parsing and invalid `Vector3` sentinels are centralized in
  `game/scripts/visuals/visual_value_util.gd`.
- Store visual physical-contract checks use
  `game/scripts/visuals/store_physical_contract_validator.gd` and
  `game/scripts/visuals/store_room_contract_validator.gd`.
- Store-session no-argument interactable dispatch is centralized in
  `game/scripts/store_session/store_session_interactable_base.gd`.
- Store visual overhaul row construction is owned by
  `game/scripts/store_session/store_visual_overhaul_rows.gd`.

## Validation Surface

The code paths above are covered by the default local gate
(`bash tests/run_tests.sh`) through the GUT suites and maintained shell
validators documented in `docs/testing.md`. The visual sweep is run directly by
`scripts/run_store_visual_sweep.sh` and by the advisory weekly workflow.
