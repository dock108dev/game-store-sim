class_name StoreSessionTutorialFullStep
extends RefCounted

const CAPTURE_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/scenario_screenshot_capture.gd"
)
const CHECKS_SCRIPT: GDScript = preload("res://tests/automation/store_session_tutorial_checks.gd")

const STORE_ID: StringName = &"retro_games"
const SALE_GAME_ID: String = "neo_ignite_motorway_kings_loose"
const RETURN_GAME_ID: String = "neo_ignite_motorway_kings_westside_loose"
const BUNDLE_CONTROLLER_ID: String = "neo_ignite_controller_standard"
const CHOICE_ID: StringName = &"clean_exchange"
const REQUIRED_SEED: String = "tutorial_full_day1_seed"

var _owner: Node
var _result: Dictionary
var _options: Dictionary
var _step: Dictionary
var _assertions: Dictionary = {"total": 0, "passed": 0, "failed": 0}
var _fixtures: Array[Node] = []
var _failure: String = ""
var _checks: RefCounted


func execute(
	owner: Node, step_result: Dictionary, step: Dictionary, result: Dictionary, options: Dictionary
) -> Dictionary:
	_owner = owner
	_step = step
	_result = result
	_options = options
	_failure = ""
	_assertions = {"total": 0, "passed": 0, "failed": 0}
	_checks = CHECKS_SCRIPT.new()
	_ensure_store_gameplay_focus()
	var controller: StoreSessionController = _controller()
	if controller == null:
		return _fail_step(step_result, "store-session controller unavailable")
	if not _assert_fresh_isolated_run():
		return _fail_step(step_result, _failure)
	_seed_salable_inventory()
	await _frames(3)

	for checkpoint: Dictionary in _route_checkpoints():
		if not await _checkpoint(
			str(checkpoint.get("label", "")), controller, checkpoint.get("expect", {}) as Dictionary
		):
			return _fail_step(step_result, _failure)
		if not await _apply_actions(controller, checkpoint.get("after", []) as Array):
			return _fail_step(step_result, _failure)
	_cleanup_fixtures()
	step_result["ok"] = true
	step_result["data"] = {"assertion_counts": _assertions, "captures": 18}
	return step_result


func _checkpoint(label: String, controller: StoreSessionController, expected: Dictionary) -> bool:
	var wait_result: Dictionary = await _checks.wait_for(
		_owner, controller, expected, int(_step.get("timeout_frames", 300))
	)
	_assertions = wait_result.get("assertion_counts", _assertions) as Dictionary
	if not _failure.is_empty():
		return false
	if not bool(wait_result.get("ok", false)):
		_failure = str(wait_result.get("reason", "checkpoint failed"))
		return false
	var capture: Dictionary = (
		CAPTURE_SCRIPT
		. capture_viewport(
			_owner.get_viewport(),
			{
				"scenario_id": str(_result.get("scenario_id", "tutorial_full")),
				"seed": REQUIRED_SEED,
				"checkpoint": label,
				"allow_placeholder": bool(_step.get("allow_placeholder", true)),
				"assertion_counts": _assertions.duplicate(true),
			}
		)
	)
	if not bool(capture.get("ok", false)):
		_failure = str(capture.get("error", "screenshot capture failed"))
		return false
	(_result.get("captures", {}) as Dictionary)[label] = capture
	return true


func _route_checkpoints() -> Array[Dictionary]:
	var stock_1: String = "Place item 1 of 3 on Starter Display"
	var stock_2: String = "Place item 2 of 3 on Starter Display"
	var stock_3: String = "Place item 3 of 3 on Starter Display"
	return [
		_cp(
			"01_boot_first_day_manager_objective",
			{
				"stage": "training_talk_manager",
				"target": "StoreSessionManager/Interactable",
				"prompt": "Talk to Manager",
				"header": "FIRST DAY",
				"preopening_complete": false
			}
		),
		_cp(
			"02_training_talk_manager_prompt",
			{
				"stage": "training_talk_manager",
				"target": "StoreSessionManager/Interactable",
				"prompt": "Talk to Manager",
				"header": "FIRST DAY"
			},
			["interact"]
		),
		_cp(
			"03_training_check_register_ready",
			{
				"stage": "training_check_register",
				"target": "StoreSessionDayEndTrigger/Interactable",
				"prompt": "Check Register",
				"register": "READY",
				"header": "FIRST DAY"
			},
			["interact"]
		),
		_cp(
			"04_training_backroom_inventory",
			{
				"stage": "training_back_room_inventory",
				"target": "StoreSessionBackroomPickup/Interactable",
				"prompt": "Inspect Starter Stock Box",
				"register": "BACK\nROOM",
				"header": "FIRST DAY"
			},
			["interact"]
		),
		_cp(
			"05_training_stock_item_1",
			{
				"stage": "training_stock_shelf",
				"target": "StoreSessionRestockShelf/Interactable",
				"prompt": stock_1,
				"carrying": true
			},
			["interact"]
		),
		_cp(
			"06_training_stock_item_2",
			{
				"stage": "training_stock_shelf",
				"target": "StoreSessionRestockShelf/Interactable",
				"prompt": stock_2,
				"carrying": true
			},
			["interact"]
		),
		_cp(
			"07_training_stock_item_3",
			{
				"stage": "training_stock_shelf",
				"target": "StoreSessionRestockShelf/Interactable",
				"prompt": stock_3,
				"carrying": true
			},
			["interact"]
		),
		_cp(
			"08_day1_open_customer_objective",
			{
				"stage": "talk_to_customer",
				"target": "StoreSessionDayOneCustomer/Interactable",
				"prompt": "Talk to customer",
				"header_prefix": "DAY 1",
				"close_reason": "Talk to the customer first.",
				"preopening_complete": true
			}
		),
		_cp(
			"09_day1_customer_prompt",
			{
				"stage": "talk_to_customer",
				"target": "StoreSessionDayOneCustomer/Interactable",
				"prompt": "Talk to customer"
			},
			["interact"]
		),
		_cp(
			"10_day1_customer_decision_modal",
			{
				"stage": "talk_to_customer",
				"modal_busy": true,
				"register": "SALE\nOPEN",
				"event_id": "day01_wrong_console_parent"
			},
			["choose"]
		),
		_cp(
			"11_day1_customer_result",
			{"stage": "talk_to_customer", "result_visible": true, "modal_busy": true},
			["ack_result", "fast_forward_exit"]
		),
		_cp(
			"12_day1_customer_exit",
			{
				"stage": "back_room_inventory",
				"customer_exit": "exited_hidden",
				"target": "StoreSessionBackroomPickup/Interactable",
				"prompt": "Inspect Starter Stock Box"
			},
			["interact"]
		),
		_cp(
			"13_day1_backroom_delivery",
			{
				"stage": "stock_shelf",
				"target": "StoreSessionRestockShelf/Interactable",
				"prompt": stock_1
			},
			["interact", "interact"]
		),
		_cp(
			"14_day1_stock_shelf",
			{
				"stage": "stock_shelf",
				"target": "StoreSessionRestockShelf/Interactable",
				"prompt": stock_3,
				"carrying": true
			},
			["interact"]
		),
		_cp(
			"15_day1_close_ready",
			{
				"stage": "end_day",
				"target": "StoreSessionDayEndTrigger/Interactable",
				"prompt": "Close day",
				"register": "CLOSE\nDAY",
				"can_close": true
			},
			["interact"]
		),
		_cp("16_day1_close_confirmation", {"stage": "end_day", "modal_busy": true}, ["ack_close"]),
		_cp(
			"17_day1_summary",
			{"stage": "end_day", "modal_busy": true, "summary_visible": true},
			["ack_summary"]
		),
		_cp(
			"18_day2_started",
			{
				"stage": "talk_to_customer",
				"day": 2,
				"header_prefix": "DAY 2",
				"modal_busy": false,
				"preopening_complete": true
			}
		),
	]


func _cp(label: String, expect: Dictionary, after: Array[String] = []) -> Dictionary:
	return {"label": label, "expect": expect, "after": after}


func _apply_actions(controller: StoreSessionController, actions: Array) -> bool:
	for action: String in actions:
		match action:
			"interact":
				await _interact(controller)
			"choose":
				if not _choose_decision(controller):
					return false
			"ack_result":
				if not controller.acknowledge_prompt_for_automation():
					_failure = "customer result acknowledgement unavailable"
					return false
				await _frames(1)
			"fast_forward_exit":
				controller.fast_forward_animations_for_automation()
			"ack_close":
				if not ModalQueue.acknowledge_active_for_automation():
					_failure = "close confirmation acknowledgement unavailable"
					return false
			"ack_summary":
				if not controller.acknowledge_prompt_for_automation():
					_failure = "day summary continuation unavailable"
					return false
			_:
				_failure = "unknown tutorial action: %s" % action
				return false
	return true


func _interact(controller: StoreSessionController) -> void:
	var target: Node = _store_root().get_node_or_null(
		NodePath(controller.active_objective_target_path())
	)
	if target is Interactable:
		(target as Interactable).interact()
	await _frames(2)
	if controller.acknowledge_prompt_for_automation():
		await _frames(1)


func _choose_decision(controller: StoreSessionController) -> bool:
	var panel: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	if panel == null:
		_failure = "decision panel unavailable"
		return false
	return panel.choose_for_automation(CHOICE_ID)


func _seed_salable_inventory() -> void:
	var data_loader := DataLoader.new()
	_owner.add_child(data_loader)
	_fixtures.append(data_loader)
	var items: Dictionary = {}
	items[SALE_GAME_ID] = _item_definition(SALE_GAME_ID, "Motorway Kings", &"cartridges", 22.0)
	items[RETURN_GAME_ID] = _item_definition(
		RETURN_GAME_ID, "Motorway Kings: Westside", &"cartridges", 32.0
	)
	items[BUNDLE_CONTROLLER_ID] = _item_definition(
		BUNDLE_CONTROLLER_ID, "Neo Ignite Controller", &"accessories", 24.0
	)
	data_loader.set("_items", items)
	var inventory := InventorySystem.new()
	_owner.add_child(inventory)
	_fixtures.append(inventory)
	inventory.initialize(data_loader)
	var economy := EconomySystem.new()
	_owner.add_child(economy)
	_fixtures.append(economy)
	economy.initialize(500.0)
	var definition: ItemDefinition = data_loader.get_item(SALE_GAME_ID)
	var item: ItemInstance = ItemInstance.create(definition, "good", 0, definition.base_price)
	item.current_location = "shelf:tutorial_full_route"
	inventory.add_item(STORE_ID, item)


func _item_definition(
	id: String, display_name: String, category: StringName, price: float
) -> ItemDefinition:
	var definition := ItemDefinition.new()
	definition.id = id
	definition.item_name = display_name
	definition.store_type = STORE_ID
	definition.category = category
	definition.base_price = price
	definition.rarity = "common"
	return definition


func _assert_fresh_isolated_run() -> bool:
	if not bool(_options.get("fresh_save", false)):
		_failure = "tutorial_full requires fresh_save=true"
		return false
	if str(_result.get("seed", "")) != REQUIRED_SEED:
		_failure = "tutorial_full requires fixed seed %s" % REQUIRED_SEED
		return false
	if not UserDataPaths.is_automation_root_enabled():
		_failure = "tutorial_full requires UserDataPaths automation root"
		return false
	return true


func _controller() -> StoreSessionController:
	return (
		_owner.get_tree().get_first_node_in_group("store_session_controller")
		as StoreSessionController
	)


func _store_root() -> Node:
	return _owner.get_tree().current_scene


func _ensure_store_gameplay_focus() -> void:
	if InputFocus.current() == &"":
		InputFocus.push_context(InputFocus.CTX_STORE_GAMEPLAY)


func _frames(count: int) -> void:
	for _i: int in range(count):
		await _owner.get_tree().process_frame


func _cleanup_fixtures() -> void:
	for node: Node in _fixtures:
		if is_instance_valid(node):
			node.queue_free()
	_fixtures.clear()


func _fail_step(step_result: Dictionary, reason: String) -> Dictionary:
	_cleanup_fixtures()
	step_result["ok"] = false
	step_result["reason"] = reason
	step_result["data"] = {"assertion_counts": _assertions}
	return step_result
