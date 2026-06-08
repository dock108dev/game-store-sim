extends Resource
class_name CustomerDialogueFlow

@export var flow_id: String = ""
@export var archetype_id: String = ""
@export var trigger: String = ""
@export_multiline var opening_line: String = ""
@export var player_options: Array[String] = []
@export var response_lines: Array[String] = []
@export var consequence_key: String = ""
@export var hidden_thread_probe: bool = false


func is_valid_flow() -> bool:
	return (
		not flow_id.strip_edges().is_empty()
		and not trigger.strip_edges().is_empty()
		and not opening_line.strip_edges().is_empty()
		and not player_options.is_empty()
		and not response_lines.is_empty()
	)


func is_hidden_probe() -> bool:
	return hidden_thread_probe


func preview_line() -> String:
	var option := ""
	if not player_options.is_empty():
		option = player_options[0]

	return "%s -> %s" % [opening_line.strip_edges(), option.strip_edges()]
