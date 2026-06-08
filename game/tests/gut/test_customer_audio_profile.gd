extends GutTest

const CustomerAudioProfileScript := preload("res://scripts/customers/customer_audio_profile.gd")
const CUSTOMER_SCENES := [
	"res://scenes/customers/simple_buyer_customer.tscn",
	"res://scenes/customers/simple_trade_in_customer.tscn",
	"res://scenes/customers/simple_preorder_customer.tscn",
	"res://scenes/customers/simple_service_customer.tscn",
	"res://scenes/customers/suspicious_customer.tscn",
]


func test_customer_audio_profile_covers_stop_11_3_placeholders() -> void:
	var profile: Node = CustomerAudioProfileScript.new()
	add_child_autofree(profile)

	var ids: Array = profile.call("get_cue_ids")
	assert_true(profile.call("has_required_cues"))
	assert_eq(ids.size(), 6)
	assert_true(ids.has("footstep"))
	assert_true(ids.has("mumble"))
	assert_true(ids.has("greeting"))
	assert_true(ids.has("approval"))
	assert_true(ids.has("annoyance"))
	assert_true(ids.has("leaving"))


func test_customer_audio_profile_uses_placeholder_safe_mix_levels() -> void:
	var profile: Node = CustomerAudioProfileScript.new()
	add_child_autofree(profile)

	for cue in profile.call("get_cue_catalog"):
		assert_lte(float(cue.get("volume_db", 0.0)), -19.0, str(cue.get("id", "")))
		assert_false(str(cue.get("summary", "")).is_empty(), str(cue.get("id", "")))


func test_customer_scenes_contain_audio_profile_players() -> void:
	for scene_path in CUSTOMER_SCENES:
		var customer: Node = load(scene_path).instantiate()
		add_child_autofree(customer)
		var profile: Node = customer.get_node("CustomerAudioProfile")
		assert_true(profile.call("has_required_cues"), scene_path)
		assert_false(str(profile.get("role_id")).is_empty(), scene_path)
		for cue in profile.call("get_cue_catalog"):
			var audio_player := profile.get_node(str(cue.get("player_path", ""))) as AudioStreamPlayer3D
			assert_not_null(audio_player, "%s %s" % [scene_path, str(cue.get("id", ""))])
			assert_not_null(audio_player.stream, "%s %s" % [scene_path, str(cue.get("id", ""))])
			assert_false(audio_player.autoplay, "%s %s" % [scene_path, str(cue.get("id", ""))])


func test_customer_audio_profile_records_cues_and_maps_feedback_tones() -> void:
	var profile: Node = CustomerAudioProfileScript.new()
	add_child_autofree(profile)

	assert_true(profile.call("play_cue", "greeting"))
	assert_eq(profile.get("last_cue_id"), "greeting")
	assert_false(profile.call("play_cue", "voice_line"))
	assert_eq(profile.call("cue_for_feedback_tone", "positive"), "approval")
	assert_eq(profile.call("cue_for_feedback_tone", "warning"), "annoyance")
	assert_eq(profile.call("cue_for_feedback_tone", "suspicious"), "annoyance")
	assert_eq(profile.call("cue_for_feedback_tone", "info"), "mumble")


func test_customer_audio_profile_summary_names_placeholder_scope() -> void:
	var profile: Node = CustomerAudioProfileScript.new()
	add_child_autofree(profile)

	var summary: String = profile.call("get_customer_audio_summary_text")
	assert_string_contains(summary, "Customer audio placeholders")
	assert_string_contains(summary, "Footstep")
	assert_string_contains(summary, "Mumble")
	assert_string_contains(summary, "Greeting")
	assert_string_contains(summary, "Approval")
	assert_string_contains(summary, "Annoyance")
	assert_string_contains(summary, "Leaving")
