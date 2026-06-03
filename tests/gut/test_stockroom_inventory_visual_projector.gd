extends GutTest

const ExpandableStoreShellRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/expandable_store_shell_runtime.gd"
)
const ProjectorScript: GDScript = preload(
	"res://game/scripts/visuals/stockroom_inventory_visual_projector.gd"
)
const STORE_ID: StringName = &"retro_games"

var _inventory: InventorySystem = null
var _projector: Node3D = null
var _saved_state: GameManager.State
var _saved_store_id: StringName


func before_each() -> void:
	_saved_state = GameManager.current_state
	_saved_store_id = GameManager.current_store_id
	GameManager.current_state = GameManager.State.STORE_VIEW
	GameManager.current_store_id = STORE_ID
	_inventory = InventorySystem.new()
	add_child(_inventory)
	_projector = ProjectorScript.new() as Node3D
	add_child(_projector)
	_projector.setup(null, _inventory, STORE_ID)


func after_each() -> void:
	if _inventory != null:
		_inventory.load_save_data({})
		if is_instance_valid(_inventory):
			_inventory.free()
	if is_instance_valid(_projector):
		_projector.free()
	_inventory = null
	_projector = null
	GameManager.current_store_id = _saved_store_id
	GameManager.current_state = _saved_state


func test_empty_stockroom_renders_stable_placeholder_state() -> void:
	assert_not_null(_projector.get_node_or_null("EmptyPickupBayMarker"))
	assert_not_null(_projector.get_node_or_null("BackroomRackEmptyMarker"))
	assert_not_null(_projector.get_node_or_null("ReserveStockEmptyMarker"))
	assert_not_null(_projector.get_node_or_null("HoldBayEmptyMarker"))
	assert_not_null(_projector.get_node_or_null("TradeInIntakeEmptyTray"))
	assert_eq(_status_count(ProjectorScript.STATUS_PICKUP_READY), 0)
	assert_eq(_snapshot_count("backroom"), 0)
	_assert_visual_only_projection(_projector)


func test_backroom_inventory_labels_group_counts_without_owning_stock() -> void:
	var game_def: ItemDefinition = _definition("byte_courier", "Byte Courier", "games")
	var console_def: ItemDefinition = _definition("deck_cube", "Deck Cube", "hardware")
	_add_item(game_def, "backroom")
	_add_item(game_def, "backroom")
	_add_item(console_def, "backroom")
	_add_item(game_def, "shelf:starter_a")
	_add_unknown_item("backroom")
	_projector.refresh()

	var snapshot: Dictionary = _projector.get_meta("stockroom_snapshot") as Dictionary
	assert_eq(int(snapshot.get("backroom", -1)), 4)
	assert_eq(int(snapshot.get("shelf", -1)), 1)
	assert_eq(int(snapshot.get("unknown", -1)), 1)
	assert_not_null(_projector.get_node_or_null("PickupReadyBox00"))
	assert_not_null(_projector.get_node_or_null("BackroomInventoryBox00"))
	var summary_text: String = _label_text("StockroomInventorySummaryLabel")
	assert_string_contains(summary_text, "Stock 4 / shelf 1")
	assert_string_contains(summary_text, "Games")
	assert_true(
		summary_text.contains("x2"),
		"Summary label must expose the top grouped inventory count"
	)
	assert_false(
		summary_text.contains("Unknown x"),
		"Summary label must not expose raw unknown debug counts in the scene"
	)
	var summary_label: Label3D = _label("StockroomInventorySummaryLabel")
	if summary_label != null:
		assert_lte(summary_label.pixel_size, 0.010)
		assert_lte(summary_label.font_size, 18)


func test_inventory_location_transition_refreshes_physical_state_from_signal() -> void:
	var def: ItemDefinition = _definition("signal_cart", "Signal Cart", "games")
	var item: ItemInstance = _add_item(def, "backroom")
	assert_eq(_snapshot_count("backroom"), 1)
	_inventory.move_item(String(item.instance_id), "shelf:signal_slot")
	assert_eq(_snapshot_count("backroom"), 0)
	assert_eq(_snapshot_count("shelf"), 1)
	assert_not_null(_projector.get_node_or_null("EmptyPickupBayMarker"))
	assert_null(_projector.get_node_or_null("PickupReadyBox00"))


func test_hold_and_trade_in_surfaces_follow_exposed_runtime_state() -> void:
	EventBus.hold_added.emit(STORE_ID, "local-hold-1", &"byte_courier", "Mira")
	assert_gt(_status_count(ProjectorScript.STATUS_HOLD), 0)
	EventBus.trade_in_initiated.emit("customer-a")
	assert_gt(_status_count(ProjectorScript.STATUS_TRADE_IN), 0)
	EventBus.trade_in_rejected.emit("customer-a")
	_projector.refresh()
	assert_eq(_snapshot_bool("trade_in_pending"), false)
	EventBus.hold_fulfilled.emit(STORE_ID, "local-hold-1", &"byte_courier", "manual")
	assert_eq(_status_count(ProjectorScript.STATUS_HOLD), 0)


func test_rebuilt_shell_rehydrates_from_inventory_not_old_visual_nodes() -> void:
	var def: ItemDefinition = _definition("reload_box", "Reload Box", "games")
	_add_item(def, "backroom")
	var shell := Node3D.new()
	add_child_autofree(shell)
	var first_projection: Node = shell.get_node_or_null("StockroomInventoryState")
	ExpandableStoreShellRuntimeScript.call("_add_stockroom_inventory_projection", null, shell)
	first_projection = shell.get_node_or_null("StockroomInventoryState")
	assert_not_null(first_projection)
	assert_not_null(first_projection.get_node_or_null("PickupReadyBox00"))
	var first_projection_id: int = first_projection.get_instance_id()

	var stocked_item: ItemInstance = _inventory.get_backroom_items_for_store(String(STORE_ID))[0]
	_inventory.move_item(String(stocked_item.instance_id), "shelf:reload_slot")
	shell.remove_child(first_projection)
	first_projection.free()
	ExpandableStoreShellRuntimeScript.call("_add_stockroom_inventory_projection", null, shell)
	var rebuilt_projection: Node = shell.get_node_or_null("StockroomInventoryState")
	assert_not_null(rebuilt_projection)
	assert_ne(rebuilt_projection.get_instance_id(), first_projection_id)
	assert_not_null(rebuilt_projection.get_node_or_null("EmptyPickupBayMarker"))
	assert_null(rebuilt_projection.get_node_or_null("PickupReadyBox00"))


func test_projected_props_stay_inside_stockroom_room_contract() -> void:
	_add_item(_definition("bounded_cart", "Bounded Cart", "games"), "backroom")
	_projector.refresh()
	var room_min := Vector3(1.25, 0.0, -9.95)
	var room_max := Vector3(7.50, 2.8, 1.25)
	for child: Node in _projector.get_children():
		if not child is Node3D:
			continue
		var node := child as Node3D
		assert_between(node.position.x, room_min.x, room_max.x, "%s x bounds" % node.name)
		assert_between(node.position.y, room_min.y, room_max.y, "%s y bounds" % node.name)
		assert_between(node.position.z, room_min.z, room_max.z, "%s z bounds" % node.name)
	_assert_visual_only_projection(_projector)


func _definition(id: String, display_name: String, category: String) -> ItemDefinition:
	var def := ItemDefinition.new()
	def.id = id
	def.item_name = display_name
	def.category = category
	def.store_type = STORE_ID
	def.base_price = 10.0
	def.rarity = "common"
	return def


func _add_item(def: ItemDefinition, location: String) -> ItemInstance:
	var item: ItemInstance = ItemInstance.create(def, "good", 0, def.base_price)
	item.current_location = location
	_inventory.add_item(STORE_ID, item)
	return item


func _add_unknown_item(location: String) -> ItemInstance:
	var item := ItemInstance.new()
	item.instance_id = "unknown_%d" % _inventory.get_item_count()
	item.current_location = location
	_inventory.add_item(STORE_ID, item)
	return item


func _snapshot_count(key: String) -> int:
	var snapshot: Dictionary = _projector.get_meta("stockroom_snapshot") as Dictionary
	return int(snapshot.get(key, -1))


func _snapshot_bool(key: String) -> bool:
	var snapshot: Dictionary = _projector.get_meta("stockroom_snapshot") as Dictionary
	return bool(snapshot.get(key, false))


func _status_count(status: StringName) -> int:
	var count: int = 0
	for node: Node in _projector.find_children("*", "MeshInstance3D", true, false):
		if node.get_meta("stockroom_inventory_status", &"") == status:
			count += 1
	return count


func _label_text(path: String) -> String:
	var label_root: Node = _projector.get_node_or_null(path)
	assert_not_null(label_root, "%s must exist" % path)
	if label_root == null:
		return ""
	var label: Label3D = label_root.get_node_or_null("LabelText") as Label3D
	assert_not_null(label, "%s must expose LabelText" % path)
	if label == null:
		return ""
	return label.text


func _label(path: String) -> Label3D:
	var label_root: Node = _projector.get_node_or_null(path)
	assert_not_null(label_root, "%s must exist" % path)
	if label_root == null:
		return null
	var label: Label3D = label_root.get_node_or_null("LabelText") as Label3D
	assert_not_null(label, "%s must expose LabelText" % path)
	return label


func _assert_visual_only_projection(root: Node) -> void:
	for child: Node in root.get_children():
		assert_false(_has_gameplay_node(child), "%s must stay visual-only" % child.name)


func _has_gameplay_node(root: Node) -> bool:
	if (
		root is Area3D
		or root is CollisionObject3D
		or root is CollisionShape3D
		or root is PhysicsBody3D
		or root is NavigationObstacle3D
		or root is Interactable
	):
		return true
	for child: Node in root.get_children():
		if _has_gameplay_node(child):
			return true
	return false
