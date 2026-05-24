## Shared code-to-screen proof schema for store_session route artifacts.
class_name StoreCodeToScreenProofContract
extends RefCounted

const REQUIRED_FIELDS: Array[String] = [
	"screen_object",
	"input_affordance",
	"code_owner",
	"state_mutation",
	"screen_feedback",
	"next_beat",
	"test_capture",
]


static func contract_metadata() -> Dictionary:
	return {
		"fields": REQUIRED_FIELDS.duplicate(),
		"loop_readiness_artifact": true,
		"entry_readiness_checkpoint": "day1_playable_ready",
		"scope": "Day 1 gameplay route proof, separate from store-entry readiness.",
	}


static func proof_from_route_beat(beat: Dictionary) -> Dictionary:
	var beat_name: String = str(beat.get("beat_name", ""))
	var refs: Array = beat.get("automated_route_assertions", []) as Array
	return {
		"screen_object": _screen_object(beat_name, beat),
		"input_affordance": _input_affordance(beat_name, beat),
		"code_owner": _code_owner(beat_name),
		"state_mutation": _state_mutation(beat),
		"screen_feedback": _screen_feedback(beat),
		"next_beat": _next_beat(beat_name),
		"test_capture": "%s; capture %s" % [
			", ".join(PackedStringArray(refs)),
			str(beat.get("capture_helper_call", "")),
		],
	}


static func validate_route_beats(beats: Array) -> Array[String]:
	var errors: Array[String] = []
	for beat_variant: Variant in beats:
		var beat: Dictionary = beat_variant as Dictionary
		var beat_name: String = str(beat.get("beat_name", ""))
		errors.append_array(validate_proof_payload(
			beat.get("code_to_screen_proof", {}) as Dictionary,
			beat_name
		))
	return errors


static func validate_proof_payload(
	proof: Dictionary,
	label: String = "proof"
) -> Array[String]:
	var errors: Array[String] = []
	for field: String in REQUIRED_FIELDS:
		if not proof.has(field) or _is_blank(proof.get(field, "")):
			errors.append("%s missing %s" % [label, field])
	return errors


static func _screen_object(beat_name: String, beat: Dictionary) -> String:
	match beat_name:
		"manager_prompt":
			return "Manager proxy at checkout plus right-panel opening checklist."
		"register_prompt":
			return "Checkout register target and register-ready prompt."
		"backroom_pickup_prompt":
			return "Back-room stock box pickup target and stockroom counter."
		"training_shelf_transition", "stocked_shelf_stat_change":
			return "Used-games shelf display with visible shelf and stockroom counts."
		"before_customer", "customer_decision_card", "result_acknowledgement", \
		"after_result_customer_exit":
			return "Customer proxy at checkout, customer modal, and HUD stat counters."
		"close_day_prompt":
			return "Close-day register trigger plus completed Day 1 checklist state."
		"close_day_summary":
			return "Day summary panel with sales, rent, profit, inventory, and customer values."
	return "%s route capture surface." % str(beat.get("label", "store route"))


static func _input_affordance(beat_name: String, beat: Dictionary) -> String:
	var prompt: String = str(beat.get("active_prompt", ""))
	match beat_name:
		"customer_decision_card", "result_acknowledgement", "close_day_summary":
			return "Modal choice/acknowledgement controls are selectable from normal route input."
	return (
		"Interaction prompt `%s` appears during the normal route "
		+ "and reaches its beat owner."
	) % prompt


static func _code_owner(beat_name: String) -> String:
	match beat_name:
		"backroom_pickup_prompt":
			return (
				"stockroom_pickup_interactable.gd bridges input; "
				+ "store_session_controller.gd owns progression."
			)
		"training_shelf_transition", "stocked_shelf_stat_change":
			return (
				"restock_interactable.gd bridges input; "
				+ "store_session_controller.gd owns shelf progression."
			)
		"before_customer", "customer_decision_card", "result_acknowledgement", \
		"after_result_customer_exit":
			return (
				"first_day_customer_interactable.gd bridges input; "
				+ "store_session_controller.gd owns customer progression."
			)
		"close_day_prompt", "close_day_summary":
			return "store_session_controller.gd owns close-day flow and summary payload."
	return "store_session_controller.gd owns Day 1 progression for this beat."


static func _state_mutation(beat: Dictionary) -> String:
	return "Stage `%s`, objective `%s`, counts %s, customer %s, deltas %s, summary %s." % [
		str(beat.get("expected_stage", "")),
		str(beat.get("expected_objective", "")),
		str(beat.get("shelf_backroom_counts", {})),
		str(beat.get("customer_state", {})),
		str(beat.get("inventory_cash_deltas", {})),
		str(beat.get("summary_values", {})),
	]


static func _screen_feedback(beat: Dictionary) -> String:
	return "Capture `%s` must show prompt/modal/HUD evidence %s." % [
		str(beat.get("filename", "")),
		str(beat.get("hud_right_panel", {})),
	]


static func _next_beat(beat_name: String) -> String:
	var chain: Dictionary = {
		"manager_prompt": "Register prompt enables after manager interaction.",
		"register_prompt": "Back-room pickup prompt enables after register check.",
		"backroom_pickup_prompt": "Shelf stocking prompt enables after stock pickup.",
		"training_shelf_transition": "Customer prompt enables after shelf stocking.",
		"before_customer": "Customer decision card opens from customer interaction.",
		"customer_decision_card": "Result acknowledgement appears after choice selection.",
		"result_acknowledgement": "Customer exit and post-customer stock route become visible.",
		"after_result_customer_exit": "Post-customer shelf/stat update route becomes available.",
		"stocked_shelf_stat_change": "Close-day trigger enables after final shelf update.",
		"close_day_prompt": "Close confirmation leads to day summary.",
		"close_day_summary": "Summary review completes the route artifact.",
	}
	return str(chain.get(beat_name, "Next Day 1 route beat is documented in manifest order."))


static func _is_blank(value: Variant) -> bool:
	if value == null:
		return true
	return str(value).strip_edges().is_empty()
