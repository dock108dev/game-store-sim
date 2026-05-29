extends GutTest

const _StoreVisualSweep: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)
const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const REFERENCE_REVIEW_MODE_SETTING: String = "mallcore/test/reference_corner_review_mode"
const LOCKED_FEATURE_ROOTS: Array[String] = [
	"crt_demo_area",
	"staff_picks_table",
	"testing_station",
]
const REQUIRED_FIRST_TEN_SECONDS_BEATS: Array[String] = [
	"spawn_first_look",
	"checkout_manager_counter",
	"shelf_wall_product_focus",
	"stockroom_looking_in",
	"stockroom_work_area_interior",
	"exit_threshold_return_view",
]

var _root: Node3D = null
var _camera: Camera3D = null
var _saved_state: GameManager.State
var _saved_day: int
var _saved_reference_review_mode: Variant


func before_each() -> void:
	_saved_state = GameManager.current_state
	_saved_day = GameManager.get_current_day()
	_saved_reference_review_mode = ProjectSettings.get_setting(
		REFERENCE_REVIEW_MODE_SETTING, false
	)
	ProjectSettings.set_setting(REFERENCE_REVIEW_MODE_SETTING, true)
	GameManager.current_state = GameManager.State.STORE_VIEW
	GameManager.set_current_day(1)
	StoreSessionState.reset_new_run()
	StoreSessionState.preopening_complete = true
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()
	InteractionPrompt._reset_for_tests()

	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "Retro Games scene must load for validation")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame

	_camera = Camera3D.new()
	_camera.name = "VisualValidationSweepCamera"
	_camera.fov = 70.0
	_camera.near = 0.05
	_root.add_child(_camera)
	_camera.current = true
	await get_tree().process_frame


func after_each() -> void:
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	InteractionPrompt._reset_for_tests()
	if is_instance_valid(_root):
		_root.free()
	_root = null
	_camera = null
	StoreSessionState.reset_new_run()
	GameManager.current_state = _saved_state
	GameManager.set_current_day(_saved_day)
	ProjectSettings.set_setting(REFERENCE_REVIEW_MODE_SETTING, _saved_reference_review_mode)


func test_first_ten_seconds_sweep_frames_store_review_anchors() -> void:
	var rows: Array[Dictionary] = _sweep_rows()
	assert_eq(rows.size(), 6, "Validation sweep must cover six first-ten-seconds route views")
	var seen_beats: Array[String] = []
	for row: Dictionary in rows:
		seen_beats.append(str(row.get("name", "")))
		_assert_sweep_row_frames_focus(row)
		assert_eq(str(row.get("scope", "")), "first_ten_seconds")
		assert_true(
			[
				StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
				StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL,
			].has(str(row.get("visual_scope_mode", ""))),
			"%s sweep must declare a runtime or reference-visible visual scope" % row["name"]
		)
		assert_eq(
			str(row.get("review_target", "")),
			_StoreVisualSweep.ACCEPTANCE_TARGET,
			"%s sweep must target first-ten-seconds acceptance" % row["name"]
		)
		assert_eq(
			str(row.get("hud_context_required", "")),
			_StoreVisualSweep.HUD_CONTEXT_LABEL,
			"%s sweep must require first-day HUD context" % row["name"]
		)
		assert_false(
			str(row.get("next_destination", "")).is_empty(),
			"%s sweep must name the destination a first-run player should infer" % row["name"]
		)
		assert_false(
			str(row.get("active_route_stage", "")).is_empty(),
			"%s sweep must identify the active route stage" % row["name"]
		)
		assert_false(
			str(row.get("active_prompt", "")).is_empty(),
			"%s sweep must record the active prompt reviewers should see" % row["name"]
		)
		assert_false(
			str(row.get("next_expected_beat", "")).is_empty(),
			"%s sweep must record the next expected route beat" % row["name"]
		)
		assert_false(
			str(row.get("route_anchor", "")).contains("ReadabilityProps/DayOneRouteMarkers"),
			"%s sweep must target generated-shell or live route landmarks" % row["name"]
		)
		assert_false(
			str(row.get("local_action", "")).is_empty(),
			"%s sweep must name the local action a first-run player should infer" % row["name"]
		)
		assert_false(
			str(row.get("primary_work_surface_target", "")).is_empty(),
			"%s sweep must identify the primary work-surface target" % row["name"]
		)
		var work_surface_review: Dictionary = row.get("work_surface_review", {}) as Dictionary
		assert_false(
			work_surface_review.is_empty(),
			"%s sweep must declare a work-surface review contract" % row["name"]
		)
		assert_true(
			bool(work_surface_review.get("dominance_required", false)),
			"%s sweep must judge primary surface dominance" % row["name"]
		)
		assert_true(
			str(work_surface_review.get("primary_action_surface", "")) \
					== str(row.get("primary_work_surface_target", "")),
			"%s sweep primary action surface must match its target" % row["name"]
		)
		var design_checks: Array = row.get("design_checks", []) as Array
		for design_check: String in _StoreVisualSweep.route_design_checks():
			assert_true(
				design_checks.has(design_check),
				"%s sweep must include design check %s" % [row["name"], design_check]
			)
		assert_true(
			bool(work_surface_review.get("supporting_props_should_stay_quiet", false)),
			"%s sweep must judge supporting prop quietness" % row["name"]
		)
		var route_anchor: Node3D = _node3d(str(row.get("route_anchor", "")))
		assert_not_null(
			route_anchor,
			"%s sweep must keep a route anchor aligned with the tutorial" % row["name"]
		)
		for anchor_path: String in row["anchors"]:
			var anchor: Node3D = _node3d(anchor_path)
			assert_not_null(
				anchor,
				"%s sweep must keep anchor %s" % [row["name"], anchor_path]
			)
			if anchor != null:
				assert_true(
					_is_visible_through_ancestors(anchor),
					"%s sweep anchor must be visible: %s" % [row["name"], anchor_path]
				)
	for required: String in REQUIRED_FIRST_TEN_SECONDS_BEATS:
		assert_true(
			seen_beats.has(required),
			"First-ten-seconds sweep must include phase beat %s" % required
		)


func test_screenshot_sweep_writes_named_artifacts_for_review() -> void:
	var rows: Array[Dictionary] = _sweep_rows()
	for row: Dictionary in rows:
		_assert_sweep_row_frames_focus(row)
		await get_tree().process_frame
		var result: Dictionary = _StoreVisualSweep.save_viewport_png(
			get_viewport(),
			_StoreVisualSweep.visual_sweep_dir(),
			str(row["filename"]),
			true
		)
		assert_true(
			bool(result.get("ok", false)),
			"%s sweep screenshot must save: %s"
			% [row["name"], str(result.get("error", ""))]
		)
		if bool(result.get("ok", false)):
			assert_true(
				FileAccess.file_exists(str(result["path"])),
				"%s sweep screenshot must exist on disk" % row["name"]
			)
			assert_gt(
				int(result.get("width", 0)),
				0,
				"%s sweep screenshot must have a rendered width" % row["name"]
			)
			assert_gt(
				int(result.get("height", 0)),
				0,
				"%s sweep screenshot must have a rendered height" % row["name"]
			)
			if bool(result.get("placeholder", false)):
				assert_eq(
					DisplayServer.get_name(),
					"headless",
					"Placeholder sweep images are only allowed under headless display"
				)
				assert_true(
					bool(result.get("non_acceptance_evidence", false)),
					"Placeholder sweep images must be marked non-acceptance evidence"
				)
				assert_false(
					bool(result.get("acceptance_evidence", true)),
					"Placeholder sweep images must not count as acceptance evidence"
				)

	var manifest: Dictionary = _StoreVisualSweep.write_review_manifest(
		_StoreVisualSweep.review_manifest_dir(),
		rows
	)
	assert_true(
		bool(manifest.get("ok", false)),
		"Screenshot sweep must write a review manifest: %s" % str(manifest.get("error", ""))
	)
	if bool(manifest.get("ok", false)):
		assert_true(
			FileAccess.file_exists(str(manifest["path"])),
			"Screenshot sweep review manifest must exist on disk"
		)
		var payload: Dictionary = _read_json_file(str(manifest["path"]))
		assert_eq(str(payload.get("acceptance_target", "")), _StoreVisualSweep.ACCEPTANCE_TARGET)
		var beats: Array = payload.get("beats", []) as Array
		assert_eq(beats.size(), rows.size(), "Manifest must write one entry per artifact")
		var template: Dictionary = payload.get("manual_review_template", {}) as Dictionary
		var verdicts: Array = template.get("verdicts", []) as Array
		assert_eq(verdicts.size(), rows.size(), "Manifest must include one verdict per artifact")
		var full_store_context: Dictionary = payload.get("full_store_review_context", {}) as Dictionary
		assert_eq(
			str(full_store_context.get("acceptance_role", "")),
			"secondary_context_only",
			"Full-store sweep context must not replace first-ten-seconds acceptance"
		)
		var full_store_beats: Array = full_store_context.get("beats", []) as Array
		assert_eq(full_store_beats.size(), 8, "Full-store context must keep eight legacy beats")
		for beat: Dictionary in full_store_beats:
			assert_eq(
				str(beat.get("visual_scope_mode", "")),
				StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
				"Full-store context must use the authored-full visual scope"
			)
		var profile: Dictionary = payload.get("visual_scope_profile", {}) as Dictionary
		var modes: Array = profile.get("modes", []) as Array
		assert_true(
			modes.has(StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL),
			"Manifest must document the authored-full profile"
		)
		assert_true(
			modes.has(StoreVisualScopeProfileScript.MODE_SUPPRESSION_DIFF_LABEL),
			"Manifest must document the suppression-diff profile"
		)
		var capture_policy: Dictionary = payload.get("capture_policy", {}) as Dictionary
		var resolution: Array = capture_policy.get("resolution", []) as Array
		assert_eq(resolution.size(), 2)
		if resolution.size() == 2:
			assert_eq(int(resolution[0]), 1280)
			assert_eq(int(resolution[1]), 720)
		assert_eq(str(capture_policy.get("renderer", "")), "gl_compatibility")
		assert_false(
			bool(capture_policy.get("headless_allowed", true)),
			"Acceptance captures must reject headless display mode"
		)
		assert_false(
			bool(capture_policy.get("placeholder_allowed", true)),
			"Acceptance captures must reject placeholder images"
		)
		assert_true(
			(payload.get("baseline_review_rules", []) as Array).has(
				"route anchor must not be visually drowned by decorative props"
			),
			"Manifest must preserve route-anchor review rejection criteria"
		)
		assert_true(
			(payload.get("baseline_review_rules", []) as Array).has(
				"work-surface captures must show the primary action surface as dominant"
			),
			"Manifest must require work-surface dominance review"
		)
		assert_true(
			(payload.get("baseline_review_rules", []) as Array).has(
				"supporting props must stay quieter than the action surface"
			),
			"Manifest must require supporting props to stay quiet"
		)
		var diff_policy: Dictionary = payload.get("diff_review_policy", {}) as Dictionary
		var metrics: Array = diff_policy.get("metrics", []) as Array
		assert_true(metrics.has("noise_filtered_changed_pixels"))
		assert_true(metrics.has("mean_absolute_error"))
		assert_true(metrics.has("max_delta"))
		for beat: Dictionary in beats:
			assert_eq(str(beat.get("review_target", "")), _StoreVisualSweep.ACCEPTANCE_TARGET)
			assert_false(
				str(beat.get("active_route_stage", "")).is_empty(),
				"Manifest beat must preserve route stage metadata"
			)
			assert_false(
				str(beat.get("active_prompt", "")).is_empty(),
				"Manifest beat must preserve active prompt metadata"
			)
			assert_false(
				str(beat.get("next_expected_beat", "")).is_empty(),
				"Manifest beat must preserve next expected beat metadata"
			)
			assert_false(
				str(beat.get("primary_work_surface_target", "")).is_empty(),
				"Manifest beat must preserve work-surface target metadata"
			)
			var work_surface_review: Dictionary = beat.get("work_surface_review", {}) as Dictionary
			assert_false(
				work_surface_review.is_empty(),
				"Manifest beat must preserve work-surface review metadata"
			)
			var design_checks: Array = beat.get("design_checks", []) as Array
			for design_check: String in _StoreVisualSweep.route_design_checks():
				assert_true(
					design_checks.has(design_check),
					"Manifest beat must preserve design check %s" % design_check
				)
			assert_eq(
				str(beat.get("hud_context_required", "")),
				_StoreVisualSweep.HUD_CONTEXT_LABEL,
				"Manifest beat must preserve the first-day HUD requirement"
			)


func test_acceptance_visual_sweep_runner_uses_display_backed_capture_contract() -> void:
	var source: String = _read_text("res://tests/visual/capture_store_visual_sweep.gd")
	for filename: String in [
		"01_spawn_first_look.png",
		"02_checkout_manager_counter.png",
		"03_shelf_wall_product_focus.png",
		"04_stockroom_looking_in.png",
		"05_stockroom_work_area_interior.png",
		"06_exit_threshold_return_view.png",
	]:
		assert_true(
			_has_sweep_filename(filename),
			"Acceptance filename must remain canonical: %s" % filename
		)
	assert_string_contains(source, "DisplayServer.get_name() == \"headless\"")
	assert_string_contains(source, "requires a display-backed viewport")
	assert_string_contains(source, "placeholder")
	assert_string_contains(source, "CAPTURE_RESOLUTION")
	assert_string_contains(source, "CAPTURE_RANDOM_SEED")
	assert_string_contains(source, "apply_mode_to_tree")
	assert_string_contains(source, "active_route_stage")
	assert_string_contains(source, "active_prompt")
	assert_string_contains(source, "next_expected_beat")
	assert_string_contains(source, "primary_work_surface_target")
	assert_string_contains(source, "anchor_validation")
	assert_string_contains(source, "debug_ui_validation")
	assert_string_contains(source, "image_validation")
	assert_string_contains(source, "non_acceptance_evidence")
	assert_string_contains(source, "acceptance_current_dir")
	assert_string_contains(source, "write_review_manifest")


func test_visual_sweep_diff_script_declares_soft_baseline_and_threshold_contract() -> void:
	var source: String = _read_text("res://tests/visual/diff_screenshots.py")
	assert_string_contains(source, "REQUIRED_FILENAMES")
	assert_string_contains(source, "baseline_missing")
	assert_string_contains(source, "NOISE_FLOOR = 3")
	assert_string_contains(source, "CHANGED_RATIO_WARN = 0.0025")
	assert_string_contains(source, "CHANGED_RATIO_FAIL = 0.01")
	assert_string_contains(source, "MAE_WARN = 0.75")
	assert_string_contains(source, "MAE_FAIL = 2.0")
	assert_string_contains(source, "MAX_DELTA_FAIL = 96")
	assert_string_contains(source, "luminance_stddev")
	assert_string_contains(source, "validate_capture_metadata")
	assert_string_contains(source, "\"active_route_stage\"")
	assert_string_contains(source, "\"active_prompt\"")
	assert_string_contains(source, "\"next_expected_beat\"")
	assert_string_contains(source, "Capture metadata missing {field}")
	assert_string_contains(source, "Capture did not validate intended visual anchors")
	assert_string_contains(source, "Capture did not validate editor/debug UI absence")
	assert_string_contains(source, "Capture marked as non-acceptance evidence")
	assert_string_contains(source, "json.dump(payload")


func test_visual_sweep_shell_runner_uses_xvfb_and_compatibility_rendering() -> void:
	var source: String = _read_text("res://scripts/run_store_visual_sweep.sh")
	assert_string_contains(source, "xvfb-run")
	assert_string_contains(source, "--rendering-method gl_compatibility")
	assert_false(source.contains("--headless"), "Visual sweep runner must not use headless Godot")
	assert_string_contains(
		source,
		"tests/visual/baselines/retro_games_day_one/$GODOT_VERSION_BUCKET/linux"
	)
	assert_string_contains(source, "tests/visual/capture_store_visual_sweep.gd")
	assert_string_contains(source, "tests/visual/diff_screenshots.py")
	assert_string_contains(source, "--allow-missing-baseline")


func test_screenshot_sweep_documents_human_review_criteria() -> void:
	var review_criteria: Array[String] = _StoreVisualSweep.review_criteria()
	for required: String in [
		"first-look store identity",
		"new player can infer the next destination",
		"new player can infer the local action",
		"no debug/editor UI",
		"no duplicated objective/action text",
		"no misleading unavailable destination",
		"readable local prompt ownership",
		"checkout/shelf/queue flow is understandable",
		"used game store reads without HUD text",
		"spawn view is not a sparse box",
		"shelf wall reads stocked",
		"checkout reads as a service counter",
		"stockroom path reads as a work area",
		"entry and exit threshold stay visible",
		"exit threshold reads as the return path",
		"walking paths",
		"cramped/empty balance",
		"backwards signs",
		"random cubes/panels",
		"product alignment",
		"first-day UI state",
		"First Day — 8:00 AM is visible",
		"HUD supports rather than fights the route views",
		"HUD context supports route understanding only",
		"3D staging communicates the route without new explanatory UI panels",
		"generated shell landmarks identify destinations from screenshots alone",
		"camera-visible density replaces hidden prop count",
		"primary action surface is visually dominant",
		"supporting props stay quiet",
		"material families stay consistent",
		"scale is readable and believable",
		"blank walls, oversized doors, and disconnected props do not dominate",
	]:
		assert_true(
			review_criteria.has(required),
			"Sweep review criteria must include %s" % required
		)

	var failure_criteria: Array[String] = _StoreVisualSweep.design_failure_criteria()
	for required: String in [
		"oversized signs dominate the composition",
		"slab shelves dominate the composition",
		"random loose primitives dominate the composition",
		"color-strip noise dominates the composition",
		"floating text dominates the composition",
		"mismatched scale dominates the composition",
		"blank wall mass dominates the composition",
		"oversized door geometry dominates the composition",
		"disconnected props dominate the composition",
		"material families read as unrelated surfaces",
	]:
		assert_true(
			_failure_criteria_contains(failure_criteria, required),
			"Sweep failure criteria must include %s" % required
		)


func test_first_run_flow_review_markers_remain_visible() -> void:
	var steps: Array[Dictionary] = _StoreVisualSweep.first_run_flow_steps()
	assert_eq(
		steps.size(),
		7,
		"First-run flow review must cover manager, register, backroom, shelf, customer, open-store, exit"
	)
	for step: Dictionary in steps:
		var anchor_path: String = str(step.get("anchor", ""))
		var anchor: Node3D = _node3d(anchor_path)
		assert_not_null(
			anchor,
			"First-run flow step must keep route anchor %s" % anchor_path
		)
		if anchor != null:
			assert_true(
				_is_visible_through_ancestors(anchor),
				"First-run flow route anchor must be visible: %s" % anchor_path
			)


func test_first_ten_seconds_beats_stay_aligned_with_first_run_route() -> void:
	var first_run_anchors: Dictionary = {}
	for step: Dictionary in _StoreVisualSweep.first_run_flow_steps():
		first_run_anchors[str(step.get("anchor", ""))] = true
	for row: Dictionary in _sweep_rows():
		assert_true(
			first_run_anchors.has(str(row.get("route_anchor", ""))),
			"%s route anchor must come from first-run flow steps" % row["name"]
		)


func test_locked_feature_visuals_do_not_mutate_runtime_state() -> void:
	var controller: Node = _controller()
	assert_not_null(controller, "StoreSessionController must exist")
	if controller == null:
		return
	var before: Dictionary = _runtime_state_snapshot(controller)
	watch_signals(EventBus)

	for root_path: String in LOCKED_FEATURE_ROOTS:
		var root: Node = _root.get_node_or_null(root_path)
		assert_not_null(root, "Locked visual root must exist: %s" % root_path)
		if root == null:
			continue
		var interactables: Array[Interactable] = []
		_collect_interactables(root, interactables)
		for interactable: Interactable in interactables:
			assert_false(
				interactable.enabled,
				"%s must not expose an enabled interaction"
				% _relative_path(interactable)
			)

	await get_tree().process_frame
	var after: Dictionary = _runtime_state_snapshot(controller)
	assert_eq(after, before, "Locked visual roots must not alter runtime state")
	for signal_name: String in [
		"objective_changed",
		"objective_completed",
		"unlock_granted",
		"inventory_changed",
		"customer_entered",
		"customer_purchased",
		"money_changed",
		"day_phase_changed",
		"store_shelf_count_changed",
	]:
		assert_signal_not_emitted(
			EventBus,
			signal_name,
			"Locked visual roots must not emit %s" % signal_name
		)


func test_preopening_hud_prompt_and_debug_surfaces_have_single_owners() -> void:
	var controller: Node = _controller()
	assert_not_null(controller, "StoreSessionController must exist")
	if controller == null:
		return

	assert_true(StoreSessionHUD.is_active(), "StoreSessionHUD must be active after scene ready")
	assert_true(
		StoreSessionHUD.get_right_panel().visible,
		"Right panel owns checklist and stock stats during store_session play"
	)
	assert_true(
		StoreSessionHUD.get_event_log_panel().visible,
		"Event log panel owns bottom-left recent-event output"
	)
	var debug_overlay: CanvasLayer = controller.get("_debug_overlay") as CanvasLayer
	assert_not_null(debug_overlay, "Controller must own the debug overlay")
	if debug_overlay != null:
		var panel: PanelContainer = debug_overlay.get("_panel") as PanelContainer
		assert_not_null(panel, "Debug overlay must own a panel")
		if panel != null:
			assert_false(panel.visible, "Debug overlay must be hidden by default")

	var prompt_panel: Control = InteractionPrompt.get_node_or_null("PanelContainer") as Control
	assert_not_null(prompt_panel, "InteractionPrompt must own the prompt panel")
	if prompt_panel != null:
		assert_false(
			prompt_panel.visible,
			"InteractionPrompt must not show a duplicate persistent action at rest"
		)
	assert_false(
		_has_visible_objective_text_outside_right_panel(),
		"Persistent objective text must stay in the right panel"
	)


func _assert_sweep_row_frames_focus(row: Dictionary) -> void:
	var focus: Node3D = _node3d(String(row["focus"]))
	assert_not_null(focus, "%s sweep focus must exist" % row["name"])
	if focus == null or _camera == null:
		return
	_camera.global_position = row["camera"] as Vector3
	_camera.look_at(focus.global_position, Vector3.UP)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	assert_gt(viewport_size.x, 0.0, "Viewport width must be available")
	assert_gt(viewport_size.y, 0.0, "Viewport height must be available")
	assert_false(
		_camera.is_position_behind(focus.global_position),
		"%s sweep focus must be in front of the camera" % row["name"]
	)
	var screen_pos: Vector2 = _camera.unproject_position(focus.global_position)
	assert_true(
		_point_inside_viewport(screen_pos, viewport_size),
		"%s sweep focus must project inside the viewport; got %s"
		% [row["name"], screen_pos]
	)


func _sweep_rows() -> Array[Dictionary]:
	return _StoreVisualSweep.rows()


func _has_sweep_filename(filename: String) -> bool:
	for row: Dictionary in _sweep_rows():
		if str(row.get("filename", "")) == filename:
			return true
	return false


func _runtime_state_snapshot(controller: Node) -> Dictionary:
	var completed: Dictionary = (
		controller.get("_completed_objectives") as Dictionary
	).duplicate(true)
	var unlocks: Array[String] = []
	for unlock_id: StringName in UnlockSystemSingleton.get_all_granted():
		unlocks.append(String(unlock_id))
	unlocks.sort()
	return {
		"stage": String(controller.call("current_stage")),
		"completed_objectives": completed,
		"run_state": StoreSessionState.get_save_data(),
		"unlocks": unlocks,
		"economy_cash": _economy_cash_or_null(),
		"time_phase": _time_phase_or_null(),
		"inventory_counts": _inventory_counts_or_null(),
	}


func _economy_cash_or_null() -> Variant:
	var economy: EconomySystem = GameManager.get_economy_system()
	if economy == null:
		return null
	return economy.get_cash()


func _time_phase_or_null() -> Variant:
	var time_system: TimeSystem = GameManager.get_time_system()
	if time_system == null:
		return null
	return int(time_system.get_current_phase())


func _inventory_counts_or_null() -> Variant:
	var inventory: InventorySystem = GameManager.get_inventory_system()
	if inventory == null:
		return null
	return {
		"backroom": inventory.get_backroom_items().size(),
		"shelf": inventory.get_shelf_items().size(),
	}


func _has_visible_objective_text_outside_right_panel() -> bool:
	var forbidden_labels: Array[String] = [
		"ObjectiveRail",
		"TutorialOverlay",
		"TelegraphCard",
	]
	for node_name: String in forbidden_labels:
		for node: Node in get_tree().get_nodes_in_group(node_name):
			if node is CanvasItem and (node as CanvasItem).visible:
				return true
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud == null:
		return false
	var topbar: Node = hud.get_node_or_null("TopBar")
	if topbar == null:
		return false
	for label_name: String in [
		"ItemsPlacedLabel",
		"BackRoomLabel",
		"CustomersLabel",
		"SalesTodayLabel",
	]:
		var label: CanvasItem = topbar.get_node_or_null(label_name) as CanvasItem
		if label != null and label.visible:
			return true
	return false


func _node3d(path: String) -> Node3D:
	if _root == null:
		return null
	return _root.get_node_or_null(path) as Node3D


func _controller() -> Node:
	if _root == null:
		return null
	return _root.get_node_or_null("StoreSessionController")


func _collect_interactables(node: Node, out: Array[Interactable]) -> void:
	if node is Interactable:
		out.append(node as Interactable)
	for child: Node in node.get_children():
		_collect_interactables(child, out)


func _point_inside_viewport(point: Vector2, viewport_size: Vector2) -> bool:
	return point.x >= _StoreVisualSweep.VIEWPORT_MARGIN_PX \
		and point.y >= _StoreVisualSweep.VIEWPORT_MARGIN_PX \
		and point.x <= viewport_size.x - _StoreVisualSweep.VIEWPORT_MARGIN_PX \
		and point.y <= viewport_size.y - _StoreVisualSweep.VIEWPORT_MARGIN_PX


func _is_visible_through_ancestors(node: Node) -> bool:
	var current: Node = node
	while current != null and current != _root:
		if current is Node3D and not (current as Node3D).visible:
			return false
		current = current.get_parent()
	return true


func _relative_path(node: Node) -> String:
	if _root == null or node == null:
		return ""
	return String(_root.get_path_to(node))


func _read_json_file(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Manifest JSON must be readable")
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(parsed is Dictionary, "Manifest JSON must parse as an object")
	if not (parsed is Dictionary):
		return {}
	return parsed as Dictionary


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Source text must be readable: %s" % path)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _failure_criteria_contains(criteria: Array[String], phrase: String) -> bool:
	for criterion: String in criteria:
		if criterion.contains(phrase) or phrase.contains(criterion):
			return true
	return false
