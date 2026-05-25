extends GutTest

const _ScenarioScreenshotCapture: GDScript = preload(
	"res://game/scripts/automation/scenario_screenshot_capture.gd"
)
const _TEST_ROOT: String = "user://scenario_screenshot_capture_test"

var _saved_artifact_env: String = ""
var _saved_workspace_env: String = ""
var _saved_sha: String = ""


func before_each() -> void:
	_saved_artifact_env = OS.get_environment("MALLCORE_ARTIFACT_DIR")
	_saved_workspace_env = OS.get_environment("GITHUB_WORKSPACE")
	_saved_sha = OS.get_environment("GITHUB_SHA")
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _TEST_ROOT)
	OS.set_environment("GITHUB_WORKSPACE", "")
	OS.set_environment("GITHUB_SHA", "unit-test-sha")


func after_each() -> void:
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _saved_artifact_env)
	OS.set_environment("GITHUB_WORKSPACE", _saved_workspace_env)
	OS.set_environment("GITHUB_SHA", _saved_sha)


func test_scenario_dir_and_checkpoint_names_are_stable() -> void:
	assert_eq(
		_ScenarioScreenshotCapture.scenario_dir("Fresh Install Smoke"),
		_TEST_ROOT + "/screenshots/scenario/fresh_install_smoke"
	)
	assert_eq(
		_ScenarioScreenshotCapture.checkpoint_filename("Store UI Open", 5), "005_store_ui_open.png"
	)
	assert_eq(_ScenarioScreenshotCapture.checkpoint_filename("001 Main Menu"), "001_main_menu.png")
	for checkpoint: String in [
		"001_main_menu",
		"002_new_game_loaded",
		"003_tutorial_step_1",
		"004_first_movement",
		"005_store_ui_open",
		"006_stock_shelf",
		"007_customer_queue",
		"008_sale_complete",
		"009_save_reload",
	]:
		assert_true(_ScenarioScreenshotCapture.evidence_checkpoint_names().has(checkpoint))


func test_named_checkpoint_writes_png_and_metadata() -> void:
	var result: Dictionary = (
		_ScenarioScreenshotCapture
		. capture_viewport(
			get_viewport(),
			{
				"scenario_id": "fresh_install_smoke",
				"seed": "seed_001",
				"scene": "MainMenu",
				"checkpoint": "Store UI Open",
				"index": 5,
				"allow_placeholder": true,
				"assertion_counts": {"total": 2, "passed": 2, "failed": 0},
			}
		)
	)

	assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
	assert_eq(str(result.get("filename", "")), "005_store_ui_open.png")
	assert_true(FileAccess.file_exists(str(result.get("path", ""))))
	assert_true(FileAccess.file_exists(str(result.get("metadata_path", ""))))

	var metadata: Dictionary = _read_json_file(str(result.get("metadata_path", "")))
	assert_eq(str(metadata.get("scenario_id", "")), "fresh_install_smoke")
	assert_eq(str(metadata.get("seed", "")), "seed_001")
	assert_eq(str(metadata.get("scene", "")), "MainMenu")
	assert_eq(str(metadata.get("checkpoint", "")), "Store UI Open")
	assert_eq(str(metadata.get("checkpoint_slug", "")), "005_store_ui_open")
	assert_eq(str(metadata.get("commit", "")), "unit-test-sha")
	assert_true((metadata.get("resolution", {}) as Dictionary).has("width"))
	assert_true((metadata.get("resolution", {}) as Dictionary).has("height"))
	assert_eq(int((metadata.get("assertion_counts", {}) as Dictionary).get("total", -1)), 2)
	assert_eq(str(metadata.get("display_server", "")), DisplayServer.get_name())
	assert_eq(bool(metadata.get("placeholder", false)), DisplayServer.get_name() == "headless")
	assert_eq(
		bool(metadata.get("non_acceptance_evidence", false)),
		bool(metadata.get("placeholder", false))
	)


func test_failed_capture_records_no_metadata() -> void:
	var result: Dictionary = (
		_ScenarioScreenshotCapture
		. capture_viewport(
			null,
			{
				"scenario_id": "failed_capture",
				"checkpoint": "Failed Capture",
				"index": 1,
				"allow_placeholder": false,
			}
		)
	)

	assert_false(bool(result.get("ok", true)))
	assert_eq(str(result.get("filename", "")), "001_failed_capture.png")
	assert_false(result.has("metadata_path"))


func test_headless_placeholder_requires_explicit_flag() -> void:
	if DisplayServer.get_name() != "headless":
		pending("Placeholder-only assertion applies to headless runs")
		return
	var denied: Dictionary = _ScenarioScreenshotCapture.capture_viewport(
		get_viewport(), {"scenario_id": "placeholder_gate", "checkpoint": "Denied", "index": 1}
	)
	assert_false(bool(denied.get("ok", true)))

	var allowed: Dictionary = (
		_ScenarioScreenshotCapture
		. capture_viewport(
			get_viewport(),
			{
				"scenario_id": "placeholder_gate",
				"checkpoint": "Allowed",
				"index": 2,
				"allow_placeholder": true,
			}
		)
	)
	assert_true(bool(allowed.get("ok", false)), str(allowed.get("error", "")))
	assert_true(bool(allowed.get("placeholder", false)))
	var metadata: Dictionary = _read_json_file(str(allowed.get("metadata_path", "")))
	assert_eq(str(metadata.get("capture_mode", "")), "placeholder")
	assert_true(bool(metadata.get("non_acceptance_evidence", false)))


func _read_json_file(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "JSON file must open: %s" % path)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(parsed is Dictionary, "JSON payload must be an object")
	if not (parsed is Dictionary):
		return {}
	return parsed as Dictionary
