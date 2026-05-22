extends GutTest

const StoreLayoutRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/store_layout_runtime.gd"
)
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)

var _parent: Node3D
var _grid: BuildModeGrid
var _placement: FixturePlacementSystem
var _runtime: Node


func before_each() -> void:
	_parent = Node3D.new()
	add_child(_parent)
	_grid = BuildModeGrid.new()
	_parent.add_child(_grid)
	_grid.initialize(BuildModeGrid.StoreSize.SMALL, Vector3.ZERO)
	_placement = FixturePlacementSystem.new()
	_parent.add_child(_placement)
	_placement.initialize(_grid, null, null, _grid.grid_size.y - 2, BuildModeGrid.StoreSize.SMALL)
	_runtime = StoreLayoutRuntimeScript.new()
	_parent.add_child(_runtime)


func after_each() -> void:
	_parent.free()


func test_runtime_seeds_sparse_starter_fixtures_when_placement_is_empty() -> void:
	_runtime.call("initialize", _placement, _grid)

	var placed: Array[Dictionary] = _placement.get_placed_fixtures()
	assert_eq(placed.size(), 4)
	assert_eq(_runtime.call("get_generated_fixture_count"), 4)
	assert_eq(_runtime.call("get_generated_dressing_count"), 4)
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
	assert_eq(_runtime.call("get_generated_dressing_count"), 4)


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
	assert_eq(_placement.get_placed_fixtures().size(), 5)
	assert_eq(_runtime.call("get_generated_fixture_count"), 5)


func test_growth_layout_dressing_appears_after_store_expansion_upgrade() -> void:
	_runtime.call("initialize", _placement, _grid)
	assert_eq(_runtime.call("get_generated_dressing_count"), 4)

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

	assert_eq(_runtime.call("get_generated_dressing_count"), 5)
	assert_eq(
		_runtime.get("layout_ids")[1],
		StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT,
	)
