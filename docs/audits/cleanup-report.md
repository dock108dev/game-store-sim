# Cleanup Report

Date: 2026-06-02

This note exists because current source comments cite it for the few oversized
source files and broad visual suites that intentionally remain grouped. It is a
current-state reference, not a changelog or backlog.

## Files still >500 LOC

| File | Current size | Current reason to keep grouped |
| --- | ---: | --- |
| `game/scripts/store_session/store_session_controller.gd` | 5735 LOC | The Day 1 store-session chain is still one orchestration owner: stage state, event loading, prompts, panels, carried stock, customer-exit state, close-day handling, and store-session visual helpers all read the same `_stage` / `_objectives` contract. Splitting only one presenter slice would leave the route split across competing owners. |
| `game/scripts/visuals/store_visual_kit.gd` | 1091 LOC | The generated-store visual kit keeps material-facing fixture IDs, primitive helpers, prop construction, and decoration factories behind one registry-facing API used by generated layouts and runtime feedback. |
| `game/scripts/systems/checkout_system.gd` | 1017 LOC | Queue readiness, sale initiation, payment/haggle resolution, bundle handling, register-panel wiring, and transaction view-model adaptation still share one register-flow owner so customer sale state does not diverge between systems. |
| `game/scripts/store_session/store_visual_sweep.gd` | 1287 LOC | The visual sweep owns route rows, capture target selection, artifact paths, acceptance policy, manifest assembly, PNG writing, and closeout reporting for the same display-backed review contract used by `scripts/run_store_visual_sweep.sh`. |

## Broad suites kept grouped

| File | Current reason to keep grouped |
| --- | --- |
| `tests/gut/test_visual_overhaul_validation_gate.gd` | Route-wide acceptance rows, visual-sweep manifests, fixture state, and screenshot-backed policy are asserted as one route contract. A partial split would duplicate the same route setup while weakening the acceptance signal. |
| `tests/gut/test_expandable_store_boot_shell.gd` | Shell bootstrap, floor-plan, generated geometry, and visual-role assertions all depend on the same booted shell fixture. |
| `tests/gut/test_stockroom_working_back_room_dressing.gd` | Stockroom room-contract and dressing assertions are derived from the same generated stockroom scene setup. |

## Current consolidations

- Vector parsing and invalid `Vector3` sentinels are centralized in
  `game/scripts/visuals/visual_value_util.gd`.
- Store visual physical-contract checks use
  `game/scripts/visuals/store_physical_contract_validator.gd` and
  `game/scripts/visuals/store_room_contract_validator.gd`.
- Store-session no-argument interactable dispatch is centralized in
  `game/scripts/store_session/store_session_interactable_base.gd`.
- Store visual overhaul row construction is owned by
  `game/scripts/store_session/store_visual_overhaul_rows.gd`.

## Validation surface

The grouped paths above are covered by the default local gate
(`bash tests/run_tests.sh`) through GUT suites and maintained shell validators
documented in `docs/testing.md`. The display-backed visual sweep is run
directly by `scripts/run_store_visual_sweep.sh` and by the advisory weekly
visual workflow.
