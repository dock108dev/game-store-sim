## Regression coverage for shared decision-panel content grammar.
extends GutTest

const CHECKOUT_PANEL_SCENE: PackedScene = preload(
	"res://game/scenes/ui/checkout_panel.tscn"
)
const INVENTORY_PANEL_SCENE: PackedScene = preload(
	"res://game/scenes/ui/inventory_panel.tscn"
)
const BACK_ROOM_PANEL_SCENE: PackedScene = preload(
	"res://game/scenes/ui/back_room_inventory_panel.tscn"
)
const DecisionPanelStyle = preload("res://game/scripts/ui/decision_panel_style.gd")


class BackRoomAuditStub:
	extends RefCounted

	func get_inventory_audit_rows() -> Array:
		return [
			{
				"item_id": "cart_a",
				"item_name": "Trade-In Cart",
				"expected": 2,
				"actual": 1,
				"mismatched": true,
				"flagged": false,
			},
			{
				"item_id": "cart_b",
				"item_name": "Clean Shelf",
				"expected": 1,
				"actual": 1,
				"mismatched": false,
				"flagged": false,
			},
		]

	func flag_discrepancy(
		_item_id: StringName, _expected: int, _actual: int
	) -> bool:
		return true


class BackRoomControllerStub:
	extends RefCounted

	var audit: BackRoomAuditStub = BackRoomAuditStub.new()


func before_each() -> void:
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()


func after_each() -> void:
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()


func test_decision_panel_names_are_string_names() -> void:
	assert_eq(typeof(PricingPanel.PANEL_NAME), TYPE_STRING_NAME)
	assert_eq(typeof(CheckoutPanel.PANEL_NAME), TYPE_STRING_NAME)
	assert_eq(typeof(InventoryPanel.PANEL_NAME), TYPE_STRING_NAME)
	assert_eq(typeof(BackRoomInventoryPanel.PANEL_NAME), TYPE_STRING_NAME)
	assert_eq(typeof(FixtureCatalogPanel.PANEL_NAME), TYPE_STRING_NAME)


func test_shared_status_colors_match_equivalent_panel_states() -> void:
	assert_eq(
		DecisionPanelStyle.status_color(&"ok"),
		UIThemeConstants.get_positive_color()
	)
	assert_eq(
		DecisionPanelStyle.status_color(&"mismatch"),
		UIThemeConstants.get_negative_color()
	)
	assert_eq(
		DecisionPanelStyle.money_delta_color(25.0),
		UIThemeConstants.SEMANTIC_MONEY_GAIN
	)
	assert_eq(
		DecisionPanelStyle.money_delta_color(-25.0),
		UIThemeConstants.SEMANTIC_MONEY_COST
	)


func test_inventory_tabs_use_shared_active_tab_style() -> void:
	var panel: InventoryPanel = (
		INVENTORY_PANEL_SCENE.instantiate() as InventoryPanel
	)
	add_child_autofree(panel)

	var expected: Color = UIThemeConstants.get_store_accent(
		StringName(panel.store_id)
	)
	assert_eq(
		panel._backroom_tab.modulate,
		expected,
		"Active inventory tab should use the shared store accent"
	)
	assert_eq(
		panel._shelves_tab.modulate,
		Color.WHITE,
		"Inactive inventory tab should remain neutral"
	)


func test_stockroom_table_uses_shared_status_rows() -> void:
	var panel: BackRoomInventoryPanel = (
		BACK_ROOM_PANEL_SCENE.instantiate() as BackRoomInventoryPanel
	)
	panel.set_controller(BackRoomControllerStub.new())
	add_child_autofree(panel)
	await get_tree().process_frame

	var header: Label = _find_label_with_text(panel, "Item")
	var mismatch_value: Label = _find_label_with_text(panel, "1")
	var ok_label: Label = _find_label_with_text(panel, "OK")

	assert_not_null(header)
	assert_not_null(mismatch_value)
	assert_not_null(ok_label)
	assert_eq(
		header.get_theme_color("font_color"),
		UIThemeConstants.ACCENT_COLOR_AMBER
	)
	assert_eq(
		ok_label.get_theme_color("font_color"),
		UIThemeConstants.get_positive_color()
	)


func test_checkout_content_keeps_modal_decision_grammar() -> void:
	var panel: CheckoutPanel = (
		CHECKOUT_PANEL_SCENE.instantiate() as CheckoutPanel
	)
	add_child_autofree(panel)
	InputFocus.push_context(InputFocus.CTX_STORE_GAMEPLAY)

	panel.show_checkout([{
		"item_name": "Trade-In Cart",
		"condition": "Good",
		"price": 19.99,
	}])
	panel.populate_customer_card({
		"archetype_id": &"collector",
		"archetype_label": "Collector",
		"want": "Wants a clean shelf copy.",
		"context": "Checking condition before buying.",
		"offer_price": 19.99,
		"sticker_price": 19.99,
	})
	await get_tree().process_frame

	assert_true(panel.is_open())
	assert_eq(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_true(_has_visible_text(panel, "Wants a clean shelf copy."))
	assert_true(_has_visible_text(panel, "19.99"))
	assert_false(
		WorkSurfaceLayout.rects_overlap(
			WorkSurfaceLayout.first_person_work_rect(Vector2(1280, 720)),
			WorkSurfaceLayout.panel_reserved_rect(
				WorkSurfaceLayout.PANEL_CHECKOUT, Vector2(1280, 720)
			),
		),
		"Checkout reservation should not occlude the authored work surface"
	)

	panel.hide_checkout(true)
	assert_false(panel.is_open())


func _find_label_with_text(root: Node, text: String) -> Label:
	for node: Node in _walk(root):
		if node is Label and (node as Label).text == text:
			return node as Label
	return null


func _has_visible_text(root: Node, needle: String) -> bool:
	for node: Node in _walk(root):
		if node is Control and not (node as Control).visible:
			continue
		if node is Label and (node as Label).text.contains(needle):
			return true
		if node is RichTextLabel and (node as RichTextLabel).text.contains(needle):
			return true
		if node is Button and (node as Button).text.contains(needle):
			return true
	return false


func _walk(root: Node) -> Array[Node]:
	var out: Array[Node] = [root]
	var index: int = 0
	while index < out.size():
		var node: Node = out[index]
		for child: Node in node.get_children():
			out.append(child)
		index += 1
	return out
