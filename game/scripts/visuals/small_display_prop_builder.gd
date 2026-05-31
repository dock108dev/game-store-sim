## Low-poly visual-only starter display props for store dressing.
class_name SmallDisplayPropBuilder
extends RefCounted

const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)

const CATEGORY_ACRYLIC_STAND: StringName = &"acrylic_stand"
const CATEGORY_CONTROLLER_BIN: StringName = &"controller_bin"
const CATEGORY_REPAIR_TESTING_MAT: StringName = &"repair_testing_mat"
const CATEGORY_CLIPBOARD_INTAKE_SLIP: StringName = &"clipboard_intake_slip"
const CATEGORY_TAPED_BOX_LABEL: StringName = &"taped_box_label"
const CATEGORY_SECURITY_TAG_BLOCK: StringName = &"security_tag_block"


## Builds a small display prop by category without gameplay collision or slots.
static func build(category: StringName, store_visual_id: StringName) -> Node3D:
	match category:
		CATEGORY_ACRYLIC_STAND:
			return acrylic_stand(store_visual_id)
		CATEGORY_CONTROLLER_BIN:
			return controller_bin(store_visual_id)
		CATEGORY_REPAIR_TESTING_MAT:
			return repair_testing_mat(store_visual_id)
		CATEGORY_TAPED_BOX_LABEL:
			return taped_box_label(store_visual_id)
		CATEGORY_SECURITY_TAG_BLOCK:
			return security_tag_block(store_visual_id)
	return null


## Builds a small acrylic stand for upright product display.
static func acrylic_stand(store_visual_id: StringName) -> Node3D:
	var root: Node3D = _root("PropAcrylicStand", store_visual_id, CATEGORY_ACRYLIC_STAND)
	_add_acrylic_box(root, "BackPlate", Vector3(0.0, 0.20, 0.035), Vector3(0.34, 0.34, 0.025))
	_add_acrylic_box(root, "BaseFoot", Vector3(0.0, 0.035, 0.02), Vector3(0.38, 0.05, 0.22))
	_add_acrylic_box(root, "FrontLip", Vector3(0.0, 0.085, -0.085), Vector3(0.36, 0.06, 0.03))
	_add_box(
		root,
		"ShadowFoot",
		Vector3(0.0, 0.012, 0.02),
		Vector3(0.40, 0.024, 0.24),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_TRIM
	)
	return root


## Builds a decorative controller bin separate from the slotted gameplay fixture.
static func controller_bin(store_visual_id: StringName) -> Node3D:
	var root: Node3D = _root("PropControllerBin", store_visual_id, CATEGORY_CONTROLLER_BIN)
	root.set_meta("decorative_variant_for", "res://game/scenes/stores/fixtures/controller_bin.tscn")
	_add_box(
		root,
		"BinBody",
		Vector3(0.0, 0.16, 0.0),
		Vector3(0.58, 0.32, 0.34),
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE,
		StarterDetailBuilderScript.ROLE_PANEL
	)
	_add_box(
		root,
		"BinOpenShadow",
		Vector3(0.0, 0.34, 0.0),
		Vector3(0.50, 0.028, 0.26),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_SEAM
	)
	_add_box(
		root,
		"FrontRim",
		Vector3(0.0, 0.37, -0.19),
		Vector3(0.64, 0.07, 0.045),
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE,
		StarterDetailBuilderScript.ROLE_LIP
	)
	_add_box(
		root,
		"BackRim",
		Vector3(0.0, 0.37, 0.19),
		Vector3(0.64, 0.07, 0.045),
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE,
		StarterDetailBuilderScript.ROLE_LIP
	)
	for index: int in range(3):
		var x_offset: float = -0.18 + float(index) * 0.18
		_add_controller_silhouette(root, index, Vector3(x_offset, 0.41, -0.01))
	return root


## Builds a rubber repair and testing mat with small bench detail.
static func repair_testing_mat(store_visual_id: StringName) -> Node3D:
	var root: Node3D = _root("PropRepairTestingMat", store_visual_id, CATEGORY_REPAIR_TESTING_MAT)
	_add_box(
		root,
		"MatBody",
		Vector3.ZERO,
		Vector3(0.72, 0.026, 0.42),
		StarterDetailBuilderScript.FAMILY_RUBBER,
		StarterDetailBuilderScript.ROLE_MAT
	)
	for x_offset: float in [-0.18, 0.0, 0.18]:
		_add_box(
			root,
			"MatGridLineX%03d" % int(round((x_offset + 0.36) * 100.0)),
			Vector3(x_offset, 0.018, 0.0),
			Vector3(0.012, 0.012, 0.38),
			StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
			StarterDetailBuilderScript.ROLE_SEAM
		)
	for z_offset: float in [-0.10, 0.10]:
		_add_box(
			root,
			"MatGridLineZ%03d" % int(round((z_offset + 0.22) * 100.0)),
			Vector3(0.0, 0.020, z_offset),
			Vector3(0.66, 0.012, 0.012),
			StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
			StarterDetailBuilderScript.ROLE_SEAM
		)
	_add_box(
		root,
		"TestPad",
		Vector3(0.22, 0.042, -0.08),
		Vector3(0.24, 0.026, 0.16),
		StarterDetailBuilderScript.FAMILY_DARK_DEVICE_PLASTIC,
		StarterDetailBuilderScript.ROLE_PANEL
	)
	_add_box(
		root,
		"ScrewTray",
		Vector3(-0.24, 0.040, 0.11),
		Vector3(0.16, 0.030, 0.12),
		StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL,
		StarterDetailBuilderScript.ROLE_PANEL
	)
	return root


## Builds a reusable taped paper label for boxes and bins.
static func taped_box_label(store_visual_id: StringName) -> Node3D:
	var root: Node3D = _root("PropTapedBoxLabel", store_visual_id, CATEGORY_TAPED_BOX_LABEL)
	_add_box(
		root,
		"LabelPaper",
		Vector3.ZERO,
		Vector3(0.34, 0.018, 0.16),
		StarterDetailBuilderScript.FAMILY_PAPER,
		StarterDetailBuilderScript.ROLE_LABEL
	)
	_add_box(
		root,
		"TopTape",
		Vector3(0.0, 0.018, -0.075),
		Vector3(0.38, 0.014, 0.030),
		StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM,
		StarterDetailBuilderScript.ROLE_TRIM
	)
	_add_box(
		root,
		"BottomTape",
		Vector3(0.0, 0.018, 0.075),
		Vector3(0.38, 0.014, 0.030),
		StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM,
		StarterDetailBuilderScript.ROLE_TRIM
	)
	_add_box(
		root,
		"InkLine",
		Vector3(-0.02, 0.028, 0.0),
		Vector3(0.22, 0.010, 0.012),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_SEAM
	)
	return root


## Builds a small block of security tags for checkout or shelf dressing.
static func security_tag_block(store_visual_id: StringName) -> Node3D:
	var root: Node3D = _root("PropSecurityTagBlock", store_visual_id, CATEGORY_SECURITY_TAG_BLOCK)
	for index: int in range(4):
		var x_offset: float = -0.135 + float(index) * 0.09
		_add_box(
			root,
			"TagBlock%02d" % index,
			Vector3(x_offset, 0.045, 0.0),
			Vector3(0.070, 0.090, 0.13),
			StarterDetailBuilderScript.FAMILY_DARK_DEVICE_PLASTIC,
			StarterDetailBuilderScript.ROLE_PANEL
		)
		_add_box(
			root,
			"TagStripe%02d" % index,
			Vector3(x_offset, 0.095, -0.068),
			Vector3(0.052, 0.014, 0.010),
			StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM,
			StarterDetailBuilderScript.ROLE_LABEL
		)
	_add_box(
		root,
		"TagTray",
		Vector3(0.0, 0.012, 0.0),
		Vector3(0.44, 0.024, 0.17),
		StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL,
		StarterDetailBuilderScript.ROLE_PANEL
	)
	return root


static func _root(name: String, store_visual_id: StringName, category: StringName) -> Node3D:
	var root := Node3D.new()
	root.name = name
	root.set_meta("store_visual_id", store_visual_id)
	root.set_meta("store_visual_source", "store_visual_kit")
	root.set_meta("visual_only", true)
	root.set_meta("small_display_prop_category", category)
	return root


static func _add_controller_silhouette(parent: Node3D, index: int, position: Vector3) -> void:
	_add_box(
		parent,
		"ControllerShell%02d" % index,
		position,
		Vector3(0.15, 0.035, 0.08),
		StarterDetailBuilderScript.FAMILY_DARK_DEVICE_PLASTIC,
		StarterDetailBuilderScript.ROLE_PANEL,
		Vector3(0.0, float(index - 1) * 8.0, 0.0)
	)
	_add_box(
		parent,
		"ControllerButton%02dA" % index,
		position + Vector3(0.040, 0.026, -0.024),
		Vector3(0.025, 0.018, 0.018),
		StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM,
		StarterDetailBuilderScript.ROLE_LABEL
	)
	_add_box(
		parent,
		"ControllerButton%02dB" % index,
		position + Vector3(0.070, 0.026, 0.020),
		Vector3(0.020, 0.018, 0.018),
		StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL,
		StarterDetailBuilderScript.ROLE_LABEL
	)


static func _add_acrylic_box(
	parent: Node3D, name: String, position: Vector3, size: Vector3
) -> MeshInstance3D:
	var material := StandardMaterial3D.new()
	material.resource_name = "acrylic_clear_blue"
	material.albedo_color = Color(0.58, 0.80, 0.88, 0.86)
	material.roughness = 0.48
	material.metallic = 0.0
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.position = position
	instance.mesh = mesh
	instance.material_override = material
	StarterDetailBuilderScript.apply_visual_metadata(
		instance,
		&"acrylic_clear_blue",
		StarterDetailBuilderScript.ROLE_PANEL
	)
	parent.add_child(instance)
	return instance


static func _add_box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	family: StringName,
	role: StringName,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var material: StandardMaterial3D = StarterDetailBuilderScript.material_for(family)
	if material == null:
		return null
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.position = position
	instance.rotation_degrees = rotation_degrees
	instance.mesh = mesh
	instance.material_override = material
	StarterDetailBuilderScript.apply_visual_metadata(instance, family, role)
	parent.add_child(instance)
	return instance
