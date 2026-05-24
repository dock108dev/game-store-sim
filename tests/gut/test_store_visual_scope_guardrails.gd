extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"

const VISUAL_ONLY_ROOTS: Array[String] = [
	"ReadabilityProps",
	"ReadabilityProps/CheckoutCounterDressing",
	"ReadabilityProps/ShelfSpineRuns",
	"ReadabilityProps/UsedConsoleDressing",
	"ReadabilityProps/BackroomDressing",
	"ReadabilityProps/FloorDisplayIsland",
	"ReadabilityProps/SpawnViewFloorDressing",
	"ReadabilityProps/ProductDisplayRows",
	"ReadabilityProps/DayOneRouteMarkers",
]

const REQUIRED_BETA_KEEP_ROOTS: Array[String] = [
	"ExpandableStoreShell",
	"checkout_counter",
	"FrontLaneQueue",
	"BetaDayOneCustomer",
	"BetaBackroomPickup",
	"BetaRestockShelf",
	"BetaDayEndTrigger",
]

const REQUIRED_VISIBLE_SIGNS: Array[String] = [
	"ExpandableStoreShell/StarterSignLabel",
	"ExpandableStoreShell/GamesBayLabel",
	"ExpandableStoreShell/StockroomLabel",
	"ExpandableStoreShell/ExpansionLabel",
]

const REQUIRED_HIDDEN_DEFERRED_ROOTS: Array[String] = [
	"CartRackRight",
	"GlassCase",
	"ConsoleShelf",
	"AccessoriesBin",
	"bargain_bin",
	"crt_demo_area",
	"staff_picks_table",
]

const REQUIRED_CONTEXT_ROOTS: Array[String] = [
	"ExpandableStoreShell",
]

const APPROVED_AMBIENT_INTERACTABLES: Array[String] = [
	"EntranceDoor/Interactable",
	"checkout_counter/RegisterStatusIndicator",
]

const OBJECTIVE_TARGET_PATHS: Array[String] = [
	"BetaDayOneCustomer/Interactable",
	"BetaBackroomPickup/Interactable",
	"BetaRestockShelf/Interactable",
	"BetaDayEndTrigger/Interactable",
]

const ALLOWED_VISIBLE_CATEGORIES: Array[String] = [
	"fixture",
	"product",
	"sign",
	"gameplay_marker",
	"intentional_dressing",
]

const VISIBLE_ROOT_CLASSIFICATIONS: Dictionary = {
	"EntranceDoor": ["fixture"],
	"checkout_counter": ["fixture"],
	"FrontLaneQueue": ["fixture", "gameplay_marker"],
	"BetaDayOneCustomer": ["gameplay_marker"],
	"BetaBackroomPickup": ["gameplay_marker", "product", "sign"],
	"BetaRestockShelf": ["gameplay_marker", "product"],
	"BetaDayEndTrigger": ["gameplay_marker"],
	"BetaHiddenClue": ["intentional_dressing"],
	"ExpandableStoreShell": ["fixture", "sign", "intentional_dressing"],
}

var _root: Node3D
var _saved_state: GameManager.State
var _saved_day: int


func before_each() -> void:
	_saved_state = GameManager.current_state
	_saved_day = GameManager.get_current_day()
	GameManager.current_state = GameManager.State.STORE_VIEW
	GameManager.set_current_day(1)
	BetaRunState.reset_new_run()
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame


func after_each() -> void:
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	if is_instance_valid(_root):
		_root.free()
	_root = null
	BetaRunState.reset_new_run()
	GameManager.current_state = _saved_state
	GameManager.set_current_day(_saved_day)


func test_visual_dressing_roots_remain_visual_only() -> void:
	for node_path: String in VISUAL_ONLY_ROOTS:
		var visual_root: Node = _root.get_node_or_null(node_path)
		assert_not_null(visual_root, "Visual dressing root must exist: %s" % node_path)
		if visual_root == null:
			continue
		assert_false(
			_has_forbidden_visual_descendant(visual_root),
			"%s must not contain gameplay, physics, or runtime-script descendants" % node_path
		)


func test_visible_beta_roots_have_explicit_scene_categories() -> void:
	for child: Node in _root.get_children():
		if not _is_visible_through_ancestors(child):
			continue
		if not _has_visible_authored_surface(child):
			continue
		var root_name: String = str(child.name)
		assert_true(
			BetaDayOneController.BETA_KEEP_ROOT_NODES.has(StringName(root_name)),
			"%s must be beta-kept before it can remain visible" % root_name
		)
		assert_true(
			VISIBLE_ROOT_CLASSIFICATIONS.has(root_name),
			(
				"%s must be classified as fixture, product, sign, gameplay marker, or dressing"
				% root_name
			)
		)
	for root_name: String in VISIBLE_ROOT_CLASSIFICATIONS.keys():
		assert_true(
			BetaDayOneController.BETA_KEEP_ROOT_NODES.has(StringName(root_name)),
			"%s classification must match a beta-visible root" % root_name
		)
		var categories: Array = VISIBLE_ROOT_CLASSIFICATIONS[root_name] as Array
		assert_gt(categories.size(), 0, "%s must have at least one category" % root_name)
		for category: String in categories:
			assert_true(
				ALLOWED_VISIBLE_CATEGORIES.has(category),
				"%s uses unsupported visual category: %s" % [root_name, category]
			)


func test_beta_keep_roots_and_signs_stay_visible_after_scope_strip() -> void:
	for root_name: String in REQUIRED_BETA_KEEP_ROOTS:
		assert_true(
			BetaDayOneController.BETA_KEEP_ROOT_NODES.has(StringName(root_name)),
			"%s must stay in the beta-visible root set" % root_name
		)
		var node: Node = _root.get_node_or_null(root_name)
		assert_not_null(node, "Beta-visible root must exist: %s" % root_name)
		if node != null:
			assert_true(
				_is_visible_through_ancestors(node),
				"%s must remain visible through every ancestor" % root_name
			)
	for sign_path: String in REQUIRED_VISIBLE_SIGNS:
		var sign: Node = _root.get_node_or_null(sign_path)
		assert_not_null(sign, "Required beta sign must exist: %s" % sign_path)
		if sign != null:
			assert_true(
				_is_visible_through_ancestors(sign),
				"%s must stay visible through its ancestor chain" % sign_path
			)


func test_deferred_and_context_roots_match_runtime_scope() -> void:
	for root_name: String in REQUIRED_HIDDEN_DEFERRED_ROOTS:
		var root_key: StringName = StringName(root_name)
		assert_true(
			BetaDayOneController.BETA_DEFERRED_ROOT_NODES.has(root_key),
			"%s must be classified as deferred beta scope" % root_name
		)
		assert_false(
			BetaDayOneController.BETA_KEEP_ROOT_NODES.has(root_key),
			"%s must not be promoted as a beta-visible root" % root_name
		)
		var node: Node = _root.get_node_or_null(root_name)
		assert_not_null(node, "Deferred full-store root must remain authored: %s" % root_name)
		if node is Node3D:
			assert_false(
				(node as Node3D).visible, "%s must be hidden by beta runtime scope" % root_name
			)
	for root_name: String in REQUIRED_CONTEXT_ROOTS:
		var root_key: StringName = StringName(root_name)
		assert_true(
			BetaDayOneController.BETA_CONTEXT_ROOT_NODES.has(root_key),
			"%s must be classified as retained tutorial context" % root_name
		)
		assert_true(
			BetaDayOneController.BETA_KEEP_ROOT_NODES.has(root_key),
			(
				"%s context must remain visible until the current tutorial no longer needs it"
				% root_name
			)
		)


func test_hidden_noise_roots_stay_hidden_and_disabled() -> void:
	for node_path: String in BetaDayOneController._HIDDEN_NOISE_PATHS:
		var node: Node = _root.get_node_or_null(node_path)
		assert_not_null(node, "Hidden beta noise root must exist: %s" % node_path)
		if node == null:
			continue
		if node is Node3D:
			assert_false((node as Node3D).visible, "%s must stay hidden in beta" % node_path)
		var interactables: Array[Interactable] = []
		_collect_interactables(node, interactables)
		for interactable: Interactable in interactables:
			assert_false(
				interactable.enabled,
				(
					"%s must not leave an enabled Interactable under hidden beta noise"
					% _relative_path(interactable)
				)
			)


func test_objective_targets_keep_visible_context_bundles() -> void:
	var bundles: Dictionary = {
		"BetaDayOneCustomer":
		[
			"FrontLaneQueue",
			"ExpandableStoreShell",
			"ExpandableStoreShell/StarterSignLabel",
		],
		"BetaBackroomPickup":
		[
			"BackroomUtilityLight",
			"ExpandableStoreShell/StockroomPartition",
			"ExpandableStoreShell/StockroomLabel",
			"BetaBackroomPickup/StockBox",
			"BetaBackroomPickup/StockBoxLabel",
		],
		"BetaRestockShelf":
		[
			"ExpandableStoreShell/StarterBackWall",
			"ExpandableStoreShell/GamesBayLabel",
			"BetaRestockShelf/RestockCrate",
		],
		"BetaDayEndTrigger":
		[
			"FrontLaneQueue",
			"ExpandableStoreShell",
			"ExpandableStoreShell/StarterSignLabel",
		],
	}
	for target_name: String in bundles.keys():
		var target: Node = _root.get_node_or_null("%s/Interactable" % target_name)
		assert_not_null(target, "%s must keep its objective Interactable" % target_name)
		for context_path: String in bundles[target_name]:
			var context: Node = _root.get_node_or_null(context_path)
			assert_not_null(
				context, "%s context bundle must include %s" % [target_name, context_path]
			)
			if context != null:
				assert_true(
					_is_visible_through_ancestors(context),
					"%s context path must remain visible: %s" % [target_name, context_path]
				)


func test_objective_tables_keep_beta_target_paths_and_hidden_clue_non_objective() -> void:
	for target_path: String in OBJECTIVE_TARGET_PATHS:
		var root_name: String = target_path.get_slice("/", 0)
		assert_true(
			BetaDayOneController.BETA_KEEP_ROOT_NODES.has(StringName(root_name)),
			"%s must stay in the beta keep list" % root_name
		)
		assert_not_null(_root.get_node_or_null(target_path), "%s must exist" % target_path)
	var seen_paths: Array[String] = []
	for table: Array in [
		_controller().get("_training_objectives"),
		_controller().get("_day_one_objectives"),
	]:
		for entry: Dictionary in table:
			var target_path: String = str(entry.get("target_path", ""))
			assert_true(
				OBJECTIVE_TARGET_PATHS.has(target_path),
				"Objective target must remain one of the beta-critical interactables"
			)
			seen_paths.append(target_path)
	for target_path: String in OBJECTIVE_TARGET_PATHS:
		assert_true(seen_paths.has(target_path), "%s must be used by an objective" % target_path)
	assert_false(
		seen_paths.has("BetaHiddenClue/Interactable"),
		"BetaHiddenClue must remain ambient context, not an objective target"
	)


func test_checkout_and_hidden_clue_roles_do_not_compete_for_e_press() -> void:
	var passive_register_hint: Interactable = (
		_root.get_node_or_null("checkout_counter/RegisterStatusIndicator") as Interactable
	)
	assert_not_null(passive_register_hint)
	if passive_register_hint != null:
		assert_eq(passive_register_hint.proximity_radius, 0.0)
		assert_false(passive_register_hint.can_interact())
	for disabled_path: String in ["Checkout/Register", "checkout_counter/Interactable"]:
		var disabled_register: Interactable = _root.get_node_or_null(disabled_path) as Interactable
		assert_not_null(
			disabled_register, "%s must exist as a distinct checkout role" % disabled_path
		)
		if disabled_register != null:
			assert_false(
				disabled_register.enabled, "%s must not compete during beta" % disabled_path
			)
	assert_true(_root.get_node_or_null("RegisterArea") is Area3D)
	var hidden_clue: Interactable = (
		_root.get_node_or_null("BetaHiddenClue/Interactable") as Interactable
	)
	assert_not_null(hidden_clue, "BetaHiddenClue/Interactable must remain authored")
	if hidden_clue != null:
		assert_eq(hidden_clue.proximity_radius, 2.25)
		assert_eq(hidden_clue.proximity_facing_dot, 0.4)
		assert_false(hidden_clue.enabled)


func test_day_one_stage_gating_enables_only_current_target_and_ambient() -> void:
	var completed_for_close: Dictionary = {
		&"talk_to_customer": true,
		&"back_room_inventory": true,
		&"stock_shelf": true,
	}
	var stages: Array[Dictionary] = [
		{
			"stage": BetaDayOneController.STAGE_TALK_TO_CUSTOMER,
			"target": "BetaDayOneCustomer/Interactable",
			"completed": {},
		},
		{
			"stage": BetaDayOneController.STAGE_BACK_ROOM_INVENTORY,
			"target": "BetaBackroomPickup/Interactable",
			"completed": {&"talk_to_customer": true},
		},
		{
			"stage": BetaDayOneController.STAGE_STOCK_SHELF,
			"target": "BetaRestockShelf/Interactable",
			"completed": {&"talk_to_customer": true, &"back_room_inventory": true},
		},
		{
			"stage": BetaDayOneController.STAGE_END_DAY,
			"target": "BetaDayEndTrigger/Interactable",
			"completed": completed_for_close,
		},
	]
	for row: Dictionary in stages:
		_set_controller_stage(
			row["stage"], _controller().get("_day_one_objectives"), row["completed"]
		)
		_assert_only_expected_interactables_enabled(row["target"])


func test_training_stage_gating_enables_only_current_target_and_ambient() -> void:
	var stages: Array[Dictionary] = [
		{
			"stage": BetaDayOneController.STAGE_TRAINING_TALK_MANAGER,
			"target": "BetaDayOneCustomer/Interactable",
		},
		{
			"stage": BetaDayOneController.STAGE_TRAINING_CHECK_REGISTER,
			"target": "BetaDayEndTrigger/Interactable",
		},
		{
			"stage": BetaDayOneController.STAGE_TRAINING_BACK_ROOM,
			"target": "BetaBackroomPickup/Interactable",
		},
		{
			"stage": BetaDayOneController.STAGE_TRAINING_STOCK_SHELF,
			"target": "BetaRestockShelf/Interactable",
		},
	]
	for row: Dictionary in stages:
		_set_controller_stage(row["stage"], _controller().get("_training_objectives"), {})
		_assert_only_expected_interactables_enabled(row["target"])


func _controller() -> Node:
	if _root == null:
		return null
	return _root.get_node_or_null("BetaDayOneController")


func _set_controller_stage(stage: StringName, objectives: Array, completed: Dictionary) -> void:
	var controller: Node = _controller()
	assert_not_null(controller, "BetaDayOneController must exist")
	if controller == null:
		return
	controller.set("_objectives", objectives.duplicate(true))
	controller.set("_completed_objectives", completed.duplicate(true))
	controller.set("_stage", stage)
	controller.call("_apply_objective_gating")


func _assert_only_expected_interactables_enabled(target_path: String) -> void:
	var expected: Array[String] = APPROVED_AMBIENT_INTERACTABLES.duplicate()
	expected.append(target_path)
	expected.sort()
	var actual: Array[String] = _enabled_interactable_paths()
	actual.sort()
	assert_eq(
		actual,
		expected,
		"Only the active objective target and approved ambient interactables may be enabled"
	)


func _enabled_interactable_paths() -> Array[String]:
	var out: Array[String] = []
	for node: Node in get_tree().get_nodes_in_group("interactable"):
		if not (node is Interactable):
			continue
		var interactable: Interactable = node as Interactable
		if not _is_descendant_of(interactable, _root):
			continue
		if interactable.enabled:
			out.append(_relative_path(interactable))
	return out


func _collect_interactables(node: Node, out: Array[Interactable]) -> void:
	if node is Interactable:
		out.append(node as Interactable)
	for child: Node in node.get_children():
		_collect_interactables(child, out)


func _has_forbidden_visual_descendant(node: Node) -> bool:
	for child: Node in node.get_children():
		if (
			child is Interactable
			or child is ShelfSlot
			or child is Area3D
			or child is CollisionObject3D
			or child is CollisionShape3D
			or child is NavigationObstacle3D
			or child.get_script() != null
		):
			return true
		if _has_forbidden_visual_descendant(child):
			return true
	return false


func _has_visible_authored_surface(node: Node) -> bool:
	if (
		(node is MeshInstance3D or node is Label3D or node is Decal)
		and _is_visible_through_ancestors(node)
	):
		return true
	for child: Node in node.get_children():
		if _has_visible_authored_surface(child):
			return true
	return false


func _is_visible_through_ancestors(node: Node) -> bool:
	var current: Node = node
	while current != null and current != _root:
		if current is Node3D and not (current as Node3D).visible:
			return false
		current = current.get_parent()
	return true


func _is_descendant_of(node: Node, ancestor: Node) -> bool:
	var current: Node = node
	while current != null:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false


func _relative_path(node: Node) -> String:
	if _root == null or node == null:
		return ""
	return String(_root.get_path_to(node))
