extends RefCounted

const INVALID_VECTOR3: Vector3 = Vector3(1.0e20, 1.0e20, 1.0e20)


static func dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value as Dictionary
	return {}


static func vector3_from_array(raw: Variant, fallback: Vector3) -> Vector3:
	if raw is not Array:
		return fallback
	var values: Array = raw as Array
	if values.size() < 3:
		return fallback
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


static func is_vector3_array(raw: Variant, require_numeric: bool = true) -> bool:
	if raw is not Array:
		return false
	var values: Array = raw as Array
	if values.size() != 3:
		return false
	if not require_numeric:
		return true
	for item: Variant in values:
		if typeof(item) != TYPE_INT and typeof(item) != TYPE_FLOAT:
			return false
	return true


static func vector3_from_exact_array(
	raw: Variant, fallback: Vector3, require_numeric: bool = true
) -> Vector3:
	if not is_vector3_array(raw, require_numeric):
		return fallback
	var values: Array = raw as Array
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


static func vector2i_from_array(raw: Variant, fallback: Vector2i) -> Vector2i:
	if raw is not Array:
		return fallback
	var values: Array = raw as Array
	if values.size() < 2:
		return fallback
	return Vector2i(int(values[0]), int(values[1]))


static func yaw_delta(a: float, b: float) -> float:
	var delta: float = fposmod(a - b + 180.0, 360.0) - 180.0
	return abs(delta)
