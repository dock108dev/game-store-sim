# gdlint:disable=max-file-lines
## Runtime visual shell for the one-store expansion model.
##
## `retro_games.tscn` still owns gameplay anchors and interactables, but boot
## presentation is generated here: an expanded starter footprint with a closed
## expansion bay. Growth should unlock more generated layout pieces instead of
## revealing legacy authored full-store fixtures.
class_name ExpandableStoreShellRuntime
extends RefCounted

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const OnboardingRouteCueRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/onboarding_route_cue_runtime.gd"
)
const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)
const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")

const ROOT_NAME: StringName = &"ExpandableStoreShell"
const _STARTER_PRODUCT_FALLBACKS: Dictionary = {
	"console_neo_ignite":
	{
		"display_name": "Neo Ignite Console (Working)",
		"category": "consoles",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"price_cents": 11900,
	},
	"neo_ignite_motorway_kings_loose":
	{
		"display_name": "Motorway Kings",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"box_art_key": "motorway_kings_neo_ignite",
		"visual_presentation": "game_case",
		"price_cents": 1600,
	},
	"neo_ignite_kingdom_embers_loose":
	{
		"display_name": "Kingdom of Embers",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"visual_presentation": "game_case",
		"price_cents": 1800,
	},
	"neo_ignite_torque_force_3_loose":
	{
		"display_name": "Torque Force 3",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"visual_presentation": "cartridge",
		"price_cents": 1100,
	},
	"neo_ignite_gridiron_2005_loose":
	{
		"display_name": "Gridiron Season 2005",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"visual_presentation": "cartridge",
		"price_cents": 500,
	},
}
const _SHELL_WIDTH: float = 16.0
const _SHELL_DEPTH: float = 20.0
const _SHELL_CENTER_Z: float = 0.0
const _SHELL_LEFT_X: float = -8.0
const _SHELL_RIGHT_X: float = 8.0
const _SHELL_BACK_Z: float = -10.0
const _SHELL_FRONT_Z: float = 10.0
const _PLAYER_BOUNDS_MIN: Vector3 = Vector3(-7.45, 0.0, -9.35)
const _PLAYER_BOUNDS_MAX: Vector3 = Vector3(7.45, 0.0, 9.05)
const _PLAYER_SPAWN_POSITION: Vector3 = Vector3(-0.55, 0.0, 8.35)
const _PLAYER_SPAWN_ROTATION: Vector3 = Vector3(0.0, -25.0, 0.0)
const _ENTRANCE_POSITION: Vector3 = Vector3(0.0, 0.0, 9.72)
const _ENTRY_AREA_POSITION: Vector3 = Vector3(0.0, 1.2, 9.15)
const _CHECKOUT_POSITION: Vector3 = Vector3(5.65, 0.0, 6.15)
const _SHELF_TARGET_POSITION: Vector3 = Vector3(-4.10, 0.0, -1.20)
const _CHECKOUT_SERVICE_OFFSET_FROM_LAYOUT: Vector3 = Vector3(-0.80, 0.0, 1.10)
const _STOCKROOM_PICKUP_POSITION: Vector3 = Vector3(4.90, 0.0, -8.70)
const _STOCKROOM_THRESHOLD_POSITION: Vector3 = Vector3(4.95, 0.06, -5.65)
const _STOCKROOM_VISUAL_WIDTH: float = 6.25
const _STOCKROOM_VISUAL_DEPTH: float = 11.20
const _STOCKROOM_VISUAL_CENTER_X: float = 4.375
const _STOCKROOM_VISUAL_CENTER_Z: float = -4.35
const _ANCHOR_SCALE_CHECKOUT: Vector3 = Vector3(0.82, 0.82, 0.82)

const _HIDDEN_AUTHORED_VISUAL_ROOTS: Array[String] = [
	"Floor",
	"BackWallBody",
	"LeftWallBody",
	"RightWallBody",
	"Ceiling",
	"FrontWallLeftBody",
	"FrontWallRightBody",
	"Storefront",
	"EntranceInterior",
	"InteriorSignage",
	"ZoneLabels",
	"ReadabilityProps",
	"ReadabilityProps/ShelfSpineRuns",
	"ReadabilityProps/ProductDisplayRows",
	"ReadabilityProps/SpawnViewFloorDressing",
	"ReadabilityProps/DayOneRouteMarkers",
	"CartRackLeft",
	"Checkout",
	"back_room",
	"StoreSessionBackroomWallSide",
	"StoreSessionBackroomWallFrontLeft",
	"StoreSessionBackroomWallFrontRight",
	"Decorations",
	"TimeClock",
]


static func apply(store: Node) -> void:
	if store == null:
		return
	var layout_catalog: RefCounted = StoreVisualLayoutScript.load_default()
	_hide_authored_visual_roots(store)
	_move_starter_anchors(store, layout_catalog)
	var shell: Node3D = _ensure_shell_root(store)
	_rebuild_shell(shell, layout_catalog)


## Returns authored visual roots hidden before the generated starter shell is built.
static func hidden_authored_visual_roots() -> Array[String]:
	return _HIDDEN_AUTHORED_VISUAL_ROOTS.duplicate()


static func _hide_authored_visual_roots(store: Node) -> void:
	for node_path: String in _HIDDEN_AUTHORED_VISUAL_ROOTS:
		var node: Node3D = store.get_node_or_null(NodePath(node_path)) as Node3D
		if node != null:
			node.visible = false


static func _move_starter_anchors(store: Node, layout_catalog: RefCounted) -> void:
	var display_table: Dictionary = _starter_fixture_placement(
		layout_catalog, "starter_display_table"
	)
	var checkout_counter: Dictionary = _starter_fixture_placement(
		layout_catalog, "starter_checkout_counter"
	)
	var shelf_position: Vector3 = _placement_position(display_table, _SHELF_TARGET_POSITION)
	var shelf_rotation: Vector3 = _placement_rotation(display_table, Vector3(0.0, -8.0, 0.0))
	var checkout_position: Vector3 = _placement_position(checkout_counter, _CHECKOUT_POSITION)
	var checkout_rotation: Vector3 = _placement_rotation(checkout_counter, Vector3.ZERO)
	var checkout_scale: Vector3 = _placement_scale(checkout_counter, _ANCHOR_SCALE_CHECKOUT)
	var checkout_service_position: Vector3 = (
		checkout_position + _CHECKOUT_SERVICE_OFFSET_FROM_LAYOUT
	)
	_set_position(store, "PlayerEntrySpawn", _PLAYER_SPAWN_POSITION)
	_set_rotation_degrees(store, "PlayerEntrySpawn", _PLAYER_SPAWN_ROTATION)
	_set_player_bounds(store, _PLAYER_BOUNDS_MIN, _PLAYER_BOUNDS_MAX)
	_set_position(store, "Checkout", checkout_position)
	_set_rotation_degrees(store, "Checkout", checkout_rotation)
	_set_scale(store, "Checkout", checkout_scale)
	_set_position(store, "checkout_counter", checkout_position)
	_set_rotation_degrees(store, "checkout_counter", checkout_rotation)
	_set_scale(store, "checkout_counter", checkout_scale)
	_set_position(store, "RegisterArea", checkout_service_position + Vector3(0.0, 1.0, 0.0))
	_set_position(store, "StoreSessionDayOneCustomer", checkout_service_position)
	_set_global_position(
		store,
		"Checkout/StoreSessionCustomerFloorMat",
		checkout_service_position + Vector3(0.0, 0.01, 0.0)
	)
	_set_position(store, "StoreSessionDayEndTrigger", checkout_position + Vector3(0.0, 1.05, 0.0))
	_set_position(store, "StoreSessionRestockShelf", shelf_position)
	_set_rotation_degrees(store, "StoreSessionRestockShelf", shelf_rotation)
	_hide_node(store, "StoreSessionRestockShelf/RestockCrate")
	_set_position(store, "StoreSessionBackroomPickup", _STOCKROOM_PICKUP_POSITION)
	_set_position(store, "EntranceDoor", _ENTRANCE_POSITION)
	_hide_node(store, "EntranceDoor/DoorMesh")
	_hide_node(store, "EntranceDoor/StaticBody3D")
	_set_position(store, "EntryArea", _ENTRY_AREA_POSITION)
	_set_position(store, "QueueMarker1", checkout_service_position)
	_set_position(store, "QueueMarker2", checkout_service_position + Vector3(-0.95, 0.0, 0.25))
	_set_position(store, "QueueMarker3", checkout_service_position + Vector3(-1.90, 0.0, 0.50))
	_set_position(store, "FrontLaneQueue", checkout_service_position + Vector3(-0.55, 0.0, -0.05))
	_set_position(store, "BackroomUtilityLight", Vector3(4.95, 2.35, -8.45))
	_set_position(store, "CheckoutLaneSpotlight", Vector3(5.05, 3.1, 6.75))
	_set_position(store, "FluorescentKeyLight", Vector3(0.0, 3.25, -0.15))
	_set_position(store, "WarmNeonFill", Vector3(-5.6, 2.1, -0.9))
	_set_position(store, "GreenNeonFill", Vector3(6.2, 2.2, 5.85))
	_set_customer_nav(store, shelf_position, checkout_service_position)


static func _set_customer_nav(
	store: Node, shelf_position: Vector3, checkout_service_position: Vector3
) -> void:
	_set_position(store, "StoreStaffConfig/RegisterPoint", checkout_service_position)
	_set_position(store, "StoreStaffConfig/BackroomPoint", _STOCKROOM_PICKUP_POSITION)
	_set_position(store, "StoreStaffConfig/GreeterPoint", Vector3(0.0, 0.0, 8.20))
	_set_position(
		store, "CustomerNavConfig/EntryPoint", _ENTRY_AREA_POSITION + Vector3(0.0, -1.15, 0.0)
	)
	_set_position(
		store, "CustomerNavConfig/BrowseWaypoint01", shelf_position + Vector3(0.0, 0.05, 0.0)
	)
	_set_position(store, "CustomerNavConfig/BrowseWaypoint02", Vector3(-5.25, 0.05, -6.05))
	_set_position(store, "CustomerNavConfig/BrowseWaypoint03", Vector3(0.30, 0.05, -2.05))
	_set_position(store, "CustomerNavConfig/BrowseWaypoint04", Vector3(-5.65, 0.05, 2.45))
	_set_position(
		store,
		"CustomerNavConfig/CheckoutApproach",
		checkout_service_position + Vector3(0.0, 0.05, 0.0)
	)
	_set_position(
		store, "CustomerNavConfig/ExitPoint", _ENTRY_AREA_POSITION + Vector3(0.0, -1.15, 0.0)
	)


static func _set_position(store: Node, path: String, position: Vector3) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node != null:
		node.position = position


static func _set_global_position(store: Node, path: String, global_position: Vector3) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node == null:
		return
	if node.is_inside_tree():
		node.global_position = global_position
		return
	var parent_node: Node3D = node.get_parent() as Node3D
	if parent_node == null:
		node.position = global_position
		return
	var parent_transform: Transform3D = _local_global_transform(parent_node)
	node.position = parent_transform.affine_inverse() * global_position


static func _set_rotation_degrees(store: Node, path: String, rotation_degrees: Vector3) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node != null:
		node.rotation_degrees = rotation_degrees


static func _set_scale(store: Node, path: String, scale: Vector3) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node != null:
		node.scale = scale


static func _hide_node(store: Node, path: String) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node != null:
		node.visible = false


static func _starter_fixture_placement(
	layout_catalog: RefCounted, fixture_id: String
) -> Dictionary:
	if layout_catalog == null:
		return {}
	return (
		(
			layout_catalog
			. call(
				"get_fixture_placement",
				StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
				fixture_id,
			)
		)
		as Dictionary
	)


static func _starter_first_delivery_products(layout_catalog: RefCounted) -> Array[Dictionary]:
	if layout_catalog == null:
		return []
	return (
		(
			layout_catalog
			. call(
				"get_product_placements",
				StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
				StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY,
			)
		)
		as Array[Dictionary]
	)


static func _placement_position(placement: Dictionary, fallback: Vector3) -> Vector3:
	return VisualValueUtilScript.vector3_from_array(placement.get("position", []), fallback)


static func _placement_rotation(placement: Dictionary, fallback: Vector3) -> Vector3:
	return VisualValueUtilScript.vector3_from_array(placement.get("rotation_degrees", []), fallback)


static func _placement_scale(placement: Dictionary, fallback: Vector3) -> Vector3:
	return VisualValueUtilScript.vector3_from_array(placement.get("scale", []), fallback)


static func _set_player_bounds(store: Node, bounds_min: Vector3, bounds_max: Vector3) -> void:
	var spawn: Marker3D = store.get_node_or_null("PlayerEntrySpawn") as Marker3D
	if spawn == null:
		return
	spawn.set_meta("bounds_min", bounds_min)
	spawn.set_meta("bounds_max", bounds_max)


static func _ensure_shell_root(store: Node) -> Node3D:
	var shell: Node3D = store.get_node_or_null(NodePath(ROOT_NAME)) as Node3D
	if shell == null and store.has_meta("_expandable_store_shell_pending"):
		shell = store.get_meta("_expandable_store_shell_pending") as Node3D
	if shell == null:
		shell = Node3D.new()
		shell.name = ROOT_NAME
		store.set_meta("_expandable_store_shell_pending", shell)
		if store.is_inside_tree():
			store.add_child.call_deferred(shell)
		else:
			store.add_child(shell)
	shell.visible = true
	for child: Node in shell.get_children():
		child.free()
	return shell


static func _local_global_transform(node: Node3D) -> Transform3D:
	var chain: Array[Node3D] = []
	var current: Node = node
	while current is Node3D:
		chain.push_front(current as Node3D)
		current = current.get_parent()
	var result := Transform3D.IDENTITY
	for item: Node3D in chain:
		result *= item.transform
	return result


static func _rebuild_shell(shell: Node3D, layout_catalog: RefCounted) -> void:
	var wall_mat: StandardMaterial3D = _mat(Color(0.54, 0.49, 0.41, 1.0))
	var trim_mat: StandardMaterial3D = _mat(Color(0.15, 0.10, 0.07, 1.0))
	var floor_mat: StandardMaterial3D = _mat(Color(0.44, 0.29, 0.17, 1.0))
	var ceiling_mat: StandardMaterial3D = _mat(Color(0.60, 0.57, 0.51, 1.0))
	var shutter_mat: StandardMaterial3D = _mat(Color(0.20, 0.17, 0.22, 1.0))
	var sign_mat: StandardMaterial3D = _mat(Color(0.34, 0.18, 0.05, 1.0))
	var dark_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_DARK_DEVICE_PLASTIC
	)
	var shelf_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE
	)
	var table_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE
	)
	var paper_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_CARDBOARD
	)
	var blue_case_mat: StandardMaterial3D = _mat(Color(0.05, 0.12, 0.32, 1.0))
	var green_case_mat: StandardMaterial3D = _mat(Color(0.03, 0.23, 0.15, 1.0))
	var red_case_mat: StandardMaterial3D = _mat(Color(0.35, 0.08, 0.05, 1.0))
	var sales_panel_mat: StandardMaterial3D = _mat(Color(0.59, 0.50, 0.37, 1.0))
	var shelf_cool_panel_mat: StandardMaterial3D = _mat(Color(0.22, 0.29, 0.31, 1.0))
	var checkout_service_mat: StandardMaterial3D = _mat(Color(0.62, 0.42, 0.22, 1.0))
	var stock_box_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_CARDBOARD
	)
	var backroom_floor_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL
	)
	var backroom_panel_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL
	)
	var backroom_rack_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL
	)
	var crate_shadow_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT
	)
	var gold_mat: StandardMaterial3D = _mat(
		Color(1.0, 0.78, 0.30, 1.0), Color(1.0, 0.63, 0.18, 1.0), 0.35
	)
	var paper_white_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_PAPER
	)
	var purple_case_mat: StandardMaterial3D = _mat(Color(0.26, 0.12, 0.34, 1.0))
	var teal_case_mat: StandardMaterial3D = _mat(Color(0.04, 0.30, 0.32, 1.0))
	var rubber_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_RUBBER
	)
	var identity_panel_mat: StandardMaterial3D = _mat(Color(0.17, 0.23, 0.24, 1.0))
	var identity_trim_mat: StandardMaterial3D = _mat(Color(0.77, 0.52, 0.24, 1.0))
	var sightline_mat: StandardMaterial3D = _mat(Color(0.31, 0.20, 0.13, 1.0))
	var floor_seam_mat: StandardMaterial3D = _mat(Color(0.38, 0.24, 0.14, 1.0))
	var floor_scuff_mat: StandardMaterial3D = _mat(Color(0.40, 0.26, 0.16, 1.0))
	var storefront_frame_mat: StandardMaterial3D = _mat(Color(0.24, 0.21, 0.18, 1.0))
	var storefront_metal_mat: StandardMaterial3D = _mat(Color(0.62, 0.46, 0.25, 1.0))
	var storefront_threshold_mat: StandardMaterial3D = _mat(Color(0.43, 0.34, 0.22, 1.0))
	var storefront_glass_mat: StandardMaterial3D = _glass_mat(Color(0.38, 0.47, 0.50, 0.11))
	var palette: Dictionary = {
		"wall": wall_mat,
		"trim": trim_mat,
		"floor": floor_mat,
		"ceiling": ceiling_mat,
		"shutter": shutter_mat,
		"sign": sign_mat,
		"dark": dark_mat,
		"shelf": shelf_mat,
		"table": table_mat,
		"paper": paper_mat,
		"blue_case": blue_case_mat,
		"green_case": green_case_mat,
		"red_case": red_case_mat,
		"sales_panel": sales_panel_mat,
		"shelf_cool_panel": shelf_cool_panel_mat,
		"checkout_service": checkout_service_mat,
		"stock_box": stock_box_mat,
		"gold": gold_mat,
		"paper_white": paper_white_mat,
		"purple_case": purple_case_mat,
		"teal_case": teal_case_mat,
		"rubber": rubber_mat,
		"identity_panel": identity_panel_mat,
		"identity_trim": identity_trim_mat,
		"sightline": sightline_mat,
		"floor_seam": floor_seam_mat,
		"floor_scuff": floor_scuff_mat,
		"backroom_floor": backroom_floor_mat,
		"backroom_panel": backroom_panel_mat,
		"backroom_rack": backroom_rack_mat,
		"crate_shadow": crate_shadow_mat,
	}

	_add_box(
		shell,
		"StarterFloor",
		Vector3(0.0, 0.025, _SHELL_CENTER_Z),
		Vector3(_SHELL_WIDTH, 0.05, _SHELL_DEPTH),
		floor_mat
	)
	_add_box(
		shell,
		"StarterCeiling",
		Vector3(0.0, 3.45, _SHELL_CENTER_Z),
		Vector3(_SHELL_WIDTH, 0.08, _SHELL_DEPTH),
		ceiling_mat
	)
	_add_wall(
		shell,
		"StarterBackWall",
		Vector3(0.0, 1.72, _SHELL_BACK_Z),
		Vector3(_SHELL_WIDTH, 3.45, 0.12),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterLeftWall",
		Vector3(_SHELL_LEFT_X, 1.72, _SHELL_CENTER_Z),
		Vector3(0.12, 3.45, _SHELL_DEPTH),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterRightWall",
		Vector3(_SHELL_RIGHT_X, 1.72, _SHELL_CENTER_Z),
		Vector3(0.12, 3.45, _SHELL_DEPTH),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterFrontWallLeft",
		Vector3(-5.15, 1.72, _SHELL_FRONT_Z),
		Vector3(5.7, 3.45, 0.12),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterFrontWallRight",
		Vector3(5.15, 1.72, _SHELL_FRONT_Z),
		Vector3(5.7, 3.45, 0.12),
		wall_mat
	)

	_add_box(
		shell,
		"BackWallTrim",
		Vector3(0.0, 0.68, _SHELL_BACK_Z + 0.09),
		Vector3(15.4, 0.08, 0.10),
		trim_mat
	)
	_add_box(
		shell,
		"LeftWallTrim",
		Vector3(_SHELL_LEFT_X + 0.09, 0.68, _SHELL_CENTER_Z),
		Vector3(0.10, 0.08, 19.4),
		trim_mat
	)
	_add_box(
		shell,
		"RightWallTrim",
		Vector3(_SHELL_RIGHT_X - 0.09, 0.68, _SHELL_CENTER_Z),
		Vector3(0.10, 0.08, 19.4),
		trim_mat
	)
	_add_box(
		shell,
		"EntryThreshold",
		Vector3(0.0, 0.046, 9.66),
		Vector3(1.92, 0.022, 0.18),
		storefront_threshold_mat
	)
	_add_box(
		shell,
		"FrontDoorFrameLeft",
		Vector3(-0.94, 1.32, 9.90),
		Vector3(0.040, 2.48, 0.060),
		storefront_frame_mat
	)
	_add_box(
		shell,
		"FrontDoorFrameRight",
		Vector3(0.94, 1.32, 9.90),
		Vector3(0.040, 2.48, 0.060),
		storefront_frame_mat
	)
	_add_box(
		shell,
		"FrontDoorFrameTop",
		Vector3(0.0, 2.56, 9.90),
		Vector3(1.92, 0.045, 0.060),
		storefront_frame_mat
	)
	_add_wall(
		shell,
		"StarterGlassDoorBlocker",
		Vector3(0.0, 1.30, 9.94),
		Vector3(1.64, 1.88, 0.020),
		storefront_glass_mat
	)
	_add_box(
		shell,
		"FrontDoorPushPlate",
		Vector3(0.44, 1.12, 9.82),
		Vector3(0.040, 0.24, 0.020),
		storefront_metal_mat
	)

	_add_box(
		shell,
		"StarterSignBacking",
		Vector3(-4.75, 2.70, _SHELL_BACK_Z + 0.15),
		Vector3(1.85, 0.34, 0.08),
		sign_mat
	)
	_add_label(
		shell, "StarterSignLabel", "SHELF LIFE", Vector3(-4.75, 2.74, _SHELL_BACK_Z + 0.22), 30
	)
	_add_label(shell, "GamesBayLabel", "", Vector3(-4.75, 2.35, _SHELL_BACK_Z + 0.23), 22)
	_add_spawn_identity_composition(shell, palette)

	_add_wall(
		shell, "StockroomPartition", Vector3(3.55, 0.90, -5.65), Vector3(0.82, 1.80, 0.10), wall_mat
	)
	_add_wall(
		shell,
		"StockroomLeftSideReturn",
		Vector3(3.18, 1.55, -7.70),
		Vector3(0.12, 2.95, 4.12),
		wall_mat
	)
	_add_wall(
		shell,
		"StockroomSideReturn",
		Vector3(5.86, 1.55, -7.70),
		Vector3(0.12, 2.95, 4.12),
		wall_mat
	)
	_add_wall(
		shell, "StockroomBackPanel", Vector3(4.55, 1.55, -9.85), Vector3(2.70, 2.95, 0.10), wall_mat
	)
	_add_box(
		shell, "StockroomPost", Vector3(3.95, 0.94, -5.65), Vector3(0.12, 1.88, 0.12), dark_mat
	)
	_add_box(
		shell,
		"StockroomDoorJambRight",
		Vector3(5.54, 1.44, -5.65),
		Vector3(0.12, 2.55, 0.12),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomDoorLintel",
		Vector3(4.75, 2.72, -5.65),
		Vector3(1.70, 0.12, 0.14),
		dark_mat
	)
	_add_box(
		shell, "StockroomHeader", Vector3(4.78, 2.20, -5.61), Vector3(0.76, 0.08, 0.16), trim_mat
	)
	_add_box(
		shell,
		"StockroomDoorHandle",
		Vector3(4.08, 1.10, -5.57),
		Vector3(0.08, 0.16, 0.04),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomFloorTape",
		_STOCKROOM_THRESHOLD_POSITION,
		Vector3(1.55, 0.025, 0.18),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomEmployeeStripeLeft",
		Vector3(4.22, 0.073, -6.72),
		Vector3(0.12, 0.018, 1.55),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomEmployeeStripeRight",
		Vector3(5.28, 0.073, -6.72),
		Vector3(0.12, 0.018, 1.55),
		dark_mat
	)
	_add_box(
		shell, "StockroomDoorStop", Vector3(4.75, 0.16, -5.61), Vector3(1.45, 0.14, 0.05), trim_mat
	)

	_add_box(
		shell,
		"ExpansionDoorPanel",
		Vector3(_SHELL_LEFT_X + 0.07, 1.65, 0.40),
		Vector3(0.10, 2.55, 3.55),
		shutter_mat
	)
	_add_box(
		shell,
		"ExpansionHeader",
		Vector3(_SHELL_LEFT_X + 0.14, 2.95, 0.40),
		Vector3(0.10, 0.36, 3.65),
		sign_mat
	)
	_add_label(
		shell,
		"ExpansionLabel",
		"",
		Vector3(_SHELL_LEFT_X + 0.20, 2.96, 0.40),
		34,
		Vector3(0.0, -90.0, 0.0)
	)

	_add_box(
		shell,
		"StarterAisleMat",
		Vector3(1.40, 0.065, 6.55),
		Vector3(5.70, 0.025, 1.45),
		_mat(Color(0.20, 0.13, 0.10, 1.0))
	)

	# Floor wear gives scale without fighting the customer-facing retail fixtures.
	for index: int in range(15):
		var x_line: float = -7.0 + float(index) * 1.0
		_add_box(
			shell,
			"FloorBoardSeam%02d" % index,
			Vector3(x_line, 0.072, _SHELL_CENTER_Z),
			Vector3(0.018, 0.012, 19.0),
			floor_seam_mat
		)
	for index: int in range(9):
		var z_line: float = -8.35 + float(index) * 2.05
		_add_box(
			shell,
			"FloorTrafficScuff%02d" % index,
			Vector3(0.10, 0.076, z_line),
			Vector3(6.2, 0.008, 0.035),
			floor_scuff_mat
		)

	_add_readable_zone_surfaces(shell, palette)
	_add_store_identity_posters(shell, palette)

	for index: int in range(5):
		var light_x: float = -4.8 + float(index) * 2.4
		_add_box(
			shell,
			"CeilingFluorescent%02d" % index,
			Vector3(light_x, 3.39, -0.25),
			Vector3(1.05, 0.035, 0.16),
			_mat(Color(0.96, 0.91, 0.70, 1.0), Color(1.0, 0.84, 0.42, 1.0), 0.55)
		)
	_add_omni_light(
		shell,
		"ShelfWallWarmPractical",
		Vector3(-4.60, 2.65, -9.25),
		Color(1.0, 0.76, 0.48, 1.0),
		0.52,
		3.6
	)
	_add_omni_light(
		shell,
		"ShelfEdgeCoolPractical",
		Vector3(-4.20, 1.85, -1.25),
		Color(0.66, 0.76, 1.0, 1.0),
		0.42,
		2.8
	)
	_add_omni_light(
		shell,
		"CheckoutRegisterPractical",
		Vector3(5.58, 1.55, 5.95),
		Color(1.0, 0.74, 0.48, 1.0),
		0.56,
		2.8
	)
	_add_omni_light(
		shell,
		"StockroomUtilityPractical",
		Vector3(4.95, 2.30, -8.45),
		Color(0.58, 0.74, 1.0, 1.0),
		0.62,
		3.2
	)
	_add_omni_light(
		shell,
		"EntryThresholdPractical",
		Vector3(0.0, 2.15, 8.95),
		Color(1.0, 0.78, 0.55, 1.0),
		0.28,
		2.4
	)
	_add_intentional_day_one_fixtures(shell, palette, layout_catalog)


static func _add_spawn_identity_composition(shell: Node3D, palette: Dictionary) -> void:
	var identity_panel_mat: StandardMaterial3D = palette["identity_panel"] as StandardMaterial3D
	var identity_trim_mat: StandardMaterial3D = palette["identity_trim"] as StandardMaterial3D
	var sightline_mat: StandardMaterial3D = palette["sightline"] as StandardMaterial3D
	var gold_mat: StandardMaterial3D = palette["gold"] as StandardMaterial3D
	var teal_case_mat: StandardMaterial3D = palette["teal_case"] as StandardMaterial3D
	var backroom_panel_mat: StandardMaterial3D = palette["backroom_panel"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	_add_box(
		shell,
		"StoreIdentityWallPanel",
		Vector3(-4.75, 2.20, _SHELL_BACK_Z + 0.105),
		Vector3(2.64, 1.42, 0.035),
		identity_panel_mat
	)
	_add_box(
		shell,
		"StoreIdentitySignCanopy",
		Vector3(-4.75, 2.96, _SHELL_BACK_Z + 0.19),
		Vector3(2.24, 0.12, 0.12),
		identity_trim_mat
	)
	_add_box(
		shell,
		"StoreIdentitySignUnderRail",
		Vector3(-4.75, 2.48, _SHELL_BACK_Z + 0.20),
		Vector3(2.08, 0.07, 0.10),
		gold_mat
	)
	for side: int in [-1, 1]:
		_add_box(
			shell,
			"StoreIdentitySignBracket%s" % ("Left" if side < 0 else "Right"),
			Vector3(-4.75 + float(side) * 1.06, 2.70, _SHELL_BACK_Z + 0.19),
			Vector3(0.08, 0.46, 0.10),
			identity_trim_mat
		)
	for index: int in range(3):
		_add_box(
			shell,
			"StoreIdentityCaseStripe%02d" % index,
			Vector3(-5.60 + float(index) * 0.82, 2.13, _SHELL_BACK_Z + 0.16),
			Vector3(0.44, 0.10, 0.045),
			teal_case_mat if index != 1 else gold_mat
		)
	_add_box(
		shell,
		"SpawnAisleRunner",
		Vector3(1.32, 0.080, 6.28),
		Vector3(5.78, 0.014, 1.18),
		sightline_mat
	)
	_add_box(
		shell,
		"SpawnCheckoutSightlineStrip",
		Vector3(3.52, 0.092, 6.66),
		Vector3(2.30, 0.012, 0.12),
		gold_mat
	)
	_add_box(
		shell,
		"SpawnStarterDisplaySightlineStrip",
		Vector3(-3.10, 0.092, 4.10),
		Vector3(0.16, 0.012, 3.72),
		teal_case_mat
	)
	_add_box(
		shell,
		"SpawnStockroomSightlineStrip",
		Vector3(4.74, 0.094, -4.88),
		Vector3(1.34, 0.012, 0.10),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"SpawnRetailZoneLowRail",
		Vector3(-1.70, 0.46, 2.20),
		Vector3(0.10, 0.68, 1.92),
		rubber_mat
	)
	_add_omni_light(
		shell,
		"StoreIdentitySignWashPractical",
		Vector3(-4.75, 2.50, -8.80),
		Color(1.0, 0.72, 0.40, 1.0),
		0.38,
		2.2
	)


static func _add_readable_zone_surfaces(shell: Node3D, palette: Dictionary) -> void:
	var trim_mat: StandardMaterial3D = palette["trim"] as StandardMaterial3D
	var gold_mat: StandardMaterial3D = palette["gold"] as StandardMaterial3D
	var blue_case_mat: StandardMaterial3D = palette["blue_case"] as StandardMaterial3D
	var teal_case_mat: StandardMaterial3D = palette["teal_case"] as StandardMaterial3D
	var purple_case_mat: StandardMaterial3D = palette["purple_case"] as StandardMaterial3D
	var sales_panel_mat: StandardMaterial3D = palette["sales_panel"] as StandardMaterial3D
	var shelf_cool_panel_mat: StandardMaterial3D = palette["shelf_cool_panel"] as StandardMaterial3D
	var checkout_service_mat: StandardMaterial3D = palette["checkout_service"] as StandardMaterial3D
	var backroom_panel_mat: StandardMaterial3D = palette["backroom_panel"] as StandardMaterial3D
	var backroom_floor_mat: StandardMaterial3D = palette["backroom_floor"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	_add_box(
		shell,
		"SalesFloorWarmBackWallPanel",
		Vector3(-1.15, 1.30, _SHELL_BACK_Z + 0.075),
		Vector3(3.30, 1.45, 0.030),
		sales_panel_mat
	)
	_add_box(
		shell,
		"ShelfWallCoolReadPanel",
		Vector3(-4.60, 1.34, _SHELL_BACK_Z + 0.090),
		Vector3(2.92, 1.34, 0.035),
		shelf_cool_panel_mat
	)
	_add_box(
		shell,
		"ShelfWallAccentTopRail",
		Vector3(-4.60, 2.03, _SHELL_BACK_Z + 0.13),
		Vector3(2.72, 0.055, 0.060),
		teal_case_mat
	)
	_add_box(
		shell,
		"ShelfWallBlueBayPatch",
		Vector3(-5.62, 1.28, _SHELL_BACK_Z + 0.135),
		Vector3(0.28, 0.34, 0.045),
		blue_case_mat
	)
	_add_box(
		shell,
		"ShelfWallPurpleBayPatch",
		Vector3(-3.62, 1.52, _SHELL_BACK_Z + 0.135),
		Vector3(0.30, 0.30, 0.045),
		purple_case_mat
	)
	_add_box(
		shell,
		"CheckoutServiceWarmWallPanel",
		Vector3(7.90, 1.28, 6.04),
		Vector3(0.035, 1.30, 2.10),
		checkout_service_mat
	)
	_add_box(
		shell,
		"CheckoutServiceFloorPool",
		Vector3(5.30, 0.071, 6.66),
		Vector3(2.15, 0.012, 1.42),
		_mat(Color(0.26, 0.17, 0.10, 1.0))
	)
	_add_box(
		shell,
		"CheckoutCounterEdgeLine",
		Vector3(5.03, 0.88, 6.68),
		Vector3(0.92, 0.035, 0.035),
		trim_mat
	)
	_add_box(
		shell,
		"ManagerAreaBackPanel",
		Vector3(7.90, 1.72, 7.16),
		Vector3(0.035, 0.74, 0.88),
		checkout_service_mat
	)
	_add_box(
		shell,
		"ManagerAreaLedgerRail",
		Vector3(7.86, 1.98, 7.16),
		Vector3(0.050, 0.055, 0.72),
		gold_mat
	)
	_add_box(
		shell,
		"QueueLaneWarmInlay",
		Vector3(3.82, 0.083, 7.02),
		Vector3(1.74, 0.012, 0.26),
		gold_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"QueueLaneMarkerPuck%02d" % index,
			Vector3(4.84 - float(index) * 0.94, 0.088, 7.25 - float(index) * 0.24),
			Vector3(0.26, 0.014, 0.16),
			rubber_mat
		)
	_add_box(
		shell,
		"StockroomCoolDoorRevealLeft",
		Vector3(4.04, 1.24, -5.58),
		Vector3(0.12, 1.58, 0.035),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomCoolDoorRevealRight",
		Vector3(5.46, 1.24, -5.58),
		Vector3(0.12, 1.58, 0.035),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomCoolDoorRevealHeader",
		Vector3(4.75, 2.05, -5.58),
		Vector3(1.42, 0.12, 0.035),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomUtilityFloorApron",
		Vector3(4.86, 0.069, -6.34),
		Vector3(1.66, 0.014, 1.12),
		backroom_floor_mat
	)
	_add_box(
		shell,
		"StockroomWarmPickupSightPatch",
		Vector3(4.90, 0.092, -8.50),
		Vector3(0.92, 0.020, 0.55),
		gold_mat
	)
	_add_box(
		shell,
		"EntryMutedFloorMat",
		Vector3(-0.25, 0.070, 8.82),
		Vector3(1.85, 0.012, 0.62),
		rubber_mat
	)
	_add_box(
		shell,
		"EntryWarmSightlineStrip",
		Vector3(0.0, 0.086, 9.28),
		Vector3(1.60, 0.012, 0.075),
		gold_mat
	)


static func _add_store_identity_posters(shell: Node3D, palette: Dictionary) -> void:
	var identity_panel_mat: StandardMaterial3D = palette["identity_panel"] as StandardMaterial3D
	var identity_trim_mat: StandardMaterial3D = palette["identity_trim"] as StandardMaterial3D
	var gold_mat: StandardMaterial3D = palette["gold"] as StandardMaterial3D
	var teal_case_mat: StandardMaterial3D = palette["teal_case"] as StandardMaterial3D
	var purple_case_mat: StandardMaterial3D = palette["purple_case"] as StandardMaterial3D
	var paper_white_mat: StandardMaterial3D = palette["paper_white"] as StandardMaterial3D
	_add_poster_panel(
		shell,
		"ShelfLifeTradePoster",
		Vector3(7.90, 1.84, 4.58),
		Vector3(0.0, -90.0, 0.0),
		identity_panel_mat,
		identity_trim_mat,
		gold_mat,
		teal_case_mat
	)
	_add_poster_panel(
		shell,
		"ShelfLifeRepairPoster",
		Vector3(-7.90, 1.78, -1.65),
		Vector3(0.0, 90.0, 0.0),
		identity_panel_mat,
		identity_trim_mat,
		teal_case_mat,
		purple_case_mat
	)
	_add_box(
		shell,
		"ShelfLifeQueueCardPanel",
		Vector3(7.90, 1.38, 7.08),
		Vector3(0.034, 0.50, 0.42),
		paper_white_mat
	)
	_add_box(
		shell,
		"ShelfLifeQueueCardTopRule",
		Vector3(7.86, 1.57, 7.08),
		Vector3(0.048, 0.035, 0.34),
		gold_mat
	)
	_add_box(
		shell,
		"ShelfLifeQueueCardBottomRule",
		Vector3(7.86, 1.21, 7.08),
		Vector3(0.048, 0.026, 0.30),
		identity_trim_mat
	)


static func _add_poster_panel(
	shell: Node3D,
	base_name: String,
	position: Vector3,
	rotation_degrees: Vector3,
	panel_mat: StandardMaterial3D,
	trim_mat: StandardMaterial3D,
	accent_a_mat: StandardMaterial3D,
	accent_b_mat: StandardMaterial3D
) -> void:
	var root := Node3D.new()
	root.name = base_name
	root.position = position
	root.rotation_degrees = rotation_degrees
	root.set_meta("visual_source", "store_identity_poster")
	shell.add_child(root)
	_add_box(root, "Panel", Vector3.ZERO, Vector3(0.034, 0.78, 0.54), panel_mat)
	_add_box(root, "TopRail", Vector3(-0.003, 0.33, 0.0), Vector3(0.046, 0.050, 0.48), trim_mat)
	_add_box(root, "BottomRail", Vector3(-0.003, -0.33, 0.0), Vector3(0.046, 0.042, 0.42), trim_mat)
	for index: int in range(3):
		_add_box(
			root,
			"CaseStripe%02d" % index,
			Vector3(-0.010, 0.10 - float(index) * 0.12, -0.15 + float(index) * 0.15),
			Vector3(0.050, 0.075, 0.18),
			accent_a_mat if index != 1 else accent_b_mat
		)


static func _add_intentional_day_one_fixtures(
	shell: Node3D, palette: Dictionary, layout_catalog: RefCounted
) -> void:
	var trim_mat: StandardMaterial3D = palette["trim"] as StandardMaterial3D
	var dark_mat: StandardMaterial3D = palette["dark"] as StandardMaterial3D
	var shelf_mat: StandardMaterial3D = palette["shelf"] as StandardMaterial3D
	var table_mat: StandardMaterial3D = palette["table"] as StandardMaterial3D
	var paper_mat: StandardMaterial3D = palette["paper"] as StandardMaterial3D
	var paper_white_mat: StandardMaterial3D = palette["paper_white"] as StandardMaterial3D
	var gold_mat: StandardMaterial3D = palette["gold"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	var backroom_floor_mat: StandardMaterial3D = palette["backroom_floor"] as StandardMaterial3D
	var backroom_panel_mat: StandardMaterial3D = palette["backroom_panel"] as StandardMaterial3D
	var backroom_rack_mat: StandardMaterial3D = palette["backroom_rack"] as StandardMaterial3D
	var crate_shadow_mat: StandardMaterial3D = palette["crate_shadow"] as StandardMaterial3D
	var graphite_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_DARK_DEVICE_PLASTIC
	)
	var stock_box_mat: StandardMaterial3D = palette["stock_box"] as StandardMaterial3D
	var checkout_placement: Dictionary = _starter_fixture_placement(
		layout_catalog, "starter_checkout_counter"
	)
	var display_table_placement: Dictionary = _starter_fixture_placement(
		layout_catalog, "starter_display_table"
	)
	var checkout_position: Vector3 = _placement_position(checkout_placement, _CHECKOUT_POSITION)
	var display_position: Vector3 = _placement_position(
		display_table_placement, _SHELF_TARGET_POSITION
	)

	_add_checkout_core(
		shell,
		dark_mat,
		table_mat,
		paper_mat,
		paper_white_mat,
		gold_mat,
		graphite_mat,
		checkout_position,
		layout_catalog
	)
	_add_used_game_wall_shelf(shell, trim_mat, shelf_mat)
	_add_starter_display_table_context(shell, trim_mat, dark_mat, table_mat, display_position)
	for placement: Dictionary in _starter_first_delivery_products(layout_catalog):
		_add_starter_product_visual(shell, placement)
	_add_expanded_stockroom_visual_scope(shell, palette)
	_add_stockroom_contents(
		shell,
		trim_mat,
		dark_mat,
		stock_box_mat,
		paper_white_mat,
		gold_mat,
		rubber_mat,
		backroom_floor_mat,
		backroom_panel_mat,
		backroom_rack_mat,
		crate_shadow_mat
	)
	OnboardingRouteCueRuntimeScript.apply(shell)


static func _add_expanded_stockroom_visual_scope(shell: Node3D, palette: Dictionary) -> void:
	var backroom_floor_mat: StandardMaterial3D = palette["backroom_floor"] as StandardMaterial3D
	var backroom_panel_mat: StandardMaterial3D = palette["backroom_panel"] as StandardMaterial3D
	var backroom_rack_mat: StandardMaterial3D = palette["backroom_rack"] as StandardMaterial3D
	var stock_box_mat: StandardMaterial3D = palette["stock_box"] as StandardMaterial3D
	var crate_shadow_mat: StandardMaterial3D = palette["crate_shadow"] as StandardMaterial3D
	var paper_white_mat: StandardMaterial3D = palette["paper_white"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	_add_box(
		shell,
		"StockroomExpandedCoolFloorApron",
		Vector3(_STOCKROOM_VISUAL_CENTER_X, 0.055, _STOCKROOM_VISUAL_CENTER_Z),
		Vector3(_STOCKROOM_VISUAL_WIDTH, 0.025, _STOCKROOM_VISUAL_DEPTH),
		backroom_floor_mat
	)
	_add_box(
		shell,
		"StockroomExpandedBackWallPanel",
		Vector3(_STOCKROOM_VISUAL_CENTER_X, 1.25, -9.88),
		Vector3(6.00, 1.65, 0.055),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedRightWallPanel",
		Vector3(7.44, 1.25, _STOCKROOM_VISUAL_CENTER_Z),
		Vector3(0.055, 1.65, 10.90),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedFrontPartitionLow",
		Vector3(3.20, 0.72, 1.25),
		Vector3(2.65, 1.25, 0.08),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedFrontPartitionHighA",
		Vector3(1.58, 1.72, 1.25),
		Vector3(0.56, 3.20, 0.08),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedFrontPartitionHighB",
		Vector3(6.68, 1.72, 1.25),
		Vector3(1.10, 3.20, 0.08),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedAisleShadow",
		Vector3(4.86, 0.062, -6.92),
		Vector3(1.35, 0.015, 2.75),
		crate_shadow_mat
	)
	_add_box(
		shell,
		"StockroomExpandedCeilingPanel",
		Vector3(_STOCKROOM_VISUAL_CENTER_X, 3.34, _STOCKROOM_VISUAL_CENTER_Z),
		Vector3(_STOCKROOM_VISUAL_WIDTH, 0.045, _STOCKROOM_VISUAL_DEPTH),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedOverheadRun00",
		Vector3(2.10, 2.72, -8.65),
		Vector3(2.00, 0.28, 0.58),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomExpandedOverheadRun01",
		Vector3(6.90, 2.72, -3.55),
		Vector3(0.58, 0.28, 5.50),
		backroom_rack_mat
	)
	for level: int in range(3):
		_add_box(
			shell,
			"StockroomExpandedSideRackShelf%02d" % level,
			Vector3(7.06, 0.74 + float(level) * 0.62, -3.55),
			Vector3(0.42, 0.11, 3.20),
			backroom_rack_mat
		)
	for index: int in range(4):
		_add_box(
			shell,
			"StockroomExpandedSideRackUpright%02d" % index,
			Vector3(7.04, 1.42, -4.92 + float(index) * 0.92),
			Vector3(0.11, 1.98, 0.10),
			backroom_rack_mat
		)
	_add_box(
		shell,
		"StockroomExpandedPalletZonePaint",
		Vector3(2.90, 0.066, -6.70),
		Vector3(2.20, 0.012, 1.35),
		crate_shadow_mat
	)
	_add_box(
		shell,
		"StockroomExpandedReceivingStripeA",
		Vector3(4.08, 0.071, -5.80),
		Vector3(0.06, 0.012, 2.20),
		rubber_mat
	)
	_add_box(
		shell,
		"StockroomExpandedReceivingStripeB",
		Vector3(5.72, 0.071, -5.80),
		Vector3(0.06, 0.012, 2.20),
		rubber_mat
	)
	for level: int in range(4):
		_add_box(
			shell,
			"StockroomExpandedDeepRackShelf%02d" % level,
			Vector3(2.05, 0.78 + float(level) * 0.64, -9.24),
			Vector3(1.70, 0.12, 0.48),
			backroom_rack_mat
		)
	for index: int in range(5):
		_add_box(
			shell,
			"StockroomExpandedDeepRackUpright%02d" % index,
			Vector3(1.30 + float(index) * 0.48, 1.62, -9.24),
			Vector3(0.08, 2.25, 0.12),
			backroom_rack_mat
		)
	for index: int in range(3):
		_add_box(
			shell,
			"StockroomExpandedPalletStack%02d" % index,
			Vector3(2.35 + float(index) * 0.74, 0.38 + float(index % 2) * 0.22, -6.95),
			Vector3(0.84, 0.62 + float(index % 2) * 0.34, 0.68),
			stock_box_mat if index != 1 else crate_shadow_mat
		)
	for index: int in range(4):
		_add_box(
			shell,
			"StockroomExpandedBoxWall%02d" % index,
			Vector3(6.88, 0.48 + float(index % 3) * 0.42, -7.25 + float(index) * 0.62),
			Vector3(0.50, 0.70, 0.54),
			stock_box_mat if index % 2 == 0 else crate_shadow_mat
		)
		_add_box(
			shell,
			"StockroomExpandedBoxLabel%02d" % index,
			Vector3(6.59, 0.58 + float(index % 3) * 0.42, -7.25 + float(index) * 0.62),
			Vector3(0.018, 0.10, 0.18),
			paper_white_mat
		)
	for index: int in range(4):
		var high_bin_position := (
			Vector3(2.00 + float(index) * 0.46, 2.93, -8.65)
			if index < 2
			else Vector3(6.90, 2.93, -4.55 + float(index - 2) * 1.20)
		)
		_add_box(
			shell,
			"StockroomExpandedHighBin%02d" % index,
			high_bin_position,
			Vector3(0.42, 0.34, 0.44),
			crate_shadow_mat
		)
	for index: int in range(4):
		_add_box(
			shell,
			"StockroomExpandedRackBin%02d" % index,
			Vector3(6.82, 1.04 + float(index % 2) * 0.58, -4.52 + float(index / 2) * 1.12),
			Vector3(0.36, 0.30, 0.42),
			crate_shadow_mat
		)
	_add_box(
		shell,
		"StockroomExpandedRollingLadderFrame",
		Vector3(1.62, 1.12, -4.85),
		Vector3(0.12, 2.05, 0.12),
		rubber_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"StockroomExpandedRollingLadderStep%02d" % index,
			Vector3(1.90, 0.45 + float(index) * 0.37, -4.85),
			Vector3(0.58, 0.06, 0.10),
			rubber_mat
		)


static func _add_checkout_core(
	shell: Node3D,
	dark_mat: StandardMaterial3D,
	table_mat: StandardMaterial3D,
	paper_mat: StandardMaterial3D,
	paper_white_mat: StandardMaterial3D,
	gold_mat: StandardMaterial3D,
	graphite_mat: StandardMaterial3D,
	checkout_position: Vector3,
	layout_catalog: RefCounted
) -> void:
	var screen_mat := _mat(Color(0.04, 0.16, 0.11, 1.0), Color(0.12, 0.58, 0.34, 1.0), 0.48)
	var readiness_mat := _mat(Color(0.14, 0.48, 0.28, 1.0), Color(0.22, 0.78, 0.40, 1.0), 0.42)
	var service_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE
	)
	var mat_mat: StandardMaterial3D = StarterDetailBuilderScript.material_for(
		StarterDetailBuilderScript.FAMILY_RUBBER
	)
	var checkout_offset: Vector3 = checkout_position - _CHECKOUT_POSITION
	var counter_component: Dictionary = _checkout_component(
		StoreVisualKitScript.STARTER_CHECKOUT_COUNTER
	)
	var counter_top: MeshInstance3D = _add_box(
		shell,
		"CheckoutCounterTop",
		Vector3(5.60, 0.79, 6.14) + checkout_offset,
		Vector3(1.22, 0.08, 1.12),
		table_mat
	)
	_mark_checkout_component(counter_top, counter_component)
	_add_box(
		shell,
		"CheckoutCustomerSidePanel",
		Vector3(5.60, 0.42, 6.69) + checkout_offset,
		Vector3(1.16, 0.56, 0.08),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutEmployeeSidePanel",
		Vector3(5.60, 0.42, 5.59) + checkout_offset,
		Vector3(1.16, 0.56, 0.08),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutLeftSidePanel",
		Vector3(4.97, 0.42, 6.14) + checkout_offset,
		Vector3(0.08, 0.56, 1.02),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutRightSidePanel",
		Vector3(6.23, 0.42, 6.14) + checkout_offset,
		Vector3(0.08, 0.56, 1.02),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutFrontLaminatePanel",
		Vector3(5.45, 0.43, 6.58) + checkout_offset,
		Vector3(0.92, 0.52, 0.055),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutFrontToeKick",
		Vector3(5.45, 0.13, 6.62) + checkout_offset,
		Vector3(0.84, 0.12, 0.06),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterDrawer",
		Vector3(5.68, 0.87, 5.63) + checkout_offset,
		Vector3(0.52, 0.18, 0.32),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterCashSlot",
		Vector3(5.68, 0.96, 5.45) + checkout_offset,
		Vector3(0.38, 0.03, 0.03),
		graphite_mat
	)
	_add_checkout_indicator(
		shell,
		"CheckoutCashDrawerReadyLight",
		Vector3(5.87, 0.975, 5.45) + checkout_offset,
		readiness_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterNeck",
		Vector3(5.68, 1.08, 5.59) + checkout_offset,
		Vector3(0.07, 0.19, 0.07),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterScreenBezel",
		Vector3(5.68, 1.22, 5.465) + checkout_offset,
		Vector3(0.46, 0.30, 0.025),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterScreen",
		Vector3(5.68, 1.22, 5.435) + checkout_offset,
		Vector3(0.34, 0.20, 0.025),
		screen_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterKeypad",
		Vector3(5.44, 0.99, 5.83) + checkout_offset,
		Vector3(0.22, 0.04, 0.18),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutReceiptSlip",
		Vector3(5.95, 0.945, 5.83) + checkout_offset,
		Vector3(0.22, 0.025, 0.16),
		paper_white_mat
	)
	_add_box(
		shell,
		"CheckoutManagerNamePlate",
		Vector3(5.50, 1.04, 6.615) + checkout_offset,
		Vector3(0.32, 0.08, 0.025),
		gold_mat
	)
	_add_box(
		shell,
		"CheckoutCounterPaperStack",
		Vector3(6.06, 0.89, 6.05) + checkout_offset,
		Vector3(0.22, 0.05, 0.16),
		paper_mat
	)
	_add_box(
		shell,
		"CheckoutReceiptPrinterBody",
		Vector3(5.95, 0.88, 5.83) + checkout_offset,
		Vector3(0.30, 0.10, 0.22),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutReceiptPaperRoll",
		Vector3(5.95, 0.955, 5.73) + checkout_offset,
		Vector3(0.18, 0.05, 0.05),
		paper_white_mat
	)
	_add_checkout_indicator(
		shell,
		"CheckoutPrinterReadyLight",
		Vector3(5.81, 0.955, 5.76) + checkout_offset,
		readiness_mat
	)
	_add_box(
		shell,
		"CheckoutCardReader",
		Vector3(5.32, 0.865, 6.09) + checkout_offset,
		Vector3(0.18, 0.07, 0.24),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutBarcodeScanner",
		Vector3(6.13, 0.865, 6.03) + checkout_offset,
		Vector3(0.22, 0.07, 0.10),
		graphite_mat
	)
	_add_checkout_indicator(
		shell,
		"CheckoutScannerReadyLight",
		Vector3(6.04, 0.925, 6.01) + checkout_offset,
		readiness_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerPaymentDisplay",
		Vector3(5.28, 1.02, 6.555) + checkout_offset,
		Vector3(0.32, 0.18, 0.04),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerPaymentDisplayScreen",
		Vector3(5.28, 1.02, 6.585) + checkout_offset,
		Vector3(0.24, 0.12, 0.025),
		screen_mat
	)
	_add_box(
		shell,
		"CheckoutCounterCableRun",
		Vector3(5.50, 0.842, 5.97) + checkout_offset,
		Vector3(0.38, 0.018, 0.025),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutScannerCable",
		Vector3(5.98, 0.842, 5.96) + checkout_offset,
		Vector3(0.30, 0.018, 0.025),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutBaggingSurface",
		Vector3(5.44, 0.842, 6.38) + checkout_offset,
		Vector3(0.42, 0.025, 0.28),
		service_mat
	)
	_add_box(
		shell,
		"CheckoutBagStack",
		Vector3(5.44, 0.885, 6.38) + checkout_offset,
		Vector3(0.26, 0.055, 0.18),
		paper_white_mat
	)
	_add_box(
		shell,
		"CheckoutManagerFloorMat",
		Vector3(5.95, 0.077, 5.78) + checkout_offset,
		Vector3(0.42, 0.014, 0.55),
		mat_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerFloorMat",
		Vector3(4.85, 0.077, 7.22) + checkout_offset,
		Vector3(0.58, 0.014, 0.42),
		mat_mat
	)
	_add_label(shell, "CheckoutTradeInsText", "", Vector3(5.50, 1.12, 6.58) + checkout_offset, 15)
	_add_checkout_kit_props(shell, checkout_position, layout_catalog)


static func _add_checkout_indicator(
	shell: Node3D, name: String, position: Vector3, material: StandardMaterial3D
) -> void:
	var indicator: MeshInstance3D = _add_box(
		shell, name, position, Vector3(0.055, 0.018, 0.055), material
	)
	indicator.set_meta("checkout_station_visual_only", true)
	indicator.set_meta("checkout_station_role", "readiness_indicator")


static func _add_checkout_kit_props(
	shell: Node3D, checkout_position: Vector3, layout_catalog: RefCounted
) -> void:
	var checkout_offset: Vector3 = checkout_position - _CHECKOUT_POSITION
	var slots: Array[Dictionary] = [
		{
			"name": "CheckoutKitCounterRegister",
			"id": StoreVisualKitScript.GLTF_COUNTER_REGISTER,
			"component_id": &"",
			"position": Vector3(5.64, 0.835, 5.62) + checkout_offset,
			"rotation": Vector3(0.0, -8.0, 0.0),
			"scale": Vector3(0.24, 0.24, 0.24),
		},
		{
			"name": "CheckoutKitRegisterMonitor",
			"id": StoreVisualKitScript.REGISTER,
			"component_id": StoreVisualKitScript.STARTER_REGISTER_TERMINAL,
			"position": Vector3(5.46, 0.985, 5.48) + checkout_offset,
			"rotation": Vector3(0.0, -8.0, 0.0),
			"scale": Vector3(0.72, 0.72, 0.72),
		},
		{
			"name": "CheckoutKitReceiptPrinter",
			"id": StoreVisualKitScript.RECEIPT_PRINTER,
			"component_id": StoreVisualKitScript.STARTER_RECEIPT_PRINTER,
			"position": Vector3(5.98, 0.835, 5.84) + checkout_offset,
			"rotation": Vector3(0.0, 10.0, 0.0),
			"scale": Vector3(0.82, 0.82, 0.82),
		},
		{
			"name": "CheckoutKitCardReader",
			"id": StoreVisualKitScript.CARD_READER,
			"component_id": StoreVisualKitScript.STARTER_CARD_READER,
			"position": Vector3(5.26, 0.845, 6.34) + checkout_offset,
			"rotation": Vector3(0.0, -18.0, 0.0),
			"scale": Vector3(0.50, 0.50, 0.50),
		},
		{
			"name": "CheckoutKitBarcodeScanner",
			"id": StoreVisualKitScript.BARCODE_SCANNER,
			"position": Vector3(6.16, 0.855, 6.08) + checkout_offset,
			"rotation": Vector3(0.0, -34.0, 0.0),
			"scale": Vector3(0.72, 0.72, 0.72),
		},
		{
			"name": "CheckoutKitPaperStack",
			"id": StoreVisualKitScript.PAPER_STACK,
			"position": Vector3(5.96, 0.848, 6.32) + checkout_offset,
			"rotation": Vector3(0.0, 16.0, 0.0),
			"scale": Vector3(0.70, 0.70, 0.70),
		},
		{
			"name": "CheckoutKitTapeRoll",
			"id": StoreVisualKitScript.TAPE_ROLL,
			"position": Vector3(6.22, 0.860, 5.72) + checkout_offset,
			"rotation": Vector3(0.0, 28.0, 0.0),
			"scale": Vector3(0.62, 0.62, 0.62),
		},
		{
			"name": "CheckoutKitManagerClipboard",
			"id": StoreVisualKitScript.CLIPBOARD,
			"position": Vector3(5.28, 0.842, 5.78) + checkout_offset,
			"rotation": Vector3(0.0, -24.0, 0.0),
			"scale": Vector3(0.66, 0.66, 0.66),
		},
	]
	for slot: Dictionary in slots:
		var component_id: StringName = slot.get("component_id", &"") as StringName
		var position: Vector3 = slot["position"] as Vector3
		var rotation: Vector3 = slot["rotation"] as Vector3
		var scale: Vector3 = slot["scale"] as Vector3
		if not String(component_id).is_empty():
			var placement: Dictionary = _starter_fixture_placement(
				layout_catalog, String(component_id)
			)
			position = _placement_position(placement, position)
			rotation = _placement_rotation(placement, rotation)
			scale = _placement_scale(placement, scale)
		_add_checkout_visual_prop(
			shell,
			str(slot["name"]),
			slot["id"] as StringName,
			position,
			rotation,
			scale,
			_checkout_component(component_id)
		)


static func _add_checkout_visual_prop(
	parent: Node3D,
	name: String,
	visual_id: StringName,
	position: Vector3,
	rotation_degrees: Vector3,
	scale: Vector3,
	component: Dictionary = {}
) -> Node3D:
	var visual: Node3D = _add_store_visual(
		parent, name, visual_id, position, scale, rotation_degrees
	)
	visual.set_meta("checkout_station_visual_only", true)
	visual.set_meta("checkout_station_slot", name)
	_mark_checkout_component(visual, component)
	_strip_interaction_descendants(visual)
	return visual


static func _checkout_component(concept_id: StringName) -> Dictionary:
	if String(concept_id).is_empty():
		return {}
	for component: Dictionary in StoreVisualKitScript.starter_checkout_station_components():
		if component.get("concept_id", &"") == concept_id:
			return component
	return {}


static func _mark_checkout_component(node: Node, component: Dictionary) -> void:
	if node == null or component.is_empty():
		return
	node.set_meta("starter_checkout_component_id", component.get("concept_id", &""))
	node.set_meta("starter_checkout_visual_id", component.get("visual_id", &""))
	node.set_meta("checkout_station_visual_only", true)
	node.set_meta("day_one_default_checkout_piece", bool(component.get("day_one_default", false)))


static func _strip_interaction_descendants(node: Node) -> void:
	for child: Node in node.get_children().duplicate():
		if (
			child is Area3D
			or child is CollisionShape3D
			or child is PhysicsBody3D
			or child is NavigationObstacle3D
			or child is Interactable
		):
			child.free()
			continue
		_strip_interaction_descendants(child)


static func _add_used_game_wall_shelf(
	shell: Node3D, trim_mat: StandardMaterial3D, shelf_mat: StandardMaterial3D
) -> void:
	_add_box(
		shell,
		"StarterUsedShelfBacker",
		Vector3(-4.60, 1.34, -9.865),
		Vector3(2.48, 1.18, 0.045),
		_mat(Color(0.16, 0.11, 0.08, 1.0))
	)
	for rail: int in range(3):
		_add_box(
			shell,
			"StarterUsedShelfRail%02d" % rail,
			Vector3(-4.60, 0.88 + float(rail) * 0.44, -9.38),
			Vector3(2.34, 0.065, 0.13),
			shelf_mat
		)
	_add_box(
		shell,
		"StarterUsedShelfTopLip",
		Vector3(-4.60, 1.78, -9.31),
		Vector3(2.42, 0.055, 0.07),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfMiddleLip",
		Vector3(-4.60, 1.32, -9.31),
		Vector3(2.42, 0.055, 0.07),
		trim_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"StarterUsedEmptySlot%02d" % index,
			Vector3(-5.18 + float(index) * 0.48, 1.00, -9.33),
			Vector3(0.30, 0.18, 0.026),
			_mat(Color(0.10, 0.075, 0.055, 1.0))
		)
		_add_box(
			shell,
			"StarterUsedShelfPriceTag%02d" % index,
			Vector3(-5.18 + float(index) * 0.48, 0.82, -9.28),
			Vector3(0.18, 0.052, 0.018),
			StarterDetailBuilderScript.material_for(
				StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM
			)
		)
	_add_box(
		shell,
		"StarterUsedShelfLeftDivider",
		Vector3(-5.74, 1.33, -9.32),
		Vector3(0.045, 0.92, 0.09),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfCenterDivider",
		Vector3(-4.60, 1.33, -9.32),
		Vector3(0.045, 0.92, 0.09),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfRightDivider",
		Vector3(-3.46, 1.33, -9.32),
		Vector3(0.045, 0.92, 0.09),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfBottomLip",
		Vector3(-4.60, 0.86, -9.31),
		Vector3(2.42, 0.055, 0.08),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfRightEmptyBay",
		Vector3(-3.72, 1.43, -9.33),
		Vector3(0.34, 0.23, 0.028),
		_mat(Color(0.10, 0.075, 0.055, 1.0))
	)
	_add_box(
		shell,
		"StarterUsedShelfRightPriceTag",
		Vector3(-3.72, 1.20, -9.28),
		Vector3(0.20, 0.055, 0.018),
		StarterDetailBuilderScript.material_for(StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM)
	)
	_add_box(
		shell,
		"StarterUsedShelfFloorFootprint",
		Vector3(-4.60, 0.078, -8.45),
		Vector3(2.55, 0.012, 0.34),
		_mat(Color(0.13, 0.09, 0.06, 1.0))
	)


static func _add_starter_display_table_context(
	shell: Node3D,
	trim_mat: StandardMaterial3D,
	dark_mat: StandardMaterial3D,
	table_mat: StandardMaterial3D,
	display_position: Vector3
) -> void:
	var display_center := display_position + Vector3(0.0, 0.0, 0.08)
	_add_box(
		shell,
		"StarterDisplayTableFootprint",
		display_center + Vector3(0.0, 0.078, 0.0),
		Vector3(2.82, 0.012, 1.18),
		_mat(Color(0.12, 0.09, 0.06, 1.0))
	)
	_add_box(
		shell,
		"StarterDisplayTableBacker",
		display_center + Vector3(0.0, 1.22, -0.44),
		Vector3(2.10, 0.42, 0.045),
		_mat(Color(0.17, 0.11, 0.07, 1.0))
	)
	_add_box(
		shell,
		"StarterDisplayTableBackRail",
		display_center + Vector3(0.0, 1.41, -0.37),
		Vector3(2.18, 0.055, 0.10),
		trim_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableFrontLip",
		display_center + Vector3(0.0, 1.02, 0.46),
		Vector3(2.42, 0.075, 0.10),
		table_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableLeftDivider",
		display_center + Vector3(-0.82, 1.17, 0.08),
		Vector3(0.045, 0.30, 0.70),
		trim_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableRightDivider",
		display_center + Vector3(0.82, 1.17, 0.08),
		Vector3(0.045, 0.30, 0.70),
		trim_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableRiser",
		display_center + Vector3(-0.48, 1.23, -0.12),
		Vector3(0.58, 0.10, 0.42),
		dark_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableTray",
		display_center + Vector3(0.55, 1.09, 0.10),
		Vector3(0.64, 0.055, 0.48),
		table_mat
	)
	for index: int in range(2):
		_add_box(
			shell,
			"StarterDisplayEmptySlot%02d" % index,
			display_center + Vector3(0.16 + float(index) * 0.48, 1.015, 0.43),
			Vector3(0.22, 0.035, 0.030),
			_mat(Color(0.12, 0.085, 0.055, 1.0))
		)


static func _add_starter_product_visual(shell: Node3D, placement: Dictionary) -> void:
	var item_id: String = str(placement.get("product_item_id", ""))
	var visual: Node3D = ProductVisualFactoryScript.create_visual_for_item(
		_starter_product_visual_data(item_id, placement)
	)
	if visual == null:
		return
	visual.name = str(placement.get("name", item_id))
	visual.position = _placement_position(placement, Vector3.ZERO)
	visual.rotation_degrees = _placement_rotation(placement, Vector3.ZERO)
	visual.scale = _placement_scale(placement, Vector3.ONE)
	visual.set_meta("product_item_id", item_id)
	visual.set_meta("route_role", str(placement.get("route_role", "starter_sale_item")))
	visual.set_meta("stock_state", str(placement.get("stock_state", "")))
	if placement.has("delivery_index"):
		visual.set_meta("delivery_index", int(placement.get("delivery_index", -1)))
	visual.add_to_group("product_display")
	_mute_product_labels(visual)
	shell.add_child(visual)


static func _starter_product_visual_data(item_id: String, placement: Dictionary) -> Dictionary:
	var data: Dictionary = {}
	if _STARTER_PRODUCT_FALLBACKS.has(item_id):
		data = (_STARTER_PRODUCT_FALLBACKS[item_id] as Dictionary).duplicate(true)
	data["definition_id"] = item_id
	data["route_role"] = str(placement.get("route_role", "starter_sale_item"))
	data["stock_state"] = str(placement.get("stock_state", ""))
	data["show_price_tag"] = bool(placement.get("show_price_tag", true))
	var entry: Dictionary = ContentRegistry.get_entry(StringName(item_id))
	if entry.is_empty():
		return data
	data["display_name"] = str(entry.get("item_name", data.get("display_name", item_id)))
	data["category"] = str(entry.get("category", data.get("category", "")))
	data["platform_id"] = str(entry.get("platform_id", data.get("platform_id", "")))
	data["price_cents"] = int(
		round(float(entry.get("used_price", entry.get("base_price", 0.0))) * 100.0)
	)
	for key: String in [
		"box_art_key",
		"platform_visual_id",
		"visual_alias_id",
		"visual_presentation",
	]:
		if entry.has(key):
			data[key] = entry[key]
	return data


static func _mute_product_labels(node: Node) -> void:
	var label: Label3D = node as Label3D
	if label != null:
		label.text = ""
	for child: Node in node.get_children():
		_mute_product_labels(child)


static func _add_stockroom_contents(
	shell: Node3D,
	trim_mat: StandardMaterial3D,
	dark_mat: StandardMaterial3D,
	stock_box_mat: StandardMaterial3D,
	paper_white_mat: StandardMaterial3D,
	gold_mat: StandardMaterial3D,
	rubber_mat: StandardMaterial3D,
	backroom_floor_mat: StandardMaterial3D,
	backroom_panel_mat: StandardMaterial3D,
	backroom_rack_mat: StandardMaterial3D,
	crate_shadow_mat: StandardMaterial3D
) -> void:
	_add_box(
		shell,
		"StockroomCoolFloorApron",
		Vector3(4.58, 0.079, -7.75),
		Vector3(2.52, 0.014, 4.30),
		backroom_floor_mat
	)
	_add_box(
		shell,
		"StockroomBackWallCoolPanel",
		Vector3(4.58, 1.44, -9.88),
		Vector3(2.34, 1.74, 0.026),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomLeftWallCoolPanel",
		Vector3(3.25, 1.36, -7.75),
		Vector3(0.026, 1.58, 3.70),
		backroom_panel_mat
	)
	var stockroom_shelf: Node3D = _add_store_visual(
		shell,
		"StockroomBackRackKit",
		StoreVisualKitScript.STOCKROOM_SHELF,
		Vector3(4.52, 0.0, -9.55),
		Vector3.ONE
	)
	_flatten_visual_children(stockroom_shelf, shell)
	for index: int in range(4):
		var row: int = index / 2
		var column: int = index % 2
		_add_box(
			shell,
			"StockroomTallCrate%02d" % index,
			Vector3(3.48 + float(column) * 0.26, 0.37 + float(row) * 0.28, -8.35),
			Vector3(0.22, 0.24, 0.28),
			stock_box_mat if index % 2 == 0 else crate_shadow_mat
		)
		_add_box(
			shell,
			"StockroomTallCrateFace%02d" % index,
			Vector3(3.48 + float(column) * 0.26, 0.40 + float(row) * 0.28, -8.19),
			Vector3(0.13, 0.04, 0.018),
			paper_white_mat
		)
	_add_box(
		shell,
		"StockroomOverheadShelf",
		Vector3(4.72, 2.18, -8.58),
		Vector3(1.58, 0.06, 0.32),
		backroom_rack_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"StockroomOverheadBin%02d" % index,
			Vector3(4.18 + float(index) * 0.48, 2.34, -8.58),
			Vector3(0.28, 0.20, 0.24),
			crate_shadow_mat
		)
	for index: int in range(6):
		var row: int = index / 3
		var column: int = index % 3
		_add_box(
			shell,
			"StockroomSupplyBox%02d" % index,
			Vector3(4.02 + float(column) * 0.34, 1.02 + float(row) * 0.44, -9.32),
			Vector3(0.26, 0.20, 0.24),
			stock_box_mat if index % 2 == 0 else crate_shadow_mat
		)
	_add_box(
		shell,
		"StockroomReceivingTableTop",
		Vector3(5.50, 0.78, -7.95),
		Vector3(0.48, 0.10, 0.70),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayFloorPlate",
		Vector3(4.90, 0.091, -8.70),
		Vector3(1.02, 0.018, 0.72),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayBackLightPanel",
		Vector3(4.90, 1.10, -9.82),
		Vector3(1.18, 1.18, 0.024),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayLabelPlate",
		Vector3(4.90, 1.76, -9.78),
		Vector3(0.72, 0.18, 0.030),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayLeftGuide",
		Vector3(4.27, 0.105, -8.70),
		Vector3(0.08, 0.018, 0.78),
		rubber_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayRightGuide",
		Vector3(5.53, 0.105, -8.70),
		Vector3(0.08, 0.018, 0.78),
		rubber_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTableLegA",
		Vector3(5.34, 0.39, -7.70),
		Vector3(0.055, 0.68, 0.055),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTableLegB",
		Vector3(5.66, 0.39, -8.20),
		Vector3(0.055, 0.68, 0.055),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTapeRoll",
		Vector3(5.40, 0.86, -7.83),
		Vector3(0.12, 0.08, 0.12),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomTapeDispenserBase",
		Vector3(5.40, 0.84, -7.97),
		Vector3(0.22, 0.05, 0.10),
		crate_shadow_mat
	)
	_add_box(
		shell,
		"StockroomPackingClipboard",
		Vector3(5.56, 0.86, -8.09),
		Vector3(0.18, 0.035, 0.24),
		paper_white_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonBase",
		Vector3(5.82, 0.92, -8.02),
		Vector3(0.36, 0.12, 0.26),
		stock_box_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonInterior",
		Vector3(5.82, 1.005, -8.02),
		Vector3(0.30, 0.025, 0.20),
		crate_shadow_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonFrontFlap",
		Vector3(5.82, 1.03, -7.84),
		Vector3(0.34, 0.035, 0.14),
		stock_box_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonBackFlap",
		Vector3(5.82, 1.03, -8.20),
		Vector3(0.34, 0.035, 0.14),
		stock_box_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonLeftFlap",
		Vector3(5.58, 1.03, -8.02),
		Vector3(0.12, 0.035, 0.24),
		stock_box_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonRightFlap",
		Vector3(6.06, 1.03, -8.02),
		Vector3(0.12, 0.035, 0.24),
		stock_box_mat
	)
	for index: int in range(3):
		var case_mat: StandardMaterial3D = (
			dark_mat if index == 0 else backroom_rack_mat if index == 1 else crate_shadow_mat
		)
		_add_box(
			shell,
			"StockroomDeliveryCase%02d" % index,
			Vector3(5.73 + float(index) * 0.09, 1.06, -8.02),
			Vector3(0.065, 0.085, 0.16),
			case_mat
		)
	for index: int in range(2):
		_add_box(
			shell,
			"StockroomPackingSlip%02d" % index,
			Vector3(5.42 + float(index) * 0.14, 0.895, -8.20),
			Vector3(0.10, 0.014, 0.15),
			paper_white_mat
		)
		_add_box(
			shell,
			"StockroomClosedReserveCarton%02d" % index,
			Vector3(3.58 + float(index) * 0.34, 0.72, -9.20),
			Vector3(0.28, 0.24, 0.34),
			stock_box_mat
		)
		_add_box(
			shell,
			"StockroomReserveCartonTape%02d" % index,
			Vector3(3.58 + float(index) * 0.34, 0.85, -9.20),
			Vector3(0.035, 0.018, 0.30),
			gold_mat
		)
	_add_box(
		shell,
		"StockroomSortingMat",
		Vector3(4.12, 0.074, -7.35),
		Vector3(0.62, 0.018, 1.10),
		rubber_mat
	)
	_add_box(
		shell, "StockroomWallRack", Vector3(3.30, 1.52, -7.90), Vector3(0.10, 0.86, 1.30), trim_mat
	)
	_add_box(
		shell,
		"StockroomHandTruckHint",
		Vector3(5.68, 0.54, -6.45),
		Vector3(0.10, 0.72, 0.08),
		rubber_mat
	)
	_add_box(
		shell,
		"StockroomHandTruckToe",
		Vector3(5.62, 0.13, -6.61),
		Vector3(0.38, 0.05, 0.12),
		rubber_mat
	)
	_add_label(
		shell, "StockroomWallTaskText", "", Vector3(5.80, 1.87, -6.45), 18, Vector3(0.0, -90.0, 0.0)
	)


static func _add_wall(
	parent: Node3D, name: String, position: Vector3, size: Vector3, material: StandardMaterial3D
) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = position
	parent.add_child(body)
	_add_mesh_box(body, "Visual", Vector3.ZERO, size, material)
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)


static func _add_box(
	parent: Node3D, name: String, position: Vector3, size: Vector3, material: StandardMaterial3D
) -> MeshInstance3D:
	return _add_mesh_box(parent, name, position, size, material)


static func _add_product_box(
	parent: Node3D, name: String, position: Vector3, size: Vector3, material: StandardMaterial3D
) -> Node3D:
	var visual := Node3D.new()
	visual.name = name
	visual.position = position
	visual.set_meta("visual_source", "plain_case")
	visual.add_to_group("product_display")
	parent.add_child(visual)
	_add_mesh_box(visual, "Case", Vector3.ZERO, size, material)
	_add_mesh_box(
		visual,
		"SpineStripe",
		Vector3(0.0, size.y * 0.22, size.z * 0.56),
		Vector3(size.x * 0.70, size.y * 0.10, size.z * 0.16),
		_mat(Color(0.92, 0.72, 0.34, 1.0))
	)
	return visual


static func _add_store_visual(
	parent: Node3D,
	name: String,
	visual_id: StringName,
	position: Vector3,
	scale: Vector3,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> Node3D:
	var visual: Node3D = StoreVisualKitScript.instantiate(visual_id) as Node3D
	if visual == null:
		push_error(
			"ExpandableStoreShellRuntime: visual '%s' missing from StoreVisualKit" % visual_id
		)
		visual = Node3D.new()
	visual.name = name
	visual.position = position
	visual.rotation_degrees = rotation_degrees
	visual.scale = scale
	visual.set_meta("visual_source", "store_visual_kit")
	visual.set_meta("store_visual_id", visual_id)
	parent.add_child(visual)
	return visual


static func _flatten_visual_children(source: Node3D, target: Node3D) -> void:
	if source == null or target == null:
		return
	var source_position: Vector3 = source.position
	for child: Node in source.get_children().duplicate():
		var child_3d: Node3D = child as Node3D
		if child_3d != null:
			child_3d.position += source_position
		source.remove_child(child)
		target.add_child(child)
	source.queue_free()


static func _add_plane_prop(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector2,
	material: StandardMaterial3D,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	mesh_instance.position = position
	mesh_instance.rotation_degrees = rotation_degrees
	var mesh := PlaneMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.set_meta("visual_source", "authored_surface")
	parent.add_child(mesh_instance)
	return mesh_instance


static func _add_mesh_box(
	parent: Node3D, name: String, position: Vector3, size: Vector3, material: StandardMaterial3D
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	mesh_instance.position = position
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	if StarterDetailBuilderScript.material_family_ids().has(StringName(material.resource_name)):
		StarterDetailBuilderScript.apply_visual_metadata(
			mesh_instance, StringName(material.resource_name), _detail_role_for_size(size)
		)
	parent.add_child(mesh_instance)
	return mesh_instance


static func _detail_role_for_size(size: Vector3) -> StringName:
	var smallest: float = minf(size.x, minf(size.y, size.z))
	if smallest <= StarterDetailBuilderScript.MIN_DETAIL_THICKNESS + 0.006:
		return StarterDetailBuilderScript.ROLE_SEAM
	if size.y <= StarterDetailBuilderScript.MAX_DETAIL_THICKNESS:
		return StarterDetailBuilderScript.ROLE_LIP
	return StarterDetailBuilderScript.ROLE_PANEL


static func _add_omni_light(
	parent: Node3D, name: String, position: Vector3, color: Color, energy: float, omni_range: float
) -> void:
	var light := OmniLight3D.new()
	light.name = name
	light.position = position
	light.light_color = color
	light.light_energy = energy
	light.omni_range = omni_range
	parent.add_child(light)


static func _add_label(
	parent: Node3D,
	name: String,
	text: String,
	position: Vector3,
	font_size: int,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> void:
	var label := Label3D.new()
	label.name = name
	label.text = text
	label.position = position
	label.rotation_degrees = rotation_degrees
	label.pixel_size = 0.006
	label.font_size = font_size
	label.modulate = Color(1.0, 0.86, 0.46, 1.0)
	label.outline_size = 6
	label.outline_modulate = Color(0.05, 0.04, 0.03, 1.0)
	label.double_sided = false
	label.shaded = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)


static func _mat(
	albedo: Color, emission: Color = Color.TRANSPARENT, emission_energy: float = 0.0
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.86
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material


static func _glass_mat(albedo: Color) -> StandardMaterial3D:
	var material := _mat(albedo)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	return material
