extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const ExpandableStoreShellRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/expandable_store_shell_runtime.gd"
)

const GENERATED_VISUAL_ONLY_SURFACES: Array[String] = [
	"ExpandableStoreShell/CheckoutRegisterScreen",
	"ExpandableStoreShell/CheckoutReceiptPrinterBody",
	"ExpandableStoreShell/CheckoutCardReader",
	"ExpandableStoreShell/StarterDisplayTableTray",
	"ExpandableStoreShell/StockroomReceivingTableTop",
	"ExpandableStoreShell/StockroomExpandedBoxWall00",
	"ExpandableStoreShell/StockroomExpandedRollingLadderFrame",
]
const HIDDEN_AUTHORED_BOOT_ROOTS: Array[String] = [
	"Checkout",
	"back_room",
	"StoreSessionBackroomWallSide",
	"StoreSessionBackroomWallFrontLeft",
	"StoreSessionBackroomWallFrontRight",
]

var _root: Node3D
var _saved_state: GameManager.State
var _saved_day: int


func before_each() -> void:
	_saved_state = GameManager.current_state
	_saved_day = GameManager.get_current_day()
	GameManager.current_state = GameManager.State.STORE_VIEW
	GameManager.set_current_day(1)
	StoreSessionState.reset_new_run()
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
	StoreSessionState.reset_new_run()
	GameManager.current_state = _saved_state
	GameManager.set_current_day(_saved_day)


func test_visual_sweep_route_paths_match_declared_scope_policy() -> void:
	for row: Dictionary in StoreVisualSweepScript.rows():
		var mode: int = _scope_mode_from_label(str(row.get("visual_scope_mode", "")))
		var review_paths: Array[String] = _review_paths_for_row(row)
		StoreVisualScopeProfileScript.apply_mode_to_tree(_root, mode, review_paths)
		for node_path: String in review_paths:
			var target: Node = _root.get_node_or_null(NodePath(node_path))
			assert_not_null(
				target,
				"%s review path must exist for %s" % [node_path, str(row.get("name", ""))]
			)
			if target == null:
				continue
			var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
				_root,
				node_path,
				mode
			)
			assert_true(
				bool(decision.get("visible", false)),
				(
					"%s review path %s must be visible in declared scope %s; got %s"
					% [
						str(row.get("name", "")),
						node_path,
						str(row.get("visual_scope_mode", "")),
						str(decision.get("decision_label", "")),
					]
				)
			)
			if target is Node3D:
				assert_true(
					_is_visible_through_ancestors(target),
					"%s must be tool-visible after applying declared review scope" % node_path
				)


func test_shell_hidden_authored_roots_do_not_own_controller_targets() -> void:
	var hidden_roots: Array[String] = ExpandableStoreShellRuntimeScript.hidden_authored_visual_roots()
	var controller: Node = _controller()
	assert_not_null(controller, "StoreSessionController must exist")
	if controller == null:
		return
	var tables: Array = [
		controller.get("_training_objectives"),
		controller.get("_day_one_objectives"),
	]
	for table_variant: Variant in tables:
		var objective_table: Array = table_variant as Array
		for entry: Dictionary in objective_table:
			var target_path: String = str(entry.get("target_path", ""))
			assert_false(target_path.is_empty(), "Controller objective target path must be explicit")
			assert_false(
				_path_is_under_any(target_path, hidden_roots),
				"%s must not be owned by a shell-hidden authored visual root" % target_path
			)
			var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
				_root,
				target_path,
				StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
			)
			assert_true(
				bool(decision.get("runtime_visible", false)),
				"%s must be visible through store-session runtime scope" % target_path
			)


func test_shell_hidden_reference_props_stay_tool_visible_only() -> void:
	var hidden_roots: Array[String] = ExpandableStoreShellRuntimeScript.hidden_authored_visual_roots()
	for node_path: String in StoreVisualScopeProfileScript.REFERENCE_VISIBLE_PATHS:
		if not _root.has_node(NodePath(node_path)):
			continue
		assert_true(
			_path_is_under_any(node_path, hidden_roots),
			"%s must stay explicitly owned by shell-hidden authored reference policy" % node_path
		)
		var runtime_decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
			_root,
			node_path,
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
		)
		assert_false(
			bool(runtime_decision.get("visible", true)),
			"%s must not become normal runtime clutter" % node_path
		)
		var reference_decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
			_root,
			node_path,
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE
		)
		assert_true(
			bool(reference_decision.get("visible", false)),
			"%s must remain available to reference-visible tooling" % node_path
		)
		var reference_paths: Array[String] = [node_path]
		StoreVisualScopeProfileScript.apply_mode_to_tree(
			_root,
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE,
			reference_paths
		)
		var target: Node = _root.get_node_or_null(NodePath(node_path))
		if target is Node3D:
			assert_true(
				_is_visible_through_ancestors(target),
				"%s must become visible when reference-visible tooling requests it" % node_path
			)


func test_hidden_authored_boot_roots_stay_out_of_runtime_scope() -> void:
	var hidden_roots: Array[String] = ExpandableStoreShellRuntimeScript.hidden_authored_visual_roots()
	for node_path: String in HIDDEN_AUTHORED_BOOT_ROOTS:
		assert_true(
			hidden_roots.has(node_path),
			"%s must stay registered as generated-shell hidden authored presentation" % node_path
		)
		var node: Node = _root.get_node_or_null(NodePath(node_path))
		assert_not_null(node, "%s must remain authored for drift coverage" % node_path)
		if node == null:
			continue
		var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
			_root,
			node_path,
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
		)
		assert_false(
			bool(decision.get("visible", true)),
			"%s must not become visible through store-session runtime scope" % node_path
		)
		if node is Node3D:
			assert_false(
				_is_visible_through_ancestors(node),
				"%s must stay hidden in the Day-1 generated shell" % node_path
			)


func test_generated_shell_visual_only_surfaces_remain_non_gameplay() -> void:
	for node_path: String in GENERATED_VISUAL_ONLY_SURFACES:
		var node: Node = _root.get_node_or_null(NodePath(node_path))
		assert_not_null(node, "%s must exist as generated shell visual context" % node_path)
		if node == null:
			continue
		assert_false(
			_has_forbidden_visual_descendant(node),
			"%s must not gain interactable, route-trigger, or physics descendants" % node_path
		)


func _controller() -> Node:
	if _root == null:
		return null
	return _root.get_node_or_null("StoreSessionController")


func _scope_mode_from_label(label: String) -> int:
	match label:
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL:
			return StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL:
			return StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE
		StoreVisualScopeProfileScript.MODE_SUPPRESSION_DIFF_LABEL:
			return StoreVisualScopeProfileScript.MODE_SUPPRESSION_DIFF
		_:
			return StoreVisualScopeProfileScript.MODE_AUTHORED_FULL


func _review_paths_for_row(row: Dictionary) -> Array[String]:
	var out: Array[String] = []
	_append_review_path(out, str(row.get("focus", "")))
	_append_review_path(out, str(row.get("route_anchor", "")))
	_append_review_path(out, str(row.get("primary_work_surface_target", "")))
	for anchor: Variant in row.get("anchors", []) as Array:
		_append_review_path(out, str(anchor))
	var action_context: Dictionary = row.get("action_context", {}) as Dictionary
	_append_review_path(out, str(action_context.get("active_target", "")))
	for candidate_variant: Variant in action_context.get("actionable_candidates", []) as Array:
		var candidate: Dictionary = candidate_variant as Dictionary
		_append_review_path(out, str(candidate.get("path", "")))
	return out


func _append_review_path(out: Array[String], node_path: String) -> void:
	var normalized: String = node_path.strip_edges()
	if normalized.is_empty() or out.has(normalized):
		return
	out.append(normalized)


func _path_is_under_any(node_path: String, roots: Array[String]) -> bool:
	for root_path: String in roots:
		if node_path == root_path or node_path.begins_with("%s/" % root_path):
			return true
	return false


func _has_forbidden_visual_descendant(node: Node) -> bool:
	if (
		node is Interactable
		or node is ShelfSlot
		or node is Area3D
		or node is PhysicsBody3D
		or node is CollisionObject3D
		or node is CollisionShape3D
		or node is NavigationObstacle3D
		or node.get_script() != null
	):
		return true
	for child: Node in node.get_children():
		if _has_forbidden_visual_descendant(child):
			return true
	return false


func _is_visible_through_ancestors(node: Node) -> bool:
	var current: Node = node
	while current != null and current != _root:
		if current is Node3D and not (current as Node3D).visible:
			return false
		current = current.get_parent()
	return true
