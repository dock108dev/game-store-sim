extends GutTest

const _StoreSessionManualDayOneRouteCapture: GDScript = preload(
	"res://game/scripts/store_session/manual_day_one_route_capture.gd"
)
const _StoreProofContract: GDScript = preload(
	"res://game/scripts/store_session/store_code_to_screen_proof_contract.gd"
)
const _ROUTE_ASSERTION_FILE: String = "res://tests/gut/test_store_session_day_one_critical_path.gd"
const _TEST_ARTIFACT_DIR: String = "user://screenshots/manual_routes/schema_validation"
const _REQUIRED_BEAT_FIELDS: Array[String] = [
	"index",
	"beat_name",
	"capture_beat_name",
	"capture_helper_call",
	"filename",
	"snapshot_filename",
	"expected_objective",
	"expected_stage",
	"active_prompt",
	"hud_right_panel",
	"shelf_backroom_counts",
	"customer_state",
	"inventory_cash_deltas",
	"summary_values",
	"automated_route_assertions",
	"code_to_screen_proof",
]
const _MAJOR_ROUTE_BEATS: Array[String] = [
	"manager_prompt",
	"register_prompt",
	"backroom_pickup_prompt",
	"training_shelf_transition",
	"customer_decision_card",
	"close_day_prompt",
	"close_day_summary",
]


func test_route_manifest_schema_covers_required_review_beats() -> void:
	var manifest: Dictionary = _StoreSessionManualDayOneRouteCapture.build_manifest(
		_TEST_ARTIFACT_DIR,
		"schema_test_run"
	)
	assert_eq(str(manifest.get("artifact_type", "")), "manual_day1_loop_route")
	assert_eq(int(manifest.get("schema_version", 0)), 1)
	var contract: Dictionary = manifest.get("code_to_screen_contract", {}) as Dictionary
	assert_true(bool(contract.get("loop_readiness_artifact", false)))
	assert_eq(str(contract.get("entry_readiness_checkpoint", "")), "day1_playable_ready")
	assert_eq(contract.get("fields", []), _StoreProofContract.REQUIRED_FIELDS)
	assert_eq(
		str((manifest.get("capture_helper", {}) as Dictionary).get("argument_field", "")),
		"capture_beat_name",
		"Manifest must document the explicit beat-name argument passed to capture"
	)

	var beats: Array = manifest.get("beats", []) as Array
	assert_gt(beats.size(), 0, "Manual route manifest must contain capture beats")
	assert_eq(
		_StoreProofContract.validate_route_beats(beats),
		[],
		"Every route beat must include complete code-to-screen proof"
	)
	var seen: Array[String] = []
	for beat_variant: Variant in beats:
		var beat: Dictionary = beat_variant as Dictionary
		_assert_route_beat_schema(beat)
		seen.append(str(beat.get("beat_name", "")))

	for required: String in _StoreSessionManualDayOneRouteCapture.REQUIRED_REVIEW_BEATS:
		assert_true(
			seen.has(required),
			"Manual route manifest must include required review beat %s" % required
		)

	for required_major_beat: String in _MAJOR_ROUTE_BEATS:
		var major_beat: Dictionary = _beat_by_name(beats, required_major_beat)
		assert_false(major_beat.is_empty(), "Missing major route beat %s" % required_major_beat)
		_assert_code_to_screen_proof(major_beat)

	var summary: Dictionary = _beat_by_name(beats, "close_day_summary")
	assert_eq(int(summary.get("index", 0)), 11)
	var summary_values: Dictionary = summary.get("summary_values", {}) as Dictionary
	assert_eq(int(summary_values.get("sales", 0)), 15)
	assert_eq(int(summary_values.get("rent", 0)), -50)
	assert_eq(int(summary_values.get("profit", 0)), -35)
	assert_eq(int(summary_values.get("ending_cash", 0)), 515)
	assert_eq(int(summary_values.get("customers_helped", 0)), 1)


func test_route_manifest_writes_checklist_and_capture_metadata() -> void:
	var capture_results: Dictionary = {
		"manager_prompt": {
			"ok": true,
			"filename": "20260523_120000_manager_prompt.png",
			"path": "user://screenshots/20260523_120000_manager_prompt.png",
		},
	}
	var result: Dictionary = _StoreSessionManualDayOneRouteCapture.write_route_manifest(
		_TEST_ARTIFACT_DIR,
		"schema_test_run",
		capture_results
	)
	assert_true(
		bool(result.get("ok", false)),
		"Manual route manifest writer must succeed: %s" % str(result.get("error", ""))
	)
	if not bool(result.get("ok", false)):
		return
	assert_true(FileAccess.file_exists(str(result.get("path", ""))))
	assert_true(FileAccess.file_exists(str(result.get("manual_review_path", ""))))

	var payload: Dictionary = _read_json_file(str(result.get("path", "")))
	assert_eq(str(payload.get("route_id", "")), "retro_games_day_one_loop")
	assert_true(str(payload.get("capture_dir", "")).contains("/captures"))
	assert_true(str(payload.get("snapshot_dir", "")).contains("/snapshots"))
	var choice: Dictionary = payload.get("canonical_customer_choice", {}) as Dictionary
	assert_eq(str(choice.get("event_id", "")), "day01_wrong_console_parent")
	assert_eq(str(choice.get("choice_id", "")), "clean_exchange")

	var beats: Array = payload.get("beats", []) as Array
	var manager_beat: Dictionary = _beat_by_name(beats, "manager_prompt")
	assert_eq(
		str((manager_beat.get("capture_result", {}) as Dictionary).get("filename", "")),
		"20260523_120000_manager_prompt.png",
		"Manifest must retain explicit capture result metadata by beat name"
	)
	var review: Dictionary = payload.get("manual_review_template", {}) as Dictionary
	var verdicts: Array = review.get("verdicts", []) as Array
	assert_eq(verdicts.size(), beats.size(), "Manual review template must cover every beat")
	var review_text: String = _read_text_file(str(result.get("manual_review_path", "")))
	assert_true(review_text.contains("Screen Object:"), "Checklist must include proof fields")
	assert_true(review_text.contains("Test Capture:"), "Checklist must include capture proof")


func test_route_beats_link_to_existing_automated_assertions() -> void:
	var lines: PackedStringArray = _read_lines(_ROUTE_ASSERTION_FILE)
	assert_gt(lines.size(), 0, "Automated route assertion file must be readable")
	for beat: Dictionary in _StoreSessionManualDayOneRouteCapture.route_beats():
		var refs: Array = beat.get("automated_route_assertions", []) as Array
		assert_gt(
			refs.size(),
			0,
			"%s must link to at least one automated assertion" % str(beat.get("beat_name", ""))
		)
		for ref_variant: Variant in refs:
			var ref: String = str(ref_variant)
			assert_true(ref.begins_with("tests/gut/test_store_session_day_one_critical_path.gd:"))
			var line_number: int = int(ref.get_slice(":", 1))
			assert_true(line_number > 0 and line_number <= lines.size(), "Bad ref %s" % ref)
			if line_number > 0 and line_number <= lines.size():
				var line: String = lines[line_number - 1]
				assert_true(
					_is_assertion_or_route_step(line),
					"Manual route ref must point to an assertion or route action: %s" % ref
				)


func test_incomplete_code_to_screen_proof_is_flagged() -> void:
	var incomplete: Dictionary = {
		"screen_object": "",
		"input_affordance": "Prompt reaches a script.",
		"code_owner": "One controller.",
		"state_mutation": "State changed.",
		"screen_feedback": "",
		"next_beat": "",
		"test_capture": "",
	}
	var errors: Array[String] = _StoreProofContract.validate_proof_payload(incomplete, "state_only")
	assert_true(errors.has("state_only missing screen_object"))
	assert_true(errors.has("state_only missing screen_feedback"))
	assert_true(errors.has("state_only missing next_beat"))
	assert_true(errors.has("state_only missing test_capture"))


func _assert_route_beat_schema(beat: Dictionary) -> void:
	for field: String in _REQUIRED_BEAT_FIELDS:
		assert_true(beat.has(field), "Route beat must include %s" % field)
	var beat_name: String = str(beat.get("beat_name", ""))
	assert_false(beat_name.is_empty(), "Route beat name must be non-empty")
	assert_eq(str(beat.get("capture_beat_name", "")), beat_name)
	assert_eq(
		str(beat.get("capture_helper_call", "")),
		"capture_current_viewport(\"%s\")" % beat_name
	)
	assert_true(str(beat.get("filename", "")).begins_with("%02d_" % int(beat.get("index", 0))))
	assert_true(str(beat.get("filename", "")).ends_with(".png"))
	assert_true(str(beat.get("snapshot_filename", "")).ends_with(".json"))
	assert_false(str(beat.get("expected_stage", "")).is_empty())
	assert_false(str(beat.get("expected_objective", "")).is_empty())
	assert_false(str(beat.get("active_prompt", "")).is_empty())
	assert_false((beat.get("hud_right_panel", {}) as Dictionary).is_empty())
	assert_true((beat.get("shelf_backroom_counts", {}) as Dictionary).has("shelf"))
	assert_true((beat.get("shelf_backroom_counts", {}) as Dictionary).has("backroom"))
	assert_true((beat.get("customer_state", {}) as Dictionary).has("state"))
	assert_true((beat.get("inventory_cash_deltas", {}) as Dictionary).has("cash_delta"))
	_assert_code_to_screen_proof(beat)


func _assert_code_to_screen_proof(beat: Dictionary) -> void:
	var proof: Dictionary = beat.get("code_to_screen_proof", {}) as Dictionary
	for field: String in _StoreProofContract.REQUIRED_FIELDS:
		assert_true(proof.has(field), "Proof must include %s" % field)
		assert_false(str(proof.get(field, "")).strip_edges().is_empty())
	assert_true(str(proof.get("screen_feedback", "")).contains(str(beat.get("filename", ""))))
	assert_true(str(proof.get("test_capture", "")).contains(str(beat.get("capture_helper_call", ""))))


func _beat_by_name(beats: Array, beat_name: String) -> Dictionary:
	for beat_variant: Variant in beats:
		var beat: Dictionary = beat_variant as Dictionary
		if str(beat.get("beat_name", "")) == beat_name:
			return beat
	return {}


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


func _read_lines(path: String) -> PackedStringArray:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return PackedStringArray()
	return file.get_as_text().split("\n")


func _is_assertion_or_route_step(line: String) -> bool:
	return line.contains("assert_") or line.contains("_assert_") or line.contains("_interact_") \
		or line.contains("_press_") or line.contains("_acknowledge_") \
		or line.contains("_open_customer_decision")
