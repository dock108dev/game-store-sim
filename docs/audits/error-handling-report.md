# Error Handling Report

Date: 2026-06-02

This report documents the handled-error contracts cited by current code
comments. It is a section-id reference for code comments, not a separate
remediation list.

## Runtime Assertions

| ID | Current contract | Code basis |
| --- | --- | --- |
| `EH-AS-1` | Debug-only `assert()` checks are paired with runtime `push_error` or `AuditLog.fail_check` on the same owned path, so release builds still emit an observable failure record where the project relies on the check. | `game/autoload/audit_log.gd`, `game/autoload/store_registry.gd`, `game/autoload/camera_authority.gd` |

## Player-Visible UI Fallbacks

| ID | Current contract | Code basis |
| --- | --- | --- |
| `EH-02` | Empty placement-hint item names are accepted and rendered as a generic prompt; store-session mode suppresses build-placement hints. | `game/scripts/ui/placement_hint_ui.gd` |
| `EH-05` | `CloseDayPreview` warns when its snapshot callback is not wired because the dry run would otherwise inspect an empty shelf snapshot. | `game/scenes/ui/close_day_preview.gd` |
| `EH-09` | Missing close-day preview UI is a wiring regression and emits `push_error`; the day-close command is not silently ignored. | `game/scenes/ui/hud.gd` |
| `F-53` | An interactable with no prompt label returns an empty label instead of logging on every hover frame, because the empty prompt panel is already visible evidence. | `game/scripts/player/interaction_ray.gd` |
| `F-54` | HUD notification forwarding preserves existing `notification_requested` and `critical_notification_requested` emitters. Empty messages are swallowed because there is no UI payload to render. | `game/scenes/ui/hud.gd` |

## Content And Runtime Data

| ID | Current contract | Code basis |
| --- | --- | --- |
| `EH-11` | Despawning a null customer is a caller bug and emits `push_error`; this avoids silently losing customer lifecycle accounting. | `game/scripts/systems/customer_system.gd` |
| `EH-12` | Store-session day and event JSON open/parse failures emit `push_error` for required files. Optional future-day files may warn and return `{}`. | `game/scripts/store_session/store_session_controller.gd` |
| `EH-16` | Starting-inventory failures return an empty array only after emitting `push_error`, so boot and CI see content-authoring regressions that would empty Day 1 stock. | `game/autoload/data_loader.gd` |
| `EH-17` | Unknown environment zones warn and keep the previous environment, because tests intentionally emit sentinel store ids and gameplay can continue with the prior environment. | `game/autoload/environment_manager.gd` |
| `F-16` | `GameWorld` state validation emits `push_error` and a player notification, then keeps the run alive because degraded gameplay is preferred to forcing a menu return. | `game/scenes/world/game_world.gd` |

## Checkout And Register

| ID | Current contract | Code basis |
| --- | --- | --- |
| `EH-18` | Invalid `initiate_sale` inputs warn and leave checkout processing false because tests intentionally exercise null-customer and zero-price rejection paths. | `game/scripts/systems/checkout_system.gd` |
| `EH-19` | Missing checkout or haggle panel wiring emits `push_error`; otherwise customers can stall at the register with no diagnostic. | `game/scripts/systems/checkout_system.gd` |

## Typed Autoload Access

| ID | Current contract | Code basis |
| --- | --- | --- |
| `EH-13` / `EH-15` | Dead guard shapes that walk autoloads or probe methods before calling required owner APIs are avoided on ownership-critical paths. Typed autoload calls make owner API renames fail at parse/runtime validation instead of silently skipping behavior. | `game/autoload/store_registry.gd` |
| `EH-31` | Store registry seeding uses typed `ContentRegistry` methods instead of `has_method` probes; a renamed registry API should fail loudly. | `game/autoload/store_registry.gd` |
| `EH-38` | StoreRegistry connects to typed `EventBus.content_loaded` and typed `ContentRegistry` methods because those owners are registered autoloads in `project.godot`. | `game/autoload/store_registry.gd` |

## Silent Test/Early-Boot Seams

| ID | Current contract | Code basis |
| --- | --- | --- |
| `J1` | `GameManager._resolve_system_ref` returns a null weak reference silently for early callers and headless fixtures; callers that require a system must assert presence themselves. | `game/autoload/game_manager.gd` |
| `J2` | HUD inventory and cash seeding may silently skip on the first frame or in headless tests because `GameWorld` Tier 5 can construct UI before every system is live; later signals re-poll. | `game/scenes/ui/hud.gd` |
| `J3` | `KpiStrip` silently skips milestone seeding before `GameManager.data_loader` is present and re-polls on gameplay readiness. | `game/scripts/ui/kpi_strip.gd` |
