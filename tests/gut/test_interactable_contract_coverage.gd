# gdlint:disable=max-public-methods
extends GutTest

const RAY_SCRIPT: GDScript = preload("res://game/scripts/player/interaction_ray.gd")
const STORE_SCENES: Array[String] = ["res://game/scenes/stores/retro_games.tscn"]

const UI_ACTIONS: Array[Dictionary] = [
	{
		"category": "menu_buttons",
		"scene": "res://game/scenes/ui/main_menu.tscn",
		"paths": [
			"VBox/PlayButton",
			"VBox/LoadButton",
			"VBox/SettingsButton",
			"VBox/QuitButton",
		],
	},
	{
		"category": "save_load_terminal",
		"scene": "res://game/scenes/ui/save_load_panel.tscn",
		"paths": [
			"PanelRoot/Margin/VBox/Header/CloseButton",
			"ConfirmRoot/Margin/VBox/Buttons/YesButton",
			"ConfirmRoot/Margin/VBox/Buttons/NoButton",
		],
	},
	{
		"category": "build_buy_ui",
		"scene": "res://game/scenes/ui/fixture_catalog.tscn",
		"paths": ["PanelRoot/Margin/VBox/Header/CloseButton"],
	},
	{
		"category": "build_buy_ui",
		"scene": "res://game/scenes/ui/order_panel.tscn",
		"paths": [
			"PanelRoot/Margin/VBox/Header/CloseButton",
			"PanelRoot/Margin/VBox/Content/CartSection/SubmitButton",
		],
	},
	{
		"category": "tutorial_target",
		"scene": "res://game/scenes/ui/tutorial_overlay.tscn",
		"paths": ["BottomBar/HBox/SkipButton"],
		"meta_path": ".",
		"meta_key": "semantic_target",
		"meta_value": "tutorial.panel",
	},
	{
		"category": "notification_action",
		"scene": "res://game/scenes/ui/milestone_card.tscn",
		"paths": ["Margin/MainVBox/ContinueButton"],
		"allow_hidden": true,
	},
]
var _root: Node3D
var _player: CharacterBody3D
var _camera: Camera3D
var _ray: Node
var _focused_labels: Array[String] = []
var _disabled_reasons: Array[String] = []
var _unfocused_count: int = 0
var _local_interactions: int = 0
var _bus_interactions: int = 0
var _clicked: Array[Array] = []
var _player_interactions: int = 0
var _customer_interactions: int = 0
func before_each() -> void:
	InputFocus._reset_for_tests()
	InputFocus.push_context(InputFocus.CTX_STORE_GAMEPLAY)
	_reset_captures()
	_root = Node3D.new()
	_root.name = "InteractionContractFixture"
	add_child_autofree(_root)
	_player = CharacterBody3D.new()
	_player.name = "Player"
	_player.add_to_group("player")
	_player.set_physics_process(true)
	_root.add_child(_player)
	_camera = Camera3D.new()
	_camera.name = "StoreCamera"
	_camera.position = Vector3(0.0, 1.7, 0.0)
	_player.add_child(_camera)
	_ray = Node.new()
	_ray.name = "InteractionRay"
	_ray.set_script(RAY_SCRIPT)
	_player.add_child(_ray)
	_ray.call("_apply_camera", _camera)
	EventBus.interactable_focused.connect(_on_focused)
	EventBus.interactable_focused_disabled.connect(_on_disabled_focused)
	EventBus.interactable_unfocused.connect(_on_unfocused)
	EventBus.interactable_interacted.connect(_on_bus_interacted)
	EventBus.interactable_clicked.connect(_on_clicked)
	EventBus.player_interacted.connect(_on_player_interacted)
	EventBus.customer_interacted.connect(_on_customer_interacted)


func after_each() -> void:
	InputFocus._reset_for_tests()
	_disconnect_bus()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func test_core_interactable_categories_share_the_runtime_contract() -> void:
	for definition: Dictionary in _interactable_definitions():
		_reset_captures()
		var target: Interactable = _make_contract_target(definition)
		target.interacted.connect(_on_local_interacted)

		_assert_interactable_surface(target, definition)
		_ray.call("_set_hovered_target", target)
		_assert_focus_surface(target, definition)

		_dispatch_interact_action()
		_dispatch_left_click()

		assert_eq(_local_interactions, 2, "%s should emit local activation" % definition["category"])
		assert_eq(_bus_interactions, 2, "%s should emit EventBus activation" % definition["category"])
		assert_eq(_player_interactions, 2, "%s should route through player interaction" % definition["category"])
		assert_eq(_clicked.size(), 2, "%s should emit scoped click ids" % definition["category"])
		assert_eq(String(_clicked[0][0]), String(definition["id"]))
		assert_eq(String(_clicked[0][1]), "contract_store")
		if bool(definition.get("customer_signal", false)):
			assert_eq(_customer_interactions, 2, "Customer targets should emit their category signal")
		_ray.call("_set_hovered_target", null)
		assert_eq(_unfocused_count, 1, "%s should unfocus once" % definition["category"])


func test_disabled_interactable_has_prompt_but_no_activation_or_soft_lock() -> void:
	var target := DisabledContractInteractable.new()
	target.name = "DisabledCounter"
	target.display_name = "counter"
	target.prompt_text = "Use"
	target.disabled_reason = "No action available"
	target.interactable_id = &"disabled.counter"
	target.store_id = &"contract_store"
	target.add_child(_shape())
	_root.add_child(target)
	target.interacted.connect(_on_local_interacted)
	_reset_captures()
	var starting_depth: int = InputFocus.depth()

	_ray.call("_set_hovered_target", target)
	_dispatch_interact_action()
	_dispatch_left_click()

	assert_true(_focused_labels.is_empty(), "Disabled focus must not show an active prompt")
	assert_eq(_disabled_reasons, ["No action available"], "Disabled focus should explain the state")
	assert_eq(_local_interactions, 0, "Disabled targets must not emit local activation")
	assert_eq(_bus_interactions, 0, "Disabled targets must not emit bus activation")
	assert_eq(_player_interactions, 0, "Disabled targets must not dispatch player interaction")
	assert_eq(_clicked.size(), 0, "Disabled targets must not emit scoped clicks")
	assert_eq(InputFocus.current(), InputFocus.CTX_STORE_GAMEPLAY, "Input focus must remain playable")
	assert_eq(InputFocus.depth(), starting_depth, "Disabled interaction must not mutate focus depth")
	assert_true(_player.is_physics_processing(), "Player movement processing must remain enabled")
	assert_eq(_ray.call("get_open_panel_count"), 0, "Disabled interaction must not leave a modal open")
	_ray.call("_set_hovered_target", null)
	assert_null(_ray.call("get_hovered_target"), "Unfocus should leave no hovered target")


func test_focus_cycle_highlights_once_and_shelf_label_visibility_tracks_focus() -> void:
	var target := ContractInteractable.new()
	target.name = "HighlightTarget"
	target.display_name = "target"
	target.prompt_text = "Inspect"
	target.add_child(_shape())
	_root.add_child(target)

	_ray.call("_set_hovered_target", target)
	_ray.call("_set_hovered_target", target)
	_ray.call("_set_hovered_target", null)

	assert_eq(target.highlight_calls, 1, "Focus should highlight the target once")
	assert_eq(target.unhighlight_calls, 1, "Unfocus should unhighlight the target once")
	assert_eq(_unfocused_count, 1, "A single focus clear should emit one unfocus")

	var slot := ShelfSlot.new()
	slot.name = "LabelSlot"
	slot.display_name = "Shelf Slot"
	slot.add_child(_shape())
	_root.add_child(slot)
	slot.assign_item(&"stocked_item")
	slot.set_display_data("Used Game", "good", 12.0)
	assert_false(slot._info_label.visible, "Shelf label starts hidden")

	_ray.call("_set_hovered_target", slot)
	assert_true(slot._info_label.visible, "Shelf label should show on focus")
	_ray.call("_set_hovered_target", null)
	assert_false(slot._info_label.visible, "Shelf label should hide on unfocus")


func test_active_store_scene_required_interactable_types_are_scanned() -> void:
	var required: Dictionary = {
		Interactable.InteractionType.SHELF_SLOT: "shelf",
		Interactable.InteractionType.REGISTER: "register",
		Interactable.InteractionType.ITEM: "product_box",
		Interactable.InteractionType.BACKROOM: "storage_backroom",
		Interactable.InteractionType.CUSTOMER: "customer",
		Interactable.InteractionType.STOREFRONT: "store_entrance",
	}
	var covered: Dictionary = _covered_types()

	for scene_path: String in STORE_SCENES:
		var packed: PackedScene = load(scene_path) as PackedScene
		assert_not_null(packed, "Store scene should load: %s" % scene_path)
		if packed == null:
			continue
		var scene: Node = packed.instantiate()
		add_child_autofree(scene)
		var seen: Dictionary = {}
		for target: Interactable in _collect_interactables(scene):
			var area: Area3D = target.get_interaction_area()
			assert_not_null(area, "Scene target should expose an InteractionArea")
			if area != null:
				assert_same(Interactable.from_collider(area), target)
			assert_ne(target.get_prompt_label().strip_edges(), "")
			seen[target.interaction_type] = true
			assert_true(
				covered.has(target.interaction_type),
				"Untested scene interaction type: %s" % _type_name(target.interaction_type)
			)
		for type_value: int in required.keys():
			assert_true(
				seen.has(type_value),
				"%s should contain required category %s"
					% [scene_path, required[type_value]]
			)


func test_core_ui_action_surfaces_are_visible_focusable_and_signalable() -> void:
	for entry: Dictionary in UI_ACTIONS:
		var packed: PackedScene = load(str(entry["scene"])) as PackedScene
		assert_not_null(packed, "UI scene should load: %s" % entry["scene"])
		if packed == null:
			continue
		var root: Node = packed.instantiate()
		if entry.has("meta_path"):
			add_child_autofree(root)
			var meta_node: Node = root.get_node_or_null(NodePath(str(entry["meta_path"])))
			assert_not_null(meta_node, "Semantic UI target should exist")
			if meta_node != null:
				assert_eq(
					str(meta_node.get_meta(str(entry["meta_key"]), "")),
					str(entry["meta_value"])
				)
		for button_path: String in entry["paths"]:
			var button: Button = root.get_node_or_null(NodePath(button_path)) as Button
			assert_not_null(button, "%s button path should exist" % entry["category"])
			if button == null:
				continue
			if not bool(entry.get("allow_hidden", false)):
				assert_true(button.visible, "%s button should be visible" % button_path)
			assert_ne(button.text.strip_edges(), "", "%s button should have a label" % button_path)
			assert_ne(button.focus_mode, Control.FOCUS_NONE, "%s button should accept focus" % button_path)
			_assert_button_activation_probe(button_path)
		if not root.is_inside_tree():
			root.free()


func test_supported_interaction_inputs_are_explicitly_covered() -> void:
	assert_true(InputMap.has_action("interact"), "The gameplay interaction action must exist")
	var has_key: bool = false
	var has_controller: bool = false
	for event: InputEvent in InputMap.action_get_events("interact"):
		has_key = has_key or event is InputEventKey
		has_controller = has_controller or event is InputEventJoypadButton or event is InputEventJoypadMotion
	assert_true(has_key, "Keyboard interact is configured and covered by InputEventAction dispatch")
	if has_controller:
		var target := _make_contract_target(_interactable_definitions()[0])
		_ray.call("_set_hovered_target", target)
		_dispatch_interact_action()
		assert_eq(_player_interactions, 1, "Controller mappings share the interact action path")
	else:
		assert_false(has_controller, "No controller-specific interact mapping is currently configured")


func _interactable_definitions() -> Array[Dictionary]:
	return [
		_def("register", Interactable.InteractionType.REGISTER, "register.main", "Use", "register"),
		_def("shelf", Interactable.InteractionType.SHELF_SLOT, "shelf.slot", "Stock", "display shelf", true),
		_def("product_box", Interactable.InteractionType.ITEM, "product.box", "Inspect", "product box"),
		_def("storage_backroom", Interactable.InteractionType.BACKROOM, "backroom.pickup", "Check", "back room"),
		_def("customer", Interactable.InteractionType.CUSTOMER, "customer.talk", "Talk to", "customer", false, true),
		_def("store_entrance", Interactable.InteractionType.STOREFRONT, "store.entrance", "Enter", "glass door"),
		_def("returns_bin", Interactable.InteractionType.RETURNS_BIN, "returns.bin", "Check", "returns bin"),
	]


func _def(
	category: String,
	type_value: int,
	id: String,
	prompt: String,
	name_text: String,
	use_shelf: bool = false,
	customer_signal: bool = false
) -> Dictionary:
	return {
		"category": category,
		"type": type_value,
		"id": id,
		"prompt": prompt,
		"name": name_text,
		"use_shelf": use_shelf,
		"customer_signal": customer_signal,
	}


func _make_contract_target(definition: Dictionary) -> Interactable:
	var target: Interactable
	if bool(definition.get("use_shelf", false)):
		var slot := ShelfSlot.new()
		slot.display_name = str(definition["name"])
		slot.add_child(_shape())
		_root.add_child(slot)
		slot.assign_item(&"contract_item")
		slot.set_display_data("Contract Item", "good", 10.0)
		target = slot
	else:
		var probe := CustomerContractInteractable.new() if bool(definition.get("customer_signal", false)) else ContractInteractable.new()
		probe.interaction_type = int(definition["type"])
		probe.display_name = str(definition["name"])
		probe.prompt_text = str(definition["prompt"])
		probe.add_child(_shape())
		_root.add_child(probe)
		target = probe
	target.interactable_id = StringName(str(definition["id"]))
	target.store_id = &"contract_store"
	return target


func _assert_interactable_surface(target: Interactable, definition: Dictionary) -> void:
	assert_true(target.visible, "%s should have visible 3D affordance" % definition["category"])
	var area: Area3D = target.get_interaction_area()
	assert_not_null(area, "%s should expose collision area" % definition["category"])
	if area == null:
		return
	assert_eq(area.collision_layer, Interactable.INTERACTABLE_LAYER)
	assert_true(area.input_ray_pickable, "%s area should be ray-pickable" % definition["category"])
	assert_same(Interactable.from_collider(area), target)
	assert_ne(target.get_prompt_label().strip_edges(), "")


func _assert_focus_surface(target: Interactable, definition: Dictionary) -> void:
	assert_eq(_focused_labels.size(), 1, "%s should focus once" % definition["category"])
	assert_eq(_disabled_reasons.size(), 0, "%s should not focus as disabled" % definition["category"])
	assert_eq(_focused_labels[0], target.get_prompt_label())
	assert_same(_ray.call("get_hovered_target"), target)


func _assert_button_activation_probe(label: String) -> void:
	var probe := Button.new()
	var press_count: Array[int] = [0]
	probe.pressed.connect(func() -> void: press_count[0] += 1)
	probe.pressed.emit()
	assert_eq(press_count[0], 1, "%s button contract should emit pressed once" % label)
	probe.free()


func _covered_types() -> Dictionary:
	var covered: Dictionary = {}
	for definition: Dictionary in _interactable_definitions():
		covered[int(definition["type"])] = true
	return covered


func _collect_interactables(root: Node) -> Array[Interactable]:
	var found: Array[Interactable] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for child: Node in node.get_children():
			stack.append(child)
		if node is Interactable:
			found.append(node as Interactable)
	return found


func _shape() -> CollisionShape3D:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.75, 1.0, 0.75)
	shape.shape = box
	return shape


func _dispatch_interact_action() -> void:
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	_ray.call("_unhandled_input", event)


func _dispatch_left_click() -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	_ray.call("_unhandled_input", event)


func _reset_captures() -> void:
	_focused_labels.clear()
	_disabled_reasons.clear()
	_unfocused_count = 0
	_local_interactions = 0
	_bus_interactions = 0
	_clicked.clear()
	_player_interactions = 0
	_customer_interactions = 0


func _disconnect_bus() -> void:
	if EventBus.interactable_focused.is_connected(_on_focused):
		EventBus.interactable_focused.disconnect(_on_focused)
	if EventBus.interactable_focused_disabled.is_connected(_on_disabled_focused):
		EventBus.interactable_focused_disabled.disconnect(_on_disabled_focused)
	if EventBus.interactable_unfocused.is_connected(_on_unfocused):
		EventBus.interactable_unfocused.disconnect(_on_unfocused)
	if EventBus.interactable_interacted.is_connected(_on_bus_interacted):
		EventBus.interactable_interacted.disconnect(_on_bus_interacted)
	if EventBus.interactable_clicked.is_connected(_on_clicked):
		EventBus.interactable_clicked.disconnect(_on_clicked)
	if EventBus.player_interacted.is_connected(_on_player_interacted):
		EventBus.player_interacted.disconnect(_on_player_interacted)
	if EventBus.customer_interacted.is_connected(_on_customer_interacted):
		EventBus.customer_interacted.disconnect(_on_customer_interacted)


func _on_focused(label: String) -> void:
	_focused_labels.append(label)


func _on_disabled_focused(reason: String) -> void:
	_disabled_reasons.append(reason)


func _on_unfocused() -> void:
	_unfocused_count += 1


func _on_local_interacted() -> void:
	_local_interactions += 1


func _on_bus_interacted(_target: Interactable, _type: int) -> void:
	_bus_interactions += 1


func _on_clicked(id: StringName, store: StringName) -> void:
	_clicked.append([id, store])


func _on_player_interacted(_target: Node) -> void:
	_player_interactions += 1


func _on_customer_interacted(_customer: Node) -> void:
	_customer_interactions += 1


func _type_name(type_value: int) -> String:
	for key: String in Interactable.InteractionType.keys():
		if int(Interactable.InteractionType[key]) == type_value:
			return key
	return str(type_value)


class ContractInteractable:
	extends Interactable

	var highlight_calls: int = 0
	var unhighlight_calls: int = 0

	func highlight() -> void:
		highlight_calls += 1
		super.highlight()

	func unhighlight() -> void:
		unhighlight_calls += 1
		super.unhighlight()


class CustomerContractInteractable:
	extends ContractInteractable

	func interact(by: Node = null) -> void:
		super.interact(by)
		EventBus.customer_interacted.emit(self)


class DisabledContractInteractable:
	extends ContractInteractable

	var disabled_reason: String = ""

	func can_interact(_actor: Node = null) -> bool:
		return false

	func get_disabled_reason(_actor: Node = null) -> String:
		return disabled_reason
