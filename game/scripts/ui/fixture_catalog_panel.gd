class_name FixtureCatalogPanel
extends CanvasLayer
const FixtureSilhouetteViewScript = preload("res://game/scripts/ui/fixture_silhouette_view.gd")
const PlacementReasonTextScript = preload("res://game/resources/placement_reason_text.gd")
const CatalogEffectMetadataScript = preload("res://game/resources/catalog_effect_metadata.gd")
const StoreDesignCatalogScript = preload("res://game/scripts/systems/store_design_catalog.gd")
const DecisionPanelStyle = preload("res://game/scripts/ui/decision_panel_style.gd")
const PANEL_NAME: StringName = &"fixture_catalog"
const PLACE_BUTTON_TEXT: String = "Place"
const SELECTED_BUTTON_TEXT: String = "Selected"
const LOCKED_BUTTON_TEXT: String = "Locked"
const UNAFFORDABLE_BUTTON_TEXT: String = "Need Cash"
const LIMIT_BUTTON_TEXT: String = "Limit Hit"
const APPLY_BUTTON_TEXT: String = "Apply"
const LOCKED_COLOR: Color = Color(0.722, 0.659, 0.549, 0.72)
const UNAFFORDABLE_COLOR: Color = Color(1.0, 0.706, 0.659, 0.9)
const SELECTED_COLOR: Color = Color(0.427, 0.812, 0.353, 1.0)
const PLACEABLE_COLOR: Color = Color.WHITE
const PLACEMENT_PUNCH_SCALE: float = 1.08
const PLACEMENT_PUNCH_DURATION: float = 0.2
const DEFAULT_TAB: StringName = &"fixtures"
const _TAB_LABELS: Dictionary = {
	&"fixtures": "Fixtures",
	&"shelves": "Shelves",
	&"counters": "Counters",
	&"signage": "Signage",
	&"decor": "Decor",
	&"surfaces": "Surfaces",
	&"lighting": "Lighting",
	&"stockroom": "Stockroom",
}
const _TAB_ORDER: Array[StringName] = [&"fixtures", &"shelves", &"counters", &"signage", &"decor", &"surfaces", &"lighting", &"stockroom"]
var data_loader: DataLoader
var economy_system: EconomySystem
var placement_system: FixturePlacementSystem
var build_mode_system: BuildModeSystem
var store_type: StringName = &""
var _is_open: bool = false
var _selected_fixture_id: StringName = &""
var _active_category_tab: StringName = DEFAULT_TAB
var _fixtures_by_tab: Dictionary = {}
var _tab_buttons: Dictionary = {}
var _anim_tween: Tween
var _feedback_tween: Tween
var _rest_x: float = 0.0
var _current_day_snapshot: int = 1
var _card_buttons: Dictionary = {}
var _card_panels: Dictionary = {}
var _card_status_labels: Dictionary = {}
@onready var _panel: PanelContainer = $PanelRoot
@onready var _close_button: Button = $PanelRoot/Margin/VBox/Header/CloseButton
@onready var _cash_label: Label = $PanelRoot/Margin/VBox/Header/CashLabel
@onready var _category_tabs: HBoxContainer = $PanelRoot/Margin/VBox/CategoryTabs
@onready var _catalog_grid: GridContainer = $PanelRoot/Margin/VBox/CatalogScroll/CatalogGrid
@onready var _place_button: Button = $PanelRoot/Margin/VBox/ActionControls/PlaceButton
@onready var _move_button: Button = $PanelRoot/Margin/VBox/ActionControls/MoveButton
@onready var _rotate_button: Button = $PanelRoot/Margin/VBox/ActionControls/RotateButton
@onready var _sell_button: Button = $PanelRoot/Margin/VBox/ActionControls/SellButton
@onready var _back_button: Button = $PanelRoot/Margin/VBox/ActionControls/BackButton
@onready var _info_label: Label = $PanelRoot/Margin/VBox/InfoLabel
func _ready() -> void:
	_panel.visible = false
	_rest_x = _panel.position.x
	_close_button.pressed.connect(close)
	DecisionPanelStyle.apply_header_label(
		$PanelRoot/Margin/VBox/Header/TitleLabel
	)
	DecisionPanelStyle.apply_action_button(_place_button, true)
	DecisionPanelStyle.apply_action_button(_move_button)
	DecisionPanelStyle.apply_action_button(_rotate_button)
	DecisionPanelStyle.apply_action_button(_sell_button)
	DecisionPanelStyle.apply_action_button(_back_button)
	_place_button.pressed.connect(_on_place_control_pressed)
	_rotate_button.pressed.connect(_on_rotate_control_pressed)
	_back_button.pressed.connect(_on_back_control_pressed)
	EventBus.panel_opened.connect(_on_panel_opened)
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.build_mode_entered.connect(_on_build_mode_entered)
	EventBus.build_mode_exited.connect(_on_build_mode_exited)
	EventBus.fixture_placed.connect(_on_fixture_placed)
	EventBus.fixture_removed.connect(_on_fixture_removed)
	EventBus.fixture_placement_invalid.connect(_on_fixture_placement_invalid)
	EventBus.active_store_changed.connect(_on_active_store_changed)
	EventBus.reputation_changed.connect(_on_reputation_changed)
	_update_action_controls("idle")
## Opens the fixture catalog and refreshes available fixtures.
func open() -> void:
	if _is_open:
		return
	if data_loader == null:
		push_warning("FixtureCatalogPanel: missing data_loader")
		return
	var active_store_id: StringName = _get_active_store_id()
	if active_store_id.is_empty():
		push_warning("FixtureCatalogPanel: missing active store")
		return
	_is_open = true
	_selected_fixture_id = &""
	_sync_runtime_state()
	_update_cash_display()
	_refresh_catalog()
	_update_info_label()
	PanelAnimator.kill_tween(_anim_tween)
	_anim_tween = PanelAnimator.slide_open(_panel, _rest_x, false)
	EventBus.panel_opened.emit(PANEL_NAME)
## Closes the fixture catalog.
func close(immediate: bool = false) -> void:
	if not _is_open:
		return
	_is_open = false
	_selected_fixture_id = &""
	PanelAnimator.kill_tween(_anim_tween)
	if immediate:
		_panel.visible = false
		_panel.position.x = _rest_x
	else:
		_anim_tween = PanelAnimator.slide_close(_panel, _rest_x, false)
	EventBus.panel_closed.emit(PANEL_NAME)
	_update_info_label()
## Returns true when the panel is currently open.
func is_open() -> bool:
	return _is_open
func _refresh_catalog() -> void:
	_card_buttons.clear()
	_card_panels.clear()
	_card_status_labels.clear()
	var fixtures: Array[FixtureDefinition] = data_loader.get_fixtures_for_store(
		String(_get_active_store_id())
	)
	fixtures.sort_custom(_sort_fixture_definitions)
	_build_category_tabs(fixtures)
	_refresh_visible_tab()
	_update_selection_state()
func _build_category_tabs(fixtures: Array[FixtureDefinition]) -> void:
	_fixtures_by_tab.clear()
	for tab: StringName in _TAB_ORDER:
		_fixtures_by_tab[tab] = []
	for fixture: FixtureDefinition in fixtures:
		var tab: StringName = _get_fixture_tab_id(fixture)
		(_fixtures_by_tab[tab] as Array).append(fixture)
	for option: Dictionary in StoreCustomizationSystem.get_design_options_for_day(
		_current_day_snapshot
	):
		(_fixtures_by_tab[option["category"]] as Array).append(option)
	_clear_children(_category_tabs)
	_tab_buttons.clear()
	for tab: StringName in _TAB_ORDER:
		if (_fixtures_by_tab[tab] as Array).is_empty():
			continue
		var button := Button.new()
		button.name = "%sTab" % String(tab).capitalize()
		button.text = _TAB_LABELS[tab]
		button.toggle_mode = true
		button.pressed.connect(_set_active_category_tab.bind(tab))
		_category_tabs.add_child(button)
		_tab_buttons[tab] = button
	if not _tab_buttons.has(_active_category_tab):
		_active_category_tab = DEFAULT_TAB
	_update_tab_buttons()
func _set_active_category_tab(tab_id: StringName) -> void:
	_active_category_tab = tab_id
	_update_tab_buttons()
	_refresh_visible_tab()
func _refresh_visible_tab() -> void:
	_clear_children(_catalog_grid)
	var entries: Array = _fixtures_by_tab.get(_active_category_tab, [])
	for entry: Variant in entries:
		if entry is FixtureDefinition:
			_catalog_grid.add_child(_create_fixture_card(entry as FixtureDefinition))
		elif entry is Dictionary:
			_catalog_grid.add_child(_create_design_card(entry as Dictionary))
	_update_selection_state()
func _create_fixture_card(fixture: FixtureDefinition) -> Control:
	var card := _new_card("%sCard" % fixture.id)
	var body: VBoxContainer = card.get_node("Margin/Body")
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	body.add_child(header)
	var state: Dictionary = _get_fixture_catalog_state(fixture)
	var silhouette := FixtureSilhouetteViewScript.new()
	silhouette.name = "SilhouetteView"
	silhouette.configure(fixture, state["state"] == "locked")
	header.add_child(silhouette)
	header.add_child(_build_title_block(fixture))
	body.add_child(_build_detail_label("OwnedLabel", _owned_text(fixture)))
	body.add_child(_build_detail_label("CapacityLabel", "Capacity: %s" % fixture.get_capacity_label_text()))
	body.add_child(_build_detail_label("EffectLabel", "Effects: %s" % fixture.get_effect_summary_text()))
	body.add_child(_build_detail_label("FootprintLabel", _footprint_text(fixture)))
	_add_card_footer(body, card, fixture.id, state)
	_apply_fixture_state(card, state)
	return card
func _create_design_card(option: Dictionary) -> Control:
	var card := _new_card("%sCard" % str(option["id"]))
	var body: VBoxContainer = card.get_node("Margin/Body")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	body.add_child(row)
	var swatch := ColorRect.new()
	swatch.name = "SurfaceSwatch"
	swatch.custom_minimum_size = Vector2(56.0, 56.0)
	swatch.color = option["color"]
	row.add_child(swatch)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(column)
	column.add_child(_build_named_label("NameLabel", str(option["name"])))
	column.add_child(_build_named_label("PriceLabel", "Price: $%.0f" % float(option["cost"])))
	body.add_child(_build_detail_label("CapacityLabel", "Surface: %s" % str(option["surface"])))
	body.add_child(_build_detail_label("EffectLabel", "Effects: %s" % _design_effect_text(option)))
	body.add_child(_build_detail_label("FootprintLabel", "Applies to store design"))
	var state := _get_design_state(option)
	_add_card_footer(body, card, str(option["id"]), state)
	_apply_fixture_state(card, state)
	return card
func _new_card(card_name: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = card_name
	card.custom_minimum_size = Vector2(260.0, 184.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin := MarginContainer.new()
	margin.name = "Margin"
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 8)
	card.add_child(margin)
	var body := VBoxContainer.new()
	body.name = "Body"
	body.add_theme_constant_override("separation", 5)
	margin.add_child(body)
	return card
func _build_title_block(fixture: FixtureDefinition) -> Control:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 2)
	column.add_child(_build_named_label("NameLabel", fixture.display_name))
	column.add_child(_build_named_label("PriceLabel", "Price: $%.0f" % fixture.cost))
	return column
func _add_card_footer(body: VBoxContainer, card: PanelContainer, id: String, state: Dictionary) -> void:
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	body.add_child(footer)
	var status := _build_detail_label("StatusLabel", state["text"])
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	DecisionPanelStyle.apply_status_label(status, StringName(state["state"]))
	footer.add_child(status)
	var button := Button.new()
	button.name = "SelectButton"
	button.custom_minimum_size = Vector2(92.0, 32.0)
	button.text = state["button"]
	button.disabled = state["disabled"]
	DecisionPanelStyle.apply_action_button(button, state["state"] == "ready")
	if not button.disabled:
		button.pressed.connect(_on_fixture_requested.bind(id))
	footer.add_child(button)
	_card_buttons[id] = button
	_card_panels[id] = card
	_card_status_labels[id] = status
func _build_named_label(label_name: String, text: String) -> Label:
	var label := Label.new()
	label.name = label_name
	label.text = text
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return label
func _build_detail_label(label_name: String, text: String) -> Label:
	var label := _build_named_label(label_name, text)
	label.modulate = Color(0.76, 0.76, 0.76)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
func _get_fixture_catalog_state(fixture: FixtureDefinition) -> Dictionary:
	var owned_count: int = _get_owned_count(fixture.id)
	if _is_fixture_locked(fixture):
		return _state("locked", "Locked · %s" % _get_unlock_tooltip(fixture), LOCKED_BUTTON_TEXT, true)
	if fixture.owned_limit > 0 and owned_count >= fixture.owned_limit:
		return _state("limit", "Limit reached · %d owned" % owned_count, LIMIT_BUTTON_TEXT, true)
	if fixture.cost > _get_current_cash():
		return _state("unaffordable", "Need $%.0f more" % (fixture.cost - _get_current_cash()), UNAFFORDABLE_BUTTON_TEXT, true)
	if fixture.id == String(_selected_fixture_id):
		return _state("selected", "Selected for placement", SELECTED_BUTTON_TEXT, false)
	return _state("ready", "Ready to place", PLACE_BUTTON_TEXT, false)
func _get_design_state(option: Dictionary) -> Dictionary:
	var status: String = str(option.get("status", "ready"))
	if status == "locked":
		return _state("locked", "Locked · %s" % str(option.get("unlock", "Unavailable")), LOCKED_BUTTON_TEXT, true)
	if float(option["cost"]) > _get_current_cash():
		return _state("unaffordable", "Need $%.0f more" % (float(option["cost"]) - _get_current_cash()), UNAFFORDABLE_BUTTON_TEXT, true)
	if status == "selected":
		return _state("selected", "Selected finish", SELECTED_BUTTON_TEXT, true)
	return _state("ready", "Ready to apply", APPLY_BUTTON_TEXT, false)
func _state(id: String, text: String, button: String, disabled: bool) -> Dictionary:
	return {"state": id, "text": text, "button": button, "disabled": disabled}
func _apply_fixture_state(card: PanelContainer, state: Dictionary) -> void:
	card.modulate = DecisionPanelStyle.catalog_card_modulate(
		StringName(state["state"])
	)
	card.tooltip_text = state["text"]
func _get_fixture_tab_id(fixture: FixtureDefinition) -> StringName:
	var tab := StringName(fixture.catalog_category)
	if tab.is_empty():
		tab = StringName(fixture.visual_category)
	if not _TAB_LABELS.has(tab):
		return DEFAULT_TAB
	return tab
func _owned_text(fixture: FixtureDefinition) -> String:
	var limit: String = "" if fixture.owned_limit <= 0 else " / %d" % fixture.owned_limit
	return "Owned: %d%s" % [_get_owned_count(fixture.id), limit]
func _footprint_text(fixture: FixtureDefinition) -> String:
	var parts: PackedStringArray = ["Footprint: %d cells" % fixture.footprint_cells.size()]
	parts.append("Wall" if fixture.requires_wall else "Floor")
	parts.append("Rotates" if fixture.rotation_support else "Fixed")
	parts.append("Sell-back: $%.0f" % fixture.get_sellback_price())
	return " · ".join(parts)
func _get_unlock_tooltip(fixture: FixtureDefinition) -> String:
	var conditions: PackedStringArray = []
	if fixture.unlock_rep > 0.0:
		conditions.append("Reputation %.0f required" % fixture.unlock_rep)
	if fixture.unlock_day > 0:
		conditions.append("Day %d required" % fixture.unlock_day)
	if conditions.is_empty():
		return "Locked"
	return ", ".join(conditions)
func _is_fixture_locked(fixture: FixtureDefinition) -> bool:
	return (
		(fixture.unlock_rep > 0.0 and _get_current_reputation() < fixture.unlock_rep)
		or (fixture.unlock_day > 0 and _current_day_snapshot < fixture.unlock_day)
	)
func _on_fixture_requested(id: String) -> void:
	var fixture: FixtureDefinition = data_loader.get_fixture(id)
	if _card_panels.has(id) and fixture == null:
		_apply_design_selection(id)
		return
	_selected_fixture_id = StringName(id)
	_update_selection_state()
	_update_info_label()
	EventBus.fixture_catalog_requested.emit(id)
func _update_selection_state() -> void:
	for id_value: Variant in _card_buttons.keys():
		var id: String = str(id_value)
		var fixture: FixtureDefinition = data_loader.get_fixture(id)
		if fixture == null:
			continue
		var state: Dictionary = _get_fixture_catalog_state(fixture)
		var button := _card_buttons[id] as Button
		var card := _card_panels[id] as PanelContainer
		var status := _card_status_labels[id] as Label
		if button:
			button.text = state["button"]
		if status:
			status.text = state["text"]
			DecisionPanelStyle.apply_status_label(
				status, StringName(state["state"])
			)
		if card:
			_apply_fixture_state(card, state)
	_update_action_controls("selected" if not _selected_fixture_id.is_empty() else "idle")
func _update_action_controls(state: String) -> void:
	var has_selection: bool = state == "selected"
	_place_button.disabled = not has_selection
	_rotate_button.disabled = not has_selection
	_move_button.disabled = true
	_sell_button.disabled = true
	_place_button.text = "Place" if not has_selection else "Place on Grid"
	_move_button.tooltip_text = "Select an existing fixture in the grid to move it"
	_sell_button.tooltip_text = "Right-click a placed fixture to sell it"
	_back_button.text = "Cancel" if has_selection else "Back"
func _update_info_label() -> void:
	if _selected_fixture_id.is_empty():
		_info_label.text = "Select an item, then use place, move, rotate, sell, or back controls"
		return
	var fixture: FixtureDefinition = data_loader.get_fixture(String(_selected_fixture_id))
	_info_label.text = "Placing: %s" % (
		fixture.display_name if fixture else String(_selected_fixture_id)
	)
func _get_owned_count(fixture_type: String) -> int:
	if placement_system == null:
		return 0
	var count: int = 0
	for entry: Dictionary in placement_system.get_placed_fixtures():
		if str(entry.get("fixture_type", "")) == fixture_type:
			count += 1
	return count
func _get_current_cash() -> float:
	return economy_system.get_cash() if economy_system else 0.0
func _get_current_reputation() -> float:
	if not is_instance_valid(ReputationSystemSingleton):
		return ReputationSystem.DEFAULT_REPUTATION
	return ReputationSystemSingleton.get_reputation(String(_get_active_store_id()))
func _get_active_store_id() -> StringName:
	var candidate: String = String(store_type)
	if candidate.is_empty():
		candidate = String(GameManager.get_active_store_id())
	if candidate.is_empty():
		return &""
	var resolved: StringName = ContentRegistry.resolve(candidate)
	return resolved if not resolved.is_empty() else StringName(candidate)
func _sync_runtime_state() -> void:
	var time_system: TimeSystem = GameManager.get_time_system()
	_current_day_snapshot = time_system.current_day if time_system else 1
func _sort_fixture_definitions(left: FixtureDefinition, right: FixtureDefinition) -> bool:
	if left.catalog_sort != right.catalog_sort:
		return left.catalog_sort < right.catalog_sort
	return left.display_name.naturalnocasecmp_to(right.display_name) < 0
func _update_cash_display() -> void:
	_cash_label.text = "Cash: $%.0f" % _get_current_cash()
func _update_tab_buttons() -> void:
	var accent: Color = UIThemeConstants.get_store_accent(_get_active_store_id())
	for tab: StringName in _tab_buttons:
		var button := _tab_buttons[tab] as Button
		button.button_pressed = tab == _active_category_tab
		DecisionPanelStyle.apply_tab_button(button, button.button_pressed, accent)
func _clear_children(node: Node) -> void:
	for child: Node in node.get_children():
		child.queue_free()
func _on_place_control_pressed() -> void:
	if not _selected_fixture_id.is_empty():
		EventBus.fixture_catalog_requested.emit(String(_selected_fixture_id))


func _apply_design_selection(id: String) -> void:
	var option: Dictionary = StoreDesignCatalogScript.get_option(id)
	if option.is_empty():
		_info_label.text = "Design selection unavailable: %s" % id.capitalize()
		return
	if StoreCustomizationSystem.get_design_option_status(id, _current_day_snapshot) == "locked":
		_info_label.text = "Design selection locked: %s" % str(option.get("name", id))
		return
	var cost: float = float(option.get("cost", 0.0))
	if cost > 0.0 and economy_system:
		if not economy_system.deduct_cash(cost, "Store design: %s" % id):
			_info_label.text = "Need more cash for %s" % str(option.get("name", id))
			_refresh_catalog()
			return
	var applied: bool = false
	if build_mode_system:
		applied = build_mode_system.apply_design_option(
			StringName(id), _current_day_snapshot
		)
	else:
		applied = StoreCustomizationSystem.apply_design_option(
			StringName(id), _current_day_snapshot, _get_active_store_id()
		)
	if applied:
		_update_cash_display()
		_refresh_catalog()
		_info_label.text = "Applied: %s" % str(option.get("name", id))


func _design_effect_text(option: Dictionary) -> String:
	var effects: Array[Dictionary] = []
	effects.assign(option.get("effects", []))
	if not str(option.get("effect_summary", "")).is_empty():
		return str(option.get("effect_summary", ""))
	return ", ".join(CatalogEffectMetadataScript.labels_for_effects(effects))
func _on_rotate_control_pressed() -> void:
	if build_mode_system:
		build_mode_system.rotate_selected_fixture()
	_info_label.text = "Rotating placement preview"
func _on_back_control_pressed() -> void:
	if not _selected_fixture_id.is_empty():
		_selected_fixture_id = &""
		if build_mode_system:
			build_mode_system.deselect_fixture()
		_update_selection_state()
		_update_info_label()
		return
	close()
func _on_panel_opened(panel_name: String) -> void:
	if panel_name != PANEL_NAME and _is_open:
		close(true)
func _on_money_changed(_old_amount: float, _new_amount: float) -> void:
	if _is_open:
		_update_cash_display()
		_refresh_catalog()
func _on_reputation_changed(store_id: String, _old_score: float, _new_score: float) -> void:
	if _is_open and ContentRegistry.resolve(store_id) == _get_active_store_id():
		_refresh_catalog()
func _on_active_store_changed(new_store_id: StringName) -> void:
	store_type = new_store_id
	if not _is_open:
		return
	if new_store_id.is_empty():
		close(true)
		return
	_refresh_catalog()
	_update_info_label()
func _on_build_mode_entered() -> void:
	_sync_runtime_state()
	open()
func _on_build_mode_exited() -> void:
	PanelAnimator.kill_tween(_anim_tween)
	if _is_open:
		close()
		return
	_panel.visible = false
	_panel.position.x = _rest_x
	_selected_fixture_id = &""
	_update_info_label()
func _on_fixture_placed(_fixture_id: String, _grid_pos: Vector2i, _rotation: int) -> void:
	if not _is_open:
		return
	PanelAnimator.kill_tween(_feedback_tween)
	_feedback_tween = PanelAnimator.pulse_scale(
		_panel, PLACEMENT_PUNCH_SCALE, PLACEMENT_PUNCH_DURATION
	)
	_refresh_catalog()
	_info_label.text = "Placed. Select, move, rotate, sell, or back out."
func _on_fixture_removed(_fixture_id: String, _grid_pos: Vector2i) -> void:
	if _is_open:
		_refresh_catalog()
func _on_fixture_placement_invalid(reason: String) -> void:
	if not _is_open:
		return
	PanelAnimator.kill_tween(_feedback_tween)
	PanelAnimator.shake(_panel)
	_feedback_tween = PanelAnimator.flash_color(
		_panel, UIThemeConstants.get_negative_color(), PanelAnimator.FEEDBACK_SHAKE_DURATION
	)
	_info_label.text = "Invalid placement: %s" % PlacementReasonTextScript.get_text(reason)
