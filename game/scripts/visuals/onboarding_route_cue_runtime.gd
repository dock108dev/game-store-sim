## Visual-only floor wear cues for the first-run store-session route.
class_name OnboardingRouteCueRuntime
extends RefCounted

const ROOT_NAME: StringName = &"OnboardingRouteCues"
const _CUE_ALPHA: float = 0.34
const _CUE_Y: float = 0.084

const _CUES: Array[Dictionary] = [
	{
		"name": "CheckoutBackroomFloorWear00",
		"position": Vector3(5.35, _CUE_Y, 4.95),
		"size": Vector3(0.34, 0.012, 0.78),
		"rotation": Vector3(0.0, 1.0, 0.0),
	},
	{
		"name": "CheckoutBackroomFloorWear01",
		"position": Vector3(5.18, _CUE_Y, 2.35),
		"size": Vector3(0.30, 0.012, 0.76),
		"rotation": Vector3(0.0, -3.0, 0.0),
	},
	{
		"name": "CheckoutBackroomFloorWear02",
		"position": Vector3(5.04, _CUE_Y, 1.35),
		"size": Vector3(0.28, 0.012, 0.72),
		"rotation": Vector3(0.0, 4.0, 0.0),
	},
	{
		"name": "StockroomInteriorFloorWear00",
		"position": Vector3(4.95, _CUE_Y, -1.75),
		"size": Vector3(0.28, 0.012, 0.72),
		"rotation": Vector3(0.0, 1.0, 0.0),
	},
	{
		"name": "StockroomInteriorFloorWear01",
		"position": Vector3(4.93, _CUE_Y, -4.70),
		"size": Vector3(0.28, 0.012, 0.72),
		"rotation": Vector3(0.0, -2.0, 0.0),
	},
	{
		"name": "StockroomInteriorFloorWear02",
		"position": Vector3(4.90, _CUE_Y, -7.20),
		"size": Vector3(0.28, 0.012, 0.72),
		"rotation": Vector3(0.0, 2.0, 0.0),
	},
	{
		"name": "StockroomShelfFloorWear00",
		"position": Vector3(2.20, _CUE_Y, 0.50),
		"size": Vector3(0.30, 0.012, 0.74),
		"rotation": Vector3(0.0, -53.0, 0.0),
	},
	{
		"name": "StockroomShelfFloorWear01",
		"position": Vector3(-0.60, _CUE_Y, -0.30),
		"size": Vector3(0.28, 0.012, 0.72),
		"rotation": Vector3(0.0, -56.0, 0.0),
	},
	{
		"name": "StockroomShelfFloorWear02",
		"position": Vector3(-2.80, _CUE_Y, -0.90),
		"size": Vector3(0.28, 0.012, 0.66),
		"rotation": Vector3(0.0, -60.0, 0.0),
	},
	{
		"name": "StarterShelfLocalFloorWear",
		"position": Vector3(-3.75, _CUE_Y, -0.55),
		"size": Vector3(0.62, 0.012, 0.20),
		"rotation": Vector3(0.0, -8.0, 0.0),
	},
]


static func apply(shell: Node3D) -> void:
	if shell == null:
		return
	var root: Node3D = shell.get_node_or_null(NodePath(ROOT_NAME)) as Node3D
	if root == null:
		root = Node3D.new()
		root.name = ROOT_NAME
		shell.add_child(root)
	for child: Node in root.get_children():
		child.free()
	var material := _cue_material()
	for cue: Dictionary in _CUES:
		_add_cue(root, cue, material)


static func _add_cue(parent: Node3D, cue: Dictionary, material: StandardMaterial3D) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = str(cue["name"])
	mesh_instance.position = cue["position"] as Vector3
	mesh_instance.rotation_degrees = cue["rotation"] as Vector3
	var mesh := BoxMesh.new()
	mesh.size = cue["size"] as Vector3
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.set_meta("route_cue_role", "floor_wear")
	parent.add_child(mesh_instance)


static func _cue_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.12, 0.08, 0.055, _CUE_ALPHA)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.95
	return material
