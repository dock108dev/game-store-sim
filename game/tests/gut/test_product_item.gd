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


func test_used_game_has_readable_front_cover_label() -> void:
	var cover_mesh := _item.get_node_or_null("CoverLabelMesh") as MeshInstance3D
	assert_not_null(cover_mesh)
	assert_gt(cover_mesh.mesh.size.x, 0.3)
	assert_gt(cover_mesh.mesh.size.y, 0.4)
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


func test_product_definition_describes_retail_fields() -> void:
	var product := load("res://data/products/used_star_trader.tres") as ProductDefinition
	var description := product.describe()
	assert_string_contains(description, "Star Trader")
	assert_string_contains(description, "Orbit 64")
	assert_string_contains(description, "Good")
	assert_string_contains(description, "Market $24.99")
