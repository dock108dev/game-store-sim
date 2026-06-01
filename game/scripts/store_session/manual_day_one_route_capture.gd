## Manifest writer for the manual Day 1 route capture.
class_name ManualDayOneRouteCapture
extends RefCounted

const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const StoreProofContractScript: GDScript = preload(
	"res://game/scripts/store_session/store_code_to_screen_proof_contract.gd"
)

const ARTIFACT_DIR: String = "user://screenshots/manual_routes/retro_games_day_one_loop"
const MANIFEST_FILENAME: String = "route_manifest.json"
const MANUAL_REVIEW_FILENAME: String = "manual_review.md"
const CAPTURE_DIR_NAME: String = "captures"
const SNAPSHOT_DIR_NAME: String = "snapshots"
const ARTIFACT_TYPE: String = "manual_day1_loop_route"
const SCHEMA_VERSION: int = 1

const REQUIRED_REVIEW_BEATS: Array[String] = [
	"manager_prompt",
	"register_prompt",
	"backroom_pickup_prompt",
	"training_shelf_transition",
	"before_customer",
	"customer_decision_card",
	"post_customer_recovery",
	"stocked_shelf_stat_change",
	"close_day_prompt",
	"close_day_summary",
]

## Returns the ordered manual capture beats for the continuous Day 1 route.
static func route_beats() -> Array[Dictionary]:
	var beats: Array[Dictionary] = [
		_beat(
			1,
			"manager_prompt",
			"Manager prompt",
			"01_manager_prompt.png",
			"Walk to the manager proxy at checkout before interacting.",
			"training_talk_manager",
			"talk_to_manager",
			"Talk to Manager",
			{
				"header": "FIRST DAY",
				"stats": {"Customers": "0", "Sales": "0", "Shelf": "0 / 0", "Stockroom": "0"}
			},
			{"shelf": 0, "backroom": 0},
			{"state": "manager_role_visible", "event_id": ""},
			{"cash_delta": 0, "reputation_delta": 0, "manager_trust_delta": 0},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:421",
				"tests/gut/test_store_session_day_one_critical_path.gd:422",
			]
		),
		_beat(
			2,
			"register_prompt",
			"Register prompt",
			"02_register_prompt.png",
			"Press interact on the manager prompt and walk to the register.",
			"training_check_register",
			"check_register",
			"Check Register",
			{
				"header": "FIRST DAY",
				"stats": {"Customers": "0", "Sales": "0", "Shelf": "0 / 0", "Stockroom": "0"}
			},
			{"shelf": 0, "backroom": 0},
			{"state": "waiting_for_register_check", "event_id": ""},
			{"cash_delta": 0, "reputation_delta": 0, "manager_trust_delta": 0},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:425",
				"tests/gut/test_store_session_day_one_critical_path.gd:426",
				"tests/gut/test_store_session_day_one_critical_path.gd:429",
			]
		),
		_beat(
			3,
			"backroom_pickup_prompt",
			"Backroom pickup prompt",
			"03_backroom_pickup_prompt.png",
			"Press interact at the register and walk to the back room pickup.",
			"training_back_room_inventory",
			"back_room_inventory",
			"Inspect Starter Stock Box",
			{
				"header": "FIRST DAY",
				"stats": {"Customers": "0", "Sales": "0", "Shelf": "0 / 0", "Stockroom": "3"}
			},
			{"shelf": 0, "backroom": 3},
			{"state": "pickup_enabled", "event_id": ""},
			{"cash_delta": 0, "reputation_delta": 0, "manager_trust_delta": 0},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:431",
				"tests/gut/test_store_session_day_one_critical_path.gd:432",
				"tests/gut/test_store_session_day_one_critical_path.gd:435",
			]
		),
		_beat(
			4,
			"training_shelf_transition",
			"Training shelf transition",
			"04_training_shelf_transition.png",
			"Pick up the back room stock and walk to the training shelf.",
			"training_stock_shelf",
			"stock_shelf",
			"Stock Starter Display",
			{
				"header": "FIRST DAY",
				"stats": {"Customers": "0", "Sales": "0", "Shelf": "0 / 3", "Stockroom": "3"}
			},
			{"shelf": 0, "backroom": 3, "carrying_stock": true},
			{"state": "stocking_training_enabled", "event_id": ""},
			{"cash_delta": 0, "reputation_delta": 0, "manager_trust_delta": 0},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:442",
				"tests/gut/test_store_session_day_one_critical_path.gd:443",
				"tests/gut/test_store_session_day_one_critical_path.gd:444",
			]
		),
		_beat(
			5,
			"before_customer",
			"Before customer",
			"05_before_customer.png",
			"Stock the training shelf and return to the customer at checkout.",
			"talk_to_customer",
			"talk_to_customer",
			"Talk to customer",
			{
				"header_prefix": "DAY 1",
				"stats": {"Customers": "0", "Sales": "0", "Shelf": "3 / 3", "Stockroom": "0"}
			},
			{"shelf": 3, "backroom": 0, "carrying_stock": false},
			{"state": "waiting_for_customer_decision", "event_id": "day01_wrong_console_parent"},
			{"cash_delta": 0, "reputation_delta": 0, "manager_trust_delta": 0},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:453",
				"tests/gut/test_store_session_day_one_critical_path.gd:455",
				"tests/gut/test_store_session_day_one_critical_path.gd:456",
			]
		),
		_beat(
			6,
			"customer_decision_card",
			"Customer decision card",
			"06_customer_decision_card.png",
			"Interact with the customer and leave the decision card open.",
			"talk_to_customer",
			"talk_to_customer",
			"Decision card visible",
			{
				"modal": "customer_decision",
				"stats": {"Customers": "0", "Sales": "0", "Shelf": "3 / 3", "Stockroom": "0"}
			},
			{"shelf": 3, "backroom": 0, "carrying_stock": false},
			{"state": "choice_pending", "event_id": "day01_wrong_console_parent"},
			{"cash_delta": 0, "reputation_delta": 0, "manager_trust_delta": 0},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:460",
				"tests/gut/test_store_session_day_one_critical_path.gd:464",
				"tests/gut/test_store_session_day_one_critical_path.gd:467",
			]
		),
		_beat(
			7,
			"result_acknowledgement",
			"Result acknowledgement",
			"07_result_acknowledgement.png",
			"Choose the canonical exchange option and leave the result panel open.",
			"talk_to_customer",
			"talk_to_customer",
			"Result panel visible",
			{
				"modal": "customer_result",
				"stats": {"Customers": "0", "Sales": "0", "Shelf": "3 / 3", "Stockroom": "0"}
			},
			{"shelf": 3, "backroom": 0, "carrying_stock": false},
			{"state": "result_visible", "event_id": "day01_wrong_console_parent"},
			{"cash_delta": 15, "reputation_delta": 2, "manager_trust_delta": 2},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:473",
				"tests/gut/test_store_session_day_one_critical_path.gd:480",
				"tests/gut/test_store_session_day_one_critical_path.gd:483",
			]
		),
		_beat(
			8,
			"post_customer_recovery",
			"Post-customer recovery",
			"08_post_customer_recovery.png",
			"Acknowledge the result and capture after the customer starts leaving.",
			"talk_to_customer",
			"back_room_inventory",
			"Inspect Starter Stock Box",
			{
				"stats": {"Customers": "1", "Sales": "1", "Shelf": "3 / 3", "Stockroom": "0"}
			},
			{"shelf": 3, "backroom": 0, "carrying_stock": false},
			{"state": "exit_in_progress", "event_id": "day01_wrong_console_parent"},
			{"cash_delta": 15, "reputation_delta": 2, "manager_trust_delta": 2},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:488",
				"tests/gut/test_store_session_day_one_critical_path.gd:493",
				"tests/gut/test_store_session_day_one_critical_path.gd:496",
				"tests/gut/test_store_session_day_one_critical_path.gd:511",
				"tests/gut/test_store_session_day_one_critical_path.gd:512",
			]
		),
		_beat(
			9,
			"stocked_shelf_stat_change",
			"Stocked shelf stat change",
			"09_stocked_shelf_stat_change.png",
			"Complete the post-customer backroom pickup and shelf restock.",
			"end_day",
			"close_day",
			"Close day",
			{
				"stats": {"Customers": "1", "Sales": "1", "Shelf": "4 / 5", "Stockroom": "1"}
			},
			{"shelf": 4, "backroom": 1, "carrying_stock": false},
			{"state": "customer_served_and_shelf_stocked", "event_id": "day01_wrong_console_parent"},
			{"cash_delta": 15, "reputation_delta": 2, "manager_trust_delta": 2},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:516",
				"tests/gut/test_store_session_day_one_critical_path.gd:525",
				"tests/gut/test_store_session_day_one_critical_path.gd:528",
				"tests/gut/test_store_session_day_one_critical_path.gd:552",
			]
		),
		_beat(
			10,
			"close_day_prompt",
			"Close day prompt",
			"10_close_day_prompt.png",
			"Walk to the close-day trigger after the final shelf/stat update.",
			"end_day",
			"close_day",
			"Close day",
			{
				"stats": {"Customers": "1", "Sales": "1", "Shelf": "4 / 5", "Stockroom": "1"}
			},
			{"shelf": 4, "backroom": 1, "carrying_stock": false},
			{"state": "close_day_enabled", "event_id": "day01_wrong_console_parent"},
			{"cash_delta": 15, "reputation_delta": 2, "manager_trust_delta": 2},
			{},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:552",
				"tests/gut/test_store_session_day_one_critical_path.gd:553",
				"tests/gut/test_store_session_day_one_critical_path.gd:557",
				"tests/gut/test_store_session_day_one_critical_path.gd:562",
			]
		),
		_beat(
			11,
			"close_day_summary",
			"Close day summary",
			"11_close_day_summary.png",
			"Confirm close day and capture the summary panel.",
			"summary",
			"summary",
			"Summary visible",
			{
				"modal": "day_summary",
				"stats": {"Customers": "1", "Sales": "1", "Shelf": "4 / 5", "Stockroom": "1"}
			},
			{"shelf": 4, "backroom": 1, "carrying_stock": false},
			{"state": "summary_visible", "event_id": "day01_wrong_console_parent"},
			{"cash_delta": 15, "reputation_delta": 2, "manager_trust_delta": 2},
			{
				"starting_cash": 500,
				"sales": 15,
				"rent": -50,
				"profit": -35,
				"ending_cash": 515,
				"customers_helped": 1,
				"items_stocked": 3,
				"sales_completed": 1,
				"shelf_inventory": 3,
				"backroom_inventory": 1,
			},
			[
				"tests/gut/test_store_session_day_one_critical_path.gd:557",
				"tests/gut/test_store_session_day_one_critical_path.gd:571",
				"tests/gut/test_store_session_day_one_critical_path.gd:574",
				"tests/gut/test_store_session_day_one_critical_path.gd:585",
				"tests/gut/test_store_session_day_one_critical_path.gd:586",
				"tests/gut/test_store_session_day_one_critical_path.gd:587",
				"tests/gut/test_store_session_day_one_critical_path.gd:596",
				"tests/gut/test_store_session_day_one_critical_path.gd:618",
				"tests/gut/test_store_session_day_one_critical_path.gd:636",
				"tests/gut/test_store_session_day_one_critical_path.gd:645",
			]
		),
	]
	return _with_next_expected_beats(beats)

## Returns a manifest payload without touching the filesystem.
static func build_manifest(
	dir_path: String = ARTIFACT_DIR,
	run_id: String = "",
	capture_results: Dictionary = {}
) -> Dictionary:
	var resolved_run_id: String = run_id
	if resolved_run_id.is_empty():
		resolved_run_id = "%s_day1_loop" % _timestamp()
	resolved_run_id = StoreVisualSweepScript.sanitize_slug(resolved_run_id)
	var run_dir: String = "%s/%s" % [dir_path, resolved_run_id]
	return {
		"schema_version": SCHEMA_VERSION,
		"artifact_type": ARTIFACT_TYPE,
		"route_id": "retro_games_day_one_loop",
		"run_id": resolved_run_id,
		"artifact_dir": ProjectSettings.globalize_path(run_dir),
		"capture_dir": ProjectSettings.globalize_path("%s/%s" % [run_dir, CAPTURE_DIR_NAME]),
		"snapshot_dir": ProjectSettings.globalize_path("%s/%s" % [run_dir, SNAPSHOT_DIR_NAME]),
		"manual_review_path": ProjectSettings.globalize_path(
			"%s/%s" % [run_dir, MANUAL_REVIEW_FILENAME]
		),
		"capture_helper": {
			"script": "res://game/scripts/store_session/store_screenshot_helper.gd",
			"method": "capture_current_viewport",
			"argument_field": "capture_beat_name",
		},
		"code_to_screen_contract": StoreProofContractScript.contract_metadata(),
		"canonical_customer_choice": {
			"event_id": "day01_wrong_console_parent",
			"choice_id": "clean_exchange",
			"expected_outcome": {
				"cash_delta": 15,
				"reputation_delta": 2,
				"manager_trust_delta": 2,
				"customers_helped_delta": 1,
				"sales_delta": 1,
				"customer_exits": true,
				"summary_must_include_customer": true
			}
		},
		"required_review_beats": REQUIRED_REVIEW_BEATS.duplicate(),
		"beats": _beats_with_capture_results(route_beats(), capture_results),
		"manual_review_template": _manual_review_template(route_beats())
	}

## Writes the route manifest and manual review checklist into a run directory.
static func write_route_manifest(
	dir_path: String = ARTIFACT_DIR,
	run_id: String = "",
	capture_results: Dictionary = {}
) -> Dictionary:
	var manifest: Dictionary = build_manifest(dir_path, run_id, capture_results)
	var run_dir: String = _run_dir(dir_path, str(manifest.get("run_id", "")))
	for path: String in [
		run_dir,
		"%s/%s" % [run_dir, CAPTURE_DIR_NAME],
		"%s/%s" % [run_dir, SNAPSHOT_DIR_NAME],
	]:
		var dir_result: Dictionary = StoreVisualSweepScript.ensure_artifact_dir(path)
		if not bool(dir_result.get("ok", false)):
			return dir_result

	var manifest_path: String = "%s/%s" % [run_dir, MANIFEST_FILENAME]
	var manifest_result: Dictionary = AutomationArtifactsScript.write_json(
		manifest_path,
		manifest,
		"Cannot write route manifest"
	)
	if not bool(manifest_result.get("ok", false)):
		return manifest_result

	var review_result: Dictionary = _write_manual_review(run_dir, manifest)
	if not bool(review_result.get("ok", false)):
		return review_result

	return {
		"ok": true,
		"path": manifest_path,
		"absolute_path": ProjectSettings.globalize_path(manifest_path),
		"manual_review_path": review_result.get("path", ""),
		"run_id": manifest.get("run_id", ""),
	}

static func _beat(
	index: int,
	beat_name: String,
	label: String,
	filename: String,
	player_action: String,
	stage: String,
	objective_id: String,
	active_prompt: String,
	hud_right_panel: Dictionary,
	counts: Dictionary,
	customer_state: Dictionary,
	inventory_cash_deltas: Dictionary,
	summary_values: Dictionary,
	automated_assertions: Array[String]
) -> Dictionary:
	var beat: Dictionary = {
		"index": index,
		"beat_name": beat_name,
		"capture_beat_name": beat_name,
		"capture_helper_call": "capture_current_viewport(\"%s\")" % beat_name,
		"label": label,
		"filename": filename,
		"snapshot_filename": filename.get_basename() + ".json",
		"player_action_before_capture": player_action,
		"expected_objective": objective_id,
		"expected_stage": stage,
		"active_prompt": active_prompt,
		"next_expected_beat": "",
		"hud_right_panel": hud_right_panel,
		"shelf_backroom_counts": counts,
		"customer_state": customer_state,
		"inventory_cash_deltas": inventory_cash_deltas,
		"summary_values": summary_values,
		"automated_route_assertions": automated_assertions,
	}
	beat["code_to_screen_proof"] = StoreProofContractScript.proof_from_route_beat(beat)
	return beat


static func _with_next_expected_beats(beats: Array[Dictionary]) -> Array[Dictionary]:
	for index: int in range(beats.size()):
		var next_beat_name: String = "route_complete"
		if index + 1 < beats.size():
			next_beat_name = str(beats[index + 1].get("beat_name", ""))
		beats[index]["next_expected_beat"] = next_beat_name
		beats[index]["code_to_screen_proof"] = StoreProofContractScript.proof_from_route_beat(
			beats[index]
		)
	return beats

static func _beats_with_capture_results(
	beats: Array[Dictionary],
	capture_results: Dictionary
) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for beat: Dictionary in beats:
		var copy: Dictionary = beat.duplicate(true)
		var beat_name: String = str(copy.get("beat_name", ""))
		copy["capture_result"] = capture_results.get(beat_name, {})
		out.append(copy)
	return out

static func _manual_review_template(beats: Array[Dictionary]) -> Dictionary:
	var verdicts: Array[Dictionary] = []
	for beat: Dictionary in beats:
		verdicts.append({
			"beat_name": str(beat.get("beat_name", "")),
			"capture_beat_name": str(beat.get("capture_beat_name", "")),
			"status": "pending",
			"screenshot_matches_state": false,
			"active_prompt": str(beat.get("active_prompt", "")),
			"next_expected_beat": str(beat.get("next_expected_beat", "")),
			"automated_assertion_checked": false,
			"notes": "",
		})
	return {
		"verdicts": verdicts,
	}

static func _write_manual_review(run_dir: String, manifest: Dictionary) -> Dictionary:
	var path: String = "%s/%s" % [run_dir, MANUAL_REVIEW_FILENAME]
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _error("Cannot write manual review checklist: %s" % path)
	var lines: PackedStringArray = PackedStringArray()
	lines.append("# Manual Day 1 Route Capture")
	lines.append("")
	lines.append("Run id: %s" % str(manifest.get("run_id", "")))
	lines.append("")
	for beat_variant: Variant in manifest.get("beats", []):
		var beat: Dictionary = beat_variant as Dictionary
		lines.append(
			"- [ ] %02d %s -> `%s`"
			% [
				int(beat.get("index", 0)),
				str(beat.get("label", "")),
				str(beat.get("filename", "")),
			]
		)
		lines.append("  - Capture: `%s`" % str(beat.get("capture_helper_call", "")))
		lines.append("  - Expected stage: `%s`" % str(beat.get("expected_stage", "")))
		lines.append("  - Expected prompt: `%s`" % str(beat.get("active_prompt", "")))
		lines.append("  - Next expected beat: `%s`" % str(beat.get("next_expected_beat", "")))
		for field: String in StoreProofContractScript.REQUIRED_FIELDS:
			var proof: Dictionary = beat.get("code_to_screen_proof", {}) as Dictionary
			lines.append(
				"  - %s: %s"
				% [field.capitalize().replace("_", " "), str(proof.get(field, ""))]
			)
	file.store_string("\n".join(lines))
	file.close()
	return {
		"ok": true,
		"path": path,
		"absolute_path": ProjectSettings.globalize_path(path),
	}

static func _run_dir(dir_path: String, run_id: String) -> String:
	return "%s/%s" % [dir_path, StoreVisualSweepScript.sanitize_slug(run_id)]

static func _timestamp() -> String:
	var d: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d%02d%02d_%02d%02d%02d" % [int(d.get("year", 0)), int(d.get("month", 0)),
		int(d.get("day", 0)), int(d.get("hour", 0)), int(d.get("minute", 0)),
		int(d.get("second", 0))]

static func _error(message: String) -> Dictionary:
	return {"ok": false, "error": message}
