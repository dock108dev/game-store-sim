extends GutTest

const STATUS_PATH := "res://../docs/status.json"
const CURRENT_STATE_PATH := "res://../docs/CURRENT_STATE.md"
const README_PATH := "res://../README.md"


func test_docs_status_contract_names_design_reset_gate() -> void:
	var status := _load_json(STATUS_PATH)

	assert_eq(status.get("current_phase"), "hero_art_slice_implemented_pending_owner_visual_validation")
	assert_eq(status.get("playtest_state"), "paused_until_hero_art_slice_approved")
	assert_eq(status.get("project"), "game-store-sim")
	assert_true(status.get("playable_state", {}).get("human_review_required"))
	assert_eq(status.get("playable_state", {}).get("visual_read"), "object_family_pass_rejected_still_graybox_read")
	assert_string_contains(str(status.get("removed_doc_policy", "")), "deleted")
	assert_eq(_dictionary(status.get("visual_validation", {})).get("status"), "failed")
	assert_eq(_dictionary(status.get("visual_validation", {})).get("next_allowed_work"), "owner_visual_validation_of_isolated_hero_art_slice")


func test_docs_status_contract_records_validation_baseline() -> void:
	var validation: Dictionary = _dictionary(status_value("validation"))
	var ui: Dictionary = _dictionary(validation.get("ui_automation"))
	var scripts: Dictionary = _dictionary(validation.get("script_test_mapping"))

	assert_eq(validation.get("command"), "scripts/validate_godot.sh")
	assert_eq(int(validation.get("gut_tests")), 594)
	assert_eq(int(validation.get("gut_asserts")), 12286)
	assert_eq(int(ui.get("automated")), 512)
	assert_eq(int(ui.get("total")), 632)
	assert_eq(int(scripts.get("covered")), 55)
	assert_eq(int(scripts.get("total")), 55)
	assert_eq(int(validation.get("active_validation_tools")), 3)
	assert_eq(int(validation.get("catalog_products")), 62)
	assert_eq(validation.get("desktop_pack_smoke"), "passed")
	assert_eq(validation.get("screenshot_sanity"), "passed")
	assert_eq(int(validation.get("screenshot_count")), 27)
	assert_eq(validation.get("screenshot_contact_sheet"), "artifacts/validation/latest/screenshot-contact-sheet.png")
	assert_eq(validation.get("packet_09_art_spike_scene"), "game/scenes/world/art_benchmark/packet_09_inside_out_art_spike.tscn")
	assert_eq(validation.get("packet_09_art_spike_capture_tool"), "game/tests/tools/capture_packet_09_art_spike_screenshot.gd")
	assert_eq(validation.get("packet_09_art_spike_review_board"), "artifacts/validation/latest/packet-09-art-spike-review-board.png")
	assert_true((validation.get("packet_09_art_spike_screenshots", []) as Array).has("artifacts/validation/latest/screenshots/packet_09_inside_out_art_spike.png"))
	assert_eq(validation.get("hero_art_slice_scene"), "game/scenes/world/art_benchmark/hero_art_slice.tscn")
	assert_eq(validation.get("hero_art_slice_capture_tool"), "game/tests/tools/capture_hero_art_slice_screenshot.gd")
	assert_eq(validation.get("hero_art_slice_screenshot"), "pending local GUI capture")


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
	assert_true(active_docs.has("docs/visual-bible/README.md"))
	assert_true(active_docs.has("docs/visual-bible/01-store-shell-architecture.md"))
	assert_true(active_docs.has("docs/visual-bible/02-fixtures-and-displays.md"))
	assert_true(active_docs.has("docs/visual-bible/03-product-art-and-packaging.md"))
	assert_true(active_docs.has("docs/visual-bible/04-fictional-platforms-and-games.md"))
	assert_true(active_docs.has("docs/visual-bible/05-counter-register-and-trade-in.md"))
	assert_true(active_docs.has("docs/visual-bible/06-stockroom-receiving-office.md"))
	assert_true(active_docs.has("docs/visual-bible/07-signage-marketing-and-store-identity.md"))
	assert_true(active_docs.has("docs/visual-bible/08-art-production-pipeline.md"))
	assert_true(active_docs.has("docs/visual-bible/09-mvp-object-implementation-checklist.md"))
	assert_true(active_docs.has("docs/design-implementation/README.md"))
	assert_true(active_docs.has("docs/design-implementation/02-visual-module-system-spec.md"))
	assert_true(active_docs.has("docs/design-implementation/13-agent-work-packet-template.md"))
	assert_true(active_docs.has("docs/design-implementation/14-phase-implementation-roadmap.md"))
	assert_true(active_docs.has("docs/design-implementation/15-art-direction-reset-and-spike-plan.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/00-packet-index.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/01-mvp-product-art-kit.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/02-mvp-fixture-display-kit.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/03-shell-counter-backroom-kit.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/04-playable-store-integration-review.md"))
	assert_true(active_docs.has("docs/design-implementation/work-packets/05-hero-art-slice-proof.md"))
	assert_true(active_docs.has("new_real_inspiration/README.md"))
	assert_true(active_docs.has("docs/production/04-backlog.md"))
	assert_true(active_docs.has("docs/production/06-validation.md"))
	assert_true(active_docs.has("docs/production/13-visual-blockers.md"))
	assert_true(active_docs.has("docs/production/14-visual-bible-implementation-review.md"))
	assert_true(active_docs.has("docs/production/15-failed-visual-validation.md"))
	assert_true(active_docs.has("docs/production/16-hero-art-slice-review.md"))
	assert_true(active_docs.has("docs/qa/smoke-playtest.md"))
	assert_true(active_docs.has("docs/qa/screenshot-review.md"))
	assert_false(active_docs.has("docs/design-implementation/03-store-shell-and-mall-entrance-slice.md"))
	assert_false(active_docs.has("docs/design-implementation/12-validation-and-screenshot-checklist.md"))
	assert_false(active_docs.has("docs/design-implementation/work-packets/01-visual-module-foundation.md"))
	assert_false(active_docs.has("docs/design-implementation/work-packets/09-art-direction-spike.md"))
	assert_false(active_docs.has("docs/production/13-alpha-bug-list.md"))
	assert_false(active_docs.has("docs/production/14-owner-visual-review-package.md"))
	assert_false(active_docs.has("docs/design-planning/README.md"))
	assert_false(active_docs.has("docs/visual-production/00-art-language-rebuild-plan.md"))
	assert_false(active_docs.has("docs/visual-production/19-hard-visual-benchmark-rebuild.md"))
	assert_false(active_docs.has("docs/production/15-alpha-playtest-package.md"))


func test_current_state_and_readme_point_to_new_plan() -> void:
	var current_state := FileAccess.get_file_as_string(CURRENT_STATE_PATH)
	var readme := FileAccess.get_file_as_string(README_PATH)

	assert_string_contains(current_state, "docs/status.json")
	assert_string_contains(current_state, "Design Source Of Truth")
	assert_string_contains(current_state, "Visual Bible")
	assert_string_contains(current_state, "Design Implementation Index")
	assert_string_contains(current_state, "Failed Visual Validation")
	assert_string_contains(current_state, "Visual Blockers")
	assert_string_contains(current_state, "hero art slice")
	assert_string_contains(current_state, "2002-2004")
	assert_string_contains(readme, "docs/status.json")
	assert_string_contains(readme, "Design Source Of Truth")
	assert_string_contains(readme, "Design Implementation Index")
	assert_string_contains(readme, "Hero Art Slice Proof")
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
