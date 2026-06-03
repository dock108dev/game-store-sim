## Fixed first-person roam route for visual/HUD validation.
class_name FPRoamValidationManifest
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)

const SUITE: String = "fp_roam_validation"
const CAPTURE_RESOLUTION: Vector2i = Vector2i(1280, 720)
const CAPTURE_CAMERA_FOV: float = 78.0
const CAPTURE_RANDOM_SEED: int = 2041
const CONTROL_RUN: String = "control"
const CANDIDATE_RUN: String = "candidate"
const REVIEW_MANIFEST_FILENAME: String = "review_manifest.json"


static func normalize_run_label(raw: String) -> String:
	var normalized: String = raw.strip_edges().to_lower().replace("-", "_")
	if normalized == CANDIDATE_RUN:
		return CANDIDATE_RUN
	return CONTROL_RUN


static func run_root_dir(run_label: String) -> String:
	return AutomationArtifactsScript.artifact_path(
		"fp_roam_validation/%s" % normalize_run_label(run_label)
	)


static func current_dir(run_label: String) -> String:
	return "%s/current" % run_root_dir(run_label)


static func manifest_path(run_label: String) -> String:
	return "%s/%s" % [run_root_dir(run_label), REVIEW_MANIFEST_FILENAME]


static func side_by_side_dir() -> String:
	return AutomationArtifactsScript.artifact_path("fp_roam_validation/compare")


static func review_checklist() -> Array[String]:
	return [
		"ObjectiveRail hidden in FP mode",
		"single FP objective sentence visible",
		"interaction prompt appears only on focused stops",
		"cash and time remain compact",
		"right status panel does not hide the route target",
		"checkout, starter display, stockroom, and exit are readable",
		"no giant blank panel dominates the stop",
		"no camera clipping, falling, or untextured void",
	]


static func rows() -> Array[Dictionary]:
	return [
		_row(
			1,
			"spawn_first_read",
			"01_spawn_first_read.png",
			Vector3(-0.55, 1.70, 9.0),
			"StoreSessionManager",
			"Talk to Manager",
			"First read from player spawn: checkout, manager, shelf, and store identity.",
			["first_view_identity", "route_readability"],
			[
				"StoreSessionManager",
				"checkout_counter",
				"StoreSessionRestockShelf",
				"ExpandableStoreShell/StoreIdentitySignCanopy",
				"ExpandableStoreShell/StarterFloor",
			],
			{"max_near_white_ratio": 0.18}
		),
		_row(
			2,
			"checkout_counter_focus",
			"02_checkout_counter_focus.png",
			Vector3(2.35, 1.56, 6.10),
			"ExpandableStoreShell/CheckoutRegisterScreen",
			"Talk to Manager",
			"Counter stop: manager/register should read without a bottom task wall.",
			["checkout_and_transaction_work", "compact_prompt_ownership"],
			[
				"StoreSessionManager",
				"checkout_counter",
				"ExpandableStoreShell/CheckoutRegisterScreen",
				"StoreSessionDayEndTrigger",
			],
			{"max_near_white_ratio": 0.17}
		),
		_row(
			3,
			"starter_display_focus",
			"03_starter_display_focus.png",
			Vector3(-3.90, 1.55, 1.65),
			"StoreSessionRestockShelf/EmptyOverlay",
			"Stock Starter Display",
			"Display stop: starter table should be findable and not buried by HUD.",
			["shelf_economics_and_product_readability"],
			[
				"StoreSessionRestockShelf",
				"StoreSessionRestockShelf/ShelfBoard",
				"StoreSessionRestockShelf/EmptyOverlay",
				"ExpandableStoreShell/StarterUsedShelfBacker",
			],
			{"max_near_white_ratio": 0.18}
		),
		_row(
			4,
			"stockroom_threshold",
			"04_stockroom_threshold.png",
			Vector3(2.20, 1.58, -3.95),
			"ExpandableStoreShell/StockroomFloorTape",
			"Inspect Starter Stock Box",
			"Threshold stop: route into stockroom should read as intentional space.",
			["stockroom_route", "store_construction_and_expansion"],
			[
				"StoreSessionBackroomPickup",
				"ExpandableStoreShell/StockroomPartition",
				"ExpandableStoreShell/StockroomFloorTape",
				"ExpandableStoreShell/StockroomUtilityPractical",
				"ExpandableStoreShell/StockroomPickupWarmPractical",
			],
			{"max_near_white_ratio": 0.16}
		),
		_row(
			5,
			"stockroom_work_area",
			"05_stockroom_work_area.png",
			Vector3(3.15, 1.58, -6.05),
			"StoreSessionBackroomPickup/StockBoxLabel",
			"Inspect Starter Stock Box",
			"Interior stockroom stop: stock box and work area should read clearly.",
			["stockroom_work_surface", "back_room_inventory"],
			[
				"StoreSessionBackroomPickup",
				"StoreSessionBackroomPickup/StockBox",
				"StoreSessionBackroomPickup/StockBoxLabel",
				"ExpandableStoreShell/StockroomUtilityPractical",
				"ExpandableStoreShell/StockroomPickupWarmPractical",
			],
			{
				"max_near_white_ratio": 0.12,
				"review_note": "Stockroom card and stock box must read without a wall-sized text block.",
			}
		),
		_row(
			6,
			"exit_threshold_return",
			"06_exit_threshold_return.png",
			Vector3(-2.35, 1.62, 8.95),
			"ExpandableStoreShell/EntryThreshold",
			"Exit to Mall",
			"Exit stop: threshold should read without becoming the active store target.",
			["storefront_threshold", "mall_return_route"],
			[
				"ExpandableStoreShell/EntryThreshold",
				"ExpandableStoreShell/ThresholdFloorInlay",
				"ExpandableStoreShell/WelcomeMatInset",
				"ExpandableStoreShell/StorefrontCanopyLabel",
			],
			{"max_near_white_ratio": 0.18}
		),
		_row(
			7,
			"wide_back_of_store",
			"07_wide_back_of_store.png",
			Vector3(-5.75, 1.74, -1.35),
			"StoreSessionManager",
			"",
			"Wide sanity stop: checks blank partitions, lighting balance, and sightlines.",
			["whole_store_read", "blank_wall_dominance"],
			[
				"StoreSessionManager",
				"StoreSessionRestockShelf",
				"ExpandableStoreShell/StockroomPartition",
				"ExpandableStoreShell/StarterFloor",
			],
			{"max_near_white_ratio": 0.18}
		),
		_row(
			8,
			"storefront_identity_close",
			"08_storefront_identity_close.png",
			Vector3(-1.15, 1.56, 8.55),
			"ExpandableStoreShell/StorefrontCanopyLabel",
			"Exit to Mall",
			"Storefront close read: identity should feel authored, not like a blank exit.",
			["storefront_identity", "mall_return_route"],
			[
				"ExpandableStoreShell/StorefrontCanopyLabel",
				"ExpandableStoreShell/FrontGlassLeftLite",
				"ExpandableStoreShell/WindowDisplayCartridgeStack",
				"ExpandableStoreShell/Phase3EntryWindowGameStack00",
				"ExpandableStoreShell/Phase4MallPlanter00",
				"ExpandableStoreShell/Phase4MallBench00",
				"ExpandableStoreShell/Phase4WindowStaffPicksDecal",
			],
			{"max_near_white_ratio": 0.18},
				{
					"required_phase4_roles": ["planter", "bench", "window_business_decal"],
					"required_phase4_state_values": [
						"mall_context:threshold_dressing",
						"storefront_identity:staff_picks",
					],
				}
		),
		_row(
			9,
			"shelf_wall_density_close",
			"09_shelf_wall_density_close.png",
			Vector3(-3.80, 1.50, 0.10),
			"ExpandableStoreShell/Phase3ShelfFaceout00",
			"Stock Starter Display",
			"Shelf-wall close read: product density should read without text spam.",
			["shelf_economics_and_product_readability"],
			[
				"ExpandableStoreShell/StarterUsedShelfBacker",
				"ExpandableStoreShell/StarterUsedShelfRail00",
				"ExpandableStoreShell/Phase3ShelfSpineRun00",
				"ExpandableStoreShell/Phase3ShelfFaceout00",
				"ExpandableStoreShell/Phase4ShelfCartridgeRun00",
				"ExpandableStoreShell/Phase4ShelfConsoleBox00",
				"ExpandableStoreShell/Phase4ShelfControllerLoose00",
			],
			{"max_near_white_ratio": 0.18},
			{
					"required_phase4_roles": [
						"shelf_product_variety",
						"high_value_shelf_tell",
						"accessory_variety",
						"price_rail_readability",
					],
					"required_phase4_state_values": [
						"shelf_density:stocked",
						"high_value_shelf_tell:boxed_console",
						"accessory_density:loose_controller",
						"price_rail:readable",
					],
				}
			),
		_row(
			10,
			"checkout_detail_density",
			"10_checkout_detail_density.png",
			Vector3(3.28, 1.44, 6.85),
			"ExpandableStoreShell/Phase3CheckoutImpulseCard00",
			"Talk to Manager",
			"Checkout close read: register detail should feel stocked but not obstructive.",
			["checkout_and_transaction_work"],
			[
				"ExpandableStoreShell/CheckoutRegisterScreen",
				"ExpandableStoreShell/CheckoutCardReader",
				"ExpandableStoreShell/Phase3CheckoutImpulseCard00",
				"ExpandableStoreShell/Phase3CheckoutCounterSleeve00",
				"ExpandableStoreShell/Phase4CheckoutPendingTray",
				"ExpandableStoreShell/Phase4CheckoutReceiptState",
				"ExpandableStoreShell/Phase4CheckoutNoSaleStamp",
				"ExpandableStoreShell/Phase4QueueHeldGameCase00",
			],
			{"max_near_white_ratio": 0.17},
			{
				"required_phase4_roles": [
					"checkout_pending_physical_state",
						"checkout_settled_physical_state",
						"checkout_no_sale_physical_state",
						"customer_held_item",
						"queue_intent_marker",
					],
					"required_phase4_state_values": [
						"checkout_transaction_state:pending",
						"checkout_transaction_state:settled",
						"checkout_transaction_state:no_sale",
						"customer_queue_state:holding_item",
						"customer_queue_state:ready_to_checkout",
					],
				}
			),
		_row(
			11,
			"starter_table_density_close",
			"11_starter_table_density_close.png",
			Vector3(-3.85, 1.44, 1.85),
			"ExpandableStoreShell/Phase3StarterTableFaceout00",
			"Stock Starter Display",
			"Display-table close read: starter table should feel merchandised.",
			["shelf_economics_and_product_readability"],
			[
				"StoreSessionRestockShelf",
				"ExpandableStoreShell/StarterDisplayTableTray",
				"ExpandableStoreShell/Phase3StarterTableFaceout00",
				"ExpandableStoreShell/Phase3StarterTableSleeveStack00",
				"ExpandableStoreShell/Phase4DisplayLooseCart00",
				"ExpandableStoreShell/Phase4DisplayControllerLoose00",
			],
			{"max_near_white_ratio": 0.18},
			{
					"required_phase4_roles": [
						"starter_table_product_variety",
						"starter_table_accessory_variety",
					],
					"required_phase4_state_values": [
						"starter_table_density:loose_cart",
						"starter_table_density:loose_controller",
					],
				}
			),
	]


static func _row(
	index: int,
	name: String,
	filename: String,
	camera: Vector3,
	focus: String,
	prompt_text: String,
	review_goal: String,
	inspiration_tags: Array[String],
	anchors: Array[String],
	image_limits: Dictionary = {},
	density_requirements: Dictionary = {}
) -> Dictionary:
	return {
		"index": index,
		"name": name,
		"filename": filename,
		"camera": camera,
		"focus": focus,
		"prompt_text": prompt_text,
		"objective_text": "Talk to the manager at checkout for opening instructions.",
		"review_goal": review_goal,
		"inspiration_tags": inspiration_tags,
		"anchors": anchors,
		"image_limits": image_limits,
		"density_requirements": density_requirements,
		"visual_scope_mode": StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
		"checklist": review_checklist(),
	}
