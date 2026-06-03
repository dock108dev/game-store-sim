class_name StoreVisualScopeProfile
extends RefCounted

enum ScopeMode {
	AUTHORED_FULL,
	STORE_SESSION_RUNTIME,
	STORE_SESSION_REFERENCE_VISIBLE,
	SUPPRESSION_DIFF,
}

enum VisibilityDecision {
	VISIBLE,
	HIDDEN_RUNTIME_NOISE,
	DEFERRED_RUNTIME_ROOT,
	CONTEXT_ROOT,
	KEEP_ROOT,
	REFERENCE_VISIBLE,
	MISSING,
	CONFLICT,
}

const MODE_AUTHORED_FULL: int = ScopeMode.AUTHORED_FULL
const MODE_STORE_SESSION_RUNTIME: int = ScopeMode.STORE_SESSION_RUNTIME
const MODE_STORE_SESSION_REFERENCE_VISIBLE: int = ScopeMode.STORE_SESSION_REFERENCE_VISIBLE
const MODE_SUPPRESSION_DIFF: int = ScopeMode.SUPPRESSION_DIFF
const MODE_AUTHORED_FULL_LABEL: String = "authored_full"
const MODE_STORE_SESSION_RUNTIME_LABEL: String = "store_session_runtime"
const MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL: String = "store_session_reference_visible"
const MODE_SUPPRESSION_DIFF_LABEL: String = "suppression_diff"

const DECISION_VISIBLE: int = VisibilityDecision.VISIBLE
const DECISION_HIDDEN_RUNTIME_NOISE: int = VisibilityDecision.HIDDEN_RUNTIME_NOISE
const DECISION_DEFERRED_RUNTIME_ROOT: int = VisibilityDecision.DEFERRED_RUNTIME_ROOT
const DECISION_CONTEXT_ROOT: int = VisibilityDecision.CONTEXT_ROOT
const DECISION_KEEP_ROOT: int = VisibilityDecision.KEEP_ROOT
const DECISION_REFERENCE_VISIBLE: int = VisibilityDecision.REFERENCE_VISIBLE
const DECISION_MISSING: int = VisibilityDecision.MISSING
const DECISION_CONFLICT: int = VisibilityDecision.CONFLICT

const SOURCE_AUTHORED_SCENE: String = "authored_scene"
const SOURCE_HIDDEN_NOISE: String = "hidden_runtime_noise"
const SOURCE_DEFERRED_ROOT: String = "deferred_runtime_root"
const SOURCE_CONTEXT_ROOT: String = "context_root"
const SOURCE_KEEP_ROOT: String = "keep_root"
const SOURCE_REFERENCE_VISIBLE: String = "reference_visible"

const HIDDEN_NOISE_PATHS: Array[String] = [
	"new_console_display",
	"poster_slot",
	"delivery_manifest",
	"featured_display",
	"release_notes_clipboard",
	"employee_area",
	"StoreAtmosphereProps",
	"new_release_wall",
	"old_gen_shelf",
	"hold_shelf",
	"testing_station",
	"refurb_bench",
	"CartRackRight",
	"GlassCase",
	"ConsoleShelf",
	"AccessoriesBin",
	"bargain_bin",
	"crt_demo_area",
	"staff_picks_table",
	"ZoneLabels/ShelvesBacking",
	"ZoneLabels/ShelvesLabel",
	"ZoneLabels/BackroomBacking",
	"ZoneLabels/BackroomLabel",
	"ZoneLabels/UsedConsolesLabel",
	"ZoneLabels/StaffPicksLabel",
	"ReadabilityProps/UsedConsoleDressing",
	"ReadabilityProps/FloorDisplayIsland",
	"ReadabilityProps/DayOneRouteMarkers",
]

const DEFERRED_ROOT_NODES: Array[StringName] = [
	&"CartRackRight",
	&"GlassCase",
	&"ConsoleShelf",
	&"AccessoriesBin",
	&"bargain_bin",
	&"crt_demo_area",
	&"staff_picks_table",
]

const CONTEXT_ROOT_NODES: Array[StringName] = [
	&"ExpandableStoreShell",
]

const REFERENCE_VISIBLE_PATHS: Array[String] = [
	"Checkout",
	"CartRackLeft",
	"ReadabilityProps/CheckoutCounterDressing",
	"ReadabilityProps/ShelfSpineRuns",
	"ReadabilityProps/ProductDisplayRows",
	"ReadabilityProps/SpawnViewFloorDressing",
	"ReadabilityProps/DayOneRouteMarkers",
	"ReadabilityProps/ZoneIdentity",
	"ZoneLabels/ShelvesBacking",
	"ZoneLabels/ShelvesLabel",
	"ZoneLabels/BackroomBacking",
	"ZoneLabels/BackroomLabel",
]

const KEEP_ROOT_NODES: Array[StringName] = [
	&"PlayerController",
	&"PlayerEntrySpawn",
	&"FluorescentKeyLight",
	&"WarmNeonFill",
	&"GreenNeonFill",
	&"CheckoutLaneSpotlight",
	&"FrontLaneFill",
	&"CheckoutCounterPractical",
	&"BackroomUtilityLight",
	&"EntranceDoor",
	&"NavigationRegion3D",
	&"EntryArea",
	&"RegisterArea",
	&"checkout_counter",
	&"FrontLaneQueue",
	&"StoreSessionController",
	&"StoreSessionManager",
	&"StoreSessionDayOneCustomer",
	&"StoreSessionBackroomPickup",
	&"StoreSessionRestockShelf",
	&"StoreSessionDayEndTrigger",
	&"StoreSessionHiddenClue",
	&"BackOfficeTerminal",
	&"ExpandableStoreShell",
]

const KEEP_VISIBLE_PATHS: Array[String] = [
	"ReadabilityProps/ZoneIdentity/BackroomDoorThreshold",
	"ReadabilityProps/ZoneIdentity/BackroomThresholdLeftGuide",
	"ReadabilityProps/ZoneIdentity/BackroomThresholdRightGuide",
	"ReadabilityProps/ZoneIdentity/BackroomFloorMat",
	"ReadabilityProps/ZoneIdentity/ShelfStockAccent",
	"ReadabilityProps/ZoneIdentity/StarterTableFrontFootprint",
	"ReadabilityProps/ZoneIdentity/StarterTableLeftGuide",
	"ReadabilityProps/ZoneIdentity/StarterTableRightGuide",
	"ReadabilityProps/CheckoutCounterDressing",
	"ReadabilityProps/ShelfSpineRuns",
	"ReadabilityProps/ProductDisplayRows",
	"ReadabilityProps/SpawnViewFloorDressing",
	"ReadabilityProps/WallPosterRails",
	"ReadabilityProps/BackroomDressing",
]

const MINIMUM_TRACKED_PATHS: Array[String] = [
	"Checkout",
	"CartRackLeft",
	"CartRackRight",
	"GlassCase",
	"ConsoleShelf",
	"AccessoriesBin",
	"FrontLaneQueue",
	"ReadabilityProps/ZoneLighting",
	"ReadabilityProps/ZoneIdentity",
	"ReadabilityProps/WallPosterRails",
	"ReadabilityProps/ProductDisplayRows",
	"ReadabilityProps/ShelfFaceDressing",
	"ReadabilityProps/FloorDisplayIsland",
	"ReadabilityProps/SpawnViewFloorDressing",
	"ReadabilityProps/DayOneRouteMarkers",
	"ReadabilityProps/CheckoutCounterDressing",
	"ReadabilityProps/ShelfSpineRuns",
	"ReadabilityProps/UsedConsoleDressing",
	"ReadabilityProps/BackroomDressing",
]

const _DECISION_LABELS: Dictionary = {
	DECISION_VISIBLE: "visible",
	DECISION_HIDDEN_RUNTIME_NOISE: "hidden_runtime_noise",
	DECISION_DEFERRED_RUNTIME_ROOT: "deferred_runtime_root",
	DECISION_CONTEXT_ROOT: "context_root",
	DECISION_KEEP_ROOT: "keep_root",
	DECISION_REFERENCE_VISIBLE: "reference_visible",
	DECISION_MISSING: "missing",
	DECISION_CONFLICT: "conflict",
}

const _MODE_LABELS: Dictionary = {
	MODE_AUTHORED_FULL: MODE_AUTHORED_FULL_LABEL,
	MODE_STORE_SESSION_RUNTIME: MODE_STORE_SESSION_RUNTIME_LABEL,
	MODE_STORE_SESSION_REFERENCE_VISIBLE: MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL,
	MODE_SUPPRESSION_DIFF: MODE_SUPPRESSION_DIFF_LABEL,
}


## Returns a stable, serializable name for a scope mode.
static func mode_label(mode: int) -> String:
	return str(_MODE_LABELS.get(mode, MODE_AUTHORED_FULL_LABEL))


## Returns a stable, serializable name for a visibility decision.
static func decision_label(decision: int) -> String:
	return str(_DECISION_LABELS.get(decision, "visible"))


## Classifies one store-relative path for the requested visual scope.
static func classify_path(root: Node, path: String, mode: int) -> Dictionary:
	var normalized_path: String = path.strip_edges()
	var exists: bool = _node_exists(root, normalized_path)
	var hidden: bool = _matches_any_path(normalized_path, HIDDEN_NOISE_PATHS)
	var deferred: bool = _matches_any_root(normalized_path, DEFERRED_ROOT_NODES)
	var context: bool = _matches_any_root(normalized_path, CONTEXT_ROOT_NODES)
	var keep: bool = (
		_matches_any_root(normalized_path, KEEP_ROOT_NODES)
		or _matches_any_path(normalized_path, KEEP_VISIBLE_PATHS)
	)
	var reference: bool = _matches_any_path(normalized_path, REFERENCE_VISIBLE_PATHS)
	var conflict: bool = exists and hidden and reference
	var runtime_visible: bool = exists and (context or keep)
	var reference_visible: bool = exists and (context or keep or reference)
	var authored_visible: bool = exists
	var source_list: Array[String] = _source_list(
		exists,
		hidden,
		deferred,
		context,
		keep,
		reference
	)
	var decision: int = _decision_for_mode(
		mode,
		exists,
		hidden,
		deferred,
		context,
		keep,
		reference,
		conflict
	)
	var mode_visible: bool = _visible_for_mode(
		mode,
		authored_visible,
		runtime_visible,
		reference_visible
	)
	return {
		"path": normalized_path,
		"exists": exists,
		"authored_visible": authored_visible,
		"runtime_visible": runtime_visible,
		"reference_visible": reference_visible,
		"visible": mode_visible,
		"decision": decision,
		"decision_label": decision_label(decision),
		"reason": _reason_for_decision(decision),
		"source_list": source_list,
		"conflict": conflict,
		"conflict_flag": conflict,
		"mode": mode_label(mode),
	}


## Returns whether a path should be shown in the requested scope.
static func should_show_in_mode(root: Node, path: String, mode: int) -> bool:
	var decision: Dictionary = classify_path(root, path, mode)
	return bool(decision.get("visible", false))


## Builds a suppression-diff table for tracked or caller-supplied paths.
static func suppression_diff(root: Node, paths: Array[String] = []) -> Array[Dictionary]:
	var inspected_paths: Array[String] = paths
	if inspected_paths.is_empty():
		inspected_paths = tracked_paths()
	var rows: Array[Dictionary] = []
	for path: String in inspected_paths:
		rows.append(classify_path(root, path, MODE_SUPPRESSION_DIFF))
	return rows


## Returns the canonical path inventory used by galleries and suppression diffs.
static func tracked_paths() -> Array[String]:
	var paths: Array[String] = []
	_append_unique_values(paths, MINIMUM_TRACKED_PATHS)
	_append_unique_values(paths, HIDDEN_NOISE_PATHS)
	_append_unique_values(paths, DEFERRED_ROOT_NODES)
	_append_unique_values(paths, CONTEXT_ROOT_NODES)
	_append_unique_values(paths, REFERENCE_VISIBLE_PATHS)
	_append_unique_values(paths, KEEP_ROOT_NODES)
	_append_unique_values(paths, KEEP_VISIBLE_PATHS)
	paths.sort()
	return paths


## Applies a scope to tracked Node3D paths for tooling captures.
static func apply_mode_to_tree(root: Node, mode: int, paths: Array[String] = []) -> void:
	if root == null:
		return
	var inspected_paths: Array[String] = paths
	if inspected_paths.is_empty():
		inspected_paths = tracked_paths()
	for path: String in inspected_paths:
		var target: Node = root.get_node_or_null(NodePath(path))
		if not (target is Node3D):
			continue
		if should_show_in_mode(root, path, mode):
			_show_node_and_ancestors(root, target)
		else:
			(target as Node3D).visible = false


## Returns a compact manifest for review tools that need the shared policy names.
static func scope_manifest() -> Dictionary:
	return {
		"modes":
		[
			MODE_AUTHORED_FULL_LABEL,
			MODE_STORE_SESSION_RUNTIME_LABEL,
			MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL,
			MODE_SUPPRESSION_DIFF_LABEL,
		],
		"decisions": _DECISION_LABELS.values(),
		"tracked_paths": tracked_paths(),
		"known_conflict_paths": known_conflict_paths(),
	}


## Returns authored paths intentionally hidden at runtime but visible for reference review.
static func known_conflict_paths() -> Array[String]:
	var conflicts: Array[String] = []
	for path: String in HIDDEN_NOISE_PATHS:
		if _matches_any_path(path, REFERENCE_VISIBLE_PATHS):
			conflicts.append(path)
	conflicts.sort()
	return conflicts


static func _decision_for_mode(
	mode: int,
	exists: bool,
	hidden: bool,
	deferred: bool,
	context: bool,
	keep: bool,
	reference: bool,
	conflict: bool
) -> int:
	if not exists:
		return DECISION_MISSING
	match mode:
		MODE_AUTHORED_FULL:
			return DECISION_VISIBLE
		MODE_STORE_SESSION_RUNTIME:
			return _runtime_decision(hidden, deferred, context, keep)
		MODE_STORE_SESSION_REFERENCE_VISIBLE:
			return _reference_decision(hidden, deferred, context, keep, reference)
		MODE_SUPPRESSION_DIFF:
			return _diff_decision(hidden, deferred, context, keep, reference, conflict)
		_:
			return DECISION_VISIBLE


static func _runtime_decision(hidden: bool, deferred: bool, context: bool, keep: bool) -> int:
	if context:
		return DECISION_CONTEXT_ROOT
	if keep:
		return DECISION_KEEP_ROOT
	if deferred:
		return DECISION_DEFERRED_RUNTIME_ROOT
	if hidden:
		return DECISION_HIDDEN_RUNTIME_NOISE
	return DECISION_HIDDEN_RUNTIME_NOISE


static func _reference_decision(
	hidden: bool,
	deferred: bool,
	context: bool,
	keep: bool,
	reference: bool
) -> int:
	if context:
		return DECISION_CONTEXT_ROOT
	if keep:
		return DECISION_KEEP_ROOT
	if reference:
		return DECISION_REFERENCE_VISIBLE
	if deferred:
		return DECISION_DEFERRED_RUNTIME_ROOT
	if hidden:
		return DECISION_HIDDEN_RUNTIME_NOISE
	return DECISION_HIDDEN_RUNTIME_NOISE


static func _diff_decision(
	hidden: bool,
	deferred: bool,
	context: bool,
	keep: bool,
	reference: bool,
	conflict: bool
) -> int:
	if conflict:
		return DECISION_CONFLICT
	if context:
		return DECISION_CONTEXT_ROOT
	if keep:
		return DECISION_KEEP_ROOT
	if reference:
		return DECISION_REFERENCE_VISIBLE
	if deferred:
		return DECISION_DEFERRED_RUNTIME_ROOT
	if hidden:
		return DECISION_HIDDEN_RUNTIME_NOISE
	return DECISION_VISIBLE


static func _visible_for_mode(
	mode: int,
	authored_visible: bool,
	runtime_visible: bool,
	reference_visible: bool
) -> bool:
	match mode:
		MODE_STORE_SESSION_RUNTIME:
			return runtime_visible
		MODE_STORE_SESSION_REFERENCE_VISIBLE:
			return reference_visible
		MODE_SUPPRESSION_DIFF:
			return authored_visible
		_:
			return authored_visible


static func _reason_for_decision(decision: int) -> String:
	match decision:
		DECISION_HIDDEN_RUNTIME_NOISE:
			return "Hidden by store-session runtime scope to reduce Day-1 visual noise."
		DECISION_DEFERRED_RUNTIME_ROOT:
			return "Deferred runtime root remains authored for full-store review."
		DECISION_CONTEXT_ROOT:
			return "Context root remains visible because route review depends on it."
		DECISION_KEEP_ROOT:
			return "Keep root remains visible for store-session operation."
		DECISION_REFERENCE_VISIBLE:
			return "Reference-visible path stays available for route visual review."
		DECISION_MISSING:
			return "Path is not present under the inspected store root."
		DECISION_CONFLICT:
			return "Path is runtime-hidden but intentionally reference-visible."
		_:
			return "Visible authored store content."


static func _source_list(
	exists: bool,
	hidden: bool,
	deferred: bool,
	context: bool,
	keep: bool,
	reference: bool
) -> Array[String]:
	var source_list: Array[String] = []
	if exists:
		source_list.append(SOURCE_AUTHORED_SCENE)
	if hidden:
		source_list.append(SOURCE_HIDDEN_NOISE)
	if deferred:
		source_list.append(SOURCE_DEFERRED_ROOT)
	if context:
		source_list.append(SOURCE_CONTEXT_ROOT)
	if keep:
		source_list.append(SOURCE_KEEP_ROOT)
	if reference:
		source_list.append(SOURCE_REFERENCE_VISIBLE)
	return source_list


static func _node_exists(root: Node, path: String) -> bool:
	if root == null or path.is_empty():
		return false
	return root.has_node(NodePath(path))


static func _matches_any_path(path: String, candidates: Array[String]) -> bool:
	if path.is_empty():
		return false
	for candidate: String in candidates:
		if path == candidate or path.begins_with("%s/" % candidate):
			return true
	return false


static func _matches_any_root(path: String, roots: Array[StringName]) -> bool:
	if path.is_empty():
		return false
	var first_segment: String = path.get_slice("/", 0)
	for root: StringName in roots:
		if first_segment == String(root):
			return true
	return false


static func _append_unique_values(out: Array[String], values: Variant) -> void:
	if not (values is Array):
		return
	var items: Array = values as Array
	for value: Variant in items:
		var text: String = str(value)
		if not out.has(text):
			out.append(text)


static func _show_node_and_ancestors(root: Node, target: Node) -> void:
	var current: Node = target
	while current != null and current != root:
		if current is Node3D:
			(current as Node3D).visible = true
		current = current.get_parent()
