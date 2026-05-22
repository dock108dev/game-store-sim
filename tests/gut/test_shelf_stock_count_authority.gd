## Verifies shelf stock counts come from inventory state, not visual dressing.
extends GutTest


const _HudScene: PackedScene = preload("res://game/scenes/ui/hud.tscn")


func test_hud_ignores_static_product_display_nodes() -> void:
	var pair: Array = _make_hud_with_inventory()
	var hud: CanvasLayer = pair[0] as CanvasLayer
	var display_root := Node3D.new()
	display_root.name = "ProductDisplayRows"
	add_child_autofree(display_root)
	for i: int in range(4):
		var prop := MeshInstance3D.new()
		prop.name = "StaticProductDisplay%d" % i
		prop.add_to_group("product_display")
		display_root.add_child(prop)

	EventBus.inventory_changed.emit()

	assert_eq(
		hud._items_placed_count,
		0,
		"HUD shelf count must ignore static product_display dressing"
	)


func test_hud_counts_inventory_shelf_locations() -> void:
	var pair: Array = _make_hud_with_inventory()
	var hud: CanvasLayer = pair[0] as CanvasLayer
	var inventory: InventorySystem = pair[1] as InventorySystem
	var item: ItemInstance = _make_counted_item()

	inventory.add_item(&"retro_games", item)
	inventory.assign_to_shelf(&"retro_games", item.instance_id, &"count_slot")

	assert_eq(
		hud._items_placed_count,
		1,
		"HUD shelf count must reconcile from inventory shelf locations"
	)


func test_hud_shelf_count_decrements_when_inventory_item_leaves_shelf() -> void:
	var pair: Array = _make_hud_with_inventory()
	var hud: CanvasLayer = pair[0] as CanvasLayer
	var inventory: InventorySystem = pair[1] as InventorySystem
	var item: ItemInstance = _make_counted_item()

	inventory.add_item(&"retro_games", item)
	inventory.assign_to_shelf(&"retro_games", item.instance_id, &"count_slot")
	assert_eq(hud._items_placed_count, 1, "Precondition: HUD counted shelf item")

	inventory.move_item(item.instance_id, "backroom")

	assert_eq(
		hud._items_placed_count,
		0,
		"HUD shelf count must drop when inventory no longer reports a shelf item"
	)


func _make_hud_with_inventory() -> Array:
	var hud: CanvasLayer = _HudScene.instantiate()
	add_child_autofree(hud)
	var inventory := InventorySystem.new()
	inventory.name = "InventorySystem"
	add_child_autofree(inventory)
	return [hud, inventory]


func _make_counted_item() -> ItemInstance:
	var def := ItemDefinition.new()
	def.id = "counted_shelf_item"
	def.item_name = "Counted Shelf Item"
	def.category = "cartridges"
	def.base_price = 10.0
	def.store_type = "retro_games"
	var item: ItemInstance = ItemInstance.create(def, "good", 0, def.base_price)
	item.current_location = "backroom"
	return item
