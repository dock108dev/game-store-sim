## Runtime visual shell for the one-store expansion model.
##
## `retro_games.tscn` still owns gameplay anchors and interactables, but boot
## presentation is generated here: a compact starter footprint with a closed
## expansion bay. Growth should unlock more generated layout pieces instead of
## revealing legacy authored full-store fixtures.
class_name ExpandableStoreShellRuntime
extends RefCounted

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
	"BetaBackroomWallSide",
	"BetaBackroomWallFrontLeft",
	"BetaBackroomWallFrontRight",
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
	_set_position(store, "BetaDayOneCustomer", Vector3(2.52, 0.0, 4.85))
	_set_position(store, "BetaDayEndTrigger", Vector3(2.92, 1.05, 3.75))
	_set_position(store, "BetaRestockShelf", Vector3(-1.7, 0.0, -2.95))
	_set_position(store, "BetaBackroomPickup", Vector3(3.15, 0.0, -2.15))
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
	_set_position(store, "CustomerNavConfig/BrowseWaypoint01", Vector3(-1.7, 0.05, -2.75))
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
		shell, "StarterSignBacking", Vector3(-0.4, 2.68, -3.50), Vector3(4.1, 0.52, 0.08), sign_mat
	)
	_add_label(shell, "StarterSignLabel", "SHELF LIFE", Vector3(-0.4, 2.74, -3.43), 64)
	_add_box(
		shell, "GamesBayBacking", Vector3(-0.4, 2.18, -3.49), Vector3(1.9, 0.42, 0.08), sign_mat
	)
	_add_label(shell, "GamesBayLabel", "USED GAMES", Vector3(-0.4, 2.23, -3.42), 42)

	_add_wall(
		shell, "StockroomPartition", Vector3(3.05, 0.46, -1.06), Vector3(1.25, 0.92, 0.10), wall_mat
	)
	_add_box(
		shell, "StockroomPost", Vector3(2.34, 0.94, -1.06), Vector3(0.12, 1.88, 0.12), dark_mat
	)
	_add_box(
		shell, "StockroomHeader", Vector3(3.25, 2.18, -3.48), Vector3(1.38, 0.35, 0.08), sign_mat
	)
	_add_label(shell, "StockroomLabel", "STOCK", Vector3(3.25, 2.21, -3.41), 30)
	_add_box(
		shell,
		"StockroomFloorTape",
		Vector3(3.15, 0.06, -1.55),
		Vector3(1.55, 0.025, 0.18),
		gold_mat
	)
	_add_box(
		shell, "StockroomBoxA", Vector3(3.08, 0.30, -2.25), Vector3(0.58, 0.48, 0.48), stock_box_mat
	)
	_add_box(
		shell, "StockroomBoxB", Vector3(3.52, 0.55, -2.62), Vector3(0.52, 0.42, 0.42), stock_box_mat
	)
	_add_box(
		shell,
		"StockroomClipboard",
		Vector3(2.70, 1.22, -0.96),
		Vector3(0.36, 0.04, 0.26),
		paper_mat
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
		"EXPANSION",
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
	_add_box(
		shell, "CounterQueueTape", Vector3(1.45, 0.07, 4.85), Vector3(1.85, 0.025, 0.12), gold_mat
	)
	_add_box(
		shell,
		"StarterRegisterCounter",
		Vector3(3.04, 0.42, 3.50),
		Vector3(0.92, 0.76, 0.58),
		table_mat
	)
	_add_box(
		shell,
		"StarterRegisterScreen",
		Vector3(2.80, 0.98, 3.18),
		Vector3(0.34, 0.28, 0.06),
		dark_mat
	)
	_add_box(
		shell,
		"StarterRegisterGlow",
		Vector3(2.80, 0.99, 3.14),
		Vector3(0.25, 0.17, 0.025),
		_mat(Color(0.20, 0.95, 0.52, 1.0), Color(0.20, 1.0, 0.50, 1.0), 0.45)
	)
	_add_box(
		shell, "StarterCardReader", Vector3(3.12, 0.92, 3.18), Vector3(0.16, 0.11, 0.18), dark_mat
	)
	_add_box(
		shell,
		"BackWallShelfShadow",
		Vector3(-0.85, 1.05, -3.47),
		Vector3(3.0, 1.00, 0.06),
		dark_mat
	)
	_add_box(
		shell,
		"BackWallLowerShelf",
		Vector3(-0.85, 1.05, -3.34),
		Vector3(3.25, 0.10, 0.42),
		shelf_mat
	)
	_add_box(
		shell,
		"BackWallUpperShelf",
		Vector3(-0.85, 1.55, -3.34),
		Vector3(3.25, 0.10, 0.38),
		shelf_mat
	)
	for index: int in range(7):
		var x := -2.15 + float(index) * 0.43
		var mat: StandardMaterial3D = [blue_case_mat, green_case_mat, red_case_mat][index % 3]
		_add_box(
			shell,
			"StarterShelfCase%02d" % index,
			Vector3(x, 1.31, -3.10),
			Vector3(0.18, 0.34, 0.05),
			mat
		)
	for index: int in range(5):
		var x := -1.82 + float(index) * 0.48
		var mat: StandardMaterial3D = [green_case_mat, blue_case_mat, red_case_mat][index % 3]
		_add_box(
			shell,
			"StarterShelfTopCase%02d" % index,
			Vector3(x, 1.78, -3.10),
			Vector3(0.20, 0.32, 0.05),
			mat
		)
	_add_box(
		shell,
		"CenterDisplayTableTop",
		Vector3(-1.75, 0.68, 1.55),
		Vector3(1.45, 0.14, 0.82),
		table_mat
	)
	_add_box(
		shell,
		"CenterDisplayTableLegA",
		Vector3(-2.32, 0.34, 1.22),
		Vector3(0.12, 0.68, 0.12),
		dark_mat
	)
	_add_box(
		shell,
		"CenterDisplayTableLegB",
		Vector3(-1.18, 0.34, 1.88),
		Vector3(0.12, 0.68, 0.12),
		dark_mat
	)
	_add_box(
		shell,
		"CenterDisplayConsole",
		Vector3(-1.95, 0.86, 1.42),
		Vector3(0.34, 0.16, 0.42),
		_mat(Color(0.13, 0.13, 0.15, 1.0))
	)
	_add_box(
		shell,
		"CenterDisplayGameA",
		Vector3(-1.52, 0.86, 1.28),
		Vector3(0.20, 0.04, 0.30),
		red_case_mat
	)
	_add_box(
		shell,
		"CenterDisplayGameB",
		Vector3(-1.38, 0.88, 1.68),
		Vector3(0.20, 0.04, 0.30),
		blue_case_mat
	)
	_add_box(
		shell, "StarterPriceCard", Vector3(-2.28, 0.94, 1.82), Vector3(0.28, 0.05, 0.18), paper_mat
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
