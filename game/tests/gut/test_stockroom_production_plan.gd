extends GutTest

const MASTER_PATH := "res://../docs/design-source-of-truth/00-master-design-source-of-truth.md"
const SLICE_PATH := "res://../docs/design-source-of-truth/01-vertical-slice-spec.md"
const WORLD_PATH := "res://../docs/design-source-of-truth/02-store-design-world-building.md"
const ASSET_ROADMAP_PATH := "res://../docs/design-source-of-truth/03-asset-inventory-roadmap.md"
const VALIDATION_PLAN_PATH := "res://../docs/design-source-of-truth/04-validation-and-signoff.md"
const BACKLOG_PATH := "res://../docs/production/04-backlog.md"
const SCENARIO_PATH := "res://tests/validation/scenarios/stockroom_production_plan.json"


func test_design_source_names_core_slice_constraints() -> void:
	var master := FileAccess.get_file_as_string(MASTER_PATH)
	var slice := FileAccess.get_file_as_string(SLICE_PATH)
	var world := FileAccess.get_file_as_string(WORLD_PATH)
	var required_terms := [
		"2002-2004",
		"Nova",
		"Vertex",
		"Prism",
		"Pocket",
		"underfunded",
		"15-25%",
		"40-60 games",
	]

	for term in required_terms:
		assert_true(master.contains(term) or slice.contains(term) or world.contains(term), term)

	assert_string_contains(master, "Current mechanics stay stable")
	assert_string_contains(world, "The store remains game-first.")


func test_asset_roadmap_names_required_counts_and_phases() -> void:
	var roadmap := FileAccess.get_file_as_string(ASSET_ROADMAP_PATH)

	for term in [
		"total objects: 300",
		"MVP objects: 77",
		"OBJ-001 Narrow storefront glass door",
		"OBJ-057 Double-sided gondola shelf",
		"Phase 1: Store Shell And First Read",
		"Phase 5: Demo, Bargain, Guides, And Hardware",
	]:
		assert_string_contains(roadmap, term)

	assert_string_contains(roadmap, "Do not build all 300 objects as loose props")


func test_design_reset_validation_plan_names_owner_gate() -> void:
	var validation_plan := FileAccess.get_file_as_string(VALIDATION_PLAN_PATH)
	var backlog := FileAccess.get_file_as_string(BACKLOG_PATH)

	assert_string_contains(validation_plan, "Does the current build deliver the fantasy")
	assert_string_contains(validation_plan, "small early-2000s independent game store")
	assert_string_contains(backlog, "Design reset")
	assert_string_contains(backlog, "Stop and ask for owner review")


func test_legacy_stockroom_validation_scenarios_remain_structured() -> void:
	var scenarios := _scenario_map(SCENARIO_PATH)
	for scenario_id in ["stockroom_staff_boundary_shell", "stockroom_receiving_intake_station", "stockroom_manager_office_context"]:
		assert_true(scenarios.has(scenario_id), "missing stockroom scenario %s" % scenario_id)
		var scenario: Dictionary = scenarios.get(scenario_id)
		assert_eq(scenario.get("status"), "automated", scenario_id)
		assert_true(scenario.get("critical"), scenario_id)


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
