extends StaticBody3D

@export var display_name: String = "Interactable"
@export_multiline var inspect_text: String = "Nothing interesting yet."


func get_interaction_prompt() -> String:
	return "Click Inspect %s" % display_name


func interact() -> String:
	return inspect_text
