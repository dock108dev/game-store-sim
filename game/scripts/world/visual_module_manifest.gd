extends Node3D
class_name VisualModuleManifest

@export var module_id := ""
@export_multiline var responsibility := ""
@export var owned_node_names: PackedStringArray = PackedStringArray()


func missing_owned_node_names(world_root: Node) -> PackedStringArray:
	var missing := PackedStringArray()
	for node_name in owned_node_names:
		if world_root.find_child(node_name, true, false) == null:
			missing.append(node_name)
	return missing


func resolved_owned_nodes(world_root: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for node_name in owned_node_names:
		var node := world_root.find_child(node_name, true, false)
		if node != null:
			nodes.append(node)
	return nodes
