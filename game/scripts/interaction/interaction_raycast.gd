extends RayCast3D

@export var prompt_path: NodePath

var _current_interactable: Node = null
var _prompt: Node = null


func _ready() -> void:
	_prompt = get_node_or_null(prompt_path)


func _physics_process(_delta: float) -> void:
	force_raycast_update()

	var collider := get_collider()
	if collider != null and collider.has_method("get_interaction_prompt"):
		_current_interactable = collider
		if _prompt != null and _prompt.has_method("show_prompt"):
			_prompt.show_prompt(_get_prompt_text(collider))
		return

	_current_interactable = null
	if _prompt != null and _prompt.has_method("hide_prompt"):
		_prompt.hide_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if _current_interactable == null:
		return

	if not event.is_action_pressed("interact"):
		return

	var result := ""
	if _current_interactable.has_method("interact_with_actor"):
		result = str(_current_interactable.interact_with_actor(_get_actor()))
	elif _current_interactable.has_method("interact"):
		result = str(_current_interactable.interact())

	if _prompt != null and _prompt.has_method("show_message"):
		_prompt.show_message(result)


func _get_prompt_text(interactable: Node) -> String:
	if interactable.has_method("get_interaction_prompt_for_actor"):
		return str(interactable.get_interaction_prompt_for_actor(_get_actor()))

	return str(interactable.get_interaction_prompt())


func _get_actor() -> Node:
	var node: Node = self
	while node != null:
		if node.has_method("is_holding_item"):
			return node
		node = node.get_parent()

	return null
