extends "res://scripts/interaction/interactable.gd"
class_name BackroomComputer

@export var store_session_path: NodePath


func get_interaction_prompt() -> String:
	return "E View Backroom Computer"


func get_interaction_prompt_for_actor(_actor: Node) -> String:
	return get_interaction_prompt()


func interact() -> String:
	var session := _get_store_session()
	if session == null:
		return "Backroom computer unavailable."

	return session.get_summary_text()


func interact_with_actor(actor: Node) -> String:
	var session := _get_store_session()
	if session == null:
		return "Backroom computer unavailable."

	if actor != null and actor.has_method("open_day_summary"):
		return str(actor.open_day_summary(session))

	return session.get_summary_text()


func _get_store_session() -> Node:
	if store_session_path.is_empty():
		return null

	return get_node_or_null(store_session_path)
