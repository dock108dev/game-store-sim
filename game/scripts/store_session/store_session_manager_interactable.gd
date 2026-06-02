class_name StoreSessionManagerInteractable
extends StoreSessionInteractableBase


func _ready() -> void:
	display_name = "Manager"
	prompt_text = "Talk to"
	action_verb = "Talk"
	interaction_type = InteractionType.CUSTOMER
	interactable_id = &"store_session.manager"
	proximity_radius = 3.4
	proximity_facing_dot = 0.22
	super._ready()


func can_interact(_actor: Node = null) -> bool:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return false
	return controller.can_interact_manager()


func get_disabled_reason(_actor: Node = null) -> String:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return "Manager flow unavailable."
	return controller.manager_disabled_reason()


func interact(by: Node = null) -> void:
	_interact_and_call_controller(by, &"on_store_manager_interacted")
