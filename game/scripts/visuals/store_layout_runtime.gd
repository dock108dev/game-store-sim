## Runtime owner for generated store fixture visuals.
##
## The authored store scene should be the shell: walls, floor, lighting,
## player/nav anchors, and controllers. This node turns store layout data plus
## FixturePlacementSystem state into the shelves/counter/stockroom visuals the
## player actually owns.
class_name StoreLayoutRuntime
extends Node3D

const DEFAULT_STORE_ID: StringName = &"retro_games"
const GENERATED_FIXTURES_NAME: StringName = &"GeneratedFixtures"
const GENERATED_DRESSING_NAME: StringName = &"GeneratedDressing"

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const VisualNodeUtilScript: GDScript = preload("res://game/scripts/visuals/visual_node_util.gd")
const VisualValueUtilScript: GDScript = preload(
	"res://game/scripts/visuals/visual_value_util.gd"
)

const _FIXTURE_TYPE_VISUALS: Dictionary = {
	"wall_shelf": StoreVisualKitScript.WALL_SHELF,
	"display_table": StoreVisualKitScript.DISPLAY_TABLE,
	"counter": StoreVisualKitScript.CHECKOUT_COUNTER,
	"register": StoreVisualKitScript.REGISTER,
	"storage_unit": StoreVisualKitScript.STOCKROOM_TABLE,
	"floor_rack": StoreVisualKitScript.FLOOR_RACK,
}

var store_id: StringName = DEFAULT_STORE_ID
var layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
var layout_ids: Array[StringName] = []
var active_unlocks: Array[StringName] = []
var seed_when_empty: bool = true

var _placement_system: FixturePlacementSystem = null
var _grid: BuildModeGrid = null
var _catalog: RefCounted = null
var _fixture_root: Node3D = null
var _dressing_root: Node3D = null
var _layout_placements_by_fixture_id: Dictionary = {}


func _exit_tree() -> void:
	_disconnect_eventbus()


func initialize(
	placement_system: FixturePlacementSystem,
	grid: BuildModeGrid,
	p_store_id: StringName = DEFAULT_STORE_ID,
	p_layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
	p_active_unlocks: Array[StringName] = []
) -> void:
	_placement_system = placement_system
	_grid = grid
	store_id = p_store_id
	layout_id = p_layout_id
	layout_ids = _default_layout_ids(p_store_id, p_layout_id)
	active_unlocks = p_active_unlocks.duplicate()
	_catalog = StoreVisualLayoutScript.load_default()
	_rebuild_layout_lookup()
	_ensure_roots()
	if seed_when_empty:
		seed_starter_fixtures_if_empty()
	rebuild_visuals()
	_connect_eventbus()


func seed_starter_fixtures_if_empty() -> int:
	if _placement_system == null:
		return 0
	if not _placement_system.get_placed_fixtures().is_empty():
		return 0
	var seeded: int = 0
	for placement: Dictionary in _layout_placements():
		if not bool(placement.get("starter_owned", false)):
			continue
		if bool(placement.get("visual_only", false)):
			continue
		var fixture_type: String = str(placement.get("fixture_type", ""))
		var fixture_id: String = str(placement.get("fixture_id", ""))
		if fixture_type.is_empty() or fixture_id.is_empty():
			continue
		var grid_pos: Vector2i = VisualValueUtilScript.vector2i_from_array(
			placement.get("grid_position", []), Vector2i.ZERO
		)
		var rotation: int = int(placement.get("fixture_rotation", 0))
		var is_register: bool = bool(placement.get("is_register", false))
		var price: float = float(placement.get("purchase_price", 0.0))
		(
			_placement_system
			. register_existing_fixture(
				fixture_id,
				fixture_type,
				grid_pos,
				rotation,
				is_register,
				price,
			)
		)
		seeded += 1
	return seeded


func rebuild_visuals() -> void:
	_ensure_roots()
	VisualNodeUtilScript.clear_children(_fixture_root)
	VisualNodeUtilScript.clear_children(_dressing_root)
	_render_placed_fixtures()
	_render_layout_dressing()


func get_generated_fixture_count() -> int:
	_ensure_roots()
	return _fixture_root.get_child_count()


func get_generated_dressing_count() -> int:
	_ensure_roots()
	return _dressing_root.get_child_count()


func _render_placed_fixtures() -> void:
	if _placement_system == null:
		return
	for fixture_data: Dictionary in _placement_system.get_placed_fixtures():
		var fixture_id: String = str(fixture_data.get("fixture_id", ""))
		var placement: Dictionary = _layout_placements_by_fixture_id.get(fixture_id, {})
		var visual_id: StringName = _visual_id_for_fixture(fixture_data, placement)
		var node: Node3D = StoreVisualKitScript.instantiate(visual_id) as Node3D
		if node == null:
			continue
		node.name = fixture_id
		node.set_meta("fixture_id", fixture_id)
		node.set_meta("fixture_type", str(fixture_data.get("fixture_type", "")))
		node.set_meta("visual_id", visual_id)
		if placement.is_empty():
			_apply_grid_transform(node, fixture_data)
		else:
			_apply_layout_transform(node, placement)
		_fixture_root.add_child(node)


func _render_layout_dressing() -> void:
	for placement: Dictionary in _layout_placements():
		if (
			not str(placement.get("fixture_type", "")).is_empty()
			and not bool(placement.get("visual_only", false))
		):
			continue
		var product_item_id: String = str(placement.get("product_item_id", ""))
		if not product_item_id.is_empty():
			if _should_render_product_placement(placement):
				_render_product_dressing(placement, product_item_id)
			continue
		var visual_id: StringName = StringName(str(placement.get("visual_id", "")))
		var node: Node3D = StoreVisualKitScript.instantiate(visual_id) as Node3D
		if node == null:
			continue
		node.name = str(placement.get("name", String(visual_id)))
		node.set_meta("visual_id", visual_id)
		node.set_meta("zone", str(placement.get("zone", "")))
		var fixture_id: String = str(placement.get("fixture_id", ""))
		if not fixture_id.is_empty():
			node.set_meta("fixture_id", fixture_id)
		if bool(placement.get("visual_only", false)):
			node.set_meta("visual_only", true)
		_apply_layout_transform(node, placement)
		_dressing_root.add_child(node)


func _render_product_dressing(placement: Dictionary, product_item_id: String) -> void:
	var item_data: Dictionary = _product_visual_data_from_item_id(product_item_id)
	item_data["route_role"] = str(placement.get("route_role", "starter_sale_item"))
	item_data["stock_state"] = str(placement.get("stock_state", "available"))
	item_data["show_price_tag"] = bool(placement.get("show_price_tag", false))
	var node: Node3D = ProductVisualFactoryScript.create_visual_for_item(item_data)
	if node == null:
		return
	node.name = str(placement.get("name", product_item_id))
	node.set_meta("product_item_id", product_item_id)
	node.set_meta("visual_source", "product_visual_factory")
	node.set_meta("zone", str(placement.get("zone", "")))
	if placement.has("delivery_index"):
		node.set_meta("delivery_index", int(placement.get("delivery_index", -1)))
	node.add_to_group("product_display")
	_apply_layout_transform(node, placement)
	_dressing_root.add_child(node)


func _should_render_product_placement(placement: Dictionary) -> bool:
	var stock_state: StringName = StringName(str(placement.get("stock_state", "")))
	if String(stock_state).is_empty():
		return true
	return stock_state == StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY


func _product_visual_data_from_item_id(item_id: String) -> Dictionary:
	var definition: ItemDefinition = null
	if GameManager.data_loader:
		definition = GameManager.data_loader.get_item(item_id)
	if definition:
		return _product_visual_data_from_definition(definition)
	var entry: Dictionary = ContentRegistry.get_entry(StringName(item_id))
	if entry.is_empty():
		return {}
	return _product_visual_data_from_entry(item_id, entry)


func _product_visual_data_from_definition(definition: ItemDefinition) -> Dictionary:
	var data: Dictionary = {
		"definition_id": definition.id,
		"display_name": definition.item_name,
		"category": String(definition.category),
		"platform_id": String(definition.platform_id),
		"price_cents": int(round(definition.used_price * 100.0)),
	}
	if definition.extra is Dictionary:
		for key: String in [
			"box_art_key",
			"platform_visual_id",
			"visual_alias_id",
			"visual_presentation",
		]:
			if definition.extra.has(key):
				data[key] = definition.extra[key]
	return data


func _product_visual_data_from_entry(item_id: String, entry: Dictionary) -> Dictionary:
	var data: Dictionary = {
		"definition_id": str(entry.get("id", item_id)),
		"display_name": str(entry.get("item_name", item_id)),
		"category": str(entry.get("category", "")),
		"platform_id": str(entry.get("platform_id", "")),
		"price_cents": int(round(float(entry.get("used_price", entry.get("base_price", 0.0))) * 100.0)),
	}
	for key: String in [
		"box_art_key",
		"platform_visual_id",
		"visual_alias_id",
		"visual_presentation",
	]:
		if entry.has(key):
			data[key] = entry[key]
	return data


func _visual_id_for_fixture(fixture_data: Dictionary, placement: Dictionary) -> StringName:
	if not placement.is_empty():
		var visual_id: StringName = StringName(str(placement.get("visual_id", "")))
		if not String(visual_id).is_empty():
			return visual_id
	var fixture_type: String = str(fixture_data.get("fixture_type", ""))
	return _FIXTURE_TYPE_VISUALS.get(fixture_type, StoreVisualKitScript.STOCK_BOX)


func _apply_layout_transform(node: Node3D, placement: Dictionary) -> void:
	node.position = VisualValueUtilScript.vector3_from_array(
		placement.get("position", []), Vector3.ZERO
	)
	node.rotation_degrees = VisualValueUtilScript.vector3_from_array(
		placement.get("rotation_degrees", []), Vector3.ZERO
	)
	node.scale = VisualValueUtilScript.vector3_from_array(
		placement.get("scale", []), Vector3.ONE
	)


func _apply_grid_transform(node: Node3D, fixture_data: Dictionary) -> void:
	var grid_pos: Vector2i = fixture_data.get("grid_position", Vector2i.ZERO) as Vector2i
	if _grid != null:
		node.position = _grid.grid_to_world(grid_pos)
	else:
		node.position = Vector3(float(grid_pos.x), 0.0, float(grid_pos.y))
	node.rotation_degrees = Vector3(0.0, float(int(fixture_data.get("rotation", 0))) * 90.0, 0.0)


func _layout_placements() -> Array[Dictionary]:
	if _catalog == null:
		return []
	var placements: Array[Dictionary] = []
	for id: StringName in layout_ids:
		var layout_placements: Array[Dictionary] = (
			_catalog.call("get_placements", id, active_unlocks) as Array[Dictionary]
		)
		placements.append_array(layout_placements)
	return placements


func _rebuild_layout_lookup() -> void:
	_layout_placements_by_fixture_id.clear()
	for placement: Dictionary in _layout_placements():
		var fixture_id: String = str(placement.get("fixture_id", ""))
		if not fixture_id.is_empty():
			_layout_placements_by_fixture_id[fixture_id] = placement


func _ensure_roots() -> void:
	_fixture_root = get_node_or_null(NodePath(GENERATED_FIXTURES_NAME)) as Node3D
	if _fixture_root == null:
		_fixture_root = Node3D.new()
		_fixture_root.name = GENERATED_FIXTURES_NAME
		add_child(_fixture_root)
	_dressing_root = get_node_or_null(NodePath(GENERATED_DRESSING_NAME)) as Node3D
	if _dressing_root == null:
		_dressing_root = Node3D.new()
		_dressing_root.name = GENERATED_DRESSING_NAME
		add_child(_dressing_root)


func _connect_eventbus() -> void:
	if not EventBus.fixture_placed.is_connected(_on_fixture_placed):
		EventBus.fixture_placed.connect(_on_fixture_placed)
	if not EventBus.fixture_removed.is_connected(_on_fixture_removed):
		EventBus.fixture_removed.connect(_on_fixture_removed)
	if not EventBus.fixture_state_loaded.is_connected(_on_fixture_state_loaded):
		EventBus.fixture_state_loaded.connect(_on_fixture_state_loaded)
	if not EventBus.store_upgrade_effect_applied.is_connected(_on_store_upgrade_effect_applied):
		EventBus.store_upgrade_effect_applied.connect(_on_store_upgrade_effect_applied)


func _disconnect_eventbus() -> void:
	if EventBus.fixture_placed.is_connected(_on_fixture_placed):
		EventBus.fixture_placed.disconnect(_on_fixture_placed)
	if EventBus.fixture_removed.is_connected(_on_fixture_removed):
		EventBus.fixture_removed.disconnect(_on_fixture_removed)
	if EventBus.fixture_state_loaded.is_connected(_on_fixture_state_loaded):
		EventBus.fixture_state_loaded.disconnect(_on_fixture_state_loaded)
	if EventBus.store_upgrade_effect_applied.is_connected(_on_store_upgrade_effect_applied):
		EventBus.store_upgrade_effect_applied.disconnect(_on_store_upgrade_effect_applied)


func _on_fixture_placed(_fixture_id: String, _grid_pos: Vector2i, _rotation: int) -> void:
	rebuild_visuals()


func _on_fixture_removed(_fixture_id: String, _grid_pos: Vector2i) -> void:
	rebuild_visuals()


func _on_fixture_state_loaded() -> void:
	rebuild_visuals()


func _on_store_upgrade_effect_applied(
	p_store_id: StringName, upgrade_id: String, _effect_type: String, _effect_value: float
) -> void:
	if p_store_id != store_id:
		return
	var unlock_id: StringName = StringName("upgrade:%s" % upgrade_id)
	if not active_unlocks.has(unlock_id):
		active_unlocks.append(unlock_id)
	rebuild_visuals()


func _default_layout_ids(p_store_id: StringName, p_layout_id: StringName) -> Array[StringName]:
	var ids: Array[StringName] = [p_layout_id]
	if (
		p_store_id == DEFAULT_STORE_ID
		and p_layout_id == StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	):
		ids.append(StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT)
	return ids
