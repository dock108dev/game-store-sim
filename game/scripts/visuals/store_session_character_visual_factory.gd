class_name StoreSessionCharacterVisualFactory
extends RefCounted

## Runtime character visual builder for store-session NPCs.
##
## This is deliberately visual-only: `StoreSessionController` owns role,
## stage, trigger sizing, and movement. This factory owns the silhouette so
## first-person NPCs do not regress to block placeholders.

const MANAGER_DETAIL_PARTS: Array[String] = ["Badge", "NameTag", "Lanyard", "Clipboard"]


static func configure_customer_proxy(proxy_root: Node3D, is_manager_role: bool) -> void:
	if proxy_root == null:
		return
	_remove_stale_parts(proxy_root)
	_configure_capsule(
		proxy_root,
		"Body",
		0.22,
		0.92,
		Vector3(0.0, 0.78, 0.0),
		Color(0.16, 0.29, 0.42, 1.0)
	)
	_configure_sphere(
		proxy_root,
		"Head",
		0.18,
		0.34,
		Vector3(0.0, 1.38, 0.0),
		Color(0.72, 0.59, 0.50, 1.0)
	)
	_configure_sphere(
		proxy_root,
		"HairCap",
		0.19,
		0.16,
		Vector3(0.0, 1.53, -0.01),
		Color(0.10, 0.07, 0.05, 1.0)
	)
	_configure_box(
		proxy_root,
		"FaceBand",
		Vector3(0.23, 0.055, 0.024),
		Vector3(0.0, 1.38, 0.17),
		Color(0.84, 0.68, 0.55, 1.0)
	)
	_configure_capsule(
		proxy_root,
		"ArmLeft",
		0.055,
		0.62,
		Vector3(-0.29, 0.78, 0.01),
		Color(0.57, 0.46, 0.38, 1.0),
		Vector3(0.0, 0.0, -7.0)
	)
	_configure_capsule(
		proxy_root,
		"ArmRight",
		0.055,
		0.62,
		Vector3(0.29, 0.78, 0.01),
		Color(0.57, 0.46, 0.38, 1.0),
		Vector3(0.0, 0.0, 7.0)
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
		Vector3(0.14, 0.09, 0.022),
		Vector3(-0.115, 0.99, 0.145),
		Color(0.98, 0.78, 0.30, 1.0)
	)
	_configure_box(
		proxy_root,
		"NameTag",
		Vector3(0.17, 0.07, 0.022),
		Vector3(0.12, 1.05, 0.145),
		Color(0.93, 0.85, 0.62, 1.0)
	)
	_configure_box(
		proxy_root,
		"Lanyard",
		Vector3(0.05, 0.32, 0.022),
		Vector3(0.0, 0.93, 0.148),
		Color(0.96, 0.72, 0.26, 1.0)
	)
	_configure_box(
		proxy_root,
		"Clipboard",
		Vector3(0.23, 0.32, 0.034),
		Vector3(0.32, 0.62, 0.14),
		Color(0.50, 0.35, 0.21, 1.0),
		Vector3(0.0, 0.0, -8.0)
	)
	set_manager_details_visible(proxy_root, is_manager_role)


static func set_manager_details_visible(proxy_root: Node, is_manager_role: bool) -> void:
	if proxy_root == null:
		return
	for part_name: String in MANAGER_DETAIL_PARTS:
		var part: Node3D = proxy_root.get_node_or_null(part_name) as Node3D
		if part != null:
			part.visible = is_manager_role


static func _remove_stale_parts(proxy_root: Node3D) -> void:
	for stale_name: String in ["Marker"]:
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
	rotation_degrees: Vector3 = Vector3.ZERO
) -> void:
	var part: MeshInstance3D = _mesh_part(proxy_root, part_name)
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	_apply_part_transform(part, position, rotation_degrees)
	part.material_override = _material(color)


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


static func _apply_part_transform(
	part: MeshInstance3D, position: Vector3, rotation_degrees: Vector3
) -> void:
	part.position = position
	part.rotation_degrees = rotation_degrees
	part.scale = Vector3.ONE


static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	return material
