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
const APPLIED_DESIGN_NAME: StringName = &"AppliedStoreDesign"

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const StarterProductVisualResolverScript: GDScript = preload(
	"res://game/scripts/visuals/starter_product_visual_resolver.gd"
)
const GrowthLayoutSurfaceBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/growth_layout_surface_builder.gd"
)
const VisualNodeUtilScript: GDScript = preload("res://game/scripts/visuals/visual_node_util.gd")
const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")

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
var _active_design_payload: Dictionary = {}


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
	_active_design_payload = StoreCustomizationSystem.get_store_design_payload(store_id)
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
	_render_growth_contract_dressing()
	_render_design_customization()


func get_generated_fixture_count() -> int:
	_ensure_roots()
	return _fixture_root.get_child_count()


func get_generated_dressing_count() -> int:
	_ensure_roots()
	var count: int = _dressing_root.get_child_count()
	if _dressing_root.get_node_or_null(NodePath(APPLIED_DESIGN_NAME)) != null:
		count -= 1
	return count


func get_applied_design_payload() -> Dictionary:
	return _active_design_payload.duplicate(true)


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
		_apply_fixture_design_metadata(node, fixture_data)
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


func _render_growth_contract_dressing() -> void:
	if _catalog == null:
		return
	for id: StringName in layout_ids:
		if id != StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT:
			continue
		for node: Node3D in GrowthLayoutSurfaceBuilderScript.build_surfaces(
			_catalog, id, active_unlocks
		):
			_dressing_root.add_child(node)


func _render_design_customization() -> void:
	if _active_design_payload.is_empty():
		return
	var design_root := Node3D.new()
	design_root.name = APPLIED_DESIGN_NAME
	design_root.set_meta("store_id", String(store_id))
	design_root.set_meta("design_payload", _active_design_payload.duplicate(true))
	for group_name: String in [
		"surfaces",
		"lighting",
		"signage",
		"decor",
		"stockroom",
		"counter",
		"shelf",
		"register",
	]:
		var group_payload: Dictionary = _active_design_payload.get(group_name, {}) as Dictionary
		if group_payload.is_empty():
			continue
		design_root.add_child(_build_design_marker(group_name, group_payload))
	_dressing_root.add_child(design_root)


func _build_design_marker(group_name: String, group_payload: Dictionary) -> Node3D:
	var marker := MeshInstance3D.new()
	marker.name = "%sDesign" % group_name.capitalize()
	var mesh := BoxMesh.new()
	mesh.size = _marker_size(group_payload)
	marker.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = _color_from_payload(group_payload)
	marker.material_override = material
	marker.position = _marker_position(group_name)
	marker.set_meta("design_group", group_name)
	marker.set_meta("zone", str(group_payload.get("zone", "")))
	marker.set_meta("role", str(group_payload.get("role", "")))
	marker.set_meta("facing", str(group_payload.get("facing", "")))
	marker.set_meta("payload", group_payload.duplicate(true))
	return marker


func _apply_fixture_design_metadata(node: Node3D, fixture_data: Dictionary) -> void:
	var fixture_type: String = str(fixture_data.get("fixture_type", ""))
	var variant_id: String = ""
	if fixture_type == "register" or bool(fixture_data.get("is_register", false)):
		var register_payload: Dictionary = _active_design_payload.get("register", {}) as Dictionary
		variant_id = str(register_payload.get("register_style_id", ""))
	elif fixture_type == "counter":
		var counter_payload: Dictionary = _active_design_payload.get("counter", {}) as Dictionary
		variant_id = str(counter_payload.get("counter_style_id", ""))
	elif fixture_type == "wall_shelf" or fixture_type == "floor_rack":
		var shelf_payload: Dictionary = _active_design_payload.get("shelf", {}) as Dictionary
		variant_id = str(shelf_payload.get("shelf_style_id", ""))
	if variant_id.is_empty():
		return
	node.set_meta("design_variant_id", variant_id)


func _marker_size(group_payload: Dictionary) -> Vector3:
	var size: Array = group_payload.get("size", []) as Array
	if size.size() >= 2:
		return Vector3(maxf(float(size[0]), 0.25), 0.05, maxf(float(size[1]), 0.25))
	return Vector3(0.75, 0.05, 0.75)


func _marker_position(group_name: String) -> Vector3:
	var index: int = (
		[
			"surfaces",
			"lighting",
			"signage",
			"decor",
			"stockroom",
			"counter",
			"shelf",
			"register",
		]
		. find(group_name)
	)
	if index < 0:
		index = 0
	return Vector3(-5.0 + float(index) * 1.3, 0.08, -4.5)


func _color_from_payload(group_payload: Dictionary) -> Color:
	var color_values: Array = group_payload.get("color", []) as Array
	if color_values.size() >= 3:
		return Color(
			float(color_values[0]),
			float(color_values[1]),
			float(color_values[2]),
			float(color_values[3]) if color_values.size() >= 4 else 1.0
		)
	return Color(1.0, 1.0, 1.0, 1.0)


func _should_render_product_placement(placement: Dictionary) -> bool:
	var stock_state: StringName = StringName(str(placement.get("stock_state", "")))
	if String(stock_state).is_empty():
		return true
	return stock_state == StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY


func _product_visual_data_from_item_id(item_id: String) -> Dictionary:
	return StarterProductVisualResolverScript.visual_data_for_item_id(item_id)


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
	node.scale = VisualValueUtilScript.vector3_from_array(placement.get("scale", []), Vector3.ONE)


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
	if not EventBus.store_design_changed.is_connected(_on_store_design_changed):
		EventBus.store_design_changed.connect(_on_store_design_changed)


func _disconnect_eventbus() -> void:
	if EventBus.fixture_placed.is_connected(_on_fixture_placed):
		EventBus.fixture_placed.disconnect(_on_fixture_placed)
	if EventBus.fixture_removed.is_connected(_on_fixture_removed):
		EventBus.fixture_removed.disconnect(_on_fixture_removed)
	if EventBus.fixture_state_loaded.is_connected(_on_fixture_state_loaded):
		EventBus.fixture_state_loaded.disconnect(_on_fixture_state_loaded)
	if EventBus.store_upgrade_effect_applied.is_connected(_on_store_upgrade_effect_applied):
		EventBus.store_upgrade_effect_applied.disconnect(_on_store_upgrade_effect_applied)
	if EventBus.store_design_changed.is_connected(_on_store_design_changed):
		EventBus.store_design_changed.disconnect(_on_store_design_changed)


func _on_fixture_placed(_fixture_id: String, _grid_pos: Vector2i, _rotation: int) -> void:
	rebuild_visuals()


func _on_fixture_removed(_fixture_id: String, _grid_pos: Vector2i) -> void:
	rebuild_visuals()


func _on_fixture_state_loaded() -> void:
	rebuild_visuals()


func _on_store_design_changed(p_store_id: StringName, design_payload: Dictionary) -> void:
	if p_store_id != store_id:
		return
	_active_design_payload = design_payload.duplicate(true)
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
