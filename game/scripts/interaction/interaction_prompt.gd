extends CanvasLayer

@export var message_seconds: float = 2.5

@onready var label: Label = $MarginContainer/PanelContainer/Label

var _message_timer: float = 0.0


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

	label.text = text
	visible = true


func show_message(text: String) -> void:
	_message_timer = message_seconds
	label.text = text
	visible = true


func hide_prompt() -> void:
	_message_timer = 0.0
	visible = false

