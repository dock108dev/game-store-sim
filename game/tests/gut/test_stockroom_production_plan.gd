extends GutTest

const PLAN_PATH := "res://../docs/production/17-stockroom-production-plan.md"
const README_PATH := "res://../README.md"
const BACKLOG_PATH := "res://../docs/production/04-backlog.md"
const COMPLETION_PLAN_PATH := "res://../docs/production/11-game-completion-plan.md"
const DECISION_LOG_PATH := "res://../docs/production/03-decision-log.md"
const MANUAL_DOC_PATH := "res://../docs/production/07-current-manual-playtest.md"
const PACKAGE_DOC_PATH := "res://../docs/production/15-alpha-playtest-package.md"
const SCENARIO_PATH := "res://tests/validation/scenarios/stockroom_production_plan.json"


func test_stockroom_plan_is_active_next_stage() -> void:
	var plan := FileAccess.get_file_as_string(PLAN_PATH)
	var readme := FileAccess.get_file_as_string(README_PATH)
	var backlog := FileAccess.get_file_as_string(BACKLOG_PATH)
	var completion_plan := FileAccess.get_file_as_string(COMPLETION_PLAN_PATH)
	var decision_log := FileAccess.get_file_as_string(DECISION_LOG_PATH)
	var package_doc := FileAccess.get_file_as_string(PACKAGE_DOC_PATH)

	assert_string_contains(plan, "next active implementation plan after readability recovery")
	assert_string_contains(plan, "External alpha playtest remains paused until the owner screenshot pass is readable")
	assert_string_contains(plan, "employees-only stockroom and office")
	assert_string_contains(plan, "do not turn them into instant sales-floor inventory")
	assert_string_contains(readme, "Employees-Only Stockroom Production Plan")
	assert_string_contains(backlog, "Employees-only stockroom production")
	assert_string_contains(completion_plan, "17-stockroom-production-plan.md")
	assert_string_contains(decision_log, "Employees-Only Stockroom Production")
	assert_string_contains(package_doc, "stockroom production phase")


func test_stockroom_plan_has_ordered_slice_stops() -> void:
	var plan := FileAccess.get_file_as_string(PLAN_PATH)
	var required_slices := [
		"## Slice 0: Docs, Audit, And Validation Lock",
		"## Slice 1: Stockroom Shell And Staff Boundary",
		"## Slice 2: Receiving And Intake Stations",
		"## Slice 3: Backstock Shelving And Pull/Store Flow",
		"## Slice 4: Manager Office And Computer World Context",
		"## Slice 5: Service, Safe, And Records Corners",
		"## Slice 6: Stockroom Computer Workflow Copy And Controls",
		"## Slice 7: Stockroom Lighting, Materials, And Prop Density",
		"## Slice 8: Validation Sync And External Package Decision",
	]

	for slice_name in required_slices:
		assert_string_contains(plan, slice_name)

	assert_string_contains(plan, "delivery door or roll-up/pallet zone")
	assert_string_contains(plan, "labeled category shelves")
	assert_string_contains(plan, "manager's office workstation")
	assert_string_contains(plan, "Keep every slice validated, committed, and pushed")


func test_stockroom_manual_checks_are_synced() -> void:
	var manual_doc := FileAccess.get_file_as_string(MANUAL_DOC_PATH)
	var plan := FileAccess.get_file_as_string(PLAN_PATH)

	assert_string_contains(manual_doc, "Stockroom Production Focus")
	assert_string_contains(manual_doc, "43_stockroom_staff_threshold.png")
	assert_string_contains(manual_doc, "45_receiving_intake_station.png")
	assert_string_contains(manual_doc, "48_manager_office_context.png")
	assert_string_contains(plan, "50_storage_tab_physical_flow.png")


func test_stockroom_validation_scenarios_are_registered() -> void:
	var scenarios := _scenario_map(SCENARIO_PATH)
	var required_ids := [
		"stockroom_plan_docs_sync",
		"stockroom_slice_stop_contract",
		"stockroom_manual_checklist_sync",
		"stockroom_readme_pointer_sync",
		"stockroom_backlog_pointer_sync",
		"stockroom_completion_handoff_sync",
		"stockroom_package_pause_guard",
		"stockroom_staff_boundary_shell",
		"stockroom_office_service_route_cues",
		"stockroom_receiving_state_cues",
		"stockroom_receiving_intake_station",
		"stockroom_backstock_category_lanes",
		"stockroom_backstock_pull_stage",
		"stockroom_manager_office_context",
	]

	for scenario_id in required_ids:
		assert_true(scenarios.has(scenario_id), "missing stockroom scenario %s" % scenario_id)
		var scenario: Dictionary = scenarios.get(scenario_id)
		assert_eq(scenario.get("status"), "automated", scenario_id)
		assert_true(scenario.get("critical"), scenario_id)
		assert_string_contains(str(scenario.get("evidence", "")), "res://tests/gut/")


func _scenario_map(path: String) -> Dictionary:
	var data := _load_json(path)
	var scenarios: Array = data.get("ui_scenarios", [])
	var by_id := {}
	for scenario in scenarios:
		by_id[str(scenario.get("id", ""))] = scenario
	return by_id


func _load_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	assert_false(text.is_empty(), path)
	var parsed = JSON.parse_string(text)
	assert_true(parsed is Dictionary, path)
	return parsed as Dictionary
