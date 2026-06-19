extends Node3D

const VORTEX_TEAL := Color(0.02, 0.43, 0.42, 1.0)
const VORTEX_CREAM := Color(0.98, 0.9, 0.72, 1.0)
const CASE_BLACK := Color(0.025, 0.032, 0.04, 1.0)
const CASE_EDGE := Color(0.08, 0.095, 0.1, 1.0)
const PRICE_STICKER := Color(0.98, 0.84, 0.28, 1.0)
const SPORT_GREEN := Color(0.12, 0.56, 0.24, 1.0)
const SPORT_WHITE := Color(0.92, 0.96, 0.9, 1.0)
const QUEST_PURPLE := Color(0.28, 0.2, 0.48, 1.0)
const QUEST_GOLD := Color(0.98, 0.72, 0.32, 1.0)


func _ready() -> void:
	if get_child_count() > 0:
		return

	_build_game_stack("Footy2002Stack", Vector3(-0.52, 0.0, 0.0), "sports", deg_to_rad(14.0))
	_build_game_stack("CritterQuestIIStack", Vector3(-0.19, 0.0, 0.03), "quest", deg_to_rad(-10.0))
	_build_console_stack(Vector3(0.28, 0.0, 0.03), deg_to_rad(5.0))
	_build_accessory_pack_pair(Vector3(0.72, 0.0, 0.06), deg_to_rad(-12.0))


func _build_game_stack(node_name: String, origin: Vector3, cover_kind: String, yaw: float) -> void:
	var stack := Node3D.new()
	stack.name = node_name
	stack.position = origin
	stack.rotation.y = yaw
	add_child(stack)

	var case_size := Vector3(0.18, 0.32, 0.026)
	for index in range(3):
		_add_box(
			stack,
			"%sCopy%02d" % [node_name, index + 1],
			Vector3(float(index) * 0.018, case_size.y / 2.0 + float(index) * 0.006, float(index) * 0.032),
			case_size,
			CASE_BLACK.darkened(float(index) * 0.08)
		)

	_add_box(stack, "%sSpineStripe" % node_name, Vector3(-0.071, 0.172, -0.025), Vector3(0.018, 0.282, 0.012), VORTEX_TEAL)
	_add_box(stack, "%sPlatformBand" % node_name, Vector3(0.014, 0.298, -0.026), Vector3(0.13, 0.024, 0.012), VORTEX_TEAL)
	_add_box(stack, "%sCoverPanel" % node_name, Vector3(0.014, 0.17, -0.029), Vector3(0.132, 0.218, 0.012), SPORT_GREEN if cover_kind == "sports" else QUEST_PURPLE)
	_add_box(stack, "%sTopEdge" % node_name, Vector3(0.006, 0.316, -0.031), Vector3(0.15, 0.01, 0.012), CASE_EDGE)
	_add_box(stack, "%sPriceSticker" % node_name, Vector3(0.052, 0.068, -0.034), Vector3(0.046, 0.032, 0.012), PRICE_STICKER)

	if cover_kind == "sports":
		_add_box(stack, "%sFieldLineHorizontal" % node_name, Vector3(0.014, 0.17, -0.037), Vector3(0.108, 0.008, 0.012), SPORT_WHITE)
		_add_box(stack, "%sFieldLineVertical" % node_name, Vector3(0.014, 0.17, -0.039), Vector3(0.008, 0.142, 0.012), SPORT_WHITE)
		_add_disc(stack, "%sBall" % node_name, Vector3(0.045, 0.19, -0.044), 0.019, 0.008, SPORT_WHITE)
		_add_box(stack, "%sPlayerBody" % node_name, Vector3(-0.033, 0.168, -0.044), Vector3(0.026, 0.082, 0.012), Color(0.03, 0.045, 0.04, 1.0))
		_add_disc(stack, "%sPlayerHead" % node_name, Vector3(-0.033, 0.226, -0.046), 0.012, 0.008, Color(0.03, 0.045, 0.04, 1.0))
	else:
		_add_box(stack, "%sAdventureHorizon" % node_name, Vector3(0.014, 0.136, -0.037), Vector3(0.108, 0.026, 0.012), Color(0.18, 0.14, 0.28, 1.0))
		_add_disc(stack, "%sCritterBody" % node_name, Vector3(-0.02, 0.19, -0.044), 0.028, 0.008, QUEST_GOLD)
		_add_box(stack, "%sCritterEarA" % node_name, Vector3(-0.042, 0.231, -0.046), Vector3(0.012, 0.038, 0.012), QUEST_GOLD)
		_add_box(stack, "%sCritterEarB" % node_name, Vector3(0.002, 0.231, -0.046), Vector3(0.012, 0.038, 0.012), QUEST_GOLD)
		_add_box(stack, "%sQuestGem" % node_name, Vector3(0.047, 0.19, -0.046), Vector3(0.028, 0.038, 0.012), VORTEX_CREAM)
		_add_box(stack, "%sSequelMarker" % node_name, Vector3(0.053, 0.252, -0.047), Vector3(0.042, 0.018, 0.012), PRICE_STICKER)


func _build_console_stack(origin: Vector3, yaw: float) -> void:
	var stack := Node3D.new()
	stack.name = "VortexConsoleBoxStack"
	stack.position = origin
	stack.rotation.y = yaw
	add_child(stack)

	for index in range(2):
		_add_box(
			stack,
			"VortexConsoleBoxCopy%02d" % [index + 1],
			Vector3(float(index) * 0.035, 0.21 + float(index) * 0.028, float(index) * 0.052),
			Vector3(0.62, 0.42, 0.22),
			VORTEX_CREAM.darkened(float(index) * 0.08)
		)

	_add_box(stack, "VortexConsoleBoxSidePanel", Vector3(-0.255, 0.23, -0.118), Vector3(0.055, 0.34, 0.018), VORTEX_TEAL)
	_add_box(stack, "VortexConsoleBoxPlatformBand", Vector3(0.04, 0.36, -0.122), Vector3(0.45, 0.046, 0.018), VORTEX_TEAL)
	_add_box(stack, "VortexConsoleBoxFrontArtPanel", Vector3(0.04, 0.225, -0.128), Vector3(0.4, 0.22, 0.018), Color(0.94, 0.84, 0.64, 1.0))
	_add_box(stack, "VortexConsoleBoxHandle", Vector3(0.0, 0.442, -0.126), Vector3(0.18, 0.026, 0.018), VORTEX_TEAL.darkened(0.12))
	_add_box(stack, "VortexConsoleBoxFlapSeam", Vector3(0.0, 0.408, -0.129), Vector3(0.48, 0.009, 0.018), CASE_EDGE)
	_add_box(stack, "VortexConsoleRenderBody", Vector3(-0.04, 0.225, -0.142), Vector3(0.23, 0.074, 0.024), Color(0.045, 0.06, 0.065, 1.0))
	_add_disc(stack, "VortexConsoleRenderLens", Vector3(0.095, 0.23, -0.157), 0.025, 0.008, VORTEX_TEAL)
	_add_box(stack, "VortexConsolePriceSticker", Vector3(0.218, 0.1, -0.146), Vector3(0.076, 0.046, 0.018), PRICE_STICKER)


func _build_accessory_pack_pair(origin: Vector3, yaw: float) -> void:
	var pair := Node3D.new()
	pair.name = "VortexControllerPackPair"
	pair.position = origin
	pair.rotation.y = yaw
	add_child(pair)

	for index in range(2):
		var x_offset := float(index) * 0.085
		_add_box(pair, "VortexControllerPack%02d" % [index + 1], Vector3(x_offset, 0.17, float(index) * 0.025), Vector3(0.22, 0.34, 0.06), VORTEX_CREAM.darkened(float(index) * 0.07))
		_add_box(pair, "VortexControllerPack%02dBand" % [index + 1], Vector3(x_offset, 0.294, -0.037 + float(index) * 0.025), Vector3(0.17, 0.032, 0.014), VORTEX_TEAL)
		_add_box(pair, "VortexControllerPack%02dGripA" % [index + 1], Vector3(x_offset - 0.048, 0.166, -0.043 + float(index) * 0.025), Vector3(0.042, 0.072, 0.014), CASE_BLACK)
		_add_box(pair, "VortexControllerPack%02dGripB" % [index + 1], Vector3(x_offset + 0.048, 0.166, -0.043 + float(index) * 0.025), Vector3(0.042, 0.072, 0.014), CASE_BLACK)
		_add_box(pair, "VortexControllerPack%02dBridge" % [index + 1], Vector3(x_offset, 0.184, -0.047 + float(index) * 0.025), Vector3(0.112, 0.04, 0.014), CASE_BLACK)
		_add_disc(pair, "VortexControllerPack%02dButtonMark" % [index + 1], Vector3(x_offset + 0.034, 0.191, -0.057 + float(index) * 0.025), 0.011, 0.006, VORTEX_TEAL)
		_add_box(pair, "VortexControllerPack%02dPriceSticker" % [index + 1], Vector3(x_offset + 0.052, 0.07, -0.05 + float(index) * 0.025), Vector3(0.046, 0.032, 0.014), PRICE_STICKER)


func _add_box(parent: Node3D, node_name: String, position_value: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.position = position_value
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = _make_material(color)
	node.mesh = mesh
	parent.add_child(node)
	return node


func _add_disc(parent: Node3D, node_name: String, position_value: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.position = position_value
	node.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh.material = _make_material(color)
	node.mesh = mesh
	parent.add_child(node)
	return node


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	return material
