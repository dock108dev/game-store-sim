extends GutTest

const HUD_SCENE: PackedScene = preload("res://game/scenes/ui/hud.tscn")
const CHECKOUT_PANEL_SCENE: PackedScene = preload(
	"res://game/scenes/ui/checkout_panel.tscn"
)
const SAVE_LOAD_PANEL_SCENE: PackedScene = preload(
	"res://game/scenes/ui/save_load_panel.tscn"
)
const BACK_ROOM_PANEL_SCENE: PackedScene = preload(
	"res://game/scenes/ui/back_room_inventory_panel.tscn"
)
const TUTORIAL_OVERLAY_SCENE: PackedScene = preload(
	"res://game/scenes/ui/tutorial_overlay.tscn"
)
const INTERACTION_PROMPT_SCENE: PackedScene = preload(
	"res://game/scenes/ui/interaction_prompt.tscn"
)
const SHELF_SLOT_SCENE: PackedScene = preload(
	"res://game/scenes/stores/components/shelf_slot.tscn"
)
const CUSTOMER_NPC_SCENE: PackedScene = preload(
	"res://game/scenes/characters/customer_npc.tscn"
)
const DECISION_CARD_SCRIPT: GDScript = preload(
	"res://game/scripts/store_session/decision_card_panel.gd"
)

var _saved_game_state: GameManager.State
var _saved_tutorial_active: bool


class BackRoomAuditStub:
	extends RefCounted

	var flagged: bool = false

	func get_inventory_audit_rows() -> Array:
		return [{
			"item_id": "cart_a",
			"item_name": "Trade-In Cart",
			"expected": 2,
			"actual": 1,
			"mismatched": true,
			"flagged": flagged,
		}]

	func flag_discrepancy(
		_item_id: StringName,
		_expected: int,
		_actual: int
	) -> bool:
		if flagged:
			return false
		flagged = true
		return true


class BackRoomControllerStub:
	extends RefCounted

	var audit: BackRoomAuditStub

	func _init(audit_stub: BackRoomAuditStub) -> void:
		audit = audit_stub


func before_each() -> void:
	_saved_game_state = GameManager.current_state
	_saved_tutorial_active = GameManager.is_tutorial_active
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()


func after_each() -> void:
	GameManager.current_state = _saved_game_state
	GameManager.is_tutorial_active = _saved_tutorial_active
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()
	UserDataPaths.cleanup_active_test_run()
	UserDataPaths.reset_for_normal_play()


func test_hud_scene_renders_public_status_labels() -> void:
	GameManager.current_state = GameManager.State.GAMEPLAY
	var hud: CanvasLayer = HUD_SCENE.instantiate()
	add_child_autofree(hud)

	EventBus.money_changed.emit(0.0, 275.0)
	EventBus.day_started.emit(3)
	EventBus.hour_changed.emit(14)
	await get_tree().create_timer(0.4).timeout

	assert_true(
		_has_visible_text(hud, "$275.00"),
		"HUD scene expected visible cash label '$275.00' after money_changed"
	)
	assert_true(
		_has_visible_text(hud, "Day 3"),
		"HUD scene expected visible day label after day_started"
	)
	assert_true(
		_has_visible_text(hud, "2:00 PM"),
		"HUD scene expected visible time label after hour_changed"
	)


func test_store_checkout_panel_renders_item_rows_and_actions() -> void:
	var panel: CheckoutPanel = CHECKOUT_PANEL_SCENE.instantiate()
	add_child_autofree(panel)

	panel.show_checkout([{
		"item_name": "Trade-In Cart",
		"condition": "Good",
		"price": 19.99,
	}])
	await get_tree().process_frame

	assert_true(
		panel.is_open(),
		"CheckoutPanel scene expected visible contract: panel opens for checkout"
	)
	assert_true(
		_has_visible_text(panel, "Trade-In Cart"),
		"CheckoutPanel scene expected visible item name in checkout row"
	)
	assert_true(
		_has_visible_text(panel, "19.99"),
		"CheckoutPanel scene expected visible price in checkout row"
	)
	assert_true(
		_visible_button_with_text(panel, "Confirm") != null,
		"CheckoutPanel scene expected visible Confirm action button"
	)
	panel.hide_checkout(true)


func test_shelf_slot_renders_stocked_product_card_label() -> void:
	var slot: ShelfSlot = SHELF_SLOT_SCENE.instantiate() as ShelfSlot
	add_child_autofree(slot)

	assert_true(
		slot.is_in_group("shelf_slot"),
		"ShelfSlot scene expected visible contract: slot registers as shelf_slot"
	)
	assert_true(
		slot.place_item("cart_visible", "sealed_product"),
		"ShelfSlot scene expected stocked product placement to succeed"
	)
	slot.set_display_data("Trade-In Cart", "good", 19.99)
	slot.focused.emit()
	await get_tree().process_frame

	assert_true(
		slot.is_occupied(),
		"ShelfSlot scene expected occupied state after stocking"
	)
	assert_not_null(
		_find_node_by_name(slot, "PlaceholderPropShelfProduct"),
		"ShelfSlot scene expected visible product prop node after stocking"
	)
	assert_true(
		_has_visible_label3d_text(slot, "Trade-In Cart"),
		"ShelfSlot scene expected visible stocked product card label"
	)


func test_customer_scene_renders_npc_and_public_visit_state() -> void:
	var nav_config: CustomerNavConfig = _make_nav_config()
	add_child_autofree(nav_config)
	var npc: CustomerNPC = CUSTOMER_NPC_SCENE.instantiate() as CustomerNPC
	add_child_autofree(npc)

	npc.initialize({"purchase_intent": 0.5}, nav_config)
	npc.begin_visit()

	assert_not_null(
		npc.get_node_or_null("MeshInstance3D"),
		"CustomerNPC scene expected visible character mesh"
	)
	assert_not_null(
		npc.get_node_or_null("AnimationPlayer"),
		"CustomerNPC scene expected animation player for visible state"
	)
	assert_eq(
		npc.get_visit_state(),
		CustomerNPC.CustomerVisitState.BROWSING,
		"CustomerNPC scene expected public visit state BROWSING after begin_visit"
	)


func test_back_room_inventory_panel_renders_audit_rows_and_flag_action() -> void:
	var audit := BackRoomAuditStub.new()
	var controller := BackRoomControllerStub.new(audit)
	var panel: BackRoomInventoryPanel = (
		BACK_ROOM_PANEL_SCENE.instantiate() as BackRoomInventoryPanel
	)
	panel.set_controller(controller)
	add_child_autofree(panel)
	await get_tree().process_frame

	assert_true(
		panel.is_open(),
		"BackRoomInventoryPanel scene expected visible contract: panel starts open"
	)
	assert_true(
		_has_visible_text(panel, "Trade-In Cart"),
		"BackRoomInventoryPanel scene expected visible stock row item name"
	)
	assert_true(
		_has_visible_text(panel, "1"),
		"BackRoomInventoryPanel scene expected visible actual count"
	)
	assert_true(
		_visible_button_with_text(panel, "Flag Discrepancy") != null,
		"BackRoomInventoryPanel scene expected visible flag discrepancy action"
	)


func test_tutorial_and_store_session_prompts_render_player_guidance() -> void:
	GameManager.current_state = GameManager.State.STORE_VIEW
	var tutorial := TutorialSystem.new()
	add_child_autofree(tutorial)
	var overlay: TutorialOverlay = (
		TUTORIAL_OVERLAY_SCENE.instantiate() as TutorialOverlay
	)
	overlay.tutorial_system = tutorial
	add_child_autofree(overlay)
	tutorial.initialize(true)
	tutorial._welcome_timer = TutorialSystem.WELCOME_DURATION
	tutorial._process(0.01)

	assert_true(
		_has_visible_non_empty_label(overlay),
		"TutorialOverlay scene expected visible prompt text after first step"
	)

	var prompt: CanvasLayer = INTERACTION_PROMPT_SCENE.instantiate()
	add_child_autofree(prompt)
	EventBus.interactable_focused.emit("[E] Stock Shelf")
	await get_tree().process_frame

	assert_true(
		_has_visible_text(prompt, "[E] Stock Shelf"),
		"InteractionPrompt scene expected visible store-session prompt text"
	)


func test_decision_card_claims_modal_focus_and_renders_choices() -> void:
	InputFocus.push_context(InputFocus.CTX_STORE_GAMEPLAY)
	var baseline_depth: int = InputFocus.depth()
	var card: DecisionCardPanel = DECISION_CARD_SCRIPT.new() as DecisionCardPanel
	add_child_autofree(card)

	card.show_event({
		"title": "Customer Offer",
		"body": "A shopper asks about the trade-in cart.",
		"choices": [
			{"id": "accept", "label": "Accept Offer", "effects": {}},
			{"id": "decline", "label": "Decline", "effects": {}},
		],
	})
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(
		card.visible,
		"DecisionCardPanel scene expected visible modal card after show_event"
	)
	assert_eq(
		InputFocus.current(),
		InputFocus.CTX_MODAL,
		"DecisionCardPanel scene expected CTX_MODAL ownership while visible"
	)
	assert_eq(
		InputFocus.depth(),
		baseline_depth + 1,
		"DecisionCardPanel scene expected exactly one modal focus frame"
	)
	assert_true(
		_has_visible_text(card, "Customer Offer"),
		"DecisionCardPanel scene expected visible decision title"
	)
	assert_true(
		_visible_button_with_text(card, "Accept Offer") != null,
		"DecisionCardPanel scene expected visible first choice button"
	)

	card.close()
	assert_eq(
		InputFocus.depth(),
		baseline_depth,
		"DecisionCardPanel scene expected modal focus release on close"
	)


func test_save_load_panel_renders_load_slots_and_disabled_empty_actions() -> void:
	var path_error: Error = UserDataPaths.configure_test_run(
		"component_scene_contracts",
		true
	)
	assert_eq(
		path_error,
		OK,
		"SaveLoadPanel scene setup expected isolated save path"
	)
	var save_manager := SaveManager.new()
	add_child_autofree(save_manager)
	var panel: SaveLoadPanel = SAVE_LOAD_PANEL_SCENE.instantiate() as SaveLoadPanel
	panel.save_manager = save_manager
	add_child_autofree(panel)

	panel.open_load()
	await get_tree().process_frame

	assert_true(
		panel.is_open(),
		"SaveLoadPanel scene expected visible contract: load panel opens"
	)
	assert_true(
		_has_visible_text(panel, "Empty Slot"),
		"SaveLoadPanel scene expected visible empty-slot row in load mode"
	)
	var load_button: Button = _visible_button_with_text(panel, "Load")
	assert_not_null(
		load_button,
		"SaveLoadPanel scene expected visible Load action button"
	)
	if load_button != null:
		assert_true(
			load_button.disabled,
			"SaveLoadPanel scene expected empty load slot action to be disabled"
		)


func _make_nav_config() -> CustomerNavConfig:
	var config := CustomerNavConfig.new()
	var entry := _make_marker(Vector3.ZERO)
	var browse := _make_marker(Vector3(1.0, 0.0, 0.0))
	var checkout := _make_marker(Vector3(2.0, 0.0, 0.0))
	var exit_marker := _make_marker(Vector3(0.0, 0.0, 2.0))
	config.add_child(entry)
	config.add_child(browse)
	config.add_child(checkout)
	config.add_child(exit_marker)
	config.entry_point = entry
	config.browse_waypoints = [browse]
	config.checkout_approach = checkout
	config.exit_point = exit_marker
	return config


func _make_marker(position: Vector3) -> Marker3D:
	var marker := Marker3D.new()
	marker.position = position
	return marker


func _has_visible_text(root: Node, expected: String) -> bool:
	for node: Node in _visible_text_nodes(root):
		var text: String = _node_text(node)
		if text.contains(expected):
			return true
	return false


func _has_visible_non_empty_label(root: Node) -> bool:
	for node: Node in _visible_text_nodes(root):
		if node is Label and not (node as Label).text.strip_edges().is_empty():
			return true
	return false


func _visible_button_with_text(root: Node, expected: String) -> Button:
	for node: Node in _visible_text_nodes(root):
		if node is Button and (node as Button).text.contains(expected):
			return node as Button
	return null


func _visible_text_nodes(root: Node) -> Array[Node]:
	var found: Array[Node] = []
	_collect_visible_text_nodes(root, found)
	return found


func _collect_visible_text_nodes(node: Node, found: Array[Node]) -> void:
	if _is_hidden_canvas_item(node):
		return
	if node is Label or node is RichTextLabel or node is Button:
		found.append(node)
	for child: Node in node.get_children():
		_collect_visible_text_nodes(child, found)


func _node_text(node: Node) -> String:
	if node is RichTextLabel:
		return (node as RichTextLabel).text
	if node is Button:
		return (node as Button).text
	if node is Label:
		return (node as Label).text
	return ""


func _has_visible_label3d_text(root: Node, expected: String) -> bool:
	for child: Node in root.get_children():
		if _is_hidden_canvas_item(child):
			continue
		if child is Label3D and (child as Label3D).text.contains(expected):
			return true
		if _has_visible_label3d_text(child, expected):
			return true
	return false


func _find_node_by_name(root: Node, target_name: StringName) -> Node:
	if root.name == target_name:
		return root
	for child: Node in root.get_children():
		var found: Node = _find_node_by_name(child, target_name)
		if found != null:
			return found
	return null


func _is_hidden_canvas_item(node: Node) -> bool:
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return true
	return false
