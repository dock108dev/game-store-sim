extends Resource
class_name CustomerArchetype

@export var archetype_id: String = ""
@export var display_name: String = ""
@export var role: String = ""
@export var preferred_categories: Array[String] = []
@export_range(0.0, 2.0, 0.05) var price_sensitivity: float = 1.0
@export_range(1.0, 30.0, 0.5) var patience_seconds: float = 8.0
@export var visual_cue: String = ""
@export var dialogue_style: String = ""
@export var default_feedback: String = ""
@export var hidden_thread_contact: bool = false


func is_valid_archetype() -> bool:
	return (
		not archetype_id.strip_edges().is_empty()
		and not display_name.strip_edges().is_empty()
		and not role.strip_edges().is_empty()
		and price_sensitivity > 0.0
		and patience_seconds >= 1.0
	)


func is_hidden_thread_contact() -> bool:
	return hidden_thread_contact


func summary_line() -> String:
	var category_text := "general"
	if not preferred_categories.is_empty():
		category_text = ", ".join(preferred_categories)

	return "%s - %s - %s - patience %0.1fs - price x%0.2f" % [
		display_name,
		role,
		category_text,
		patience_seconds,
		price_sensitivity,
	]
