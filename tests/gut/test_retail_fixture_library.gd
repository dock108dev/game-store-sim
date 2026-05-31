## Tests reusable retail fixture scenes, scene-path data, and collection shape.
extends GutTest

const FIXTURE_SCENES: Dictionary = {
	"RetailWallShelf": {
		"path": "res://game/scenes/stores/fixtures/retail_wall_shelf.tscn",
		"slot_ids": [
			"wall_shelf_1",
			"wall_shelf_2",
			"wall_shelf_3",
			"wall_shelf_4",
		],
	},
	"RetailGondolaShelf": {
		"path": "res://game/scenes/stores/fixtures/retail_gondola_shelf.tscn",
		"slot_ids": [
			"gondola_1",
			"gondola_2",
			"gondola_3",
			"gondola_4",
			"gondola_5",
			"gondola_6",
		],
	},
	"CheckoutCounter": {
		"path": "res://game/scenes/stores/fixtures/checkout_counter.tscn",
		"slot_ids": ["counter_impulse_1", "counter_impulse_2"],
	},
	"DisplayTable": {
		"path": "res://game/scenes/stores/fixtures/display_table.tscn",
		"slot_ids": [
			"display_table_1",
			"display_table_2",
			"display_table_3",
		],
	},
	"ReceivingTable": {
		"path": "res://game/scenes/stores/fixtures/receiving_table.tscn",
		"slot_ids": ["receiving_1", "receiving_2"],
	},
	"BoxStack": {
		"path": "res://game/scenes/stores/fixtures/box_stack.tscn",
		"slot_ids": [],
	},
	"QueuePost": {
		"path": "res://game/scenes/stores/fixtures/queue_post.tscn",
		"slot_ids": [],
	},
	"WallSign": {
		"path": "res://game/scenes/stores/fixtures/wall_sign.tscn",
		"slot_ids": [],
	},
	"ShelfLabel": {
		"path": "res://game/scenes/stores/fixtures/shelf_label.tscn",
		"slot_ids": [],
	},
	"GameCase": {
		"path": "res://game/scenes/stores/fixtures/game_case.tscn",
		"slot_ids": [],
	},
	"ConsoleBox": {
		"path": "res://game/scenes/stores/fixtures/console_box.tscn",
		"slot_ids": [],
	},
	"ControllerBin": {
		"path": "res://game/scenes/stores/fixtures/controller_bin.tscn",
		"slot_ids": ["controller_bin_1", "controller_bin_2"],
	},
	"FixtureCheckoutCounter": {
		"path": "res://game/scenes/stores/fixtures/fixture_checkout_counter.tscn",
		"slot_ids": ["counter_impulse_1", "counter_impulse_2"],
	},
	"FixtureWallShelf": {
		"path": "res://game/scenes/stores/fixtures/fixture_wall_shelf.tscn",
		"slot_ids": [
			"wall_shelf_1",
			"wall_shelf_2",
			"wall_shelf_3",
			"wall_shelf_4",
		],
	},
	"FixtureDisplayTable": {
		"path": "res://game/scenes/stores/fixtures/fixture_display_table.tscn",
		"slot_ids": [
			"display_table_1",
			"display_table_2",
			"display_table_3",
		],
	},
	"FixtureQueueLane": {
		"path": "res://game/scenes/stores/fixtures/fixture_queue_lane.tscn",
		"slot_ids": [],
	},
	"FixtureStockroomTable": {
		"path": "res://game/scenes/stores/fixtures/fixture_stockroom_table.tscn",
		"slot_ids": ["receiving_1", "receiving_2"],
	},
	"PropGameCase": {
		"path": "res://game/scenes/stores/fixtures/prop_game_case.tscn",
		"slot_ids": [],
	},
	"PropConsoleBox": {
		"path": "res://game/scenes/stores/fixtures/prop_console_box.tscn",
		"slot_ids": [],
	},
	"PropRegister": {
		"path": "res://game/scenes/stores/fixtures/prop_register.tscn",
		"slot_ids": [],
	},
	"PropCardReader": {
		"path": "res://game/scenes/stores/fixtures/prop_card_reader.tscn",
		"slot_ids": [],
	},
	"PropReceiptPrinter": {
		"path": "res://game/scenes/stores/fixtures/prop_receipt_printer.tscn",
		"slot_ids": [],
	},
	"SignZoneHeader": {
		"path": "res://game/scenes/stores/fixtures/sign_zone_header.tscn",
		"slot_ids": [],
	},
	"SignShelfLabel": {
		"path": "res://game/scenes/stores/fixtures/sign_shelf_label.tscn",
		"slot_ids": [],
	},
}

const RETRO_SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const FIXTURE_CATALOG_PATH: String = "res://game/content/fixtures.json"
const MeshBoundsUtil: GDScript = preload(
	"res://game/scripts/visuals/mesh_bounds_util.gd"
)
const SIGN_BACKING_MATERIAL_PATH: String = "res://game/assets/materials/mat_sign_backing.tres"
const LAMINATE_COUNTER_MATERIAL_PATH: String = (
	"res://game/assets/materials/mat_laminate_counter.tres"
)
const PLAYER_CAMERA_EYE_Y: float = 1.62
const PLAYER_CHEST_Y: float = 1.35
const SUPPORT_TOLERANCE: float = 0.04
const SIGN_TEXT_COLOR: Color = Color(1, 0.92, 0.55, 1)
const SIGN_OUTLINE_COLOR: Color = Color(0.05, 0.05, 0.05, 1)
const SIGN_BACKING_DEPTH: float = 0.03
const CHECKOUT_PROP_SCENES: Dictionary = {
	"PropRegister": {
		"nodes": ["RegisterBase", "ScreenBezel", "Screen", "ScreenText", "RearServicePanel"],
	},
	"PropCardReader": {
		"nodes": ["ReaderBody", "ReaderScreen", "CardSlot", "RearPlate"],
	},
	"PropReceiptPrinter": {
		"nodes": ["PrinterBody", "PrinterLid", "ReceiptSlot", "ReceiptStrip", "RearPanel"],
	},
}
const ABOVE_EYE_WALL_FIXTURES: Array[String] = [
	"RetailWallShelf",
	"WallSign",
	"FixtureWallShelf",
	"SignZoneHeader",
]
const ROOT_FIXTURE_NAMES: Array[String] = [
	"CartRackLeft",
	"CartRackRight",
	"GlassCase",
	"ConsoleShelf",
	"AccessoriesBin",
	"Checkout",
]
const FIXTURE_HEIGHT_BUDGETS: Dictionary = {
	"RetailWallShelf": {"min": 2.05, "max": 2.50},
	"RetailGondolaShelf": {"min": 1.15, "max": PLAYER_CHEST_Y},
	"CheckoutCounter": {"min": 0.90, "max": PLAYER_CHEST_Y},
	"DisplayTable": {"min": 0.70, "max": 0.95},
	"ReceivingTable": {"min": 0.85, "max": 1.05},
	"BoxStack": {"min": 0.80, "max": 1.20},
	"QueuePost": {"min": 0.95, "max": 1.15},
	"WallSign": {"min": 0.45, "max": 0.60},
	"ShelfLabel": {"min": 0.15, "max": 0.25},
	"GameCase": {"min": 0.34, "max": 0.44},
	"ConsoleBox": {"min": 0.32, "max": 0.44},
	"ControllerBin": {"min": 0.55, "max": 0.70},
	"FixtureCheckoutCounter": {"min": 0.90, "max": PLAYER_CHEST_Y},
	"FixtureWallShelf": {"min": 2.05, "max": 2.50},
	"FixtureDisplayTable": {"min": 0.70, "max": 0.95},
	"FixtureQueueLane": {"min": 1.05, "max": PLAYER_CHEST_Y},
	"FixtureStockroomTable": {"min": 0.85, "max": 1.05},
	"PropGameCase": {"min": 0.34, "max": 0.44},
	"PropConsoleBox": {"min": 0.32, "max": 0.44},
	"PropRegister": {"min": 0.36, "max": 0.48},
	"PropCardReader": {"min": 0.08, "max": 0.24},
	"PropReceiptPrinter": {"min": 0.18, "max": 0.32},
	"SignZoneHeader": {"min": 0.45, "max": 0.60},
	"SignShelfLabel": {"min": 0.15, "max": 0.25},
}
const SLOT_SUPPORT_SURFACES: Dictionary = {
	"RetailWallShelf": "ShelfBoard2",
	"RetailGondolaShelf": "TopShelfFront",
	"CheckoutCounter": "CounterTop",
	"DisplayTable": "TableMesh",
	"ReceivingTable": "BenchMesh",
	"ControllerBin": "BinRim",
	"FixtureCheckoutCounter": "CounterTop",
	"FixtureWallShelf": "ShelfBoard2",
	"FixtureDisplayTable": "TableMesh",
	"FixtureStockroomTable": "BenchMesh",
}
const LARGE_FIXTURE_MESH_MINIMUMS: Dictionary = {
	"RetailWallShelf": 6,
	"RetailGondolaShelf": 6,
	"CheckoutCounter": 4,
	"DisplayTable": 7,
	"ReceivingTable": 7,
	"QueuePost": 4,
	"WallSign": 3,
	"ControllerBin": 2,
	"FixtureCheckoutCounter": 4,
	"FixtureWallShelf": 6,
	"FixtureDisplayTable": 7,
	"FixtureQueueLane": 6,
	"FixtureStockroomTable": 7,
	"PropRegister": 4,
	"PropCardReader": 3,
	"PropReceiptPrinter": 5,
	"SignZoneHeader": 3,
}
const REUSABLE_SIGN_FIXTURE_PARTS: Dictionary = {
	"WallSign": {
		"label": "SignText",
		"backing": "SignPanel",
	},
	"ShelfLabel": {
		"label": "LabelText",
		"backing": "LabelBacking",
	},
}


func test_required_reusable_fixture_scenes_load() -> void:
	for scene_name: String in FIXTURE_SCENES:
		var path: String = FIXTURE_SCENES[scene_name]["path"]
		var packed: PackedScene = load(path) as PackedScene
		assert_not_null(packed, "%s must load from %s" % [scene_name, path])


func test_fixture_scene_roots_and_slots_follow_collection_shape() -> void:
	for scene_name: String in FIXTURE_SCENES:
		var path: String = FIXTURE_SCENES[scene_name]["path"]
		var root: Node = (load(path) as PackedScene).instantiate()
		add_child_autofree(root)
		assert_eq(root.name, scene_name)
		assert_true(root.is_in_group("fixture"), "%s root must be collectible" % scene_name)
		if scene_name == "CheckoutCounter":
			var counter_top: MeshInstance3D = (
				root.get_node_or_null("CounterTop") as MeshInstance3D
			)
			assert_not_null(counter_top, "CheckoutCounter must expose CounterTop")
			if counter_top != null:
				var material: StandardMaterial3D = (
					counter_top.get_surface_override_material(0) as StandardMaterial3D
				)
				assert_not_null(material, "CheckoutCounter top must have a material")
				if material != null:
					assert_eq(
						material.resource_path,
						LAMINATE_COUNTER_MATERIAL_PATH,
						"CheckoutCounter top must use the shared laminate counter material"
					)

		var actual_ids: Array[String] = []
		for slot: Node in _collect_direct_slots(root):
			actual_ids.append(String(slot.get("slot_id")))
			assert_eq(slot.get_parent(), root, "%s slots must be direct children" % scene_name)
		assert_eq(actual_ids, FIXTURE_SCENES[scene_name]["slot_ids"])


func test_fixture_scene_paths_load_and_match_declared_slots() -> void:
	var loader := DataLoader.new()
	var placement := FixturePlacementSystem.new()
	add_child_autofree(placement)
	placement.set_data_loader(loader)

	for fixture: FixtureDefinition in _fixture_definitions_from_json():
		loader._fixtures[fixture.id] = fixture
		if fixture.scene_path.is_empty():
			continue
		var resolved_path: String = placement.get_fixture_scene_path(fixture.id)
		assert_eq(resolved_path, fixture.scene_path)
		var root: Node = (load(resolved_path) as PackedScene).instantiate()
		add_child_autofree(root)
		assert_eq(
			_collect_direct_slots(root).size(),
			fixture.slot_count,
			"%s scene slot count must match fixture data" % fixture.id
		)


func test_reusable_fixture_scene_heights_share_player_scale_budget() -> void:
	for scene_name: String in FIXTURE_SCENES:
		var root: Node3D = (
			load(FIXTURE_SCENES[scene_name]["path"]) as PackedScene
		).instantiate() as Node3D
		add_child_autofree(root)
		var height_budget: Dictionary = FIXTURE_HEIGHT_BUDGETS[scene_name]
		var bounds: AABB = MeshBoundsUtil.visual_bounds(root)
		assert_gte(
			bounds.size.y,
			height_budget["min"],
			"%s height %.2f must meet its minimum fixture scale"
			% [scene_name, bounds.size.y]
		)
		assert_lte(
			bounds.size.y,
			height_budget["max"],
			"%s height %.2f must stay within the player-camera scale budget %.2f"
			% [scene_name, bounds.size.y, height_budget["max"]]
		)
		if not ABOVE_EYE_WALL_FIXTURES.has(scene_name):
			assert_lte(
				bounds.end.y,
				PLAYER_CAMERA_EYE_Y,
				"%s visual top %.2f must not dominate the %.2fm player camera"
				% [scene_name, bounds.end.y, PLAYER_CAMERA_EYE_Y]
			)


func test_floor_fixture_slots_rest_on_declared_support_surfaces() -> void:
	for scene_name: String in SLOT_SUPPORT_SURFACES:
		var root: Node3D = (
			load(FIXTURE_SCENES[scene_name]["path"]) as PackedScene
		).instantiate() as Node3D
		add_child_autofree(root)
		var support_path: String = SLOT_SUPPORT_SURFACES[scene_name]
		var support: MeshInstance3D = root.get_node_or_null(support_path) as MeshInstance3D
		assert_not_null(
			support,
			"%s must expose %s as its product support surface"
			% [scene_name, support_path]
		)
		if support == null:
			continue
		var support_top_y: float = MeshBoundsUtil.mesh_bounds_in_root(root, support).end.y
		for slot: Node in _collect_direct_slots(root):
			var slot_y: float = (slot as Node3D).position.y
			assert_gte(
				slot_y,
				support_top_y - SUPPORT_TOLERANCE,
				"%s/%s must not sink products below %.2f"
				% [scene_name, slot.name, support_top_y]
			)
			assert_lte(
				slot_y,
				support_top_y + 0.24,
				"%s/%s must stay close to support surface %.2f"
				% [scene_name, slot.name, support_top_y]
			)


func test_large_fixture_scenes_use_trim_legs_or_rails_not_single_blocks() -> void:
	for scene_name: String in LARGE_FIXTURE_MESH_MINIMUMS:
		var root: Node3D = (
			load(FIXTURE_SCENES[scene_name]["path"]) as PackedScene
		).instantiate() as Node3D
		add_child_autofree(root)
		var mesh_count: int = _count_mesh_descendants(root)
		assert_gte(
			mesh_count,
			LARGE_FIXTURE_MESH_MINIMUMS[scene_name],
			"%s must be built from fixture-language parts, not one raw primitive"
			% scene_name
		)


func test_reusable_sign_fixtures_share_backed_sign_vocabulary() -> void:
	var expected_material: StandardMaterial3D = load(
		SIGN_BACKING_MATERIAL_PATH
	) as StandardMaterial3D
	assert_not_null(expected_material, "Shared sign backing material must load")
	for scene_name: String in REUSABLE_SIGN_FIXTURE_PARTS:
		var root: Node3D = (
			load(FIXTURE_SCENES[scene_name]["path"]) as PackedScene
		).instantiate() as Node3D
		add_child_autofree(root)
		var parts: Dictionary = REUSABLE_SIGN_FIXTURE_PARTS[scene_name]
		var label: Label3D = root.get_node_or_null(String(parts["label"])) as Label3D
		var backing: MeshInstance3D = (
			root.get_node_or_null(String(parts["backing"])) as MeshInstance3D
		)
		assert_not_null(label, "%s must expose a Label3D sign face" % scene_name)
		assert_not_null(backing, "%s must expose a physical sign backing" % scene_name)
		if label == null or backing == null:
			continue
		assert_eq(label.modulate, SIGN_TEXT_COLOR)
		assert_eq(label.outline_modulate, SIGN_OUTLINE_COLOR)
		assert_gte(label.outline_size, 6)
		assert_false(label.shaded)
		assert_false(label.double_sided)
		assert_ne(label.billboard, BaseMaterial3D.BILLBOARD_ENABLED)
		var material: StandardMaterial3D = backing.get_surface_override_material(
			0
		) as StandardMaterial3D
		assert_not_null(material, "%s backing must have a material" % scene_name)
		if material == null:
			continue
		assert_eq(
			material.resource_path,
			SIGN_BACKING_MATERIAL_PATH,
			"%s backing must use the shared finished sign-board material"
			% scene_name
		)
		assert_almost_eq(
			_box_depth(backing),
			SIGN_BACKING_DEPTH,
			0.001,
			"%s backing must use the shared shallow physical board depth"
			% scene_name
		)

	var wall_label: Label3D = _fixture_label("WallSign", "SignText")
	var shelf_label: Label3D = _fixture_label("ShelfLabel", "LabelText")
	assert_gt(
		_sign_text_scale(wall_label),
		_sign_text_scale(shelf_label),
		"Zone-header fixture text must dominate shelf-label fixture text"
	)

func test_queue_lane_fixture_is_open_directional_retail_flow() -> void:
	var root: Node3D = (
		load(FIXTURE_SCENES["FixtureQueueLane"]["path"]) as PackedScene
	).instantiate() as Node3D
	add_child_autofree(root)

	for required_path: String in [
		"QueueMat01",
		"QueueMat02",
		"QueueMat03",
		"DirectionArrowShaft",
		"DirectionArrowHeadLeft",
		"DirectionArrowHeadRight",
		"LeftGuideRope",
		"RightGuideRope",
		"BackLeftPost",
		"BackRightPost",
		"RegisterLeftPost",
		"RegisterRightPost",
	]:
		assert_not_null(
			root.get_node_or_null(required_path),
			"FixtureQueueLane must include %s" % required_path
		)

	var mat_1: Node3D = root.get_node_or_null("QueueMat01") as Node3D
	var mat_2: Node3D = root.get_node_or_null("QueueMat02") as Node3D
	var mat_3: Node3D = root.get_node_or_null("QueueMat03") as Node3D
	var arrow_head_left: Node3D = root.get_node_or_null("DirectionArrowHeadLeft") as Node3D
	var left_rope: Node3D = root.get_node_or_null("LeftGuideRope") as Node3D
	var right_rope: Node3D = root.get_node_or_null("RightGuideRope") as Node3D
	if mat_1 != null and mat_2 != null and mat_3 != null:
		assert_gt(
			mat_1.position.x,
			mat_2.position.x,
			"QueueMat01 must be closest to the register end of the lane"
		)
		assert_gt(
			mat_2.position.x,
			mat_3.position.x,
			"Queue mats must read as a line advancing toward the register"
		)
	if arrow_head_left != null and mat_2 != null:
		assert_gt(
			arrow_head_left.position.x,
			mat_2.position.x,
			"Queue arrow must point toward the register end of the lane"
		)
	if left_rope != null and right_rope != null:
		assert_gt(
			absf(left_rope.position.z - right_rope.position.z),
			0.8,
			"Queue ropes must frame the sides instead of closing the lane ends"
		)
		assert_lte(
			absf(left_rope.position.x - right_rope.position.x),
			0.05,
			"Queue side ropes must run parallel along the customer path"
		)
	for child: Node in _collect_descendants(root):
		assert_false(
			child is Area3D,
			"FixtureQueueLane must not define interaction areas"
		)


func test_checkout_props_are_finished_visual_only_scenes() -> void:
	for scene_name: String in CHECKOUT_PROP_SCENES:
		var root: Node3D = (
			load(FIXTURE_SCENES[scene_name]["path"]) as PackedScene
		).instantiate() as Node3D
		add_child_autofree(root)
		assert_eq(root.get_script(), null, "%s root must not own gameplay" % scene_name)
		for required_node: String in CHECKOUT_PROP_SCENES[scene_name]["nodes"]:
			assert_not_null(
				root.get_node_or_null(required_node),
				"%s must include visible checkout detail %s" % [scene_name, required_node]
			)
		for node: Node in _collect_descendants(root):
			assert_false(
				node is Area3D,
				"%s must not expose an interaction Area3D at %s" % [scene_name, node.name]
			)
			assert_eq(
				node.get_script(),
				null,
				"%s child %s must remain visual or physical only" % [scene_name, node.name]
			)


func test_checkout_counter_composes_visual_props_without_owning_register_contract() -> void:
	var root: Node = (
		load(FIXTURE_SCENES["CheckoutCounter"]["path"]) as PackedScene
	).instantiate()
	add_child_autofree(root)
	for prop_name: String in ["RegisterVisual", "CardReaderVisual", "ReceiptPrinterVisual"]:
		var prop: Node = root.get_node_or_null(prop_name)
		assert_not_null(prop, "CheckoutCounter must instance %s" % prop_name)
		assert_false(prop is Area3D, "%s must not be the gameplay interactable" % prop_name)
	var store := _instantiate_retro_store()
	var interactable: Node = store.get_node_or_null("checkout_counter/Interactable")
	assert_not_null(interactable, "live checkout register interactable must remain authored")
	assert_true(interactable is RegisterInteractable)


func test_table_and_counter_tops_have_appropriate_support_structure() -> void:
	var top_expectations: Dictionary = {
		"CheckoutCounter": "CounterTop",
		"DisplayTable": "TableMesh",
		"ReceivingTable": "BenchMesh",
	}
	var sturdy_top_minimums: Dictionary = {
		"DisplayTable": 0.155,
	}
	for scene_name: String in top_expectations:
		var root: Node3D = (
			load(FIXTURE_SCENES[scene_name]["path"]) as PackedScene
		).instantiate() as Node3D
		add_child_autofree(root)
		var top: MeshInstance3D = root.get_node_or_null(
			top_expectations[scene_name]
		) as MeshInstance3D
		assert_not_null(top, "%s must expose a visible top surface" % scene_name)
		if top:
			var top_height: float = MeshBoundsUtil.mesh_bounds_in_root(root, top).size.y
			if sturdy_top_minimums.has(scene_name):
				assert_gte(
					top_height,
					sturdy_top_minimums[scene_name],
					"%s top must have enough visual weight for a retail fixture"
					% scene_name
				)
			else:
				assert_lte(
					top_height,
					0.12,
					"%s top must stay a thin retail surface" % scene_name
				)
		if scene_name == "DisplayTable":
			for support_name: String in [
				"FrontLip",
				"BackLip",
				"LeftLip",
				"RightLip",
				"UnderRailFront",
				"UnderRailBack",
			]:
				assert_not_null(
					root.get_node_or_null(support_name),
					"DisplayTable must include sturdy support detail %s" % support_name
				)
		if scene_name != "CheckoutCounter":
			for leg_name: String in [
				"LegFrontLeft",
				"LegFrontRight",
				"LegBackLeft",
				"LegBackRight",
			]:
				assert_not_null(
					root.get_node_or_null(leg_name),
					"%s must include support leg %s" % [scene_name, leg_name]
				)


func test_retro_games_fixture_roots_stay_collectible_with_direct_slots() -> void:
	var store := _instantiate_retro_store()
	assert_gte(store.get_fixture_count(), ROOT_FIXTURE_NAMES.size())
	for fixture_name: String in ROOT_FIXTURE_NAMES:
		var fixture: Node = store.get_node_or_null(fixture_name)
		assert_not_null(fixture, "%s must stay direct under store root" % fixture_name)
		assert_eq(fixture.get_parent(), store)
		for slot: Node in _collect_direct_slots(fixture):
			assert_eq(slot.get_parent(), fixture)
			assert_false(String(slot.get("slot_id")).is_empty())


func test_retro_games_entry_and_register_areas_stay_root_owned() -> void:
	var store := _instantiate_retro_store()
	var entry_area: Area3D = store.get_entry_area()
	var register_area: Area3D = store.get_register_area()
	assert_not_null(entry_area)
	assert_not_null(register_area)
	assert_eq(entry_area.get_parent(), store)
	assert_eq(register_area.get_parent(), store)


func test_invalid_scene_path_does_not_block_fixture_placement() -> void:
	var grid := BuildModeGrid.new()
	add_child_autofree(grid)
	grid.initialize(BuildModeGrid.StoreSize.SMALL, Vector3.ZERO)

	var loader := DataLoader.new()
	var bad_definition := FixtureDefinition.new()
	bad_definition.id = "invalid_scene_fixture"
	bad_definition.display_name = "Invalid Scene Fixture"
	bad_definition.price = 0.0
	bad_definition.cost = 0.0
	bad_definition.grid_size = Vector2i.ONE
	bad_definition.footprint_cells = [Vector2i.ZERO]
	bad_definition.scene_path = "res://game/scenes/stores/fixtures/missing_fixture.tscn"
	loader._fixtures[bad_definition.id] = bad_definition

	var placement := FixturePlacementSystem.new()
	add_child_autofree(placement)
	placement.initialize(grid, null, null, 8, BuildModeGrid.StoreSize.SMALL)
	placement.set_data_loader(loader)
	placement.select_fixture(bad_definition.id)

	assert_eq(placement.get_fixture_scene_path(bad_definition.id), "")
	assert_true(placement.try_place(Vector2i(5, 5)))
	assert_true(placement.needs_nav_rebake)


func _instantiate_retro_store() -> StoreController:
	var packed: PackedScene = load(RETRO_SCENE_PATH) as PackedScene
	assert_not_null(packed, "retro_games scene must load")
	var store: StoreController = packed.instantiate() as StoreController
	add_child_autofree(store)
	return store


func _collect_direct_slots(root: Node) -> Array[Node]:
	var slots: Array[Node] = []
	for child: Node in root.get_children():
		if child.is_in_group("shelf_slot") or child.get("slot_id") != null:
			slots.append(child)
	return slots


func _count_mesh_descendants(root: Node) -> int:
	return MeshBoundsUtil.collect_mesh_descendants(root).size()


func _fixture_label(scene_name: String, label_path: String) -> Label3D:
	var root: Node3D = (
		load(FIXTURE_SCENES[scene_name]["path"]) as PackedScene
	).instantiate() as Node3D
	add_child_autofree(root)
	return root.get_node_or_null(label_path) as Label3D


func _sign_text_scale(label: Label3D) -> float:
	if label == null:
		return 0.0
	return float(label.font_size) * label.pixel_size


func _box_depth(mesh_inst: MeshInstance3D) -> float:
	var box: BoxMesh = mesh_inst.mesh as BoxMesh
	if box == null:
		return 0.0
	return box.size.z


func _collect_descendants(root: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child: Node in root.get_children():
		nodes.append(child)
		nodes.append_array(_collect_descendants(child))
	return nodes


func _fixture_definitions_from_json() -> Array[FixtureDefinition]:
	var raw: Variant = DataLoader.load_json(FIXTURE_CATALOG_PATH)
	assert_true(raw is Dictionary, "fixtures.json must load")
	var definitions: Array[FixtureDefinition] = []
	for entry: Variant in (raw as Dictionary).get("entries", []):
		if entry is Dictionary:
			var fixture: FixtureDefinition = ContentParser.parse_fixture(entry)
			if fixture:
				definitions.append(fixture)
	return definitions
