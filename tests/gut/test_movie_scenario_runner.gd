extends GutTest

const MOVIE_RUNNER_SCRIPT: GDScript = preload(
	"res://tests/movie_scenarios/movie_scenario_runner.gd"
)


func test_movie_catalog_covers_nightly_review_surfaces() -> void:
	var runner: Node = MOVIE_RUNNER_SCRIPT.new()
	var ids: PackedStringArray = runner.call("available_scenario_ids")

	assert_true(ids.has("store_opening"))
	assert_true(ids.has("checkout_pressure"))
	assert_true(ids.has("upgrade_purchase_loop"))
	assert_true(ids.has("toast_readability_pass"))
	assert_true(ids.has("objective_rail_progression"))
	assert_true(ids.has("gallery_walkthrough_smoke"))
	runner.free()


func test_movie_args_parse_scenario_and_duration_frames() -> void:
	var runner: Node = MOVIE_RUNNER_SCRIPT.new()
	var parsed: Dictionary = runner.call(
		"parse_cli_args",
		PackedStringArray([
			"--movie-scenario",
			"checkout_pressure",
			"--duration-frames=123",
		])
	)

	assert_true(bool(parsed.get("ok", false)), str(parsed.get("message", "")))
	assert_eq(str(parsed.get("scenario_id", "")), "checkout_pressure")
	assert_eq(int(parsed.get("duration_frames", 0)), 123)
	runner.free()


func test_movie_args_default_duration_and_reject_unknown_scenario() -> void:
	var runner: Node = MOVIE_RUNNER_SCRIPT.new()
	var defaulted: Dictionary = runner.call(
		"parse_cli_args",
		PackedStringArray(["--scenario=toast_readability_pass"])
	)
	var rejected: Dictionary = runner.call(
		"parse_cli_args",
		PackedStringArray(["--scenario=missing_video"])
	)

	assert_true(bool(defaulted.get("ok", false)), str(defaulted.get("message", "")))
	assert_eq(int(defaulted.get("duration_frames", 0)), 600)
	assert_false(bool(rejected.get("ok", true)))
	assert_eq(str(rejected.get("code", "")), "unknown_scenario_id")
	assert_true((rejected.get("available_scenario_ids", []) as Array).has("store_opening"))
	runner.free()


func test_render_script_invokes_godot_movie_maker_and_reports_failures() -> void:
	var source: String = _read_text("res://scripts/render_nightly_videos.sh")

	assert_string_contains(source, "scripts/godot_exec.sh")
	assert_string_contains(source, "--write-movie")
	assert_string_contains(source, "--fixed-fps")
	assert_string_contains(source, "--movie-scenario")
	assert_string_contains(source, "--duration-frames")
	assert_string_contains(source, "videos/scenario/nightly")
	assert_string_contains(source, "logs/scenario/nightly-videos")
	assert_string_contains(source, "missing movie file")
	assert_string_contains(source, "empty movie file")
	assert_string_contains(source, "unknown scenario id")
	assert_string_contains(source, "runner timeout")
	assert_string_contains(source, "required for nightly video rendering in CI")


func test_nightly_video_workflow_is_advisory_and_retains_artifacts() -> void:
	var source: String = _read_text("res://.github/workflows/nightly-videos.yml")

	assert_string_contains(source, "schedule:")
	assert_string_contains(source, "workflow_dispatch:")
	assert_string_contains(source, "xvfb-run -a bash scripts/render_nightly_videos.sh")
	assert_string_contains(source, "artifacts/videos/scenario/nightly/")
	assert_string_contains(source, "artifacts/logs/scenario/nightly-videos/")
	assert_string_contains(source, "retention-days: 14")


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
