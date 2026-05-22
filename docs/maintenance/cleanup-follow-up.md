# Cleanup Follow-up

This pass removed stale embedded tooling and planning artifacts, then captured
the remaining oversized files for deliberate follow-up work. The files below
are still above the ~500 LOC cleanup target.

## Refactor Candidates

Scene and authored content files are expected to be large, but they should
still be split when ownership boundaries become clear.

| LOC | File | Follow-up direction |
| ---: | --- | --- |
| 6274 | `game/scenes/stores/retro_games.tscn` | Consider replacing more authored fixture clusters with reusable scene instances and generated layout data. |
| 2898 | `game/scripts/beta/beta_day_one_controller.gd` | Split repeatable shift flow, customer decision handling, panels, and visual reset helpers into focused collaborators. |
| 1491 | `game/scenes/ui/hud.gd` | Separate top-bar counters, FP-mode labels, close-day preview, and panel toggle wiring. |
| 1283 | `game/scripts/core/save_manager.gd` | Isolate schema migration, slot index IO, atomic writes, and validation helpers. |
| 1224 | `game/scenes/world/game_world.gd` | Extract boot orchestration, store runtime wiring, player spawn/camera wiring, and build-mode setup. |
| 968 | `game/content/items/retro_games.json` | Split catalog by category or supplier tier if authoring friction grows. |
| 956 | `game/scripts/systems/customer_system.gd` | Separate spawn scheduling, first-customer guarantees, and customer lifecycle accounting. |
| 925 | `game/scripts/systems/inventory_system.gd` | Separate stock mutation, queries, and reporting helpers. |
| 909 | `game/scenes/ui/day_summary.gd` | Split payload normalization from UI construction. |
| 898 | `game/autoload/data_loader.gd` | Extract typed content parsers and starter-inventory generation. |
| 881 | `game/scripts/stores/retro_games.gd` | Split store-specific startup wiring, fixture helpers, and visual state toggles. |
| 864 | `game/scripts/systems/checkout_system.gd` | Separate cart validation, sale settlement, receipt/toast emission, and dev helpers. |
| 859 | `game/autoload/event_bus.gd` | Group signals by domain or document why the single bus remains preferable. |
| 833 | `game/scripts/characters/customer.gd` | Separate navigation fallback, shopping FSM, and animation hooks. |
| 817 | `game/scenes/ui/inventory_panel.gd` | Split row building, filtering, and action dispatch. |
| 815 | `game/scripts/content_parser.gd` | Split per-resource parsers if content schemas keep expanding. |
| 789 | `game/autoload/settings.gd` | Separate persistence, input settings, graphics settings, and UI helpers. |
| 783 | `game/scenes/ui/checkout_panel.gd` | Split cart view, line-item rendering, and checkout actions. |
| 758 | `game/scripts/systems/ambient_moments_system.gd` | Separate event selection, timing, and presentation dispatch. |
| 741 | `game/scripts/systems/economy_system.gd` | Separate pricing, rent, cash ledger, and derived metrics. |
| 740 | `game/scripts/systems/order_system.gd` | Separate order lifecycle, supplier rules, and delivery handling. |
| 721 | `game/autoload/audio_manager.gd` | Separate music, ambience, SFX, and bus/volume state. |
| 713 | `game/scripts/characters/shopper_ai.gd` | Separate decision model, pathing, and store interaction behavior. |
| 682 | `game/scripts/world/storefront.gd` | Split storefront visuals from store-entry interactions. |
| 676 | `game/scripts/systems/performance_report_system.gd` | Separate report aggregation from day-beat text selection. |
| 666 | `game/scripts/stores/store_controller.gd` | Separate store lifecycle, input context, and dev fixture helpers. |
| 666 | `game/scenes/ui/order_panel.gd` | Split row construction, supplier filters, and order actions. |
| 647 | `game/autoload/manager_relationship_manager.gd` | Split note selection, trust math, and content validation. |
| 647 | `game/autoload/content_registry.gd` | Separate registry loading, lookup helpers, and warning behavior. |
| 634 | `game/scenes/ui/settings_panel.gd` | Split settings sections into smaller builders. |
| 634 | `game/content/progression/milestone_definitions.json` | Split milestones by domain if authoring becomes hard to review. |
| 625 | `game/scripts/systems/haggle_system.gd` | Separate offer generation, scoring, and outcome application. |
| 618 | `game/scripts/player/interaction_ray.gd` | Split targeting, prompt emission, and modal/input gating. |
| 617 | `game/scripts/systems/progression_system.gd` | Split milestone evaluation from unlock side effects. |
| 588 | `game/scripts/systems/build_mode_system.gd` | Separate grid math, preview state, and placement command handling. |
| 574 | `game/autoload/hidden_thread_system.gd` | Separate clue state, scoring, and event hooks. |
| 573 | `game/scripts/systems/tutorial_system.gd` | Separate tutorial rules from UI emission. |
| 558 | `game/scripts/systems/store_state_manager.gd` | Separate ownership state, serialization, and active-store routing. |
| 542 | `game/scripts/ui/haggle_panel.gd` | Split decision UI from payload formatting. |
| 541 | `game/scripts/beta/beta_right_panel.gd` | Split stats rendering from objective checklist state. |
| 541 | `game/autoload/staff_manager.gd` | Separate hiring, assignment, and payroll logic. |
| 526 | `game/scripts/systems/random_event_system.gd` | Separate event eligibility, selection, and effect application. |
| 515 | `game/scripts/characters/customer_animator.gd` | Separate state selection from animation application. |
| 503 | `game/autoload/reputation_system.gd` | Separate score mutation from event emission. |
| 502 | `game/scripts/stores/shelf_slot.gd` | Separate stock authority, prompt state, and visual refresh. |

## Large Test Files

These are above the same threshold, but splitting them should follow the
production refactor they validate.

| LOC | File |
| ---: | --- |
| 2459 | `tests/gut/test_beta_day_one_critical_path.gd` |
| 2110 | `tests/gut/test_store_visual_readability.gd` |
| 859 | `tests/gut/test_retro_games_fixture_geometry.gd` |
| 850 | `tests/gut/test_inventory_panel.gd` |
| 842 | `tests/gut/test_retro_games_scene_issue_006.gd` |
| 776 | `tests/gut/test_shopper_ai.gd` |
| 702 | `tests/gut/test_customer_spawn_scheduling.gd` |
| 696 | `tests/gut/test_hud.gd` |
| 672 | `tests/gut/test_retail_fixture_library.gd` |
| 631 | `tests/gut/test_checkout_system.gd` |
| 607 | `tests/gut/test_eventbus_signal_compat.gd` |
| 584 | `tests/gut/test_retro_games_interior_signage.gd` |
| 584 | `tests/gut/test_random_event_system.gd` |
| 550 | `tests/gut/test_objective_rail_day1_visibility.gd` |
| 539 | `tests/gut/test_beta_visual_scope_guardrails.gd` |
| 531 | `tests/gut/test_interaction_ray.gd` |
| 528 | `tests/gut/test_employee_progression_unlocks.gd` |
| 525 | `tests/gut/test_retro_games_floor_plan.gd` |
| 524 | `game/tests/unit/test_ending_evaluator_system.gd` |
| 522 | `tests/gut/test_ambient_moments_system.gd` |
| 508 | `tests/gut/test_objective_director.gd` |
| 507 | `tests/gut/test_hud_fp_mode.gd` |
