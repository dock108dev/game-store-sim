## Shared low-poly detail vocabulary for starter-store visual dressing.
class_name StarterDetailBuilder
extends RefCounted

const FAMILY_WOOD_LAMINATE: StringName = &"wood_laminate"
const FAMILY_DARK_DEVICE_PLASTIC: StringName = &"dark_device_plastic"
const FAMILY_CARDBOARD: StringName = &"cardboard"
const FAMILY_PAPER: StringName = &"paper"
const FAMILY_PRICE_TAG_WARM: StringName = &"price_tag_warm"
const FAMILY_STOCKROOM_COOL_METAL: StringName = &"stockroom_cool_metal"
const FAMILY_RUBBER: StringName = &"rubber"
const FAMILY_SHADOW_ACCENT: StringName = &"shadow_accent"

const ROLE_PANEL: StringName = &"panel"
const ROLE_TRIM: StringName = &"trim"
const ROLE_LABEL: StringName = &"label"
const ROLE_SEAM: StringName = &"seam"
const ROLE_LIP: StringName = &"lip"
const ROLE_BRACE: StringName = &"brace"
const ROLE_MAT: StringName = &"mat"
const ROLE_CABLE: StringName = &"cable"

const MIN_DETAIL_THICKNESS: float = 0.012
const MAX_DETAIL_THICKNESS: float = 0.060
const SURFACE_OFFSET: float = 0.016
const PRODUCT_PANEL_OFFSET: float = 0.002
const PRODUCT_PRICE_TAG_SIZE: Vector3 = Vector3(0.070, 0.026, 0.006)

const _MATERIAL_SPECS: Dictionary = {
	FAMILY_WOOD_LAMINATE: {
		"color": Color(0.54, 0.34, 0.17, 1.0),
		"roughness": 0.86,
	},
	FAMILY_DARK_DEVICE_PLASTIC: {
		"color": Color(0.10, 0.11, 0.13, 1.0),
		"roughness": 0.84,
	},
	FAMILY_CARDBOARD: {
		"color": Color(0.56, 0.36, 0.18, 1.0),
		"roughness": 0.90,
	},
	FAMILY_PAPER: {
		"color": Color(0.96, 0.90, 0.74, 1.0),
		"roughness": 0.92,
	},
	FAMILY_PRICE_TAG_WARM: {
		"color": Color(0.94, 0.79, 0.48, 1.0),
		"emission": Color(0.72, 0.48, 0.18, 1.0),
		"emission_energy": 0.08,
		"roughness": 0.72,
	},
	FAMILY_STOCKROOM_COOL_METAL: {
		"color": Color(0.24, 0.28, 0.30, 1.0),
		"roughness": 0.88,
	},
	FAMILY_RUBBER: {
		"color": Color(0.05, 0.055, 0.055, 1.0),
		"roughness": 0.94,
	},
	FAMILY_SHADOW_ACCENT: {
		"color": Color(0.17, 0.18, 0.18, 1.0),
		"roughness": 0.95,
	},
}


static func material_family_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in _MATERIAL_SPECS.keys():
		ids.append(raw_id as StringName)
	return ids


static func material_for(family: StringName) -> StandardMaterial3D:
	var specs: Dictionary = _MATERIAL_SPECS.get(family, {}) as Dictionary
	if specs.is_empty():
		return null
	var material := StandardMaterial3D.new()
	material.resource_name = String(family)
	material.albedo_color = specs.get("color", Color.WHITE) as Color
	material.roughness = float(specs.get("roughness", 0.86))
	material.metallic = 0.0
	var emission_energy: float = float(specs.get("emission_energy", 0.0))
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = specs.get("emission", Color.TRANSPARENT) as Color
		material.emission_energy_multiplier = emission_energy
	return material


static func add_box_detail(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	family: StringName,
	role: StringName
) -> MeshInstance3D:
	var material: StandardMaterial3D = material_for(family)
	if material == null:
		return null
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	mesh_instance.position = position
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	apply_visual_metadata(mesh_instance, family, role)
	parent.add_child(mesh_instance)
	return mesh_instance


static func apply_visual_metadata(node: Node, family: StringName, role: StringName) -> void:
	if node == null:
		return
	node.set_meta("starter_visual_only", true)
	node.set_meta("starter_material_family", family)
	node.set_meta("starter_detail_role", role)


static func product_price_tag(price_cents: int) -> MeshInstance3D:
	var tag := MeshInstance3D.new()
	tag.name = "ProductPriceTag"
	var mesh := BoxMesh.new()
	mesh.size = PRODUCT_PRICE_TAG_SIZE
	tag.mesh = mesh
	tag.material_override = material_for(FAMILY_PRICE_TAG_WARM)
	tag.position = Vector3(0.060, -0.080, 0.036)
	tag.set_meta("price_cents", price_cents)
	apply_visual_metadata(tag, FAMILY_PRICE_TAG_WARM, ROLE_LABEL)
	return tag


static func material_family_for_node(node: Node) -> StringName:
	if node == null:
		return &""
	if node.has_meta("starter_material_family"):
		return node.get_meta("starter_material_family") as StringName
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance == null:
		return &""
	var material: Material = mesh_instance.material_override
	if material == null:
		return &""
	return StringName(material.resource_name)
