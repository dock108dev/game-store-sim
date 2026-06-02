## Action-context contract for first-day visual sweep review rows.
class_name StoreVisualActionContext
extends RefCounted

const REQUIRED_ACTION_MOMENTS: Array[String] = [
	"checkout",
	"backroom_pickup",
	"restock_table",
	"product_inspection",
	"close_day",
]


## Returns action-context metadata for a normal player approach screenshot.
static func context(
	moment: String,
	active_target: String,
	active_prompt: String,
	local_action: String,
	next_destination: String,
	actionable_candidates: Array[Dictionary],
	approach_angle: String
) -> Dictionary:
	return {
		"moment": moment,
		"active_target": active_target,
		"active_prompt": active_prompt,
		"local_action": local_action,
		"next_destination": next_destination,
		"actionable_candidates": actionable_candidates,
		"approach_angle": approach_angle,
		"normal_player_approach": true,
		"tight_closeup": false,
		"shows_next_destination": true,
		"ambiguity_policy": "exactly_one_active_candidate",
	}


## Returns one nearby candidate in the row's action-context disambiguation list.
static func candidate(path: String, state: String, reason: String) -> Dictionary:
	return {
		"path": path,
		"state": state,
		"reason": reason,
	}


## Returns a validation result for the active action context bound to a sweep row.
static func validate_row(row: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var context_payload: Dictionary = row.get("action_context", {}) as Dictionary
	if context_payload.is_empty():
		errors.append("missing_action_context")
	else:
		_validate_context_fields(context_payload, errors)
		_validate_candidates(context_payload, errors)
	return {
		"ok": errors.is_empty(),
		"errors": errors,
		"moment": str(context_payload.get("moment", "")),
		"active_target": str(context_payload.get("active_target", "")),
	}


## Returns the route sequence reviewers use to judge the first-day screenshots.
static func route_sequence() -> Array[Dictionary]:
	return [
		{
			"step": "checkout",
			"destination": "manager and checkout register",
			"anchor": "StoreSessionManager",
			"moment": "checkout",
		},
		{
			"step": "backroom pickup",
			"destination": "inventory pickup",
			"anchor": "ExpandableStoreShell/StockroomFloorTape",
			"moment": "backroom_pickup",
		},
		{
			"step": "restock table",
			"destination": "restock shelf",
			"anchor": "StoreSessionRestockShelf",
			"moment": "restock_table",
		},
		{
			"step": "product sale",
			"destination": "customer and stocked product",
			"anchor": "StoreSessionDayOneCustomer",
			"moment": "product_inspection",
		},
		{
			"step": "checkout close",
			"destination": "open-store closeout",
			"anchor": "StoreSessionDayEndTrigger",
			"moment": "close_day",
		},
	]


static func _validate_context_fields(context_payload: Dictionary, errors: Array[String]) -> void:
	if str(context_payload.get("moment", "")).is_empty():
		errors.append("missing_action_moment")
	if str(context_payload.get("active_target", "")).is_empty():
		errors.append("missing_active_target")
	if str(context_payload.get("active_prompt", "")).is_empty():
		errors.append("missing_active_prompt")
	if not bool(context_payload.get("normal_player_approach", false)):
		errors.append("missing_normal_player_approach")
	if bool(context_payload.get("tight_closeup", true)):
		errors.append("tight_closeup_cannot_satisfy_route_review")
	if not bool(context_payload.get("shows_next_destination", false)):
		errors.append("missing_next_destination_context")


static func _validate_candidates(context_payload: Dictionary, errors: Array[String]) -> void:
	var active_paths: Array[String] = []
	var candidates: Array = context_payload.get("actionable_candidates", []) as Array
	if candidates.is_empty():
		errors.append("missing_actionable_candidates")
	for candidate_variant: Variant in candidates:
		var candidate_payload: Dictionary = candidate_variant as Dictionary
		var state: String = str(candidate_payload.get("state", ""))
		var path: String = str(candidate_payload.get("path", ""))
		if path.is_empty():
			errors.append("candidate_missing_path")
		if state == "active":
			active_paths.append(path)
		elif state == "disabled" and str(candidate_payload.get("reason", "")).is_empty():
			errors.append("disabled_candidate_missing_reason:%s" % path)
	if active_paths.size() != 1:
		errors.append("ambiguous_action_context:%s" % ",".join(active_paths))
	elif active_paths[0] != str(context_payload.get("active_target", "")):
		errors.append("active_candidate_does_not_match_target")
