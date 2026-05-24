class_name StoreSessionInteractableBase
extends Interactable


## Shared lookup for store_session Day-1 interactables. Test fixtures may omit the
## controller group, so callers treat null as "flow unavailable".
func _controller() -> StoreSessionController:
	var tree: SceneTree = get_tree()
	if tree == null:
		return null
	var node: Node = tree.get_first_node_in_group("store_session_controller")
	if node is StoreSessionController:
		return node as StoreSessionController
	return null
