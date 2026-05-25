extends GutTest

const StoreLayoutRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/store_layout_runtime.gd"
)
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)

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
	assert_eq(_runtime.call("get_generated_dressing_count"), 3)
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
	assert_eq(_runtime.call("get_generated_dressing_count"), 3)


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
	assert_eq(_runtime.call("get_generated_dressing_count"), 3)

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

	assert_eq(_runtime.call("get_generated_dressing_count"), 4)
	assert_eq(
		_runtime.get("layout_ids")[1],
		StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT,
	)


func test_starter_merchandise_is_rendered_from_product_visual_factory() -> void:
	_runtime.call("initialize", _placement, _grid)
	var dressing_root: Node = _runtime.get_node("GeneratedDressing")
	var seen: PackedStringArray = []
	for child: Node in dressing_root.get_children():
		assert_eq(str(child.get_meta("visual_source", "")), "product_visual_factory")
		assert_true(child.is_in_group("product_display"))
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
