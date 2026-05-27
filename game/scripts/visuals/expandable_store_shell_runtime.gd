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
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const OnboardingRouteCueRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/onboarding_route_cue_runtime.gd"
)

const ROOT_NAME: StringName = &"ExpandableStoreShell"
const _STARTER_PRODUCT_FALLBACKS: Dictionary = {
	"console_neo_ignite": {
		"display_name": "Neo Ignite Console (Working)",
		"category": "consoles",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"price_cents": 11900,
	},
	"neo_ignite_motorway_kings_loose": {
		"display_name": "Motorway Kings",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"box_art_key": "motorway_kings_neo_ignite",
		"price_cents": 1600,
	},
	"neo_ignite_kingdom_embers_loose": {
		"display_name": "Kingdom of Embers",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"price_cents": 1800,
	},
	"neo_ignite_torque_force_3_loose": {
		"display_name": "Torque Force 3",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"price_cents": 1100,
	},
	"neo_ignite_gridiron_2005_loose": {
		"display_name": "Gridiron Season 2005",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"price_cents": 500,
	},
}
const _SHELL_WIDTH: float = 12.0
const _SHELL_DEPTH: float = 17.5
const _SHELL_CENTER_Z: float = 1.10
const _SHELL_LEFT_X: float = -6.0
const _SHELL_RIGHT_X: float = 6.0
const _SHELL_BACK_Z: float = -7.65
const _SHELL_FRONT_Z: float = 9.85
const _PLAYER_BOUNDS_MIN: Vector3 = Vector3(-5.45, 0.0, -7.30)
const _PLAYER_BOUNDS_MAX: Vector3 = Vector3(5.45, 0.0, 8.65)
const _PLAYER_SPAWN_POSITION: Vector3 = Vector3(0.0, 0.0, 7.85)
const _ENTRANCE_POSITION: Vector3 = Vector3(0.0, 0.0, 9.62)
const _ENTRY_AREA_POSITION: Vector3 = Vector3(0.0, 1.2, 9.05)
const _CHECKOUT_POSITION: Vector3 = Vector3(4.25, 0.0, 5.55)
const _CHECKOUT_SERVICE_POSITION: Vector3 = Vector3(3.55, 0.0, 6.65)
const _SHELF_TARGET_POSITION: Vector3 = Vector3(-2.65, 0.0, 1.05)
const _STOCKROOM_PICKUP_POSITION: Vector3 = Vector3(4.80, 0.0, -6.85)
const _STOCKROOM_THRESHOLD_POSITION: Vector3 = Vector3(4.75, 0.06, -4.38)
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
	_hide_authored_visual_roots(store)
	_move_starter_anchors(store)
	var shell: Node3D = _ensure_shell_root(store)
	_rebuild_shell(shell)


static func _hide_authored_visual_roots(store: Node) -> void:
	for node_path: String in _HIDDEN_AUTHORED_VISUAL_ROOTS:
		var node: Node3D = store.get_node_or_null(NodePath(node_path)) as Node3D
		if node != null:
			node.visible = false


static func _move_starter_anchors(store: Node) -> void:
	_set_position(store, "PlayerEntrySpawn", _PLAYER_SPAWN_POSITION)
	_set_rotation_degrees(store, "PlayerEntrySpawn", Vector3.ZERO)
	_set_player_bounds(store, _PLAYER_BOUNDS_MIN, _PLAYER_BOUNDS_MAX)
	_set_position(store, "Checkout", _CHECKOUT_POSITION)
	_set_scale(store, "Checkout", _ANCHOR_SCALE_CHECKOUT)
	_set_position(store, "checkout_counter", _CHECKOUT_POSITION)
	_set_scale(store, "checkout_counter", _ANCHOR_SCALE_CHECKOUT)
	_set_position(store, "RegisterArea", _CHECKOUT_SERVICE_POSITION + Vector3(0.0, 1.0, 0.0))
	_set_position(store, "StoreSessionDayOneCustomer", _CHECKOUT_SERVICE_POSITION)
	_set_global_position(
		store,
		"Checkout/StoreSessionCustomerFloorMat",
		_CHECKOUT_SERVICE_POSITION + Vector3(0.0, 0.01, 0.0)
	)
	_set_position(store, "StoreSessionDayEndTrigger", _CHECKOUT_POSITION + Vector3(0.0, 1.05, 0.0))
	_set_position(store, "StoreSessionRestockShelf", _SHELF_TARGET_POSITION)
	_set_rotation_degrees(store, "StoreSessionRestockShelf", Vector3(0.0, -8.0, 0.0))
	_hide_node(store, "StoreSessionRestockShelf/RestockCrate")
	_set_position(store, "StoreSessionBackroomPickup", _STOCKROOM_PICKUP_POSITION)
	_set_position(store, "EntranceDoor", _ENTRANCE_POSITION)
	_hide_node(store, "EntranceDoor/DoorMesh")
	_hide_node(store, "EntranceDoor/StaticBody3D")
	_set_position(store, "EntryArea", _ENTRY_AREA_POSITION)
	_set_position(store, "QueueMarker1", _CHECKOUT_SERVICE_POSITION)
	_set_position(store, "QueueMarker2", _CHECKOUT_SERVICE_POSITION + Vector3(-0.95, 0.0, 0.25))
	_set_position(store, "QueueMarker3", _CHECKOUT_SERVICE_POSITION + Vector3(-1.90, 0.0, 0.50))
	_set_position(store, "FrontLaneQueue", _CHECKOUT_SERVICE_POSITION + Vector3(-0.55, 0.0, -0.05))
	_set_position(store, "BackroomUtilityLight", Vector3(4.80, 2.35, -6.85))
	_set_position(store, "CheckoutLaneSpotlight", Vector3(3.65, 3.1, 6.15))
	_set_position(store, "FluorescentKeyLight", Vector3(0.0, 3.25, 1.0))
	_set_position(store, "WarmNeonFill", Vector3(-3.8, 2.1, 0.8))
	_set_position(store, "GreenNeonFill", Vector3(4.7, 2.2, 5.3))
	_set_customer_nav(store)


static func _set_customer_nav(store: Node) -> void:
	_set_position(store, "StoreStaffConfig/RegisterPoint", _CHECKOUT_SERVICE_POSITION)
	_set_position(store, "StoreStaffConfig/BackroomPoint", _STOCKROOM_PICKUP_POSITION)
	_set_position(store, "StoreStaffConfig/GreeterPoint", Vector3(0.0, 0.0, 7.65))
	_set_position(
		store, "CustomerNavConfig/EntryPoint", _ENTRY_AREA_POSITION + Vector3(0.0, -1.15, 0.0)
	)
	_set_position(
		store,
		"CustomerNavConfig/BrowseWaypoint01",
		_SHELF_TARGET_POSITION + Vector3(0.0, 0.05, 0.0)
	)
	_set_position(store, "CustomerNavConfig/BrowseWaypoint02", Vector3(-3.85, 0.05, -3.45))
	_set_position(store, "CustomerNavConfig/BrowseWaypoint03", Vector3(0.40, 0.05, -1.35))
	_set_position(store, "CustomerNavConfig/BrowseWaypoint04", Vector3(-4.45, 0.05, 2.65))
	_set_position(
		store,
		"CustomerNavConfig/CheckoutApproach",
		_CHECKOUT_SERVICE_POSITION + Vector3(0.0, 0.05, 0.0)
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


static func _rebuild_shell(shell: Node3D) -> void:
	var wall_mat: StandardMaterial3D = _mat(Color(0.50, 0.46, 0.39, 1.0))
	var trim_mat: StandardMaterial3D = _mat(Color(0.15, 0.10, 0.07, 1.0))
	var floor_mat: StandardMaterial3D = _mat(Color(0.46, 0.28, 0.15, 1.0))
	var ceiling_mat: StandardMaterial3D = _mat(Color(0.60, 0.57, 0.51, 1.0))
	var shutter_mat: StandardMaterial3D = _mat(Color(0.20, 0.17, 0.22, 1.0))
	var sign_mat: StandardMaterial3D = _mat(Color(0.34, 0.18, 0.05, 1.0))
	var dark_mat: StandardMaterial3D = _mat(Color(0.12, 0.10, 0.09, 1.0))
	var shelf_mat: StandardMaterial3D = _mat(Color(0.24, 0.14, 0.07, 1.0))
	var table_mat: StandardMaterial3D = _mat(Color(0.48, 0.30, 0.14, 1.0))
	var paper_mat: StandardMaterial3D = _mat(Color(0.92, 0.74, 0.46, 1.0))
	var blue_case_mat: StandardMaterial3D = _mat(Color(0.05, 0.12, 0.32, 1.0))
	var green_case_mat: StandardMaterial3D = _mat(Color(0.03, 0.23, 0.15, 1.0))
	var red_case_mat: StandardMaterial3D = _mat(Color(0.35, 0.08, 0.05, 1.0))
	var stock_box_mat: StandardMaterial3D = _mat(Color(0.56, 0.36, 0.18, 1.0))
	var backroom_floor_mat: StandardMaterial3D = _mat(Color(0.23, 0.28, 0.31, 1.0))
	var backroom_panel_mat: StandardMaterial3D = _mat(Color(0.31, 0.36, 0.38, 1.0))
	var backroom_rack_mat: StandardMaterial3D = _mat(Color(0.24, 0.28, 0.30, 1.0))
	var crate_shadow_mat: StandardMaterial3D = _mat(Color(0.17, 0.18, 0.18, 1.0))
	var gold_mat: StandardMaterial3D = _mat(
		Color(1.0, 0.78, 0.30, 1.0), Color(1.0, 0.63, 0.18, 1.0), 0.35
	)
	var paper_white_mat: StandardMaterial3D = _mat(Color(0.96, 0.90, 0.74, 1.0))
	var purple_case_mat: StandardMaterial3D = _mat(Color(0.26, 0.12, 0.34, 1.0))
	var teal_case_mat: StandardMaterial3D = _mat(Color(0.04, 0.30, 0.32, 1.0))
	var rubber_mat: StandardMaterial3D = _mat(Color(0.05, 0.055, 0.055, 1.0))
	var storefront_frame_mat: StandardMaterial3D = _mat(Color(0.20, 0.17, 0.14, 1.0))
	var storefront_metal_mat: StandardMaterial3D = _mat(Color(0.62, 0.46, 0.25, 1.0))
	var storefront_threshold_mat: StandardMaterial3D = _mat(Color(0.30, 0.22, 0.15, 1.0))
	var storefront_glass_mat: StandardMaterial3D = _glass_mat(Color(0.38, 0.47, 0.50, 0.15))
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
		"stock_box": stock_box_mat,
		"gold": gold_mat,
		"paper_white": paper_white_mat,
		"purple_case": purple_case_mat,
		"teal_case": teal_case_mat,
		"rubber": rubber_mat,
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
		Vector3(-4.15, 1.72, _SHELL_FRONT_Z),
		Vector3(3.7, 3.45, 0.12),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterFrontWallRight",
		Vector3(4.15, 1.72, _SHELL_FRONT_Z),
		Vector3(3.7, 3.45, 0.12),
		wall_mat
	)

	_add_box(
		shell,
		"BackWallTrim",
		Vector3(0.0, 0.68, _SHELL_BACK_Z + 0.09),
		Vector3(11.6, 0.08, 0.10),
		trim_mat
	)
	_add_box(
		shell,
		"LeftWallTrim",
		Vector3(_SHELL_LEFT_X + 0.09, 0.68, _SHELL_CENTER_Z),
		Vector3(0.10, 0.08, 17.0),
		trim_mat
	)
	_add_box(
		shell,
		"RightWallTrim",
		Vector3(_SHELL_RIGHT_X - 0.09, 0.68, _SHELL_CENTER_Z),
		Vector3(0.10, 0.08, 17.0),
		trim_mat
	)
	_add_box(
		shell,
		"EntryThreshold",
		Vector3(0.0, 0.047, 9.52),
		Vector3(2.10, 0.025, 0.26),
		storefront_threshold_mat
	)
	_add_box(
		shell,
		"FrontDoorFrameLeft",
		Vector3(-1.08, 1.42, 9.76),
		Vector3(0.055, 2.72, 0.09),
		storefront_frame_mat
	)
	_add_box(
		shell,
		"FrontDoorFrameRight",
		Vector3(1.08, 1.42, 9.76),
		Vector3(0.055, 2.72, 0.09),
		storefront_frame_mat
	)
	_add_box(
		shell,
		"FrontDoorFrameTop",
		Vector3(0.0, 2.76, 9.76),
		Vector3(2.20, 0.065, 0.09),
		storefront_frame_mat
	)
	_add_wall(
		shell,
		"StarterGlassDoorBlocker",
		Vector3(0.0, 1.40, 9.82),
		Vector3(1.92, 2.18, 0.035),
		storefront_glass_mat
	)
	_add_box(
		shell,
		"FrontDoorPushPlate",
		Vector3(0.52, 1.18, 9.70),
		Vector3(0.055, 0.32, 0.035),
		storefront_metal_mat
	)

	_add_box(
		shell,
		"StarterSignBacking",
		Vector3(-3.35, 2.70, _SHELL_BACK_Z + 0.15),
		Vector3(1.85, 0.34, 0.08),
		sign_mat
	)
	_add_label(
		shell, "StarterSignLabel", "SHELF LIFE", Vector3(-3.35, 2.74, _SHELL_BACK_Z + 0.22), 30
	)
	_add_label(shell, "GamesBayLabel", "", Vector3(-3.35, 2.35, _SHELL_BACK_Z + 0.23), 22)

	_add_wall(
		shell, "StockroomPartition", Vector3(3.55, 0.90, -4.45), Vector3(0.82, 1.80, 0.10), wall_mat
	)
	_add_wall(
		shell,
		"StockroomLeftSideReturn",
		Vector3(3.18, 1.55, -6.12),
		Vector3(0.12, 2.95, 2.72),
		wall_mat
	)
	_add_wall(
		shell,
		"StockroomSideReturn",
		Vector3(5.86, 1.55, -5.82),
		Vector3(0.12, 2.95, 3.30),
		wall_mat
	)
	_add_wall(
		shell, "StockroomBackPanel", Vector3(4.55, 1.55, -7.45), Vector3(2.70, 2.95, 0.10), wall_mat
	)
	_add_box(
		shell, "StockroomPost", Vector3(3.95, 0.94, -4.45), Vector3(0.12, 1.88, 0.12), dark_mat
	)
	_add_box(
		shell,
		"StockroomDoorJambRight",
		Vector3(5.54, 1.44, -4.45),
		Vector3(0.12, 2.55, 0.12),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomDoorLintel",
		Vector3(4.75, 2.72, -4.45),
		Vector3(1.70, 0.12, 0.14),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomHeader",
		Vector3(4.78, 2.20, -4.41),
		Vector3(0.76, 0.08, 0.16),
		trim_mat
	)
	_add_box(
		shell,
		"StockroomDoorHandle",
		Vector3(4.08, 1.10, -4.37),
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
		Vector3(4.22, 0.073, -5.35),
		Vector3(0.12, 0.018, 1.20),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomEmployeeStripeRight",
		Vector3(5.28, 0.073, -5.35),
		Vector3(0.12, 0.018, 1.20),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomDoorStop",
		Vector3(4.75, 0.16, -4.41),
		Vector3(1.45, 0.14, 0.05),
		trim_mat
	)

	_add_box(
		shell,
		"ExpansionDoorPanel",
		Vector3(_SHELL_LEFT_X + 0.07, 1.65, 1.10),
		Vector3(0.10, 2.55, 3.55),
		shutter_mat
	)
	_add_box(
		shell,
		"ExpansionHeader",
		Vector3(_SHELL_LEFT_X + 0.14, 2.95, 1.10),
		Vector3(0.10, 0.36, 3.65),
		sign_mat
	)
	_add_label(
		shell,
		"ExpansionLabel",
		"",
		Vector3(_SHELL_LEFT_X + 0.20, 2.96, 1.10),
		34,
		Vector3(0.0, -90.0, 0.0)
	)

	_add_box(
		shell,
		"StarterAisleMat",
		Vector3(0.95, 0.065, 5.95),
		Vector3(4.55, 0.025, 1.25),
		_mat(Color(0.20, 0.13, 0.10, 1.0))
	)

	# Floor wear gives scale without fighting the customer-facing retail fixtures.
	for index: int in range(11):
		var x_line: float = -5.0 + float(index) * 1.0
		_add_box(
			shell,
			"FloorBoardSeam%02d" % index,
			Vector3(x_line, 0.072, _SHELL_CENTER_Z),
			Vector3(0.018, 0.012, 16.6),
			_mat(Color(0.23, 0.13, 0.08, 1.0))
		)
	for index: int in range(8):
		var z_line: float = -6.45 + float(index) * 2.05
		_add_box(
			shell,
			"FloorTrafficScuff%02d" % index,
			Vector3(0.10, 0.076, z_line),
			Vector3(4.4, 0.008, 0.035),
			_mat(Color(0.28, 0.17, 0.10, 1.0))
		)

	for index: int in range(4):
		var light_x: float = -3.6 + float(index) * 2.4
		_add_box(
			shell,
			"CeilingFluorescent%02d" % index,
			Vector3(light_x, 3.39, 0.55),
			Vector3(1.05, 0.035, 0.16),
			_mat(Color(0.96, 0.91, 0.70, 1.0), Color(1.0, 0.84, 0.42, 1.0), 0.55)
		)
	_add_omni_light(
		shell,
		"ShelfWallWarmPractical",
		Vector3(-2.80, 2.65, -6.95),
		Color(1.0, 0.76, 0.48, 1.0),
		0.48,
		3.6
	)
	_add_omni_light(
		shell,
		"ShelfEdgeCoolPractical",
		Vector3(-2.85, 1.85, 0.95),
		Color(0.66, 0.76, 1.0, 1.0),
		0.38,
		2.8
	)
	_add_omni_light(
		shell,
		"CheckoutRegisterPractical",
		Vector3(4.18, 1.55, 5.35),
		Color(1.0, 0.74, 0.48, 1.0),
		0.50,
		2.8
	)
	_add_omni_light(
		shell,
		"StockroomUtilityPractical",
		Vector3(4.75, 2.30, -6.70),
		Color(0.58, 0.74, 1.0, 1.0),
		0.62,
		3.2
	)
	_add_omni_light(
		shell,
		"EntryThresholdPractical",
		Vector3(0.0, 2.15, 8.45),
		Color(1.0, 0.78, 0.55, 1.0),
		0.30,
		2.4
	)
	_add_intentional_day_one_fixtures(shell, palette)


static func _add_intentional_day_one_fixtures(shell: Node3D, palette: Dictionary) -> void:
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
	var graphite_mat := _mat(Color(0.10, 0.11, 0.13, 1.0))
	var stock_box_mat: StandardMaterial3D = palette["stock_box"] as StandardMaterial3D

	_add_checkout_core(
		shell, dark_mat, table_mat, paper_mat, paper_white_mat, gold_mat, graphite_mat
	)
	_add_used_game_wall_shelf(shell, trim_mat, shelf_mat)
	_add_starter_display_table_context(shell, trim_mat, dark_mat, table_mat)
	_add_stock_closet_contents(
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


static func _add_checkout_core(
	shell: Node3D,
	dark_mat: StandardMaterial3D,
	table_mat: StandardMaterial3D,
	paper_mat: StandardMaterial3D,
	paper_white_mat: StandardMaterial3D,
	gold_mat: StandardMaterial3D,
	graphite_mat: StandardMaterial3D
) -> void:
	var screen_mat := _mat(Color(0.04, 0.16, 0.11, 1.0), Color(0.12, 0.58, 0.34, 1.0), 0.48)
	var service_mat := _mat(Color(0.42, 0.32, 0.22, 1.0))
	var mat_mat := _mat(Color(0.10, 0.12, 0.11, 1.0))
	_add_box(
		shell,
		"CheckoutCounterTop",
		Vector3(4.20, 0.79, 5.54),
		Vector3(1.22, 0.08, 1.12),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerSidePanel",
		Vector3(4.20, 0.42, 6.09),
		Vector3(1.16, 0.56, 0.08),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutEmployeeSidePanel",
		Vector3(4.20, 0.42, 4.99),
		Vector3(1.16, 0.56, 0.08),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutLeftSidePanel",
		Vector3(3.57, 0.42, 5.54),
		Vector3(0.08, 0.56, 1.02),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutRightSidePanel",
		Vector3(4.83, 0.42, 5.54),
		Vector3(0.08, 0.56, 1.02),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutFrontLaminatePanel",
		Vector3(4.05, 0.43, 5.98),
		Vector3(0.92, 0.52, 0.055),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutFrontToeKick",
		Vector3(4.05, 0.13, 6.02),
		Vector3(0.84, 0.12, 0.06),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterDrawer",
		Vector3(4.28, 0.87, 5.03),
		Vector3(0.52, 0.18, 0.32),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterCashSlot",
		Vector3(4.28, 0.96, 4.85),
		Vector3(0.38, 0.03, 0.03),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterNeck",
		Vector3(4.28, 1.08, 4.99),
		Vector3(0.07, 0.19, 0.07),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterScreenBezel",
		Vector3(4.28, 1.22, 4.865),
		Vector3(0.46, 0.30, 0.025),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterScreen",
		Vector3(4.28, 1.22, 4.835),
		Vector3(0.34, 0.20, 0.025),
		screen_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterKeypad",
		Vector3(4.04, 0.99, 5.23),
		Vector3(0.22, 0.04, 0.18),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutReceiptSlip",
		Vector3(4.55, 0.945, 5.23),
		Vector3(0.22, 0.025, 0.16),
		paper_white_mat
	)
	_add_box(
		shell,
		"CheckoutManagerNamePlate",
		Vector3(4.10, 1.04, 6.015),
		Vector3(0.32, 0.08, 0.025),
		gold_mat
	)
	_add_box(
		shell,
		"CheckoutCounterPaperStack",
		Vector3(4.66, 0.89, 5.45),
		Vector3(0.22, 0.05, 0.16),
		paper_mat
	)
	_add_box(
		shell,
		"CheckoutReceiptPrinterBody",
		Vector3(4.55, 0.88, 5.23),
		Vector3(0.30, 0.10, 0.22),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutReceiptPaperRoll",
		Vector3(4.55, 0.955, 5.13),
		Vector3(0.18, 0.05, 0.05),
		paper_white_mat
	)
	_add_box(
		shell,
		"CheckoutCardReader",
		Vector3(3.92, 0.865, 5.49),
		Vector3(0.18, 0.07, 0.24),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutBarcodeScanner",
		Vector3(4.73, 0.865, 5.43),
		Vector3(0.22, 0.07, 0.10),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerPaymentDisplay",
		Vector3(3.88, 1.02, 5.955),
		Vector3(0.32, 0.18, 0.04),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerPaymentDisplayScreen",
		Vector3(3.88, 1.02, 5.985),
		Vector3(0.24, 0.12, 0.025),
		screen_mat
	)
	_add_box(
		shell,
		"CheckoutCounterCableRun",
		Vector3(4.10, 0.842, 5.37),
		Vector3(0.38, 0.018, 0.025),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutScannerCable",
		Vector3(4.58, 0.842, 5.36),
		Vector3(0.30, 0.018, 0.025),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutBaggingSurface",
		Vector3(4.04, 0.842, 5.78),
		Vector3(0.42, 0.025, 0.28),
		service_mat
	)
	_add_box(
		shell,
		"CheckoutBagStack",
		Vector3(4.04, 0.885, 5.78),
		Vector3(0.26, 0.055, 0.18),
		paper_white_mat
	)
	_add_box(
		shell,
		"CheckoutManagerFloorMat",
		Vector3(4.55, 0.077, 5.18),
		Vector3(0.42, 0.014, 0.55),
		mat_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerFloorMat",
		Vector3(3.55, 0.077, 6.62),
		Vector3(0.58, 0.014, 0.42),
		mat_mat
	)
	_add_label(shell, "CheckoutTradeInsText", "", Vector3(4.10, 1.12, 5.98), 15)


static func _add_used_game_wall_shelf(
	shell: Node3D,
	trim_mat: StandardMaterial3D,
	shelf_mat: StandardMaterial3D
) -> void:
	_add_box(
		shell,
		"StarterUsedShelfBacker",
		Vector3(-2.80, 1.32, -7.515),
		Vector3(2.40, 0.84, 0.045),
		_mat(Color(0.16, 0.11, 0.08, 1.0))
	)
	for rail: int in range(2):
		_add_box(
			shell,
			"StarterUsedShelfRail%02d" % rail,
			Vector3(-2.80, 1.06 + float(rail) * 0.42, -7.03),
			Vector3(2.25, 0.07, 0.10),
			shelf_mat if rail == 0 else trim_mat
		)
	var shelf_products: Array[Dictionary] = [
		{
			"name": "StarterProductMotorwayKings",
			"item_id": "neo_ignite_motorway_kings_loose",
			"position": Vector3(-3.50, 1.18, -6.99),
			"rotation": Vector3(0.0, -8.0, 0.0),
			"scale": Vector3(0.86, 0.86, 0.86),
		},
		{
			"name": "StarterProductKingdomEmbers",
			"item_id": "neo_ignite_kingdom_embers_loose",
			"position": Vector3(-2.95, 1.18, -6.99),
			"rotation": Vector3(0.0, 6.0, 0.0),
			"scale": Vector3(0.86, 0.86, 0.86),
		},
		{
			"name": "StarterProductTorqueForce",
			"item_id": "neo_ignite_torque_force_3_loose",
			"position": Vector3(-2.38, 1.18, -6.99),
			"rotation": Vector3(0.0, -4.0, 0.0),
			"scale": Vector3(0.84, 0.84, 0.84),
		},
	]
	for product: Dictionary in shelf_products:
		_add_starter_product_visual(shell, product)
	for index: int in range(3):
		_add_box(
			shell,
			"StarterUsedEmptySlot%02d" % index,
			Vector3(-3.45 + float(index) * 0.58, 1.43, -6.99),
			Vector3(0.32, 0.035, 0.025),
			_mat(Color(0.10, 0.075, 0.055, 1.0))
		)
	_add_box(
		shell,
		"StarterUsedShelfLeftDivider",
		Vector3(-3.94, 1.26, -6.98),
		Vector3(0.045, 0.64, 0.09),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfCenterDivider",
		Vector3(-2.80, 1.26, -6.98),
		Vector3(0.045, 0.64, 0.09),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfRightDivider",
		Vector3(-1.66, 1.26, -6.98),
		Vector3(0.045, 0.64, 0.09),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfBottomLip",
		Vector3(-2.80, 0.87, -6.98),
		Vector3(2.34, 0.055, 0.08),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfFloorFootprint",
		Vector3(-2.80, 0.078, -6.10),
		Vector3(2.55, 0.012, 0.34),
		_mat(Color(0.13, 0.09, 0.06, 1.0))
	)


static func _add_starter_display_table_context(
	shell: Node3D,
	trim_mat: StandardMaterial3D,
	dark_mat: StandardMaterial3D,
	table_mat: StandardMaterial3D
) -> void:
	var display_center := _SHELF_TARGET_POSITION + Vector3(0.0, 0.0, 0.08)
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
	var table_products: Array[Dictionary] = [
		{
			"name": "StarterProductConsoleNeoIgnite",
			"item_id": "console_neo_ignite",
			"position": display_center + Vector3(-0.66, 1.31, -0.12),
			"rotation": Vector3(0.0, -18.0, 0.0),
			"scale": Vector3(1.34, 1.34, 1.34),
		},
		{
			"name": "StarterProductGridiron",
			"item_id": "neo_ignite_gridiron_2005_loose",
			"position": display_center + Vector3(0.42, 1.18, 0.11),
			"rotation": Vector3(0.0, 12.0, 0.0),
			"scale": Vector3(0.84, 0.84, 0.84),
		},
	]
	for product: Dictionary in table_products:
		_add_starter_product_visual(shell, product)
	for index: int in range(2):
		_add_box(
			shell,
			"StarterDisplayEmptySlot%02d" % index,
			display_center + Vector3(0.16 + float(index) * 0.48, 1.015, 0.43),
			Vector3(0.22, 0.035, 0.030),
			_mat(Color(0.12, 0.085, 0.055, 1.0))
		)


static func _add_starter_product_visual(shell: Node3D, placement: Dictionary) -> void:
	var item_id: String = str(placement.get("item_id", ""))
	var visual: Node3D = ProductVisualFactoryScript.create_visual_for_item(
		_starter_product_visual_data(item_id)
	)
	if visual == null:
		return
	visual.name = str(placement.get("name", item_id))
	visual.position = placement.get("position", Vector3.ZERO) as Vector3
	visual.rotation_degrees = placement.get("rotation", Vector3.ZERO) as Vector3
	visual.scale = placement.get("scale", Vector3.ONE) as Vector3
	visual.set_meta("product_item_id", item_id)
	visual.set_meta("route_role", "starter_sale_item")
	visual.add_to_group("product_display")
	_mute_product_labels(visual)
	shell.add_child(visual)


static func _starter_product_visual_data(item_id: String) -> Dictionary:
	var data: Dictionary = {}
	if _STARTER_PRODUCT_FALLBACKS.has(item_id):
		data = (_STARTER_PRODUCT_FALLBACKS[item_id] as Dictionary).duplicate(true)
	data["definition_id"] = item_id
	data["route_role"] = "starter_sale_item"
	data["stock_state"] = "available"
	data["show_price_tag"] = true
	var entry: Dictionary = ContentRegistry.get_entry(StringName(item_id))
	if entry.is_empty():
		return data
	data["display_name"] = str(entry.get("item_name", data.get("display_name", item_id)))
	data["category"] = str(entry.get("category", data.get("category", "")))
	data["platform_id"] = str(entry.get("platform_id", data.get("platform_id", "")))
	data["price_cents"] = int(
		round(float(entry.get("used_price", entry.get("base_price", 0.0))) * 100.0)
	)
	for key: String in ["box_art_key", "platform_visual_id", "visual_alias_id"]:
		if entry.has(key):
			data[key] = entry[key]
	return data


static func _mute_product_labels(node: Node) -> void:
	var label: Label3D = node as Label3D
	if label != null:
		label.text = ""
	for child: Node in node.get_children():
		_mute_product_labels(child)


static func _add_stock_closet_contents(
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
		Vector3(4.58, 0.079, -6.05),
		Vector3(2.52, 0.014, 2.92),
		backroom_floor_mat
	)
	_add_box(
		shell,
		"StockroomBackWallCoolPanel",
		Vector3(4.58, 1.44, -7.38),
		Vector3(2.34, 1.74, 0.026),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomLeftWallCoolPanel",
		Vector3(3.25, 1.36, -6.00),
		Vector3(0.026, 1.58, 2.36),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomSupplyShelf",
		Vector3(4.38, 0.88, -7.42),
		Vector3(1.75, 0.10, 0.34),
		trim_mat
	)
	for index: int in range(5):
		_add_box(
			shell,
			"StockroomSupplyBox%02d" % index,
			Vector3(3.78 + float(index) * 0.30, 1.04, -7.42),
			Vector3(0.20, 0.18, 0.22),
			stock_box_mat
		)
		_add_box(
			shell,
			"StockroomSupplyLabel%02d" % index,
			Vector3(3.78 + float(index) * 0.30, 1.04, -7.29),
			Vector3(0.12, 0.045, 0.018),
			paper_white_mat
		)
		_add_box(
			shell,
			"StockroomSupplyBand%02d" % index,
			Vector3(3.78 + float(index) * 0.30, 1.15, -7.29),
			Vector3(0.16, 0.035, 0.016),
			crate_shadow_mat
		)
	for level: int in range(3):
		_add_box(
			shell,
			"StockroomBackRackShelf%02d" % level,
			Vector3(4.52, 1.24 + float(level) * 0.42, -7.30),
			Vector3(1.92, 0.055, 0.20),
			backroom_rack_mat
		)
	for rack_x: float in [3.50, 4.02, 4.74, 5.28]:
		_add_box(
			shell,
			"StockroomBackRackUpright%02d" % int(round(rack_x * 100.0)),
			Vector3(rack_x, 1.62, -7.28),
			Vector3(0.045, 1.28, 0.08),
			backroom_rack_mat
		)
	for index: int in range(4):
		var row: int = index / 2
		var column: int = index % 2
		_add_box(
			shell,
			"StockroomTallCrate%02d" % index,
			Vector3(3.48 + float(column) * 0.26, 0.37 + float(row) * 0.28, -6.58),
			Vector3(0.22, 0.24, 0.28),
			stock_box_mat if index % 2 == 0 else crate_shadow_mat
		)
		_add_box(
			shell,
			"StockroomTallCrateFace%02d" % index,
			Vector3(3.48 + float(column) * 0.26, 0.40 + float(row) * 0.28, -6.42),
			Vector3(0.13, 0.04, 0.018),
			paper_white_mat
		)
	_add_box(
		shell,
		"StockroomOverheadShelf",
		Vector3(4.72, 2.18, -6.72),
		Vector3(1.58, 0.06, 0.32),
		backroom_rack_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"StockroomOverheadBin%02d" % index,
			Vector3(4.18 + float(index) * 0.48, 2.34, -6.72),
			Vector3(0.28, 0.20, 0.24),
			crate_shadow_mat
		)
	_add_box(
		shell,
		"StockroomReceivingTableTop",
		Vector3(5.50, 0.78, -6.30),
		Vector3(0.48, 0.10, 0.70),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTableLegA",
		Vector3(5.34, 0.39, -6.05),
		Vector3(0.055, 0.68, 0.055),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTableLegB",
		Vector3(5.66, 0.39, -6.55),
		Vector3(0.055, 0.68, 0.055),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTapeRoll",
		Vector3(5.40, 0.86, -6.18),
		Vector3(0.12, 0.08, 0.12),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomTapeDispenserBase",
		Vector3(5.40, 0.84, -6.32),
		Vector3(0.22, 0.05, 0.10),
		crate_shadow_mat
	)
	_add_box(
		shell,
		"StockroomPackingClipboard",
		Vector3(5.56, 0.86, -6.44),
		Vector3(0.18, 0.035, 0.24),
		paper_white_mat
	)
	for index: int in range(2):
		_add_box(
			shell,
			"StockroomPackingSlip%02d" % index,
			Vector3(5.42 + float(index) * 0.14, 0.895, -6.55),
			Vector3(0.10, 0.014, 0.15),
			paper_white_mat
		)
	_add_box(
		shell,
		"StockroomSortingMat",
		Vector3(4.12, 0.074, -5.88),
		Vector3(0.62, 0.018, 0.86),
		_mat(Color(0.13, 0.15, 0.16, 1.0))
	)
	_add_box(
		shell,
		"StockroomWallRack",
		Vector3(3.30, 1.52, -6.28),
		Vector3(0.10, 0.86, 1.02),
		trim_mat
	)
	_add_box(
		shell,
		"StockroomHandTruckHint",
		Vector3(5.68, 0.54, -5.20),
		Vector3(0.10, 0.72, 0.08),
		rubber_mat
	)
	_add_box(
		shell,
		"StockroomHandTruckToe",
		Vector3(5.62, 0.13, -5.36),
		Vector3(0.38, 0.05, 0.12),
		rubber_mat
	)
	_add_label(
		shell,
		"StockroomWallTaskText",
		"",
		Vector3(5.80, 1.87, -5.20),
		18,
		Vector3(0.0, -90.0, 0.0)
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
) -> void:
	_add_mesh_box(parent, name, position, size, material)


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
	parent.add_child(mesh_instance)
	return mesh_instance


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
