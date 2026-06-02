## Builds visual-only surfaces from unlocked store growth physical contracts.
class_name GrowthLayoutSurfaceBuilder
extends RefCounted

const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)
const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")

const META_GENERATED: StringName = &"growth_contract_surface"


static func build_surfaces(
	catalog: RefCounted, layout_id: StringName, active_unlocks: Array[StringName]
) -> Array[Node3D]:
	if catalog == null or not _layout_unlocked(catalog, layout_id, active_unlocks):
		return []
	var zones: Dictionary = catalog.call("get_named_zones", layout_id) as Dictionary
	var result: Array[Node3D] = []
	for contract: Dictionary in catalog.call("get_placement_contracts", layout_id, active_unlocks):
		var node: Node3D = _build_contract_node(contract, zones)
		if node != null:
			result.append(node)
	return result


static func _layout_unlocked(
	catalog: RefCounted, layout_id: StringName, active_unlocks: Array[StringName]
) -> bool:
	var metadata: Dictionary = catalog.call("get_validation_metadata", layout_id) as Dictionary
	var required_unlock: StringName = StringName(str(metadata.get("requires_unlock", "")))
	return String(required_unlock).is_empty() or active_unlocks.has(required_unlock)


static func _build_contract_node(contract: Dictionary, zones: Dictionary) -> Node3D:
	var role: String = str(contract.get("physical_role", ""))
	if role == "route_corridor" and _is_route_contract(contract):
		return _build_route_node(contract, zones)
	if not bool(contract.get("visual_dressing", false)) or not _is_growth_delta(contract):
		return null
	return _build_surface_node(contract, zones)


static func _is_growth_delta(contract: Dictionary) -> bool:
	var object_id: String = str(contract.get("object_id", ""))
	var zone_id: String = str(contract.get("zone_id", ""))
	return (
		object_id.begins_with("growth_")
		or object_id.begins_with("expanded_")
		or object_id == "stockroom_upgrade_surface"
		or object_id == "sales_floor_expansion_surface"
		or zone_id.begins_with("growth_")
		or zone_id.begins_with("expanded_")
		or zone_id == "stockroom_upgrade_surface"
		or zone_id == "sales_floor_expansion_surface"
	)


static func _is_route_contract(contract: Dictionary) -> bool:
	var object_id: String = str(contract.get("object_id", ""))
	return object_id == "customer_route_core" or object_id == "staff_route_core"


static func _build_surface_node(contract: Dictionary, zones: Dictionary) -> Node3D:
	var root := Node3D.new()
	var object_id: String = str(contract.get("object_id", "growth_surface"))
	var role: String = str(contract.get("physical_role", "visual_dressing"))
	var zone: Dictionary = zones.get(str(contract.get("zone_id", "")), {}) as Dictionary
	var footprint: Dictionary = contract.get("footprint", {}) as Dictionary
	var size: Vector3 = _vector3(footprint, "size", _vector3(zone, "size", Vector3.ONE))
	root.name = _node_name(object_id)
	root.position = _vector3(contract, "position", _vector3(zone, "position", Vector3.ZERO))
	root.rotation_degrees = _vector3(contract, "rotation_degrees", Vector3.ZERO)
	_apply_metadata(root, contract, size)
	_add_surface_details(root, role, size)
	return root


static func _build_route_node(contract: Dictionary, zones: Dictionary) -> Node3D:
	var zone: Dictionary = zones.get(str(contract.get("zone_id", "")), {}) as Dictionary
	var points: Array[Vector3] = _points(zone)
	if points.size() < 2:
		return null
	var root := Node3D.new()
	var object_id: String = str(contract.get("object_id", "route_corridor"))
	var width: float = float(
		(contract.get("footprint", {}) as Dictionary).get(
			"corridor_width", zone.get("corridor_width", 0.75)
		)
	)
	root.name = _node_name(object_id)
	_apply_metadata(root, contract, Vector3(width, 0.035, width))
	root.set_meta("corridor_width", width)
	root.set_meta("point_count", points.size())
	for index: int in range(points.size() - 1):
		_add_route_segment(root, points[index], points[index + 1], width, index)
	return root


static func _add_surface_details(root: Node3D, role: String, size: Vector3) -> void:
	var family: StringName = _family_for_role(role)
	var slab_height: float = clampf(size.y, 0.04, 0.16)
	var slab_size := Vector3(maxf(size.x, 0.08), slab_height, maxf(size.z, 0.08))
	StarterDetailBuilderScript.add_box_detail(
		root,
		"Surface",
		Vector3(0.0, slab_height * 0.5, 0.0),
		slab_size,
		family,
		StarterDetailBuilderScript.ROLE_PANEL
	)
	if role == "stockroom_upgrade_surface":
		_add_stockroom_details(root, size)
	elif role == "expansion_surface":
		_add_floor_details(root, size)
	else:
		_add_display_details(root, size)


static func _add_display_details(root: Node3D, size: Vector3) -> void:
	var family: StringName = StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE
	var rail_z: float = maxf(size.z * 0.38, 0.18)
	StarterDetailBuilderScript.add_box_detail(
		root,
		"FrontRail",
		Vector3(0.0, 0.22, rail_z),
		Vector3(size.x, 0.06, 0.05),
		family,
		StarterDetailBuilderScript.ROLE_LIP
	)
	StarterDetailBuilderScript.add_box_detail(
		root,
		"BackLabelRail",
		Vector3(0.0, 0.32, -rail_z),
		Vector3(size.x * 0.82, 0.10, 0.04),
		StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM,
		StarterDetailBuilderScript.ROLE_LABEL
	)


static func _add_floor_details(root: Node3D, size: Vector3) -> void:
	var seam_family: StringName = StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT
	for offset: float in [-0.33, 0.0, 0.33]:
		StarterDetailBuilderScript.add_box_detail(
			root,
			"FloorExpansionSeam%03d" % int((offset + 0.5) * 1000.0),
			Vector3(size.x * offset, 0.05, 0.0),
			Vector3(0.025, 0.018, size.z),
			seam_family,
			StarterDetailBuilderScript.ROLE_SEAM
		)


static func _add_stockroom_details(root: Node3D, size: Vector3) -> void:
	var rack_family: StringName = StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL
	for x: float in [-0.32, 0.32]:
		StarterDetailBuilderScript.add_box_detail(
			root,
			"UpgradeRack%03d" % int((x + 0.5) * 1000.0),
			Vector3(size.x * x, 0.42, 0.0),
			Vector3(0.08, 0.84, size.z * 0.82),
			rack_family,
			StarterDetailBuilderScript.ROLE_BRACE
		)
	StarterDetailBuilderScript.add_box_detail(
		root,
		"StockroomUpgradeLabel",
		Vector3(0.0, 0.92, size.z * 0.38),
		Vector3(size.x * 0.62, 0.12, 0.035),
		StarterDetailBuilderScript.FAMILY_PAPER,
		StarterDetailBuilderScript.ROLE_LABEL
	)


static func _add_route_segment(
	root: Node3D, start: Vector3, end: Vector3, width: float, index: int
) -> void:
	var delta: Vector3 = end - start
	var length: float = Vector2(delta.x, delta.z).length()
	if length <= 0.01:
		return
	var segment := Node3D.new()
	segment.name = "RouteSegment%02d" % index
	segment.position = (start + end) * 0.5 + Vector3(0.0, 0.025, 0.0)
	segment.rotation_degrees = Vector3(0.0, rad_to_deg(atan2(delta.x, delta.z)), 0.0)
	StarterDetailBuilderScript.add_box_detail(
		segment,
		"RouteBand",
		Vector3.ZERO,
		Vector3(width, 0.035, length),
		StarterDetailBuilderScript.FAMILY_RUBBER,
		StarterDetailBuilderScript.ROLE_MAT
	)
	root.add_child(segment)


static func _apply_metadata(root: Node3D, contract: Dictionary, footprint_size: Vector3) -> void:
	root.set_meta(META_GENERATED, true)
	root.set_meta("object_id", str(contract.get("object_id", "")))
	root.set_meta("zone", str(contract.get("zone_id", "")))
	root.set_meta("physical_role", str(contract.get("physical_role", "")))
	root.set_meta("footprint_size", footprint_size)
	root.set_meta("action_critical", bool(contract.get("action_critical", false)))
	root.set_meta("visual_dressing", bool(contract.get("visual_dressing", false)))


static func _family_for_role(role: String) -> StringName:
	if role == "stockroom_upgrade_surface":
		return StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL
	if role == "expansion_surface":
		return StarterDetailBuilderScript.FAMILY_RUBBER
	if role == "expanded_wall_display":
		return StarterDetailBuilderScript.FAMILY_DARK_DEVICE_PLASTIC
	return StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE


static func _vector3(entry: Dictionary, field: String, fallback: Vector3) -> Vector3:
	return VisualValueUtilScript.vector3_from_array(entry.get(field, []), fallback)


static func _points(zone: Dictionary) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for raw_point: Variant in zone.get("points", []):
		result.append(VisualValueUtilScript.vector3_from_array(raw_point, Vector3.ZERO))
	return result


static func _node_name(object_id: String) -> String:
	var parts: PackedStringArray = object_id.split("_", false)
	var result := ""
	for part: String in parts:
		result += part.capitalize()
	return result
