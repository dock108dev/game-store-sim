class_name StoreSessionInteractableBase
extends Interactable


## Shared lookup for store_session Day-1 interactables. Test fixtures may omit the
## controller group, so callers treat null as "flow unavailable".
func _controller() -> StoreSessionController:
	if not is_inside_tree():
		return null
	var tree: SceneTree = get_tree()
	if tree == null:
		return null
	var node: Node = tree.get_first_node_in_group("store_session_controller")
	if node is StoreSessionController:
		return node as StoreSessionController
	return null


func _interact_and_call_controller(by: Node, method_name: StringName) -> void:
	if not can_interact(by):
		return
	super.interact(by)
	get_tree().call_group("store_session_controller", String(method_name))
