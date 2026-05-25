class_name StoreSessionTutorialChecks
extends RefCounted

var _assertions: Dictionary = {"total": 0, "passed": 0, "failed": 0}
var _failure: String = ""


func wait_for(
	owner: Node, controller: StoreSessionController, expected: Dictionary, timeout_frames: int
) -> Dictionary:
	_failure = ""
	for _i: int in range(timeout_frames):
		var snap: Dictionary = controller.get_session_progress_snapshot()
		if _snapshot_matches_raw(owner, controller, snap, expected):
			_assert_snapshot(owner, controller, snap, expected)
			return {"ok": true, "assertion_counts": _assertions.duplicate(true)}
		await owner.get_tree().process_frame
	var current: Dictionary = controller.get_session_progress_snapshot()
	return {
		"ok": false,
		"reason": _failure_context(current, expected),
		"assertion_counts": _assertions.duplicate(true),
	}


func _snapshot_matches_raw(
	owner: Node, controller: StoreSessionController, snap: Dictionary, expected: Dictionary
) -> bool:
	var ui: Dictionary = snap.get("ui", {}) as Dictionary
	var target: Dictionary = snap.get("target", {}) as Dictionary
	var customer: Dictionary = snap.get("customer", {}) as Dictionary
	var visible_prompt: Dictionary = snap.get("visible_prompt", {}) as Dictionary
	if expected.has("stage") and str(snap.get("stage", "")) != str(expected["stage"]):
		return false
	if expected.has("day") and int(snap.get("day", 0)) != int(expected["day"]):
		return false
	if expected.has("target") and str(target.get("path", "")) != str(expected["target"]):
		return false
	if expected.has("target") and not bool(target.get("reachable_unblocked", false)):
		return false
	if expected.has("prompt") and str(visible_prompt.get("label", "")) != str(expected["prompt"]):
		return false
	if expected.has("header") and str(ui.get("right_panel_header", "")) != str(expected["header"]):
		return false
	if (
		expected.has("header_prefix")
		and not str(ui.get("right_panel_header", "")).begins_with(str(expected["header_prefix"]))
	):
		return false
	if expected.has("register") and _register_text(owner) != str(expected["register"]):
		return false
	if (
		expected.has("close_reason")
		and str(snap.get("close_day_reason", "")) != str(expected["close_reason"])
	):
		return false
	if (
		expected.has("can_close")
		and bool(snap.get("can_close_day", false)) != bool(expected["can_close"])
	):
		return false
	if expected.has("carrying"):
		var carrying: bool = bool(
			(snap.get("carry", {}) as Dictionary).get("carrying_stock", false)
		)
		if carrying != bool(expected["carrying"]):
			return false
	if (
		expected.has("modal_busy")
		and bool(ui.get("modal_busy", false)) != bool(expected["modal_busy"])
	):
		return false
	if expected.has("event_id") and str(customer.get("event_id", "")) != str(expected["event_id"]):
		return false
	if (
		expected.has("result_visible")
		and bool(customer.get("result_visible", false)) != bool(expected["result_visible"])
	):
		return false
	if (
		expected.has("customer_exit")
		and str(customer.get("exit_state", "")) != str(expected["customer_exit"])
	):
		return false
	if (
		expected.has("preopening_complete")
		and StoreSessionState.preopening_complete != bool(expected["preopening_complete"])
	):
		return false
	if expected.has("summary_visible") and not _summary_visible(controller):
		return false
	if not bool(ui.get("hud_active", false)) or bool(ui.get("tutorial_overlay_visible", true)):
		return false
	if not bool(expected.get("modal_busy", false)) and String(InputFocus.current()) == "modal":
		return false
	return true


func _assert_snapshot(
	owner: Node, controller: StoreSessionController, snap: Dictionary, expected: Dictionary
) -> bool:
	var ui: Dictionary = snap.get("ui", {}) as Dictionary
	var target: Dictionary = snap.get("target", {}) as Dictionary
	var customer: Dictionary = snap.get("customer", {}) as Dictionary
	var visible_prompt: Dictionary = snap.get("visible_prompt", {}) as Dictionary
	if (
		expected.has("stage")
		and not _assert_eq(str(snap.get("stage", "")), str(expected["stage"]), "stage")
	):
		return false
	if expected.has("day") and not _assert_eq(int(snap.get("day", 0)), int(expected["day"]), "day"):
		return false
	if expected.has("target"):
		if not _assert_eq(str(target.get("path", "")), str(expected["target"]), "target path"):
			return false
		if not _assert_true(bool(target.get("present", false)), "target present"):
			return false
		if not _assert_true(bool(target.get("reachable_unblocked", false)), "target reachable"):
			return false
	if (
		expected.has("prompt")
		and not _assert_eq(str(visible_prompt.get("label", "")), str(expected["prompt"]), "prompt")
	):
		return false
	if (
		expected.has("header")
		and not _assert_eq(str(ui.get("right_panel_header", "")), str(expected["header"]), "header")
	):
		return false
	if expected.has("header_prefix"):
		if not _assert_true(
			str(ui.get("right_panel_header", "")).begins_with(str(expected["header_prefix"])),
			"header prefix"
		):
			return false
	if (
		expected.has("register")
		and not _assert_eq(_register_text(owner), str(expected["register"]), "register")
	):
		return false
	if (
		expected.has("close_reason")
		and not _assert_eq(
			str(snap.get("close_day_reason", "")), str(expected["close_reason"]), "close reason"
		)
	):
		return false
	if (
		expected.has("can_close")
		and not _assert_eq(
			bool(snap.get("can_close_day", false)),
			bool(expected["can_close"]),
			"close availability"
		)
	):
		return false
	if expected.has("carrying"):
		var carrying: bool = bool(
			(snap.get("carry", {}) as Dictionary).get("carrying_stock", false)
		)
		if not _assert_eq(carrying, bool(expected["carrying"]), "carrying stock"):
			return false
	if (
		expected.has("modal_busy")
		and not _assert_eq(
			bool(ui.get("modal_busy", false)), bool(expected["modal_busy"]), "modal busy"
		)
	):
		return false
	if (
		expected.has("event_id")
		and not _assert_eq(str(customer.get("event_id", "")), str(expected["event_id"]), "event id")
	):
		return false
	if (
		expected.has("result_visible")
		and not _assert_eq(
			bool(customer.get("result_visible", false)),
			bool(expected["result_visible"]),
			"result visible"
		)
	):
		return false
	if (
		expected.has("customer_exit")
		and not _assert_eq(
			str(customer.get("exit_state", "")), str(expected["customer_exit"]), "customer exit"
		)
	):
		return false
	if (
		expected.has("preopening_complete")
		and not _assert_eq(
			StoreSessionState.preopening_complete,
			bool(expected["preopening_complete"]),
			"preopening complete"
		)
	):
		return false
	if (
		expected.has("summary_visible")
		and not _assert_true(_summary_visible(controller), "summary visible")
	):
		return false
	return _assert_negative_surfaces(ui, bool(expected.get("modal_busy", false)))


func _assert_negative_surfaces(ui: Dictionary, modal_expected: bool) -> bool:
	if not _assert_true(bool(ui.get("hud_active", false)), "store HUD active"):
		return false
	if not _assert_false(bool(ui.get("tutorial_overlay_visible", true)), "tutorial overlay hidden"):
		return false
	if (
		not modal_expected
		and not _assert_false(String(InputFocus.current()) == "modal", "movement not modal-blocked")
	):
		return false
	return true


func _register_text(owner: Node) -> String:
	var scene: Node = owner.get_tree().current_scene
	var screen: Node = (
		scene.find_child("RegisterScreenState", true, false) if scene != null else null
	)
	if screen != null and screen.has_method("display_text"):
		return str(screen.call("display_text"))
	return ""


func _summary_visible(controller: StoreSessionController) -> bool:
	var panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	return panel != null and panel.visible


func _failure_context(current: Dictionary, expected: Dictionary) -> String:
	return (
		"expected_action=%s expected_target=%s current_prompt=%s current_stage=%s recovery=%s"
		% [
			str(expected.get("prompt", "")),
			str(expected.get("target", "")),
			str((current.get("visible_prompt", {}) as Dictionary).get("label", "")),
			str(current.get("stage", "")),
			_recovery_surface(),
		]
	)


func _recovery_surface() -> String:
	var modal_snapshot: Dictionary = ModalQueue.get_modal_snapshot()
	if bool(modal_snapshot.get("busy", false)):
		return "modal:%s" % str(modal_snapshot.get("active_panel", ""))
	return "store_session_prompt"


func _assert_eq(actual: Variant, expected: Variant, label: String) -> bool:
	_assertions["total"] = int(_assertions["total"]) + 1
	if actual == expected:
		_assertions["passed"] = int(_assertions["passed"]) + 1
		return true
	_assertions["failed"] = int(_assertions["failed"]) + 1
	_failure = "%s expected=%s actual=%s" % [label, expected, actual]
	return false


func _assert_true(value: bool, label: String) -> bool:
	return _assert_eq(value, true, label)


func _assert_false(value: bool, label: String) -> bool:
	return _assert_eq(value, false, label)
