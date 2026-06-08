extends GutTest

const InteractionAudioFeedbackScript := preload("res://scripts/player/interaction_audio_feedback.gd")


func test_interaction_audio_catalog_covers_stop_11_2_cues() -> void:
	var feedback: Node = InteractionAudioFeedbackScript.new()
	add_child_autofree(feedback)

	var ids: Array = feedback.call("get_cue_ids")
	assert_true(feedback.call("has_required_cues"))
	assert_eq(ids.size(), 12)
	assert_true(ids.has("pickup"))
	assert_true(ids.has("place"))
	assert_true(ids.has("stock"))
	assert_true(ids.has("scan"))
	assert_true(ids.has("register"))
	assert_true(ids.has("cash_drawer"))
	assert_true(ids.has("computer_click"))
	assert_true(ids.has("button_hover"))
	assert_true(ids.has("button_click"))
	assert_true(ids.has("box_open"))
	assert_true(ids.has("shelf_bump"))
	assert_true(ids.has("error"))


func test_interaction_audio_uses_prompt_safe_mix_levels() -> void:
	var feedback: Node = InteractionAudioFeedbackScript.new()
	add_child_autofree(feedback)

	var catalog: Array = feedback.call("get_cue_catalog")
	for cue in catalog:
		assert_lte(float(cue.get("volume_db", 0.0)), -14.0, str(cue.get("id", "")))
		assert_false(str(cue.get("summary", "")).is_empty(), str(cue.get("id", "")))


func test_player_controller_contains_interaction_audio_feedback() -> void:
	var player: Node = load("res://scenes/player/player_controller.tscn").instantiate()
	add_child_autofree(player)
	var feedback: Node = player.get_node("InteractionAudioFeedback")

	assert_true(feedback.call("has_required_cues"))
	for cue in feedback.call("get_cue_catalog"):
		var audio_player := feedback.get_node(str(cue.get("player_path", ""))) as AudioStreamPlayer
		assert_not_null(audio_player, str(cue.get("id", "")))
		assert_not_null(audio_player.stream, str(cue.get("id", "")))
		assert_false(audio_player.autoplay, str(cue.get("id", "")))


func test_player_controller_records_interaction_audio_cues() -> void:
	var player: Node = load("res://scenes/player/player_controller.tscn").instantiate()
	add_child_autofree(player)
	var feedback: Node = player.get_node("InteractionAudioFeedback")

	assert_true(player.call("play_interaction_audio", "pickup"))
	assert_eq(feedback.get("last_cue_id"), "pickup")
	assert_true(player.call("play_interaction_audio", "computer_click"))
	assert_eq(feedback.get("last_cue_id"), "computer_click")
	assert_false(player.call("play_interaction_audio", "missing_cue"))


func test_interaction_audio_summary_names_action_groups() -> void:
	var feedback: Node = InteractionAudioFeedbackScript.new()
	add_child_autofree(feedback)

	var summary: String = feedback.call("get_interaction_audio_summary_text")
	assert_string_contains(summary, "Interaction audio baseline:")
	assert_string_contains(summary, "Pickup")
	assert_string_contains(summary, "Stock")
	assert_string_contains(summary, "Register")
	assert_string_contains(summary, "Cash drawer")
	assert_string_contains(summary, "Computer click")
	assert_string_contains(summary, "Error")
