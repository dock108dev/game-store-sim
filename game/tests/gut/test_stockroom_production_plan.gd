extends GutTest

const ART_PLAN_PATH := "res://../docs/visual-production/00-art-language-rebuild-plan.md"
const KIT_SPEC_PATH := "res://../docs/visual-production/01-modular-asset-kit-spec.md"
const VALIDATION_PLAN_PATH := "res://../docs/visual-production/02-art-rebuild-validation-plan.md"
const BACKLOG_PATH := "res://../docs/production/04-backlog.md"
const SCENARIO_PATH := "res://tests/validation/scenarios/stockroom_production_plan.json"


func test_art_language_rebuild_plan_has_ordered_phases() -> void:
	var plan := FileAccess.get_file_as_string(ART_PLAN_PATH)
	var required_phases := [
		"## Phase A: Baseline Lock And Rejection Record",
		"## Phase B: Art-Kit Sandbox Scene",
		"## Phase C: Storefront Facade Kit",
		"## Phase D: Register Counter And First Interior Kit",
		"## Phase E: Wall Shelf, Product, And Poster Kit",
		"## Phase F: Receiving And Backroom Threshold Kit",
		"## Phase G: Production Route Replacement",
		"## Phase H: Validation And Owner Review",
	]

	for phase in required_phases:
		assert_string_contains(plan, phase)

	assert_string_contains(plan, "Stop if the sandbox scene still reads as cubes")
	assert_string_contains(plan, "Do not build broad catalog variants")


func test_modular_asset_spec_names_required_kits_and_folders() -> void:
	var spec := FileAccess.get_file_as_string(KIT_SPEC_PATH)

	for path in [
		"game/scenes/world/art_benchmark/",
		"game/scenes/world/kits/storefront/",
		"game/scenes/world/kits/interior/",
		"game/scenes/world/kits/fixtures/",
		"game/assets/materials/retail/",
		"game/assets/decals/retail/",
	]:
		assert_string_contains(spec, path)

	assert_string_contains(spec, "Avoid as final route art")
	assert_string_contains(spec, "raw rectangular CSG blocks")


func test_art_rebuild_validation_plan_names_owner_gate() -> void:
	var validation_plan := FileAccess.get_file_as_string(VALIDATION_PLAN_PATH)
	var backlog := FileAccess.get_file_as_string(BACKLOG_PATH)

	assert_string_contains(validation_plan, "Does the opening route read like a simple mid-00s independent game shop")
	assert_string_contains(validation_plan, "The pass fails if the answer is still \"cubes.\"")
	assert_string_contains(backlog, "Art language rebuild")
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
