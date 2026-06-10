extends CanvasLayer

@export var message_seconds: float = 2.5

@onready var label: Label = $MarginContainer/PanelContainer/Label
@onready var reticle: Label = $CenterReticle

const TONE_ACTION := "action"
const TONE_BLOCKED := "blocked"
const TONE_MESSAGE := "message"
const ACTION_COLOR := Color(0.9, 0.98, 1.0, 1.0)
const BLOCKED_COLOR := Color(1.0, 0.66, 0.58, 1.0)
const MESSAGE_COLOR := Color(1.0, 0.9, 0.62, 1.0)
const ACTION_WORDS := [
	"Pick Up",
	"Ring Up",
	"Complete",
	"Take",
	"View",
	"Talk",
	"Stock",
	"Price",
	"Inspect",
	"Accept",
	"Decline",
	"Order",
	"Commit",
	"Start",
	"End",
	"Place",
]

var _message_timer: float = 0.0
var _prompt_action: String = ""
var _prompt_subject: String = ""
var _prompt_tone: String = TONE_ACTION


func _ready() -> void:
	hide_prompt()


func _process(delta: float) -> void:
	if _message_timer <= 0.0:
		return

	_message_timer -= delta
	if _message_timer <= 0.0:
		hide_prompt()


func show_prompt(text: String) -> void:
	if _message_timer > 0.0:
		return

	_apply_prompt_text(text, TONE_ACTION)
	visible = true
	reticle.visible = true


func show_message(text: String) -> void:
	_message_timer = message_seconds
	_apply_prompt_text(text, TONE_MESSAGE)
	visible = true
	reticle.visible = true


func hide_prompt() -> void:
	_message_timer = 0.0
	_prompt_action = ""
	_prompt_subject = ""
	_prompt_tone = TONE_ACTION
	reticle.visible = false
	visible = false


func get_prompt_action() -> String:
	return _prompt_action


func get_prompt_subject() -> String:
	return _prompt_subject


func get_prompt_tone() -> String:
	return _prompt_tone


func _apply_prompt_text(text: String, fallback_tone: String) -> void:
	var prompt_text := text.strip_edges()
	var parsed := _parse_prompt_text(prompt_text, fallback_tone)
	_prompt_action = str(parsed.get("action", ""))
	_prompt_subject = str(parsed.get("subject", ""))
	_prompt_tone = str(parsed.get("tone", fallback_tone))
	label.text = prompt_text
	label.modulate = _tone_color(_prompt_tone)
	reticle.text = _reticle_text(_prompt_tone)
	reticle.modulate = _tone_color(_prompt_tone)


func _parse_prompt_text(text: String, fallback_tone: String) -> Dictionary:
	if text.begins_with("Click "):
		var click_subject := text.substr(6).strip_edges()
		for action_word in ACTION_WORDS:
			if click_subject == action_word:
				return {
					"action": action_word,
					"subject": "",
					"tone": TONE_ACTION,
				}
			if click_subject.begins_with("%s " % action_word):
				return {
					"action": action_word,
					"subject": click_subject.substr(str(action_word).length() + 1).strip_edges(),
					"tone": TONE_ACTION,
				}
		return {
			"action": "Click",
			"subject": click_subject,
			"tone": TONE_ACTION,
		}

	if _is_blocked_prompt(text):
		return {
			"action": "Blocked",
			"subject": text,
			"tone": TONE_BLOCKED,
		}

	return {
		"action": "Status",
		"subject": text,
		"tone": fallback_tone,
	}


func _is_blocked_prompt(text: String) -> bool:
	var normalized := text.to_lower()
	return normalized.contains("cannot") \
		or normalized.contains("unavailable") \
		or normalized.begins_with("fixed price") \
		or normalized.begins_with("hold an item") \
		or normalized.begins_with("could not")


func _tone_color(tone: String) -> Color:
	match tone:
		TONE_BLOCKED:
			return BLOCKED_COLOR
		TONE_MESSAGE:
			return MESSAGE_COLOR
		_:
			return ACTION_COLOR


func _reticle_text(tone: String) -> String:
	if tone == TONE_BLOCKED or tone == TONE_MESSAGE:
		return "!"

	return "+"
