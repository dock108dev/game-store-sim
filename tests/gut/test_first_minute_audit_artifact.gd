extends GutTest

const FirstMinuteAuditArtifactScript: GDScript = preload(
	"res://game/scripts/store_session/first_minute_audit_artifact.gd"
)

const TEST_RUN_ID: String = "schema_test_run"


func test_first_minute_artifact_covers_required_beats_without_close_day() -> void:
	var artifact: Dictionary = FirstMinuteAuditArtifactScript.build_artifact(TEST_RUN_ID)
	assert_eq(str(artifact.get("artifact_type", "")), "first_minute_screenshot_audit")
	assert_eq(int(artifact.get("schema_version", 0)), 1)
	assert_true(
		str(artifact.get("artifact_dir", "")).ends_with(
			"artifacts/first_minute_audit/retro_games_day_one/schema_test_run"
		)
	)
	var policy: Dictionary = artifact.get("capture_policy", {}) as Dictionary
	assert_eq(int(policy.get("timebox_seconds", 0)), 60)
	assert_false(
		bool(policy.get("requires_close_day_summary", true)),
		"First-minute artifact must not require close-day summary"
	)

	var beats: Array = artifact.get("beats", []) as Array
	var expected: Array[String] = [
		"spawn_start",
		"manager_prompt",
		"register_prompt",
		"backroom_entry_prompt",
		"stockroom_work_area",
		"carrying_shelf_transition",
		"before_customer_state",
		"customer_decision_card",
		"result_acknowledgement",
		"post_customer_recovery",
		"sixty_second_state",
	]
	assert_eq(_beat_ids(beats), expected)
	assert_eq(
		_interaction_target_for(beats, "spawn_start"),
		"StoreSessionManager/Interactable"
	)
	assert_eq(
		_interaction_target_for(beats, "register_prompt"),
		"StoreSessionDayEndTrigger/Interactable"
	)
	assert_eq(
		_interaction_target_for(beats, "before_customer_state"),
		"StoreSessionDayOneCustomer/Interactable"
	)
	assert_eq(_beat_by_id(beats, "sixty_second_state").get("target_timestamp_sec", 0), 60)
	assert_false(
		_beat_ids(beats).has("close_day_summary"),
		"Close-day summary belongs to the longer route artifact, not this audit"
	)
	for beat_variant: Variant in beats:
		_assert_audit_beat_schema(beat_variant as Dictionary)


func test_punch_list_projects_actionable_records_from_top_level_fields() -> void:
	var artifact: Dictionary = (
		FirstMinuteAuditArtifactScript
		. build_artifact(
			TEST_RUN_ID,
			{},
			{
				"manager_prompt":
				{
					"status": "FAIL",
					"summary": "Prompt hidden behind counter",
					"notes": "Counter approach screenshot does not show the prompt",
				},
				"stockroom_work_area":
				{
					"status": "MISSING",
					"summary": "Screenshot missing",
				},
				"customer_decision_card":
				{
					"status": "PASS",
				},
			}
		)
	)
	var punch_list: Array = artifact.get("punch_list", []) as Array
	assert_eq(punch_list.size(), 2)
	var manager: Dictionary = punch_list[0] as Dictionary
	assert_eq(str(manager.get("beat_id", "")), "manager_prompt")
	assert_eq(str(manager.get("status", "")), "FAIL")
	assert_eq(str(manager.get("owner", "")), "store_session")
	assert_eq(str(manager.get("category", "")), "training")
	assert_eq(str(manager.get("severity", "")), "high")
	assert_true(str(manager.get("acceptance", "")).contains("Manager prompt screenshot"))
	assert_true(str(manager.get("screenshot_path", "")).ends_with("01_manager_prompt.png"))
	assert_eq(str(manager.get("summary", "")), "Prompt hidden behind counter")
	assert_false(_punch_ids(punch_list).has("customer_decision_card"))


func test_writer_outputs_json_and_markdown_with_punch_list_first() -> void:
	var result: Dictionary = (
		FirstMinuteAuditArtifactScript
		. write_artifact(
			TEST_RUN_ID,
			{},
			{
				"backroom_entry_prompt":
				{
					"status": "KNOWN_FAIL",
					"summary": "Awaiting stockroom polish review",
					"notes": "Known visual review gap",
				},
			}
		)
	)
	assert_true(
		bool(result.get("ok", false)),
		"First-minute artifact writer must succeed: %s" % str(result.get("error", ""))
	)
	if not bool(result.get("ok", false)):
		return
	var json_path: String = str(result.get("json_path", ""))
	var markdown_path: String = str(result.get("markdown_path", ""))
	assert_true(FileAccess.file_exists(json_path))
	assert_true(FileAccess.file_exists(markdown_path))

	var payload: Dictionary = _read_json_file(json_path)
	var punch_list: Array = payload.get("punch_list", []) as Array
	assert_eq(punch_list.size(), 1)
	assert_eq(str((punch_list[0] as Dictionary).get("beat_id", "")), "backroom_entry_prompt")

	var markdown: String = _read_text_file(markdown_path)
	assert_true(markdown.contains("## Punch List"))
	assert_true(markdown.contains("## Audit Beats"))
	assert_lt(markdown.find("## Punch List"), markdown.find("## Audit Beats"))
	assert_true(markdown.contains("Back-room entry or pickup prompt"))
	assert_true(markdown.contains("store_session"))
	assert_true(markdown.contains("training"))
	assert_true(markdown.contains("Back-room route exposes the pickup prompt"))


func _assert_audit_beat_schema(beat: Dictionary) -> void:
	for field: String in [
		"beat_id",
		"label",
		"status",
		"screenshot_path",
		"target_timestamp_sec",
		"route_state",
		"hud_state",
		"prompt_state",
		"interaction_target",
		"visual_review_verdicts",
		"category",
		"severity",
		"owner",
		"acceptance",
	]:
		assert_true(beat.has(field), "Audit beat must include %s" % field)
	assert_false(str(beat.get("screenshot_path", "")).is_empty())
	assert_true(int(beat.get("target_timestamp_sec", -1)) >= 0)
	assert_false((beat.get("route_state", {}) as Dictionary).is_empty())
	assert_true((beat.get("prompt_state", {}) as Dictionary).has("active_prompt"))
	assert_true((beat.get("interaction_target", {}) as Dictionary).has("target"))
	var verdicts: Dictionary = beat.get("visual_review_verdicts", {}) as Dictionary
	assert_true(verdicts.has("review_status"))
	assert_true(verdicts.has("visual_strengths"))
	assert_false(str(beat.get("category", "")).is_empty())
	assert_false(str(beat.get("severity", "")).is_empty())
	assert_false(str(beat.get("owner", "")).is_empty())
	assert_false(str(beat.get("acceptance", "")).is_empty())


func _beat_ids(beats: Array) -> Array[String]:
	var out: Array[String] = []
	for beat_variant: Variant in beats:
		var beat: Dictionary = beat_variant as Dictionary
		out.append(str(beat.get("beat_id", "")))
	return out


func _punch_ids(punch_list: Array) -> Array[String]:
	var out: Array[String] = []
	for item_variant: Variant in punch_list:
		var item: Dictionary = item_variant as Dictionary
		out.append(str(item.get("beat_id", "")))
	return out


func _beat_by_id(beats: Array, beat_id: String) -> Dictionary:
	for beat_variant: Variant in beats:
		var beat: Dictionary = beat_variant as Dictionary
		if str(beat.get("beat_id", "")) == beat_id:
			return beat
	return {}


func _interaction_target_for(beats: Array, beat_id: String) -> String:
	var beat: Dictionary = _beat_by_id(beats, beat_id)
	var interaction_target: Dictionary = beat.get("interaction_target", {}) as Dictionary
	return str(interaction_target.get("target", ""))


func _read_json_file(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "JSON file must open: %s" % path)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert_true(parsed is Dictionary, "JSON payload must be an object")
	if not (parsed is Dictionary):
		return {}
	return parsed as Dictionary


func _read_text_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Text file must open: %s" % path)
	if file == null:
		return ""
	return file.get_as_text()
