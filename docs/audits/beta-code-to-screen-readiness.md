# Beta Code-To-Screen Readiness Audit

Date: 2026-05-23

This audit maps the current beta Day 1 route proof surfaces. It is separate
from the store-entry readiness checkpoint: `Day1ReadinessAudit` emits
`day1_playable_ready`, while the route proof artifacts below cover the
player-facing Day 1 loop after entry.

## Proof Contract

`game/scripts/beta/beta_code_to_screen_proof_contract.gd` defines the required
proof fields for each route beat:

| Field | Code meaning |
| --- | --- |
| `screen_object` | Visible object or panel that must appear for the beat. |
| `input_affordance` | Prompt, modal control, or normal route input used by the beat. |
| `code_owner` | Script that owns the behavior. |
| `state_mutation` | Stage, objective, count, customer, inventory, cash, or summary state expected from the beat. |
| `screen_feedback` | Screenshot-facing evidence expected for the beat. |
| `next_beat` | Route step enabled by completing the beat. |
| `test_capture` | Automated assertion references plus the capture helper call. |

`tests/gut/test_manual_day_one_route_capture.gd` validates that every manifest
beat includes the full proof payload.

## Route Manifest

`game/scripts/beta/beta_manual_day_one_route_capture.gd` writes a
`manual_day1_loop_route` manifest under
`user://screenshots/manual_routes/retro_games_day_one_loop`. The manifest
contains ordered beats, a manual review checklist, capture metadata, and the
proof contract metadata.

Required review beats in the script:

| Beat | Route surface |
| --- | --- |
| `manager_prompt` | Manager proxy at checkout and opening checklist. |
| `register_prompt` | Register target and register prompt. |
| `backroom_pickup_prompt` | Back-room pickup target and stockroom counter. |
| `training_shelf_transition` | Shelf stocking prompt after stock pickup. |
| `before_customer` | Customer proxy at checkout before the decision card. |
| `customer_decision_card` | Customer decision modal. |
| `after_result_customer_exit` | Customer exit state after result acknowledgement. |
| `stocked_shelf_stat_change` | Post-customer shelf and stat update. |
| `close_day_prompt` | Close-day register trigger. |
| `close_day_summary` | Day summary panel. |

## Current Code Owners

| Surface | Current owner |
| --- | --- |
| Day 1 route state machine, objective advancement, customer resolution, summary payload | `game/scripts/beta/beta_day_one_controller.gd` |
| Back-room pickup interaction bridge | `game/scripts/beta/beta_backroom_pickup_interactable.gd` |
| Shelf stocking interaction bridge | `game/scripts/beta/beta_restock_interactable.gd` |
| Customer interaction bridge | `game/scripts/beta/beta_day1_customer_interactable.gd` |
| Customer decision modal | `game/scripts/beta/beta_decision_card_panel.gd` |
| Customer result acknowledgement modal | `game/scripts/beta/beta_customer_result_panel.gd` |
| Persistent register display state | `game/scripts/beta/register_screen_state.gd` |
| First-person carried stock marker | `game/scripts/beta/beta_carried_stock_marker.gd` |
| Real-inventory vs tutorial-count adapter | `game/scripts/beta/beta_inventory_count_adapter.gd` |
| Beta day summary panel | `game/scripts/beta/beta_day_summary_panel.gd` |

## Automated Coverage

Current GUT coverage tied to this route includes:

| Test file | Covered surface |
| --- | --- |
| `tests/gut/test_beta_day_one_critical_path.gd` | Full Day 1 route through summary, route target activation, shelf visuals, customer decision/result flow, sale/exchange/refusal variants, close-day gating. |
| `tests/gut/test_beta_day_one_vertical_slice_validation.gd` | Prompt visibility, decision modal visibility, customer exit visibility, result reset, shelf item rendering, summary visibility, counter/receipt anchor visibility. |
| `tests/gut/test_beta_customer_repeat_loop.gd` | Two-customer route ordering, Day 2 result visibility, repeat-customer no-stock routing. |
| `tests/gut/test_beta_customer_inventory_effects.gd` | Customer inventory transactions and beta inventory-count adapter behavior. |
| `tests/gut/test_manual_day_one_route_capture.gd` | Route manifest schema, required beat list, capture metadata, proof payload completeness. |
| `tests/gut/test_register_screen_state.gd` | Persistent register screen states and receipt visibility. |
| `tests/gut/test_beta_restock_shelf_visual_spec.gd` | Stock carry, shelf count, and visible shelf item behavior. |

## Runtime Artifacts

The beta screenshot helper writes viewport captures under
`user://screenshots/`. `BetaManualDayOneRouteCapture.write_route_manifest()`
writes `route_manifest.json` and `manual_review.md` into a timestamped
manual-route run directory.
