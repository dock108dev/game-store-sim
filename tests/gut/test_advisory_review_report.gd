extends GutTest

const AdvisoryReviewReportScript: GDScript = preload(
	"res://game/scripts/automation/advisory_review_report.gd"
)
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const ManualRouteScript: GDScript = preload(
	"res://game/scripts/store_session/manual_day_one_route_capture.gd"
)

const TEST_ROOT: String = "user://advisory_review_report_test"


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(TEST_ROOT)


func test_classifies_and_normalizes_supported_manifest_shapes() -> void:
	var no_captures: Array[Dictionary] = []
	var sweep_manifest: Dictionary = StoreVisualSweepScript.write_review_manifest(
		TEST_ROOT + "/reports/sweep",
		StoreVisualSweepScript.rows(),
		no_captures
	)
	assert_true(bool(sweep_manifest.get("ok", false)), str(sweep_manifest.get("error", "")))
	var sweep_payload: Dictionary = _read_json(str(sweep_manifest.get("path", "")))
	var sweep_normalized: Dictionary = AdvisoryReviewReportScript.normalize_manifest(
		str(sweep_manifest.get("path", "")),
		sweep_payload
	)
	assert_eq(str(sweep_normalized.get("manifest_kind", "")), "store_visual_sweep")
	var sweep_beats: Array = sweep_normalized.get("beats", []) as Array
	assert_eq(sweep_beats.size(), StoreVisualSweepScript.rows().size())
	if not sweep_beats.is_empty():
		var sweep_beat: Dictionary = sweep_beats[0] as Dictionary
		assert_false(str(sweep_beat.get("active_route_stage", "")).is_empty())
		assert_false(str(sweep_beat.get("local_action", "")).is_empty())
		assert_false(str(sweep_beat.get("next_destination", "")).is_empty())
		assert_false(str(sweep_beat.get("visual_scope_mode", "")).is_empty())
		assert_false(str(sweep_beat.get("primary_work_surface_target", "")).is_empty())

	var route_payload: Dictionary = ManualRouteScript.build_manifest(TEST_ROOT + "/manual", "route_run")
	var route_normalized: Dictionary = AdvisoryReviewReportScript.normalize_manifest(
		TEST_ROOT + "/manual/route_run/route_manifest.json",
		route_payload
	)
	assert_eq(str(route_normalized.get("manifest_kind", "")), "manual_day1_loop_route")
	assert_gt((route_normalized.get("beats", []) as Array).size(), 0)

	var gallery_payload: Dictionary = _gallery_manifest()
	var gallery_normalized: Dictionary = AdvisoryReviewReportScript.normalize_manifest(
		TEST_ROOT + "/gallery/review_manifest.json",
		gallery_payload
	)
	assert_eq(str(gallery_normalized.get("manifest_kind", "")), "visual_gallery")
	assert_eq((gallery_normalized.get("beats", []) as Array).size(), 1)

	var video_payload: Dictionary = _video_manifest(TEST_ROOT + "/videos/route.avi")
	var video_normalized: Dictionary = AdvisoryReviewReportScript.normalize_manifest(
		TEST_ROOT + "/video/video_manifest.json",
		video_payload
	)
	assert_eq(str(video_normalized.get("manifest_kind", "")), "video_review")
	assert_eq((video_normalized.get("beats", []) as Array).size(), 1)


func test_report_schema_is_advisory_and_beat_scoped() -> void:
	var image_path: String = TEST_ROOT + "/sweep/01_spawn_first_look.png"
	_write_png(image_path)
	var normalized: Dictionary = AdvisoryReviewReportScript.normalize_manifest(
		TEST_ROOT + "/sweep/review_manifest.json",
		_sweep_manifest_with_capture(image_path, true, false, "")
	)
	var report: Dictionary = AdvisoryReviewReportScript.build_report(normalized)

	assert_eq(int(report.get("schema_version", 0)), 1)
	assert_true(bool(report.get("advisory_only", false)))
	assert_eq(str(report.get("review_status", "")), "complete_no_findings")
	assert_eq(str(report.get("overall_advisory_verdict", "")), "no_advisory_findings_recorded")
	assert_eq(int(report.get("reviewed_count", 0)), 1)
	assert_true((report.get("design_categories", []) as Array).has("visual_hierarchy"))
	assert_eq((report.get("findings", []) as Array).size(), 0)


func test_capture_quality_findings_do_not_fabricate_visual_observations() -> void:
	var corrupt_path: String = TEST_ROOT + "/sweep/corrupt.png"
	_write_text(corrupt_path, "not an image")
	var placeholder_path: String = TEST_ROOT + "/sweep/placeholder.png"
	_write_png(placeholder_path)
	var missing_report: Dictionary = AdvisoryReviewReportScript.build_report(
		AdvisoryReviewReportScript.normalize_manifest(
			TEST_ROOT + "/sweep/missing_manifest.json",
			_sweep_manifest_with_capture(TEST_ROOT + "/sweep/missing.png", false, false, "Viewport image unavailable in headless display mode")
		)
	)
	var corrupt_report: Dictionary = AdvisoryReviewReportScript.build_report(
		AdvisoryReviewReportScript.normalize_manifest(
			TEST_ROOT + "/sweep/corrupt_manifest.json",
			_sweep_manifest_with_capture(corrupt_path, true, false, "")
		)
	)
	var placeholder_report: Dictionary = AdvisoryReviewReportScript.build_report(
		AdvisoryReviewReportScript.normalize_manifest(
			TEST_ROOT + "/sweep/placeholder_manifest.json",
			_sweep_manifest_with_capture(placeholder_path, true, true, "")
		)
	)

	_assert_has_non_visual_finding(missing_report, "capture_quality.missing_image")
	_assert_has_non_visual_finding(missing_report, "capture_quality.headless_capture_failure")
	_assert_has_non_visual_finding(corrupt_report, "capture_quality.unreadable_image")
	_assert_has_non_visual_finding(placeholder_report, "capture_quality.placeholder_artifact")


func test_low_confidence_observation_is_info_and_needs_human_interpretation() -> void:
	var image_path: String = TEST_ROOT + "/sweep/low_confidence.png"
	_write_png(image_path)
	var normalized: Dictionary = AdvisoryReviewReportScript.normalize_manifest(
		TEST_ROOT + "/sweep/review_manifest.json",
		_sweep_manifest_with_capture(image_path, true, false, "")
	)
	var report: Dictionary = AdvisoryReviewReportScript.build_report(
		normalized,
		[
			{
				"beat_id": "spawn_first_look",
				"criterion_id": "visual_hierarchy.focal_clutter",
				"category": "visual_hierarchy",
				"severity": "high",
				"confidence": 0.31,
				"observation": "Possible clutter around the register.",
				"expected_condition": "Main route anchor should remain readable.",
				"recommendation": "Ask a human reviewer to inspect the artifact.",
				"next_human_action": "inspect artifact",
			},
		]
	)
	var finding: Dictionary = (report.get("findings", []) as Array)[0] as Dictionary
	assert_eq(str(report.get("review_status", "")), "needs_human_interpretation")
	assert_eq(str(finding.get("severity", "")), "info")
	assert_true(bool(finding.get("needs_human_interpretation", false)))


func test_markdown_summary_starts_with_status_and_groups_findings_by_beat() -> void:
	var normalized: Dictionary = AdvisoryReviewReportScript.normalize_manifest(
		TEST_ROOT + "/gallery/review_manifest.json",
		_gallery_manifest()
	)
	var report: Dictionary = AdvisoryReviewReportScript.build_report(
		normalized,
		[
			{
				"beat_id": "gallery_state",
				"criterion_id": "component_consistency.ui_language",
				"category": "component_consistency",
				"severity": "medium",
				"confidence": 0.9,
				"observation": "Gallery control language differs from core shop panels.",
				"expected_condition": "Gallery components should match the shop UI language.",
				"recommendation": "Compare baseline before changing shared UI components.",
				"next_human_action": "compare baseline",
			},
		]
	)
	var markdown: String = AdvisoryReviewReportScript.markdown_report(report)

	assert_true(markdown.begins_with("# Advisory Visual Review\n- Status:"))
	assert_string_contains(markdown, "## Highest-Severity Findings")
	assert_string_contains(markdown, "## Findings By Beat Or Frame")
	assert_string_contains(markdown, "### gallery_state")
	assert_string_contains(markdown, "Action: compare baseline")
	assert_string_contains(markdown, TEST_ROOT + "/gallery/gallery_state.png")
	var finding: Dictionary = (report.get("findings", []) as Array)[0] as Dictionary
	assert_true(bool(finding.get("secondary_context", false)))


func test_writes_json_and_markdown_reports_next_to_manifest() -> void:
	var image_path: String = TEST_ROOT + "/write/01_spawn_first_look.png"
	_write_png(image_path)
	var manifest_path: String = TEST_ROOT + "/write/review_manifest.json"
	var manifest: Dictionary = _sweep_manifest_with_capture(image_path, true, false, "")
	_write_json(manifest_path, manifest)
	var result: Dictionary = AdvisoryReviewReportScript.write_reports(manifest_path, manifest)

	assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
	assert_true(FileAccess.file_exists(str(result.get("json_path", ""))))
	assert_true(FileAccess.file_exists(str(result.get("markdown_path", ""))))
	var payload: Dictionary = _read_json(str(result.get("json_path", "")))
	assert_eq(str(payload.get("report_type", "")), "advisory_ai_visual_review")


func _sweep_manifest_with_capture(
	path: String,
	ok: bool,
	placeholder: bool,
	error: String
) -> Dictionary:
	var capture: Dictionary = {
		"ok": ok,
		"path": path,
		"filename": path.get_file(),
		"beat": "spawn_first_look",
		"placeholder": placeholder,
		"error": error,
	}
	return {
		"artifact_type": "store_visual_sweep",
		"schema_version": 1,
		"artifact_dir": path.get_base_dir(),
		"acceptance_target": "first_ten_seconds_route_views",
		"review_criteria": ["route readability"],
		"design_failure_criteria": ["floating text dominates the composition"],
		"beats": [
			{
				"index": 1,
				"name": "spawn_first_look",
				"label": "Spawn first look",
				"filename": path.get_file(),
				"scope": "first_ten_seconds",
				"review_target": "first_ten_seconds_route_views",
				"local_action": "read the route",
				"next_destination": "register",
			},
		],
		"captures": [capture],
	}


func _gallery_manifest() -> Dictionary:
	var path: String = TEST_ROOT + "/gallery/gallery_state.png"
	_write_png(path)
	return {
		"artifact_type": "visual_gallery",
		"schema_version": 1,
		"gallery_id": "visual_gallery",
		"review_flag_catalog": [
			"placeholder_like_geometry",
			"unreadable_signage",
			"mismatched_ui_component_styling",
		],
		"items": [{"id": "panel", "group": "hud"}],
		"state_beats": [{"id": "gallery_state", "filename": "gallery_state.png", "state": "normal"}],
		"captures": [
			{
				"ok": true,
				"beat": "gallery_state",
				"filename": "gallery_state.png",
				"path": path,
				"placeholder": false,
			},
		],
	}


func _video_manifest(path: String) -> Dictionary:
	_write_text(path, "video")
	return {
		"artifact_type": "video_review",
		"schema_version": 1,
		"scenario_id": "store_opening",
		"video_path": path,
		"frames": [
			{"id": "entry_frame", "frame": 12, "expected_condition": "Entry route is readable."},
		],
	}


func _assert_has_non_visual_finding(report: Dictionary, criterion_id: String) -> void:
	for finding_variant: Variant in report.get("findings", []) as Array:
		var finding: Dictionary = finding_variant as Dictionary
		if str(finding.get("criterion_id", "")) == criterion_id:
			assert_false(bool(finding.get("visual_observation", true)))
			assert_true(str(finding.get("observation", "")).contains("no visual observation"))
			assert_eq(str(finding.get("next_human_action", "")), "rerun capture")
			return
	fail_test("Missing capture-quality finding: %s" % criterion_id)


func _write_png(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var image: Image = Image.create_empty(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.25, 0.3, 1.0))
	assert_eq(image.save_png(path), OK)


func _write_text(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file)
	if file == null:
		return
	file.store_string(text)
	file.close()


func _write_json(path: String, payload: Dictionary) -> void:
	_write_text(path, JSON.stringify(payload, "\t"))


func _read_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(parsed is Dictionary)
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}
