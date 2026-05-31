extends GutTest

const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)


func test_visual_sweep_covers_required_day_one_action_moments() -> void:
	var moments: Dictionary = {}
	for row: Dictionary in StoreVisualSweepScript.rows():
		var context: Dictionary = row.get("action_context", {}) as Dictionary
		var moment: String = str(context.get("moment", ""))
		if moment.is_empty():
			continue
		moments[moment] = true
		assert_true(
			bool(StoreVisualSweepScript.validate_action_context(row).get("ok", false)),
			"%s must have unambiguous action context" % str(row.get("name", ""))
		)
		assert_eq(
			str(context.get("active_prompt", "")),
			str(row.get("active_prompt", "")),
			"%s action context must match row prompt" % str(row.get("name", ""))
		)
		assert_eq(
			str(context.get("next_destination", "")),
			str(row.get("next_destination", "")),
			"%s action context must match row destination" % str(row.get("name", ""))
		)
		assert_true(
			bool(context.get("normal_player_approach", false)),
			"%s must be reviewed from a normal approach angle" % str(row.get("name", ""))
		)
		assert_false(
			bool(context.get("tight_closeup", true)),
			"%s must not rely on a tight object closeup" % str(row.get("name", ""))
		)

	for required: String in StoreVisualSweepScript.REQUIRED_ACTION_MOMENTS:
		assert_true(
			moments.has(required),
			"Visual sweep must include action context for %s" % required
		)


func test_action_context_validation_flags_multiple_active_candidates() -> void:
	var row: Dictionary = StoreVisualSweepScript.rows()[0].duplicate(true)
	var context: Dictionary = row.get("action_context", {}) as Dictionary
	var candidates: Array = context.get("actionable_candidates", []) as Array
	candidates.append({
		"path": "StoreSessionBackroomPickup/Interactable",
		"state": "active",
		"reason": "",
	})
	context["actionable_candidates"] = candidates
	row["action_context"] = context

	var validation: Dictionary = StoreVisualSweepScript.validate_action_context(row)
	assert_false(bool(validation.get("ok", true)))
	assert_true(
		_has_error_prefix(validation.get("errors", []) as Array, "ambiguous_action_context"),
		"Multiple active nearby candidates must be flagged as ambiguous"
	)


func test_first_day_route_sequence_matches_acceptance_order() -> void:
	var expected_moments: Array[String] = [
		"checkout",
		"backroom_pickup",
		"restock_table",
		"product_inspection",
		"close_day",
	]
	var actual_moments: Array[String] = []
	for step: Dictionary in StoreVisualSweepScript.first_day_route_sequence():
		actual_moments.append(str(step.get("moment", "")))
	assert_eq(actual_moments, expected_moments)


func _has_error_prefix(errors: Array, prefix: String) -> bool:
	for error_variant: Variant in errors:
		if str(error_variant).begins_with(prefix):
			return true
	return false
