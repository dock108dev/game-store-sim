class_name HUDNotificationVisualStateScene
extends Control

const SURFACE_ID: String = "hud_notification_states"
const PANEL_RADIUS: int = 6
const PANEL_PADDING: int = 10
const BODY_FONT_SIZE: int = 15
const HEADER_FONT_SIZE: int = 18
const TOP_BAR_HEIGHT: float = 48.0
const RIGHT_PANEL_WIDTH: float = 300.0
const RIGHT_PANEL_INSET: float = 20.0
const TOAST_WIDTH: float = 420.0
const TOAST_HEIGHT: float = 48.0
const TOAST_TOP: float = 96.0
const TOAST_GAP: float = 8.0
const TOAST_LEFT_MARGIN: float = 16.0
const TOAST_RIGHT_PANEL_GAP: float = 24.0
const OBJECTIVE_HEIGHT: float = 112.0
const PROMPT_WIDTH: float = 360.0
const PROMPT_HEIGHT: float = 40.0
const EVENT_LOG_WIDTH: float = 248.0
const EVENT_LOG_HEIGHT: float = 90.0
const STATE_IDS: Array[String] = [
	"normal",
	"low_money",
	"many_notifications",
	"stock_warning",
	"tutorial_active",
	"side_panel_open",
	"store_ui_open",
	"dialogue_plus_notification",
	"small_resolution",
	"ultrawide_resolution",
]
const RESOLUTION_MATRIX: Array[Vector2i] = [
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1080),
]
const DEFAULT_STATE_RESOLUTIONS: Dictionary = {
	"small_resolution": Vector2i(1024, 576),
	"ultrawide_resolution": Vector2i(2560, 1080),
}
var _state_id: String = "normal"
var _viewport_size: Vector2i = Vector2i(1280, 720)
var _surface: Control
var _rects: Dictionary = {}
var _text_nodes: Array[Label] = []
var _primary_node: String = "objective_rail"
var _passive_nodes: Array[String] = []
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_meta("visual_surface_id", SURFACE_ID)
	set_meta("scenario_target_kind", "visual_test_surface")
	render_state(_state_id, _viewport_size)

func render_state(state_id: String, viewport_size: Vector2i = Vector2i.ZERO) -> Dictionary:
	if not STATE_IDS.has(state_id):
		return _error_report(state_id, viewport_size, "unknown_state", "")
	if viewport_size == Vector2i.ZERO:
		viewport_size = DEFAULT_STATE_RESOLUTIONS.get(state_id, Vector2i(1280, 720)) as Vector2i
	_state_id = state_id
	_viewport_size = viewport_size
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	size = Vector2(viewport_size)
	custom_minimum_size = Vector2(viewport_size)
	_clear_surface()
	_build_surface()
	_apply_state(state_id)
	return layout_report()

func layout_report() -> Dictionary:
	_register_rects()
	var failures: Array[Dictionary] = []
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(_viewport_size))
	for node_name: String in _rects.keys():
		var rect: Rect2 = _rects[node_name]
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			failures.append(_failure(node_name, "non_positive_size", rect, null))
		elif not viewport_rect.encloses(rect):
			failures.append(_failure(node_name, "offscreen", rect, viewport_rect))
	for label: Label in _text_nodes:
		if label.visible and label.text.strip_edges().is_empty():
			failures.append(_failure(label.name, "empty_text_box", label.get_global_rect(), null))
		elif label.visible and label.get_global_rect().size.length() <= 0.0:
			failures.append(_failure(label.name, "text_box_non_positive_size", label.get_global_rect(), null))
	_check_pair(failures, "notification_stack", "right_panel", "overlaps_right_panel")
	_check_pair(failures, "notification_stack", "interaction_prompt", "overlaps_prompt")
	_check_pair(failures, "notification_stack", "store_ui_panel", "overlaps_store_ui")
	_check_pair(failures, "dialogue_panel", "notification_stack", "dialogue_competes_with_toasts")
	_check_pair(failures, "event_log", "objective_rail", "event_log_overlaps_objective")
	_check_primary_dominance(failures)
	return {
		"ok": failures.is_empty(),
		"visual_surface_id": SURFACE_ID,
		"state_id": _state_id,
		"viewport": {"width": _viewport_size.x, "height": _viewport_size.y},
		"primary_node": _primary_node,
		"rects": _serializable_rects(),
		"failures": failures,
	}

func _build_surface() -> void:
	_surface = Control.new()
	_surface.name = "HUDVisualStateSurface"
	_surface.size = Vector2(_viewport_size)
	_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_surface)
	_add_background()
	_add_top_bar("$135.00", "Day 1 - 8:00 AM", Color(0.96, 0.91, 0.83))
	_add_objective_rail("Talk to the customer at the counter", "Press E", "E")
	_add_interaction_prompt("Counter - Press E")

func _apply_state(state_id: String) -> void:
	_primary_node = "objective_rail"
	_passive_nodes = []
	match state_id:
		"normal":
			_add_notification_stack(["Store opened"], [&"system"])
		"low_money":
			_primary_node = "low_money_banner"
			_set_cash("$8.50", Color(1.0, 0.71, 0.66))
			_add_banner("LowMoneyBanner", "Cash is tight - prioritize one shelf", Color(0.55, 0.12, 0.10, 0.94))
			_add_notification_stack(["Low cash"], [&"warning"])
		"many_notifications":
			_primary_node = "objective_rail"
			_add_notification_stack([
				"Sale completed",
				"Shelf stock is low",
				"Customer waiting",
				"Manager note updated",
				"Open task remains",
			], [&"sale", &"warning", &"customer", &"system", &"objective"])
		"stock_warning":
			_primary_node = "right_panel"
			_add_right_panel("STOCK WARNING", ["Shelf: 1 / 8", "Back room: 0", "Order soon"])
			_add_event_log(["Stock dipped below target", "Customer asked for classics"])
			_add_notification_stack(["Shelf stock low"], [&"warning"])
		"tutorial_active":
			_primary_node = "tutorial_bar"
			_add_right_panel("FIRST DAY", ["Manager", "Register", "Back room", "Shelf stock"])
			_add_tutorial_bar("Check the stock box, then return to the starter shelf")
		"side_panel_open":
			_primary_node = "right_panel"
			_add_right_panel("TODAY", ["Shelves: 6", "Stockroom: 3", "Customers: 2", "Sales: $42"])
			_add_event_log(["Restocked shelf", "Sale completed"])
		"store_ui_open":
			_primary_node = "store_ui_panel"
			_add_store_ui_panel()
			_add_notification_stack(["Sale queued"], [&"sale"])
		"dialogue_plus_notification":
			_primary_node = "dialogue_panel"
			_add_dialogue_panel("Mara", "That shelf needs one more game before we unlock the door.")
			_add_notification_stack(["New task"], [&"objective"])
		"small_resolution":
			_primary_node = "objective_rail"
			_add_right_panel("COMPACT", ["Shelves: 2", "Stockroom: 1"])
			_add_notification_stack(["Compact HUD"], [&"system"])
		"ultrawide_resolution":
			_primary_node = "store_ui_panel"
			_add_store_ui_panel()
			_add_right_panel("WIDE VIEW", ["Shelves: 8", "Stockroom: 4", "Customers: 5"])


func _add_background() -> void:
	var bg := ColorRect.new()
	bg.name = "StoreBackdrop"
	bg.color = Color(0.095, 0.082, 0.071, 1.0)
	bg.size = Vector2(_viewport_size)
	_surface.add_child(bg)


func _add_top_bar(cash: String, time: String, text_color: Color) -> void:
	var top := PanelContainer.new()
	top.name = "TopBar"
	top.position = Vector2(12.0, 8.0)
	top.size = Vector2(max(520.0, _viewport_size.x - 344.0), 40.0)
	top.add_theme_stylebox_override("panel", _panel_style(Color(0.12, 0.10, 0.086, 0.88)))
	_surface.add_child(top)
	var row := HBoxContainer.new()
	row.name = "Row"
	row.add_theme_constant_override("separation", 18)
	top.add_child(row)
	_add_label(row, "CashLabel", cash, HEADER_FONT_SIZE, text_color, Vector2(160, TOP_BAR_HEIGHT))
	_add_label(row, "TimeLabel", time, BODY_FONT_SIZE, text_color, Vector2(220, TOP_BAR_HEIGHT))
	_add_label(row, "StatusLabel", "Retro Games", BODY_FONT_SIZE, text_color, Vector2(160, TOP_BAR_HEIGHT))


func _set_cash(text: String, color: Color) -> void:
	var label := _surface.get_node_or_null("TopBar/Row/CashLabel") as Label
	if label != null:
		label.text = text
		label.add_theme_color_override("font_color", color)


func _add_objective_rail(objective: String, action: String, key_text: String) -> void:
	var panel := PanelContainer.new()
	panel.name = "ObjectiveRail"
	panel.position = Vector2(12.0, _viewport_size.y - OBJECTIVE_HEIGHT - 8.0)
	panel.size = Vector2(_viewport_size.x - 24.0, OBJECTIVE_HEIGHT)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.10, 0.085, 0.072, 0.88)))
	_surface.add_child(panel)
	var row := HBoxContainer.new()
	row.name = "Row"
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	_add_label(row, "ObjectiveText", objective, HEADER_FONT_SIZE, Color(0.96, 0.91, 0.83), Vector2(520, 42))
	_add_label(row, "ActionText", action, BODY_FONT_SIZE, Color(0.91, 0.65, 0.28), Vector2(100, 42))
	_add_label(row, "KeyBadge", key_text, BODY_FONT_SIZE, Color(0.17, 0.11, 0.07), Vector2(36, 32), true)


func _add_interaction_prompt(text: String) -> void:
	var panel := PanelContainer.new()
	panel.name = "InteractionPrompt"
	panel.position = Vector2(
		_viewport_size.x - PROMPT_WIDTH - float(PANEL_PADDING * 2) - 16.0,
		_viewport_size.y - 200.0
	)
	panel.size = Vector2(PROMPT_WIDTH, PROMPT_HEIGHT)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.122, 0.102, 0.086, 0.78)))
	_surface.add_child(panel)
	_add_label(panel, "PromptText", text, BODY_FONT_SIZE, Color(0.96, 0.91, 0.83), panel.size)


func _add_right_panel(title: String, rows: Array[String]) -> void:
	var panel := PanelContainer.new()
	panel.name = "RightPanel"
	panel.position = Vector2(_viewport_size.x - RIGHT_PANEL_WIDTH - RIGHT_PANEL_INSET, 84.0)
	panel.size = Vector2(RIGHT_PANEL_WIDTH, min(250.0, _viewport_size.y - 248.0))
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.08, 0.14, 0.78)))
	_surface.add_child(panel)
	var col := VBoxContainer.new()
	col.name = "Column"
	col.add_theme_constant_override("separation", 6)
	panel.add_child(col)
	_add_label(col, "RightTitle", title, HEADER_FONT_SIZE, Color.WHITE, Vector2(260, 24))
	for i: int in range(rows.size()):
		_add_label(col, "RightRow%d" % i, rows[i], BODY_FONT_SIZE, Color(1, 1, 1, 0.72), Vector2(260, 22))


func _add_notification_stack(messages: Array[String], categories: Array[StringName]) -> void:
	var stack := VBoxContainer.new()
	stack.name = "NotificationStack"
	stack.position = Vector2(_toast_x(), TOAST_TOP)
	stack.size = Vector2(TOAST_WIDTH, 0.0)
	stack.add_theme_constant_override("separation", int(TOAST_GAP))
	_surface.add_child(stack)
	var visible_count: int = min(messages.size(), 2)
	var card_count: int = visible_count
	if messages.size() > visible_count:
		card_count += 1
	stack.size = Vector2(TOAST_WIDTH, card_count * (TOAST_HEIGHT + TOAST_GAP) - TOAST_GAP)
	for i: int in range(visible_count):
		var category := categories[min(i, categories.size() - 1)]
		_add_toast(stack, "Toast%d" % i, messages[i], category)
	if messages.size() > visible_count:
		_add_toast(stack, "QueueSummary", "%d queued" % (messages.size() - visible_count), &"system")


func _add_toast(parent: Control, node_name: String, text: String, category: StringName) -> void:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.custom_minimum_size = Vector2(TOAST_WIDTH, TOAST_HEIGHT)
	panel.add_theme_stylebox_override("panel", _toast_style(_category_color(category)))
	parent.add_child(panel)
	panel.set_meta("category", String(category))
	panel.set_meta("corner_radius", PANEL_RADIUS)
	panel.set_meta("font_size", BODY_FONT_SIZE)
	_add_label(panel, "ToastText", text, BODY_FONT_SIZE, Color(0.92, 0.92, 0.92), Vector2(TOAST_WIDTH, TOAST_HEIGHT))


func _add_event_log(rows: Array[String]) -> void:
	var panel := PanelContainer.new()
	panel.name = "EventLog"
	panel.position = Vector2(16.0, _viewport_size.y - 286.0)
	panel.size = Vector2(EVENT_LOG_WIDTH, EVENT_LOG_HEIGHT)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.08, 0.14, 0.76)))
	_surface.add_child(panel)
	var col := VBoxContainer.new()
	col.name = "Rows"
	col.add_theme_constant_override("separation", 2)
	panel.add_child(col)
	for i: int in range(rows.size()):
		_add_label(col, "Event%d" % i, rows[i], 12, Color(0.95, 0.95, 0.95, 0.9), Vector2(220, 18))


func _add_tutorial_bar(text: String) -> void:
	var panel := PanelContainer.new()
	panel.name = "TutorialBar"
	panel.position = Vector2(64.0, _viewport_size.y - 72.0)
	panel.size = Vector2(_viewport_size.x - 128.0, 48.0)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.10, 0.09, 0.13, 0.94)))
	_surface.add_child(panel)
	_add_label(panel, "TutorialText", text, BODY_FONT_SIZE, Color(0.96, 0.91, 0.83), panel.size)


func _add_store_ui_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "StoreUIPanel"
	panel.position = Vector2(48.0, 180.0)
	panel.size = Vector2(min(520.0, _viewport_size.x - 420.0), min(300.0, _viewport_size.y - 320.0))
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.122, 0.102, 0.086, 0.96)))
	_surface.add_child(panel)
	var col := VBoxContainer.new()
	col.name = "Column"
	col.add_theme_constant_override("separation", 8)
	panel.add_child(col)
	_add_label(col, "StoreUITitle", "Shelf Stock", HEADER_FONT_SIZE, Color(0.96, 0.91, 0.83), Vector2(440, 26))
	_add_label(col, "StoreUIAction", "Place Starter Cartridge", BODY_FONT_SIZE, Color(0.91, 0.65, 0.28), Vector2(440, 24))
	_add_label(col, "StoreUIBody", "3 items available", BODY_FONT_SIZE, Color(1, 1, 1, 0.72), Vector2(440, 24))


func _add_dialogue_panel(speaker: String, text: String) -> void:
	var panel := PanelContainer.new()
	panel.name = "DialoguePanel"
	panel.position = Vector2(64.0, _viewport_size.y - 270.0)
	panel.size = Vector2(min(620.0, _viewport_size.x - 560.0), 112.0)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.09, 0.08, 0.11, 0.96)))
	_surface.add_child(panel)
	var col := VBoxContainer.new()
	col.name = "Column"
	col.add_theme_constant_override("separation", 6)
	panel.add_child(col)
	_add_label(col, "Speaker", speaker, HEADER_FONT_SIZE, Color(0.91, 0.65, 0.28), Vector2(540, 24))
	_add_label(col, "DialogueText", text, BODY_FONT_SIZE, Color(0.96, 0.91, 0.83), Vector2(540, 48))


func _add_banner(node_name: String, text: String, color: Color) -> void:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.position = Vector2(16.0, 60.0)
	panel.size = Vector2(min(520.0, _viewport_size.x - 360.0), 56.0)
	panel.add_theme_stylebox_override("panel", _panel_style(color))
	_surface.add_child(panel)
	_add_label(panel, "BannerText", text, BODY_FONT_SIZE, Color(1, 0.92, 0.86), panel.size)


func _add_label(
	parent: Node, node_name: String, text: String, font_size: int, color: Color,
	min_size: Vector2, badge: bool = false
) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.custom_minimum_size = min_size
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if badge:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	_text_nodes.append(label)
	return label


func _panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = PANEL_RADIUS
	style.corner_radius_top_right = PANEL_RADIUS
	style.corner_radius_bottom_left = PANEL_RADIUS
	style.corner_radius_bottom_right = PANEL_RADIUS
	style.content_margin_left = PANEL_PADDING
	style.content_margin_right = PANEL_PADDING
	style.content_margin_top = PANEL_PADDING
	style.content_margin_bottom = PANEL_PADDING
	return style


func _toast_style(border_color: Color) -> StyleBoxFlat:
	var style := _panel_style(Color(0.08, 0.08, 0.08, 0.85))
	style.border_width_left = 3
	style.border_color = border_color
	return style


func _category_color(category: StringName) -> Color:
	match category:
		&"sale":
			return Color(0.30, 0.69, 0.31)
		&"warning":
			return Color(0.95, 0.72, 0.11)
		&"customer":
			return Color(0.30, 1.0, 0.5)
		&"objective":
			return Color(0.40, 0.90, 1.0)
		_:
			return Color(0.45, 0.45, 0.45)


func _toast_x() -> float:
	var right_panel_left: float = _viewport_size.x - RIGHT_PANEL_INSET - RIGHT_PANEL_WIDTH
	return max(TOAST_LEFT_MARGIN, right_panel_left - TOAST_RIGHT_PANEL_GAP - TOAST_WIDTH - float(PANEL_PADDING * 2))


func _register_rects() -> void:
	_rects.clear()
	_register("top_bar", "TopBar")
	_register("low_money_banner", "LowMoneyBanner")
	_register("notification_stack", "NotificationStack")
	_register("right_panel", "RightPanel")
	_register("event_log", "EventLog")
	_register("objective_rail", "ObjectiveRail")
	_register("interaction_prompt", "InteractionPrompt")
	_register("tutorial_bar", "TutorialBar")
	_register("store_ui_panel", "StoreUIPanel")
	_register("dialogue_panel", "DialoguePanel")


func _register(key: String, path: String) -> void:
	var node := _surface.get_node_or_null(path) as Control
	if node != null and node.visible:
		_rects[key] = node.get_global_rect()


func _check_pair(
	failures: Array[Dictionary], first: String, second: String, reason: String
) -> void:
	if not _rects.has(first) or not _rects.has(second):
		return
	var first_rect: Rect2 = _rects[first]
	var second_rect: Rect2 = _rects[second]
	if first_rect.intersects(second_rect):
		failures.append(_failure(first, reason, first_rect, second_rect, second))


func _check_primary_dominance(failures: Array[Dictionary]) -> void:
	if not _rects.has(_primary_node):
		failures.append(_failure(_primary_node, "primary_missing", Rect2(), null))
		return
	var primary_area: float = _area(_rects[_primary_node])
	for passive: String in _passive_nodes + ["notification_stack", "event_log"]:
		if not _rects.has(passive):
			continue
		if primary_area < _area(_rects[passive]) * 0.9:
			failures.append(_failure(_primary_node, "primary_not_dominant", _rects[_primary_node], _rects[passive], passive))


func _area(rect: Rect2) -> float:
	return rect.size.x * rect.size.y


func _serializable_rects() -> Dictionary:
	var out: Dictionary = {}
	for key: String in _rects.keys():
		var rect: Rect2 = _rects[key]
		out[key] = _rect_payload(rect)
	return out


func _failure(
	node_name: String, reason: String, rect: Rect2, other_rect: Variant,
	other_node: String = ""
) -> Dictionary:
	return {
		"node": node_name,
		"other_node": other_node,
		"state_id": _state_id,
		"viewport": {"width": _viewport_size.x, "height": _viewport_size.y},
		"rect": _rect_payload(rect),
		"other_rect": _rect_payload(other_rect) if other_rect is Rect2 else {},
		"reason": reason,
	}


func _rect_payload(rect: Rect2) -> Dictionary:
	return {
		"x": rect.position.x,
		"y": rect.position.y,
		"w": rect.size.x,
		"h": rect.size.y,
		"right": rect.position.x + rect.size.x,
		"bottom": rect.position.y + rect.size.y,
	}


func _error_report(state_id: String, viewport_size: Vector2i, reason: String, node_name: String) -> Dictionary:
	_state_id = state_id
	_viewport_size = viewport_size
	return {
		"ok": false,
		"visual_surface_id": SURFACE_ID,
		"state_id": state_id,
		"viewport": {"width": viewport_size.x, "height": viewport_size.y},
		"rects": {},
		"failures": [_failure(node_name, reason, Rect2(), null)],
	}


func _clear_surface() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_rects.clear()
	_text_nodes.clear()
