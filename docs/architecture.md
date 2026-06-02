# Architecture

## Boot Flow

The configured entry scene is `res://game/scenes/bootstrap/boot.tscn`. The boot
script (`game/scripts/core/boot.gd`, attached via the `boot.gd` wrapper at
`game/scenes/bootstrap/boot.gd`) runs synchronous startup checks before opening
the main menu:

1. `DataLoaderSingleton.load_all()` discovers JSON content under
   `res://game/content/` and aggregates load errors.
2. `arc_unlocks.json` and `objectives.json` are schema-validated.
3. `ContentRegistry.is_ready()` is asserted.
4. `ContentRegistry.get_all_store_ids()` is asserted to be non-empty.
5. `Settings.load()` then `AudioManager.initialize()` runs.
6. `GameManager.mark_boot_completed()` is called and `EventBus.boot_completed`
   is emitted.
7. `AuditLog.pass_check(&"boot_scene_ready", "from=boot.gd")` is emitted.
8. If `AutomationRunner.should_take_over_boot()` is true, automation starts
   from the completed boot state; otherwise
   `GameManager.transition_to(GameManager.State.MAIN_MENU)` opens the menu.

If any boot step fails, an in-scene error panel is shown and the transition
does not occur.

## GameWorld init tiers

`game/scenes/world/game_world.gd` runs five named initialization tiers when
the playable world scene is brought up. Tier 2 returns `bool` — a hard
failure aborts subsequent tiers. The tiers are not the same as the boot
script above; they execute after the gameplay scene loads.

| Tier | Function | Systems initialized |
|---|---|---|
| 1 — data | `initialize_tier_1_data` | `time_system`, `economy_system` (with starting cash); registers the day-end summary callable |
| 2 — state | `initialize_tier_2_state` | `inventory_system`, `store_state_manager`, `trend_system`, `market_event_system`, `market_value_system` |
| 3 — operational | `initialize_tier_3_operational` | per-store `ReputationSystemSingleton`, `customer_system`, `npc_spawner_system`, `haggle_system`, `checkout_system` (player), `queue_system`, `progression_system`, `milestone_system`, `order_system`, `staff_system` |
| 4 — world | `initialize_tier_4_world` | `build_mode` (`BuildModeSystem` + `FixturePlacementSystem` + `BuildModeTransition` + optional `NavMeshRebaker`), `day_phase_lighting` |
| 5 — meta | `initialize_tier_5_meta` | `performance_manager`, `performance_report_system`, `random_event_system`, `ambient_moments_system`, `regulars_log_system`, `ending_evaluator`, `DayManager` (instantiated and added as a child here), `store_upgrade_system`, `completion_tracker`, `LedgerSystem`, `day_cycle_controller` |

`finalize_system_wiring()` runs after all tiers and wires `SaveManager`, the
store controllers, and the day-cycle controller's save reference.

These tier functions are scene nodes' `initialize(...)` calls — not
autoloads. The autoload roster below is initialized earlier by Godot before
any scene loads.

## Autoloads

Declared in `project.godot` `[autoload]` in load order. Later autoloads may
reference earlier ones. Five entries are scenes
(`ObjectiveRail`, `InteractionPrompt`, `MorningNotePanel`, `MiddayEventCard`,
`FailCard`); the rest are scripts.

| # | Autoload | Source |
|---|---|---|
| 1 | `DataLoaderSingleton` | `game/autoload/data_loader.gd` — JSON content discovery and raw-data exposure |
| 2 | `ContentRegistry` | `game/autoload/content_registry.gd` — typed catalogs and canonical IDs |
| 3 | `EventBus` | `game/autoload/event_bus.gd` — cross-system signal hub |
| 4 | `GameManager` | `game/autoload/game_manager.gd` — top-level FSM (`MAIN_MENU`, `GAMEPLAY`, `PAUSED`, `GAME_OVER`, `LOADING`, `DAY_SUMMARY`, `BUILD`, `MALL_OVERVIEW`, `STORE_VIEW`) and run-session entry points |
| 5 | `RandomStreamIds` | `game/scripts/core/random_stream_ids.gd` — shared random-stream id constants |
| 6 | `GameRandom` | `game/autoload/game_random.gd` — deterministic random stream service |
| 7 | `UserDataPaths` | `game/autoload/user_data_paths.gd` — normal and automation-scoped `user://` persistence paths |
| 8 | `ScenarioExit` | `game/autoload/scenario_exit.gd` — automation scenario process-status owner |
| 9 | `AutomationRunner` | `game/autoload/automation_runner.gd` — parses `--test-mode` automation CLI flags and starts supported scenarios after boot |
| 10 | `AudioManager` | `game/autoload/audio_manager.gd` — buses, streams, SFX; instantiates `AudioEventHandler` (`game/autoload/audio_event_handler.gd`) as a child node, not a registered autoload |
| 11 | `Settings` | `game/autoload/settings.gd` |
| 12 | `EnvironmentManager` | `game/autoload/environment_manager.gd` |
| 13 | `CameraManager` | `game/autoload/camera_manager.gd` — read-only viewport observer |
| 14 | `StaffManager` | `game/autoload/staff_manager.gd` |
| 15 | `ReputationSystemSingleton` | `game/autoload/reputation_system.gd` |
| 16 | `DifficultySystemSingleton` | `game/autoload/difficulty_system.gd` |
| 17 | `UnlockSystemSingleton` | `game/autoload/unlock_system.gd` |
| 18 | `CheckoutSystem` | `game/autoload/checkout_system.gd` |
| 19 | `OnboardingSystemSingleton` | `game/autoload/onboarding_system.gd` |
| 20 | `TooltipManager` | `game/autoload/tooltip_manager.gd` |
| 21 | `ObjectiveRail` | `game/scenes/ui/objective_rail.tscn` (scene) |
| 22 | `InteractionPrompt` | `game/scenes/ui/interaction_prompt.tscn` (scene) |
| 23 | `ObjectiveDirector` | `game/autoload/objective_director.gd` |
| 24 | `AuditOverlay` | `game/autoload/audit_overlay.gd` |
| 25 | `AuditLog` | `game/autoload/audit_log.gd` |
| 26 | `LedgerSystem` | `game/autoload/ledger_system.gd` — per-transaction event log plus `day_closed` anchor records used for daily revenue reconciliation; initialized with `time_system` in Tier 5 |
| 27 | `EventLog` | `game/autoload/event_log.gd` — structured per-event timeline (inventory mutations, customer FSM transitions, day lifecycle, money/stat changes, modal open/close, gameplay-ready, objective completions). Re-broadcasts each entry as `EventBus.event_logged(tag, message)` in every build for the player-facing on-screen log surface; the ring buffer + stdout print are debug-only |
| 28 | `SceneRouter` | `game/autoload/scene_router.gd` — sole caller of `change_scene_to_*` |
| 29 | `ErrorBanner` | `game/autoload/error_banner.gd` |
| 30 | `CameraAuthority` | `game/autoload/camera_authority.gd` — single-current-camera authority |
| 31 | `InputFocus` | `game/autoload/input_focus.gd` — modal/context stack |
| 32 | `ModalQueue` | `game/autoload/modal_queue.gd` — priority-ordered FIFO that grants `CTX_MODAL` to one `ModalPanel` at a time; cleared by `SceneRouter` before every scene swap |
| 33 | `ModalDimOverlay` | `game/autoload/modal_dim_overlay.gd` — full-screen dimmer placed behind any open modal panel |
| 34 | `StoreRegistry` | `game/autoload/store_registry.gd` — runtime cache seeded from `ContentRegistry` |
| 35 | `StoreDirector` | `game/autoload/store_director.gd` |
| 36 | `GameState` | `game/autoload/game_state.gd` — run-state SSOT (active store, day, money) |
| 37 | `StoreSessionState` | `game/scripts/store_session/store_session_state.gd` — store-session run-state SSOT (active day, pre-opening progress, carried stock, customer/customer-result fields, counters, and end-of-day summary payload). Old beta run-state save keys are unsupported. |
| 38 | `StoreSessionHUD` | `game/autoload/store_session_hud.gd` — session-level owner of the store-session status and event-log panels; spawns both panels once at boot and exposes `activate(day)` / `deactivate()`. Registered after `StoreSessionState`/`EventBus`/`InputFocus` so panels can read the current store-session state and subscribe to signals in `_ready`. |
| 39 | `EmploymentSystem` | `game/autoload/employment_system.gd` — seasonal-employee state (trust, approval, hours, status), daily wages, and end-of-season retention/firing evaluation |
| 40 | `PlatformSystem` | `game/scripts/systems/platform_system.gd` — per-platform supply/demand/hype, daily price ticks, and platform-affinity spawn weighting |
| 41 | `StoreCustomizationSystem` | `game/scripts/systems/store_customization_system.gd` — per-day featured-display and promotional-poster choices, spawn-weight and demand multipliers, and trust/hidden-thread linkage |
| 42 | `ShiftSystem` | `game/scripts/systems/shift_system.gd` — daily clock-in/clock-out state, including 08:55 auto clock-in and trust penalties for late or missing punches |
| 43 | `ManagerRelationshipManager` | `game/autoload/manager_relationship_manager.gd` — player↔manager trust scalar/tier and morning-note selection on `day_started` |
| 44 | `MorningNotePanel` | `game/scenes/ui/morning_note_panel.tscn` (scene) — paper-memo overlay listening for `manager_note_shown` |
| 45 | `MiddayEventSystem` | `game/scripts/systems/midday_event_system.gd` — midday decision-beat queue, pauses time on pending beat, applies resolved structured effects |
| 46 | `MiddayEventCard` | `game/scenes/ui/midday_event_card.tscn` (scene) — modal "STORE EVENT" decision card emitted on `midday_event_fired` / `midday_event_resolved` |
| 47 | `FailCard` | `game/scenes/ui/fail_card.tscn` (scene) |
| 48 | `TutorialContextSystem` | `game/autoload/tutorial_context_system.gd` |
| 49 | `Day1ReadinessAudit` | `game/autoload/day1_readiness_audit.gd` — composite Day 1 playable check that subscribes to `StoreDirector.store_ready` and emits `AuditLog.pass_check(&"day1_playable_ready", …)` / `fail_check(&"day1_playable_failed", …)` |
| 50 | `HiddenThreadSystemSingleton` | `game/autoload/hidden_thread_system.gd` — cumulative awareness / paper-trail / scapegoat-risk stats and Tier 1/2/3 trigger evaluation across the run |

Single-owner responsibilities for the ownership-enforcing subset are tracked
in [`docs/architecture/ownership.md`](architecture/ownership.md).

## Signal Bus Model

`EventBus` is the central cross-system signal hub. Owner autoloads such as
`StoreDirector`, `SceneRouter`, `GameState`, `InputFocus`, and
`CameraAuthority` remain the authoritative emitters for their owned events;
`EventBus` carries mirrored or gameplay-facing signals for listeners that do
not own those systems.

Pattern:

```text
emitter.gd  ->  EventBus.signal_name.emit(payload)  ->  receiver.gd
```

Signal name conventions used in `event_bus.gd`:

| Prefix | Domain |
|---|---|
| `store_` | Store entry/exit, lease, store ready/failed, register/shelf events |
| `day_` / `hour_` | Day open/close/end, hour ticks, phase transitions, speed changes |
| `customer_` | Spawn, browse decision, haggle, purchase, depart |
| `inventory_` | Stock changes, item add/remove, price set |
| `reputation_` | Tier change, decay tick |
| `milestone_` / `unlock_` / `completion_` | Progression triggers |
| `tutorial_` / `onboarding_` | Tutorial step changes, hints |
| `interactable_` / `panel_` | UI focus and modal open/close (`panel_opened` / `panel_closed`); 3D and 2D hover events |

`run_state_changed()` is a parameterless mirror that lets listeners react to
any `GameState` mutation without subscribing to each typed setter.

## Scene Entry Points

| Scene | Role |
|---|---|
| `game/scenes/bootstrap/boot.tscn` | Entry scene; runs boot script, transitions to main menu |
| `game/scenes/ui/main_menu.tscn` | Main menu; routes `New Game` and load-slot through `GameManager.start_new_game` / `pending_load_slot` |
| `game/scenes/bootstrap/gameplay_shell.tscn` | Gameplay shell scene swapped in by `GameManager.start_new_game`; embeds `game_world.tscn`, the hub UI overlay (settings/progress buttons), and `drawer_host.tscn` |
| `game/scenes/world/game_world.tscn` | Root of the playable world; runs the five init tiers; owns runtime systems and instantiates HUD + panel scenes |
| `game/scenes/world/mall_hallway.tscn` | Optional walkable-mall hub variant; only loaded when `debug/walkable_mall = true` |
| `game/scenes/world/storefront.tscn` | Storefront-card slot scene used by `mall_hallway` when the walkable variant is enabled |
| `game/scenes/stores/retro_games.tscn` | Per-store 3D interior; camera framing via `CameraAuthority` |
| `game/scenes/ui/day_summary.tscn` | End-of-day summary panel |
| `game/scenes/ui/hud.tscn` | Persistent overlay: time/phase indicator, funds, reputation tier, live counters |

By default `debug/walkable_mall` is `false` in `project.godot`, so the
shipping flow is "hub mode": `GameWorld._setup_hub_mode` creates a
`SceneTransition`; on a new run, `apply_pending_session_state` calls
`_auto_enter_default_store_in_hub`, which emits
`EventBus.enter_store_requested(GameManager.DEFAULT_STARTING_STORE)`, and the
director enters the starter store directly without instantiating the
`mall_hallway` scene.

Store entry routes through `EventBus.enter_store_requested`, handled by
`GameWorld._on_hub_enter_store_requested`, which calls
`StoreDirector.enter_store(store_id)`. `StoreDirector` is the single entry
point and uses the injector seam (`set_scene_injector`) to load the store
scene under `StoreContainer` rather than swap the root scene; the
`StoreReadyContract` runs against the injected root before
`store_ready` is emitted.

## Visual Systems

The following reusable building blocks are the current code-backed visual
surfaces and helpers.

| Need | Use this | File |
|---|---|---|
| First-person in-store player body (WASD, mouse-look, sprint, interact) | `StorePlayerBody` spawned at `PlayerEntrySpawn` by `GameWorld._spawn_player_in_store` | `game/scripts/player/store_player_body.gd` |
| Reticle-driven interaction ray from the active store camera | `InteractionRay` (authored under `PlayerController/StoreCamera` in `retro_games.tscn`; the reusable player scene also carries an `InteractionRay` child that binds to `CameraManager.active_camera`) | `game/scripts/player/interaction_ray.gd` |
| Debug overhead/orbit camera (F1 dev toggle) | `PlayerController` (orbit pivot + ortho framing) | `game/scripts/player/player_controller.gd` |
| Build-mode orbit / pan / zoom camera with Tween transitions | `BuildModeCamera` | `game/scripts/world/build_mode_camera.gd` |
| Camera ownership / single-current assertion | `CameraAuthority.request_current(cam, source)` | `game/autoload/camera_authority.gd` |
| Hover highlight shader on 3D interactable | `Interactable.highlight()` + `mat_outline_highlight.tres` | `game/scripts/components/interactable.gd`, `game/assets/shaders/mat_outline_highlight.tres` |
| Hover tint on 2D Controls | `InteractableHover` (`self_modulate` → `ACCENT_INTERACT`) | `game/scripts/ui/interactable_hover.gd` |
| Delayed hover tooltip at cursor | `TooltipManager.show_tooltip(text, pos)` + `TooltipTrigger` | `game/autoload/tooltip_manager.gd` |
| `[E] to interact` contextual hint | `InteractionPrompt` listening to `EventBus.interactable_focused` | `game/scenes/ui/interaction_prompt.tscn` |
| Screen-center reticle for the FP camera | `Crosshair` CanvasLayer | `game/scenes/ui/crosshair.tscn` |
| One-unit shelf slot with empty→stocked mesh swap | `ShelfSlot` (extends `Interactable`) | `game/scripts/stores/shelf_slot.gd` |
| Store-session NPC silhouette | `StoreSessionCharacterVisualFactory` builds the reusable manager/customer proxy; the controller supplies role/state only | `game/scripts/visuals/store_session_character_visual_factory.gd` |
| Reusable store fixtures and props | `StoreVisualKit` resolves fixture IDs to scene assets for layouts and runtime feedback | `game/scripts/visuals/store_visual_kit.gd` |
| Generated store layout and physical contracts | `StoreVisualLayout` loads fixture/product placements plus physical contracts; `StoreLayoutRuntime` builds fixture visuals; `ExpandableStoreShellRuntime` uses the starter physical contract for shell anchors, bounds, routes, checkout, and stockroom geometry; `StorePhysicalContractValidator` / `StoreRoomContractValidator` validate contract metadata | `game/scripts/visuals/store_visual_layout.gd`, `game/scripts/visuals/store_layout_runtime.gd`, `game/scripts/visuals/expandable_store_shell_runtime.gd`, `game/scripts/visuals/store_physical_contract_validator.gd`, `game/scripts/visuals/store_room_contract_validator.gd` |
| Item-specific shelf/counter product art | `ProductVisualFactory` + product visual catalog build store-facing product cases from inventory item data | `game/scripts/visuals/product_visual_factory.gd`, `game/content/visuals/retro_games_product_visual_catalog.json` |
| Day/night light interpolation | `DayPhaseLighting` tweening `DirectionalLight3D` | `game/scripts/world/day_phase_lighting.gd` |
| CRT scanline post-process shader (2D UI) | `crt_overlay.gdshader` | `game/resources/shaders/crt_overlay.gdshader` |
| Modal open/close tween pattern | `PanelAnimator.modal_open / slide_open / stagger_fade_in` | `game/scripts/ui/panel_animator.gd` |
| Canonical CanvasLayer band assignment | `UILayers` constants | `game/scripts/ui/ui_layers.gd` |
