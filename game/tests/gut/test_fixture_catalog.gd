extends GutTest

const FIXTURE_DIR := "res://data/fixtures"


func test_fixture_catalog_contains_game_display_rack() -> void:
	var fixtures := _load_fixtures()

	assert_eq(fixtures.size(), 1)
	var fixture := fixtures[0]
	assert_eq(fixture.get("fixture_id"), "fixture_game_display_rack")
	assert_eq(fixture.get("display_name"), "Game Display Rack")
	assert_eq(fixture.get("category"), "display")
	assert_eq(fixture.get("default_slot_category"), "used_game")
	assert_eq(fixture.get("cost_cents"), 12500)
	assert_eq(fixture.get("scene_path"), "res://scenes/props/placeholder_shelf.tscn")
	assert_true(fixture.get("placeable"))
	assert_gt((fixture.get("footprint_size") as Vector2).x, 0.0)
	assert_gt((fixture.get("footprint_size") as Vector2).y, 0.0)
	assert_not_null(load(str(fixture.get("scene_path"))) as PackedScene)
	assert_string_contains(fixture.call("describe"), "Game Display Rack")
	assert_string_contains(fixture.call("describe"), "$125.00")


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
