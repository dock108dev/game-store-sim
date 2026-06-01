extends RefCounted


static func is_visible_through_ancestors(node: Node, stop_at: Node = null) -> bool:
	var current: Node = node
	while current != null and current != stop_at:
		var node_3d: Node3D = current as Node3D
		if node_3d != null and not node_3d.visible:
			return false
		current = current.get_parent()
	return true


static func flat_distance_nodes(a: Node3D, b: Node3D) -> float:
	return flat_distance_vec(scene_position(a), scene_position(b))


static func flat_distance_vec(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


static func flat_distance_to_segment(point: Vector3, start: Vector3, end: Vector3) -> float:
	var point_2d := Vector2(point.x, point.z)
	var start_2d := Vector2(start.x, start.z)
	var end_2d := Vector2(end.x, end.z)
	var segment := end_2d - start_2d
	var length_squared: float = segment.length_squared()
	if length_squared <= 0.0001:
		return point_2d.distance_to(start_2d)
	var t: float = clampf((point_2d - start_2d).dot(segment) / length_squared, 0.0, 1.0)
	return point_2d.distance_to(start_2d + segment * t)


static func scene_position(node: Node3D) -> Vector3:
	return scene_transform(node).origin


static func scene_transform(node: Node3D) -> Transform3D:
	var current_transform: Transform3D = node.transform
	var cursor: Node = node.get_parent()
	while cursor is Node3D:
		current_transform = (cursor as Node3D).transform * current_transform
		cursor = cursor.get_parent()
	return current_transform
