extends GutTest

const WorkSurfaceValidationContractScript: GDScript = preload(
	"res://game/scripts/store_session/work_surface_validation_contract.gd"
)
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)

const REQUIRED_SURFACES: Array[String] = [
	"register",
	"stock_closet",
	"shelf_table",
	"hud",
	"route_state",
]
const REQUIRED_CHANNELS: Array[String] = [
	"authored_full_scene_checks",
	"store_session_runtime_checks",
	"reference_visible_visual_review",
	"manual_route_captures",
]


func test_closeout_contract_requires_static_checks_and_surface_tests() -> void:
	var contract: Dictionary = WorkSurfaceValidationContractScript.closure_manifest()
	assert_eq(
		contract.get("required_static_commands", []),
		["gdlint game/", "git diff --check"]
	)
	assert_eq(
		str(contract.get("full_gut_command", "")),
		"godot --headless --script res://addons/gut/gut_cmdln.gd"
	)

	var focused_tests: Dictionary = contract.get("focused_tests_by_surface", {}) as Dictionary
	for surface: String in REQUIRED_SURFACES:
		assert_true(focused_tests.has(surface), "Missing focused test surface %s" % surface)
		var tests: Array = focused_tests.get(surface, []) as Array
		assert_gt(tests.size(), 0, "%s must require focused GUT tests" % surface)
		for test_path_variant: Variant in tests:
			var test_path: String = str(test_path_variant)
			assert_true(test_path.begins_with("res://tests/gut/"))
			assert_true(test_path.ends_with(".gd"))
			assert_true(FileAccess.file_exists(test_path), "Focused test must exist: %s" % test_path)


func test_contract_requires_visual_sweep_and_manual_route_capture_by_change_type() -> void:
	for change_type: String in [
		"geometry",
		"camera",
		"readability",
		"visual_scope",
		"prop",
	]:
		assert_true(
			WorkSurfaceValidationContractScript.requires_visual_sweep(change_type),
			"%s changes must require fresh first-ten-seconds visual sweep evidence"
			% change_type
		)

	for change_type: String in [
		"prompt_ownership",
		"hud_copy",
		"route_stage",
	]:
		assert_true(
			WorkSurfaceValidationContractScript.requires_manual_route_capture(change_type),
			"%s changes must require focused tests plus manual route capture review"
			% change_type
		)


func test_contract_output_channels_and_blockers_are_explicit() -> void:
	var channels: Array[Dictionary] = WorkSurfaceValidationContractScript.output_channels()
	var ids: Array[String] = []
	for channel: Dictionary in channels:
		ids.append(str(channel.get("id", "")))
		assert_false(str(channel.get("label", "")).is_empty())
		assert_false(str(channel.get("source", "")).is_empty())
		assert_false(str(channel.get("acceptance_role", "")).is_empty())

	for required: String in REQUIRED_CHANNELS:
		assert_true(ids.has(required), "Missing validation output channel %s" % required)

	var blockers: Array[String] = WorkSurfaceValidationContractScript.blocking_failures()
	for required_blocker: String in [
		"prompt ownership failure",
		"duplicate HUD copy",
		"missing work-surface anchor",
		"hidden prop-density guardrail failure",
		"non-acceptance screenshot evidence",
	]:
		assert_true(
			blockers.has(required_blocker),
			"Missing close-out blocker %s" % required_blocker
		)


func test_visual_review_manifest_includes_closeout_contract() -> void:
	var result: Dictionary = StoreVisualSweepScript.write_review_manifest(
		"user://work_surface_validation_contract/reports",
		StoreVisualSweepScript.rows()
	)
	assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
	if not bool(result.get("ok", false)):
		return

	var payload: Dictionary = _read_json(str(result.get("path", "")))
	assert_true(payload.has("work_surface_closeout_contract"))
	assert_true(payload.has("validation_output_channels"))
	var contract: Dictionary = payload.get("work_surface_closeout_contract", {}) as Dictionary
	assert_eq(
		contract.get("required_static_commands", []),
		["gdlint game/", "git diff --check"]
	)
	var channels: Array = payload.get("validation_output_channels", []) as Array
	assert_eq(channels.size(), REQUIRED_CHANNELS.size())


func test_validation_scripts_surface_closeout_requirements() -> void:
	var godot_runner: String = _read_text("res://scripts/run_godot_tests.sh")
	assert_string_contains(godot_runner, "gdlint game/")
	assert_string_contains(godot_runner, "git diff --check")
	assert_string_contains(godot_runner, "Focused GUT tests")

	var visual_runner: String = _read_text("res://scripts/run_store_visual_sweep.sh")
	for required: String in [
		"authored-full scene checks",
		"store-session runtime checks",
		"reference-visible visual review",
		"manual route captures",
		"first-ten-seconds captures",
	]:
		assert_string_contains(visual_runner, required)


func _read_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "JSON file must open: %s" % path)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(parsed is Dictionary, "JSON file must parse as an object")
	if not (parsed is Dictionary):
		return {}
	return parsed as Dictionary


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Text file must open: %s" % path)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
