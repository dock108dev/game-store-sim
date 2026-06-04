extends GutTest

# See docs/audits/cleanup-report.md: this route-wide visual gate stays together
# until manifest policy, fixture state, and acceptance assertions can split cleanly.
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")
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
	"product_sale_review",
	"checkout_close_day",
	"exit_threshold_return_view",
]
const REQUIRED_OVERHAUL_ACCEPTANCE_BEATS: Array[String] = [
	"build_design_tool",
	"stocked_shelf_state",
	"shelf_after_sale_gap",
	"checkout_transaction_active",
	"register_trade_in_no_sale",
	"customer_queue_state",
	"customization_featured_display",
	"stockroom_inventory_state",
	"growth_expansion_preview",
	"lighting_balance_review",
	"decision_panels_work_surface_balance",
]
const REQUIRED_OVERHAUL_ACCEPTANCE_FILENAMES: Array[String] = [
	"09_build_design_tool.png",
	"10_stocked_shelf_state.png",
	"11_shelf_after_sale_gap.png",
	"12_checkout_transaction_active.png",
	"13_register_trade_in_no_sale.png",
	"14_customer_queue_state.png",
	"15_customization_featured_display.png",
	"16_stockroom_inventory_state.png",
	"17_growth_expansion_preview.png",
	"18_lighting_balance_review.png",
	"19_decision_panels_work_surface_balance.png",
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
	assert_eq(rows.size(), 8, "Validation sweep must cover eight first-day route views")
	var seen_beats: Array[String] = []
	for row: Dictionary in rows:
		seen_beats.append(str(row.get("name", "")))
		_assert_sweep_row_frames_focus(row)
		if str(row.get("name", "")) == "spawn_first_look":
			_assert_spawn_first_look_matches_player_spawn(row)
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
			StoreVisualSweepScript.ACCEPTANCE_TARGET,
			"%s sweep must target first-ten-seconds acceptance" % row["name"]
		)
		assert_eq(
			str(row.get("hud_context_required", "")),
			StoreVisualSweepScript.HUD_CONTEXT_LABEL,
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
		assert_true(
			bool(StoreVisualSweepScript.validate_action_context(row).get("ok", false)),
			"%s sweep must declare one unambiguous active action context" % row["name"]
		)
		var action_context: Dictionary = row.get("action_context", {}) as Dictionary
		assert_true(
			bool(action_context.get("normal_player_approach", false)),
			"%s sweep must use a normal player approach angle" % row["name"]
		)
		assert_false(
			bool(action_context.get("tight_closeup", true)),
			"%s sweep must not rely on tight object closeups" % row["name"]
		)
		assert_true(
			bool(action_context.get("shows_next_destination", false)),
			"%s sweep must include next-destination context" % row["name"]
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
		for design_check: String in StoreVisualSweepScript.route_design_checks():
			assert_true(
				design_checks.has(design_check),
				"%s sweep must include design check %s" % [row["name"], design_check]
			)
		assert_true(
			bool(work_surface_review.get("supporting_props_should_stay_quiet", false)),
			"%s sweep must judge supporting prop quietness" % row["name"]
		)
		_assert_inspiration_closeout(
			row.get("inspiration_closeout", {}) as Dictionary,
			"%s sweep" % row["name"]
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


func test_stockroom_sweep_rows_record_pickup_prompt_and_blocked_guidance() -> void:
	for row_name: String in ["stockroom_looking_in", "stockroom_work_area_interior"]:
		var row: Dictionary = _sweep_row_by_name(row_name)
		assert_false(row.is_empty(), "Missing stockroom sweep row %s" % row_name)
		if row.is_empty():
			continue
		assert_eq(str(row.get("active_prompt", "")), "Inspect Starter Stock Box")
		var disabled_guidance: Dictionary = row.get("disabled_guidance", {}) as Dictionary
		assert_eq(
			str(disabled_guidance.get("before_active_objective", "")),
			"Talk to the customer first.",
			"%s must document the wrong-stage pickup prompt" % row_name
		)
		assert_eq(
			str(disabled_guidance.get("while_carrying_stock", "")),
			"Stock already in hand. Place it on the Starter Display.",
			"%s must document the already-carrying pickup prompt" % row_name
		)


func test_overhaul_acceptance_rows_cover_stateful_visual_review_targets() -> void:
	var rows: Array[Dictionary] = StoreVisualSweepScript.overhaul_acceptance_rows()
	assert_eq(rows.size(), REQUIRED_OVERHAUL_ACCEPTANCE_BEATS.size())
	var seen_beats: Array[String] = []
	var seen_filenames: Array[String] = []
	for row: Dictionary in rows:
		seen_beats.append(str(row.get("name", "")))
		seen_filenames.append(str(row.get("filename", "")))
		assert_eq(str(row.get("scope", "")), "overhaul_acceptance")
		assert_eq(
			str(row.get("review_target", "")),
			StoreVisualSweepScript.OVERHAUL_ACCEPTANCE_TARGET
		)
		assert_false(str(row.get("setup_state", "")).is_empty())
		assert_false(str(row.get("route_anchor", "")).is_empty())
		assert_false(str(row.get("primary_work_surface_target", "")).is_empty())
		assert_true(
			bool(StoreVisualSweepScript.validate_action_context(row).get("ok", false)),
			"%s must have unambiguous action context" % str(row.get("name", ""))
		)
		var work_surface_review: Dictionary = row.get("work_surface_review", {}) as Dictionary
		assert_true(bool(work_surface_review.get("dominance_required", false)))
		assert_true(bool(work_surface_review.get("supporting_props_should_stay_quiet", false)))
		assert_gt((work_surface_review.get("must_show", []) as Array).size(), 0)
		assert_gt((work_surface_review.get("reject_if", []) as Array).size(), 0)
		var review_contract: Dictionary = StoreVisualSweepScript.review_manifest_contract(row)
		for field: String in StoreVisualSweepScript.review_manifest_required_fields():
			assert_true(
				review_contract.has(field),
				"%s review contract must include %s" % [str(row.get("name", "")), field]
			)
			var value: Variant = review_contract.get(field)
			_assert_review_contract_value_present(value)
			assert_eq(
				str(review_contract.get("route_target", "")),
				StoreVisualSweepScript.OVERHAUL_ACCEPTANCE_TARGET
			)
			assert_eq(
				str(review_contract.get("visual_scope_mode", "")),
				str(row.get("visual_scope_mode", ""))
			)
		_assert_inspiration_closeout(
			row.get("inspiration_closeout", {}) as Dictionary,
			"%s overhaul row" % str(row.get("name", ""))
		)

	for required: String in REQUIRED_OVERHAUL_ACCEPTANCE_BEATS:
		assert_true(seen_beats.has(required), "Overhaul sweep must include %s" % required)
	for filename: String in REQUIRED_OVERHAUL_ACCEPTANCE_FILENAMES:
		assert_true(seen_filenames.has(filename), "Overhaul sweep filename missing: %s" % filename)


func test_overhaul_acceptance_manifest_keeps_separate_target() -> void:
	var rows: Array[Dictionary] = StoreVisualSweepScript.overhaul_acceptance_rows()
	var result: Dictionary = StoreVisualSweepScript.write_review_manifest(
		"user://visual_overhaul_validation_gate/overhaul_reports",
		rows
	)
	assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
	if not bool(result.get("ok", false)):
		return
	var payload: Dictionary = _read_json_file(str(result.get("path", "")))
	assert_eq(
		str(payload.get("acceptance_target", "")),
		StoreVisualSweepScript.OVERHAUL_ACCEPTANCE_TARGET
	)
	var required_fields: Array = payload.get("review_manifest_required_fields", []) as Array
	for field: String in StoreVisualSweepScript.review_manifest_required_fields():
		assert_true(required_fields.has(field), "Manifest must require %s" % field)
	var beats: Array = payload.get("beats", []) as Array
	assert_eq(beats.size(), rows.size())
	for beat: Dictionary in beats:
		assert_eq(str(beat.get("review_target", "")), StoreVisualSweepScript.OVERHAUL_ACCEPTANCE_TARGET)
		assert_false(str(beat.get("setup_state", "")).is_empty())
		var review_contract: Dictionary = beat.get("review_manifest_contract", {}) as Dictionary
		assert_eq(str(review_contract.get("capture_resolution_validity", "")), "must_match_1280x720")


func test_spawn_first_look_records_spawn_acceptance_contract() -> void:
	var row: Dictionary = _sweep_row_by_name("spawn_first_look")
	assert_false(row.is_empty(), "Spawn first-look sweep row must exist")
	if row.is_empty():
		return

	var review: Dictionary = row.get("spawn_acceptance_review", {}) as Dictionary
	assert_false(review.is_empty(), "Spawn first-look row must declare screenshot acceptance")
	assert_eq(str(review.get("evidence_artifact", "")), "01_spawn_first_look.png")
	assert_eq(str(review.get("capture_workflow", "")), "scripts/run_store_visual_sweep.sh")
	assert_eq(str(review.get("capture_policy", "")), "display-backed 1280x720 gl_compatibility")

	var must_show: Array = review.get("must_show", []) as Array
	for required: String in [
		"enclosed stockroom",
		"readable checkout",
		"manager talk target",
		"queue inside store",
		"starter display visible",
		"readable storefront threshold identity",
		"open sales floor",
		"no unintended exterior objects",
	]:
		assert_true(must_show.has(required), "Spawn acceptance must show %s" % required)

	var label_free_reads: Array = review.get("must_read_without_ui_labels", []) as Array
	for required: String in [
		"fresh player can identify the first action",
		"fresh player can identify the manager target",
		"fresh player can identify the next store destinations",
		"fresh player can tell they are inside a specific storefront",
		"fresh player can distinguish the mall threshold from the sales floor",
	]:
		assert_true(
			label_free_reads.has(required),
			"Spawn acceptance must preserve label-free review item %s" % required
		)

	var route_fields: Array = review.get("route_metadata_fields", []) as Array
	for field_name: String in [
		"active_prompt",
		"next_destination",
		"local_action",
		"next_expected_beat",
		"primary_work_surface_target",
	]:
		assert_true(
			route_fields.has(field_name), "Spawn route field missing: %s" % field_name
		)
		assert_false(
			str(row.get(field_name, "")).is_empty(),
			"Spawn route value missing: %s" % field_name
		)
	assert_eq(str(row.get("active_prompt", "")), "Talk to Manager")
	assert_eq(str(row.get("next_expected_beat", "")), "checkout_manager_counter")
	assert_eq(str(row.get("next_destination", "")), "manager and checkout register")
	assert_string_contains(str(row.get("local_action", "")), "counter")
	assert_eq(str(row.get("primary_work_surface_target", "")), "checkout_counter")

	var reject_if: Array = review.get("reject_if", []) as Array
	for rejection: String in [
		"required spawn-readability anchor is missing",
		"required spawn-readability anchor is hidden by ancestors",
		"required spawn-readability anchor is outside its physical zone",
		"required spawn-readability anchor overlaps a forbidden zone",
		"required spawn-readability anchor is outside the first-ten-seconds acceptance target",
		"storefront identity is missing from the spawn first-look composition",
		"storefront identity reads as the active route target instead of background context",
		"mall-side threshold details imply a reachable exterior route",
		"capture is headless placeholder evidence",
	]:
		assert_true(reject_if.has(rejection), "Spawn acceptance must reject: %s" % rejection)


func test_spawn_first_look_readability_anchors_obey_physical_contract() -> void:
	var row: Dictionary = _sweep_row_by_name("spawn_first_look")
	assert_false(row.is_empty(), "Spawn first-look sweep row must exist")
	if row.is_empty():
		return
	var anchors: Array = row.get("spawn_readability_anchors", []) as Array
	assert_eq(anchors.size(), 8, "Spawn first-look must lock all readability anchors")
	var seen_landmarks: Array[String] = []
	var row_anchor_paths: Array = row.get("anchors", []) as Array
	var physical_contract: Dictionary = _starter_physical_contract()
	var zones: Dictionary = _zones_by_id(physical_contract)
	for raw_anchor: Variant in anchors:
		assert_true(
			raw_anchor is Dictionary, "Spawn readability anchor must be a dictionary"
		)
		if raw_anchor is not Dictionary:
			continue
		var anchor_spec: Dictionary = raw_anchor as Dictionary
		var landmark: String = str(anchor_spec.get("landmark", ""))
		var anchor_path: String = str(anchor_spec.get("path", ""))
		var physical_zone: String = str(anchor_spec.get("physical_zone", ""))
		seen_landmarks.append(landmark)
		assert_true(
			row_anchor_paths.has(anchor_path),
			"%s must be part of spawn row anchors" % anchor_path
		)
		assert_eq(
			str(anchor_spec.get("first_ten_seconds_acceptance_target", "")),
			StoreVisualSweepScript.ACCEPTANCE_TARGET,
			"%s must belong to the first-ten-seconds target" % anchor_path
		)

		var anchor: Node3D = _node3d(anchor_path)
		assert_not_null(anchor, "Spawn readability anchor must exist: %s" % anchor_path)
		if anchor == null:
			continue
		assert_true(
			_is_visible_through_ancestors(anchor),
			"Spawn readability anchor must be visible: %s" % anchor_path
		)
		assert_true(
			_anchor_inside_zone(anchor.global_position, physical_zone, physical_contract, zones),
			"%s must stay inside physical zone %s" % [anchor_path, physical_zone]
		)
		for forbidden_zone: Variant in anchor_spec.get("forbidden_zones", []):
			assert_false(
				_anchor_inside_zone(anchor.global_position, str(forbidden_zone), physical_contract, zones),
				"%s must not overlap forbidden zone %s" % [anchor_path, str(forbidden_zone)]
			)

	for landmark: String in [
		"readable_checkout",
		"manager_talk_target",
		"starter_display_visible",
		"enclosed_stockroom",
		"queue_inside_store",
		"store_bounds_context",
		"entrance_context",
		"route_sightline_context",
	]:
		assert_true(seen_landmarks.has(landmark), "Spawn landmark missing: %s" % landmark)


func test_screenshot_sweep_writes_named_artifacts_for_review() -> void:
	var rows: Array[Dictionary] = _sweep_rows()
	for row: Dictionary in rows:
		_assert_sweep_row_frames_focus(row)
		await get_tree().process_frame
		var result: Dictionary = StoreVisualSweepScript.save_viewport_png(
			get_viewport(),
			StoreVisualSweepScript.visual_sweep_dir(),
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

	var manifest: Dictionary = StoreVisualSweepScript.write_review_manifest(
		StoreVisualSweepScript.review_manifest_dir(),
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
		assert_eq(str(payload.get("acceptance_target", "")), StoreVisualSweepScript.ACCEPTANCE_TARGET)
		var source_policy: Dictionary = payload.get("inspiration_reference_policy", {}) as Dictionary
		assert_eq(str(source_policy.get("allowed_use", "")), "pattern_reference_only")
		assert_eq(
			payload.get("required_originality_commands", []),
			["bash scripts/validate_originality.sh", "bash tests/validate_original_content.sh"]
		)
		var cluster_catalog: Array = payload.get("inspiration_reference_clusters", []) as Array
		assert_gt(cluster_catalog.size(), 5, "Manifest must include the reference-cluster catalog")
		var beats: Array = payload.get("beats", []) as Array
		assert_eq(beats.size(), rows.size(), "Manifest must write one entry per artifact")
		var template: Dictionary = payload.get("manual_review_template", {}) as Dictionary
		var verdicts: Array = template.get("verdicts", []) as Array
		assert_eq(verdicts.size(), rows.size(), "Manifest must include one verdict per artifact")
		var spawn_verdict: Dictionary = _verdict_by_beat(verdicts, "01_spawn_first_look.png")
		assert_false(spawn_verdict.is_empty(), "Manifest must include spawn first-look verdict")
		_assert_inspiration_closeout(
			spawn_verdict.get("inspiration_closeout", {}) as Dictionary,
			"Spawn manual review verdict"
		)
		assert_true(
			spawn_verdict.has("fresh_player_identifies_first_action_without_ui_labels"),
			"Spawn verdict must ask whether the first action reads without UI labels"
		)
		for closeout_field: String in [
			"reference_cluster_pattern_validated",
			"mallcore_original_adaptation_confirmed",
			"no_import_trace_clone_or_logo_copy",
			"new_text_original_or_repo_existing",
		]:
			assert_true(
				spawn_verdict.has(closeout_field),
				"Spawn verdict must include closeout field %s" % closeout_field
			)
		assert_true(
			spawn_verdict.has("fresh_player_identifies_manager_target_without_ui_labels"),
			"Spawn verdict must ask whether the manager target reads without UI labels"
		)
		assert_true(
			spawn_verdict.has("fresh_player_identifies_next_store_destinations_without_ui_labels"),
			"Spawn verdict must ask whether next destinations read without UI labels"
		)
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
		var required_fields: Array = payload.get("review_manifest_required_fields", []) as Array
		for field: String in StoreVisualSweepScript.review_manifest_required_fields():
			assert_true(required_fields.has(field), "Manifest must require %s" % field)
		for beat: Dictionary in beats:
			assert_eq(str(beat.get("review_target", "")), StoreVisualSweepScript.ACCEPTANCE_TARGET)
			assert_false(
				str(beat.get("active_route_stage", "")).is_empty(),
				"Manifest beat must preserve route stage metadata"
			)
			assert_false(
				str(beat.get("active_prompt", "")).is_empty(),
				"Manifest beat must preserve active prompt metadata"
			)
			if str(beat.get("name", "")).begins_with("stockroom_"):
				var disabled_guidance: Dictionary = beat.get("disabled_guidance", {}) as Dictionary
				assert_false(
					disabled_guidance.is_empty(),
					"Manifest stockroom beats must preserve disabled guidance"
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
			var review_contract: Dictionary = beat.get("review_manifest_contract", {}) as Dictionary
			assert_eq(str(review_contract.get("route_target", "")), StoreVisualSweepScript.ACCEPTANCE_TARGET)
			assert_eq(str(review_contract.get("capture_resolution_validity", "")), "must_match_1280x720")
			_assert_inspiration_closeout(
				beat.get("inspiration_closeout", {}) as Dictionary,
				"Manifest beat %s" % str(beat.get("name", ""))
			)
			var design_checks: Array = beat.get("design_checks", []) as Array
			for design_check: String in StoreVisualSweepScript.route_design_checks():
				assert_true(
					design_checks.has(design_check),
					"Manifest beat must preserve design check %s" % design_check
				)
			if str(beat.get("name", "")) == "spawn_first_look":
				var spawn_review: Dictionary = beat.get("spawn_acceptance_review", {}) as Dictionary
				assert_false(
					spawn_review.is_empty(),
					"Manifest must preserve spawn acceptance review metadata"
				)
				assert_true(
					(spawn_review.get("must_show", []) as Array).has("readable checkout"),
					"Manifest spawn review must preserve checkout criterion"
				)
				assert_true(
					(spawn_review.get("reject_if", []) as Array).has(
						"capture is headless placeholder evidence"
					),
					"Manifest spawn review must preserve non-placeholder rejection"
				)
				var spawn_anchors: Array = beat.get("spawn_readability_anchors", []) as Array
				assert_eq(spawn_anchors.size(), 8, "Manifest must preserve spawn anchors")
			assert_eq(
				str(beat.get("hud_context_required", "")),
				StoreVisualSweepScript.HUD_CONTEXT_LABEL,
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
		"06_product_sale_review.png",
		"07_checkout_close_day.png",
		"08_exit_threshold_return_view.png",
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
	assert_string_contains(source, "camera_rotation_degrees")
	assert_string_contains(source, "apply_mode_to_tree")
	assert_string_contains(source, "active_route_stage")
	assert_string_contains(source, "active_prompt")
	assert_string_contains(source, "next_expected_beat")
	assert_string_contains(source, "primary_work_surface_target")
	assert_string_contains(source, "anchor_validation")
	assert_string_contains(source, "debug_ui_validation")
	assert_string_contains(source, "image_validation")
	assert_string_contains(source, "action_context_validation")
	assert_string_contains(source, "inspiration_closeout")
	assert_string_contains(source, "setup_state")
	assert_string_contains(source, "MALLCORE_VISUAL_SWEEP_TARGET")
	assert_string_contains(source, "rows_for_target")
	assert_string_contains(source, "spawn_acceptance_review")
	assert_string_contains(source, "spawn_readability_anchors")
	assert_string_contains(source, "review_manifest_contract")
	assert_string_contains(source, "non_acceptance_evidence")
	assert_string_contains(source, "acceptance_current_dir")
	assert_string_contains(source, "write_review_manifest")


func test_visual_sweep_diff_script_declares_soft_baseline_and_threshold_contract() -> void:
	var source: String = _read_text("res://tests/visual/diff_screenshots.py")
	assert_string_contains(source, "REQUIRED_FILENAMES")
	assert_string_contains(source, "REQUIRED_FIRST_TEN_SECONDS_FILENAMES")
	assert_string_contains(source, "REQUIRED_OVERHAUL_ACCEPTANCE_FILENAMES")
	assert_string_contains(source, "--suite")
	assert_string_contains(source, "overhaul-acceptance")
	assert_string_contains(source, "baseline_missing")
	assert_string_contains(source, "NOISE_FLOOR = 3")
	assert_string_contains(source, "CHANGED_RATIO_WARN = 0.0025")
	assert_string_contains(source, "CHANGED_RATIO_FAIL = 0.01")
	assert_string_contains(source, "MAE_WARN = 0.75")
	assert_string_contains(source, "MAE_FAIL = 2.0")
	assert_string_contains(source, "MAX_DELTA_FAIL = 96")
	assert_string_contains(source, "luminance_stddev")
	assert_string_contains(source, "validate_capture_metadata")
	assert_string_contains(source, "validate_inspiration_closeout")
	assert_string_contains(source, "\"active_route_stage\"")
	assert_string_contains(source, "\"active_prompt\"")
	assert_string_contains(source, "\"next_expected_beat\"")
	assert_string_contains(source, "Capture metadata missing {field}")
	assert_string_contains(source, "Capture did not validate intended visual anchors")
	assert_string_contains(source, "Capture did not validate unambiguous action context")
	assert_string_contains(source, "Capture did not validate editor/debug UI absence")
	assert_string_contains(source, "Capture marked as non-acceptance evidence")
	assert_string_contains(source, "Capture metadata missing inspiration_closeout")
	assert_string_contains(source, "Capture metadata missing reference cluster")
	assert_string_contains(source, "Capture metadata missing original adaptation")
	assert_string_contains(source, "Capture metadata missing originality command")
	assert_string_contains(source, "validate_review_manifest_contract")
	assert_string_contains(source, "Capture metadata missing review_manifest_contract")
	assert_string_contains(source, "capture_resolution_validity")
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
	assert_string_contains(
		source,
		"tests/visual/baselines/retro_games_overhaul_acceptance/$GODOT_VERSION_BUCKET/linux"
	)
	assert_string_contains(source, "tests/visual/capture_store_visual_sweep.gd")
	assert_string_contains(source, "tests/visual/diff_screenshots.py")
	assert_string_contains(source, "01_spawn_first_look.png")
	assert_string_contains(source, "overhaul-acceptance")
	assert_string_contains(source, "--suite")
	assert_string_contains(source, "1280x720 gl_compatibility")
	assert_string_contains(source, "bash scripts/validate_originality.sh")
	assert_string_contains(source, "bash tests/validate_original_content.sh")
	assert_string_contains(source, "--allow-missing-baseline")


func test_screenshot_sweep_documents_human_review_criteria() -> void:
	var review_criteria: Array[String] = StoreVisualSweepScript.review_criteria()
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
			(
				"fresh player can identify first action, manager target, "
				+ "and next store destinations without UI labels"
			),
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

	var failure_criteria: Array[String] = StoreVisualSweepScript.design_failure_criteria()
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
	var steps: Array[Dictionary] = StoreVisualSweepScript.first_run_flow_steps()
	assert_eq(
		steps.size(),
		5,
		"First-run flow review must cover checkout, backroom, shelf, product/sale, and close"
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
	var first_run_moments: Dictionary = {}
	for step: Dictionary in StoreVisualSweepScript.first_run_flow_steps():
		first_run_moments[str(step.get("moment", ""))] = true
	for row: Dictionary in _sweep_rows():
		var action_context: Dictionary = row.get("action_context", {}) as Dictionary
		var moment: String = str(action_context.get("moment", ""))
		if moment == "exit":
			continue
		assert_true(
			first_run_moments.has(moment),
			"%s route moment must come from first-run flow steps" % row["name"]
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
		"Right panel owns passive checklist and stock stats during store_session play"
	)
	assert_true(
		ObjectiveRail.visible,
		"ObjectiveRail owns the active bottom objective during store_session play"
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
		_has_duplicate_objective_text_outside_rail_and_right_panel(),
		"Persistent objective text must stay in ObjectiveRail or the passive right panel"
	)


func _assert_sweep_row_frames_focus(row: Dictionary) -> void:
	var focus: Node3D = _node3d(String(row["focus"]))
	assert_not_null(focus, "%s sweep focus must exist" % row["name"])
	if focus == null or _camera == null:
		return
	_camera.global_position = row["camera"] as Vector3
	_camera.fov = float(row.get("camera_fov", StoreVisualSweepScript.CAPTURE_CAMERA_FOV))
	if row.has("camera_rotation_degrees"):
		_camera.rotation_degrees = row.get("camera_rotation_degrees", Vector3.ZERO) as Vector3
	else:
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


func _assert_review_contract_value_present(value: Variant) -> void:
	assert_false(value == null)
	if value == null:
		return
	if value is String:
		assert_false((value as String).is_empty())
	elif value is Array:
		assert_gt((value as Array).size(), 0)


func _assert_spawn_first_look_matches_player_spawn(row: Dictionary) -> void:
	var spawn: Marker3D = _node3d("PlayerEntrySpawn") as Marker3D
	assert_not_null(spawn, "Spawn sweep must use PlayerEntrySpawn as its viewpoint source")
	if spawn == null or _camera == null:
		return
	var camera_position: Vector3 = row.get("camera", Vector3.ZERO) as Vector3
	assert_almost_eq(camera_position.x, spawn.global_position.x, 0.01, "spawn camera x")
	assert_almost_eq(camera_position.z, spawn.global_position.z, 0.01, "spawn camera z")
	assert_almost_eq(camera_position.y, spawn.global_position.y + 1.70, 0.01, "spawn camera eye y")
	var camera_rotation: Vector3 = row.get(
		"camera_rotation_degrees",
		Vector3(9999.0, 9999.0, 9999.0)
	) as Vector3
	assert_almost_eq(camera_rotation.x, spawn.rotation_degrees.x, 0.01, "spawn camera rotation x")
	assert_almost_eq(camera_rotation.y, spawn.rotation_degrees.y, 0.01, "spawn camera rotation y")
	assert_almost_eq(camera_rotation.z, spawn.rotation_degrees.z, 0.01, "spawn camera rotation z")
	assert_almost_eq(
		float(row.get("camera_fov", 0.0)),
		StoreVisualSweepScript.CAPTURE_CAMERA_FOV,
		0.01,
		"Spawn sweep must use the pinned capture FOV"
	)
	_camera.global_position = camera_position
	_camera.rotation_degrees = camera_rotation
	_camera.fov = StoreVisualSweepScript.CAPTURE_CAMERA_FOV
	for landmark_path: String in [
		"ExpandableStoreShell/CheckoutRegisterScreen",
		"StoreSessionManager",
		"ExpandableStoreShell/StockroomDoorStaffCard",
		"StoreSessionRestockShelf",
	]:
		_assert_node_projects_inside_spawn_view(landmark_path)


func _assert_node_projects_inside_spawn_view(node_path: String) -> void:
	var landmark: Node3D = _node3d(node_path)
	assert_not_null(landmark, "Spawn view landmark must exist: %s" % node_path)
	if landmark == null or _camera == null:
		return
	assert_false(
		_camera.is_position_behind(landmark.global_position),
		"Spawn view landmark must be in front of the camera: %s" % node_path
	)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var screen_pos: Vector2 = _camera.unproject_position(landmark.global_position)
	assert_true(
		_point_inside_viewport(screen_pos, viewport_size),
		"Spawn view landmark must project into the first look: %s got %s"
		% [node_path, screen_pos]
	)


func _sweep_rows() -> Array[Dictionary]:
	return StoreVisualSweepScript.rows()


func _sweep_row_by_name(row_name: String) -> Dictionary:
	for row: Dictionary in _sweep_rows():
		if str(row.get("name", "")) == row_name:
			return row
	return {}


func _has_sweep_filename(filename: String) -> bool:
	for row: Dictionary in _sweep_rows():
		if str(row.get("filename", "")) == filename:
			return true
	return false


func _verdict_by_beat(verdicts: Array, beat: String) -> Dictionary:
	for raw_verdict: Variant in verdicts:
		if raw_verdict is Dictionary:
			var verdict: Dictionary = raw_verdict as Dictionary
			if str(verdict.get("beat", "")) == beat:
				return verdict
	return {}


func _starter_physical_contract() -> Dictionary:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	return catalog.call(
		"get_physical_contract",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	) as Dictionary


func _zones_by_id(physical_contract: Dictionary) -> Dictionary:
	var zones: Dictionary = {}
	for raw_zone: Variant in physical_contract.get("zones", []):
		if raw_zone is Dictionary:
			var zone: Dictionary = raw_zone as Dictionary
			var zone_id: String = str(zone.get("zone_id", ""))
			if not zone_id.is_empty():
				zones[zone_id] = zone
	return zones


func _anchor_inside_zone(
	position: Vector3,
	zone_id: String,
	physical_contract: Dictionary,
	zones: Dictionary
) -> bool:
	var zone: Dictionary = (
		physical_contract.get("store_bounds", {}) as Dictionary
		if zone_id == "store_bounds"
		else zones.get(zone_id, {}) as Dictionary
	)
	if zone.is_empty():
		return false
	match str(zone.get("shape", "")):
		"box":
			return _point_inside_box(position, zone)
		"polyline_corridor":
			return _point_inside_corridor(position, zone)
		_:
			return false


func _point_inside_box(position: Vector3, zone: Dictionary) -> bool:
	var min_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		zone.get("min", []), VisualValueUtilScript.INVALID_VECTOR3
	)
	var max_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		zone.get("max", []), VisualValueUtilScript.INVALID_VECTOR3
	)
	if min_bound == VisualValueUtilScript.INVALID_VECTOR3 \
			or max_bound == VisualValueUtilScript.INVALID_VECTOR3:
		return false
	return position.x >= min_bound.x \
		and position.x <= max_bound.x \
		and position.z >= min_bound.z \
		and position.z <= max_bound.z


func _point_inside_corridor(position: Vector3, zone: Dictionary) -> bool:
	var points: Array = zone.get("points", []) as Array
	if points.size() < 2:
		return false
	var half_width: float = float(zone.get("corridor_width", 0.0)) * 0.5
	for index: int in range(points.size() - 1):
		var start: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
			points[index], VisualValueUtilScript.INVALID_VECTOR3
		)
		var end: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
			points[index + 1], VisualValueUtilScript.INVALID_VECTOR3
		)
		if start == VisualValueUtilScript.INVALID_VECTOR3 \
				or end == VisualValueUtilScript.INVALID_VECTOR3:
			continue
		if _xz_distance_to_segment(position, start, end) <= half_width:
			return true
	return false


func _xz_distance_to_segment(point: Vector3, start: Vector3, end: Vector3) -> float:
	var point_2d := Vector2(point.x, point.z)
	var start_2d := Vector2(start.x, start.z)
	var end_2d := Vector2(end.x, end.z)
	var segment: Vector2 = end_2d - start_2d
	var length_sq: float = segment.length_squared()
	if length_sq <= 0.0001:
		return point_2d.distance_to(start_2d)
	var t: float = clampf((point_2d - start_2d).dot(segment) / length_sq, 0.0, 1.0)
	return point_2d.distance_to(start_2d + (segment * t))


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


func _has_duplicate_objective_text_outside_rail_and_right_panel() -> bool:
	var forbidden_labels: Array[String] = [
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
	return point.x >= StoreVisualSweepScript.VIEWPORT_MARGIN_PX \
		and point.y >= StoreVisualSweepScript.VIEWPORT_MARGIN_PX \
		and point.x <= viewport_size.x - StoreVisualSweepScript.VIEWPORT_MARGIN_PX \
		and point.y <= viewport_size.y - StoreVisualSweepScript.VIEWPORT_MARGIN_PX


func _assert_inspiration_closeout(closeout: Dictionary, context: String) -> void:
	assert_false(closeout.is_empty(), "%s must record inspiration closeout" % context)
	if closeout.is_empty():
		return
	var clusters: Array = closeout.get("reference_clusters", []) as Array
	assert_gt(clusters.size(), 0, "%s must name a reference cluster" % context)
	for raw_cluster: Variant in clusters:
		assert_true(raw_cluster is Dictionary, "%s cluster must be a dictionary" % context)
		if raw_cluster is not Dictionary:
			continue
		var cluster: Dictionary = raw_cluster as Dictionary
		assert_false(str(cluster.get("id", "")).is_empty(), "%s cluster id missing" % context)
		assert_false(
			str(cluster.get("label", "")).is_empty(),
			"%s cluster label missing" % context
		)
		assert_false(
			str(cluster.get("pattern", "")).is_empty(),
			"%s cluster pattern missing" % context
		)
	assert_false(
		str(closeout.get("mallcore_original_adaptation", "")).is_empty(),
		"%s must describe the original Mallcore adaptation" % context
	)
	assert_false(
		str(closeout.get("intended_pattern_validation", "")).is_empty(),
		"%s must describe the pattern validation intent" % context
	)
	assert_eq(
		closeout.get("required_originality_commands", []),
		["bash scripts/validate_originality.sh", "bash tests/validate_original_content.sh"]
	)
	var policy: Dictionary = closeout.get("source_policy", {}) as Dictionary
	assert_eq(str(policy.get("allowed_use", "")), "pattern_reference_only")
	var forbidden_use: Array = policy.get("forbidden_use", []) as Array
	for forbidden: String in [
		"import",
		"trace",
		"paint_over",
		"clone_logo",
		"copy_ui",
		"duplicate_proprietary_product_store_or_character_design",
	]:
		assert_true(
			forbidden_use.has(forbidden),
			"%s must forbid source use %s" % [context, forbidden]
		)


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
