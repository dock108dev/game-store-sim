class_name StoreSessionCharacterVisualFactory
extends RefCounted

## Runtime character visual builder for store-session NPCs.
##
## This is deliberately visual-only: `StoreSessionController` owns role,
## stage, trigger sizing, and movement. This factory owns the silhouette so
## first-person NPCs do not regress to block placeholders.

const CustomerVisualProfileScript: GDScript = preload(
	"res://game/scripts/characters/customer_visual_profile.gd"
)

const MANAGER_DETAIL_PARTS: Array[String] = [
	"ApronPanel",
	"Badge",
	"NameTag",
	"Lanyard",
	"KeyRing",
	"KeyA",
	"KeyB",
	"Clipboard",
	"ClipboardPaper",
]
const CUSTOMER_ACCENT_PARTS: Array[String] = [
	"ArchetypeAccentPrimary",
	"ArchetypeAccentSecondary",
]


static func configure_customer_proxy(
	proxy_root: Node3D,
	is_manager_role: bool,
	profile_id: String = "",
	archetype_id: StringName = &""
) -> void:
	if proxy_root == null:
		return
	_remove_stale_parts(proxy_root)
	_configure_capsule(
		proxy_root,
		"Body",
		0.20,
		0.98,
		Vector3(0.0, 0.80, 0.0),
		Color(0.16, 0.29, 0.42, 1.0)
	)
	_configure_box(
		proxy_root,
		"ApronPanel",
		Vector3(0.34, 0.52, 0.028),
		Vector3(0.0, 0.88, 0.164),
		Color(0.08, 0.16, 0.14, 1.0)
	)
	_configure_sphere(
		proxy_root,
		"Head",
		0.16,
		0.29,
		Vector3(0.0, 1.39, 0.0),
		Color(0.72, 0.59, 0.50, 1.0)
	)
	_configure_sphere(
		proxy_root,
		"HairCap",
		0.155,
		0.075,
		Vector3(0.0, 1.515, -0.015),
		Color(0.075, 0.055, 0.045, 1.0)
	)
	_configure_box(
		proxy_root,
		"EyeLine",
		Vector3(0.18, 0.022, 0.018),
		Vector3(0.0, 1.405, 0.157),
		Color(0.07, 0.055, 0.045, 1.0)
	)
	_configure_capsule(
		proxy_root,
		"ArmLeft",
		0.05,
		0.58,
		Vector3(-0.255, 0.78, 0.015),
		Color(0.57, 0.46, 0.38, 1.0),
		Vector3(0.0, 0.0, -5.0)
	)
	_configure_capsule(
		proxy_root,
		"ArmRight",
		0.05,
		0.58,
		Vector3(0.255, 0.78, 0.015),
		Color(0.57, 0.46, 0.38, 1.0),
		Vector3(0.0, 0.0, 5.0)
	)
	_configure_capsule(
		proxy_root,
		"LegLeft",
		0.07,
		0.52,
		Vector3(-0.105, 0.30, 0.0),
		Color(0.09, 0.12, 0.17, 1.0)
	)
	_configure_capsule(
		proxy_root,
		"LegRight",
		0.07,
		0.52,
		Vector3(0.105, 0.30, 0.0),
		Color(0.09, 0.12, 0.17, 1.0)
	)
	_configure_box(
		proxy_root,
		"ShoeLeft",
		Vector3(0.20, 0.07, 0.24),
		Vector3(-0.11, 0.04, 0.05),
		Color(0.045, 0.045, 0.045, 1.0)
	)
	_configure_box(
		proxy_root,
		"ShoeRight",
		Vector3(0.20, 0.07, 0.24),
		Vector3(0.11, 0.04, 0.05),
		Color(0.045, 0.045, 0.045, 1.0)
	)
	_configure_box(
		proxy_root,
		"Badge",
		Vector3(0.075, 0.055, 0.018),
		Vector3(-0.115, 1.035, 0.181),
		Color(0.86, 0.78, 0.48, 1.0),
		Vector3.ZERO,
		0.15,
		0.42
	)
	_configure_box(
		proxy_root,
		"NameTag",
		Vector3(0.13, 0.045, 0.018),
		Vector3(0.095, 1.055, 0.181),
		Color(0.93, 0.85, 0.62, 1.0),
		Vector3.ZERO,
		0.0,
		0.48
	)
	_configure_box(
		proxy_root,
		"Lanyard",
		Vector3(0.032, 0.22, 0.018),
		Vector3(0.0, 0.93, 0.181),
		Color(0.72, 0.62, 0.36, 1.0),
		Vector3.ZERO,
		0.25,
		0.56
	)
	_configure_box(
		proxy_root,
		"KeyRing",
		Vector3(0.065, 0.065, 0.014),
		Vector3(-0.215, 0.73, 0.174),
		Color(0.72, 0.62, 0.36, 1.0),
		Vector3(0.0, 0.0, 45.0),
		0.35,
		0.54
	)
	_configure_box(
		proxy_root,
		"KeyA",
		Vector3(0.024, 0.115, 0.012),
		Vector3(-0.225, 0.645, 0.174),
		Color(0.72, 0.62, 0.36, 1.0),
		Vector3(0.0, 0.0, -8.0),
		0.45,
		0.5
	)
	_configure_box(
		proxy_root,
		"KeyB",
		Vector3(0.022, 0.095, 0.012),
		Vector3(-0.175, 0.65, 0.174),
		Color(0.72, 0.62, 0.36, 1.0),
		Vector3(0.0, 0.0, 16.0),
		0.45,
		0.5
	)
	_configure_box(
		proxy_root,
		"Clipboard",
		Vector3(0.16, 0.26, 0.028),
		Vector3(0.285, 0.61, 0.145),
		Color(0.50, 0.35, 0.21, 1.0),
		Vector3(0.0, 0.0, -12.0),
		0.0,
		0.75
	)
	_configure_box(
		proxy_root,
		"ClipboardPaper",
		Vector3(0.125, 0.205, 0.01),
		Vector3(0.285, 0.61, 0.164),
		Color(0.88, 0.84, 0.74, 1.0),
		Vector3(0.0, 0.0, -12.0),
		0.0,
		0.68
	)
	set_manager_details_visible(proxy_root, is_manager_role)
	set_customer_accent_visible(proxy_root, not is_manager_role)
	if not is_manager_role:
		configure_customer_accent(proxy_root, profile_id, archetype_id)


static func set_manager_details_visible(proxy_root: Node, is_manager_role: bool) -> void:
	if proxy_root == null:
		return
	for part_name: String in MANAGER_DETAIL_PARTS:
		var part: Node3D = proxy_root.get_node_or_null(part_name) as Node3D
		if part != null:
			part.visible = is_manager_role


static func set_customer_accent_visible(proxy_root: Node, visible: bool) -> void:
	if proxy_root == null:
		return
	for part_name: String in CUSTOMER_ACCENT_PARTS:
		var part: Node3D = proxy_root.get_node_or_null(part_name) as Node3D
		if part != null:
			part.visible = visible


static func configure_customer_accent(
	proxy_root: Node3D,
	profile_id: String = "",
	archetype_id: StringName = &""
) -> void:
	if proxy_root == null:
		return
	var accent: Dictionary = CustomerVisualProfileScript.accent_for(
		profile_id,
		archetype_id
	)
	_configure_accent_box(proxy_root, "ArchetypeAccentPrimary", accent, true)
	_configure_accent_box(proxy_root, "ArchetypeAccentSecondary", accent, false)


static func _remove_stale_parts(proxy_root: Node3D) -> void:
	for stale_name: String in ["Marker", "FaceBand"]:
		var stale: Node = proxy_root.get_node_or_null(stale_name)
		if stale != null:
			stale.queue_free()


static func _configure_capsule(
	proxy_root: Node3D,
	part_name: String,
	radius: float,
	height: float,
	position: Vector3,
	color: Color,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> void:
	var part: MeshInstance3D = _mesh_part(proxy_root, part_name)
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 14
	mesh.rings = 6
	part.mesh = mesh
	_apply_part_transform(part, position, rotation_degrees)
	part.material_override = _material(color)


static func _configure_sphere(
	proxy_root: Node3D,
	part_name: String,
	radius: float,
	height: float,
	position: Vector3,
	color: Color
) -> void:
	var part: MeshInstance3D = _mesh_part(proxy_root, part_name)
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 8
	part.mesh = mesh
	_apply_part_transform(part, position, Vector3.ZERO)
	part.material_override = _material(color)


static func _configure_box(
	proxy_root: Node3D,
	part_name: String,
	size: Vector3,
	position: Vector3,
	color: Color,
	rotation_degrees: Vector3 = Vector3.ZERO,
	metallic: float = 0.0,
	roughness: float = 0.86
) -> void:
	var part: MeshInstance3D = _mesh_part(proxy_root, part_name)
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	_apply_part_transform(part, position, rotation_degrees)
	part.material_override = _material(color, metallic, roughness)


static func _configure_accent_box(
	proxy_root: Node3D,
	part_name: String,
	accent: Dictionary,
	primary: bool
) -> void:
	var shape: StringName = StringName(str(accent.get("shape", &"soft_pin")))
	var color_value: Variant = accent.get("primary_color", Color.WHITE)
	if not primary:
		color_value = accent.get("secondary_color", Color.WHITE)
	_configure_box(
		proxy_root,
		part_name,
		_accent_size(shape, primary),
		_accent_position(shape, primary),
		color_value as Color,
		_accent_rotation(shape, primary),
		0.0,
		0.70
	)
	var part: MeshInstance3D = proxy_root.get_node_or_null(part_name) as MeshInstance3D
	if part != null:
		part.set_meta("accent_key", String(accent.get("key", &"casual_shopper")))
		part.set_meta("accent_shape", String(shape))
		part.visible = true


static func _mesh_part(proxy_root: Node3D, part_name: String) -> MeshInstance3D:
	var part_ref: Node = proxy_root.get_node_or_null(part_name)
	if part_ref is MeshInstance3D:
		return part_ref as MeshInstance3D
	if part_ref != null:
		proxy_root.remove_child(part_ref)
		part_ref.free()
	var part := MeshInstance3D.new()
	part.name = part_name
	proxy_root.add_child(part)
	return part


static func _accent_size(shape: StringName, primary: bool) -> Vector3:
	match shape:
		&"catalog_card":
			return Vector3(0.13, 0.09, 0.024) if primary else Vector3(0.06, 0.09, 0.026)
		&"question_tab":
			return Vector3(0.12, 0.12, 0.025) if primary else Vector3(0.04, 0.16, 0.026)
		&"coupon_strip":
			return Vector3(0.18, 0.042, 0.024) if primary else Vector3(0.045, 0.11, 0.026)
		&"neon_cap":
			return Vector3(0.19, 0.036, 0.028) if primary else Vector3(0.08, 0.05, 0.03)
		&"pennant":
			return Vector3(0.16, 0.055, 0.024) if primary else Vector3(0.055, 0.14, 0.026)
		&"price_tag":
			return Vector3(0.11, 0.14, 0.024) if primary else Vector3(0.08, 0.035, 0.026)
		&"return_slash":
			return Vector3(0.16, 0.045, 0.024) if primary else Vector3(0.04, 0.15, 0.026)
		&"low_badge":
			return Vector3(0.09, 0.08, 0.024) if primary else Vector3(0.13, 0.032, 0.026)
		&"gold_lapel":
			return Vector3(0.10, 0.12, 0.024) if primary else Vector3(0.07, 0.07, 0.026)
	return Vector3(0.11, 0.065, 0.024) if primary else Vector3(0.055, 0.055, 0.026)


static func _accent_position(shape: StringName, primary: bool) -> Vector3:
	if shape == &"neon_cap":
		return Vector3(0.0, 1.60, 0.17) if primary else Vector3(0.11, 1.52, 0.17)
	if shape == &"low_badge":
		return Vector3(-0.13, 0.68, 0.182) if primary else Vector3(0.12, 0.66, 0.182)
	return Vector3(-0.105, 1.01, 0.183) if primary else Vector3(0.115, 0.99, 0.184)


static func _accent_rotation(shape: StringName, primary: bool) -> Vector3:
	match shape:
		&"coupon_strip":
			return Vector3(0.0, 0.0, -8.0 if primary else 8.0)
		&"pennant":
			return Vector3(0.0, 0.0, 12.0 if primary else -12.0)
		&"price_tag":
			return Vector3(0.0, 0.0, -10.0 if primary else 0.0)
		&"return_slash":
			return Vector3(0.0, 0.0, -28.0 if primary else 28.0)
		&"gold_lapel":
			return Vector3(0.0, 0.0, 18.0 if primary else -18.0)
	return Vector3.ZERO


static func _apply_part_transform(
	part: MeshInstance3D, position: Vector3, rotation_degrees: Vector3
) -> void:
	part.position = position
	part.rotation_degrees = rotation_degrees
	part.scale = Vector3.ONE


static func _material(
	color: Color, metallic: float = 0.0, roughness: float = 0.86
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material
