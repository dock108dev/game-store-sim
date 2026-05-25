## Shared manifest and PNG writer for the store_session store visual review sweep.
class_name StoreVisualSweep
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)
const ARTIFACT_SUITE: String = "retro_games_day_one"
const ARTIFACT_DIR: String = "screenshots/visual_sweep/retro_games_day_one"
const ACCEPTANCE_ARTIFACT_DIR: String = "visual_sweep/retro_games_day_one"
const ACCEPTANCE_CURRENT_DIR: String = "visual_sweep/retro_games_day_one/current"
const ACCEPTANCE_DIFF_DIR: String = "visual_sweep/retro_games_day_one/diff"
const REVIEW_MANIFEST_DIR: String = "reports/visual_sweep/retro_games_day_one"
const REVIEW_MANIFEST_FILENAME: String = "review_manifest.json"
const VIEWPORT_MARGIN_PX: float = 8.0
const CAPTURE_RESOLUTION: Vector2i = Vector2i(1280, 720)
const CAPTURE_CAMERA_FOV: float = 70.0
const CAPTURE_RANDOM_SEED: int = 1801
const ACCEPTANCE_TARGET: String = "first_ten_seconds_route_views"
const HUD_CONTEXT_LABEL: String = "First Day — 8:00 AM"
const _MAX_SLUG_LENGTH: int = 64


## Returns the normal store_session review beats. These are the first-ten-seconds
## acceptance target for this phase; broader whole-room checks stay secondary.
static func rows() -> Array[Dictionary]:
	return first_ten_seconds_rows()


## Returns phase-specific first-run captures for the route views players see first.
static func first_ten_seconds_rows() -> Array[Dictionary]:
	return [
		{
			"index": 1,
			"name": "spawn_first_look",
			"label": "Spawn first look",
			"filename": "01_spawn_first_look.png",
			"camera": Vector3(0.0, 1.70, 5.82),
			"focus": "ExpandableStoreShell/StarterSignLabel",
			"anchors":
			[
				"ExpandableStoreShell/StarterSignLabel",
				"ExpandableStoreShell/StarterBackWall",
				"ExpandableStoreShell/StarterAisleMat",
				"ExpandableStoreShell/EntryThreshold",
			],
			"route_anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopRegister",
			"next_destination": "manager and checkout register",
			"local_action": "take in the store identity and walk to the counter",
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 2,
			"name": "checkout_manager_counter",
			"label": "Checkout and manager counter",
			"filename": "02_checkout_manager_counter.png",
			"camera": Vector3(1.36, 1.52, 5.48),
			"focus": "StoreSessionDayOneCustomer",
			"anchors":
			[
				"checkout_counter",
				"StoreSessionDayOneCustomer",
				"StoreSessionDayEndTrigger",
				"ExpandableStoreShell/CheckoutRegisterPractical",
				"ExpandableStoreShell/FrontDoorPushPlate",
			],
			"route_anchor": "StoreSessionDayOneCustomer",
			"next_destination": "checkout counter",
			"local_action": "talk to the manager/register area",
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 3,
			"name": "shelf_wall_product_focus",
			"label": "Starter display table focus",
			"filename": "03_shelf_wall_product_focus.png",
			"camera": Vector3(-0.18, 1.58, 0.02),
			"focus": "StoreSessionRestockShelf",
			"anchors":
			[
				"StoreSessionRestockShelf",
				"StoreSessionRestockShelf/ShelfBoard",
				"StoreSessionRestockShelf/EmptyOverlay",
				"ExpandableStoreShell/GamesBayLabel",
			],
			"route_anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopShelf",
			"next_destination": "starter display table",
			"local_action": "read the empty table target before starter stock appears",
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 4,
			"name": "stockroom_path_work_area",
			"label": "Stockroom path work area",
			"filename": "04_stockroom_path_work_area.png",
			"camera": Vector3(1.35, 1.58, 1.56),
			"focus": "StoreSessionBackroomPickup/StockBoxLabel",
			"anchors":
			[
				"StoreSessionBackroomPickup",
				"StoreSessionBackroomPickup/StockBox",
				"StoreSessionBackroomPickup/StockBoxLabel",
				"ExpandableStoreShell/StockroomPartition",
				"ExpandableStoreShell/StockroomFloorTape",
			],
			"route_anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopBackroom",
			"next_destination": "stockroom pickup",
			"local_action": "walk to the stock box and pickup work area",
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
	]


## Returns older broad-store review context kept out of phase acceptance.
static func full_store_review_context() -> Dictionary:
	return {
		"review_target": "full_store_context",
		"acceptance_role": "secondary_context_only",
			"notes": (
				"Whole-room context may be reviewed separately; "
				+ "this phase passes or fails on the first-ten-seconds route views."
			),
		"beats": _serializable_rows(full_store_rows()),
	}


## Returns the older eight-angle full-store sweep for secondary review context.
static func full_store_rows() -> Array[Dictionary]:
	return [
		{
			"index": 1,
			"name": "entrance_looking_in",
			"label": "Entrance looking in",
			"filename": "01_entrance_looking_in.png",
			"camera": Vector3(2.2, 1.7, 9.15),
			"focus": "InteriorSignage/StoreNameBanner",
			"anchors": ["Storefront", "EntranceInterior", "ReadabilityProps/FloorDisplayIsland"],
			"scope": "full_store",
			"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
			"review_target": "full_store_context",
		},
		{
			"index": 2,
			"name": "center_to_checkout",
			"label": "Center to checkout",
			"filename": "02_center_to_checkout.png",
			"camera": Vector3(0.0, 1.75, 0.25),
			"focus": "Checkout/Register/CheckoutSign",
			"anchors": ["Checkout", "StoreSessionDayEndTrigger", "ReadabilityProps/CheckoutCounterDressing"],
			"scope": "full_store",
			"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
			"review_target": "full_store_context",
		},
		{
			"index": 3,
			"name": "center_to_shelves",
			"label": "Center to shelves",
			"filename": "03_center_to_shelves.png",
			"camera": Vector3(0.0, 1.75, 0.25),
			"focus": "ZoneLabels/ShelvesLabel",
			"anchors": ["StoreSessionRestockShelf", "ReadabilityProps/ShelfSpineRuns", "AccessoriesBin"],
			"scope": "full_store",
			"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
			"review_target": "full_store_context",
		},
		{
			"index": 4,
			"name": "center_to_backroom",
			"label": "Center to backroom",
			"filename": "04_center_to_backroom.png",
			"camera": Vector3(0.0, 1.75, 0.25),
			"focus": "StoreSessionBackroomPickup/StockBoxLabel",
			"anchors": ["back_room", "StoreSessionBackroomPickup", "ReadabilityProps/BackroomDressing"],
			"scope": "full_store",
			"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
			"review_target": "full_store_context",
		},
		{
			"index": 5,
			"name": "checkout_across_store",
			"label": "Checkout across store",
			"filename": "05_checkout_across_store.png",
			"camera": Vector3(4.9, 1.75, 6.9),
			"focus": "ZoneLabels/StaffPicksLabel",
			"anchors": ["Checkout", "staff_picks_table", "ReadabilityProps/FloorDisplayIsland"],
			"scope": "full_store",
			"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
			"review_target": "full_store_context",
		},
		{
			"index": 6,
			"name": "stockroom_looking_out",
			"label": "Stockroom looking out",
			"filename": "06_stockroom_looking_out.png",
			"camera": Vector3(0.0, 1.75, -8.45),
			"focus": "EntranceInterior",
			"anchors": ["back_room", "Checkout", "ReadabilityProps/DayOneRouteMarkers"],
			"scope": "full_store",
			"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
			"review_target": "full_store_context",
		},
		{
			"index": 7,
			"name": "try_it_testing_corner",
			"label": "Try-it testing corner",
			"filename": "07_try_it_testing_corner.png",
			"camera": Vector3(-2.8, 1.75, -4.5),
			"focus": "crt_demo_area/ComingSoonLabel",
			"anchors": ["crt_demo_area", "crt_demo_area/SetupBarrierRail"],
			"scope": "full_store",
			"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
			"review_target": "full_store_context",
		},
		{
			"index": 8,
			"name": "opposite_corner_full_room_view",
			"label": "Opposite-corner full-room view",
			"filename": "08_opposite_corner_full_room_view.png",
			"camera": Vector3(-6.4, 3.4, 8.4),
			"focus": "ReadabilityProps/DayOneRouteMarkers/TrainingStopShelf",
			"anchors": ["ZoneLabels", "ReadabilityProps/ZoneLighting", "ReadabilityProps/ZoneIdentity"],
			"scope": "full_store",
			"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
			"review_target": "full_store_context",
		},
	]


## Returns the human review checks that must be applied to every sweep image.
static func review_criteria() -> Array[String]:
	return first_ten_seconds_review_criteria()


## Returns first-ten-seconds checks reviewers apply to the phase artifacts.
static func first_ten_seconds_review_criteria() -> Array[String]:
	return [
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
		"walking paths",
		"cramped/empty balance",
		"backwards signs",
		"random cubes/panels",
		"product alignment",
		"first-day UI state",
		"First Day — 8:00 AM is visible",
		"HUD supports rather than fights the route views",
		"camera-visible density replaces hidden prop count",
	]


## Returns composition failures that disqualify a screenshot from acceptance.
static func design_failure_criteria() -> Array[String]:
	return [
		"oversized signs dominate the composition",
		"slab shelves dominate the composition",
		"random loose primitives dominate the composition",
		"color-strip noise dominates the composition",
		"floating text dominates the composition",
		"mismatched scale dominates the composition",
	]


## Returns the first-run route markers that reviewers should be able to infer.
static func first_run_flow_steps() -> Array[Dictionary]:
	return [
		{
			"step": "manager",
			"destination": "manager note",
			"anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopManager",
		},
		{
			"step": "register check",
			"destination": "checkout register",
			"anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopRegister",
		},
		{
			"step": "backroom inventory",
			"destination": "inventory pickup",
			"anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopBackroom",
		},
		{
			"step": "shelf stocking",
			"destination": "restock shelf",
			"anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopShelf",
		},
		{
			"step": "practice customer",
			"destination": "practice customer",
			"anchor": "StoreSessionDayOneCustomer",
		},
		{
			"step": "open-store",
			"destination": "open-store closeout",
			"anchor": "StoreSessionDayEndTrigger",
		},
	]


## Writes the viewport image to a stable PNG filename and returns path details.
static func save_viewport_png(
	viewport: Viewport,
	dir_path: String,
	filename: String,
	allow_placeholder: bool = false
) -> Dictionary:
	var dir_result: Dictionary = ensure_artifact_dir(dir_path)
	if not bool(dir_result.get("ok", false)):
		return dir_result
	var resolved_dir: String = str(dir_result.get("path", dir_path))
	if DisplayServer.get_name() == "headless":
		if allow_placeholder:
			return _save_placeholder_png(resolved_dir, filename)
		return _error("Viewport image unavailable in headless display mode")
	if viewport == null:
		return _error("Viewport unavailable")
	var texture: ViewportTexture = viewport.get_texture()
	if texture == null:
		return _error("Viewport texture unavailable")
	var image: Image = texture.get_image()
	if image == null or image.get_width() <= 0 or image.get_height() <= 0:
		return _error("Viewport image unavailable")
	var safe_filename: String = sanitize_slug(filename.get_basename()) + ".png"
	var path: String = "%s/%s" % [resolved_dir, safe_filename]
	var save_err: int = image.save_png(path)
	if save_err != OK:
		return _error("save_png err=%d" % save_err)
	_record_artifact("screenshot", path, "viewport")
	return {
		"ok": true,
		"path": path,
		"absolute_path": ProjectSettings.globalize_path(path),
		"filename": safe_filename,
		"width": image.get_width(),
		"height": image.get_height(),
		"placeholder": false,
	}


## Ensures the screenshot artifact directory exists.
static func ensure_artifact_dir(dir_path: String) -> Dictionary:
	return AutomationArtifactsScript.ensure_artifact_dir(dir_path)


## Writes a JSON review manifest next to the PNG artifacts.
static func write_review_manifest(
	dir_path: String,
	rows_to_write: Array[Dictionary],
	captures: Array[Dictionary] = []
) -> Dictionary:
	var dir_result: Dictionary = ensure_artifact_dir(dir_path)
	if not bool(dir_result.get("ok", false)):
		return dir_result
	var resolved_dir: String = str(dir_result.get("path", dir_path))
	var path: String = "%s/%s" % [resolved_dir, REVIEW_MANIFEST_FILENAME]
	var payload: Dictionary = {
		"artifact_dir": ProjectSettings.globalize_path(resolved_dir),
		"acceptance_target": ACCEPTANCE_TARGET,
		"review_criteria": review_criteria(),
		"first_ten_seconds_review_criteria": first_ten_seconds_review_criteria(),
		"design_failure_criteria": design_failure_criteria(),
		"first_run_flow_steps": first_run_flow_steps(),
		"full_store_review_context": full_store_review_context(),
		"visual_scope_profile": StoreVisualScopeProfileScript.scope_manifest(),
		"capture_policy": capture_policy(),
		"baseline_review_rules": baseline_review_rules(),
		"diff_review_policy": diff_review_policy(),
		"manual_review_template": _manual_review_template(rows_to_write),
		"beats": _serializable_rows(rows_to_write),
		"captures": captures,
	}
	var write_result: Dictionary = AutomationArtifactsScript.write_recorded_json(
		path,
		payload,
		"report",
		"",
		"visual_sweep",
		"manifest",
		"Cannot write review manifest"
	)
	if not bool(write_result.get("ok", false)):
		return write_result
	return {
		"ok": true,
		"path": path,
		"absolute_path": ProjectSettings.globalize_path(path),
	}


## Sanitizes a human label into a bounded filename slug.
static func sanitize_slug(raw: String, max_length: int = _MAX_SLUG_LENGTH) -> String:
	return AutomationArtifactsScript.sanitize_filename_slug(raw, max_length)


## Returns the resolved screenshot directory for the store-session visual sweep.
static func visual_sweep_dir() -> String:
	return AutomationArtifactsScript.visual_sweep_screenshot_dir(ARTIFACT_SUITE)


## Returns the artifact directory for acceptance captures consumed by diffing.
static func acceptance_current_dir() -> String:
	return AutomationArtifactsScript.artifact_path(ACCEPTANCE_CURRENT_DIR)


## Returns the artifact directory for visual diff heatmaps and metadata.
static func acceptance_diff_dir() -> String:
	return AutomationArtifactsScript.artifact_path(ACCEPTANCE_DIFF_DIR)


## Returns the artifact directory for the acceptance manifest and current captures.
static func acceptance_manifest_dir() -> String:
	return AutomationArtifactsScript.artifact_path(ACCEPTANCE_ARTIFACT_DIR)


## Returns the resolved review-manifest directory for the visual sweep.
static func review_manifest_dir() -> String:
	return AutomationArtifactsScript.report_dir("visual_sweep", ARTIFACT_SUITE)


## Returns the deterministic capture contract used by CI and baseline promotion.
static func capture_policy() -> Dictionary:
	return {
		"display_mode": "display_backed_required",
		"headless_allowed": false,
		"placeholder_allowed": false,
		"resolution": [CAPTURE_RESOLUTION.x, CAPTURE_RESOLUTION.y],
		"camera_fov": CAPTURE_CAMERA_FOV,
		"random_seed": CAPTURE_RANDOM_SEED,
		"renderer": "gl_compatibility",
		"hud_context_required": HUD_CONTEXT_LABEL,
		"acceptance_target": ACCEPTANCE_TARGET,
		"scope_modes": [
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL,
		],
	}


## Returns manual baseline acceptance checks preserved in review manifests.
static func baseline_review_rules() -> Array[String]:
	return [
		"capture must be generated by the Linux display-backed visual sweep",
		"filename must match the canonical first-ten-seconds row",
		"placeholder must be false",
		"dimensions must match the pinned capture resolution",
		"debug and editor UI must be absent",
		"HUD context First Day — 8:00 AM must be visible",
		"route anchor must not be visually drowned by decorative props",
		"placeholder geometry and unintentional clutter are rejection reasons",
	]


## Returns the automated diff intent and threshold names for review tooling.
static func diff_review_policy() -> Dictionary:
	return {
		"noise_classification": "small renderer/font noise is tracked separately from meaningful hierarchy, framing, and composition changes",
		"metrics": [
			"dimensions",
			"noise_filtered_changed_pixels",
			"mean_absolute_error",
			"max_delta",
		],
		"outputs": [
			"diff_manifest.json",
			"heatmap_png",
		],
	}


static func _serializable_rows(rows_to_write: Array[Dictionary]) -> Array[Dictionary]:
	var serializable: Array[Dictionary] = []
	for row: Dictionary in rows_to_write:
		var camera: Vector3 = row.get("camera", Vector3.ZERO) as Vector3
		serializable.append({
			"index": int(row.get("index", 0)),
			"name": str(row.get("name", "")),
			"label": str(row.get("label", "")),
			"filename": str(row.get("filename", "")),
			"camera": [camera.x, camera.y, camera.z],
			"focus": str(row.get("focus", "")),
			"anchors": row.get("anchors", []),
			"route_anchor": str(row.get("route_anchor", "")),
			"next_destination": str(row.get("next_destination", "")),
			"local_action": str(row.get("local_action", "")),
			"scope": str(row.get("scope", "")),
			"visual_scope_mode": str(row.get("visual_scope_mode", "")),
			"review_target": str(row.get("review_target", "")),
			"hud_context_required": str(row.get("hud_context_required", "")),
		})
	return serializable


static func _manual_review_template(rows_to_write: Array[Dictionary]) -> Dictionary:
	var verdicts: Array[Dictionary] = []
	for row: Dictionary in rows_to_write:
		verdicts.append({
			"beat": str(row.get("filename", "")),
			"status": "pass|fail|needs_changes",
			"failed_review_criteria": [],
			"failed_design_criteria": [],
			"notes": "",
		})
	return {
		"verdicts": verdicts,
	}


static func _save_placeholder_png(dir_path: String, filename: String) -> Dictionary:
	var safe_filename: String = sanitize_slug(filename.get_basename()) + ".png"
	var path: String = "%s/%s" % [dir_path, safe_filename]
	var image: Image = Image.create_empty(1280, 720, false, Image.FORMAT_RGBA8)
	var base_color: Color = Color(0.08, 0.07, 0.06, 1.0)
	var stripe_color: Color = Color(0.91, 0.647, 0.278, 1.0)
	image.fill(base_color)
	for x: int in range(0, image.get_width()):
		if x % 96 < 48:
			for y: int in range(0, 48):
				image.set_pixel(x, y, stripe_color)
	var save_err: int = image.save_png(path)
	if save_err != OK:
		return _error("save_png err=%d" % save_err)
	_record_artifact("screenshot", path, "placeholder")
	return {
		"ok": true,
		"path": path,
		"absolute_path": ProjectSettings.globalize_path(path),
		"filename": safe_filename,
		"width": image.get_width(),
		"height": image.get_height(),
		"placeholder": true,
	}


static func _record_artifact(artifact_type: String, path: String, capture_mode: String) -> void:
	AutomationArtifactsScript.record_artifact(
		artifact_type,
		path,
		ARTIFACT_SUITE,
		"visual_sweep",
		capture_mode
	)


static func _error(message: String) -> Dictionary:
	return {
		"ok": false,
		"error": message,
	}
