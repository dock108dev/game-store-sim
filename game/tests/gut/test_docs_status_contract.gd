extends GutTest

const STATUS_PATH := "res://../docs/status.json"
const CURRENT_STATE_PATH := "res://../docs/CURRENT_STATE.md"
const README_PATH := "res://../README.md"


func test_docs_status_contract_names_art_language_rebuild_gate() -> void:
	var status := _load_json(STATUS_PATH)

	assert_eq(status.get("current_phase"), "art_language_rebuild_ready_for_implementation")
	assert_eq(status.get("playtest_state"), "paused_until_visual_baseline_approved")
	assert_eq(status.get("project"), "game-store-sim")
	assert_true(status.get("playable_state", {}).get("human_review_required"))
	assert_eq(status.get("playable_state", {}).get("visual_read"), "cube_language_rejected_art_kit_required")
	assert_string_contains(str(status.get("removed_doc_policy", "")), "deleted")


func test_docs_status_contract_records_validation_baseline() -> void:
	var validation: Dictionary = _dictionary(status_value("validation"))
	var ui: Dictionary = _dictionary(validation.get("ui_automation"))
	var scripts: Dictionary = _dictionary(validation.get("script_test_mapping"))

	assert_eq(validation.get("command"), "scripts/validate_godot.sh")
	assert_eq(int(validation.get("gut_tests")), 566)
	assert_eq(int(validation.get("gut_asserts")), 10705)
	assert_eq(int(ui.get("automated")), 508)
	assert_eq(int(ui.get("total")), 628)
	assert_eq(int(scripts.get("covered")), 53)
	assert_eq(int(scripts.get("total")), 53)
	assert_eq(int(validation.get("active_validation_tools")), 3)
	assert_eq(int(validation.get("catalog_products")), 60)
	assert_eq(validation.get("desktop_pack_smoke"), "passed")
	assert_eq(validation.get("screenshot_sanity"), "passed")
	assert_eq(int(validation.get("screenshot_count")), 23)
	assert_eq(validation.get("screenshot_contact_sheet"), "artifacts/validation/latest/screenshot-contact-sheet.png")


func test_docs_status_contract_points_only_to_existing_active_docs() -> void:
	var status := _load_json(STATUS_PATH)
	var active_docs: Array = status.get("active_docs", [])

	for path in active_docs:
		assert_true(FileAccess.file_exists("res://../%s" % path), str(path))

	assert_true(active_docs.has("docs/README.md"))
	assert_true(active_docs.has("docs/CURRENT_STATE.md"))
	assert_true(active_docs.has("docs/visual-production/README.md"))
	assert_true(active_docs.has("docs/visual-production/00-art-language-rebuild-plan.md"))
	assert_true(active_docs.has("docs/visual-production/01-modular-asset-kit-spec.md"))
	assert_true(active_docs.has("docs/visual-production/02-art-rebuild-validation-plan.md"))
	assert_true(active_docs.has("docs/production/04-backlog.md"))
	assert_true(active_docs.has("docs/production/06-validation.md"))
	assert_true(active_docs.has("docs/production/13-alpha-bug-list.md"))
	assert_true(active_docs.has("docs/qa/smoke-playtest.md"))
	assert_true(active_docs.has("docs/qa/screenshot-review.md"))
	assert_false(active_docs.has("docs/design-planning/README.md"))
	assert_false(active_docs.has("docs/visual-production/19-hard-visual-benchmark-rebuild.md"))
	assert_false(active_docs.has("docs/production/15-alpha-playtest-package.md"))


func test_current_state_and_readme_point_to_new_plan() -> void:
	var current_state := FileAccess.get_file_as_string(CURRENT_STATE_PATH)
	var readme := FileAccess.get_file_as_string(README_PATH)

	assert_string_contains(current_state, "docs/status.json")
	assert_string_contains(current_state, "Art Language Rebuild Plan")
	assert_string_contains(current_state, "cube")
	assert_string_contains(readme, "docs/status.json")
	assert_string_contains(readme, "Art Language Rebuild")
	assert_false(readme.contains("Prototype Visual Language Cleanup"))


func status_value(key: String) -> Variant:
	return _load_json(STATUS_PATH).get(key)


func _dictionary(value: Variant) -> Dictionary:
	assert_true(value is Dictionary)
	return value as Dictionary


func _load_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	assert_false(text.is_empty(), path)
	var parsed = JSON.parse_string(text)
	assert_true(parsed is Dictionary, path)
	return parsed as Dictionary
