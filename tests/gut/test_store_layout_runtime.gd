extends GutTest

const StoreLayoutRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/store_layout_runtime.gd"
)
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const GrowthLayoutSurfaceBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/growth_layout_surface_builder.gd"
)
const VisualValueUtilScript: GDScript = preload(
	"res://game/scripts/visuals/visual_value_util.gd"
)

const STARTER_DRESSING_COUNT := 12
const PRODUCT_DRESSING_COUNT := 3
const GROWTH_DRESSING_COUNT := 8
const GROWTH_CONTRACT_SURFACE_COUNT := 7

var _parent: Node3D
var _data_loader: DataLoader
var _previous_data_loader: DataLoader
var _content_registry_was_cleared: bool = false
var _grid: BuildModeGrid
var _placement: FixturePlacementSystem
var _runtime: Node


func before_each() -> void:
	StoreCustomizationSystem.reset_for_testing()
	_parent = Node3D.new()
	add_child(_parent)
	_previous_data_loader = GameManager.data_loader
	_content_registry_was_cleared = false
	_data_loader = DataLoader.new()
	add_child(_data_loader)
	_data_loader.load_all_content()
	GameManager.data_loader = _data_loader
	_grid = BuildModeGrid.new()
	_parent.add_child(_grid)
	_grid.initialize(BuildModeGrid.StoreSize.SMALL, Vector3.ZERO)
	_placement = FixturePlacementSystem.new()
	_parent.add_child(_placement)
	_placement.initialize(_grid, null, null, _grid.grid_size.y - 2, BuildModeGrid.StoreSize.SMALL)
	_placement.set_data_loader(_data_loader)
	_runtime = StoreLayoutRuntimeScript.new()
	_parent.add_child(_runtime)


func after_each() -> void:
	StoreCustomizationSystem.reset_for_testing()
	_parent.free()
	if is_instance_valid(_data_loader):
		_data_loader.free()
	if _content_registry_was_cleared:
		DataLoaderSingleton.load_all_content()
	if is_instance_valid(_previous_data_loader):
		GameManager.data_loader = _previous_data_loader
	else:
		GameManager.data_loader = null


func test_runtime_seeds_sparse_starter_fixtures_when_placement_is_empty() -> void:
	_runtime.call("initialize", _placement, _grid)

	var placed: Array[Dictionary] = _placement.get_placed_fixtures()
	assert_eq(placed.size(), 2)
	assert_eq(_runtime.call("get_generated_fixture_count"), 2)
	assert_eq(_runtime.call("get_generated_dressing_count"), STARTER_DRESSING_COUNT)
	assert_true(
		_placement.validate_register_exists().valid,
		"Starter counter should register as the checkout-required fixture"
	)


func test_runtime_does_not_reseed_when_saved_fixture_state_exists() -> void:
	(
		_placement
		. register_existing_fixture(
			"saved_fixture",
			"storage_unit",
			Vector2i(9, 4),
			0,
			false,
			0.0,
		)
	)
	_runtime.call("initialize", _placement, _grid)

	var placed: Array[Dictionary] = _placement.get_placed_fixtures()
	assert_eq(placed.size(), 1)
	assert_eq(str(placed[0].get("fixture_id", "")), "saved_fixture")
	assert_eq(_runtime.call("get_generated_fixture_count"), 1)
	assert_eq(_runtime.call("get_generated_dressing_count"), STARTER_DRESSING_COUNT)


func test_runtime_renders_saved_wall_shelf_with_polished_fixture_language() -> void:
	(
		_placement
		. register_existing_fixture(
			"saved_wall_shelf",
			"wall_shelf",
			Vector2i(1, 1),
			0,
			false,
			30.0,
		)
	)
	_runtime.call("initialize", _placement, _grid)

	var fixture_root: Node = _runtime.get_node("GeneratedFixtures")
	var shelf: Node3D = fixture_root.get_node_or_null("saved_wall_shelf") as Node3D
	assert_not_null(shelf, "Saved wall shelf fixture should render")
	if shelf == null:
		return
	assert_eq(StringName(str(shelf.get_meta("visual_id", ""))), StoreVisualKitScript.WALL_SHELF)
	for required_path: String in [
		"ShelfMesh",
		"ShelfBoard1",
		"ShelfLabelBacking",
		"MerchandisingRows",
	]:
		assert_not_null(
			shelf.get_node_or_null(required_path),
			"Runtime wall shelf must include %s" % required_path
		)


func test_runtime_renders_saved_floor_rack_as_gondola_fixture() -> void:
	(
		_placement
		. register_existing_fixture(
			"saved_floor_rack",
			"floor_rack",
			Vector2i(4, 4),
			0,
			false,
			50.0,
		)
	)
	_runtime.call("initialize", _placement, _grid)

	var fixture_root: Node = _runtime.get_node("GeneratedFixtures")
	var shelf: Node3D = fixture_root.get_node_or_null("saved_floor_rack") as Node3D
	assert_not_null(shelf, "Saved floor rack fixture should render")
	if shelf == null:
		return
	assert_eq(StringName(str(shelf.get_meta("visual_id", ""))), StoreVisualKitScript.FLOOR_RACK)
	assert_eq(shelf.name, "saved_floor_rack")
	assert_not_null(shelf.get_node_or_null("CenterSpine"))
	assert_not_null(shelf.get_node_or_null("TopShelfFront"))
	assert_not_null(shelf.get_node_or_null("TopShelfBack"))
	assert_not_null(shelf.get_node_or_null("MerchandisingRows/FrontLabelRail"))
	assert_not_null(shelf.get_node_or_null("MerchandisingRows/BackLabelRail"))
	assert_null(
		shelf.get_node_or_null("ShelfMesh"),
		"Floor rack runtime visual should not use wall-shelf nodes"
	)


func test_runtime_rebuilds_when_fixture_state_is_loaded_after_seed() -> void:
	_runtime.call("initialize", _placement, _grid)

	(
		_placement
		. load_save_data(
			{
				"placed_fixtures":
				[
					{
						"fixture_id": "loaded_fixture",
						"fixture_type": "storage_unit",
						"grid_position": [10, 4],
						"rotation": 0,
						"is_register": false,
						"purchase_price": 0.0,
					},
				],
			}
		)
	)

	assert_eq(_placement.get_placed_fixtures().size(), 1)
	assert_eq(_runtime.call("get_generated_fixture_count"), 1)


func test_runtime_rebuilds_generated_visuals_when_fixture_is_placed() -> void:
	_runtime.call("initialize", _placement, _grid)
	_placement.select_fixture("storage_unit")

	assert_true(_placement.try_place(Vector2i(11, 3)))
	assert_eq(_placement.get_placed_fixtures().size(), 3)
	assert_eq(_runtime.call("get_generated_fixture_count"), 3)


func test_runtime_applies_store_design_payload_on_rebuild() -> void:
	assert_true(
		StoreCustomizationSystem.apply_design_option(&"floor_tile_cream", 1, &"retro_games")
	)
	assert_true(
		StoreCustomizationSystem.apply_design_option(&"register_compact_ivory", 1, &"retro_games")
	)
	_placement.register_existing_fixture(
		"saved_register", "register", Vector2i(4, 5), 0, true, 55.0
	)
	_runtime.call("initialize", _placement, _grid)

	var dressing_root: Node = _runtime.get_node("GeneratedDressing")
	var design_root: Node = dressing_root.get_node_or_null("AppliedStoreDesign")
	assert_not_null(design_root)
	assert_not_null(design_root.get_node_or_null("SurfacesDesign"))
	assert_not_null(design_root.get_node_or_null("RegisterDesign"))
	var root_payload: Dictionary = design_root.get_meta("design_payload") as Dictionary
	var register_payload: Dictionary = root_payload.get("register", {}) as Dictionary
	assert_eq(str(register_payload.get("register_style_id", "")), "register_compact_ivory")
	var fixture_root: Node = _runtime.get_node("GeneratedFixtures")
	var register: Node = fixture_root.get_node_or_null("saved_register")
	assert_not_null(register)
	assert_eq(str(register.get_meta("design_variant_id", "")), "register_compact_ivory")

	assert_true(
		StoreCustomizationSystem.apply_design_option(&"counter_laminate_black", 1, &"retro_games")
	)
	var applied: Dictionary = _runtime.call("get_applied_design_payload") as Dictionary
	var counter_payload: Dictionary = applied.get("counter", {}) as Dictionary
	assert_eq(str(counter_payload.get("counter_style_id", "")), "counter_laminate_black")


func test_growth_layout_dressing_appears_after_store_expansion_upgrade() -> void:
	_runtime.call("initialize", _placement, _grid)
	assert_eq(_runtime.call("get_generated_dressing_count"), STARTER_DRESSING_COUNT)
	assert_eq(_growth_contract_nodes().size(), 0)

	(
		EventBus
		. store_upgrade_effect_applied
		. emit(
			&"retro_games",
			"store_expansion",
			"floor_size_increase",
			4.0,
		)
	)

	assert_eq(
		_runtime.call("get_generated_dressing_count"),
		STARTER_DRESSING_COUNT + GROWTH_DRESSING_COUNT
	)
	assert_eq(
		_runtime.get("layout_ids")[1],
		StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT,
	)
	assert_not_null(_runtime.get_node("GeneratedDressing/GrowthQueueLane"))
	assert_eq(_growth_contract_nodes().size(), GROWTH_CONTRACT_SURFACE_COUNT)
	for object_id: String in [
		"customer_route_core",
		"staff_route_core",
		"growth_feature_display_surface",
		"growth_side_display_surface",
		"expanded_wall_display_surface",
		"stockroom_upgrade_surface",
		"sales_floor_expansion_surface",
	]:
		assert_has(_growth_contract_object_ids(), object_id)


func test_growth_layout_upgrade_application_is_idempotent() -> void:
	_runtime.call("initialize", _placement, _grid)
	_emit_store_expansion()
	var first_count: int = _runtime.call("get_generated_dressing_count")
	var first_ids: PackedStringArray = _growth_contract_object_ids()

	_emit_store_expansion()

	assert_eq(_runtime.call("get_generated_dressing_count"), first_count)
	assert_eq(_growth_contract_object_ids(), first_ids)
	assert_eq(_unique_strings(first_ids).size(), first_ids.size())


func test_growth_layout_dressing_restores_from_active_unlocks_and_rebuild() -> void:
	(
		_runtime
		. call(
			"initialize",
			_placement,
			_grid,
			&"retro_games",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			[&"upgrade:store_expansion"] as Array[StringName],
		)
	)
	assert_eq(_growth_contract_nodes().size(), GROWTH_CONTRACT_SURFACE_COUNT)

	EventBus.fixture_state_loaded.emit()

	assert_eq(_growth_contract_nodes().size(), GROWTH_CONTRACT_SURFACE_COUNT)
	assert_not_null(_runtime.get_node("GeneratedDressing/GrowthQueueLane"))


func test_growth_layout_generated_objects_stay_inside_contract_bounds() -> void:
	(
		_runtime
		. call(
			"initialize",
			_placement,
			_grid,
			&"retro_games",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			[&"upgrade:store_expansion"] as Array[StringName],
		)
	)
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT
	var contract: Dictionary = catalog.call("get_physical_contract", layout_id)
	var validation_errors: PackedStringArray = catalog.call(
		"validate_physical_contract", layout_id, [&"upgrade:store_expansion"] as Array[StringName]
	)
	var store_bounds: Dictionary = contract.get("store_bounds", {}) as Dictionary
	var zones: Dictionary = catalog.call("get_named_zones", layout_id) as Dictionary
	var contracts: Dictionary = _contracts_by_object_id(contract)
	assert_eq(Array(validation_errors), [])
	for node: Node3D in _growth_contract_nodes():
		var object_id: String = str(node.get_meta("object_id", ""))
		var entry: Dictionary = contracts.get(object_id, {}) as Dictionary
		assert_false(entry.is_empty(), "%s must come from a placement contract" % object_id)
		assert_false((entry.get("clearance", {}) as Dictionary).is_empty(), object_id)
		if str(node.get_meta("physical_role", "")) == "route_corridor":
			_assert_route_segments_inside_store(node, store_bounds)
			continue
		var zone: Dictionary = zones.get(str(node.get_meta("zone", "")), {}) as Dictionary
		assert_false(zone.is_empty(), "%s must reference a declared zone" % object_id)
		_assert_point_inside_box(node.position, zone, "%s zone" % object_id)
		_assert_point_inside_box(node.position, store_bounds, "%s store bounds" % object_id)


func test_starter_merchandise_is_rendered_from_product_visual_factory() -> void:
	_runtime.call("initialize", _placement, _grid)
	var dressing_root: Node = _runtime.get_node("GeneratedDressing")
	var seen: PackedStringArray = []
	for child: Node in dressing_root.get_children():
		if not child.is_in_group("product_display"):
			continue
		assert_eq(str(child.get_meta("visual_source", "")), "product_visual_factory")
		seen.append(str(child.get_meta("product_item_id", "")))
	assert_eq(
		seen,
		PackedStringArray(
			[
				"console_neo_ignite",
				"neo_ignite_motorway_kings_loose",
				"neo_ignite_kingdom_embers_loose",
			]
		)
	)
	assert_eq(seen.size(), PRODUCT_DRESSING_COUNT)
	for index: int in range(seen.size()):
		var child: Node = _product_dressing_at(dressing_root, index)
		assert_not_null(child.get_node_or_null("ProductPriceTag"))
		assert_eq(str(child.get_meta("route_role", "")), "starter_sale_item")
		assert_eq(
			str(child.get_meta("stock_state", "")),
			String(StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY)
		)
		assert_eq(int(child.get_meta("delivery_index", -1)), index)


func test_starter_merchandise_renders_with_fallback_data_when_registry_is_not_ready() -> void:
	GameManager.data_loader = null
	ContentRegistry.clear_for_testing()
	_content_registry_was_cleared = true

	_runtime.call("initialize", _placement, _grid)
	var dressing_root: Node = _runtime.get_node("GeneratedDressing")
	var seen: PackedStringArray = []
	for child: Node in dressing_root.get_children():
		if not child.is_in_group("product_display"):
			continue
		seen.append(str(child.get_meta("product_item_id", "")))
		assert_eq(str(child.get_meta("visual_resolution_source", "")), "starter_fallback")
		assert_ne(str(child.get_meta("definition_id", "")), "")
		assert_eq(str(child.get_meta("platform_visual_id", "")), "neo_ignite_disc_tower")
		assert_not_null(child.get_node_or_null("ProductPriceTag"))
	assert_eq(seen.size(), PRODUCT_DRESSING_COUNT)


func _emit_store_expansion() -> void:
	(
		EventBus
		. store_upgrade_effect_applied
		. emit(
			&"retro_games",
			"store_expansion",
			"floor_size_increase",
			4.0,
		)
	)


func _growth_contract_nodes() -> Array[Node3D]:
	var result: Array[Node3D] = []
	var dressing_root: Node = _runtime.get_node("GeneratedDressing")
	for child: Node in dressing_root.get_children():
		if bool(child.get_meta(GrowthLayoutSurfaceBuilderScript.META_GENERATED, false)):
			result.append(child as Node3D)
	return result


func _growth_contract_object_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	for node: Node3D in _growth_contract_nodes():
		ids.append(str(node.get_meta("object_id", "")))
	ids.sort()
	return ids


func _unique_strings(values: PackedStringArray) -> PackedStringArray:
	var seen: Dictionary = {}
	var result: PackedStringArray = []
	for value: String in values:
		if seen.has(value):
			continue
		seen[value] = true
		result.append(value)
	return result


func _contracts_by_object_id(physical_contract: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for raw_contract: Variant in physical_contract.get("placement_contracts", []):
		if raw_contract is not Dictionary:
			continue
		var entry: Dictionary = raw_contract as Dictionary
		result[str(entry.get("object_id", ""))] = entry
	return result


func _assert_route_segments_inside_store(route_root: Node3D, store_bounds: Dictionary) -> void:
	var width: float = float(route_root.get_meta("corridor_width", 0.0))
	var footprint: Vector3 = route_root.get_meta("footprint_size", Vector3.ZERO) as Vector3
	assert_gt(width, 0.0)
	assert_almost_eq(footprint.x, width, 0.001)
	for segment: Node in route_root.get_children():
		assert_true(segment is Node3D)
		_assert_point_inside_box(
			(segment as Node3D).position,
			store_bounds,
			"%s segment" % str(route_root.get_meta("object_id", "")),
		)


func _assert_point_inside_box(point: Vector3, box: Dictionary, label: String) -> void:
	var min_point: Vector3 = VisualValueUtilScript.vector3_from_array(
		box.get("min", []), Vector3(-INF, -INF, -INF)
	)
	var max_point: Vector3 = VisualValueUtilScript.vector3_from_array(
		box.get("max", []), Vector3(INF, INF, INF)
	)
	assert_gte(point.x, min_point.x, "%s x min" % label)
	assert_lte(point.x, max_point.x, "%s x max" % label)
	assert_gte(point.y, min_point.y, "%s y min" % label)
	assert_lte(point.y, max_point.y, "%s y max" % label)
	assert_gte(point.z, min_point.z, "%s z min" % label)
	assert_lte(point.z, max_point.z, "%s z max" % label)


func _product_dressing_at(dressing_root: Node, product_index: int) -> Node:
	var current_index := 0
	for child: Node in dressing_root.get_children():
		if not child.is_in_group("product_display"):
			continue
		if current_index == product_index:
			return child
		current_index += 1
	return null
