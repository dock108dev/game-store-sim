class_name DayEndTriggerInteractable
extends StoreSessionInteractableBase


func _ready() -> void:
	display_name = "close day"
	prompt_text = "Close"
	action_verb = "Close"
	interaction_type = InteractionType.REGISTER
	interactable_id = &"store_session.day_end"
	proximity_radius = 3.25
	proximity_facing_dot = 0.25
	super._ready()


func can_interact(_actor: Node = null) -> bool:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return false
	return controller.can_interact_day_end()


func get_disabled_reason(_actor: Node = null) -> String:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return "Day-end flow unavailable."
	return controller.day_end_disabled_reason()


func interact(by: Node = null) -> void:
	_interact_and_call_controller(by, &"on_store_register_interacted")
