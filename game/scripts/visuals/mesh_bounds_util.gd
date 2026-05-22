## Shared mesh bounds helpers for authored product and fixture visual checks.
class_name MeshBoundsUtil
extends RefCounted


## Returns the merged AABB for all mesh descendants of `target`, measured in
## `root` local space. `target` defaults to `root` for whole-fixture checks.
static func visual_bounds(root: Node3D, target: Node = null) -> AABB:
	if root == null:
		return AABB()
	var search_root: Node = target if target != null else root
	var bounds := AABB()
	var initialized: bool = false
	for mesh_instance: MeshInstance3D in collect_mesh_descendants(search_root):
		var mesh_bounds: AABB = mesh_bounds_in_root(root, mesh_instance)
		if not initialized:
			bounds = mesh_bounds
			initialized = true
		else:
			bounds = bounds.merge(mesh_bounds)
	return bounds


## Returns a mesh instance AABB measured in `root` local space.
static func mesh_bounds_in_root(root: Node3D, mesh_instance: MeshInstance3D) -> AABB:
	if root == null or mesh_instance == null:
		return AABB()
	var mesh: Mesh = mesh_instance.mesh
	if mesh == null:
		return AABB()
	var mesh_aabb: AABB = mesh.get_aabb()
	var transform_to_root: Transform3D = _relative_transform(root, mesh_instance)
	var bounds := AABB()
	var initialized: bool = false
	for x: float in [mesh_aabb.position.x, mesh_aabb.end.x]:
		for y: float in [mesh_aabb.position.y, mesh_aabb.end.y]:
			for z: float in [mesh_aabb.position.z, mesh_aabb.end.z]:
				var point: Vector3 = transform_to_root * Vector3(x, y, z)
				if not initialized:
					bounds = AABB(point, Vector3.ZERO)
					initialized = true
				else:
					bounds = bounds.expand(point)
	return bounds


static func collect_mesh_descendants(root: Node) -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	if root == null:
		return meshes
	if root is MeshInstance3D:
		meshes.append(root as MeshInstance3D)
	for child: Node in root.get_children():
		meshes.append_array(collect_mesh_descendants(child))
	return meshes


static func _relative_transform(root: Node3D, node: Node3D) -> Transform3D:
	var result: Transform3D = node.transform
	var cursor: Node = node.get_parent()
	while cursor is Node3D and cursor != root:
		result = (cursor as Node3D).transform * result
		cursor = cursor.get_parent()
	return result
