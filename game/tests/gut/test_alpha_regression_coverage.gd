extends GutTest

const ALPHA_BUG_LIST_PATH := "res://../docs/production/13-alpha-bug-list.md"
const CAPTURE_TOOL_PATH := "res://tests/tools/capture_main_scene_screenshot.gd"
const VALIDATION_GATE_PATH := "res://../scripts/validate_godot.sh"


func test_screenshot_scenarios_cover_current_visual_blockers() -> void:
	var alpha_bug_list := FileAccess.get_file_as_string(ALPHA_BUG_LIST_PATH)
	var capture_tool := FileAccess.get_file_as_string(CAPTURE_TOOL_PATH)
	var validation_gate := FileAccess.get_file_as_string(VALIDATION_GATE_PATH)
	assert_false(alpha_bug_list.is_empty())
	assert_false(capture_tool.is_empty())
	assert_false(validation_gate.is_empty())

	for issue_id in ["VIS-001", "VIS-002", "VIS-003", "VIS-004", "VIS-007", "VIS-008", "VIS-009", "VIS-010"]:
		assert_string_contains(alpha_bug_list, issue_id)

	var required_scenarios := [
		"main_scene",
		"customer_queue",
		"register_counter",
		"trade_in_offer",
		"backroom_summary",
		"release_calendar",
		"release_allocation",
		"launch_day",
		"fixture_ghost",
		"fixture_invalid_ghost",
		"fixture_rotated_ghost",
		"fixture_placed",
	]
	for scenario in required_scenarios:
		assert_string_contains(capture_tool, '"%s"' % scenario)
		assert_string_contains(validation_gate, scenario)


func test_alpha_backroom_screenshot_scenarios_select_named_tabs() -> void:
	var capture_tool := FileAccess.get_file_as_string(CAPTURE_TOOL_PATH)

	assert_string_contains(capture_tool, '_open_day_summary_tab(player, session, "releases")')
	assert_string_contains(capture_tool, '_open_day_summary_tab(player, session, "reports")')
	assert_string_contains(capture_tool, "func _open_day_summary_tab")
	assert_string_contains(capture_tool, "func _prepare_backroom_summary")
	assert_string_contains(capture_tool, "player.open_day_summary(session)")


func test_production_visual_screenshot_scenarios_have_named_compositions() -> void:
	var capture_tool := FileAccess.get_file_as_string(CAPTURE_TOOL_PATH)
	var validation_gate := FileAccess.get_file_as_string(VALIDATION_GATE_PATH)
	var required_scenarios := [
		"storefront_entry",
		"lighting_materials_store",
		"lighting_materials_mall",
		"stocked_aisle",
		"product_closeup",
		"stockroom_doorway",
		"catalog_design_cues",
		"upgrade_preview",
	]

	for scenario in required_scenarios:
		assert_string_contains(capture_tool, '"%s"' % scenario)
		assert_string_contains(validation_gate, scenario)

	assert_string_contains(capture_tool, "_prepare_fixture_ghost(scene)")
