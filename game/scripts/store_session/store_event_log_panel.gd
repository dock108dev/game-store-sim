## Bottom-left on-screen event log surface for the store_session Day-1 loop.
##
## Subscribes to `EventBus.event_logged(tag, message)` and renders the
## most-recent entries as a stacked list of message-only `Label` rows. The
## bracket-wrapped tag (e.g. `[STOCK]`) drives the row's font_color via
## `_TAG_COLORS` but is stripped from the visible text — the underlying
## `[TAG] message` shape lives only on the signal payload. Player-facing —
## not a debug overlay — so it ships in release builds. Pairs with
## `EventLog`, which emits `event_logged` unconditionally even though its
## ring buffer is debug-only.
##
## Visual contract mirrors `StoreStatusPanel` so the two surfaces read as
## a single design family: same warm-dark `_PANEL_BG`, compact padding, no border.
## Width 260 px, height ~120 px, anchored bottom-left above the carry label
## (which sits at `offset_top = -200` from bottom — we stop at -204).
## Stays visible in first-person mode: this surface owns recent events only,
## while `StoreStatusPanel` owns objectives and `InteractionPrompt` owns the
## bottom-right action affordance.
##
## Owned by the `StoreSessionHUD` autoload (spawned in `StoreSessionHUD._ready`); persists
## across day-controller teardown so it survives day transitions without
## losing in-flight rows.
class_name StoreEventLogPanel
extends CanvasLayer

## Hard cap on rendered rows. A 4th entry queue_free()'s the oldest so the
## panel never spans more than three lines and leaves the first-person view
## uncluttered.
const MAX_VISIBLE_ENTRIES: int = 3

## Oldest visible row's alpha when the panel is full. Rows interpolate
## linearly between this value (at index 0) and 1.0 (at the last index), so
## each new entry pushes its predecessors toward transparency.
const ALPHA_OLDEST: float = 0.35

## First-minute feedback tags that should read as active player progress
## instead of passive history. The feed still orders strictly by arrival
## time; priority is expressed only through row styling.
const IMPORTANT_TAGS: Dictionary = {
	"DAY": true,
	"OBJECTIVE": true,
	"STOCK": true,
	"SYSTEM": true,
}

## CanvasLayer ordering — sits below ModalDimOverlay (49) so the day-end /
## decision modals dim it, and below ObjectiveRail (40) so the rail's
## active-step chip always wins. Layer 30 matches `StoreStatusPanel` — the
## two panels share a tier.
const LAYER_INDEX: int = 30

## Modal-fade contract — mirrors `hud.gd._MODAL_DIM_ALPHA`. When CTX_MODAL
## is on top of the InputFocus stack the panel alpha drops so the modal
## owns the foreground. Calibrated against `ModalDimOverlay.DIM_COLOR.a`
## so the composed visible opacity stays legible (0.65 × 0.6 ≈ 0.39).
const _MODAL_DIM_ALPHA: float = 0.65

const _PANEL_BG: Color = Color(0.094, 0.078, 0.067, 0.76)
const _PANEL_WIDTH: float = 248.0
const _PANEL_HEIGHT: float = 90.0
const _PADDING: int = 10
## Bottom inset chosen so the panel sits flush above `StoreSessionCarryLabel`
## (which lives at `offset_top = -200` on CarryHUD); 4 px clearance keeps
## the carry-state amber strip from kissing the panel edge.
const _BOTTOM_INSET: float = 204.0
const _LEFT_INSET: float = 16.0
const _ENTRY_FONT_SIZE: int = 12
const _IMPORTANT_ENTRY_FONT_SIZE: int = 13
const _NEWEST_ENTRY_FONT_SIZE: int = 13
const _ENTRY_MIN_HEIGHT: float = 14.0
const _ENTRY_OUTLINE_COLOR: Color = Color(0.02, 0.018, 0.015, 0.86)
const _IMPORTANT_OUTLINE_SIZE: int = 1
const _NEWEST_OUTLINE_SIZE: int = 2

const _HIDDEN_TAGS: Dictionary = {
	"DEBUG": true,
	"MODAL": true,
}

## Tag → font color. Keys are bare tag names (no brackets); the bracketed
## form arrives over `event_logged` and is unwrapped before lookup.
const _TAG_COLORS: Dictionary = {
	"STOCK": Color(0.357, 0.722, 0.910, 1.0),    # soft blue
	"CUSTOMER": Color(0.561, 0.878, 0.459, 1.0), # soft green
	"DAY": Color(0.910, 0.647, 0.278, 1.0),      # modal gold
	"SYSTEM": Color(0.722, 0.660, 0.549, 1.0),   # muted warm gray
	"OBJECTIVE": Color(0.957, 0.914, 0.831, 1.0), # cream objective echo
}

## Near-white fallback for unrecognized or missing tags. Picked over pure
## white so the muted desaturated panel chrome still wins visually.
const _DEFAULT_TAG_COLOR: Color = Color(0.95, 0.95, 0.95, 1.0)

var _entry_container: VBoxContainer


func _ready() -> void:
	add_to_group("store_event_log_panel")
	layer = LAYER_INDEX
	_build_panel()
	# §EH-13 — direct typed connection; `event_logged` is owner-declared on
	# EventBus so a signal-rename fails at parse time instead of silently
	# stranding the panel empty.
	EventBus.event_logged.connect(_on_event_logged)
	InputFocus.context_changed.connect(_on_input_focus_changed)


## Explicit disconnect on tree exit so a freed panel cannot stay subscribed
## to the autoload `EventBus.event_logged` stream and burn the customer FSM
## hot path with `Label.new()` allocations for every state change.
## Godot 4 auto-disconnects when the receiver is freed, but tests that call
## `node.free()` immediately (GUT's `add_child_autofree`) can race the
## cleanup — the disconnect here closes that gap deterministically.
func _exit_tree() -> void:
	if EventBus.event_logged.is_connected(_on_event_logged):
		EventBus.event_logged.disconnect(_on_event_logged)
	if InputFocus.context_changed.is_connected(_on_input_focus_changed):
		InputFocus.context_changed.disconnect(_on_input_focus_changed)


func _build_panel() -> void:
	var anchor: Control = Control.new()
	anchor.name = "Anchor"
	anchor.anchor_left = 0.0
	anchor.anchor_top = 1.0
	anchor.anchor_right = 0.0
	anchor.anchor_bottom = 1.0
	anchor.offset_left = _LEFT_INSET
	anchor.offset_top = -(_BOTTOM_INSET + _PANEL_HEIGHT)
	anchor.offset_right = _LEFT_INSET + _PANEL_WIDTH
	anchor.offset_bottom = -_BOTTOM_INSET
	anchor.grow_vertical = Control.GROW_DIRECTION_BEGIN
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(anchor)

	var background: ColorRect = ColorRect.new()
	background.name = "Background"
	background.color = _PANEL_BG
	background.anchor_left = 0.0
	background.anchor_top = 0.0
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor.add_child(background)

	var margin: MarginContainer = MarginContainer.new()
	margin.name = "Margin"
	margin.anchor_left = 0.0
	margin.anchor_top = 0.0
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", _PADDING)
	margin.add_theme_constant_override("margin_top", _PADDING)
	margin.add_theme_constant_override("margin_right", _PADDING)
	margin.add_theme_constant_override("margin_bottom", _PADDING)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor.add_child(margin)

	_entry_container = VBoxContainer.new()
	_entry_container.name = "Entries"
	_entry_container.add_theme_constant_override("separation", 2)
	# Bottom-anchored so new entries push older rows up — the freshest beat
	# always sits flush against the bottom of the panel where the player's
	# eye lands first.
	_entry_container.alignment = BoxContainer.ALIGNMENT_END
	_entry_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(_entry_container)


func _on_event_logged(tag: String, message: String) -> void:
	if _entry_container == null:
		return
	if message.is_empty():
		return
	var tag_key: String = _tag_key(tag)
	if _HIDDEN_TAGS.has(tag_key):
		return
	var display_text: String = _strip_leading_bracket_tags(message).strip_edges()
	if display_text.is_empty():
		return

	var row: Label = Label.new()
	row.text = display_text
	row.set_meta("event_log_tag", tag_key)
	row.add_theme_color_override(
		"font_color", _TAG_COLORS.get(tag_key, _DEFAULT_TAG_COLOR)
	)
	row.add_theme_color_override("font_outline_color", _ENTRY_OUTLINE_COLOR)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.custom_minimum_size = Vector2(0.0, _ENTRY_MIN_HEIGHT)
	_entry_container.add_child(row)

	# Synchronous eviction — `queue_free` alone keeps the node parented until
	# end-of-frame, which would skew `get_child_count()` and the alpha math.
	while _entry_container.get_child_count() > MAX_VISIBLE_ENTRIES:
		var oldest: Node = _entry_container.get_child(0)
		_entry_container.remove_child(oldest)
		oldest.queue_free()

	_refresh_alpha()
	_refresh_row_emphasis()


## Recomputes per-row `modulate.a` so the oldest row sits at `ALPHA_OLDEST`,
## the newest at 1.0, and intermediate rows fall on the linear segment
## between. Runs synchronously after every add/evict so the fade is in
## place before the next frame draws.
func _refresh_alpha() -> void:
	if _entry_container == null:
		return
	var count: int = _entry_container.get_child_count()
	for i: int in range(count):
		var child: Node = _entry_container.get_child(i)
		if not (child is CanvasItem):
			continue
		var alpha: float
		if count <= 1:
			alpha = 1.0
		else:
			alpha = lerp(ALPHA_OLDEST, 1.0, float(i) / float(count - 1))
		var item: CanvasItem = child as CanvasItem
		var mod: Color = item.modulate
		mod.a = alpha
		item.modulate = mod


func _refresh_row_emphasis() -> void:
	if _entry_container == null:
		return
	var newest_index: int = _entry_container.get_child_count() - 1
	for i: int in range(_entry_container.get_child_count()):
		var row: Node = _entry_container.get_child(i)
		if not (row is Label):
			continue
		var label: Label = row as Label
		var tag_key: String = String(label.get_meta("event_log_tag", ""))
		var important: bool = IMPORTANT_TAGS.has(tag_key)
		var newest: bool = i == newest_index
		var font_size: int = _ENTRY_FONT_SIZE
		if important:
			font_size = _IMPORTANT_ENTRY_FONT_SIZE
		if newest:
			font_size = max(font_size, _NEWEST_ENTRY_FONT_SIZE)
		var outline_size: int = 0
		if important:
			outline_size = _IMPORTANT_OUTLINE_SIZE
		if newest:
			outline_size = max(outline_size, _NEWEST_OUTLINE_SIZE)
		label.add_theme_font_size_override("font_size", font_size)
		label.add_theme_constant_override("outline_size", outline_size)


func _on_input_focus_changed(new_ctx: StringName, _old_ctx: StringName) -> void:
	var target: float = (
		_MODAL_DIM_ALPHA if new_ctx == InputFocus.CTX_MODAL else 1.0
	)
	for child: Node in get_children():
		if child is CanvasItem:
			(child as CanvasItem).modulate.a = target


## Test seam — returns the number of rendered entry rows.
func get_visible_entry_count() -> int:
	if _entry_container == null:
		return 0
	return _entry_container.get_child_count()


## Test seam — returns the visible text of the most-recent row (without the
## stripped `[TAG] ` prefix), or an empty string when the panel has no
## entries.
func get_latest_row_text() -> String:
	if _entry_container == null:
		return ""
	var count: int = _entry_container.get_child_count()
	if count == 0:
		return ""
	var row: Node = _entry_container.get_child(count - 1)
	if row is Label:
		return (row as Label).text
	return ""


## Test seam — returns the visible text at `index` (0 = oldest row), or an
## empty string when out of range.
func get_row_text_for_test(index: int) -> String:
	if _entry_container == null:
		return ""
	if index < 0 or index >= _entry_container.get_child_count():
		return ""
	var row: Node = _entry_container.get_child(index)
	if row is Label:
		return (row as Label).text
	return ""


## Test seam — returns the font color the panel would apply for `tag`.
## Accepts either the bare key (`"STOCK"`) or the bracketed form
## (`"[STOCK]"`) so call sites can use whichever they have on hand.
func get_tag_color(tag: String) -> Color:
	var key: String = _tag_key(tag)
	return _TAG_COLORS.get(key, _DEFAULT_TAG_COLOR)


## Test seam — returns the resolved `modulate.a` for the row at `index`
## (0 = oldest visible row). Mirrors what `_refresh_alpha` writes without
## forcing tests to dig into CanvasItem state directly.
func get_row_alpha(index: int) -> float:
	if _entry_container == null:
		return 0.0
	if index < 0 or index >= _entry_container.get_child_count():
		return 0.0
	var child: Node = _entry_container.get_child(index)
	if child is CanvasItem:
		return (child as CanvasItem).modulate.a
	return 0.0


## Test seam — returns the resolved row font size at `index`.
func get_row_font_size_for_test(index: int) -> int:
	var row: Label = _get_row_label(index)
	if row == null:
		return 0
	return row.get_theme_font_size("font_size")


## Test seam — returns the resolved row outline size at `index`.
func get_row_outline_size_for_test(index: int) -> int:
	var row: Label = _get_row_label(index)
	if row == null:
		return 0
	return row.get_theme_constant("outline_size")


func _get_row_label(index: int) -> Label:
	if _entry_container == null:
		return null
	if index < 0 or index >= _entry_container.get_child_count():
		return null
	var row: Node = _entry_container.get_child(index)
	if row is Label:
		return row as Label
	return null


func _tag_key(tag: String) -> String:
	return tag.strip_edges().trim_prefix("[").trim_suffix("]").to_upper()


func _strip_leading_bracket_tags(text: String) -> String:
	var remaining: String = text.strip_edges()
	while remaining.begins_with("["):
		var close_index: int = remaining.find("]")
		if close_index <= 0:
			break
		remaining = remaining.substr(close_index + 1).strip_edges()
	return remaining
