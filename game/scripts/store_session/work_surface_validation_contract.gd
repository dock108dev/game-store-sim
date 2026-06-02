## Close-out validation contract for focused store-session work-surface passes.
class_name WorkSurfaceValidationContract
extends RefCounted

const InspirationCloseoutContractScript: GDScript = preload(
	"res://game/scripts/store_session/inspiration_closeout_contract.gd"
)
const REQUIRED_STATIC_COMMANDS: Array[String] = [
	"gdlint game/",
	"git diff --check",
]
const FULL_GUT_COMMAND: String = "godot --headless --script res://addons/gut/gut_cmdln.gd"
const STORE_VISUAL_SWEEP_COMMAND: String = "bash scripts/run_store_visual_sweep.sh"
const MANUAL_ROUTE_CAPTURE_CONTRACT: String = (
	"res://game/scripts/store_session/manual_day_one_route_capture.gd"
)

const _FOCUSED_TESTS_BY_SURFACE: Dictionary = {
	"register": [
		"res://tests/gut/test_register_screen_state.gd",
		"res://tests/gut/test_register_interactable.gd",
		"res://tests/gut/test_checkout_register_positioning.gd",
		"res://tests/gut/test_store_session_preopening_training.gd",
		"res://tests/gut/test_store_session_day_one_critical_path.gd",
	],
	"stock_closet": [
		"res://tests/gut/test_customer_nav_config.gd",
		"res://tests/gut/test_retro_games_navigation.gd",
		"res://tests/gut/test_stockroom_pickup_prompt_contract.gd",
		"res://tests/gut/test_store_session_day_one_critical_path.gd",
	],
	"shelf_table": [
		"res://tests/gut/test_starter_display_table_stock_states.gd",
		"res://tests/gut/test_store_restock_shelf_visual_spec.gd",
		"res://tests/gut/test_inventory_shelf_actions_stocking.gd",
		"res://tests/gut/test_store_session_day_one_critical_path.gd",
		"res://tests/gut/test_visual_overhaul_validation_gate.gd",
	],
	"hud": [
		"res://tests/gut/test_hud.gd",
		"res://tests/gut/test_store_session_hud.gd",
		"res://tests/gut/test_hud_ready_checkpoint.gd",
		"res://tests/gut/test_objective_rail_day1_visibility.gd",
		"res://tests/gut/test_interaction_prompt.gd",
		"res://tests/gut/test_visual_overhaul_validation_gate.gd",
	],
	"route_state": [
		"res://tests/gut/test_store_session_preopening_training.gd",
		"res://tests/gut/test_store_session_day_one_critical_path.gd",
		"res://tests/gut/test_store_session_day_one_vertical_slice_validation.gd",
		"res://tests/gut/test_store_session_state_day_transition.gd",
		"res://tests/gut/test_manual_day_one_route_capture.gd",
	],
}
const _VISUAL_SWEEP_REQUIRED_CHANGE_TYPES: Array[String] = [
	"geometry",
	"camera",
	"readability",
	"visual_scope",
	"prop",
	"visual_art",
]
const _MANUAL_ROUTE_CAPTURE_REQUIRED_CHANGE_TYPES: Array[String] = [
	"prompt_ownership",
	"hud_copy",
	"route_stage",
]
const _OUTPUT_CHANNELS: Array[Dictionary] = [
	{
		"id": "authored_full_scene_checks",
		"label": "Authored-full scene checks",
		"source": "StoreVisualSweep.full_store_review_context()",
		"acceptance_role": "secondary_context_only",
	},
	{
		"id": "store_session_runtime_checks",
		"label": "Store-session runtime checks",
		"source": "StoreVisualSweep.rows() runtime visual-scope beats",
		"acceptance_role": "automated_runtime_gate",
	},
	{
		"id": "reference_visible_visual_review",
		"label": "Reference-visible visual review",
		"source": "StoreVisualSweep.rows() reference-visible beats",
		"acceptance_role": "display_backed_review_gate",
	},
	{
		"id": "manual_route_captures",
		"label": "Manual route captures",
		"source": "ManualDayOneRouteCapture.route_beats()",
		"acceptance_role": "route_state_review_gate",
	},
]
const _BLOCKING_FAILURES: Array[String] = [
	"prompt ownership failure",
	"duplicate HUD copy",
	"missing work-surface anchor",
	"hidden prop-density guardrail failure",
	"non-acceptance screenshot evidence",
]


static func closure_manifest() -> Dictionary:
	return {
		"required_static_commands": REQUIRED_STATIC_COMMANDS.duplicate(),
		"full_gut_command": FULL_GUT_COMMAND,
		"focused_gut_command_pattern": "%s -- -gtest=<test_path>" % FULL_GUT_COMMAND,
		"store_visual_sweep_command": STORE_VISUAL_SWEEP_COMMAND,
		"manual_route_capture_contract": MANUAL_ROUTE_CAPTURE_CONTRACT,
		"visual_sweep_required_change_types": visual_sweep_required_change_types(),
		"manual_route_capture_required_change_types":
		manual_route_capture_required_change_types(),
		"originality_required_change_types": originality_required_change_types(),
		"required_originality_commands":
		InspirationCloseoutContractScript.required_originality_commands(),
		"originality_source_policy": InspirationCloseoutContractScript.source_policy(),
		"focused_tests_by_surface": focused_tests_by_surface(),
		"validation_output_channels": output_channels(),
		"blocking_failures": blocking_failures(),
	}


static func focused_tests_by_surface() -> Dictionary:
	return _FOCUSED_TESTS_BY_SURFACE.duplicate(true)


static func visual_sweep_required_change_types() -> Array[String]:
	return _VISUAL_SWEEP_REQUIRED_CHANGE_TYPES.duplicate()


static func manual_route_capture_required_change_types() -> Array[String]:
	return _MANUAL_ROUTE_CAPTURE_REQUIRED_CHANGE_TYPES.duplicate()


static func originality_required_change_types() -> Array[String]:
	return InspirationCloseoutContractScript.originality_required_change_types()


static func output_channels() -> Array[Dictionary]:
	return _OUTPUT_CHANNELS.duplicate(true)


static func blocking_failures() -> Array[String]:
	return _BLOCKING_FAILURES.duplicate()


static func requires_visual_sweep(change_type: String) -> bool:
	return _VISUAL_SWEEP_REQUIRED_CHANGE_TYPES.has(change_type)


static func requires_manual_route_capture(change_type: String) -> bool:
	return _MANUAL_ROUTE_CAPTURE_REQUIRED_CHANGE_TYPES.has(change_type)


static func requires_originality_validation(change_type: String) -> bool:
	return originality_required_change_types().has(change_type)
