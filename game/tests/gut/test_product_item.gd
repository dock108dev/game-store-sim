extends GutTest

var _item: Node


func before_each() -> void:
	_item = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(_item)


func test_used_game_item_has_product_data() -> void:
	assert_not_null(_item.product)
	assert_eq(_item.product.product_id, "used_star_trader")
	assert_eq(_item.product.display_name, "Star Trader")
	assert_eq(_item.product.platform, "Orbit 64")
	assert_eq(_item.product.condition, "good")
	assert_eq(_item.product.market_value_cents, 2499)
	assert_true(_item.product.player_priceable)


func test_used_game_item_initializes_price() -> void:
	assert_eq(_item.current_price_cents, 2199)


func test_used_game_item_has_location() -> void:
	assert_eq(_item.location_id, "receiving_box_001")


func test_used_game_mesh_sits_on_node_origin() -> void:
	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	var collision_shape := _item.get_node("CollisionShape3D") as CollisionShape3D

	assert_almost_eq(case_mesh.position.y - (case_mesh.mesh.size.y / 2.0), 0.0, 0.001)
	assert_almost_eq(collision_shape.position.y - (collision_shape.shape.size.y / 2.0), 0.0, 0.001)


func test_used_game_is_upright_display_case() -> void:
	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	assert_gt(case_mesh.mesh.size.y, case_mesh.mesh.size.x)
	assert_gt(case_mesh.mesh.size.y, case_mesh.mesh.size.z * 5.0)


func test_used_game_case_is_compact_for_display_racks() -> void:
	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	var collision_shape := _item.get_node("CollisionShape3D") as CollisionShape3D

	assert_lte(case_mesh.mesh.size.x, 0.34)
	assert_lte(case_mesh.mesh.size.y, 0.46)
	assert_lte(case_mesh.mesh.size.z, 0.05)
	assert_lte(collision_shape.shape.size.x, 0.36)
	assert_lte(collision_shape.shape.size.y, 0.48)
	assert_lte(collision_shape.shape.size.z, 0.065)


func test_used_game_has_readable_front_cover_label() -> void:
	var cover_mesh := _item.get_node_or_null("CoverLabelMesh") as MeshInstance3D
	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	assert_not_null(cover_mesh)
	assert_gt(cover_mesh.mesh.size.x, 0.2)
	assert_gt(cover_mesh.mesh.size.y, 0.28)
	assert_lt(cover_mesh.mesh.size.x, case_mesh.mesh.size.x)
	assert_lt(cover_mesh.mesh.size.y, case_mesh.mesh.size.y)
	assert_lt(cover_mesh.mesh.size.z, 0.02)


func test_used_game_prompt_uses_product_name() -> void:
	assert_eq(_item.get_interaction_prompt(), "E Inspect Star Trader")


func test_used_game_inspect_text_is_product_backed() -> void:
	var text: String = _item.interact()
	assert_string_contains(text, "Star Trader")
	assert_string_contains(text, "Orbit 64")
	assert_string_contains(text, "Market $24.99")
	assert_string_contains(text, "Price $21.99")
	assert_string_contains(text, "receiving_box_001")
	assert_string_contains(text, "Serial untracked")


func test_used_game_can_enter_held_state() -> void:
	_item.set_held()

	var collision_shape := _item.get_node("CollisionShape3D") as CollisionShape3D
	assert_eq(_item.location_id, "held")
	assert_eq(_item.collision_layer, 0)
	assert_eq(_item.collision_mask, 0)
	assert_true(collision_shape.disabled)


func test_used_game_can_enter_stocked_state() -> void:
	_item.set_held()
	_item.set_stocked("shelf_slot_001")

	var collision_shape := _item.get_node("CollisionShape3D") as CollisionShape3D
	assert_eq(_item.location_id, "shelf_slot_001")
	assert_gt(_item.collision_layer, 0)
	assert_gt(_item.collision_mask, 0)
	assert_false(collision_shape.disabled)


func test_product_item_serial_defaults_to_untracked() -> void:
	var log := Node.new()
	add_child_autofree(log)

	assert_false(_item.has_serial_mismatch())
	assert_eq(_item.get_serial_status_text(), "Serial untracked")
	assert_eq(_item.flag_serial_mismatch(log), {})


func test_product_item_detects_matching_serial() -> void:
	_item.serial_id = "GST-001"
	_item.expected_serial_id = "GST-001"

	assert_false(_item.has_serial_mismatch())
	assert_eq(_item.get_serial_status_text(), "Serial GST-001")


func test_product_item_detects_mismatched_serial() -> void:
	_item.serial_id = "GST-1047"
	_item.expected_serial_id = "GST-003"

	assert_true(_item.has_serial_mismatch())
	assert_eq(_item.get_serial_status_text(), "Serial mismatch GST-1047 expected GST-003")
	assert_string_contains(_item.interact(), "Serial mismatch GST-1047 expected GST-003")


func test_product_item_flags_serial_mismatch_event() -> void:
	var log: Node = load("res://scripts/narrative/suspicious_event_log.gd").new()
	add_child_autofree(log)
	_item.instance_id = "item_used_star_trader_003"
	_item.serial_id = "GST-1047"
	_item.expected_serial_id = "GST-003"
	_item.suspicious_event_id = "serial_mismatch_item_used_star_trader_003"

	var event: Dictionary = _item.flag_serial_mismatch(log)

	assert_eq(event.get("event_id"), "serial_mismatch_item_used_star_trader_003")
	assert_eq(event.get("title"), "Mismatched serial for Star Trader")
	assert_eq(event.get("source"), "inventory")
	assert_eq(event.get("severity"), "medium")
	assert_eq(event.get("metadata").get("instance_id"), "item_used_star_trader_003")
	assert_eq(event.get("metadata").get("product_id"), "used_star_trader")
	assert_eq(event.get("metadata").get("serial_id"), "GST-1047")
	assert_eq(event.get("metadata").get("expected_serial_id"), "GST-003")
	assert_true(log.has_event("serial_mismatch_item_used_star_trader_003"))


func test_product_definition_describes_retail_fields() -> void:
	var product := load("res://data/products/used_star_trader.tres") as ProductDefinition
	var description := product.describe()
	assert_string_contains(description, "Star Trader")
	assert_string_contains(description, "Orbit 64")
	assert_string_contains(description, "Good")
	assert_string_contains(description, "Market $24.99")
