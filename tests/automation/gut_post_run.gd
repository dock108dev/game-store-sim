## Post-run hook executed after GUT records results and before SceneTree quit.
## Releases root-owned runtime nodes so headless teardown reflects test status.
extends GutHookScript


func run() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var protected_nodes: Dictionary = _protected_runner_nodes()
	var children: Array[Node] = tree.root.get_children()
	for index: int in range(children.size() - 1, -1, -1):
		var child: Node = children[index]
		if protected_nodes.has(child):
			continue
		child.free()


func _protected_runner_nodes() -> Dictionary:
	var protected_nodes: Dictionary = {}
	var node: Node = gut as Node
	while node != null:
		protected_nodes[node] = true
		node = node.get_parent()
	return protected_nodes
