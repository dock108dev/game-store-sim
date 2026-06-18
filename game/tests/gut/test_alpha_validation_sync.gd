extends GutTest

const STATUS_PATH := "res://../docs/status.json"
const VALIDATION_DOC_PATH := "res://../docs/production/06-validation.md"
const BACKLOG_PATH := "res://../docs/production/04-backlog.md"
const BUG_LIST_PATH := "res://../docs/production/13-alpha-bug-list.md"
const SCREENSHOT_REVIEW_PATH := "res://../docs/qa/screenshot-review.md"


func test_validation_snapshot_records_current_gate_outputs() -> void:
	var status := _load_json(STATUS_PATH)
	var validation: Dictionary = status.get("validation", {})
	var ui: Dictionary = validation.get("ui_automation", {})
	var scripts: Dictionary = validation.get("script_test_mapping", {})

	assert_eq(int(validation.get("gut_tests")), 571)
	assert_eq(int(ui.get("automated")), 508)
	assert_eq(int(ui.get("total")), 628)
	assert_eq(int(scripts.get("covered")), 53)
	assert_eq(int(scripts.get("total")), 53)
	assert_eq(int(validation.get("active_validation_tools")), 3)
	assert_eq(int(validation.get("catalog_products")), 60)
	assert_eq(validation.get("desktop_pack_smoke"), "passed")


func test_docs_name_design_reset_as_current_gate() -> void:
	var validation_doc := FileAccess.get_file_as_string(VALIDATION_DOC_PATH)
	var backlog := FileAccess.get_file_as_string(BACKLOG_PATH)
	var bug_list := FileAccess.get_file_as_string(BUG_LIST_PATH)
	var screenshot_review := FileAccess.get_file_as_string(SCREENSHOT_REVIEW_PATH)

	assert_string_contains(validation_doc, "design reset")
	assert_string_contains(backlog, "Design reset")
	assert_string_contains(bug_list, "VIS-001")
	assert_string_contains(screenshot_review, "2002-2004")
	assert_false(backlog.contains("external alpha"))


func test_deleted_doc_families_do_not_exist() -> void:
	var deleted_paths := [
		"res://../docs/design-planning/README.md",
		"res://../docs/game-design/00-vision.md",
		"res://../docs/production/15-alpha-playtest-package.md",
		"res://../docs/production/17-stockroom-production-plan.md",
		"res://../docs/visual-production/19-hard-visual-benchmark-rebuild.md",
		"res://../docs/qa/release-package-check.md",
	]

	for path in deleted_paths:
		assert_false(FileAccess.file_exists(path), path)


func _load_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	assert_false(text.is_empty(), path)
	var parsed = JSON.parse_string(text)
	assert_true(parsed is Dictionary, path)
	return parsed as Dictionary
