extends GutTest

const StoreAmbienceScript := preload("res://scripts/systems/store_ambience.gd")


func test_store_ambience_catalog_covers_stop_11_1_layers() -> void:
	var ambience: Node = StoreAmbienceScript.new()
	add_child_autofree(ambience)

	var ids: Array = ambience.call("get_ambience_ids")
	var catalog: Array = ambience.call("get_ambience_catalog")
	assert_true(ambience.call("has_required_ambience"))
	assert_eq(catalog.size(), 7)
	assert_true(ids.has("room_tone"))
	assert_true(ids.has("hvac"))
	assert_true(ids.has("street_muffle"))
	assert_true(ids.has("door_chime"))
	assert_true(ids.has("register_area"))
	assert_true(ids.has("backroom"))
	assert_true(ids.has("closing_quiet"))


func test_store_ambience_uses_conservative_mix_levels() -> void:
	var ambience: Node = StoreAmbienceScript.new()
	add_child_autofree(ambience)

	var catalog: Array = ambience.call("get_ambience_catalog")
	for entry in catalog:
		assert_lte(float(entry.get("volume_db", 0.0)), -18.0, str(entry.get("id", "")))
		assert_gte(float(entry.get("max_distance", 0.0)), 4.5, str(entry.get("id", "")))


func test_graybox_store_contains_configured_ambience_players() -> void:
	var scene: Node = load("res://scenes/world/graybox_store.tscn").instantiate()
	add_child_autofree(scene)
	var ambience: Node = scene.get_node("StoreAmbience")

	assert_true(ambience.call("has_required_ambience"))
	var catalog: Array = ambience.call("get_ambience_catalog")
	for entry in catalog:
		var player := ambience.get_node(str(entry.get("player_path", ""))) as AudioStreamPlayer3D
		assert_not_null(player, str(entry.get("id", "")))
		assert_not_null(player.stream, str(entry.get("id", "")))
		assert_lte(player.volume_db, -18.0, str(entry.get("id", "")))
		assert_false(player.autoplay, str(entry.get("id", "")))


func test_store_ambience_summary_names_store_zones() -> void:
	var ambience: Node = StoreAmbienceScript.new()
	add_child_autofree(ambience)

	var summary: String = ambience.call("get_ambience_summary_text")
	assert_string_contains(summary, "Store ambience baseline:")
	assert_string_contains(summary, "Room tone")
	assert_string_contains(summary, "HVAC")
	assert_string_contains(summary, "Street muffle")
	assert_string_contains(summary, "Door chime")
	assert_string_contains(summary, "Register area ambience")
	assert_string_contains(summary, "Backroom ambience")
	assert_string_contains(summary, "Closing quiet")
