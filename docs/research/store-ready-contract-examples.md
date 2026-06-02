# Store Ready Contract Examples

Date: 2026-06-02

`game/scripts/stores/store_ready_contract.gd` defines the synchronous contract
for declaring a store scene ready. `StoreDirector` is the owner that uses this
contract before emitting store readiness.

## Required Invariants

| Invariant | Meaning |
| --- | --- |
| `store_id_resolved` | The scene exposes `get_store_id()` and returns a non-empty `StringName`. |
| `scene_loaded` | The scene exists and is inside the SceneTree. |
| `controller_initialized` | The scene exposes `is_controller_initialized()` and returns `true`. |
| `content_instantiated` | The root has real content children beyond scaffolding cameras, lights, markers, or player anchors. |
| `camera_current` | At least one `Camera2D` or `Camera3D` under the scene is current. |
| `player_present` | A `PlayerController`, `Player`, or `OrbitPivot` anchor exists. |
| `input_gameplay` | The scene exposes `get_input_context()` and returns `&"store_gameplay"`. |
| `no_modal_focus` | The scene exposes `has_blocking_modal()` and returns `false`. |
| `interaction_count_ge_1` | At least one node in the `interactables` group is under the scene. |
| `objective_matches_action` | The scene exposes `objective_matches_action()` and returns `true`. |

## Current Ownership

Partial readiness is not a state. The contract returns all failed invariants so
the director can surface one complete diagnostic, and ownership remains aligned
with `docs/architecture/ownership.md`.
