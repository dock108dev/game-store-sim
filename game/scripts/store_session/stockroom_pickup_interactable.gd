class_name StockroomPickupInteractable
extends StoreSessionInteractableBase


func _ready() -> void:
	display_name = "Starter Stock Box"
	prompt_text = "Inspect"
	action_verb = "Inspect"
	interaction_type = InteractionType.BACKROOM
	interactable_id = &"store_session.backroom_pickup"
	proximity_radius = 1.4
	proximity_facing_dot = 0.55
	super._ready()


func can_interact(_actor: Node = null) -> bool:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return false
	return controller.can_interact_pickup()


func get_disabled_reason(_actor: Node = null) -> String:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return "Pickup flow unavailable."
	return controller.pickup_disabled_reason()


func interact(by: Node = null) -> void:
	if not can_interact(by):
		return
	super.interact(by)
	get_tree().call_group("store_session_controller", "on_store_stockroom_pickup_interacted")
