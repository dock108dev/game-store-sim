extends GutTest

const _AutomationArtifacts: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const _TEST_ROOT: String = "user://automation_artifacts_test"
const _WORKSPACE_ROOT: String = "/tmp/mallcore_artifact_workspace"

var _saved_artifact_env: String = ""
var _saved_workspace_env: String = ""


func before_each() -> void:
	_saved_artifact_env = OS.get_environment("MALLCORE_ARTIFACT_DIR")
	_saved_workspace_env = OS.get_environment("GITHUB_WORKSPACE")
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _TEST_ROOT)
	OS.set_environment("GITHUB_WORKSPACE", "")


func after_each() -> void:
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _saved_artifact_env)
	OS.set_environment("GITHUB_WORKSPACE", _saved_workspace_env)


func test_artifact_root_prefers_explicit_env_then_ci_workspace() -> void:
	assert_eq(_AutomationArtifacts.artifact_root(), _TEST_ROOT)

	OS.set_environment("MALLCORE_ARTIFACT_DIR", "")
	OS.set_environment("GITHUB_WORKSPACE", _WORKSPACE_ROOT)

	assert_eq(
		_AutomationArtifacts.artifact_root(),
		"%s/artifacts" % _WORKSPACE_ROOT
	)


func test_artifact_root_falls_back_to_repo_artifacts_before_user_path() -> void:
	OS.set_environment("MALLCORE_ARTIFACT_DIR", "")
	OS.set_environment("GITHUB_WORKSPACE", "")

	var root: String = _AutomationArtifacts.artifact_root()
	assert_true(root.ends_with("/artifacts"))
	assert_false(root.begins_with("user://"))


func test_join_path_and_stable_subpaths_cover_automation_outputs() -> void:
	assert_eq(
		_AutomationArtifacts.join_path([_TEST_ROOT + "/", "/logs/", "gut"]),
		_TEST_ROOT + "/logs/gut"
	)

	var subpaths: Dictionary = _AutomationArtifacts.artifact_subpaths()
	assert_eq(str(subpaths.get("scenario_screenshots", "")), "screenshots/scenario")
	assert_eq(str(subpaths.get("visual_sweep_screenshots", "")), "screenshots/visual_sweep")
	assert_eq(str(subpaths.get("gallery_screenshots", "")), "screenshots/gallery")
	assert_eq(str(subpaths.get("scenario_reports", "")), "reports/scenario")
	assert_eq(str(subpaths.get("junit", "")), "junit")
	assert_eq(str(subpaths.get("scenario_videos", "")), "videos/scenario")
	assert_eq(str(subpaths.get("artifact_manifest", "")), "manifests/artifact_manifest.json")
	assert_eq(
		_AutomationArtifacts.scenario_video_path("Nightly Smoke"),
		_TEST_ROOT + "/videos/scenario/nightly_smoke.avi"
	)


func test_directory_creation_and_slug_safety() -> void:
	var dir_result: Dictionary = _AutomationArtifacts.ensure_artifact_dir("logs/gut")
	assert_true(bool(dir_result.get("ok", false)), str(dir_result.get("error", "")))
	assert_true(DirAccess.dir_exists_absolute(str(dir_result.get("path", ""))))
	assert_eq(str(dir_result.get("relative_path", "")), "logs/gut")

	assert_eq(
		_AutomationArtifacts.sanitize_slug(" Retro Games / Day One! "),
		"retro_games_day_one"
	)
	assert_eq(_AutomationArtifacts.sanitize_slug(""), "default")


func test_write_json_creates_parent_directory() -> void:
	var path: String = _AutomationArtifacts.artifact_path("reports/scenario/write_json/payload.json")
	var result: Dictionary = _AutomationArtifacts.write_json(path, {"ok": true})

	assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
	assert_true(FileAccess.file_exists(path))
	assert_eq(bool(_read_json_file(path).get("ok", false)), true)


func test_write_recorded_json_creates_payload_and_manifest_entry() -> void:
	var path: String = _AutomationArtifacts.artifact_path(
		"reports/scenario/write_recorded_json/payload.json"
	)
	var result: Dictionary = _AutomationArtifacts.write_recorded_json(
		path,
		{"ok": true},
		"scenario_report",
		"write_recorded_json",
		"scenario",
		"json"
	)

	assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
	assert_true(FileAccess.file_exists(path))
	assert_eq(bool(_read_json_file(path).get("ok", false)), true)

	var manifest: Dictionary = _read_json_file(_AutomationArtifacts.manifest_path())
	var entry: Dictionary = _find_entry(
		manifest.get("artifacts", []) as Array,
		"reports/scenario/write_recorded_json/payload.json"
	)
	assert_eq(str(entry.get("type", "")), "scenario_report")
	assert_eq(str(entry.get("scenario", "")), "write_recorded_json")
	assert_eq(str(entry.get("suite", "")), "scenario")


func test_manifest_records_generated_artifact_entry() -> void:
	var report_dir: String = _AutomationArtifacts.report_dir("scenario", "Fresh Install Smoke")
	var dir_result: Dictionary = _AutomationArtifacts.ensure_artifact_dir(report_dir)
	assert_true(bool(dir_result.get("ok", false)), str(dir_result.get("error", "")))
	var report_path: String = _AutomationArtifacts.join_path([report_dir, "report.json"])
	var file: FileAccess = FileAccess.open(report_path, FileAccess.WRITE)
	assert_not_null(file)
	if file == null:
		return
	file.store_string("{\"ok\":true}")
	file.close()

	var record_result: Dictionary = _AutomationArtifacts.record_artifact(
		"report",
		report_path,
		"fresh_install_smoke",
		"scenario",
		"json"
	)
	assert_true(bool(record_result.get("ok", false)), str(record_result.get("error", "")))

	var manifest: Dictionary = _read_json_file(str(record_result.get("path", "")))
	var entry: Dictionary = _find_entry(
		manifest.get("artifacts", []) as Array,
		"reports/scenario/fresh_install_smoke/report.json"
	)
	assert_eq(str(entry.get("type", "")), "report")
	assert_eq(str(entry.get("scenario", "")), "fresh_install_smoke")
	assert_eq(str(entry.get("suite", "")), "scenario")
	assert_gt(int(entry.get("size", 0)), 0)
	assert_eq(str(entry.get("capture_mode", "")), "json")
	assert_eq(str(entry.get("generation_status", "")), "generated")


func test_manifest_records_missing_artifact_entry() -> void:
	var record_result: Dictionary = _AutomationArtifacts.record_missing_artifact(
		"screenshot",
		"screenshots/scenario/missing_view.png",
		"missing_view",
		"scenario",
		"viewport"
	)
	assert_true(bool(record_result.get("ok", false)), str(record_result.get("error", "")))

	var manifest: Dictionary = _read_json_file(str(record_result.get("path", "")))
	var entry: Dictionary = _find_entry(
		manifest.get("artifacts", []) as Array,
		"screenshots/scenario/missing_view.png"
	)
	assert_eq(str(entry.get("type", "")), "screenshot")
	assert_eq(int(entry.get("size", -1)), 0)
	assert_eq(str(entry.get("capture_mode", "")), "viewport")
	assert_eq(str(entry.get("generation_status", "")), "missing")


func _find_entry(entries: Array, relative_path: String) -> Dictionary:
	for entry_variant: Variant in entries:
		var entry: Dictionary = entry_variant as Dictionary
		if str(entry.get("relative_path", "")) == relative_path:
			return entry
	return {}


func _read_json_file(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(parsed is Dictionary)
	return parsed as Dictionary
