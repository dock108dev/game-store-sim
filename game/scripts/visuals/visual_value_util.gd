extends RefCounted


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


static func vector2i_from_array(raw: Variant, fallback: Vector2i) -> Vector2i:
	if raw is not Array:
		return fallback
	var values: Array = raw as Array
	if values.size() < 2:
		return fallback
	return Vector2i(int(values[0]), int(values[1]))
