extends GutTest

const RELEASE_DIR := "res://data/releases"
const EXPECTED_RELEASE_COUNT := 9


func test_new_release_resource_has_calendar_data() -> void:
	var release: Resource = load("res://data/releases/neon_skyline_launch.tres")

	assert_not_null(release)
	assert_eq(release.get("release_id"), "release_neon_skyline")
	assert_eq(release.get("product_name"), "Neon Skyline")
	assert_eq(release.get("platform"), "Orbit 64")
	assert_eq(release.get("category"), "new_game")
	assert_eq(release.get("release_day"), 3)
	assert_eq(release.get("wholesale_cost_cents"), 3200)
	assert_eq(release.get("suggested_price_cents"), 4999)
	assert_eq(release.get("allocation_limit"), 4)
	assert_eq(release.get("demand_tier"), "high")
	assert_string_contains(str(release.get("tagline")), "Street-racing")
	assert_string_contains(str(release.get("buyer_hook")), "Collectors")
	assert_string_contains(str(release.get("allocation_note")), "Reserve")


func test_new_release_formats_countdown_lines() -> void:
	var release: Resource = load("res://data/releases/neon_skyline_launch.tres")

	assert_eq(release.call("days_until", 1), 2)
	assert_string_contains(release.call("format_calendar_line", 1), "Day 3 (in 2 days): Neon Skyline")
	assert_string_contains(release.call("format_calendar_line", 2), "Day 3 (tomorrow): Neon Skyline")
	assert_string_contains(release.call("format_calendar_line", 3), "Day 3 (today): Neon Skyline")
	assert_string_contains(release.call("format_calendar_line", 4), "Day 3 (released): Neon Skyline")
	assert_string_contains(release.call("format_calendar_line", 1), "cost $32.00")
	assert_string_contains(release.call("format_calendar_line", 1), "MSRP $49.99")
	assert_string_contains(release.call("format_calendar_line", 1), "allocation 4")
	assert_string_contains(release.call("format_calendar_line", 1), "Collectors and regulars")
	assert_string_contains(release.call("format_planning_line", 1), "Street-racing sequel")
	assert_string_contains(release.call("format_planning_line", 1), "Reserve at least one copy")


func test_release_calendar_has_full_first_catalog_coverage() -> void:
	var releases := _load_releases()
	var release_ids := {}
	var product_names := {}
	var platforms := {}
	var demand_tiers := {}

	assert_gte(releases.size(), EXPECTED_RELEASE_COUNT)
	for release in releases:
		var release_id := str(release.get("release_id"))
		var product_name := str(release.get("product_name"))
		assert_false(release_ids.has(release_id), "Duplicate release_id: %s" % release_id)
		release_ids[release_id] = true
		product_names[product_name] = true
		platforms[str(release.get("platform"))] = true
		demand_tiers[str(release.get("demand_tier"))] = true
		assert_eq(str(release.get("category")), "new_game")
		assert_gt(int(release.get("release_day")), 0)
		assert_gt(int(release.get("wholesale_cost_cents")), 0)
		assert_gt(int(release.get("suggested_price_cents")), 0)
		assert_gt(int(release.get("allocation_limit")), 0)
		assert_false(str(release.get("tagline")).strip_edges().is_empty())
		assert_false(str(release.get("buyer_hook")).strip_edges().is_empty())
		assert_false(str(release.get("allocation_note")).strip_edges().is_empty())

	assert_true(platforms.has("Nova Cube"))
	assert_true(platforms.has("Orbit 64"))
	assert_true(platforms.has("Pocket Star"))
	assert_true(demand_tiers.has("medium"))
	assert_true(demand_tiers.has("high"))
	assert_true(product_names.has("Moonlight Menders"))
	assert_true(product_names.has("Velvet Voltage"))


func _load_releases() -> Array[Resource]:
	var releases: Array[Resource] = []
	var dir := DirAccess.open(RELEASE_DIR)
	assert_not_null(dir)
	if dir == null:
		return releases

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var release := load("%s/%s" % [RELEASE_DIR, file_name]) as Resource
			if release != null:
				releases.append(release)
		file_name = dir.get_next()
	dir.list_dir_end()
	return releases
