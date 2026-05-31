extends GutTest

const StoreLayoutRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/store_layout_runtime.gd"
)
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")

const STARTER_DRESSING_COUNT := 12
const PRODUCT_DRESSING_COUNT := 3

var _parent: Node3D
var _data_loader: DataLoader
var _grid: BuildModeGrid
var _placement: FixturePlacementSystem
var _runtime: Node


func before_each() -> void:
	_parent = Node3D.new()
	add_child(_parent)
	_data_loader = DataLoader.new()
	add_child(_data_loader)
	_data_loader.load_all_content()
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
	_parent.free()
	if is_instance_valid(_data_loader):
		_data_loader.free()


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


func test_growth_layout_dressing_appears_after_store_expansion_upgrade() -> void:
	_runtime.call("initialize", _placement, _grid)
	assert_eq(_runtime.call("get_generated_dressing_count"), STARTER_DRESSING_COUNT)

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

	assert_eq(_runtime.call("get_generated_dressing_count"), STARTER_DRESSING_COUNT + 1)
	assert_eq(
		_runtime.get("layout_ids")[1],
		StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT,
	)


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


func _product_dressing_at(dressing_root: Node, product_index: int) -> Node:
	var current_index := 0
	for child: Node in dressing_root.get_children():
		if not child.is_in_group("product_display"):
			continue
		if current_index == product_index:
			return child
		current_index += 1
	return null
