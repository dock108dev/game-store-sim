extends Node3D
class_name VisualModuleManifest

@export var module_id := ""
@export_multiline var responsibility := ""
@export var owned_node_names: PackedStringArray = PackedStringArray()
@export var visual_node_names: PackedStringArray = PackedStringArray()
@export var collision_node_names: PackedStringArray = PackedStringArray()
@export var anchor_node_names: PackedStringArray = PackedStringArray()
@export var material_resource_paths: PackedStringArray = PackedStringArray()


func missing_owned_node_names(world_root: Node) -> PackedStringArray:
	return _missing_named_nodes(world_root, owned_node_names)


func missing_visual_node_names(world_root: Node) -> PackedStringArray:
	return _missing_named_nodes(world_root, visual_node_names)


func missing_collision_node_names(world_root: Node) -> PackedStringArray:
	return _missing_named_nodes(world_root, collision_node_names)


func missing_anchor_node_names(world_root: Node) -> PackedStringArray:
	return _missing_named_nodes(world_root, anchor_node_names)


func missing_material_resource_paths() -> PackedStringArray:
	var missing := PackedStringArray()
	for resource_path in material_resource_paths:
		if not ResourceLoader.exists(resource_path):
			missing.append(resource_path)
	return missing


func resolved_owned_nodes(world_root: Node) -> Array[Node]:
	return _resolved_named_nodes(world_root, owned_node_names)


func resolved_visual_nodes(world_root: Node) -> Array[Node]:
	return _resolved_named_nodes(world_root, visual_node_names)


func has_module_contract() -> bool:
	return not module_id.is_empty() and not responsibility.is_empty() and not owned_node_names.is_empty()


func has_visual_contract() -> bool:
	return has_module_contract() and not visual_node_names.is_empty() and not material_resource_paths.is_empty()


func _missing_named_nodes(world_root: Node, node_names: PackedStringArray) -> PackedStringArray:
	var missing := PackedStringArray()
	for node_name in node_names:
		if world_root.find_child(node_name, true, false) == null:
			missing.append(node_name)
	return missing


func _resolved_named_nodes(world_root: Node, node_names: PackedStringArray) -> Array[Node]:
	var nodes: Array[Node] = []
	for node_name in node_names:
		var node := world_root.find_child(node_name, true, false)
		if node != null:
			nodes.append(node)
	return nodes
