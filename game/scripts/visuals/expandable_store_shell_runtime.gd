# gdlint:disable=max-file-lines
## Runtime visual shell for the one-store expansion model.
##
## `retro_games.tscn` still owns gameplay anchors and interactables, but boot
## presentation is generated here: a compact starter footprint with a closed
## expansion bay. Growth should unlock more generated layout pieces instead of
## revealing legacy authored full-store fixtures.
class_name ExpandableStoreShellRuntime
extends RefCounted

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")

const ROOT_NAME: StringName = &"ExpandableStoreShell"

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
	_set_position(store, "PlayerEntrySpawn", Vector3(0.0, 0.0, 5.65))
	_set_rotation_degrees(store, "PlayerEntrySpawn", Vector3.ZERO)
	_set_player_bounds(store, Vector3(-3.55, 0.0, -3.25), Vector3(3.55, 0.0, 6.55))
	_set_position(store, "Checkout", Vector3(2.92, 0.0, 3.75))
	_set_scale(store, "Checkout", Vector3(0.74, 0.74, 0.74))
	_set_position(store, "checkout_counter", Vector3(2.92, 0.0, 3.75))
	_set_scale(store, "checkout_counter", Vector3(0.74, 0.74, 0.74))
	_set_position(store, "RegisterArea", Vector3(2.82, 1.0, 4.00))
	_set_position(store, "StoreSessionDayOneCustomer", Vector3(2.52, 0.0, 4.85))
	_set_position(store, "StoreSessionDayEndTrigger", Vector3(2.92, 1.05, 3.75))
	_set_position(store, "StoreSessionRestockShelf", Vector3(-1.35, 0.0, 1.35))
	_set_rotation_degrees(store, "StoreSessionRestockShelf", Vector3(0.0, -8.0, 0.0))
	_hide_node(store, "StoreSessionRestockShelf/RestockCrate")
	_set_position(store, "StoreSessionBackroomPickup", Vector3(3.15, 0.0, -2.15))
	_set_position(store, "EntranceDoor", Vector3(0.0, 0.0, 7.22))
	_hide_node(store, "EntranceDoor/DoorMesh")
	_hide_node(store, "EntranceDoor/StaticBody3D")
	_set_position(store, "EntryArea", Vector3(0.0, 1.2, 6.60))
	_set_position(store, "QueueMarker1", Vector3(2.52, 0.0, 4.85))
	_set_position(store, "QueueMarker2", Vector3(1.62, 0.0, 5.05))
	_set_position(store, "QueueMarker3", Vector3(0.72, 0.0, 5.25))
	_set_position(store, "FrontLaneQueue", Vector3(1.82, 0.0, 4.75))
	_set_position(store, "BackroomUtilityLight", Vector3(3.2, 2.35, -2.2))
	_set_position(store, "CheckoutLaneSpotlight", Vector3(2.2, 3.1, 4.6))
	_set_position(store, "FluorescentKeyLight", Vector3(0.0, 3.25, 1.3))
	_set_position(store, "WarmNeonFill", Vector3(-2.7, 2.1, 0.8))
	_set_position(store, "GreenNeonFill", Vector3(2.8, 2.2, 3.0))
	_set_customer_nav(store)


static func _set_customer_nav(store: Node) -> void:
	_set_position(store, "StoreStaffConfig/RegisterPoint", Vector3(2.52, 0.0, 4.85))
	_set_position(store, "StoreStaffConfig/BackroomPoint", Vector3(3.2, 0.0, -2.2))
	_set_position(store, "StoreStaffConfig/GreeterPoint", Vector3(0.0, 0.0, 5.6))
	_set_position(store, "CustomerNavConfig/EntryPoint", Vector3(0.0, 0.05, 6.75))
	_set_position(store, "CustomerNavConfig/BrowseWaypoint01", Vector3(-1.35, 0.05, 1.35))
	_set_position(store, "CustomerNavConfig/BrowseWaypoint02", Vector3(-0.2, 0.05, -2.55))
	_set_position(store, "CustomerNavConfig/BrowseWaypoint03", Vector3(3.0, 0.05, -2.0))
	_set_position(store, "CustomerNavConfig/BrowseWaypoint04", Vector3(-2.8, 0.05, 1.1))
	_set_position(store, "CustomerNavConfig/CheckoutApproach", Vector3(2.52, 0.05, 4.85))
	_set_position(store, "CustomerNavConfig/ExitPoint", Vector3(0.0, 0.05, 6.75))


static func _set_position(store: Node, path: String, position: Vector3) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node != null:
		node.position = position


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
		store.add_child.call_deferred(shell)
	shell.visible = true
	for child: Node in shell.get_children():
		child.free()
	return shell


static func _rebuild_shell(shell: Node3D) -> void:
	var wall_mat: StandardMaterial3D = _mat(Color(0.47, 0.45, 0.41, 1.0))
	var trim_mat: StandardMaterial3D = _mat(Color(0.12, 0.07, 0.04, 1.0))
	var floor_mat: StandardMaterial3D = _mat(Color(0.44, 0.25, 0.13, 1.0))
	var ceiling_mat: StandardMaterial3D = _mat(Color(0.58, 0.55, 0.51, 1.0))
	var shutter_mat: StandardMaterial3D = _mat(Color(0.20, 0.17, 0.22, 1.0))
	var sign_mat: StandardMaterial3D = _mat(Color(0.34, 0.18, 0.05, 1.0))
	var dark_mat: StandardMaterial3D = _mat(Color(0.08, 0.08, 0.09, 1.0))
	var shelf_mat: StandardMaterial3D = _mat(Color(0.24, 0.14, 0.07, 1.0))
	var table_mat: StandardMaterial3D = _mat(Color(0.48, 0.30, 0.14, 1.0))
	var paper_mat: StandardMaterial3D = _mat(Color(0.92, 0.74, 0.46, 1.0))
	var blue_case_mat: StandardMaterial3D = _mat(Color(0.05, 0.12, 0.32, 1.0))
	var green_case_mat: StandardMaterial3D = _mat(Color(0.03, 0.23, 0.15, 1.0))
	var red_case_mat: StandardMaterial3D = _mat(Color(0.35, 0.08, 0.05, 1.0))
	var stock_box_mat: StandardMaterial3D = _mat(Color(0.56, 0.36, 0.18, 1.0))
	var gold_mat: StandardMaterial3D = _mat(
		Color(1.0, 0.78, 0.30, 1.0), Color(1.0, 0.63, 0.18, 1.0), 0.35
	)
	var paper_white_mat: StandardMaterial3D = _mat(Color(0.96, 0.90, 0.74, 1.0))
	var purple_case_mat: StandardMaterial3D = _mat(Color(0.26, 0.12, 0.34, 1.0))
	var teal_case_mat: StandardMaterial3D = _mat(Color(0.04, 0.30, 0.32, 1.0))
	var rubber_mat: StandardMaterial3D = _mat(Color(0.05, 0.055, 0.055, 1.0))
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
	}

	_add_box(shell, "StarterFloor", Vector3(0.0, 0.025, 1.85), Vector3(8.0, 0.05, 11.0), floor_mat)
	_add_box(
		shell, "StarterCeiling", Vector3(0.0, 3.45, 1.85), Vector3(8.0, 0.08, 11.0), ceiling_mat
	)
	_add_wall(
		shell, "StarterBackWall", Vector3(0.0, 1.72, -3.65), Vector3(8.0, 3.45, 0.12), wall_mat
	)
	_add_wall(
		shell, "StarterLeftWall", Vector3(-4.0, 1.72, 1.85), Vector3(0.12, 3.45, 11.0), wall_mat
	)
	_add_wall(
		shell, "StarterRightWall", Vector3(4.0, 1.72, 1.85), Vector3(0.12, 3.45, 11.0), wall_mat
	)
	_add_wall(
		shell,
		"StarterFrontWallLeft",
		Vector3(-2.95, 1.72, 7.35),
		Vector3(2.1, 3.45, 0.12),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterFrontWallRight",
		Vector3(2.95, 1.72, 7.35),
		Vector3(2.1, 3.45, 0.12),
		wall_mat
	)

	_add_box(shell, "BackWallTrim", Vector3(0.0, 0.68, -3.56), Vector3(7.7, 0.08, 0.10), trim_mat)
	_add_box(shell, "LeftWallTrim", Vector3(-3.91, 0.68, 1.85), Vector3(0.10, 0.08, 10.6), trim_mat)
	_add_box(shell, "RightWallTrim", Vector3(3.91, 0.68, 1.85), Vector3(0.10, 0.08, 10.6), trim_mat)
	_add_box(shell, "EntryThreshold", Vector3(0.0, 0.055, 7.12), Vector3(2.6, 0.05, 0.42), gold_mat)
	_add_box(
		shell, "FrontDoorFrameLeft", Vector3(-1.16, 1.55, 7.23), Vector3(0.10, 3.10, 0.16), dark_mat
	)
	_add_box(
		shell, "FrontDoorFrameRight", Vector3(1.16, 1.55, 7.23), Vector3(0.10, 3.10, 0.16), dark_mat
	)
	_add_box(
		shell, "FrontDoorFrameTop", Vector3(0.0, 3.05, 7.23), Vector3(2.42, 0.10, 0.16), dark_mat
	)
	_add_wall(
		shell,
		"StarterGlassDoorBlocker",
		Vector3(0.0, 1.55, 7.30),
		Vector3(2.08, 2.55, 0.05),
		_glass_mat(Color(0.30, 0.39, 0.46, 0.24))
	)
	_add_box(
		shell, "FrontDoorPushPlate", Vector3(0.62, 1.28, 7.19), Vector3(0.10, 0.50, 0.06), gold_mat
	)

	_add_box(
		shell, "StarterSignBacking", Vector3(-2.55, 2.70, -3.50), Vector3(1.85, 0.34, 0.08), sign_mat
	)
	_add_label(shell, "StarterSignLabel", "SHELF LIFE", Vector3(-2.55, 2.74, -3.43), 30)
	_add_label(shell, "GamesBayLabel", "", Vector3(-2.55, 2.35, -3.42), 22)

	_add_wall(
		shell, "StockroomPartition", Vector3(3.05, 0.90, -1.06), Vector3(1.25, 1.80, 0.10), wall_mat
	)
	_add_wall(
		shell, "StockroomSideReturn", Vector3(3.93, 1.55, -2.25), Vector3(0.12, 2.95, 2.55), wall_mat
	)
	_add_wall(
		shell, "StockroomBackPanel", Vector3(3.20, 1.55, -3.45), Vector3(1.45, 2.95, 0.10), wall_mat
	)
	_add_box(
		shell, "StockroomPost", Vector3(2.34, 0.94, -1.06), Vector3(0.12, 1.88, 0.12), dark_mat
	)
	_add_box(
		shell, "StockroomDoorJambRight", Vector3(3.76, 1.44, -1.06), Vector3(0.12, 2.55, 0.12), dark_mat
	)
	_add_box(
		shell, "StockroomDoorLintel", Vector3(3.05, 2.72, -1.06), Vector3(1.55, 0.12, 0.14), dark_mat
	)
	_add_box(
		shell, "StockroomHeader", Vector3(3.18, 2.20, -1.02), Vector3(0.74, 0.08, 0.16), trim_mat
	)
	_add_box(
		shell, "StockroomDoorHandle", Vector3(2.48, 1.10, -0.98), Vector3(0.08, 0.16, 0.04), gold_mat
	)
	_add_box(
		shell,
		"StockroomFloorTape",
		Vector3(3.15, 0.06, -1.55),
		Vector3(1.55, 0.025, 0.18),
		gold_mat
	)

	_add_box(
		shell,
		"ExpansionDoorPanel",
		Vector3(-3.93, 1.65, 1.20),
		Vector3(0.10, 2.55, 2.75),
		shutter_mat
	)
	_add_box(
		shell, "ExpansionHeader", Vector3(-3.86, 2.95, 1.20), Vector3(0.10, 0.36, 2.85), sign_mat
	)
	_add_label(
		shell,
		"ExpansionLabel",
		"",
		Vector3(-3.80, 2.96, 1.20),
		34,
		Vector3(0.0, -90.0, 0.0)
	)

	_add_box(
		shell,
		"StarterAisleMat",
		Vector3(-0.30, 0.065, 3.10),
		Vector3(2.4, 0.025, 1.10),
		_mat(Color(0.20, 0.13, 0.10, 1.0))
	)

	# Floor wear gives scale without fighting the customer-facing retail fixtures.
	for index: int in range(7):
		var x_line: float = -3.0 + float(index) * 1.0
		_add_box(
			shell,
			"FloorBoardSeam%02d" % index,
			Vector3(x_line, 0.072, 1.85),
			Vector3(0.018, 0.012, 10.2),
			_mat(Color(0.23, 0.13, 0.08, 1.0))
		)
	for index: int in range(6):
		var z_line: float = -2.75 + float(index) * 1.65
		_add_box(
			shell,
			"FloorTrafficScuff%02d" % index,
			Vector3(-0.25, 0.076, z_line),
			Vector3(3.5, 0.008, 0.035),
			_mat(Color(0.28, 0.17, 0.10, 1.0))
		)

	for index: int in range(3):
		var light_x: float = -2.15 + float(index) * 2.15
		_add_box(
			shell,
			"CeilingFluorescent%02d" % index,
			Vector3(light_x, 3.39, 1.20),
			Vector3(1.05, 0.035, 0.16),
			_mat(Color(0.96, 0.91, 0.70, 1.0), Color(1.0, 0.84, 0.42, 1.0), 0.55)
		)
	_add_omni_light(
		shell,
		"ShelfWallWarmPractical",
		Vector3(-1.1, 2.65, -2.70),
		Color(1.0, 0.72, 0.38, 1.0),
		0.85,
		4.0
	)
	_add_omni_light(
		shell,
		"CheckoutRegisterPractical",
		Vector3(2.65, 1.55, 3.32),
		Color(0.72, 0.98, 0.72, 1.0),
		0.42,
		2.4
	)
	_add_omni_light(
		shell,
		"StockroomUtilityPractical",
		Vector3(3.35, 2.25, -2.10),
		Color(0.65, 0.82, 1.0, 1.0),
		0.58,
		2.9
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
	var blue_case_mat: StandardMaterial3D = palette["blue_case"] as StandardMaterial3D
	var green_case_mat: StandardMaterial3D = palette["green_case"] as StandardMaterial3D
	var red_case_mat: StandardMaterial3D = palette["red_case"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	var graphite_mat := _mat(Color(0.10, 0.11, 0.13, 1.0))
	var stock_box_mat: StandardMaterial3D = palette["stock_box"] as StandardMaterial3D

	_add_checkout_core(shell, dark_mat, table_mat, paper_mat, paper_white_mat, gold_mat, graphite_mat)
	_add_used_game_wall_shelf(
		shell,
		trim_mat,
		shelf_mat,
		paper_mat,
		blue_case_mat,
		green_case_mat,
		red_case_mat,
		gold_mat
	)
	_add_stock_closet_contents(
		shell, trim_mat, dark_mat, stock_box_mat, paper_white_mat, gold_mat, rubber_mat
	)


static func _add_checkout_core(
	shell: Node3D,
	dark_mat: StandardMaterial3D,
	table_mat: StandardMaterial3D,
	paper_mat: StandardMaterial3D,
	paper_white_mat: StandardMaterial3D,
	gold_mat: StandardMaterial3D,
	graphite_mat: StandardMaterial3D
) -> void:
	_add_box(
		shell,
		"CheckoutFrontLaminatePanel",
		Vector3(2.64, 0.43, 4.08),
		Vector3(0.92, 0.52, 0.055),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutFrontToeKick",
		Vector3(2.64, 0.13, 4.12),
		Vector3(0.84, 0.12, 0.06),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterDrawer",
		Vector3(2.86, 0.87, 3.28),
		Vector3(0.52, 0.18, 0.32),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterCashSlot",
		Vector3(2.86, 0.96, 3.10),
		Vector3(0.38, 0.03, 0.03),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterNeck",
		Vector3(2.86, 1.08, 3.24),
		Vector3(0.07, 0.19, 0.07),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterScreenBezel",
		Vector3(2.86, 1.22, 3.115),
		Vector3(0.46, 0.30, 0.025),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterScreen",
		Vector3(2.86, 1.22, 3.085),
		Vector3(0.34, 0.20, 0.025),
		_mat(Color(0.04, 0.17, 0.10, 1.0), Color(0.10, 0.64, 0.34, 1.0), 0.35)
	)
	_add_box(
		shell,
		"CheckoutRegisterKeypad",
		Vector3(2.62, 0.99, 3.48),
		Vector3(0.22, 0.04, 0.18),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutReceiptSlip",
		Vector3(3.13, 0.91, 3.48),
		Vector3(0.22, 0.025, 0.16),
		paper_white_mat
	)
	_add_box(
		shell,
		"CheckoutManagerNamePlate",
		Vector3(2.68, 1.04, 4.115),
		Vector3(0.32, 0.08, 0.025),
		gold_mat
	)
	_add_box(
		shell,
		"CheckoutCounterPaperStack",
		Vector3(3.24, 0.89, 3.70),
		Vector3(0.22, 0.05, 0.16),
		paper_mat
	)
	_add_label(shell, "CheckoutTradeInsText", "", Vector3(2.68, 1.12, 4.08), 15)


static func _add_used_game_wall_shelf(
	shell: Node3D,
	trim_mat: StandardMaterial3D,
	shelf_mat: StandardMaterial3D,
	paper_mat: StandardMaterial3D,
	blue_case_mat: StandardMaterial3D,
	green_case_mat: StandardMaterial3D,
	red_case_mat: StandardMaterial3D,
	gold_mat: StandardMaterial3D
) -> void:
	_add_box(
		shell,
		"StarterUsedShelfBacker",
		Vector3(-0.80, 1.32, -3.515),
		Vector3(2.10, 0.84, 0.045),
		_mat(Color(0.16, 0.11, 0.08, 1.0))
	)
	for rail: int in range(2):
		_add_box(
			shell,
			"StarterUsedShelfRail%02d" % rail,
			Vector3(-0.80, 1.06 + float(rail) * 0.42, -3.03),
			Vector3(2.00, 0.07, 0.10),
			shelf_mat if rail == 0 else trim_mat
		)
	var case_mats: Array[StandardMaterial3D] = [
		red_case_mat,
		blue_case_mat,
		green_case_mat,
		paper_mat,
	]
	for index: int in range(8):
		var row: int = index / 4
		var column: int = index % 4
		_add_product_box(
			shell,
			"StarterUsedCase%02d" % index,
			Vector3(-1.52 + float(column) * 0.47, 1.17 + float(row) * 0.42, -3.00),
			Vector3(0.19, 0.25, 0.055),
			case_mats[index % case_mats.size()]
		)
	for index: int in range(3):
		_add_box(
			shell,
			"StarterUsedPriceTag%02d" % index,
			Vector3(-1.42 + float(index) * 0.72, 0.91, -2.99),
			Vector3(0.16, 0.045, 0.025),
			gold_mat
		)


static func _add_stock_closet_contents(
	shell: Node3D,
	trim_mat: StandardMaterial3D,
	dark_mat: StandardMaterial3D,
	stock_box_mat: StandardMaterial3D,
	paper_white_mat: StandardMaterial3D,
	gold_mat: StandardMaterial3D,
	rubber_mat: StandardMaterial3D
) -> void:
	_add_box(
		shell,
		"StockroomSupplyShelf",
		Vector3(3.30, 0.88, -2.72),
		Vector3(1.00, 0.10, 0.34),
		trim_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"StockroomSupplyBox%02d" % index,
			Vector3(3.00 + float(index) * 0.28, 1.04, -2.72),
			Vector3(0.20, 0.18, 0.22),
			stock_box_mat
		)
		_add_box(
			shell,
			"StockroomSupplyLabel%02d" % index,
			Vector3(3.00 + float(index) * 0.28, 1.04, -2.59),
			Vector3(0.12, 0.045, 0.018),
			paper_white_mat
		)
	_add_box(
		shell,
		"StockroomReceivingTableTop",
		Vector3(3.10, 0.78, -1.84),
		Vector3(0.82, 0.10, 0.46),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTapeRoll",
		Vector3(2.82, 0.86, -1.88),
		Vector3(0.12, 0.08, 0.12),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomHandTruckHint",
		Vector3(3.68, 0.54, -1.58),
		Vector3(0.10, 0.72, 0.08),
		rubber_mat
	)
	_add_label(
		shell,
		"StockroomWallTaskText",
		"",
		Vector3(3.74, 1.87, -1.58),
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
	parent: Node3D,
	name: String,
	position: Vector3,
	color: Color,
	energy: float,
	omni_range: float
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
