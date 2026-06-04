# gdlint:disable=max-file-lines
## Shared manifest and PNG writer for the store_session store visual review sweep.
## See cleanup-report.md "Files still >500 LOC": capture assembly needs extraction.
class_name StoreVisualSweep
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)
const StoreVisualActionContextScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_action_context.gd"
)
const StoreVisualFullStoreContextScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_full_store_context.gd"
)
const WorkSurfaceValidationContractScript: GDScript = preload(
	"res://game/scripts/store_session/work_surface_validation_contract.gd"
)
const InspirationCloseoutContractScript: GDScript = preload(
	"res://game/scripts/store_session/inspiration_closeout_contract.gd"
)
const StoreVisualOverhaulRowsScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_overhaul_rows.gd"
)
const ARTIFACT_SUITE: String = "retro_games_day_one"
const OVERHAUL_ARTIFACT_SUITE: String = "retro_games_overhaul_acceptance"
const ARTIFACT_DIR: String = "screenshots/visual_sweep/retro_games_day_one"
const ACCEPTANCE_ARTIFACT_DIR: String = "visual_sweep/retro_games_day_one"
const ACCEPTANCE_CURRENT_DIR: String = "visual_sweep/retro_games_day_one/current"
const ACCEPTANCE_DIFF_DIR: String = "visual_sweep/retro_games_day_one/diff"
const OVERHAUL_ACCEPTANCE_ARTIFACT_DIR: String = "visual_sweep/retro_games_overhaul_acceptance"
const OVERHAUL_ACCEPTANCE_CURRENT_DIR: String = (
	"visual_sweep/retro_games_overhaul_acceptance/current"
)
const OVERHAUL_ACCEPTANCE_DIFF_DIR: String = "visual_sweep/retro_games_overhaul_acceptance/diff"
const REVIEW_MANIFEST_DIR: String = "reports/visual_sweep/retro_games_day_one"
const REVIEW_MANIFEST_FILENAME: String = "review_manifest.json"
const VIEWPORT_MARGIN_PX: float = 8.0
const CAPTURE_RESOLUTION: Vector2i = Vector2i(1280, 720)
const CAPTURE_CAMERA_FOV: float = 70.0
const CAPTURE_RANDOM_SEED: int = 1801
const FIRST_TEN_SECONDS_TARGET_MODE: String = "first_ten_seconds"
const OVERHAUL_TARGET_MODE: String = "overhaul_acceptance"
const ACCEPTANCE_TARGET: String = "first_ten_seconds_route_views"
const OVERHAUL_ACCEPTANCE_TARGET: String = "overhaul_acceptance_views"
const HUD_CONTEXT_LABEL: String = "First Day — 8:00 AM"
const _MAX_SLUG_LENGTH: int = 64
const REQUIRED_ACTION_MOMENTS: Array[String] = (
	StoreVisualActionContextScript.REQUIRED_ACTION_MOMENTS
)


## Returns the design-coherence checks applied to each route acceptance row.
static func route_design_checks() -> Array[String]:
	return [
		"material-family consistency",
		"readable scale",
		"no blank-wall dominance",
		"no oversized-door dominance",
		"no disconnected-prop dominance",
		"storefront threshold identity",
		"threshold does not compete with route target",
	]


## Returns the spawn screenshot checklist preserved in manifests for review.
static func spawn_acceptance_review() -> Dictionary:
	return {
		"source_checklist": "BRAINDUMP spawn screenshot checklist",
		"evidence_artifact": "01_spawn_first_look.png",
		"capture_workflow": "scripts/run_store_visual_sweep.sh",
		"capture_policy": "display-backed 1280x720 gl_compatibility",
		"must_show": [
			"enclosed stockroom",
			"readable checkout",
			"manager talk target",
			"queue inside store",
			"starter display visible",
			"readable storefront threshold identity",
			"open sales floor",
			"no unintended exterior objects",
		],
		"must_read_without_ui_labels": [
			"fresh player can identify the first action",
			"fresh player can identify the manager target",
			"fresh player can identify the next store destinations",
			"fresh player can tell they are inside a specific storefront",
			"fresh player can distinguish the mall threshold from the sales floor",
		],
		"route_metadata_fields": [
			"active_prompt",
			"next_destination",
			"local_action",
			"next_expected_beat",
			"primary_work_surface_target",
		],
		"reject_if": [
			"required spawn-readability anchor is missing",
			"required spawn-readability anchor is hidden by ancestors",
			"required spawn-readability anchor is outside its physical zone",
			"required spawn-readability anchor overlaps a forbidden zone",
			"required spawn-readability anchor is outside the first-ten-seconds acceptance target",
			"the image reads as an empty room",
			"the checkout/register is not findable from the screenshot",
			"the route target is hidden by props or UI",
			"storefront identity is missing from the spawn first-look composition",
			"storefront identity reads as the active route target instead of background context",
			"mall-side threshold details imply a reachable exterior route",
			"blank wall or door shape dominates the composition",
			"decorative props overpower the action surface",
			"HUD or prompt is missing, clipped, or unreadable",
			"capture is headless placeholder evidence",
		],
	}


## Returns physical anchors required for the spawn first-look evidence row.
static func spawn_readability_anchor_contract() -> Array[Dictionary]:
	return [
		_spawn_anchor(
			"readable_checkout",
			"checkout_counter",
			"checkout",
			["entrance", "stockroom", "starter_display"]
		),
		_spawn_anchor(
			"manager_talk_target",
			"StoreSessionManager",
			"checkout",
			["entrance", "stockroom", "starter_display"]
		),
		_spawn_anchor(
			"starter_display_visible",
			"StoreSessionRestockShelf",
			"starter_display",
			["checkout", "queue_lane", "stockroom", "entrance"]
		),
		_spawn_anchor(
			"enclosed_stockroom",
			"ExpandableStoreShell/StockroomDoorStaffCard",
			"stockroom",
			["checkout", "queue_lane", "starter_display", "entrance"]
		),
		_spawn_anchor(
			"queue_inside_store",
			"FrontLaneQueue",
			"queue_lane",
			["entrance", "stockroom", "starter_display"]
		),
		_spawn_anchor("store_bounds_context", "ExpandableStoreShell/StarterFloor", "store_bounds", []),
		_spawn_anchor("entrance_context", "PlayerEntrySpawn", "entrance", ["checkout", "stockroom"]),
		_spawn_anchor(
			"route_sightline_context",
			"ExpandableStoreShell/CheckoutQueueRopeFront",
			"spawn_sightline_core",
			["stockroom", "starter_display", "entrance"]
		),
	]


## Returns a validation result for the active action context bound to a sweep row.
static func validate_action_context(row: Dictionary) -> Dictionary:
	return StoreVisualActionContextScript.validate_row(row)


## Returns the normal store_session review beats. These are the first-ten-seconds
## acceptance target for this phase; broader whole-room checks stay secondary.
static func rows() -> Array[Dictionary]:
	return first_ten_seconds_rows()


## Returns the row set for the requested visual acceptance target mode.
static func rows_for_target(target_mode: String) -> Array[Dictionary]:
	if target_mode == OVERHAUL_TARGET_MODE:
		return overhaul_acceptance_rows()
	return first_ten_seconds_rows()


## Returns stateful, non-first-ten-seconds review captures for overhaul acceptance.
static func overhaul_acceptance_rows() -> Array[Dictionary]:
	return StoreVisualOverhaulRowsScript.rows(
		OVERHAUL_ACCEPTANCE_TARGET,
		HUD_CONTEXT_LABEL,
		CAPTURE_CAMERA_FOV,
		route_design_checks()
	)


## Returns phase-specific first-run captures for the route views players see first.
static func first_ten_seconds_rows() -> Array[Dictionary]:
	return [
		{
			"index": 1,
			"name": "spawn_first_look",
			"label": "Spawn first look",
			"filename": "01_spawn_first_look.png",
			"camera": Vector3(-0.55, 1.70, 9.0),
			"camera_rotation_degrees": Vector3(0.0, -25.0, 0.0),
			"camera_fov": CAPTURE_CAMERA_FOV,
			"focus": "StoreSessionManager",
			"anchors":
			[
				"checkout_counter",
				"ExpandableStoreShell/CheckoutRegisterScreen",
				"ExpandableStoreShell/StarterSignLabel",
				"ExpandableStoreShell/StoreIdentityWallPanel",
				"ExpandableStoreShell/StoreIdentitySignCanopy",
				"ExpandableStoreShell/StorefrontCanopyLabel",
				"ExpandableStoreShell/FrontGlassLeftLite",
				"ExpandableStoreShell/FrontGlassRightLite",
				"ExpandableStoreShell/MallSideTransomGlow",
				"ExpandableStoreShell/StoreHoursPlaque",
				"ExpandableStoreShell/FrontWindowDecalLeft",
				"ExpandableStoreShell/StarterBackWall",
				"ExpandableStoreShell/FrontDoorHorizontalPushBar",
				"StoreSessionRestockShelf",
				"ExpandableStoreShell/CheckoutQueueRopeFront",
				"ExpandableStoreShell/StarterDisplayShelfEdgeCard",
				"ExpandableStoreShell/StockroomDoorDirectionPlaque",
				"ExpandableStoreShell/StockroomDoorStaffCard",
				"ExpandableStoreShell/StockroomCoolDoorRevealHeader",
				"ExpandableStoreShell/StarterFloor",
				"ExpandableStoreShell/EntryThreshold",
				"ExpandableStoreShell/ThresholdFloorInlay",
				"ExpandableStoreShell/WelcomeMatInset",
				"ExpandableStoreShell/WindowDisplayCartridgeStack",
				"FrontLaneQueue",
				"PlayerEntrySpawn",
				"StoreSessionManager",
			],
			"route_anchor": "ExpandableStoreShell/CheckoutRegisterScreen",
			"active_route_stage": "spawn_orientation",
			"active_prompt": "Talk to Manager",
			"next_expected_beat": "checkout_manager_counter",
			"next_destination": "manager and checkout register",
			"local_action": "take in the store identity and walk to the counter",
			"route_sequence_index": 0,
			"primary_work_surface_target": "checkout_counter",
			"action_context": _action_context(
				"checkout",
				"StoreSessionManager/Interactable",
				"Talk to Manager",
				"walk to the counter and talk to the manager",
				"manager and checkout register",
				[
					_candidate("StoreSessionManager/Interactable", "active", ""),
					_candidate(
						"StoreSessionDayEndTrigger/Interactable",
						"disabled",
						"Register is context until the manager beat resolves."
					),
				],
				"spawn-to-counter approach"
			),
			"work_surface_review": {
				"surface_role": "route_preview",
				"primary_action_surface": "checkout_counter",
				"dominance_required": true,
				"supporting_props_should_stay_quiet": true,
			},
			"inspiration_closeout": _inspiration_closeout(
				[
					"storefront_and_mall_identity",
					"checkout_and_transaction_work",
					"customers_and_queue",
					"shelf_economics_and_product_readability",
				],
				(
					"Original Retro Rewind entry, checkout, queue, manager, and starter display "
					+ "composition built from Mallcore props and labels."
				),
				"01_spawn_first_look.png validates first-view identity and route readability."
			),
			"spawn_acceptance_review": spawn_acceptance_review(),
			"spawn_readability_anchors": spawn_readability_anchor_contract(),
			"design_checks": route_design_checks(),
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 2,
			"name": "checkout_manager_counter",
			"label": "Checkout and manager counter",
			"filename": "02_checkout_manager_counter.png",
			"camera": Vector3(2.35, 1.52, 6.10),
			"focus": "ExpandableStoreShell/CheckoutRegisterScreen",
			"anchors":
			[
				"checkout_counter",
				"StoreSessionManager",
				"StoreSessionDayEndTrigger",
				"ExpandableStoreShell/CheckoutRegisterScreen",
				"ExpandableStoreShell/CheckoutRegisterPractical",
				"ExpandableStoreShell/FrontDoorPushPlate",
			],
			"route_anchor": "StoreSessionManager",
			"active_route_stage": "training_talk_manager",
			"active_prompt": "Talk to Manager",
			"next_expected_beat": "shelf_wall_product_focus",
			"next_destination": "checkout counter",
			"local_action": "talk to the manager/register area",
			"route_sequence_index": 1,
			"primary_work_surface_target": "checkout_counter",
			"action_context": _action_context(
				"checkout",
				"StoreSessionManager/Interactable",
				"Talk to Manager",
				"talk to the manager/register area",
				"checkout counter",
				[
					_candidate("StoreSessionManager/Interactable", "active", ""),
					_candidate(
						"StoreSessionDayEndTrigger/Interactable",
						"disabled",
						"Register and close-day hotspot must not compete with the manager prompt."
					),
					_candidate(
						"StoreSessionBackroomPickup/Interactable",
						"disabled",
						"Backroom pickup comes after the checkout beat."
					),
				],
				"customer-side counter approach"
			),
			"work_surface_review": {
				"surface_role": "service_counter_hierarchy",
				"primary_action_surface": "checkout_counter",
				"dominance_required": true,
				"supporting_props_should_stay_quiet": true,
			},
			"inspiration_closeout": _inspiration_closeout(
				["checkout_and_transaction_work", "customers_and_queue"],
				(
					"Original manager, register, close-day hotspot, and counter props stage a "
					+ "Mallcore service-counter beat without copied terminal UI."
				),
				"02_checkout_manager_counter.png validates counter hierarchy and prompt ownership."
			),
			"design_checks": route_design_checks(),
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
			"camera": Vector3(-3.90, 1.55, 1.65),
			"focus": "StoreSessionRestockShelf/EmptyOverlay",
			"anchors":
			[
				"StoreSessionRestockShelf",
				"StoreSessionRestockShelf/ShelfBoard",
				"StoreSessionRestockShelf/EmptyOverlay",
				"ExpandableStoreShell/StarterUsedShelfBacker",
			],
			"route_anchor": "StoreSessionRestockShelf",
			"active_route_stage": "training_stock_shelf",
			"active_prompt": "Stock Starter Display",
			"next_expected_beat": "before_customer",
			"next_destination": "starter display table",
			"local_action": "read the empty table target before starter stock appears",
			"route_sequence_index": 3,
			"primary_work_surface_target": "StoreSessionRestockShelf",
			"action_context": _action_context(
				"restock_table",
				"StoreSessionRestockShelf/Interactable",
				"Stock Starter Display",
				"place carried stock on the starter display table",
				"starter display table",
				[
					_candidate("StoreSessionRestockShelf/Interactable", "active", ""),
					_candidate(
						"StoreSessionBackroomPickup/Interactable",
						"disabled",
						"Backroom pickup is complete while the stock is being placed."
					),
					_candidate(
						"StoreSessionDayEndTrigger/Interactable",
						"disabled",
						"Close day unlocks after the product/sale beat."
					),
				],
				"stock-carry approach to table"
			),
			"work_surface_review": {
				"surface_role": "starter_table_hierarchy",
				"primary_action_surface": "StoreSessionRestockShelf",
				"dominance_required": true,
				"supporting_props_should_stay_quiet": true,
			},
			"inspiration_closeout": _inspiration_closeout(
				["shelf_economics_and_product_readability"],
				(
					"Original starter display table, empty overlay, price rail, and used-game "
					+ "fixture language show stock work without real packaging."
				),
				"03_shelf_wall_product_focus.png validates starter display readability."
			),
			"design_checks": route_design_checks(),
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 4,
			"name": "stockroom_looking_in",
			"label": "Stockroom looking in",
			"filename": "04_stockroom_looking_in.png",
			"camera": Vector3(2.20, 1.58, -3.95),
			"focus": "ExpandableStoreShell/StockroomDoorStaffCard",
			"anchors":
			[
				"StoreSessionBackroomPickup",
				"ExpandableStoreShell/StockroomPartition",
				"ExpandableStoreShell/StockroomLeftSideReturn",
				"ExpandableStoreShell/StockroomDoorStaffCard",
				"ExpandableStoreShell/StockroomDoorDirectionPlaque",
				"ExpandableStoreShell/StockroomUtilityPractical",
			],
			"route_anchor": "ExpandableStoreShell/StockroomDoorStaffCard",
			"active_route_stage": "training_back_room_inventory",
			"active_prompt": "Inspect Starter Stock Box",
			"disabled_guidance": _stockroom_pickup_disabled_guidance(),
			"next_expected_beat": "stockroom_work_area_interior",
			"next_destination": "stockroom pickup",
			"local_action": "recognize the open stockroom path from the sales floor",
			"route_sequence_index": 2,
			"primary_work_surface_target": "ExpandableStoreShell/StockroomDoorStaffCard",
			"action_context": _action_context(
				"backroom_pickup",
				"StoreSessionBackroomPickup/Interactable",
				"Inspect Starter Stock Box",
				"walk through the stockroom threshold to the pickup",
				"stockroom pickup",
				[
					_candidate("StoreSessionBackroomPickup/Interactable", "active", ""),
					_candidate(
						"StoreSessionRestockShelf/Interactable",
						"disabled",
						"The display table is visible context, not active before pickup."
					),
					_candidate(
						"StoreSessionDayEndTrigger/Interactable",
						"disabled",
						"Close day must stay quiet until store work is complete."
					),
				],
				"sales-floor to stockroom threshold approach"
			),
			"work_surface_review": {
				"surface_role": "stockroom_entry_hierarchy",
				"primary_action_surface": "ExpandableStoreShell/StockroomDoorStaffCard",
				"dominance_required": true,
				"supporting_props_should_stay_quiet": true,
			},
			"inspiration_closeout": _inspiration_closeout(
				[
					"shelf_economics_and_product_readability",
					"store_construction_and_expansion",
				],
				(
					"Original stockroom threshold, floor tape, partition, and utility props make "
					+ "restock capacity readable as a Mallcore work area."
				),
				"04_stockroom_looking_in.png validates stockroom path and capacity cues."
			),
			"design_checks": route_design_checks(),
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 5,
			"name": "stockroom_work_area_interior",
			"label": "Stockroom work-area interior",
			"filename": "05_stockroom_work_area_interior.png",
			"camera": Vector3(3.15, 1.58, -6.05),
			"focus": "StoreSessionBackroomPickup/StockBoxLabel",
			"anchors":
			[
				"StoreSessionBackroomPickup",
				"StoreSessionBackroomPickup/StockBox",
				"StoreSessionBackroomPickup/StockBoxLabel",
				"ExpandableStoreShell/StockroomLeftSideReturn",
				"ExpandableStoreShell/StockroomUtilityPractical",
			],
			"route_anchor": "ExpandableStoreShell/StockroomDoorStaffCard",
			"active_route_stage": "training_back_room_inventory",
			"active_prompt": "Inspect Starter Stock Box",
			"disabled_guidance": _stockroom_pickup_disabled_guidance(),
			"next_expected_beat": "shelf_wall_product_focus",
			"next_destination": "stockroom pickup",
			"local_action": "confirm the stock box is a usable work area, not a closet",
			"route_sequence_index": 2,
			"primary_work_surface_target": "StoreSessionBackroomPickup",
			"action_context": _action_context(
				"backroom_pickup",
				"StoreSessionBackroomPickup/Interactable",
				"Inspect Starter Stock Box",
				"pick up the stockroom delivery",
				"stockroom pickup",
				[
					_candidate("StoreSessionBackroomPickup/Interactable", "active", ""),
					_candidate(
						"StoreSessionRestockShelf/Interactable",
						"disabled",
						"Restock table is the next destination after pickup."
					),
				],
				"threshold-to-crate approach"
			),
			"work_surface_review": {
				"surface_role": "stockroom_work_area_hierarchy",
				"primary_action_surface": "StoreSessionBackroomPickup",
				"dominance_required": true,
				"supporting_props_should_stay_quiet": true,
			},
			"inspiration_closeout": _inspiration_closeout(
				[
					"shelf_economics_and_product_readability",
					"store_construction_and_expansion",
				],
				(
					"Original stock box, label, partition returns, and utility practicals present "
					+ "stockroom work without copied warehouse or store designs."
				),
				"05_stockroom_work_area_interior.png validates backroom work-surface clarity."
			),
			"design_checks": route_design_checks(),
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 6,
			"name": "product_sale_review",
			"label": "Product and sale review",
			"filename": "06_product_sale_review.png",
			"camera": Vector3(-2.85, 1.58, 3.05),
			"focus": "ReadabilityProps/ProductDisplayRows/DungeonDad64_ShelfA",
			"anchors":
			[
				"StoreSessionRestockShelf",
				"StoreSessionRestockShelf/PriceTagRail",
				"ReadabilityProps/ProductDisplayRows/DungeonDad64_ShelfA",
				"ReadabilityProps/ProductDisplayRows/DungeonDad64_PriceTag",
				"StoreSessionDayOneCustomer",
			],
			"route_anchor": "StoreSessionDayOneCustomer",
			"active_route_stage": "talk_to_customer",
			"active_prompt": "Talk to customer",
			"next_expected_beat": "checkout_close_day",
			"next_destination": "customer and checkout",
			"local_action": "inspect the stocked product read and handle the customer sale",
			"route_sequence_index": 4,
			"primary_work_surface_target": "StoreSessionDayOneCustomer",
			"action_context": _action_context(
				"product_inspection",
				"StoreSessionDayOneCustomer/Interactable",
				"Talk to customer",
				"read the stocked product/sale context and return to the customer",
				"customer and checkout",
				[
					_candidate("StoreSessionDayOneCustomer/Interactable", "active", ""),
					_candidate(
						"StoreSessionRestockShelf/Interactable",
						"disabled",
						"Stocked display is review context during the sale beat."
					),
					_candidate(
						"StoreSessionDayEndTrigger/Interactable",
						"disabled",
						"Close-day hotspot is visible but not active until the sale resolves."
					),
				],
				"display-table to customer approach"
			),
			"work_surface_review": {
				"surface_role": "product_sale_hierarchy",
				"primary_action_surface": "StoreSessionDayOneCustomer",
				"dominance_required": true,
				"supporting_props_should_stay_quiet": true,
			},
			"inspiration_closeout": _inspiration_closeout(
				[
					"shelf_economics_and_product_readability",
					"customers_and_queue",
					"checkout_and_transaction_work",
				],
				(
					"Original fictional product cases, price tags, customer prop staging, and sale "
					+ "route cues communicate value and transaction state."
				),
				"06_product_sale_review.png validates stocked display and customer-sale context."
			),
			"design_checks": route_design_checks(),
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 7,
			"name": "checkout_close_day",
			"label": "Checkout close-day prompt",
			"filename": "07_checkout_close_day.png",
			"camera": Vector3(2.10, 1.55, 5.40),
			"focus": "StoreSessionDayEndTrigger",
			"anchors":
			[
				"checkout_counter",
				"StoreSessionDayEndTrigger",
				"StoreSessionDayEndTrigger/Interactable",
				"ExpandableStoreShell/CheckoutRegisterScreen",
				"ExpandableStoreShell/CheckoutRegisterPractical",
			],
			"route_anchor": "StoreSessionDayEndTrigger",
			"active_route_stage": "end_day",
			"active_prompt": "Close day",
			"next_expected_beat": "front_exit",
			"next_destination": "checkout close-day hotspot",
			"local_action": "close the day at the checkout counter",
			"route_sequence_index": 5,
			"primary_work_surface_target": "StoreSessionDayEndTrigger",
			"action_context": _action_context(
				"close_day",
				"StoreSessionDayEndTrigger/Interactable",
				"Close day",
				"close the day at the checkout counter",
				"checkout close-day hotspot",
				[
					_candidate("StoreSessionDayEndTrigger/Interactable", "active", ""),
					_candidate(
						"StoreSessionDayOneCustomer/Interactable",
						"disabled",
						"Customer/sale interaction has resolved before close."
					),
					_candidate(
						"StoreSessionRestockShelf/Interactable",
						"disabled",
						"Restock table is complete before close."
					),
				],
				"sales-floor return to checkout"
			),
			"work_surface_review": {
				"surface_role": "checkout_close_hierarchy",
				"primary_action_surface": "StoreSessionDayEndTrigger",
				"dominance_required": true,
				"supporting_props_should_stay_quiet": true,
			},
			"inspiration_closeout": _inspiration_closeout(
				["checkout_and_transaction_work", "ui_and_sim_feedback"],
				(
					"Original close-day hotspot, register props, and compact HUD state keep the "
					+ "transaction surface readable without borrowed UI styling."
				),
				"07_checkout_close_day.png validates close-day checkout hierarchy."
			),
			"design_checks": route_design_checks(),
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
		{
			"index": 8,
			"name": "exit_threshold_return_view",
			"label": "Exit threshold return view",
			"filename": "08_exit_threshold_return_view.png",
			"camera": Vector3(1.60, 1.60, 5.50),
			"focus": "ExpandableStoreShell/FrontDoorPushPlate",
			"anchors":
			[
				"ExpandableStoreShell/FrontDoorPushPlate",
				"ExpandableStoreShell/EntryThreshold",
				"ExpandableStoreShell/EntryThresholdPractical",
				"ExpandableStoreShell/StarterGlassDoorBlocker",
				"ExpandableStoreShell/FrontDoorFrameLeft",
				"ExpandableStoreShell/FrontDoorFrameRight",
			],
			"route_anchor": "ExpandableStoreShell/EntryThreshold",
			"active_route_stage": "exit_orientation",
			"active_prompt": "Exit to mall",
			"next_expected_beat": "front exit",
			"next_destination": "front exit",
			"local_action": "recognize the way back out through the front threshold",
			"route_sequence_index": 6,
			"primary_work_surface_target": "ExpandableStoreShell/EntryThreshold",
			"action_context": _action_context(
				"exit",
				"EntranceDoor/Interactable",
				"Exit to mall",
				"leave through the front threshold after close",
				"front exit",
				[
					_candidate("EntranceDoor/Interactable", "active", ""),
					_candidate(
						"StoreSessionDayEndTrigger/Interactable",
						"disabled",
						"Close-day interaction is complete before exit."
					),
				],
				"checkout-to-front-threshold approach"
			),
			"work_surface_review": {
				"surface_role": "exit_threshold_hierarchy",
				"primary_action_surface": "ExpandableStoreShell/EntryThreshold",
				"dominance_required": true,
				"supporting_props_should_stay_quiet": true,
			},
			"inspiration_closeout": _inspiration_closeout(
				["storefront_and_mall_identity"],
				(
					"Original front threshold, push plate, glass blocker, and door-frame geometry "
					+ "make the mall exit legible without copying a storefront."
				),
				"08_exit_threshold_return_view.png validates return-path threshold readability."
			),
			"design_checks": route_design_checks(),
			"scope": "first_ten_seconds",
			"visual_scope_mode":
			StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL,
			"review_target": ACCEPTANCE_TARGET,
			"hud_context_required": HUD_CONTEXT_LABEL,
		},
	]


static func _action_context(
	moment: String,
	active_target: String,
	active_prompt: String,
	local_action: String,
	next_destination: String,
	actionable_candidates: Array[Dictionary],
	approach_angle: String
) -> Dictionary:
	return StoreVisualActionContextScript.context(
		moment,
		active_target,
		active_prompt,
		local_action,
		next_destination,
		actionable_candidates,
		approach_angle
	)


static func _candidate(path: String, state: String, reason: String) -> Dictionary:
	return StoreVisualActionContextScript.candidate(path, state, reason)


static func _stockroom_pickup_disabled_guidance() -> Dictionary:
	return {
		"before_active_objective": "Talk to the customer first.",
		"while_carrying_stock": "Stock already in hand. Place it on the Starter Display.",
		"after_delivery_checked": "Stock box already inspected. Stock the Starter Display.",
	}


static func _inspiration_closeout(
	cluster_ids: Array[String],
	mallcore_original_adaptation: String,
	intended_pattern_validation: String
) -> Dictionary:
	return InspirationCloseoutContractScript.closeout_for(
		cluster_ids,
		mallcore_original_adaptation,
		intended_pattern_validation
	)


## Returns older broad-store review context kept out of phase acceptance.
static func full_store_review_context() -> Dictionary:
	return StoreVisualFullStoreContextScript.context(_serializable_rows(full_store_rows()))


## Returns the older eight-angle full-store sweep for secondary review context.
static func full_store_rows() -> Array[Dictionary]:
	return StoreVisualFullStoreContextScript.rows()


## Returns the human review checks that must be applied to every sweep image.
static func review_criteria() -> Array[String]:
	return first_ten_seconds_review_criteria()


## Returns the review-manifest fields expected by the diff and human-review gates.
static func review_manifest_required_fields() -> Array[String]:
	return [
		"route_target",
		"anchors",
		"visual_scope_mode",
		"inspiration_cluster",
		"baseline_policy",
		"blank_wall_dominance",
		"work_surface_dominance",
		"disconnected_prop_dominance",
		"route_obstruction",
		"ui_clipping",
		"originality_notes",
		"capture_resolution_validity",
	]


## Returns target-specific review metadata that must survive into manifests.
static func review_manifest_contract(row: Dictionary) -> Dictionary:
	return _review_manifest_contract(row)


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
		"blank wall mass dominates the composition",
		"oversized door geometry dominates the composition",
		"disconnected props dominate the composition",
		"material families read as unrelated surfaces",
	]


## Returns the first-run route markers that reviewers should be able to infer.
static func first_run_flow_steps() -> Array[Dictionary]:
	return first_day_route_sequence()


## Returns the route sequence reviewers use to judge the first-day screenshots.
static func first_day_route_sequence() -> Array[Dictionary]:
	return StoreVisualActionContextScript.route_sequence()


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
		"acceptance_evidence": true,
		"non_acceptance_evidence": false,
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
	var target: String = ACCEPTANCE_TARGET
	if not rows_to_write.is_empty():
		target = str(rows_to_write[0].get("review_target", ACCEPTANCE_TARGET))
	var payload: Dictionary = {
		"artifact_dir": ProjectSettings.globalize_path(resolved_dir),
		"acceptance_target": target,
		"review_criteria": review_criteria(),
		"first_ten_seconds_review_criteria": first_ten_seconds_review_criteria(),
		"design_failure_criteria": design_failure_criteria(),
		"first_run_flow_steps": first_run_flow_steps(),
		"first_day_route_sequence": first_day_route_sequence(),
		"required_action_moments": REQUIRED_ACTION_MOMENTS,
		"full_store_review_context": full_store_review_context(),
		"visual_scope_profile": StoreVisualScopeProfileScript.scope_manifest(),
		"capture_policy": capture_policy(),
		"baseline_review_rules": baseline_review_rules(),
		"diff_review_policy": diff_review_policy(),
		"work_surface_closeout_contract": WorkSurfaceValidationContractScript.closure_manifest(),
		"inspiration_reference_policy": InspirationCloseoutContractScript.source_policy(),
		"inspiration_reference_clusters": InspirationCloseoutContractScript.cluster_catalog(),
		"required_originality_commands":
		InspirationCloseoutContractScript.required_originality_commands(),
		"validation_output_channels": WorkSurfaceValidationContractScript.output_channels(),
		"review_manifest_required_fields": review_manifest_required_fields(),
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


## Returns the artifact directory for target-specific captures consumed by diffing.
static func acceptance_current_dir_for_target(target_mode: String) -> String:
	if target_mode == OVERHAUL_TARGET_MODE:
		return AutomationArtifactsScript.artifact_path(OVERHAUL_ACCEPTANCE_CURRENT_DIR)
	return acceptance_current_dir()


## Returns the artifact directory for visual diff heatmaps and metadata.
static func acceptance_diff_dir() -> String:
	return AutomationArtifactsScript.artifact_path(ACCEPTANCE_DIFF_DIR)


## Returns the artifact directory for target-specific visual diff heatmaps.
static func acceptance_diff_dir_for_target(target_mode: String) -> String:
	if target_mode == OVERHAUL_TARGET_MODE:
		return AutomationArtifactsScript.artifact_path(OVERHAUL_ACCEPTANCE_DIFF_DIR)
	return acceptance_diff_dir()


## Returns the artifact directory for the acceptance manifest and current captures.
static func acceptance_manifest_dir() -> String:
	return AutomationArtifactsScript.artifact_path(ACCEPTANCE_ARTIFACT_DIR)


## Returns the artifact directory for the target-specific manifest and captures.
static func acceptance_manifest_dir_for_target(target_mode: String) -> String:
	if target_mode == OVERHAUL_TARGET_MODE:
		return AutomationArtifactsScript.artifact_path(OVERHAUL_ACCEPTANCE_ARTIFACT_DIR)
	return acceptance_manifest_dir()


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
			StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
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
		"work-surface captures must show the primary action surface as dominant",
		"supporting props must stay quieter than the action surface",
		"inspiration closeout must name the reference cluster and original Mallcore adaptation",
		"visual copy and labels must be original Mallcore text or already present in repo content",
		"01_spawn_first_look.png must be a display-backed 1280x720 gl_compatibility capture",
	]


## Returns the automated diff intent and threshold names for review tooling.
static func diff_review_policy() -> Dictionary:
	return {
		"noise_classification": (
			"small renderer/font noise is tracked separately from meaningful hierarchy, "
			+ "framing, and composition changes"
		),
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
		var action_context_validation: Dictionary = (
			validate_action_context(row) if row.has("action_context") else {}
		)
		var payload: Dictionary = {
			"index": int(row.get("index", 0)),
			"name": str(row.get("name", "")),
			"label": str(row.get("label", "")),
			"filename": str(row.get("filename", "")),
			"camera": [camera.x, camera.y, camera.z],
			"camera_fov": float(row.get("camera_fov", CAPTURE_CAMERA_FOV)),
			"focus": str(row.get("focus", "")),
			"anchors": row.get("anchors", []),
			"route_anchor": str(row.get("route_anchor", "")),
			"active_route_stage": str(row.get("active_route_stage", "")),
			"active_prompt": str(row.get("active_prompt", "")),
			"disabled_guidance": row.get("disabled_guidance", {}),
			"next_expected_beat": str(row.get("next_expected_beat", "")),
			"next_destination": str(row.get("next_destination", "")),
			"local_action": str(row.get("local_action", "")),
			"route_sequence_index": int(row.get("route_sequence_index", -1)),
			"primary_work_surface_target": str(row.get("primary_work_surface_target", "")),
			"action_context": row.get("action_context", {}),
			"action_context_validation": action_context_validation,
			"work_surface_review": row.get("work_surface_review", {}),
			"inspiration_closeout": row.get("inspiration_closeout", {}),
			"spawn_acceptance_review": row.get("spawn_acceptance_review", {}),
			"spawn_readability_anchors": row.get("spawn_readability_anchors", []),
			"design_checks": row.get("design_checks", []),
			"review_manifest_contract": _review_manifest_contract(row),
			"setup_state": str(row.get("setup_state", "")),
			"scope": str(row.get("scope", "")),
			"visual_scope_mode": str(row.get("visual_scope_mode", "")),
			"review_target": str(row.get("review_target", "")),
			"hud_context_required": str(row.get("hud_context_required", "")),
		}
		if row.has("camera_rotation_degrees"):
			var camera_rotation: Vector3 = row.get("camera_rotation_degrees", Vector3.ZERO) as Vector3
			payload["camera_rotation_degrees"] = [
				camera_rotation.x,
				camera_rotation.y,
				camera_rotation.z,
			]
		serializable.append(payload)
	return serializable


static func _manual_review_template(rows_to_write: Array[Dictionary]) -> Dictionary:
	var verdicts: Array[Dictionary] = []
	for row: Dictionary in rows_to_write:
		verdicts.append({
			"beat": str(row.get("filename", "")),
			"status": "pass|fail|needs_changes",
			"active_route_stage": str(row.get("active_route_stage", "")),
			"active_prompt": str(row.get("active_prompt", "")),
			"disabled_guidance": row.get("disabled_guidance", {}),
			"next_expected_beat": str(row.get("next_expected_beat", "")),
			"local_action": str(row.get("local_action", "")),
			"next_destination": str(row.get("next_destination", "")),
			"route_sequence_index": int(row.get("route_sequence_index", -1)),
			"visual_scope_mode": str(row.get("visual_scope_mode", "")),
			"primary_work_surface_target": str(row.get("primary_work_surface_target", "")),
			"action_context": row.get("action_context", {}),
			"inspiration_closeout": row.get("inspiration_closeout", {}),
			"spawn_acceptance_review": row.get("spawn_acceptance_review", {}),
			"spawn_readability_anchors": row.get("spawn_readability_anchors", []),
			"review_manifest_contract": _review_manifest_contract(row),
			"fresh_player_identifies_first_action_without_ui_labels": false,
			"fresh_player_identifies_manager_target_without_ui_labels": false,
			"fresh_player_identifies_next_store_destinations_without_ui_labels": false,
			"action_context_unambiguous": false,
			"normal_player_approach": false,
			"next_destination_visible": false,
			"primary_work_surface_dominant": false,
			"supporting_props_stay_quiet": false,
			"reference_cluster_pattern_validated": false,
			"mallcore_original_adaptation_confirmed": false,
			"no_import_trace_clone_or_logo_copy": false,
			"new_text_original_or_repo_existing": false,
			"material_family_consistent": false,
			"readable_scale": false,
			"blank_wall_oversized_door_disconnected_prop_absent": false,
			"failed_review_criteria": [],
			"failed_design_criteria": [],
			"notes": "",
		})
	return {
		"verdicts": verdicts,
	}


static func _review_manifest_contract(row: Dictionary) -> Dictionary:
	var closeout: Dictionary = row.get("inspiration_closeout", {}) as Dictionary
	var cluster_ids: Array[String] = []
	for cluster_variant: Variant in closeout.get("reference_clusters", []) as Array:
		if cluster_variant is Dictionary:
			cluster_ids.append(str((cluster_variant as Dictionary).get("id", "")))
	return {
		"route_target": str(row.get("review_target", "")),
		"anchors": row.get("anchors", []),
		"visual_scope_mode": str(row.get("visual_scope_mode", "")),
		"inspiration_cluster": cluster_ids,
		"baseline_policy": "fresh_display_backed_capture_with_soft_intentional_baseline",
		"blank_wall_dominance": "reject",
		"work_surface_dominance": "primary_action_surface_must_dominate",
		"disconnected_prop_dominance": "reject",
		"route_obstruction": "reject_if_primary_route_or_action_anchor_is_blocked",
		"ui_clipping": "reject",
		"originality_notes": str(closeout.get("mallcore_original_adaptation", "")),
		"capture_resolution_validity": "must_match_1280x720",
	}


static func _spawn_anchor(
	landmark: String, path: String, physical_zone: String, forbidden_zones: Array[String]
) -> Dictionary:
	return {
		"landmark": landmark,
		"path": path,
		"physical_zone": physical_zone,
		"forbidden_zones": forbidden_zones,
		"first_ten_seconds_acceptance_target": ACCEPTANCE_TARGET,
	}


static func _save_placeholder_png(dir_path: String, filename: String) -> Dictionary:
	var safe_filename: String = sanitize_slug(filename.get_basename()) + ".png"
	var path: String = "%s/%s" % [dir_path, safe_filename]
	var image: Image = Image.create_empty(
		CAPTURE_RESOLUTION.x,
		CAPTURE_RESOLUTION.y,
		false,
		Image.FORMAT_RGBA8
	)
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
		"acceptance_evidence": false,
		"non_acceptance_evidence": true,
		"non_acceptance_reason": "headless placeholder cannot satisfy work-surface polish acceptance",
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
