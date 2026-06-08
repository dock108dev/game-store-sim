extends Label3D
class_name CustomerFeedbackBubble

const TONE_INFO := "info"
const TONE_POSITIVE := "positive"
const TONE_WARNING := "warning"
const TONE_SUSPICIOUS := "suspicious"

@export var max_characters: int = 28

var tone: String = TONE_INFO


func _ready() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	visible = false
	text = ""


func show_feedback(message: String, feedback_tone: String = TONE_INFO) -> void:
	var normalized_message := message.strip_edges()
	if normalized_message.length() > max_characters:
		normalized_message = normalized_message.left(max_characters - 1) + "."

	text = normalized_message
	tone = feedback_tone
	visible = not text.is_empty()
	modulate = _color_for_tone(tone)


func clear_feedback() -> void:
	text = ""
	visible = false
	tone = TONE_INFO


func get_feedback_summary() -> Dictionary:
	return {
		"text": text,
		"tone": tone,
		"visible": visible,
	}


func _color_for_tone(feedback_tone: String) -> Color:
	match feedback_tone:
		TONE_POSITIVE:
			return Color(0.65, 0.95, 0.7, 1.0)
		TONE_WARNING:
			return Color(1.0, 0.78, 0.38, 1.0)
		TONE_SUSPICIOUS:
			return Color(0.72, 0.62, 0.95, 1.0)
	return Color(0.92, 0.9, 0.78, 1.0)
