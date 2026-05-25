## Screenshot capture for the store_session validation harness. F10 saves
## manual captures under user://; beat-named automation captures use artifacts/.
extends CanvasLayer

const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const ScenarioScreenshotCaptureScript: GDScript = preload(
	"res://game/scripts/automation/scenario_screenshot_capture.gd"
)
const SAVE_DIR: String = "user://screenshots"
const AUTOMATION_SCENARIO_ID: String = "store_session"
const TOAST_DURATION: float = 2.5
## Keep scene-derived filenames bounded even if future scenes are renamed.
const _SCENE_SLUG_LENGTH: int = 48

var _toast: Label = null
var _toast_timer: float = 0.0


func _ready() -> void:
	if not _capture_enabled():
		queue_free()
		return
	layer = 95
	process_mode = Node.PROCESS_MODE_ALWAYS

	_toast = Label.new()
	_toast.add_theme_font_size_override("font_size", 14)
	_toast.add_theme_color_override("font_color", Color(0.957, 0.914, 0.831, 1.0))
	_toast.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 1.0))
	_toast.add_theme_constant_override("outline_size", 4)
	_toast.anchor_left = 0.5
	_toast.anchor_right = 0.5
	_toast.anchor_top = 0.0
	_toast.anchor_bottom = 0.0
	_toast.offset_left = -240
	_toast.offset_top = 18
	_toast.offset_right = 240
	_toast.offset_bottom = 56
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.visible = false
	add_child(_toast)


func _input(event: InputEvent) -> void:
	if not _capture_enabled():
		return
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode != KEY_F10:
		return
	_capture()


func _process(delta: float) -> void:
	if not _toast.visible:
		return
	_toast_timer -= delta
	if _toast_timer <= 0.0:
		_toast.visible = false


func _capture_enabled() -> bool:
	return (
		OS.is_debug_build()
		or ProjectSettings.get_setting("debug/store_visual_capture_enabled", false)
	)


## Captures the current viewport and returns saved PNG path details.
func capture_current_viewport(beat_name: String = "", options: Dictionary = {}) -> Dictionary:
	if not options.is_empty():
		return _capture_scenario_checkpoint(beat_name, options)
	var slug: String = _scene_slug()
	var save_dir: String = SAVE_DIR
	if not beat_name.is_empty():
		slug = StoreVisualSweepScript.sanitize_slug(beat_name)
		save_dir = AutomationArtifactsScript.scenario_screenshot_dir(AUTOMATION_SCENARIO_ID)
	var filename: String = "%s_%s.png" % [_timestamp(), slug]
	var result: Dictionary = StoreVisualSweepScript.save_viewport_png(
		get_viewport(), save_dir, filename
	)
	if not bool(result.get("ok", false)):
		_show_toast("Screenshot failed: %s" % str(result.get("error", "unknown error")))
		return result

	var absolute: String = str(result.get("absolute_path", ""))
	_show_toast("Saved: %s" % absolute)
	return result


func _capture_scenario_checkpoint(beat_name: String, options: Dictionary) -> Dictionary:
	var capture_options: Dictionary = options.duplicate(true)
	if not beat_name.is_empty() and str(capture_options.get("checkpoint", "")).is_empty():
		capture_options["checkpoint"] = beat_name
	if str(capture_options.get("scene", "")).is_empty():
		capture_options["scene"] = _scene_slug()
	var result: Dictionary = ScenarioScreenshotCaptureScript.capture_viewport(
		get_viewport(), capture_options
	)
	if not bool(result.get("ok", false)):
		_show_toast("Screenshot failed: %s" % str(result.get("error", "unknown error")))
		return result
	_show_toast("Saved: %s" % str(result.get("absolute_path", "")))
	return result


func _capture() -> void:
	capture_current_viewport()


func _timestamp() -> String:
	var d: Dictionary = Time.get_datetime_dict_from_system()
	return (
		"%04d%02d%02d_%02d%02d%02d"
		% [
			int(d.get("year", 0)),
			int(d.get("month", 0)),
			int(d.get("day", 0)),
			int(d.get("hour", 0)),
			int(d.get("minute", 0)),
			int(d.get("second", 0)),
		]
	)


func _scene_slug() -> String:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return "scene"
	return StoreVisualSweepScript.sanitize_slug(String(scene.name), _SCENE_SLUG_LENGTH)


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.visible = true
	_toast_timer = TOAST_DURATION
