extends GutTest

const PresentationMicrofeedbackScript := preload("res://scripts/player/presentation_microfeedback.gd")


func test_presentation_microfeedback_catalog_covers_stop_11_4_effects() -> void:
	var feedback: Node = PresentationMicrofeedbackScript.new()
	add_child_autofree(feedback)

	var ids: Array = feedback.call("get_effect_ids")
	assert_true(feedback.call("has_required_effects"))
	assert_eq(ids.size(), 8)
	assert_true(ids.has("target_highlight"))
	assert_true(ids.has("item_settle"))
	assert_true(ids.has("sale_confirmation"))
	assert_true(ids.has("cash_tick"))
	assert_true(ids.has("reputation_tick"))
	assert_true(ids.has("day_transition"))
	assert_true(ids.has("delivery_arrival"))
	assert_true(ids.has("invalid_action"))


func test_player_controller_contains_microfeedback_particles() -> void:
	var player: Node = load("res://scenes/player/player_controller.tscn").instantiate()
	add_child_autofree(player)
	var feedback: Node = player.get_node("PresentationMicrofeedback")

	assert_true(feedback.call("has_required_effects"))
	for effect in feedback.call("get_effect_catalog"):
		var particles := feedback.get_node(str(effect.get("node_path", ""))) as CPUParticles3D
		assert_not_null(particles, str(effect.get("id", "")))
		assert_true(particles.one_shot, str(effect.get("id", "")))
		assert_false(particles.emitting, str(effect.get("id", "")))


func test_microfeedback_records_effects_and_maps_results() -> void:
	var feedback: Node = PresentationMicrofeedbackScript.new()
	add_child_autofree(feedback)

	assert_true(feedback.call("trigger_effect", "item_settle"))
	assert_eq(feedback.get("last_effect_id"), "item_settle")
	assert_false(feedback.call("trigger_effect", "missing_effect"))
	assert_eq(feedback.call("effect_for_result", "Sold Star Trader"), "sale_confirmation")
	assert_eq(feedback.call("effect_for_result", "Cash +$5.00"), "cash_tick")
	assert_eq(feedback.call("effect_for_result", "Reputation -2"), "reputation_tick")
	assert_eq(feedback.call("effect_for_result", "Started day 2"), "day_transition")
	assert_eq(feedback.call("effect_for_result", "Delivery arrived"), "delivery_arrival")
	assert_eq(feedback.call("effect_for_result", "No checkout waiting"), "invalid_action")


func test_player_controller_records_microfeedback_for_results() -> void:
	var player: Node = load("res://scenes/player/player_controller.tscn").instantiate()
	add_child_autofree(player)
	var feedback: Node = player.get_node("PresentationMicrofeedback")

	assert_true(player.call("play_presentation_feedback_for_result", "Sold Star Trader"))
	assert_eq(feedback.get("last_effect_id"), "sale_confirmation")
	assert_true(player.call("play_presentation_feedback_for_result", "No checkout waiting"))
	assert_eq(feedback.get("last_effect_id"), "invalid_action")


func test_microfeedback_summary_names_effect_groups() -> void:
	var feedback: Node = PresentationMicrofeedbackScript.new()
	add_child_autofree(feedback)

	var summary: String = feedback.call("get_microfeedback_summary_text")
	assert_string_contains(summary, "Presentation microfeedback baseline:")
	assert_string_contains(summary, "Target highlight")
	assert_string_contains(summary, "Item settle")
	assert_string_contains(summary, "Sale confirmation")
	assert_string_contains(summary, "Cash tick")
	assert_string_contains(summary, "Reputation tick")
	assert_string_contains(summary, "Day transition")
	assert_string_contains(summary, "Delivery arrival")
	assert_string_contains(summary, "Invalid action")
