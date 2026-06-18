extends GutTest

const STATUS_PATH := "res://../docs/status.json"
const CURRENT_STATE_PATH := "res://../docs/CURRENT_STATE.md"
const README_PATH := "res://../README.md"


func test_docs_status_contract_names_design_reset_gate() -> void:
	var status := _load_json(STATUS_PATH)

	assert_eq(status.get("current_phase"), "implementation_packets_ready")
	assert_eq(status.get("playtest_state"), "paused_until_design_source_of_truth_baseline_approved")
	assert_eq(status.get("project"), "game-store-sim")
	assert_true(status.get("playable_state", {}).get("human_review_required"))
	assert_eq(status.get("playable_state", {}).get("visual_read"), "design_reset_required_source_of_truth_adopted")
	assert_string_contains(str(status.get("removed_doc_policy", "")), "deleted")


func test_docs_status_contract_records_validation_baseline() -> void:
	var validation: Dictionary = _dictionary(status_value("validation"))
	var ui: Dictionary = _dictionary(validation.get("ui_automation"))
	var scripts: Dictionary = _dictionary(validation.get("script_test_mapping"))

	assert_eq(validation.get("command"), "scripts/validate_godot.sh")
	assert_eq(int(validation.get("gut_tests")), 570)
	assert_eq(int(validation.get("gut_asserts")), 10834)
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
	assert_true(active_docs.has("docs/design-source-of-truth/README.md"))
	assert_true(active_docs.has("docs/design-source-of-truth/00-master-design-source-of-truth.md"))
	assert_true(active_docs.has("docs/design-source-of-truth/01-vertical-slice-spec.md"))
	assert_true(active_docs.has("docs/design-source-of-truth/02-store-design-world-building.md"))
	assert_true(active_docs.has("docs/design-source-of-truth/03-asset-inventory-roadmap.md"))
	assert_true(active_docs.has("docs/design-source-of-truth/04-validation-and-signoff.md"))
	assert_true(active_docs.has("docs/design-implementation/README.md"))
	assert_true(active_docs.has("docs/design-implementation/02-visual-module-system-spec.md"))
	assert_true(active_docs.has("docs/design-implementation/03-store-shell-and-mall-entrance-slice.md"))
	assert_true(active_docs.has("docs/design-implementation/04-starting-store-layout-spec.md"))
	assert_true(active_docs.has("docs/design-implementation/05-fixture-grid-slice.md"))
	assert_true(active_docs.has("docs/design-implementation/06-checkout-and-trade-in-counter-slice.md"))
	assert_true(active_docs.has("docs/design-implementation/07-product-and-platform-visual-language-spec.md"))
	assert_true(active_docs.has("docs/design-implementation/08-required-zones-slice.md"))
	assert_true(active_docs.has("docs/design-implementation/09-density-and-clutter-rules.md"))
	assert_true(active_docs.has("docs/design-implementation/10-signage-branding-and-store-identity-spec.md"))
	assert_true(active_docs.has("docs/design-implementation/11-lighting-materials-and-color-palette-spec.md"))
	assert_true(active_docs.has("docs/design-implementation/12-validation-and-screenshot-checklist.md"))
	assert_true(active_docs.has("docs/design-implementation/13-agent-work-packet-template.md"))
	assert_true(active_docs.has("docs/design-implementation/14-phase-implementation-roadmap.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/00-packet-index.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/01-visual-module-foundation.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/02-store-shell-mall-entrance-stockroom.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/03-fixtures-and-placement-systems.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/04-checkout-trade-in-and-day-one-setup.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/05-product-platform-and-price-language.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/06-signage-promotions-and-required-zones.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/07-lighting-density-and-integration-polish.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/08-review-package-and-owner-validation.md"))
	assert_true(active_docs.has("docs/production/04-backlog.md"))
	assert_true(active_docs.has("docs/production/06-validation.md"))
	assert_true(active_docs.has("docs/production/13-alpha-bug-list.md"))
	assert_true(active_docs.has("docs/qa/smoke-playtest.md"))
	assert_true(active_docs.has("docs/qa/screenshot-review.md"))
	assert_false(active_docs.has("docs/design-planning/README.md"))
	assert_false(active_docs.has("docs/visual-production/00-art-language-rebuild-plan.md"))
	assert_false(active_docs.has("docs/visual-production/19-hard-visual-benchmark-rebuild.md"))
	assert_false(active_docs.has("docs/production/15-alpha-playtest-package.md"))


func test_current_state_and_readme_point_to_new_plan() -> void:
	var current_state := FileAccess.get_file_as_string(CURRENT_STATE_PATH)
	var readme := FileAccess.get_file_as_string(README_PATH)

	assert_string_contains(current_state, "docs/status.json")
	assert_string_contains(current_state, "Design Source Of Truth")
	assert_string_contains(current_state, "Design Implementation Index")
	assert_string_contains(current_state, "2002-2004")
	assert_string_contains(readme, "docs/status.json")
	assert_string_contains(readme, "Design Source Of Truth")
	assert_string_contains(readme, "Design Implementation Index")
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
