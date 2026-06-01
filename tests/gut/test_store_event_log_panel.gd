## Tests for the bottom-left store_session event-log surface (`StoreEventLogPanel`).
##
## Covers the visual contract (dark-indigo background, tag color tokens),
## the 4-row visible cap with descending-alpha fade, the bracket-tag strip,
## the modal-dim contract, and FP-mode ownership.
extends GutTest


func before_each() -> void:
	InputFocus._reset_for_tests()


func _make_panel() -> StoreEventLogPanel:
	var panel: StoreEventLogPanel = StoreEventLogPanel.new()
	add_child_autofree(panel)
	return panel


# ── visibility / wiring ───────────────────────────────────────────────────────

func test_panel_is_visible_at_ready() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	assert_true(
		panel.visible,
		"Event-log panel must be visible immediately after _ready"
	)


func test_panel_sits_on_layer_30() -> void:
	# AC: matches the right-side stats panel layer so the design family
	# (StoreStatusPanel, StoreEventLogPanel) shares
	# the same z-tier and the same modal-dim contract.
	var panel: StoreEventLogPanel = _make_panel()
	assert_eq(
		panel.layer, 30,
		"StoreEventLogPanel must sit on layer 30 alongside the other Today panels"
	)


func test_panel_starts_with_zero_entries() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	assert_eq(
		panel.get_visible_entry_count(), 0,
		"Panel must start with no entries"
	)


func test_panel_uses_shared_warm_hud_background() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	var background: ColorRect = panel.get_node("Anchor/Background") as ColorRect
	assert_not_null(background, "Panel must own a background rect")
	if background != null:
		assert_eq(
			background.color,
			StoreEventLogPanel._PANEL_BG,
			"Event log background must use the shared warm HUD family"
		)
		assert_eq(background.color, Color(0.094, 0.078, 0.067, 0.76))


# ── event_logged subscription ─────────────────────────────────────────────────

func test_event_logged_emit_renders_row() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.event_logged.emit("[STOCK]", "Stocked Crash Bandicoot 2.")
	await get_tree().process_frame
	assert_eq(
		panel.get_visible_entry_count(), 1,
		"event_logged must add a row"
	)


func test_empty_message_is_ignored() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.event_logged.emit("[STOCK]", "")
	await get_tree().process_frame
	assert_eq(
		panel.get_visible_entry_count(), 0,
		"Empty message must not produce a row"
	)


# ── rolling cap ───────────────────────────────────────────────────────────────

func test_max_visible_entries_is_three() -> void:
	# AC pin: the rendered cap is exactly 3 — the constant is part of the
	# spec contract, not a tunable.
	assert_eq(
		StoreEventLogPanel.MAX_VISIBLE_ENTRIES, 3,
		"Spec pins the rendered cap at 3 rows"
	)


func test_panel_caps_visible_entries_at_max() -> void:
	# AC: panel never displays more than MAX_VISIBLE_ENTRIES rows; the oldest
	# is queue_free()'d when a 5th arrives.
	var panel: StoreEventLogPanel = _make_panel()
	for i: int in range(StoreEventLogPanel.MAX_VISIBLE_ENTRIES + 4):
		EventBus.event_logged.emit("[STOCK]", "Stocked item %d." % i)
	await get_tree().process_frame
	assert_eq(
		panel.get_visible_entry_count(),
		StoreEventLogPanel.MAX_VISIBLE_ENTRIES,
		"Panel must cap rendered rows at MAX_VISIBLE_ENTRIES"
	)


# ── alpha-fade contract ───────────────────────────────────────────────────────

func test_alpha_descends_from_oldest_to_newest_when_full() -> void:
	# AC: row 0 (oldest) renders at ALPHA_OLDEST; the last row at 1.0;
	# intermediate rows interpolate linearly.
	var panel: StoreEventLogPanel = _make_panel()
	for i: int in range(StoreEventLogPanel.MAX_VISIBLE_ENTRIES):
		EventBus.event_logged.emit("[STOCK]", "Stocked item %d." % i)
	await get_tree().process_frame
	var oldest: float = panel.get_row_alpha(0)
	var newest: float = panel.get_row_alpha(
		StoreEventLogPanel.MAX_VISIBLE_ENTRIES - 1
	)
	assert_almost_eq(
		oldest, StoreEventLogPanel.ALPHA_OLDEST, 0.001,
		"Oldest visible row must sit at ALPHA_OLDEST (0.35)"
	)
	assert_almost_eq(
		newest, 1.0, 0.001,
		"Newest visible row must sit at full alpha"
	)
	# Monotonic interpolation — every step strictly increases.
	var prev: float = -1.0
	for i: int in range(StoreEventLogPanel.MAX_VISIBLE_ENTRIES):
		var a: float = panel.get_row_alpha(i)
		assert_gt(
			a, prev,
			"Row alpha must monotonically increase oldest -> newest (i=%d)" % i
		)
		prev = a


func test_alpha_recomputes_immediately_after_eviction() -> void:
	# AC: existing rows update their modulate.a immediately, not on the next
	# frame. After overflowing the cap the surviving oldest still reads at
	# ALPHA_OLDEST without waiting for any deferred refresh.
	var panel: StoreEventLogPanel = _make_panel()
	for i: int in range(StoreEventLogPanel.MAX_VISIBLE_ENTRIES + 3):
		EventBus.event_logged.emit("[STOCK]", "Stocked item %d." % i)
	assert_almost_eq(
		panel.get_row_alpha(0), StoreEventLogPanel.ALPHA_OLDEST, 0.001,
		"Oldest surviving row must sit at ALPHA_OLDEST right after eviction"
	)
	assert_almost_eq(
		panel.get_row_alpha(StoreEventLogPanel.MAX_VISIBLE_ENTRIES - 1),
		1.0,
		0.001,
		"Newest row must sit at 1.0 right after eviction"
	)


# ── tag-strip + tag color contract ────────────────────────────────────────────

func test_display_text_strips_bracket_tag_prefix() -> void:
	# AC: no visible row contains a bracket-wrapped tag like '[STOCK]'.
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.event_logged.emit("[STOCK]", "Stocked Crash Bandicoot 2.")
	await get_tree().process_frame
	var latest: String = panel.get_latest_row_text()
	assert_eq(
		latest, "Stocked Crash Bandicoot 2.",
		"Display text must drop the bracket-wrapped tag prefix"
	)
	assert_false(
		latest.find("[STOCK]") >= 0,
		"Visible row must not contain the literal '[STOCK]' token"
	)


func test_display_text_strips_redundant_message_tags() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.event_logged.emit("[STOCK]", "[STOCK] Stocked Crash Bandicoot 2.")
	await get_tree().process_frame
	var latest: String = panel.get_latest_row_text()
	assert_eq(
		latest, "Stocked Crash Bandicoot 2.",
		"Visible text must strip redundant bracket tags from message copy"
	)
	assert_false(
		latest.contains("["),
		"Visible row must not expose bracket metadata"
	)


func test_tag_colors_match_spec() -> void:
	# AC: TAG_COLORS covers STOCK (blue-teal), CUSTOMER (green),
	# DAY (amber/gold), SYSTEM (medium gray), OBJECTIVE (cyan).
	var panel: StoreEventLogPanel = _make_panel()
	assert_eq(
		panel.get_tag_color("STOCK"),
		Color(0.357, 0.722, 0.910, 1.0),
		"[STOCK] must render in soft blue"
	)
	assert_eq(
		panel.get_tag_color("CUSTOMER"),
		Color(0.561, 0.878, 0.459, 1.0),
		"[CUSTOMER] must render in soft green"
	)
	assert_eq(
		panel.get_tag_color("DAY"),
		Color(0.910, 0.647, 0.278, 1.0),
		"[DAY] must render in modal gold"
	)
	assert_eq(
		panel.get_tag_color("SYSTEM"),
		Color(0.722, 0.660, 0.549, 1.0),
		"[SYSTEM] must render in muted warm gray"
	)
	assert_eq(
		panel.get_tag_color("OBJECTIVE"),
		Color(0.957, 0.914, 0.831, 1.0),
		"[OBJECTIVE] must render in cream"
	)


func test_tag_color_accepts_bracketed_form() -> void:
	# Call sites that already have the bracketed token should not need to
	# unwrap it themselves.
	var panel: StoreEventLogPanel = _make_panel()
	assert_eq(
		panel.get_tag_color("[STOCK]"),
		panel.get_tag_color("STOCK"),
		"Bracketed lookup must resolve to the same color as the bare key"
	)


func test_unknown_tag_falls_back_to_near_white() -> void:
	# AC: entries with an unrecognized or missing tag fall back to near-white
	# — no crash, no blank row.
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.event_logged.emit("[NEWTHING]", "Surface me.")
	await get_tree().process_frame
	assert_eq(
		panel.get_visible_entry_count(), 1,
		"Unknown tags must still render"
	)
	var color: Color = panel.get_tag_color("NEWTHING")
	assert_almost_eq(color.r, 0.95, 0.001, "Unknown-tag color stays near-white (R)")
	assert_almost_eq(color.g, 0.95, 0.001, "Unknown-tag color stays near-white (G)")
	assert_almost_eq(color.b, 0.95, 0.001, "Unknown-tag color stays near-white (B)")


func test_debug_and_modal_tags_do_not_render_rows() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.event_logged.emit("[MODAL]", "Modal opened: CanvasLayer/DecisionCard.")
	EventBus.event_logged.emit("[DEBUG]", "FSM scan complete.")
	await get_tree().process_frame
	assert_eq(
		panel.get_visible_entry_count(), 0,
		"Diagnostic tags must stay out of the player-facing event log"
	)


# ── first-minute readability hierarchy ───────────────────────────────────────

func test_important_first_minute_tags_are_more_legible_than_passive_rows() -> void:
	var important_events: Array[Array] = [
		["[OBJECTIVE]", "Register ready."],
		["[STOCK]", "Stocked Crash Bandicoot 2."],
		["[DAY]", "First-day training started."],
		["[SYSTEM]", "Store is in pre-opening."],
	]
	for event: Array in important_events:
		var panel: StoreEventLogPanel = _make_panel()
		EventBus.event_logged.emit("[CUSTOMER]", "Customer left (satisfied).")
		EventBus.event_logged.emit(String(event[0]), String(event[1]))
		await get_tree().process_frame
		assert_gt(
			panel.get_row_font_size_for_test(1),
			panel.get_row_font_size_for_test(0),
			"%s beats must be larger than passive rows" % String(event[0])
		)
		assert_gt(
			panel.get_row_outline_size_for_test(1),
			panel.get_row_outline_size_for_test(0),
			"%s beats must have stronger outline" % String(event[0])
		)


func test_newest_row_keeps_readable_emphasis_after_later_passive_event() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.event_logged.emit("[DAY]", "First-day training started.")
	EventBus.event_logged.emit("[OBJECTIVE]", "Shelf stocked.")
	EventBus.event_logged.emit("[CUSTOMER]", "Customer left (satisfied).")
	await get_tree().process_frame
	assert_eq(
		panel.get_latest_row_text(), "Customer left (satisfied).",
		"Rows must stay ordered by arrival time"
	)
	assert_gte(
		panel.get_row_outline_size_for_test(2),
		StoreEventLogPanel._NEWEST_OUTLINE_SIZE,
		"Newest row must keep a readable outline even for passive history"
	)
	assert_lte(
		panel.get_visible_entry_count(),
		StoreEventLogPanel.MAX_VISIBLE_ENTRIES,
		"Event log must keep only the latest compact set of player-facing rows"
	)


func test_event_log_emphasis_stays_below_active_interaction_scale() -> void:
	assert_lte(
		StoreEventLogPanel._NEWEST_ENTRY_FONT_SIZE,
		13,
		"Recent history must stay below the active prompt/objective text scale"
	)
	assert_lte(
		StoreEventLogPanel._IMPORTANT_ENTRY_FONT_SIZE,
		StoreEventLogPanel._NEWEST_ENTRY_FONT_SIZE,
		"Important log rows must stay readable without outranking the newest beat"
	)


# ── modal-dim contract ────────────────────────────────────────────────────────

func test_panel_dims_under_modal_context() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	InputFocus.push_context(InputFocus.CTX_MODAL)
	await get_tree().process_frame
	var any_dimmed: bool = false
	for child: Node in panel.get_children():
		if child is CanvasItem and (child as CanvasItem).modulate.a < 1.0:
			any_dimmed = true
			break
	assert_true(
		any_dimmed,
		"Panel children must dim when CTX_MODAL is pushed"
	)
	InputFocus.pop_context()
	await get_tree().process_frame
	for child: Node in panel.get_children():
		if child is CanvasItem:
			assert_almost_eq(
				(child as CanvasItem).modulate.a, 1.0, 0.001,
				"Panel children must restore alpha when modal pops"
			)


# ── FP-mode ownership ─────────────────────────────────────────────────────────

func test_fp_mode_changed_does_not_hide_panel() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.fp_mode_changed.emit(true)
	await get_tree().process_frame
	assert_true(
		panel.visible,
		"Event log must remain visible in FP mode as the sole bottom-left event surface"
	)
	EventBus.fp_mode_changed.emit(false)
	await get_tree().process_frame
	assert_true(
		panel.visible,
		"Event log must remain visible when FP mode is disabled"
	)


func test_panel_does_not_connect_fp_mode_changed() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	var connections: Array = EventBus.fp_mode_changed.get_connections()
	for entry: Dictionary in connections:
		var callable: Callable = entry.get("callable") as Callable
		assert_ne(
			callable.get_object(), panel,
			"StoreEventLogPanel must not connect to fp_mode_changed"
		)


# ── EventLog → event_logged bridge ────────────────────────────────────────────

func test_event_log_record_broadcasts_event_logged() -> void:
	# AC: 'The surface subscribes to EventBus.event_logged(tag, message)'.
	# EventLog._record must emit player-facing beats so a release build still
	# drives the panel even though the ring buffer is debug-only.
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.item_stocked.emit("crash_2", "shelf_a")
	await get_tree().process_frame
	assert_gt(
		panel.get_visible_entry_count(), 0,
		"EventLog must broadcast event_logged so the panel renders"
	)
	var latest: String = panel.get_latest_row_text()
	assert_false(
		latest.is_empty(),
		"Latest row must carry the message body after the prefix strip"
	)
	assert_false(
		latest.find("[STOCK]") >= 0,
		"Display label must strip the bracket-wrapped tag prefix; got '%s'" % latest
	)


func test_event_log_filters_debug_entries_before_panel() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	var customer: Node = Node.new()
	add_child_autofree(customer)
	EventBus.modal_opened.emit(&"CanvasLayer/DecisionCard")
	EventBus.customer_state_changed.emit(customer, Customer.State.BROWSING)
	await get_tree().process_frame
	assert_eq(
		panel.get_visible_entry_count(), 0,
		"Panel must not render modal or customer-FSM debug rows"
	)
	EventBus.objective_completed.emit(&"talk_to_customer", "Customer served.")
	await get_tree().process_frame
	assert_eq(
		panel.get_visible_entry_count(), 1,
		"Panel must still render player-facing activity rows"
	)
	assert_eq(panel.get_latest_row_text(), "Customer served.")


func test_event_log_lifecycle_rows_use_player_facing_shift_copy() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	EventBus.day_started.emit(1)
	EventBus.gameplay_ready.emit()
	await get_tree().process_frame
	assert_eq(panel.get_visible_entry_count(), 2)
	assert_eq(
		panel.get_row_text_for_test(0),
		"First-day training started.",
		"Day startup row must not expose raw Day 1 lifecycle copy"
	)
	assert_eq(
		panel.get_latest_row_text(),
		"Store is in pre-opening.",
		"Gameplay-ready row must read as player-facing pre-opening status"
	)
	assert_false(panel.get_latest_row_text().contains("Game started"))


# ── width / layout contract ───────────────────────────────────────────────────

func test_background_is_constrained_to_content_width() -> void:
	# AC: the panel's dark background must sit inside the compact content
	# anchor — never spanning the full viewport width. Otherwise the bottom
	# of the screen reads as a single fused console with the interaction
	# prompt.
	var panel: StoreEventLogPanel = _make_panel()
	await get_tree().process_frame
	var anchor: Control = panel.get_node("Anchor") as Control
	assert_not_null(anchor, "Panel must own a sized Anchor control")
	# Anchor footprint matches the compact panel width — anchors collapsed
	# (left == right) so the size comes from offsets alone.
	assert_eq(
		anchor.anchor_left, anchor.anchor_right,
		"Anchor must use collapsed anchors so width is offset-driven"
	)
	var anchor_width: float = anchor.offset_right - anchor.offset_left
	assert_almost_eq(
		anchor_width, StoreEventLogPanel._PANEL_WIDTH, 0.5,
		"Anchor width (%.0fpx) must match the compact panel content width"
			% anchor_width
	)
	var background: ColorRect = anchor.get_node("Background") as ColorRect
	assert_not_null(background, "Anchor must contain the panel background ColorRect")
	# Background fills the parent Anchor, not the viewport — bounded by the
	# compact anchor footprint above.
	assert_eq(background.anchor_left, 0.0)
	assert_eq(background.anchor_right, 1.0)
	assert_eq(
		background.get_parent(), anchor,
		"Background must be parented to the compact Anchor, not the CanvasLayer root"
	)


func test_panel_footprint_stays_compact_for_fp_view() -> void:
	assert_lte(
		StoreEventLogPanel._PANEL_WIDTH,
		248.0,
		"Event log must stay narrow enough for the bottom-left safe zone"
	)
	assert_lte(
		StoreEventLogPanel._PANEL_HEIGHT,
		90.0,
		"Event log must stay short enough to avoid becoming a second panel"
	)


func test_panel_stops_above_carry_label_safe_zone() -> void:
	var panel: StoreEventLogPanel = _make_panel()
	await get_tree().process_frame
	var anchor: Control = panel.get_node("Anchor") as Control
	assert_lte(
		anchor.offset_bottom,
		-204.0,
		"Event log must leave visible clearance above the carry HUD label"
	)
