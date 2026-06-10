extends GutTest


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
