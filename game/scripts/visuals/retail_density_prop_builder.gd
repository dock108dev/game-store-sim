## Builds original, visual-only small retail props for generated store dressing.
class_name RetailDensityPropBuilder
extends RefCounted

const KIND_GAME_CASE: StringName = &"game_case"
const KIND_CARTRIDGE: StringName = &"cartridge"
const KIND_CONSOLE_BOX: StringName = &"console_box"
const KIND_CONTROLLER: StringName = &"controller"
const KIND_PRICE_TAG: StringName = &"price_tag"
const KIND_CHECKOUT_STATE: StringName = &"checkout_state"
const KIND_HELD_ITEM: StringName = &"held_item"
const KIND_QUEUE_MARKER: StringName = &"queue_marker"
const KIND_MALL_CONTEXT: StringName = &"mall_context"

const _DEFAULT_BODY := Color(0.18, 0.16, 0.13, 1.0)
const _DEFAULT_PANEL := Color(0.78, 0.68, 0.42, 1.0)


static func build(spec: Dictionary, materials: Dictionary = {}) -> Node3D:
	var root := Node3D.new()
	root.name = str(spec.get("name", "RetailDensityProp"))
	root.position = spec.get("position", Vector3.ZERO) as Vector3
	root.rotation_degrees = spec.get("rotation_degrees", Vector3.ZERO) as Vector3
	root.scale = spec.get("scale", Vector3.ONE) as Vector3
	root.set_meta("visual_only", true)
	root.set_meta("phase4_retail_prop", true)
	root.set_meta("store_visual_source", "retail_density_prop_builder")
	root.set_meta("retail_prop_kind", str(spec.get("kind", "")))
	root.set_meta("retail_prop_role", str(spec.get("role", "")))
	root.set_meta("retail_state_key", str(spec.get("state_key", "")))
	root.set_meta("retail_state_value", str(spec.get("state", spec.get("state_value", ""))))
	root.set_meta("retail_review_tags", spec.get("review_tags", []))
	match spec.get("kind", KIND_GAME_CASE) as StringName:
		KIND_CARTRIDGE:
			_build_cartridge(root, spec, materials)
		KIND_CONSOLE_BOX:
			_build_console_box(root, spec, materials)
		KIND_CONTROLLER:
			_build_controller(root, spec, materials)
		KIND_PRICE_TAG:
			_build_price_tag(root, spec, materials)
		KIND_CHECKOUT_STATE:
			_build_checkout_state(root, spec, materials)
		KIND_HELD_ITEM:
			_build_held_item(root, spec, materials)
		KIND_QUEUE_MARKER:
			_build_queue_marker(root, spec, materials)
		KIND_MALL_CONTEXT:
			_build_mall_context(root, spec, materials)
		_:
			_build_game_case(root, spec, materials)
	return root


static func _build_game_case(root: Node3D, spec: Dictionary, materials: Dictionary) -> void:
	var accent: StandardMaterial3D = _material(spec, materials, "accent", Color(0.12, 0.62, 0.66))
	_add_box(root, "CaseBody", Vector3.ZERO, Vector3(0.22, 0.34, 0.036), _mat(_DEFAULT_BODY))
	_add_box(root, "FrontLabelBlock", Vector3(0.0, 0.035, 0.022), Vector3(0.17, 0.18, 0.010), accent)
	_add_box(root, "SpineBand", Vector3(-0.095, 0.0, 0.026), Vector3(0.025, 0.30, 0.010), accent)
	_add_box(
		root,
		"ConditionSticker",
		Vector3(0.066, -0.118, 0.030),
		Vector3(0.046, 0.034, 0.010),
		_material(spec, materials, "tag", Color(0.92, 0.72, 0.28))
	)


static func _build_cartridge(root: Node3D, spec: Dictionary, materials: Dictionary) -> void:
	_add_box(
		root,
		"CartridgeBody",
		Vector3.ZERO,
		Vector3(0.20, 0.16, 0.048),
		_mat(Color(0.12, 0.13, 0.12))
	)
	_add_box(
		root,
		"LabelRecess",
		Vector3(0.0, 0.014, 0.030),
		Vector3(0.13, 0.07, 0.010),
		_material(spec, materials, "accent", Color(0.74, 0.62, 0.36))
	)
	_add_box(
		root,
		"ContactStrip",
		Vector3(0.0, -0.073, 0.032),
		Vector3(0.15, 0.016, 0.012),
		_mat(Color(0.82, 0.64, 0.30))
	)
	_add_box(
		root,
		"SideNotch",
		Vector3(-0.092, -0.020, 0.034),
		Vector3(0.024, 0.042, 0.010),
		_mat(Color(0.05, 0.05, 0.045))
	)


static func _build_console_box(root: Node3D, spec: Dictionary, materials: Dictionary) -> void:
	_add_box(
		root,
		"ConsoleBoxBody",
		Vector3.ZERO,
		Vector3(0.36, 0.34, 0.16),
		_mat(Color(0.66, 0.56, 0.38))
	)
	_add_box(
		root,
		"HandleSlot",
		Vector3(0.0, 0.125, 0.086),
		Vector3(0.17, 0.030, 0.014),
		_mat(Color(0.10, 0.08, 0.06))
	)
	_add_box(
		root,
		"PlatformStripe",
		Vector3(0.0, 0.025, 0.090),
		Vector3(0.30, 0.050, 0.014),
		_material(spec, materials, "accent", Color(0.14, 0.58, 0.66))
	)
	_add_box(
		root,
		"FragileSticker",
		Vector3(0.105, -0.080, 0.092),
		Vector3(0.075, 0.044, 0.014),
		_mat(Color(0.90, 0.76, 0.40))
	)


static func _build_controller(root: Node3D, spec: Dictionary, materials: Dictionary) -> void:
	var body_mat: StandardMaterial3D = _material(spec, materials, "body", Color(0.08, 0.08, 0.075))
	_add_box(root, "ControllerBody", Vector3.ZERO, Vector3(0.24, 0.075, 0.090), body_mat)
	_add_box(root, "LeftGrip", Vector3(-0.088, -0.045, 0.0), Vector3(0.060, 0.092, 0.080), body_mat)
	_add_box(root, "RightGrip", Vector3(0.088, -0.045, 0.0), Vector3(0.060, 0.092, 0.080), body_mat)
	for index: int in range(3):
		_add_box(
			root,
			"ButtonDot%02d" % index,
			Vector3(0.055 + float(index) * 0.028, 0.018, 0.052),
			Vector3(0.016, 0.016, 0.012),
			_material(spec, materials, "accent", Color(0.24, 0.72, 0.54))
		)


static func _build_price_tag(root: Node3D, spec: Dictionary, materials: Dictionary) -> void:
	_add_box(
		root,
		"TagPlate",
		Vector3.ZERO,
		Vector3(0.18, 0.052, 0.014),
		_mat(Color(0.92, 0.74, 0.34))
	)
	_add_box(
		root,
		"PriceRule",
		Vector3(0.0, -0.014, 0.010),
		Vector3(0.13, 0.009, 0.010),
		_material(spec, materials, "accent", Color(0.10, 0.08, 0.06))
	)


static func _build_checkout_state(root: Node3D, spec: Dictionary, _materials: Dictionary) -> void:
	var state: String = str(spec.get("state", "pending"))
	var accent: Color = Color(0.28, 0.72, 0.86)
	if state == "settled":
		accent = Color(0.94, 0.72, 0.24)
	elif state == "no_sale":
		accent = Color(0.92, 0.40, 0.22)
	_add_box(
		root,
		"StateTray",
		Vector3.ZERO,
		Vector3(0.34, 0.018, 0.22),
		_mat(Color(0.10, 0.08, 0.06))
	)
	_add_box(
		root,
		"StateItem",
		Vector3(-0.055, 0.028, 0.018),
		Vector3(0.16, 0.060, 0.12),
		_mat(_DEFAULT_PANEL)
	)
	_add_box(
		root,
		"StateStrip",
		Vector3(0.082, 0.040, 0.026),
		Vector3(0.12, 0.026, 0.026),
		_mat(accent, accent, 0.30)
	)
	_add_box(
		root,
		"ReceiptSlip",
		Vector3(0.126, 0.052, -0.052),
		Vector3(0.092, 0.014, 0.072),
		_mat(Color(0.94, 0.90, 0.78))
	)


static func _build_held_item(root: Node3D, spec: Dictionary, materials: Dictionary) -> void:
	_build_game_case(root, spec, materials)
	_add_box(
		root,
		"HoldTag",
		Vector3(0.083, 0.128, 0.036),
		Vector3(0.052, 0.028, 0.010),
		_mat(Color(0.30, 0.84, 0.42), Color(0.22, 0.78, 0.36), 0.18)
	)


static func _build_queue_marker(root: Node3D, spec: Dictionary, materials: Dictionary) -> void:
	_add_box(
		root,
		"QueuePuck",
		Vector3.ZERO,
		Vector3(0.22, 0.018, 0.16),
		_mat(Color(0.18, 0.13, 0.10))
	)
	_add_box(
		root,
		"IntentStripe",
		Vector3(0.0, 0.014, 0.0),
		Vector3(0.16, 0.012, 0.025),
		_material(spec, materials, "accent", Color(0.94, 0.66, 0.22))
	)


static func _build_mall_context(root: Node3D, spec: Dictionary, materials: Dictionary) -> void:
	var role: String = str(spec.get("role", "mall_context"))
	if role == "planter":
		_add_box(
			root,
			"PlanterBase",
			Vector3.ZERO,
			Vector3(0.46, 0.18, 0.34),
			_mat(Color(0.18, 0.12, 0.08))
		)
		_add_box(
			root,
			"PlantMass",
			Vector3(0.0, 0.14, 0.0),
			Vector3(0.34, 0.12, 0.24),
			_mat(Color(0.12, 0.32, 0.18))
		)
	elif role == "bench":
		_add_box(
			root,
			"BenchSeat",
			Vector3.ZERO,
			Vector3(0.76, 0.08, 0.22),
			_mat(Color(0.22, 0.15, 0.10))
		)
		_add_box(
			root,
			"BenchBack",
			Vector3(0.0, 0.18, -0.08),
			Vector3(0.74, 0.20, 0.060),
			_mat(Color(0.16, 0.11, 0.08))
		)
	else:
		_add_box(
			root,
			"ContextPanel",
			Vector3.ZERO,
			Vector3(0.66, 0.36, 0.030),
			_material(spec, materials, "accent", Color(0.10, 0.14, 0.16))
		)
		_add_box(
			root,
			"ContextStripe",
			Vector3(0.0, 0.10, 0.020),
			Vector3(0.48, 0.040, 0.014),
			_mat(Color(0.90, 0.62, 0.20))
		)


static func _add_box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	material: StandardMaterial3D
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	mesh_instance.position = position
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.set_meta("visual_only", true)
	mesh_instance.set_meta("phase4_retail_prop_piece", true)
	parent.add_child(mesh_instance)
	return mesh_instance


static func _material(
	spec: Dictionary, materials: Dictionary, key: String, fallback: Color
) -> StandardMaterial3D:
	var material_key: String = str(spec.get("%s_material" % key, ""))
	if not material_key.is_empty() and materials.has(material_key):
		var material: StandardMaterial3D = materials.get(material_key) as StandardMaterial3D
		if material != null:
			return material
	return _mat(fallback)


static func _mat(
	albedo: Color, emission: Color = Color.TRANSPARENT, emission_energy: float = 0.0
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.84
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
