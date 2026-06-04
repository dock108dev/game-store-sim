class_name First60QualityGateStep
extends RefCounted

const CAPTURE_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/scenario_screenshot_capture.gd"
)
const CHECKS_SCRIPT: GDScript = preload("res://tests/automation/store_session_tutorial_checks.gd")
const AUDIT_ARTIFACT_SCRIPT: GDScript = preload(
	"res://game/scripts/store_session/first_minute_audit_artifact.gd"
)
const CHECKPOINT_PASS: StringName = &"first60_quality_ready"
const CHECKPOINT_FAIL: StringName = &"first60_quality_failed"
const CHOICE_ID: StringName = &"clean_exchange"
const FIRST_PROMPT_MAX_FRAMES: int = 180

var _owner: Node
var _result: Dictionary
var _step: Dictionary
var _assertions: Dictionary = {"total": 0, "passed": 0, "failed": 0}
var _capture_results: Dictionary = {}
var _review_records: Dictionary = {}
var _failure: String = ""
var _checks: RefCounted
## Runs the first-minute quality route and emits a distinct audit checkpoint.
func execute(
	owner: Node, step_result: Dictionary, step: Dictionary, result: Dictionary, _options: Dictionary
) -> Dictionary:
	_owner = owner
	_step = step
	_result = result
	_assertions = {"total": 0, "passed": 0, "failed": 0}
	_capture_results = {}
	_review_records = {}
	_failure = ""
	_checks = CHECKS_SCRIPT.new()

	var controller: StoreSessionController = _controller()
	if controller == null:
		return _fail_step(step_result, "store-session controller unavailable")
	if not _recent_audit_passed(&"day1_playable_ready"):
		return _fail_step(step_result, "day1_playable_ready must pass before first60 gate")

	if not await _run_route(controller):
		return _fail_step(step_result, _failure)
	var artifact_result: Dictionary = AUDIT_ARTIFACT_SCRIPT.write_artifact(
		str(_result.get("scenario_id", "first60_quality")),
		_capture_results,
		_review_records
	)
	if not bool(artifact_result.get("ok", false)):
		return _fail_step(step_result, str(artifact_result.get("error", "artifact write failed")))

	AuditLog.pass_check(CHECKPOINT_PASS, "route=retro_games_day_one_first_minute")
	step_result["ok"] = true
	step_result["data"] = {
		"assertion_counts": _assertions,
		"captures": _capture_results.size(),
		"artifact": artifact_result,
	}
	return step_result
# gdlint:disable=max-returns
func _run_route(controller: StoreSessionController) -> bool:
	if not await _checkpoint(
		"spawn_start",
		{
			"stage": "training_talk_manager",
			"target": "StoreSessionManager/Interactable",
			"prompt": "Talk to Manager",
			"header": "FIRST DAY",
			"preopening_complete": false,
		},
		FIRST_PROMPT_MAX_FRAMES
	):
		return false
	if not await _wrong_target_does_not_advance(
		controller, "manager_wrong_register", "StoreSessionDayEndTrigger/Interactable"
	):
		return false
	if not await _active_detail_interaction(controller, "StoreSessionManager/Interactable"):
		return false
	if not await _acknowledge_recovery(
		controller,
		"manager_prompt",
		{
			"stage": "training_back_room_inventory",
			"target": "StoreSessionBackroomPickup/Interactable",
			"prompt": "Inspect Starter Stock Box",
			"header": "FIRST DAY",
		}
	):
		return false

	if not await _wrong_target_does_not_advance(
		controller, "backroom_wrong_register", "StoreSessionDayEndTrigger/Interactable"
	):
		return false
	if not await _active_detail_interaction(controller, "StoreSessionBackroomPickup/Interactable"):
		return false
	if not await _acknowledge_recovery(
		controller,
		"backroom_entry_prompt",
		{
			"stage": "training_stock_shelf",
			"target": "StoreSessionRestockShelf/Interactable",
			"prompt": "Place item 1 of 3 on Starter Table",
			"header": "FIRST DAY",
			"carrying": true,
		}
	):
		return false

	if not await _stock_one(
		controller, "carrying_shelf_transition", "Place item 2 of 3 on Starter Table"
	):
		return false
	if not await _stock_one(
		controller, "stockroom_work_area", "Place item 3 of 3 on Starter Table"
	):
		return false
	if not await _stock_one(controller, "open_sign_prompt", "Flip"):
		return false
	if not await _extra_stock_press_does_not_duplicate(controller):
		return false

	if not await _active_detail_interaction(controller, "StoreSessionDayEndTrigger/Interactable"):
		return false
	if not await _acknowledge_recovery(
		controller,
		"before_customer_state",
		{
			"stage": "talk_to_customer",
			"expected_target": "StoreSessionDayOneCustomer/Interactable",
			"prompt": "Talk to customer",
			"header_prefix": "DAY 1",
			"preopening_complete": true,
			"requires_reachable": false,
		}
	):
		return false

	if not await _wrong_target_does_not_advance(
		controller, "customer_wrong_register", "StoreSessionDayEndTrigger/Interactable"
	):
		return false
	if not await _customer_decision():
		return false
	if not await _customer_result(controller):
		return false
	if not await _post_customer_recovery(controller):
		return false
	return await _checkpoint(
		"sixty_second_state",
		{
			"stage": "end_day",
			"target": "StoreSessionDayEndTrigger/Interactable",
			"prompt": "Close day",
			"header_prefix": "DAY 1",
			"preopening_complete": true,
		}
	)
# gdlint:enable=max-returns
func _checkpoint(beat_id: String, expected: Dictionary, timeout_frames: int = 120) -> bool:
	var controller: StoreSessionController = _controller()
	var wait_result: Dictionary = await _checks.wait_for(
		_owner, controller, expected, timeout_frames
	)
	_merge_assertions(wait_result.get("assertion_counts", {}) as Dictionary)
	if not bool(wait_result.get("ok", false)):
		_failure = "%s: %s" % [beat_id, str(wait_result.get("reason", "checkpoint failed"))]
		_record_review(beat_id, "FAIL", _failure)
		return false
	if not _assert_route_quality(beat_id, expected):
		_record_review(beat_id, "FAIL", _failure)
		return false
	if not _capture(beat_id):
		_record_review(beat_id, "FAIL", _failure)
		return false
	_record_review(beat_id, "PASS", "")
	return true
func _active_detail_interaction(controller: StoreSessionController, target_path: String) -> bool:
	var before: Dictionary = controller.get_session_progress_snapshot()
	await _interact_path(target_path)
	await _frames(2)
	if not _assert_modal_state(true, "first-minute detail opened"):
		return false
	await _interact_path(target_path)
	await _frames(1)
	if not _assert_eq(ModalQueue.pending_count(), 0, "repeated detail interact pending count"):
		return false
	return _assert_eq(
		str(controller.get_session_progress_snapshot().get("stage", "")),
		str(before.get("stage", "")),
		"repeated detail interact stage",
	)
func _acknowledge_recovery(
	controller: StoreSessionController, beat_id: String, expected: Dictionary
) -> bool:
	if not controller.acknowledge_prompt_for_automation():
		_failure = "%s: detail acknowledgement unavailable" % beat_id
		return false
	await _frames(2)
	return await _checkpoint(beat_id, expected)
func _stock_one(controller: StoreSessionController, beat_id: String, next_prompt: String) -> bool:
	var before: Dictionary = controller.get_session_progress_snapshot()
	await _interact_path("StoreSessionRestockShelf/Interactable")
	await _frames(2)
	var expected: Dictionary = {
		"target": "StoreSessionRestockShelf/Interactable",
		"prompt": next_prompt,
		"header": "FIRST DAY",
	}
	if next_prompt == "Flip":
		expected["stage"] = "training_open_store"
		expected["target"] = "StoreSessionDayEndTrigger/Interactable"
		expected["carrying"] = false
	else:
		expected["stage"] = "training_stock_shelf"
		expected["carrying"] = true
	if not await _checkpoint(beat_id, expected):
		return false
	var after: Dictionary = controller.get_session_progress_snapshot()
	return _assert_stock_progressed_once(before, after, beat_id)
func _customer_decision() -> bool:
	await _interact_path("StoreSessionDayOneCustomer/Interactable")
	await _frames(2)
	if not await _checkpoint(
		"customer_decision_card",
		{
			"stage": "talk_to_customer",
			"modal_busy": true,
			"event_id": "day01_wrong_console_parent",
		}
	):
		return false
	await _interact_path("StoreSessionDayOneCustomer/Interactable")
	await _frames(1)
	return _assert_eq(ModalQueue.pending_count(), 0, "repeated customer interact pending count")
func _customer_result(controller: StoreSessionController) -> bool:
	var panel: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	if panel == null or not panel.choose_for_automation(CHOICE_ID):
		_failure = "customer decision choice unavailable"
		return false
	await _frames(2)
	return await _checkpoint(
		"result_acknowledgement",
		{"stage": "talk_to_customer", "modal_busy": true, "result_visible": true}
	)
func _post_customer_recovery(controller: StoreSessionController) -> bool:
	if not controller.acknowledge_prompt_for_automation():
		_failure = "customer result acknowledgement unavailable"
		return false
	await _frames(1)
	controller.fast_forward_animations_for_automation()
	await _frames(2)
	return await _checkpoint(
		"post_customer_recovery",
		{
			"stage": "back_room_inventory",
			"customer_exit": "exited_hidden",
			"target": "StoreSessionBackroomPickup/Interactable",
			"prompt": "Inspect Starter Stock Box",
			"header_prefix": "DAY 1",
		}
	)
func _wrong_target_does_not_advance(
	controller: StoreSessionController, label: String, target_path: String
) -> bool:
	var before: Dictionary = controller.get_session_progress_snapshot()
	await _interact_path(target_path)
	await _frames(2)
	var after: Dictionary = controller.get_session_progress_snapshot()
	if not _assert_eq(str(after.get("stage", "")), str(before.get("stage", "")), label):
		return false
	var before_completed: Dictionary = (before.get("objective", {}) as Dictionary).get(
		"completed_objectives", {}
	) as Dictionary
	var after_completed: Dictionary = (after.get("objective", {}) as Dictionary).get(
		"completed_objectives", {}
	) as Dictionary
	return _assert_eq(
		after_completed.size(), before_completed.size(), "%s completed count" % label
	)
func _extra_stock_press_does_not_duplicate(controller: StoreSessionController) -> bool:
	var before: Dictionary = controller.get_session_progress_snapshot()
	await _interact_path("StoreSessionRestockShelf/Interactable")
	await _frames(2)
	var after: Dictionary = controller.get_session_progress_snapshot()
	return (
		_assert_eq(str(after.get("stage", "")), "talk_to_customer", "extra stock stage")
		and _assert_eq(
			int((after.get("carry", {}) as Dictionary).get("shelf_stock_count", 0)),
			int((before.get("carry", {}) as Dictionary).get("shelf_stock_count", 0)),
			"extra stock shelf count",
		)
	)
func _assert_route_quality(beat_id: String, expected: Dictionary) -> bool:
	var snap: Dictionary = _controller().get_session_progress_snapshot()
	var objective: Dictionary = snap.get("objective", {}) as Dictionary
	var prompt: Dictionary = snap.get("visible_prompt", {}) as Dictionary
	var target: Dictionary = snap.get("target", {}) as Dictionary
	var ui: Dictionary = snap.get("ui", {}) as Dictionary
	var expected_target: String = str(expected.get("expected_target", expected.get("target", "")))
	var ok: bool = true
	ok = _assert_false(
		bool(ui.get("tutorial_overlay_visible", true)), "%s tutorial overlay" % beat_id
	) and ok
	ok = _assert_true(bool(ui.get("hud_active", false)), "%s HUD active" % beat_id) and ok
	ok = (
		_assert_true(bool(ui.get("right_panel_visible", false)), "%s checklist visible" % beat_id)
		and ok
	)
	if not bool(expected.get("modal_busy", false)):
		ok = (
			_assert_false(bool(ui.get("modal_busy", false)), "%s blocking modal" % beat_id)
			and ok
		)
		ok = (
			_assert_eq(str(ui.get("input_focus", "")), "store_gameplay", "%s input focus" % beat_id)
			and ok
		)
	if not str(expected.get("prompt", "")).is_empty():
		ok = (
			_assert_eq(
				str(prompt.get("label", "")),
				str(objective.get("prompt_label", "")),
				"%s prompt alignment" % beat_id
			)
			and ok
		)
		ok = (
			_assert_eq(
				str(prompt.get("target_path", "")),
				str(objective.get("target_path", "")),
				"%s target alignment" % beat_id,
			)
			and ok
		)
	if not expected_target.is_empty():
		ok = _assert_eq(str(target.get("path", "")), expected_target, "%s target path" % beat_id) and ok
		ok = _assert_true(bool(target.get("present", false)), "%s target present" % beat_id) and ok
		ok = _assert_true(bool(target.get("enabled", false)), "%s target enabled" % beat_id) and ok
	if not str(expected.get("prompt", "")).is_empty():
		var requires_reachable: bool = bool(expected.get("requires_reachable", true))
		if not requires_reachable:
			return ok and _assert_no_severe_ui_overlap(beat_id)
		ok = (
			_assert_true(
				bool(target.get("reachable_unblocked", false)), "%s target reachable" % beat_id
			)
			and ok
		)
	if not ok:
		return false
	return _assert_no_severe_ui_overlap(beat_id)
func _assert_no_severe_ui_overlap(beat_id: String) -> bool:
	var rects: Dictionary = _visible_ui_rects()
	var keys: Array = rects.keys()
	for i: int in range(keys.size()):
		for j: int in range(i + 1, keys.size()):
			var a: String = str(keys[i])
			var b: String = str(keys[j])
			if ModalQueue.is_busy() and (a == "panel" or b == "panel"):
				continue
			if rects[a].intersects(rects[b]) and _intersection_area(rects[a], rects[b]) > 4.0:
				_failure = "%s: %s overlaps %s" % [beat_id, a, b]
				_assertions["total"] = int(_assertions["total"]) + 1
				_assertions["failed"] = int(_assertions["failed"]) + 1
				return false
	_assertions["total"] = int(_assertions["total"]) + 1
	_assertions["passed"] = int(_assertions["passed"]) + 1
	return true
func _visible_ui_rects() -> Dictionary:
	var out: Dictionary = {}
	_add_rect(out, "prompt", _control_at(InteractionPrompt, "PanelContainer"))
	_add_rect(out, "objective", _control_at(ObjectiveRail, "MarginContainer"))
	_add_rect(out, "checklist", _first_control(StoreSessionHUD.get_right_panel()))
	_add_rect(out, "event_log", _first_control(StoreSessionHUD.get_event_log_panel()))
	_add_rect(out, "carry_label", _find_control("StoreSessionCarryLabel"))
	_add_rect(out, "carry_marker", _objective_target_chip())
	_add_rect(out, "panel", _first_control(ModalQueue.active_panel()))
	return out
func _assert_stock_progressed_once(before: Dictionary, after: Dictionary, label: String) -> bool:
	var before_count: int = int(
		(before.get("carry", {}) as Dictionary).get("shelf_stock_count", 0)
	)
	var after_count: int = int(
		(after.get("carry", {}) as Dictionary).get("shelf_stock_count", 0)
	)
	if str(after.get("stage", "")) == "talk_to_customer":
		return _assert_eq(after_count, 3, "%s final shelf count" % label)
	return _assert_eq(after_count, before_count + 1, "%s shelf count" % label)
func _interact_path(target_path: String) -> void:
	var store: Node = _store_root()
	var node: Node = (
		store.get_node_or_null(NodePath(target_path))
		if store != null
		else null
	)
	if node is Interactable:
		(node as Interactable).interact()
	await _frames(1)
func _capture(beat_id: String) -> bool:
	var capture: Dictionary = CAPTURE_SCRIPT.capture_viewport(
		_owner.get_viewport(),
		{
			"scenario_id": str(_result.get("scenario_id", "first60_quality")),
			"seed": str(_result.get("seed", "")),
			"checkpoint": beat_id,
			"allow_placeholder": bool(_step.get("allow_placeholder", false)),
			"assertion_counts": _assertions.duplicate(true),
		}
	)
	if not bool(capture.get("ok", false)):
		_failure = "%s capture failed: %s" % [beat_id, str(capture.get("error", ""))]
		return false
	(_result.get("captures", {}) as Dictionary)[beat_id] = capture
	_capture_results[beat_id] = {"path": str(capture.get("path", ""))}
	return true
func _record_review(beat_id: String, status: String, notes: String) -> void:
	_review_records[beat_id] = {"status": status, "summary": notes, "notes": notes}
func _assert_modal_state(expected: bool, label: String) -> bool:
	return _assert_eq(ModalQueue.is_busy(), expected, label)
func _assert_true(value: bool, label: String) -> bool:
	return _assert_eq(value, true, label)
func _assert_false(value: bool, label: String) -> bool:
	return _assert_eq(value, false, label)
func _assert_eq(actual: Variant, expected: Variant, label: String) -> bool:
	_assertions["total"] = int(_assertions["total"]) + 1
	if actual == expected:
		_assertions["passed"] = int(_assertions["passed"]) + 1
		return true
	_assertions["failed"] = int(_assertions["failed"]) + 1
	_failure = "%s expected=%s actual=%s" % [label, str(expected), str(actual)]
	return false
func _merge_assertions(counts: Dictionary) -> void:
	for key: String in ["total", "passed", "failed"]:
		_assertions[key] = int(_assertions.get(key, 0)) + int(counts.get(key, 0))
func _add_rect(out: Dictionary, key: String, control: Control) -> void:
	if control == null or not control.visible or not control.is_visible_in_tree():
		return
	var rect: Rect2 = control.get_global_rect()
	if rect.size.x > 1.0 and rect.size.y > 1.0:
		out[key] = rect
func _control_at(root: Node, path: String) -> Control:
	if root == null:
		return null
	return root.get_node_or_null(path) as Control
func _first_control(root: Node) -> Control:
	if root == null:
		return null
	if root is Control:
		return root as Control
	for child: Node in root.find_children("*", "Control", true, false):
		var control: Control = child as Control
		if control != null and control.visible:
			return control
	return null
func _find_control(node_name: String) -> Control:
	var root: Node = _owner.get_tree().root
	return root.find_child(node_name, true, false) as Control if root != null else null
func _objective_target_chip() -> Control:
	var highlight: Node = _controller().get("_objective_target_highlight") as Node
	if highlight != null and highlight.has_method("get_chip"):
		return highlight.call("get_chip") as Control
	return null
func _intersection_area(a: Rect2, b: Rect2) -> float:
	var left: float = maxf(a.position.x, b.position.x)
	var top: float = maxf(a.position.y, b.position.y)
	var right: float = minf(a.position.x + a.size.x, b.position.x + b.size.x)
	var bottom: float = minf(a.position.y + a.size.y, b.position.y + b.size.y)
	return maxf(0.0, right - left) * maxf(0.0, bottom - top)
func _recent_audit_passed(checkpoint: StringName) -> bool:
	for entry: Dictionary in AuditLog.recent(AuditLog.RING_CAPACITY):
		if entry.get("status") == "PASS" and entry.get("checkpoint") == checkpoint:
			return true
	return false
func _controller() -> StoreSessionController:
	var node: Node = _owner.get_tree().get_first_node_in_group("store_session_controller")
	return node as StoreSessionController
func _store_root() -> Node:
	var controller: StoreSessionController = _controller()
	return controller.get_parent() if controller != null else null
func _frames(count: int) -> void:
	for _i: int in range(count):
		await _owner.get_tree().process_frame
func _fail_step(step_result: Dictionary, reason: String) -> Dictionary:
	AuditLog.fail_check(CHECKPOINT_FAIL, reason)
	step_result["ok"] = false
	step_result["reason"] = reason
	step_result["data"] = {"assertion_counts": _assertions}
	return step_result
