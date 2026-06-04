extends GutTest

const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)

const REQUIRED_KEEP_ROOTS: Array[StringName] = [
	&"checkout_counter",
	&"FrontLaneQueue",
	&"StoreSessionBackroomPickup",
	&"StoreSessionRestockShelf",
	&"StoreSessionDayEndTrigger",
	&"BackOfficeTerminal",
	&"ExpandableStoreShell",
]

const REQUIRED_KEEP_VISIBLE_PATHS: Array[String] = [
	"ReadabilityProps/ZoneIdentity/BackroomDoorThreshold",
	"ReadabilityProps/ZoneIdentity/BackroomThresholdLeftGuide",
	"ReadabilityProps/ZoneIdentity/BackroomThresholdRightGuide",
	"ReadabilityProps/ZoneIdentity/ShelfStockAccent",
	"ReadabilityProps/ZoneIdentity/StarterTableFrontFootprint",
	"ReadabilityProps/ZoneIdentity/StarterTableLeftGuide",
	"ReadabilityProps/ZoneIdentity/StarterTableRightGuide",
	"ReadabilityProps/WallPosterRails",
	"ReadabilityProps/BackroomDressing",
]

const REQUIRED_DEFERRED_ROOTS: Array[StringName] = [
	&"ConsoleShelf",
	&"GlassCase",
	&"crt_demo_area",
	&"staff_picks_table",
]

const REQUIRED_HIDDEN_NOISE_PATHS: Array[String] = [
	"ConsoleShelf",
	"GlassCase",
	"crt_demo_area",
	"staff_picks_table",
	"ZoneLabels/ShelvesLabel",
	"ZoneLabels/BackroomLabel",
	"ReadabilityProps/CheckoutCounterDressing",
	"ReadabilityProps/ShelfSpineRuns",
	"ReadabilityProps/ProductDisplayRows",
	"ReadabilityProps/SpawnViewFloorDressing",
	"ReadabilityProps/DayOneRouteMarkers",
]

const REQUIRED_CONFLICT_PATHS: Array[String] = [
	"ReadabilityProps/DayOneRouteMarkers",
	"ReadabilityProps/CheckoutCounterDressing",
	"ReadabilityProps/ShelfSpineRuns",
	"ReadabilityProps/ProductDisplayRows",
	"ReadabilityProps/SpawnViewFloorDressing",
	"ZoneLabels/ShelvesLabel",
	"ZoneLabels/BackroomLabel",
]

var _root: Node3D = null


func before_each() -> void:
	_root = Node3D.new()
	_root.name = "StoreRoot"
	add_child(_root)
	for path: String in [
			"ReadabilityProps/UsedConsoleDressing/ConsoleTowerA",
			"ReadabilityProps/ProductDisplayRows/ShelfProductBacker",
			"ReadabilityProps/DayOneRouteMarkers/FloorCueA",
			"CartRackRight/ProductStackA",
			"StoreSessionRestockShelf/Interactable",
			"ReadabilityProps/ZoneIdentity/StarterTableFrontFootprint",
			"ReadabilityProps/CheckoutCounterDressing/RegisterReceiptStack",
			"ReadabilityProps/SpawnViewFloorDressing/EntryWearStrip",
			"ReadabilityProps/WallPosterRails/PosterRailA",
			"ReadabilityProps/BackroomDressing/ReceivingClipboard",
			"ZoneLabels/ShelvesLabel",
			"ZoneLabels/BackroomLabel",
			"ExpandableStoreShell/StarterSignLabel",
		"Checkout/Register/RegisterScreen",
		"LooseDecorPoster",
	]:
		_add_path(path)


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null


func test_profile_exposes_shared_scope_modes() -> void:
	var manifest: Dictionary = StoreVisualScopeProfileScript.scope_manifest()
	var modes: Array = manifest.get("modes", []) as Array
	for required: String in [
		StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL,
		StoreVisualScopeProfileScript.MODE_SUPPRESSION_DIFF_LABEL,
	]:
		assert_true(modes.has(required), "Scope manifest must expose %s" % required)


func test_profile_lists_day_one_keep_roots() -> void:
	for root_name: StringName in REQUIRED_KEEP_ROOTS:
		assert_true(
			StoreVisualScopeProfileScript.KEEP_ROOT_NODES.has(root_name),
			"%s must stay in the Day-1 keep root list" % String(root_name)
		)
	for node_path: String in REQUIRED_KEEP_VISIBLE_PATHS:
		assert_true(
			StoreVisualScopeProfileScript.KEEP_VISIBLE_PATHS.has(node_path),
			"%s must stay visible as a Day-1 physical affordance" % node_path
		)


func test_profile_lists_deferred_roots_and_runtime_hidden_noise() -> void:
	for root_name: StringName in REQUIRED_DEFERRED_ROOTS:
		assert_true(
			StoreVisualScopeProfileScript.DEFERRED_ROOT_NODES.has(root_name),
			"%s must stay deferred from Day-1 runtime" % String(root_name)
		)
	for node_path: String in REQUIRED_HIDDEN_NOISE_PATHS:
		assert_true(
			StoreVisualScopeProfileScript.HIDDEN_NOISE_PATHS.has(node_path),
			"%s must stay runtime-hidden by the shared scope profile" % node_path
		)


func test_profile_documents_intentional_hidden_reference_conflicts() -> void:
	var conflicts: Array[String] = StoreVisualScopeProfileScript.known_conflict_paths()
	for node_path: String in REQUIRED_CONFLICT_PATHS:
		assert_true(
			conflicts.has(node_path),
			"%s must remain hidden at runtime but available in reference review" % node_path
		)


func test_hidden_noise_decision_reports_runtime_suppression() -> void:
	var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
		_root,
		"ReadabilityProps/UsedConsoleDressing/ConsoleTowerA",
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
	)
	assert_true(bool(decision.get("exists", false)))
	assert_true(bool(decision.get("authored_visible", false)))
	assert_false(bool(decision.get("runtime_visible", true)))
	assert_false(bool(decision.get("visible", true)))
	assert_eq(
		int(decision.get("decision", -1)),
		StoreVisualScopeProfileScript.DECISION_HIDDEN_RUNTIME_NOISE
	)
	assert_true(
		(decision.get("source_list", []) as Array)
		.has(StoreVisualScopeProfileScript.SOURCE_HIDDEN_NOISE)
	)


func test_deferred_root_decision_reports_future_content_scope() -> void:
	var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
		_root,
		"CartRackRight/ProductStackA",
		StoreVisualScopeProfileScript.MODE_SUPPRESSION_DIFF
	)
	assert_true(bool(decision.get("exists", false)))
	assert_false(bool(decision.get("runtime_visible", true)))
	assert_eq(
		int(decision.get("decision", -1)),
		StoreVisualScopeProfileScript.DECISION_DEFERRED_RUNTIME_ROOT
	)
	var sources: Array = decision.get("source_list", []) as Array
	assert_true(sources.has(StoreVisualScopeProfileScript.SOURCE_DEFERRED_ROOT))
	assert_true(sources.has(StoreVisualScopeProfileScript.SOURCE_HIDDEN_NOISE))


func test_keep_and_context_roots_remain_visible_with_distinct_reasons() -> void:
	var keep_decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
		_root,
		"StoreSessionRestockShelf/Interactable",
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
	)
	assert_true(bool(keep_decision.get("runtime_visible", false)))
	assert_eq(
		int(keep_decision.get("decision", -1)),
		StoreVisualScopeProfileScript.DECISION_KEEP_ROOT
	)

	var context_decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
		_root,
		"ExpandableStoreShell/StarterSignLabel",
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
	)
	assert_true(bool(context_decision.get("runtime_visible", false)))
	assert_eq(
		int(context_decision.get("decision", -1)),
		StoreVisualScopeProfileScript.DECISION_CONTEXT_ROOT
	)


func test_unclassified_authored_root_is_not_store_session_runtime_visible() -> void:
	var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
		_root,
		"LooseDecorPoster",
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
	)
	assert_true(bool(decision.get("exists", false)))
	assert_true(bool(decision.get("authored_visible", false)))
	assert_false(bool(decision.get("runtime_visible", true)))
	assert_false(bool(decision.get("visible", true)))
	assert_eq(
		int(decision.get("decision", -1)),
		StoreVisualScopeProfileScript.DECISION_HIDDEN_RUNTIME_NOISE
	)


func test_reference_visible_decision_keeps_route_review_anchor() -> void:
	var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
		_root,
		"Checkout/Register/RegisterScreen",
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE
	)
	assert_true(bool(decision.get("reference_visible", false)))
	assert_true(bool(decision.get("visible", false)))
	assert_eq(
		int(decision.get("decision", -1)),
		StoreVisualScopeProfileScript.DECISION_REFERENCE_VISIBLE
	)
	assert_true(
		(decision.get("source_list", []) as Array)
		.has(StoreVisualScopeProfileScript.SOURCE_REFERENCE_VISIBLE)
	)


func test_missing_decision_reports_absent_path() -> void:
	var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
		_root,
		"ReadabilityProps/MissingLandmark",
		StoreVisualScopeProfileScript.MODE_SUPPRESSION_DIFF
	)
	assert_false(bool(decision.get("exists", true)))
	assert_false(bool(decision.get("authored_visible", true)))
	assert_false(bool(decision.get("runtime_visible", true)))
	assert_false(bool(decision.get("reference_visible", true)))
	assert_eq(
		int(decision.get("decision", -1)),
		StoreVisualScopeProfileScript.DECISION_MISSING
	)


func test_conflict_decision_reports_runtime_hidden_reference_visible_path() -> void:
	var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
		_root,
		"ReadabilityProps/DayOneRouteMarkers/FloorCueA",
		StoreVisualScopeProfileScript.MODE_SUPPRESSION_DIFF
	)
	assert_true(bool(decision.get("exists", false)))
	assert_true(bool(decision.get("authored_visible", false)))
	assert_false(bool(decision.get("runtime_visible", true)))
	assert_true(bool(decision.get("reference_visible", false)))
	assert_true(bool(decision.get("conflict_flag", false)))
	assert_eq(
		int(decision.get("decision", -1)),
		StoreVisualScopeProfileScript.DECISION_CONFLICT
	)
	var sources: Array = decision.get("source_list", []) as Array
	assert_true(sources.has(StoreVisualScopeProfileScript.SOURCE_HIDDEN_NOISE))
	assert_true(sources.has(StoreVisualScopeProfileScript.SOURCE_REFERENCE_VISIBLE))


func test_day_one_retail_affordances_are_runtime_visible_keep_paths() -> void:
	for node_path: String in [
		"ReadabilityProps/WallPosterRails/PosterRailA",
		"ReadabilityProps/BackroomDressing/ReceivingClipboard",
	]:
		var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
			_root,
			node_path,
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
		)
		assert_true(bool(decision.get("exists", false)), "%s fixture must exist" % node_path)
		assert_true(
			bool(decision.get("runtime_visible", false)),
			"%s must stay visible in Day-1 runtime scope" % node_path
		)
		assert_eq(
			int(decision.get("decision", -1)),
			StoreVisualScopeProfileScript.DECISION_KEEP_ROOT
		)
		assert_true(
			(decision.get("source_list", []) as Array)
			.has(StoreVisualScopeProfileScript.SOURCE_KEEP_ROOT)
		)


func test_authored_reference_dressing_is_not_store_session_runtime_visible() -> void:
	for node_path: String in [
		"ReadabilityProps/ProductDisplayRows/ShelfProductBacker",
		"ReadabilityProps/CheckoutCounterDressing/RegisterReceiptStack",
		"ReadabilityProps/SpawnViewFloorDressing/EntryWearStrip",
	]:
		var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
			_root,
			node_path,
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
		)
		assert_true(bool(decision.get("exists", false)), "%s fixture must exist" % node_path)
		assert_false(
			bool(decision.get("runtime_visible", true)),
			"%s must stay authored-reference dressing, not runtime clutter" % node_path
		)
		assert_eq(
			int(decision.get("decision", -1)),
			StoreVisualScopeProfileScript.DECISION_HIDDEN_RUNTIME_NOISE
		)


func test_authored_full_scope_preserves_runtime_hidden_dressing() -> void:
	var decision: Dictionary = StoreVisualScopeProfileScript.classify_path(
		_root,
		"ReadabilityProps/UsedConsoleDressing/ConsoleTowerA",
		StoreVisualScopeProfileScript.MODE_AUTHORED_FULL
	)
	assert_true(bool(decision.get("authored_visible", false)))
	assert_true(bool(decision.get("visible", false)))
	assert_eq(int(decision.get("decision", -1)), StoreVisualScopeProfileScript.DECISION_VISIBLE)


func _add_path(path: String) -> Node:
	var current: Node = _root
	for raw_segment: String in path.split("/"):
		var segment: String = raw_segment.strip_edges()
		if segment.is_empty():
			continue
		var child: Node = current.get_node_or_null(NodePath(segment))
		if child == null:
			child = Node3D.new()
			child.name = segment
			current.add_child(child)
		current = child
	return current
