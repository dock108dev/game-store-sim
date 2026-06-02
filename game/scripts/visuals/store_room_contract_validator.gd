## Validator for room-level sections inside authored physical layout contracts.
class_name StoreRoomContractValidator
extends RefCounted

const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")


## Appends validation messages for room contracts without owning catalog loading.
static func validate_contracts(
	room_contracts: Array[Dictionary], zones: Dictionary, errors: PackedStringArray
) -> void:
	for room: Dictionary in room_contracts:
		var room_id: String = str(room.get("room_id", ""))
		if room_id.is_empty():
			room_id = "<unnamed>"
		var zone_id: String = str(room.get("zone_id", ""))
		if zone_id.is_empty() or not zones.has(zone_id):
			errors.append("missing zone: room %s references unknown zone %s" % [room_id, zone_id])
		_validate_bounds(room_id, room.get("bounds", {}) as Dictionary, errors)
		_validate_doorways(room_id, room.get("doorways", []), errors)
		_validate_walls(room_id, room.get("walls", []), errors)
		_validate_content_zones(room_id, room.get("interior_content_zones", []), errors)
		_validate_content_rules(room_id, room.get("content_rules", []), errors)
		for raw_rule: Variant in room.get("no_overlap_constraints", []):
			if raw_rule is Dictionary:
				_validate_rule_zone_references(
					"room no-overlap", raw_rule as Dictionary, "against_zones", zones, errors
				)


static func _validate_bounds(label: String, bounds: Dictionary, errors: PackedStringArray) -> void:
	if bounds.is_empty():
		errors.append("missing field: room %s missing bounds" % label)
		return
	var min_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		bounds.get("min", []), VisualValueUtilScript.INVALID_VECTOR3
	)
	var max_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		bounds.get("max", []), VisualValueUtilScript.INVALID_VECTOR3
	)
	if (
		min_bound == VisualValueUtilScript.INVALID_VECTOR3
		or max_bound == VisualValueUtilScript.INVALID_VECTOR3
	):
		errors.append("missing field: room %s bounds missing min/max" % label)
	elif max_bound.x <= min_bound.x or max_bound.z <= min_bound.z:
		errors.append("bad bounds: room %s min/max are inverted" % label)


static func _validate_doorways(
	room_id: String, raw_doorways: Variant, errors: PackedStringArray
) -> void:
	var doorways: Array = raw_doorways as Array
	if doorways.is_empty():
		errors.append("missing field: room %s missing doorway" % room_id)
	for raw_doorway: Variant in doorways:
		if raw_doorway is not Dictionary:
			continue
		var doorway: Dictionary = raw_doorway as Dictionary
		var doorway_id: String = str(doorway.get("doorway_id", ""))
		if doorway_id.is_empty():
			errors.append("missing field: room %s doorway missing doorway_id" % room_id)
		if not VisualValueUtilScript.is_vector3_array(doorway.get("position", [])):
			errors.append("missing field: doorway %s missing position" % doorway_id)
		if float(doorway.get("clear_width_m", 0.0)) <= 0.0:
			errors.append("missing field: doorway %s missing clear_width_m" % doorway_id)
		if str(doorway.get("threshold_node", "")).is_empty():
			errors.append("missing field: doorway %s missing threshold_node" % doorway_id)
		if (doorway.get("required_nodes", []) as Array).is_empty():
			errors.append("missing field: doorway %s missing required_nodes" % doorway_id)


static func _validate_walls(room_id: String, raw_walls: Variant, errors: PackedStringArray) -> void:
	var walls: Array = raw_walls as Array
	if walls.is_empty():
		errors.append("missing field: room %s missing walls" % room_id)
	for raw_wall: Variant in walls:
		if raw_wall is not Dictionary:
			continue
		var wall: Dictionary = raw_wall as Dictionary
		var wall_id: String = str(wall.get("wall_id", ""))
		if wall_id.is_empty():
			errors.append("missing field: room %s wall missing wall_id" % room_id)
		if (wall.get("required_nodes", []) as Array).is_empty():
			errors.append("missing field: wall %s missing required_nodes" % wall_id)
		if bool(wall.get("continuous_visual_span_required", false)):
			if float(wall.get("connection_tolerance_m", -1.0)) < 0.0:
				errors.append("missing field: wall %s missing connection_tolerance_m" % wall_id)


static func _validate_content_zones(
	room_id: String, raw_content_zones: Variant, errors: PackedStringArray
) -> void:
	var content_zones: Array = raw_content_zones as Array
	if content_zones.is_empty():
		errors.append("missing field: room %s missing interior_content_zones" % room_id)
	for raw_zone: Variant in content_zones:
		if raw_zone is not Dictionary:
			continue
		var content_zone: Dictionary = raw_zone as Dictionary
		var content_zone_id: String = str(content_zone.get("zone_id", ""))
		if content_zone_id.is_empty():
			errors.append("missing field: room %s content zone missing zone_id" % room_id)
		_validate_bounds(content_zone_id, content_zone.get("bounds", {}) as Dictionary, errors)


static func _validate_content_rules(
	room_id: String, raw_content_rules: Variant, errors: PackedStringArray
) -> void:
	var content_rules: Array = raw_content_rules as Array
	if content_rules.is_empty():
		errors.append("missing field: room %s missing content_rules" % room_id)
	for raw_rule: Variant in content_rules:
		if raw_rule is not Dictionary:
			continue
		var rule: Dictionary = raw_rule as Dictionary
		var family_id: String = str(rule.get("family_id", ""))
		if family_id.is_empty():
			errors.append("missing field: room %s content rule missing family_id" % room_id)
		if (rule.get("required_nodes", []) as Array).is_empty():
			errors.append("missing field: content rule %s missing required_nodes" % family_id)
		if (
			not bool(rule.get("must_be_inside_room_bounds", false))
			and not bool(rule.get("may_be_doorway_or_threshold_prop", false))
		):
			errors.append("missing field: content rule %s missing containment policy" % family_id)


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
