extends RefCounted

const MAX_SNAP_DISTANCE_DEFAULT: float = 0.9


static func build_graph(navigation_mesh: NavigationMesh) -> Dictionary:
	var vertices: PackedVector3Array = navigation_mesh.vertices
	var polygons: Array[Dictionary] = []
	for polygon_index: int in range(navigation_mesh.get_polygon_count()):
		var indices: PackedInt32Array = navigation_mesh.get_polygon(polygon_index)
		if indices.size() < 3:
			continue
		var points: Array[Vector2] = []
		for vertex_index: int in indices:
			points.append(Vector2(vertices[vertex_index].x, vertices[vertex_index].z))
		polygons.append({"source_index": polygon_index, "points": points})
	return {"polygons": polygons, "adjacency": _build_adjacency(polygons)}


static func distance_to_graph(route_graph: Dictionary, position: Vector3) -> float:
	var nearest: Dictionary = _nearest_polygon(route_graph.get("polygons", []), position)
	return nearest.get("distance", INF)


static func route_result(
	route_graph: Dictionary,
	start_position: Vector3,
	end_position: Vector3,
	max_snap_distance: float = MAX_SNAP_DISTANCE_DEFAULT
) -> Dictionary:
	var polygons: Array = route_graph.get("polygons", [])
	var start: Dictionary = _nearest_polygon(polygons, start_position)
	var end: Dictionary = _nearest_polygon(polygons, end_position)
	var start_index: int = start.get("index", -1)
	var end_index: int = end.get("index", -1)
	var start_distance: float = start.get("distance", INF)
	var end_distance: float = end.get("distance", INF)
	var reachable := (
		start_index >= 0
		and end_index >= 0
		and start_distance <= max_snap_distance
		and end_distance <= max_snap_distance
		and _has_route(route_graph.get("adjacency", []), start_index, end_index)
	)
	return {
		"reachable": reachable,
		"start_distance": start_distance,
		"end_distance": end_distance,
		"start_polygon": start_index,
		"end_polygon": end_index,
	}


static func _nearest_polygon(polygons: Array, position: Vector3) -> Dictionary:
	var point := Vector2(position.x, position.z)
	var best_distance: float = INF
	var best_index: int = -1
	for index: int in range(polygons.size()):
		var distance: float = _distance_to_polygon(point, polygons[index].get("points", []))
		if distance < best_distance:
			best_distance = distance
			best_index = index
	return {"index": best_index, "distance": best_distance}


static func _distance_to_polygon(point: Vector2, polygon: Array) -> float:
	if polygon.size() < 3:
		return INF
	if _point_in_polygon(point, polygon):
		return 0.0
	var best_distance: float = INF
	for index: int in range(polygon.size()):
		var next_index: int = (index + 1) % polygon.size()
		best_distance = minf(
			best_distance,
			_distance_to_segment(point, polygon[index], polygon[next_index])
		)
	return best_distance


static func _point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var inside := false
	var previous: int = polygon.size() - 1
	for index: int in range(polygon.size()):
		var a: Vector2 = polygon[index]
		var b: Vector2 = polygon[previous]
		var crosses: bool = ((a.y > point.y) != (b.y > point.y))
		if crosses:
			var x_intersection: float = (
				(b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x
			)
			if point.x < x_intersection:
				inside = not inside
		previous = index
	return inside


static func _distance_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_squared: float = segment.length_squared()
	if length_squared <= 0.000001:
		return point.distance_to(start)
	var t: float = clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(start + segment * t)


static func _build_adjacency(polygons: Array[Dictionary]) -> Array:
	var adjacency: Array = []
	var edge_owners: Dictionary = {}
	for index: int in range(polygons.size()):
		adjacency.append([])
		var points: Array = polygons[index].get("points", [])
		for point_index: int in range(points.size()):
			var key: String = _edge_key(
				points[point_index],
				points[(point_index + 1) % points.size()]
			)
			if not edge_owners.has(key):
				edge_owners[key] = []
			edge_owners[key].append(index)
	for key: String in edge_owners.keys():
		var owners: Array = edge_owners[key]
		for left_index: int in range(owners.size()):
			for right_index: int in range(left_index + 1, owners.size()):
				var left: int = owners[left_index]
				var right: int = owners[right_index]
				if not adjacency[left].has(right):
					adjacency[left].append(right)
				if not adjacency[right].has(left):
					adjacency[right].append(left)
	return adjacency


static func _edge_key(a: Vector2, b: Vector2) -> String:
	var first: String = _point_key(a)
	var second: String = _point_key(b)
	var ordered: Array[String] = [first, second]
	ordered.sort()
	return "%s|%s" % [ordered[0], ordered[1]]


static func _point_key(point: Vector2) -> String:
	return "%d:%d" % [roundi(point.x * 1000.0), roundi(point.y * 1000.0)]


static func _has_route(adjacency: Array, start_index: int, end_index: int) -> bool:
	if start_index == end_index:
		return true
	if start_index < 0 or end_index < 0 or start_index >= adjacency.size():
		return false
	var pending: Array[int] = [start_index]
	var seen: Dictionary = {start_index: true}
	while not pending.is_empty():
		var current: int = pending.pop_front()
		for neighbor: int in adjacency[current]:
			if neighbor == end_index:
				return true
			if not seen.has(neighbor):
				seen[neighbor] = true
				pending.append(neighbor)
	return false
