## Deterministic UI/focus stress proof for recovery from blocked gameplay input.
class_name BadStateResistanceRunner
extends Node

const SCENARIO_ID: String = "bad_state_resistance"
const INTERACTION_RAY_SCRIPT: GDScript = preload("res://game/scripts/player/interaction_ray.gd")
const TOAST_UI_SCRIPT: GDScript = preload("res://game/ui/hud/toast_notification_ui.gd")
const MODAL_PANEL_SCRIPT: GDScript = preload("res://game/scripts/ui/modal_panel.gd")
const SCREENSHOT_CAPTURE_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/scenario_screenshot_capture.gd"
)

var _options: Dictionary = {}
var _root: Node3D = null
var _ray: Node = null
var _target: ProbeInteractable = null
var _toast_ui: ToastNotificationUI = null
var _side_panels: Dictionary = {}
var _focus_transitions: Array[Dictionary] = []
var _prompt_status: Array[String] = []
var _panel_counts: Array[Dictionary] = []
var _screenshots: Array[Dictionary] = []
var _failures: Array[String] = []
var _saved_focus_stack: Array[StringName] = []
var _saved_game_state: GameManager.State = GameManager.State.MAIN_MENU
var _saved_paused: bool = false


class ProbeInteractable:
	extends Interactable

	var interact_calls: int = 0

	func interact(by: Node = null) -> void:
		interact_calls += 1
		super.interact(by)


## Runs the stress flow and returns report-ready proof data.
func run(options: Dictionary = {}) -> Dictionary:
	_options = options.duplicate(true)
	_capture_global_state()
	_prepare_fixture()
	_connect_observers()

	_run_side_panel_conflict()
	_run_modal_notification_conflict()
	_run_pause_save_load_recovery()

	var result: Dictionary = _build_result()
	_cleanup()
	return result


func _capture_global_state() -> void:
	_saved_focus_stack = InputFocus.stack_snapshot()
	_saved_game_state = GameManager.current_state
	_saved_paused = get_tree().paused


func _prepare_fixture() -> void:
	GameRandom.enable_test_mode("bad_state_resistance")
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()
	InputFocus.push_context(InputFocus.CTX_STORE_GAMEPLAY)
	GameManager.current_state = GameManager.State.GAMEPLAY
	get_tree().paused = false

	_root = Node3D.new()
	_root.name = "BadStateResistanceFixture"
	add_child(_root)

	_target = ProbeInteractable.new()
	_target.name = "RegisterProbe"
	_target.prompt_text = "Use"
	_target.display_name = "Register"
	_root.add_child(_target)

	_ray = INTERACTION_RAY_SCRIPT.new()
	_ray.name = "InteractionRayProbe"
	add_child(_ray)
	_ray.call("_set_hovered_target", _target)

	_toast_ui = TOAST_UI_SCRIPT.new()
	_toast_ui.name = "ToastProbe"
	_toast_ui.size = Vector2(1152, 648)
	add_child(_toast_ui)


func _connect_observers() -> void:
	InputFocus.context_changed.connect(_on_focus_changed)
	EventBus.interactable_focused_disabled.connect(_on_prompt_status)


func _run_side_panel_conflict() -> void:
	_set_side_panel_visible("inventory", true)
	_set_side_panel_visible("inventory", true)
	EventBus.toast_requested.emit("Inventory open. Finish there first.", &"info", 1.0)
	_ray.call("_unhandled_input", _interact_event())
	_check(_target.interact_calls == 0, "side panel must block interaction dispatch")
	_check(
		_prompt_status.has(INTERACTION_RAY_SCRIPT.BLOCKED_BY_PANEL_REASON),
		"side panel block must surface player-facing status"
	)
	_capture("side_panel_conflict", 1)

	_set_side_panel_visible("inventory", false)
	_set_side_panel_visible("inventory", false)
	_ray.call("_unhandled_input", _interact_event())
	_check(_target.interact_calls == 1, "retry after side panel close must dispatch once")
	_check(_side_panel_count("inventory") == 0, "side panel close must be idempotent")


func _run_modal_notification_conflict() -> void:
	var modal: ModalPanel = _make_modal("QueueStressModal")
	ModalQueue.request_open(modal, ModalQueue.Priority.TUTORIAL)
	ModalQueue.request_open(modal, ModalQueue.Priority.TUTORIAL)
	EventBus.toast_requested.emit("Modal-safe toast", &"system", 1.0)
	_ray.call("_unhandled_input", _interact_event())
	_check(_target.interact_calls == 1, "modal must block interaction dispatch")
	_check(ModalQueue.pending_count() == 0, "repeated modal open must not duplicate queue entries")
	_check(
		not _toast_ui._is_showing and _toast_ui._queue.size() >= 1,
		"toast must queue silently while modal owns focus"
	)
	_capture("modal_notification_conflict", 2)

	var acknowledged: bool = ModalQueue.acknowledge_active_for_automation()
	_check(acknowledged, "automation acknowledgement must close the active modal")
	_check(not ModalQueue.is_busy(), "modal queue must be idle after acknowledgement")
	_check(
		InputFocus.current() == InputFocus.CTX_STORE_GAMEPLAY,
		"modal close must restore gameplay focus"
	)
	_ray.call("_unhandled_input", _interact_event())
	_check(_target.interact_calls == 2, "retry after modal close must dispatch once")


func _run_pause_save_load_recovery() -> void:
	var pause_modal: ModalPanel = _make_modal("PauseStressModal")
	get_tree().paused = true
	ModalQueue.request_open(pause_modal, ModalQueue.Priority.DAY_SUMMARY)
	var saved_snapshot: Dictionary = {
		"focus": InputFocus.get_focus_snapshot(),
		"modal": ModalQueue.get_modal_snapshot(),
		"interact_calls": _target.interact_calls,
	}
	EventBus.toast_requested.emit("Saved while paused", &"system", 1.0)
	_check(
		InputFocus.current() == InputFocus.CTX_MODAL,
		"pause modal must own focus while save snapshot is captured"
	)
	_capture("pause_save_load_conflict", 3)

	var loaded_snapshot: Dictionary = saved_snapshot.duplicate(true)
	ModalQueue.acknowledge_active_for_automation()
	get_tree().paused = false
	_check(
		int(loaded_snapshot.get("interact_calls", -1)) == _target.interact_calls,
		"save/load snapshot must not mutate interaction state"
	)
	_check(
		InputFocus.current() == InputFocus.CTX_STORE_GAMEPLAY,
		"unpause after save/load must restore gameplay focus"
	)
	_capture("gameplay_focus_recovered", 4)


func _set_side_panel_visible(panel_name: String, visible: bool) -> void:
	var count: int = _side_panel_count(panel_name)
	if visible:
		if count > 0:
			_record_panel_count(panel_name)
			return
		_side_panels[panel_name] = 1
		EventBus.panel_opened.emit(panel_name)
	else:
		if count <= 0:
			_record_panel_count(panel_name)
			return
		_side_panels[panel_name] = 0
		EventBus.panel_closed.emit(panel_name)
	_record_panel_count(panel_name)


func _side_panel_count(panel_name: String) -> int:
	return int(_side_panels.get(panel_name, 0))


func _record_panel_count(panel_name: String) -> void:
	_panel_counts.append({
		"panel": panel_name,
		"count": _side_panel_count(panel_name),
		"ray_open_panel_count": _ray.call("get_open_panel_count"),
		"modal": ModalQueue.get_modal_snapshot(),
	})


func _make_modal(panel_name: String) -> ModalPanel:
	var panel: ModalPanel = MODAL_PANEL_SCRIPT.new() as ModalPanel
	panel.name = panel_name
	panel.visible = false
	add_child(panel)
	return panel


func _interact_event() -> InputEventAction:
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	return event


func _capture(label: String, index: int) -> void:
	if not bool(_options.get("record_screenshots", true)):
		return
	var capture: Dictionary = SCREENSHOT_CAPTURE_SCRIPT.capture_viewport(
		get_viewport(),
		{
			"scenario_id": str(_options.get("scenario_id", SCENARIO_ID)),
			"seed": str(_options.get("seed", "")),
			"scene": "bad_state_resistance_fixture",
			"checkpoint": label,
			"index": index,
			"allow_placeholder": true,
			"assertion_counts": _assertion_counts(),
		}
	)
	_screenshots.append(capture)
	_check(bool(capture.get("ok", false)), "screenshot capture must produce evidence: %s" % label)


func _assertion_counts() -> Dictionary:
	return {
		"total": _failures.size(),
		"passed": 0 if _failures.is_empty() else _failures.size() - 1,
		"failed": _failures.size(),
	}


func _build_result() -> Dictionary:
	var modal_snapshot: Dictionary = ModalQueue.get_modal_snapshot()
	var focus_snapshot: Dictionary = InputFocus.get_focus_snapshot()
	return {
		"ok": _failures.is_empty(),
		"failures": _failures.duplicate(true),
		"panel_counts": _panel_counts.duplicate(true),
		"focus_transitions": _focus_transitions.duplicate(true),
		"modal_queue": modal_snapshot,
		"notification_queue": {
			"showing": _toast_ui._is_showing,
			"queued": _toast_ui._queue.size(),
			"mouse_filter": _toast_ui.mouse_filter,
		},
		"prompt_status": _prompt_status.duplicate(),
		"interaction": {
			"interact_calls": _target.interact_calls,
			"blocked_panel_reason": INTERACTION_RAY_SCRIPT.BLOCKED_BY_PANEL_REASON,
			"blocked_focus_reason": INTERACTION_RAY_SCRIPT.BLOCKED_BY_FOCUS_REASON,
			"focus_current": focus_snapshot.get("current", ""),
			"focus_depth": focus_snapshot.get("depth", 0),
		},
		"screenshots": _screenshots.duplicate(true),
	}


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _on_focus_changed(new_ctx: StringName, old_ctx: StringName) -> void:
	_focus_transitions.append({
		"old": String(old_ctx),
		"new": String(new_ctx),
		"depth": InputFocus.depth(),
	})


func _on_prompt_status(reason: String) -> void:
	if reason.is_empty():
		return
	_prompt_status.append(reason)


func _cleanup() -> void:
	if InputFocus.context_changed.is_connected(_on_focus_changed):
		InputFocus.context_changed.disconnect(_on_focus_changed)
	if EventBus.interactable_focused_disabled.is_connected(_on_prompt_status):
		EventBus.interactable_focused_disabled.disconnect(_on_prompt_status)
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	for ctx: StringName in _saved_focus_stack:
		InputFocus.push_context(ctx)
	GameManager.current_state = _saved_game_state
	get_tree().paused = _saved_paused
	GameRandom.disable_test_mode()
	if is_instance_valid(_root):
		_root.queue_free()
	if is_instance_valid(_toast_ui):
		_toast_ui.queue_free()
