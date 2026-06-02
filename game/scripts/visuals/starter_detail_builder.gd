## Shared low-poly detail vocabulary for starter-store visual dressing.
class_name StarterDetailBuilder
extends RefCounted

const StoreVisualStyleScript: GDScript = preload("res://game/scripts/visuals/store_visual_style.gd")

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


static func material_family_ids() -> Array[StringName]:
	return StoreVisualStyleScript.starter_material_family_ids()


static func material_for(family: StringName) -> StandardMaterial3D:
	return StoreVisualStyleScript.material_for_family(family)


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
	StoreVisualStyleScript.apply_metadata(node, family, role)


static func product_price_tag(price_cents: int) -> MeshInstance3D:
	var tag := MeshInstance3D.new()
	tag.name = "ProductPriceTag"
	var mesh := BoxMesh.new()
	mesh.size = PRODUCT_PRICE_TAG_SIZE
	tag.mesh = mesh
	tag.material_override = StoreVisualStyleScript.material_for_token(
		StoreVisualStyleScript.TOKEN_PRICE_TAG_FILL
	)
	tag.position = Vector3(0.060, -0.080, 0.036)
	tag.set_meta("price_cents", price_cents)
	StoreVisualStyleScript.apply_metadata(
		tag, FAMILY_PRICE_TAG_WARM, ROLE_LABEL, StoreVisualStyleScript.TOKEN_PRICE_TAG_FILL
	)
	return tag


static func material_family_for_node(node: Node) -> StringName:
	return StoreVisualStyleScript.material_family_for_node(node)
