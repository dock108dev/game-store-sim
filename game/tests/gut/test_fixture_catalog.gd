extends GutTest

const FIXTURE_DIR := "res://data/fixtures"


func test_fixture_catalog_contains_stop_9_fixture_set() -> void:
	var fixtures := _load_fixtures()
	var fixture_ids := _fixture_ids(fixtures)

	assert_eq(fixtures.size(), 9)
	assert_true(fixture_ids.has("fixture_game_display_rack"))
	assert_true(fixture_ids.has("fixture_wall_shelf"))
	assert_true(fixture_ids.has("fixture_accessory_peg_wall"))
	assert_true(fixture_ids.has("fixture_bargain_bin"))
	assert_true(fixture_ids.has("fixture_locked_case"))
	assert_true(fixture_ids.has("fixture_counter_rack"))
	assert_true(fixture_ids.has("fixture_demo_kiosk"))
	assert_true(fixture_ids.has("fixture_new_release_wall"))
	assert_true(fixture_ids.has("fixture_backroom_rack"))
	assert_eq(fixture_ids.size(), _unique_string_count(fixture_ids))


func test_fixture_catalog_contains_game_display_rack() -> void:
	var fixture := _fixture_by_id(_load_fixtures(), "fixture_game_display_rack")

	assert_not_null(fixture)
	assert_eq(fixture.get("fixture_id"), "fixture_game_display_rack")
	assert_eq(fixture.get("display_name"), "Game Display Rack")
	assert_eq(fixture.get("category"), "display")
	assert_eq(fixture.get("default_slot_category"), "used_game")
	assert_eq(fixture.get("cost_cents"), 12500)
	assert_eq(fixture.get("slot_count"), 3)
	assert_eq(fixture.get("placement_zone"), "sales_floor")
	assert_true((fixture.get("accepted_product_categories") as PackedStringArray).has("used_game"))
	assert_true((fixture.get("gameplay_tags") as PackedStringArray).has("starter_fixture"))
	assert_eq(fixture.get("scene_path"), "res://scenes/props/placeholder_shelf.tscn")
	assert_true(fixture.get("placeable"))
	assert_gt((fixture.get("footprint_size") as Vector2).x, 0.0)
	assert_gt((fixture.get("footprint_size") as Vector2).y, 0.0)
	assert_not_null(load(str(fixture.get("scene_path"))) as PackedScene)
	assert_string_contains(fixture.call("describe"), "Game Display Rack")
	assert_string_contains(fixture.call("describe"), "$125.00")
	assert_string_contains(fixture.call("describe"), "3 slots")


func test_fixture_catalog_has_fixture_specific_metadata() -> void:
	var fixtures := _load_fixtures()
	var peg_wall := _fixture_by_id(fixtures, "fixture_accessory_peg_wall")
	var bargain_bin := _fixture_by_id(fixtures, "fixture_bargain_bin")
	var locked_case := _fixture_by_id(fixtures, "fixture_locked_case")
	var counter_rack := _fixture_by_id(fixtures, "fixture_counter_rack")
	var demo_kiosk := _fixture_by_id(fixtures, "fixture_demo_kiosk")
	var new_release_wall := _fixture_by_id(fixtures, "fixture_new_release_wall")
	var backroom_rack := _fixture_by_id(fixtures, "fixture_backroom_rack")

	assert_eq(peg_wall.get("requires_upgrade_id"), "upgrade_fixture_peg_wall")
	assert_true((peg_wall.get("accepted_product_categories") as PackedStringArray).has("accessory"))
	assert_eq(bargain_bin.get("placement_zone"), "sales_floor_center")
	assert_true((bargain_bin.get("gameplay_tags") as PackedStringArray).has("impulse_browse"))
	assert_eq(locked_case.get("default_slot_category"), "high_value")
	assert_true((locked_case.get("gameplay_tags") as PackedStringArray).has("theft_risk_placeholder"))
	assert_eq(counter_rack.get("placement_zone"), "register_counter")
	assert_true((counter_rack.get("gameplay_tags") as PackedStringArray).has("checkout_impulse"))
	assert_true(demo_kiosk.get("placeholder"))
	assert_eq(demo_kiosk.get("slot_count"), 1)
	assert_eq(new_release_wall.get("default_slot_category"), "new_release")
	assert_eq(backroom_rack.get("requires_upgrade_id"), "upgrade_backroom_storage")
	assert_eq(backroom_rack.get("placement_zone"), "backroom_storage")


func test_fixture_catalog_all_entries_are_placeable_resources() -> void:
	for fixture in _load_fixtures():
		assert_false(str(fixture.get("fixture_id")).is_empty())
		assert_false(str(fixture.get("display_name")).is_empty())
		assert_true(fixture.get("placeable"))
		assert_gt(int(fixture.get("cost_cents")), 0)
		assert_gt(int(fixture.get("slot_count")), 0)
		assert_false(str(fixture.get("placement_zone")).is_empty())
		assert_false(str(fixture.get("scene_path")).is_empty())
		assert_not_null(load(str(fixture.get("scene_path"))) as PackedScene)
		assert_gt((fixture.get("accepted_product_categories") as PackedStringArray).size(), 0)
		assert_gt((fixture.get("gameplay_tags") as PackedStringArray).size(), 0)


func _load_fixtures() -> Array[Resource]:
	var fixtures: Array[Resource] = []
	var dir := DirAccess.open(FIXTURE_DIR)
	assert_not_null(dir)
	if dir == null:
		return fixtures

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var fixture := load("%s/%s" % [FIXTURE_DIR, file_name]) as Resource
			if fixture != null:
				fixtures.append(fixture)
		file_name = dir.get_next()
	dir.list_dir_end()
	return fixtures


func _fixture_by_id(fixtures: Array[Resource], fixture_id: String) -> Resource:
	for fixture in fixtures:
		if str(fixture.get("fixture_id")) == fixture_id:
			return fixture
	return null


func _fixture_ids(fixtures: Array[Resource]) -> Array[String]:
	var ids: Array[String] = []
	for fixture in fixtures:
		ids.append(str(fixture.get("fixture_id")))
	return ids


func _unique_string_count(values: Array[String]) -> int:
	var seen := {}
	for value in values:
		seen[value] = true
	return seen.size()
