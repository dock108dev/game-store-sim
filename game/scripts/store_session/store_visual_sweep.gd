## Shared manifest and PNG writer for the beta store visual review sweep.
class_name BetaScreenshotSweep
extends RefCounted

const ARTIFACT_DIR: String = "user://screenshots/visual_sweep/retro_games_day_one"
const REVIEW_MANIFEST_FILENAME: String = "review_manifest.json"
const VIEWPORT_MARGIN_PX: float = 8.0
const ACCEPTANCE_TARGET: String = "reference_corner_first_run"
const HUD_CONTEXT_LABEL: String = "Opening Shift — 8:00 AM"
const _MAX_SLUG_LENGTH: int = 64


## Returns the normal beta review beats. These are the reference-corner
## acceptance target for this phase; broader whole-room checks stay secondary.
static func rows() -> Array[Dictionary]:
	return reference_corner_rows()


## Returns phase-specific first-run captures for the checkout/shelf corner.
static func reference_corner_rows() -> Array[Dictionary]:
	return [
		{
			"index": 1,
			"name": "spawn_toward_checkout",
			"label": "Spawn toward checkout",
			"filename": "01_spawn_toward_checkout.png",
			"camera": Vector3(2.2, 1.7, 8.75),
			"focus": "Checkout/Register/CheckoutSign",
			"anchors":
			[
				"Checkout",
				"BetaDayOneCustomer",
				"BetaDayEndTrigger",
				"ReadabilityProps/CheckoutCounterDressing",
			],
			"route_anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopRegister",
			"next_destination": "checkout register",
			"local_action": "walk to the register and read the checkout prompt",
			"scope": "reference_corner",
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 2,
			"name": "customer_register_spot",
			"label": "Customer standing spot at register",
			"filename": "02_customer_register_spot.png",
			"camera": Vector3(2.8, 1.55, 5.95),
			"focus": "BetaDayOneCustomer",
			"anchors":
			[
				"FrontLaneQueue",
				"BetaDayOneCustomer",
				"ReadabilityProps/CheckoutCounterDressing/CustomerServiceSpotMat",
			],
			"route_anchor": "BetaDayOneCustomer",
			"next_destination": "practice customer",
			"local_action": "notice where the customer waits at the register",
			"scope": "reference_corner",
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 3,
			"name": "behind_side_checkout",
			"label": "Behind/side checkout",
			"filename": "03_behind_side_checkout.png",
			"camera": Vector3(6.35, 1.65, 4.7),
			"focus": "Checkout/Register/CheckoutDetails",
			"anchors":
			[
				"Checkout/Register",
				"Checkout/Register/CustomerWaitPosition",
				"ReadabilityProps/CheckoutCounterDressing",
				"ReadabilityProps/ZoneIdentity/ReferenceCornerWallPanel",
			],
			"route_anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopRegister",
			"next_destination": "checkout register",
			"local_action": "understand the register-side interaction zone",
			"scope": "reference_corner",
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 4,
			"name": "shelf_ten_feet",
			"label": "Shelf from roughly 10 feet",
			"filename": "04_shelf_ten_feet.png",
			"camera": Vector3(-1.0, 1.75, -3.85),
			"focus": "ZoneLabels/ShelvesLabel",
			"anchors":
			[
				"CartRackLeft",
				"BetaRestockShelf",
				"ReadabilityProps/ShelfSpineRuns",
				"ReadabilityProps/ProductDisplayRows",
			],
			"route_anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopShelf",
			"next_destination": "restock shelf",
			"local_action": "walk to the shelf run from the checkout corner",
			"scope": "reference_corner",
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 5,
			"name": "product_shelf_closeup",
			"label": "Close-up product shelf",
			"filename": "05_product_shelf_closeup.png",
			"camera": Vector3(-0.45, 1.35, -1.55),
			"focus": "ReadabilityProps/ProductDisplayRows/DungeonDad64_ShelfA",
			"anchors":
			[
				"BetaRestockShelf",
				"ReadabilityProps/ProductDisplayRows/DungeonDad64_ShelfA",
				"ReadabilityProps/ProductDisplayRows/SpaceMall3_ShelfA",
				"ReadabilityProps/ShelfSpineRuns",
			],
			"route_anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopShelf",
			"next_destination": "restock shelf",
			"local_action": "read the shelf product area and stock target",
			"scope": "reference_corner",
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 6,
			"name": "checkout_shelf_walk_path",
			"label": "Walking path between checkout and shelf",
			"filename": "06_checkout_shelf_walk_path.png",
			"camera": Vector3(3.45, 1.65, 2.75),
			"focus": "ReadabilityProps/DayOneRouteMarkers/TrainingStopShelf",
			"anchors":
			[
				"Checkout",
				"BetaRestockShelf",
				"ReadabilityProps/DayOneRouteMarkers",
				"ReadabilityProps/ZoneIdentity/ReferenceCornerFloorInset",
			],
			"route_anchor": "ReadabilityProps/DayOneRouteMarkers/TrainingStopShelf",
			"next_destination": "restock shelf",
			"local_action": "follow the path from checkout to shelf",
			"scope": "reference_corner",
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
	]


## Returns older broad-store review context kept out of phase acceptance.
static func full_store_review_context() -> Dictionary:
	return {
		"review_target": "full_store_context",
		"acceptance_role": "secondary_context_only",
		"notes": "Whole-room context may be reviewed separately; this phase passes or fails on the reference-corner beats.",
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
			"review_target": "full_store_context",
		},
		{
			"index": 2,
			"name": "center_to_checkout",
			"label": "Center to checkout",
			"filename": "02_center_to_checkout.png",
			"camera": Vector3(0.0, 1.75, 0.25),
			"focus": "Checkout/Register/CheckoutSign",
			"anchors": ["Checkout", "BetaDayEndTrigger", "ReadabilityProps/CheckoutCounterDressing"],
			"scope": "full_store",
			"review_target": "full_store_context",
		},
		{
			"index": 3,
			"name": "center_to_shelves",
			"label": "Center to shelves",
			"filename": "03_center_to_shelves.png",
			"camera": Vector3(0.0, 1.75, 0.25),
			"focus": "ZoneLabels/ShelvesLabel",
			"anchors": ["BetaRestockShelf", "ReadabilityProps/ShelfSpineRuns", "AccessoriesBin"],
			"scope": "full_store",
			"review_target": "full_store_context",
		},
		{
			"index": 4,
			"name": "center_to_backroom",
			"label": "Center to backroom",
			"filename": "04_center_to_backroom.png",
			"camera": Vector3(0.0, 1.75, 0.25),
			"focus": "BetaBackroomPickup/StockBoxLabel",
			"anchors": ["back_room", "BetaBackroomPickup", "ReadabilityProps/BackroomDressing"],
			"scope": "full_store",
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
			"review_target": "full_store_context",
		},
	]


## Returns the human review checks that must be applied to every sweep image.
static func review_criteria() -> Array[String]:
	return reference_corner_review_criteria()


## Returns reference-corner checks reviewers apply to the phase artifacts.
static func reference_corner_review_criteria() -> Array[String]:
	return [
		"reference-corner legibility",
		"new player can infer the next destination",
		"new player can infer the local action",
		"no debug/editor UI",
		"no duplicated objective/action text",
		"no misleading unavailable destination",
		"readable local prompt ownership",
		"checkout/shelf/queue flow is understandable",
		"walking paths",
		"cramped/empty balance",
		"backwards signs",
		"random cubes/panels",
		"product alignment",
		"opening-shift UI state",
		"Opening Shift — 8:00 AM is visible",
		"HUD supports rather than fights the reference corner",
		"deferred surfaces not promoted",
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
			"anchor": "BetaDayOneCustomer",
		},
		{
			"step": "open-store",
			"destination": "open-store closeout",
			"anchor": "BetaDayEndTrigger",
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
	if DisplayServer.get_name() == "headless":
		if allow_placeholder:
			return _save_placeholder_png(dir_path, filename)
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
	var path: String = "%s/%s" % [dir_path, safe_filename]
	var save_err: int = image.save_png(path)
	if save_err != OK:
		return _error("save_png err=%d" % save_err)
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
	var dir_err: int = DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		return _error("Cannot create %s (err=%d)" % [dir_path, dir_err])
	return {
		"ok": true,
		"path": dir_path,
		"absolute_path": ProjectSettings.globalize_path(dir_path),
	}


## Writes a JSON review manifest next to the PNG artifacts.
static func write_review_manifest(
	dir_path: String,
	rows_to_write: Array[Dictionary]
) -> Dictionary:
	var dir_result: Dictionary = ensure_artifact_dir(dir_path)
	if not bool(dir_result.get("ok", false)):
		return dir_result
	var path: String = "%s/%s" % [dir_path, REVIEW_MANIFEST_FILENAME]
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _error("Cannot write review manifest: %s" % path)
	var payload: Dictionary = {
		"artifact_dir": ProjectSettings.globalize_path(dir_path),
		"acceptance_target": ACCEPTANCE_TARGET,
		"review_criteria": review_criteria(),
		"reference_corner_review_criteria": reference_corner_review_criteria(),
		"design_failure_criteria": design_failure_criteria(),
		"first_run_flow_steps": first_run_flow_steps(),
		"full_store_review_context": full_store_review_context(),
		"manual_review_template": _manual_review_template(rows_to_write),
		"beats": _serializable_rows(rows_to_write),
	}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return {
		"ok": true,
		"path": path,
		"absolute_path": ProjectSettings.globalize_path(path),
	}


## Sanitizes a human label into a bounded filename slug.
static func sanitize_slug(raw: String, max_length: int = _MAX_SLUG_LENGTH) -> String:
	var lowered: String = raw.get_basename().to_lower()
	var sanitized: String = ""
	for i: int in range(lowered.length()):
		var codepoint: int = lowered.unicode_at(i)
		if (codepoint >= 0x30 and codepoint <= 0x39) \
				or (codepoint >= 0x61 and codepoint <= 0x7A) \
				or codepoint == 0x5F:
			sanitized += char(codepoint)
		elif codepoint == 0x20 or codepoint == 0x2D:
			sanitized += "_"
	if sanitized.is_empty():
		sanitized = "screenshot"
	if max_length > 0 and sanitized.length() > max_length:
		sanitized = sanitized.substr(0, max_length)
	return sanitized


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
	return {
		"ok": true,
		"path": path,
		"absolute_path": ProjectSettings.globalize_path(path),
		"filename": safe_filename,
		"width": image.get_width(),
		"height": image.get_height(),
		"placeholder": true,
	}


static func _error(message: String) -> Dictionary:
	return {
		"ok": false,
		"error": message,
	}
