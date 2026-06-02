## Data-level validator for authored store physical layout contracts.
class_name StorePhysicalContractValidator
extends RefCounted

const RoomContractValidatorScript: GDScript = preload(
	"res://game/scripts/visuals/store_room_contract_validator.gd"
)
const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")


## Returns validation messages for a layout's physical contract.
static func validate_layout(
	catalog: RefCounted, layout_id: StringName, active_unlocks: Array[StringName] = []
) -> PackedStringArray:
	var errors: PackedStringArray = []
	var contract: Dictionary = catalog.call("get_physical_contract", layout_id) as Dictionary
	if contract.is_empty():
		errors.append("missing contract: layout %s has no physical_contract" % String(layout_id))
		return errors

	var zones: Dictionary = catalog.call("get_named_zones", layout_id) as Dictionary
	var facing_definitions: Dictionary = (
		catalog.call("get_facing_definitions", layout_id) as Dictionary
	)
	var placement_contracts: Array[Dictionary] = (
		catalog.call("get_placement_contracts", layout_id, active_unlocks) as Array[Dictionary]
	)
	var placements: Array[Dictionary] = (
		catalog.call("get_placements", layout_id, active_unlocks) as Array[Dictionary]
	)
	_validate_placement_contract_coverage(
		catalog, layout_id, active_unlocks, placements, zones, errors
	)
	_validate_contract_entries(placement_contracts, zones, facing_definitions, errors)
	_validate_rule_references(
		catalog.call("get_no_overlap_rules", layout_id) as Array[Dictionary],
		catalog.call("get_clearance_rules", layout_id) as Array[Dictionary],
		placement_contracts,
		zones,
		errors,
	)
	RoomContractValidatorScript.validate_contracts(
		catalog.call("get_room_contracts", layout_id) as Array[Dictionary], zones, errors
	)
	_validate_contract_bounds_and_facing(
		catalog,
		layout_id,
		active_unlocks,
		contract,
		placement_contracts,
		zones,
		facing_definitions,
		errors,
	)
	return errors


static func _validate_placement_contract_coverage(
	catalog: RefCounted,
	layout_id: StringName,
	active_unlocks: Array[StringName],
	placements: Array[Dictionary],
	zones: Dictionary,
	errors: PackedStringArray
) -> void:
	for placement: Dictionary in placements:
		var placement_id: String = _placement_id(placement)
		var zone_id: String = str(placement.get("zone", ""))
		if zone_id.is_empty():
			errors.append("missing field: placement %s missing zone" % placement_id)
		elif not zones.has(zone_id):
			errors.append(
				"missing zone: placement %s references unknown zone %s" % [placement_id, zone_id]
			)
		if not VisualValueUtilScript.is_vector3_array(placement.get("position", []), false):
			errors.append("missing field: placement %s missing position" % placement_id)
		if not VisualValueUtilScript.is_vector3_array(
			placement.get("rotation_degrees", []), false
		):
			errors.append("missing field: placement %s missing rotation_degrees" % placement_id)
		var matches: Array[Dictionary] = (
			catalog.call("get_matching_placement_contracts", layout_id, placement, active_unlocks)
			as Array[Dictionary]
		)
		if matches.is_empty() and not bool(placement.get("physical_contract_exempt", false)):
			errors.append("missing contract: placement %s has no matching placement_contract" % placement_id)


static func _validate_contract_entries(
	placement_contracts: Array[Dictionary],
	zones: Dictionary,
	facing_definitions: Dictionary,
	errors: PackedStringArray
) -> void:
	for entry: Dictionary in placement_contracts:
		var object_id: String = str(entry.get("object_id", ""))
		if object_id.is_empty():
			object_id = "<unnamed>"
		var zone_id: String = str(entry.get("zone_id", ""))
		if zone_id.is_empty() or not zones.has(zone_id):
			errors.append("missing zone: contract %s references unknown zone %s" % [object_id, zone_id])
		if (entry.get("selector", {}) as Dictionary).is_empty():
			errors.append("missing field: contract %s missing selector" % object_id)
		if str(entry.get("physical_role", "")).is_empty():
			errors.append("missing field: contract %s missing physical_role" % object_id)
		if (entry.get("footprint", {}) as Dictionary).is_empty():
			errors.append("missing field: contract %s missing footprint" % object_id)
		_validate_facing_definition(
			"contract %s" % object_id,
			entry.get("facing", {}) as Dictionary,
			facing_definitions,
			errors,
		)
		for raw_point: Variant in entry.get("service_points", []):
			if raw_point is Dictionary:
				var point: Dictionary = raw_point as Dictionary
				_validate_facing_definition(
					"service point %s" % str(point.get("point_id", "")),
					point.get("facing", {}) as Dictionary,
					facing_definitions,
					errors,
				)


static func _validate_rule_references(
	no_overlap_rules: Array[Dictionary],
	clearance_rules: Array[Dictionary],
	placement_contracts: Array[Dictionary],
	zones: Dictionary,
	errors: PackedStringArray
) -> void:
	var roles: Dictionary = _known_physical_roles(placement_contracts, zones)
	var service_points: Dictionary = _known_service_points(placement_contracts)
	for rule: Dictionary in no_overlap_rules:
		_validate_rule_zone_references("no-overlap", rule, "applies_to_zones", zones, errors)
		_validate_rule_zone_references("no-overlap", rule, "against_zones", zones, errors)
		_validate_rule_role_references("no-overlap", rule, "applies_to_roles", roles, errors)
		_validate_rule_role_references("no-overlap", rule, "against_roles", roles, errors)
	for rule: Dictionary in clearance_rules:
		_validate_rule_zone_references("clearance", rule, "applies_to_zones", zones, errors)
		_validate_rule_zone_references("clearance", rule, "against_zones", zones, errors)
		_validate_rule_role_references("clearance", rule, "applies_to_roles", roles, errors)
		_validate_rule_role_references("clearance", rule, "against_roles", roles, errors)
		for raw_point_id: Variant in rule.get("applies_to_service_points", []):
			var point_id: String = str(raw_point_id)
			if not service_points.has(point_id):
				errors.append(
					"clearance: rule %s references unknown service point %s"
					% [str(rule.get("rule_id", "")), point_id]
				)


static func _validate_contract_bounds_and_facing(
	catalog: RefCounted,
	layout_id: StringName,
	active_unlocks: Array[StringName],
	contract: Dictionary,
	placement_contracts: Array[Dictionary],
	zones: Dictionary,
	facing_definitions: Dictionary,
	errors: PackedStringArray
) -> void:
	var store_bounds: Dictionary = contract.get("store_bounds", {}) as Dictionary
	for entry: Dictionary in placement_contracts:
		var matched_placements: Array[Dictionary] = (
			catalog.call("get_placements_matching_contract", layout_id, entry, active_unlocks)
			as Array[Dictionary]
		)
		for subject: Dictionary in _validation_subjects(entry, matched_placements, zones):
			_validate_subject_bounds(subject, entry, zones, store_bounds, errors)
			_validate_subject_facing(
				subject, entry.get("facing", {}) as Dictionary, facing_definitions, errors
			)
		_validate_service_points(
			entry, matched_placements, zones, store_bounds, facing_definitions, errors
		)


static func _validate_service_points(
	entry: Dictionary,
	matched_placements: Array[Dictionary],
	zones: Dictionary,
	store_bounds: Dictionary,
	facing_definitions: Dictionary,
	errors: PackedStringArray
) -> void:
	for anchor: Dictionary in _service_anchors(entry, matched_placements):
		for raw_point: Variant in entry.get("service_points", []):
			if raw_point is not Dictionary:
				continue
			var point: Dictionary = raw_point as Dictionary
			var point_id: String = str(point.get("point_id", ""))
			var offset: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
				point.get("position_offset", []), Vector3.ZERO, false
			)
			var radius: float = float(
				point.get("required_clearance_radius", point.get("radius", 0.0))
			)
			var subject: Dictionary = {
				"id": point_id,
				"position": (anchor.get("position", Vector3.ZERO) as Vector3) + offset,
				"rotation":
				VisualValueUtilScript.vector3_from_exact_array(
					point.get("rotation_degrees", []), VisualValueUtilScript.INVALID_VECTOR3, false
				),
				"size": Vector3(radius * 2.0, 0.05, radius * 2.0),
				"zone_id": str(entry.get("zone_id", "")),
				"check_player_bounds": false,
			}
			_validate_subject_bounds(subject, entry, zones, store_bounds, errors)
			_validate_subject_facing(
				subject, point.get("facing", {}) as Dictionary, facing_definitions, errors
			)


static func _service_anchors(
	entry: Dictionary, matched_placements: Array[Dictionary]
) -> Array[Dictionary]:
	var anchors: Array[Dictionary] = []
	if entry.has("position"):
		anchors.append(
			{
				"position": VisualValueUtilScript.vector3_from_exact_array(
					entry.get("position", []), VisualValueUtilScript.INVALID_VECTOR3, false
				)
			}
		)
	elif str(entry.get("position_source", "")) == "placement.position":
		for placement: Dictionary in matched_placements:
			anchors.append(
				{
					"position": VisualValueUtilScript.vector3_from_exact_array(
						placement.get("position", []), VisualValueUtilScript.INVALID_VECTOR3, false
					)
				}
			)
	return anchors


static func _validation_subjects(
	entry: Dictionary, matched_placements: Array[Dictionary], zones: Dictionary
) -> Array[Dictionary]:
	var subjects: Array[Dictionary] = []
	var size: Vector3 = _footprint_size(entry.get("footprint", {}) as Dictionary)
	var zone_id: String = str(entry.get("zone_id", ""))
	if str(entry.get("position_source", "")) == "zone.points":
		return subjects
	if str(entry.get("position_source", "")) == "placement.position":
		for placement: Dictionary in matched_placements:
			subjects.append(_subject_from_placement(entry, placement, size, zone_id))
		return subjects
	for raw_position: Variant in entry.get("positions", []):
		subjects.append(_subject_from_entry(entry, raw_position, size, zone_id))
	if entry.has("position"):
		subjects.append(_subject_from_entry(entry, entry.get("position", []), size, zone_id))
	elif (entry.get("selector", {}) as Dictionary).has("zone_id"):
		var zone: Dictionary = zones.get(zone_id, {}) as Dictionary
		if zone.has("position"):
			subjects.append(_subject_from_entry(entry, zone.get("position", []), size, zone_id))
	return subjects


static func _subject_from_placement(
	entry: Dictionary, placement: Dictionary, size: Vector3, zone_id: String
) -> Dictionary:
	return {
		"id": _placement_id(placement),
		"position":
		VisualValueUtilScript.vector3_from_exact_array(
			placement.get("position", []), VisualValueUtilScript.INVALID_VECTOR3, false
		),
		"rotation":
		VisualValueUtilScript.vector3_from_exact_array(
			placement.get("rotation_degrees", []), VisualValueUtilScript.INVALID_VECTOR3, false
		),
		"size": size,
		"zone_id": zone_id,
		"check_player_bounds": _checks_player_bounds(entry),
	}


static func _subject_from_entry(
	entry: Dictionary, raw_position: Variant, size: Vector3, zone_id: String
) -> Dictionary:
	return {
		"id": str(entry.get("object_id", "")),
		"position": VisualValueUtilScript.vector3_from_exact_array(
			raw_position, VisualValueUtilScript.INVALID_VECTOR3, false
		),
		"rotation":
		VisualValueUtilScript.vector3_from_exact_array(
			entry.get("rotation_degrees", []), VisualValueUtilScript.INVALID_VECTOR3, false
		),
		"size": size,
		"zone_id": zone_id,
		"check_player_bounds": _checks_player_bounds(entry),
	}


static func _validate_subject_bounds(
	subject: Dictionary,
	entry: Dictionary,
	zones: Dictionary,
	store_bounds: Dictionary,
	errors: PackedStringArray
) -> void:
	var position: Vector3 = (
		subject.get("position", VisualValueUtilScript.INVALID_VECTOR3) as Vector3
	)
	if position == VisualValueUtilScript.INVALID_VECTOR3:
		errors.append("missing field: placement %s missing position" % str(subject.get("id", "")))
		return
	var size: Vector3 = subject.get("size", Vector3.ZERO) as Vector3
	var zone_id: String = str(subject.get("zone_id", ""))
	var zone: Dictionary = zones.get(zone_id, {}) as Dictionary
	if zone.get("shape", "") == "box" and not _footprint_inside_bounds(position, size, zone):
		errors.append(
			"out-of-zone: placement %s footprint outside zone %s"
			% [str(subject.get("id", "")), zone_id]
		)
	if not store_bounds.is_empty() and not _footprint_inside_bounds(position, size, store_bounds):
		errors.append(
			"out-of-store: placement %s footprint outside starter store bounds"
			% str(subject.get("id", ""))
		)
	if bool(subject.get("check_player_bounds", false)):
		if not _footprint_inside_player_bounds(position, size, store_bounds):
			errors.append(
				"out-of-player-bounds: placement %s footprint outside starter player bounds"
				% str(subject.get("id", ""))
			)
	if (entry.get("footprint", {}) as Dictionary).is_empty():
		errors.append("missing field: placement %s missing footprint" % str(subject.get("id", "")))


static func _validate_subject_facing(
	subject: Dictionary,
	facing: Dictionary,
	facing_definitions: Dictionary,
	errors: PackedStringArray
) -> void:
	if facing.is_empty():
		return
	_validate_facing_definition(
		"placement %s" % str(subject.get("id", "")), facing, facing_definitions, errors
	)
	if not subject.has("rotation"):
		return
	var rotation: Vector3 = (
		subject.get("rotation", VisualValueUtilScript.INVALID_VECTOR3) as Vector3
	)
	if rotation == VisualValueUtilScript.INVALID_VECTOR3:
		return
	var expected_yaw: float = float(facing.get("yaw_degrees", 0.0))
	var tolerance: float = float(facing.get("tolerance_degrees", 0.0))
	if VisualValueUtilScript.yaw_delta(rotation.y, expected_yaw) > tolerance:
		errors.append(
			"bad facing: placement %s yaw %.2f outside %.2f of %.2f"
			% [str(subject.get("id", "")), rotation.y, tolerance, expected_yaw]
		)


static func _validate_facing_definition(
	label: String, facing: Dictionary, facing_definitions: Dictionary, errors: PackedStringArray
) -> void:
	if facing.is_empty():
		errors.append("bad facing: %s missing facing" % label)
		return
	var direction: String = str(facing.get("direction", ""))
	if direction.is_empty() or not facing_definitions.has(direction):
		errors.append("bad facing: %s references unknown direction %s" % [label, direction])
		return
	var named: Dictionary = facing_definitions.get(direction, {}) as Dictionary
	var named_yaw: float = float(named.get("yaw_degrees", 0.0))
	var yaw: float = float(facing.get("yaw_degrees", named_yaw))
	var tolerance: float = float(facing.get("tolerance_degrees", 0.0))
	if VisualValueUtilScript.yaw_delta(yaw, named_yaw) > tolerance:
		errors.append("bad facing: %s yaw %.2f does not match direction %s" % [label, yaw, direction])


static func _validate_rule_zone_references(
	prefix: String, rule: Dictionary, field: String, zones: Dictionary, errors: PackedStringArray
) -> void:
	for raw_zone_id: Variant in rule.get(field, []):
		var zone_id: String = str(raw_zone_id)
		if not zones.has(zone_id):
			errors.append(
				"%s: rule %s references unknown zone %s"
				% [prefix, str(rule.get("rule_id", "")), zone_id]
			)


static func _validate_rule_role_references(
	prefix: String, rule: Dictionary, field: String, roles: Dictionary, errors: PackedStringArray
) -> void:
	for raw_role: Variant in rule.get(field, []):
		var role: String = str(raw_role)
		if not roles.has(role):
			errors.append(
				"%s: rule %s references unknown role %s"
				% [prefix, str(rule.get("rule_id", "")), role]
			)


static func _known_physical_roles(
	placement_contracts: Array[Dictionary], zones: Dictionary
) -> Dictionary:
	var roles: Dictionary = {}
	for entry: Dictionary in placement_contracts:
		var role: String = str(entry.get("physical_role", ""))
		if not role.is_empty():
			roles[role] = true
	for raw_zone: Variant in zones.values():
		if raw_zone is Dictionary:
			for raw_role: Variant in (raw_zone as Dictionary).get("allows", []):
				roles[str(raw_role)] = true
	for raw_zone_id: Variant in zones.keys():
		roles[str(raw_zone_id)] = true
	return roles


static func _known_service_points(placement_contracts: Array[Dictionary]) -> Dictionary:
	var service_points: Dictionary = {}
	for entry: Dictionary in placement_contracts:
		for raw_point: Variant in entry.get("service_points", []):
			if raw_point is Dictionary:
				var point_id: String = str((raw_point as Dictionary).get("point_id", ""))
				if not point_id.is_empty():
					service_points[point_id] = true
	return service_points


static func _footprint_size(footprint: Dictionary) -> Vector3:
	var size: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		footprint.get("size", []), Vector3.ZERO, false
	)
	if size == Vector3.ZERO and footprint.has("corridor_width"):
		var width: float = float(footprint.get("corridor_width", 0.0))
		size = Vector3(width, 0.05, width)
	return size


static func _footprint_inside_bounds(
	position: Vector3, size: Vector3, bounds: Dictionary
) -> bool:
	var min_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		bounds.get("min", []), VisualValueUtilScript.INVALID_VECTOR3, false
	)
	var max_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		bounds.get("max", []), VisualValueUtilScript.INVALID_VECTOR3, false
	)
	if (
		min_bound == VisualValueUtilScript.INVALID_VECTOR3
		or max_bound == VisualValueUtilScript.INVALID_VECTOR3
	):
		return true
	var half_size: Vector3 = size * 0.5
	return (
		position.x - half_size.x >= min_bound.x
		and position.x + half_size.x <= max_bound.x
		and position.z - half_size.z >= min_bound.z
		and position.z + half_size.z <= max_bound.z
	)


static func _footprint_inside_player_bounds(
	position: Vector3, size: Vector3, store_bounds: Dictionary
) -> bool:
	var bounds: Dictionary = {
		"min": store_bounds.get("player_bounds_min", []),
		"max": store_bounds.get("player_bounds_max", []),
	}
	return _footprint_inside_bounds(position, size, bounds)


static func _checks_player_bounds(entry: Dictionary) -> bool:
	return bool(
		(entry.get("constraints", {}) as Dictionary).get("must_be_inside_player_bounds", false)
	)


static func _placement_id(placement: Dictionary) -> String:
	for key: String in ["fixture_id", "product_item_id", "name"]:
		var value: String = str(placement.get(key, ""))
		if not value.is_empty():
			return value
	return "<unnamed>"
