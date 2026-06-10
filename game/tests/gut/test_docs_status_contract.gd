extends GutTest

const STATUS_PATH := "res://../docs/status.json"
const CURRENT_STATE_PATH := "res://../docs/CURRENT_STATE.md"
const README_PATH := "res://../README.md"


func test_docs_status_contract_names_current_review_gate() -> void:
	var status := _load_json(STATUS_PATH)

	assert_eq(status.get("current_phase"), "opening_store_catalog_decor_quality_bar_ready_for_owner_review")
	assert_eq(status.get("playtest_state"), "paused_pending_owner_review")
	assert_eq(status.get("project"), "game-store-sim")
	assert_true(status.get("playable_state", {}).get("human_review_required"))
	assert_eq(status.get("playable_state", {}).get("visual_read"), "production_blockout")


func test_docs_status_contract_records_validation_baseline() -> void:
	var validation: Dictionary = _dictionary(status_value("validation"))
	var ui: Dictionary = _dictionary(validation.get("ui_automation"))
	var scripts: Dictionary = _dictionary(validation.get("script_test_mapping"))

	assert_eq(validation.get("command"), "scripts/validate_godot.sh")
	assert_eq(int(validation.get("gut_tests")), 563)
	assert_eq(int(validation.get("gut_asserts")), 9607)
	assert_eq(int(ui.get("automated")), 508)
	assert_eq(int(ui.get("total")), 628)
	assert_eq(int(scripts.get("covered")), 52)
	assert_eq(int(scripts.get("total")), 52)
	assert_eq(int(validation.get("active_validation_tools")), 3)
	assert_eq(int(validation.get("catalog_products")), 60)
	assert_eq(validation.get("desktop_pack_smoke"), "passed")
	assert_eq(validation.get("screenshot_sanity"), "passed")
	assert_eq(int(validation.get("screenshot_count")), 23)
	assert_eq(validation.get("screenshot_contact_sheet"), "artifacts/validation/latest/screenshot-contact-sheet.png")


func test_docs_status_contract_points_to_active_docs() -> void:
	var status := _load_json(STATUS_PATH)
	var active_docs: Array = status.get("active_docs", [])
	var historical_docs: Array = status.get("historical_docs", [])

	for path in active_docs:
		assert_true(FileAccess.file_exists("res://../%s" % path), str(path))

	assert_true(active_docs.has("docs/CURRENT_STATE.md"))
	assert_true(active_docs.has("docs/design-planning/README.md"))
	assert_true(active_docs.has("docs/design-planning/01-opening-store-quality-bar.md"))
	assert_true(active_docs.has("docs/design-planning/08-quality-bar-checklist.md"))
	assert_true(active_docs.has("docs/qa/smoke-playtest.md"))
	assert_true(active_docs.has("docs/qa/full-day-playtest.md"))
	assert_true(active_docs.has("docs/qa/screenshot-review.md"))
	assert_true(active_docs.has("docs/qa/release-package-check.md"))
	assert_true(historical_docs.has("docs/production/11-game-completion-plan.md"))
	assert_true(historical_docs.has("docs/production/18-production-visuals-plan.md"))


func test_current_state_and_readme_point_to_status_contract() -> void:
	var current_state := FileAccess.get_file_as_string(CURRENT_STATE_PATH)
	var readme := FileAccess.get_file_as_string(README_PATH)

	assert_string_contains(current_state, "docs/status.json")
	assert_string_contains(current_state, "docs/qa/screenshot-review.md")
	assert_string_contains(readme, "docs/status.json")
	assert_string_contains(readme, "Tests should assert that status contract")


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
