## Pins the visual readability contract: customer body color must be
## saturated enough to stand out, the empty-slot placement marker must
## render with visible alpha plus emission, and the checkout-counter
## Label3D must stay within a non-floating scale budget. These properties
## let a Day-1 player tell apart customers, fixtures, empty slots, and
## checkout signage without runtime UI overlays.
extends GutTest

const SLOT_MARKER_PATH: String = "res://game/assets/materials/mat_slot_marker.tres"
const CUSTOMER_SCENE_PATH: String = "res://game/scenes/characters/customer.tscn"
const RETRO_GAMES_SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const LAMINATE_COUNTER_MATERIAL_PATH: String = (
	"res://game/assets/materials/mat_laminate_counter.tres"
)
const SIGN_BACKING_MATERIAL_PATH: String = "res://game/assets/materials/mat_sign_backing.tres"
const FLUORESCENT_PANEL_MATERIAL_PATH: String = (
	"res://game/assets/materials/mat_fluorescent_panel.tres"
)
const RETRO_PRODUCT_MATERIAL_PATH: String = (
	"res://game/assets/materials/mat_product_retro_games_textured.tres"
)
const PRODUCT_COVER_PATHS: Array[String] = [
	"res://game/assets/products/product_dungeon_dad_64.svg",
	"res://game/assets/products/product_space_mall_3.svg",
	"res://game/assets/products/product_kart_clerk_deluxe.svg",
	"res://game/assets/products/product_pixel_pets_moon_mix.svg",
]
const PRODUCT_TEXTURE_PATHS: Array[String] = [
	"res://game/assets/products/product_dungeon_dad_64.png",
	"res://game/assets/products/product_space_mall_3.png",
	"res://game/assets/products/product_kart_clerk_deluxe.png",
	"res://game/assets/products/product_pixel_pets_moon_mix.png",
]
const PRODUCT_COVER_TITLES: Array[String] = [
	"DUNGEON",
	"SPACE",
	"KART CLERK",
	"PIXEL PETS",
]

# Slot-marker albedo alpha must be visible (not the historical 0.0 ghost
# value) so empty slots glow during placement mode against any shelf wood.
const SLOT_MARKER_MIN_ALPHA: float = 0.3

# A "saturated" hue: max(rgb) - min(rgb) >= 0.4. Pure gray (rgb equal) has
# saturation 0; the customer body color must clear this so the customer
# does not blend into the cream walls or brown floor.
const CUSTOMER_BODY_MIN_SATURATION: float = 0.4

# CheckoutSign pixel_size cap. With BILLBOARD_ENABLED + font_size ~40, a
# pixel_size above this draws a >=1m-wide floating banner above the
# register; the cap keeps the label readable but counter-scaled.
const CHECKOUT_SIGN_MAX_PIXEL_SIZE: float = 0.0035

# Register-screen emission floor. The screen sub-resource sits behind the
# ambient neon panels (1.7–1.8 energy); below this floor its green glow
# fails to read at the ~8–12m entrance spawn distance and the counter
# loses its "active POS terminal" beacon.
const REGISTER_SCREEN_MIN_EMISSION: float = 1.2
const BACKROOM_MIN_DOORWAY_WIDTH: float = 2.4
const SUPPORT_TOLERANCE: float = 0.035
const FLOOR_DETAIL_MAX_AXIS: float = 0.78
const RETAIL_CEILING_Y: float = 3.55
const ZONE_FILL_MIN_ENERGY: float = 0.35
const ZONE_FILL_MAX_ENERGY: float = 0.62
const STORE_VISUAL_LANDMARKS: Array[String] = [
	"ReadabilityProps/ZoneLighting/MainAisleWarmFill",
	"ReadabilityProps/ZoneLighting/CheckoutAmberFill",
	"ReadabilityProps/ZoneIdentity/CheckoutCeilingPractical",
	"ReadabilityProps/ZoneIdentity/AisleCeilingPractical",
	"ReadabilityProps/ZoneIdentity/ShelfCeilingPractical",
	"ReadabilityProps/ZoneIdentity/ReferenceCornerFloorInset",
	"ReadabilityProps/ZoneIdentity/ReferenceCornerWallPanel",
	"ReadabilityProps/ZoneIdentity/ReferenceCornerProductAccent",
	"ReadabilityProps/ZoneIdentity/BackroomCeilingPractical",
	"ReadabilityProps/ZoneIdentity/EntryCeilingPractical",
	"ReadabilityProps/ZoneIdentity/BackWallShelfWarmBand",
	"ReadabilityProps/ZoneIdentity/BackroomFloorMat",
	"ReadabilityProps/ZoneIdentity/EntranceRubberMat",
	"ReadabilityProps/WallPosterRails/BackWallSaleBoardFrame",
	"ReadabilityProps/ProductDisplayRows/ShelfProductBacker",
	"ReadabilityProps/ShelfFaceDressing/NewReleaseFaceA",
	"ReadabilityProps/FloorDisplayIsland/FrontCaseA",
	"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableTop",
	"ReadabilityProps/SpawnViewFloorDressing/SaleBasketA",
	"ReadabilityProps/SpawnViewFloorDressing/CordCoilA",
	"ReadabilityProps/DayOneRouteMarkers/TrainingStopManager",
	"ReadabilityProps/DayOneRouteMarkers/TrainingStopRegister",
	"ReadabilityProps/DayOneRouteMarkers/TrainingStopBackroom",
	"ReadabilityProps/DayOneRouteMarkers/TrainingStopShelf",
	"ReadabilityProps/ProductDisplayRows/DungeonDad64_ShelfA",
	"ReadabilityProps/ProductDisplayRows/SpaceMall3_ShelfA",
	"ReadabilityProps/ProductDisplayRows/KartClerkDeluxe_ShelfA",
	"ReadabilityProps/ProductDisplayRows/PixelPetsMoonMix_ShelfA",
	"ReadabilityProps/CheckoutCounterDressing/CounterReceiptSlipA",
	"ReadabilityProps/CheckoutCounterDressing/StorePolicyCard",
	"FrontLaneQueue/LaneFixture/QueueMat01",
	"ReadabilityProps/ShelfSpineRuns/ShelfSpineDungeonDadA",
	"ReadabilityProps/UsedConsoleDressing/ConsoleTowerA",
	"ReadabilityProps/BackroomDressing/StockStackA",
]
const CHECKOUT_ANCHOR_PROP_PATHS: Array[String] = [
	"Checkout/Register/RegisterScreen",
	"Checkout/Register/CheckoutDetails/CardTerminal",
	"Checkout/ReceiptPrinter",
	"ReadabilityProps/CheckoutCounterDressing/RegisterGlowPlate",
	"ReadabilityProps/CheckoutCounterDressing/StorePolicyCard",
	"ReadabilityProps/CheckoutCounterDressing/TradeInFlyer",
	"ReadabilityProps/CheckoutCounterDressing/CoinTray",
	"ReadabilityProps/CheckoutCounterDressing/StickerRoll",
	"ReadabilityProps/CheckoutCounterDressing/CounterPen",
	"ReadabilityProps/CheckoutCounterDressing/CustomerServiceSpotMat",
]
const QUEUE_VISUAL_PROP_PATHS: Array[String] = [
	"FrontLaneQueue/LaneFixture/QueueMat01",
	"FrontLaneQueue/LaneFixture/QueueMat02",
	"FrontLaneQueue/LaneFixture/QueueMat03",
	"FrontLaneQueue/LaneFixture/LeftGuideRope",
	"FrontLaneQueue/LaneFixture/RightGuideRope",
	"FrontLaneQueue/LaneFixture/DirectionArrowShaft",
	"FrontLaneQueue/LaneFixture/DirectionArrowHeadLeft",
	"FrontLaneQueue/LaneFixture/DirectionArrowHeadRight",
]
const BACKROOM_RECEIVING_BAY_PROP_PATHS: Array[String] = [
	"ReadabilityProps/BackroomDressing/LoadingZoneMat",
	"ReadabilityProps/BackroomDressing/PickupBayFloorTapeFront",
	"ReadabilityProps/BackroomDressing/PickupBayFloorTapeBack",
	"ReadabilityProps/BackroomDressing/PickupBayFloorTapeLeft",
	"ReadabilityProps/BackroomDressing/PickupBayFloorTapeRight",
	"ReadabilityProps/BackroomDressing/ReceivingTableTop",
	"ReadabilityProps/BackroomDressing/PickupBayClipboard",
	"ReadabilityProps/BackroomDressing/ReceivingSheet",
	"ReadabilityProps/BackroomDressing/ReceivingCartonStackA",
	"ReadabilityProps/BackroomDressing/ReceivingCartonStackB",
	"ReadabilityProps/BackroomDressing/CartonTapeA",
	"ReadabilityProps/BackroomDressing/CartonShippingLabelA",
	"ReadabilityProps/BackroomDressing/CartonShippingLabelB",
	"ReadabilityProps/BackroomDressing/PickupBayLabelPlate",
	"ReadabilityProps/BackroomDressing/TodayDeliverySign",
	"ReadabilityProps/BackroomDressing/HandTruckFrameLeft",
	"ReadabilityProps/BackroomDressing/HandTruckFrameRight",
	"ReadabilityProps/BackroomDressing/HandTruckToePlate",
]
const USED_CONSOLE_DEPARTMENT_PROP_PATHS: Array[String] = [
	"ReadabilityProps/UsedConsoleDressing/UsedConsoleDisplayDeck",
	"ReadabilityProps/UsedConsoleDressing/BoxedConsoleStackA",
	"ReadabilityProps/UsedConsoleDressing/BoxedConsoleStackB",
	"ReadabilityProps/UsedConsoleDressing/ControllerBinA",
	"ReadabilityProps/UsedConsoleDressing/CableBundleA",
	"ReadabilityProps/UsedConsoleDressing/CableBundleB",
]
const USED_CONSOLE_SILHOUETTE_PATHS: Array[String] = [
	"ReadabilityProps/UsedConsoleDressing/NeoIgniteSilhouetteA",
	"ReadabilityProps/UsedConsoleDressing/CanopyWaveSilhouetteA",
	"ReadabilityProps/UsedConsoleDressing/VecForceHDSilhouetteA",
	"ReadabilityProps/UsedConsoleDressing/WavePocketSilhouetteA",
	"ReadabilityProps/UsedConsoleDressing/IgniteGoSilhouetteA",
]
const USED_CONSOLE_CONTROLLER_PATHS: Array[String] = [
	"ReadabilityProps/UsedConsoleDressing/ControllerNeoIgniteA",
	"ReadabilityProps/UsedConsoleDressing/ControllerCanopyWaveA",
	"ReadabilityProps/UsedConsoleDressing/ControllerVecForceHDA",
	"ReadabilityProps/UsedConsoleDressing/ControllerWavePocketA",
	"ReadabilityProps/UsedConsoleDressing/ControllerIgniteGoA",
]
const USED_CONSOLE_CONDITION_TAG_TEXT: Array[String] = [
	"TESTED",
	"CLEANED",
	"AS-IS",
]
const USED_CONSOLE_PLATFORM_LABEL_TEXT: Array[String] = [
	"NEO IGNITE",
	"CANOPY WAVE",
	"VECFORCE HD",
	"WAVE POCKET",
	"IGNITE GO",
]
const ROOM_COHESION_DRESSING_PATHS: Array[String] = [
	"ReadabilityProps/ZoneIdentity/BackWallBaseTrim",
	"ReadabilityProps/ZoneIdentity/BackWallBaseTrimLeftRun",
	"ReadabilityProps/ZoneIdentity/BackWallBaseTrimRightRun",
	"ReadabilityProps/ZoneIdentity/LeftWallBaseTrimFrontRun",
	"ReadabilityProps/ZoneIdentity/RightWallBaseTrimCheckoutRun",
	"ReadabilityProps/ZoneIdentity/EntranceRubberMat",
	"ReadabilityProps/ZoneIdentity/EntranceMatScuffLeft",
	"ReadabilityProps/ZoneIdentity/EntranceMatScuffRight",
	"ReadabilityProps/ZoneIdentity/BackroomFloorMatScuff",
	"ReadabilityProps/ZoneIdentity/RightWallConsoleCoolBand",
	"ReadabilityProps/ZoneIdentity/BackroomServiceUtilityBand",
	"ReadabilityProps/ZoneIdentity/BackroomCeilingMount",
	"ReadabilityProps/ZoneIdentity/BackroomCeilingPractical",
	"ReadabilityProps/ZoneIdentity/EntryCeilingMount",
	"ReadabilityProps/ZoneIdentity/EntryCeilingPractical",
	"ReadabilityProps/WallPosterRails",
]
const ANCHORED_WALL_CARD_PATHS: Array[String] = [
	"ReadabilityProps/WallPosterRails/BackWallSaleBoardFrame",
	"ReadabilityProps/WallPosterRails/BackWallSaleBoardPanel",
	"ReadabilityProps/WallPosterRails/BackWallSaleBoardTopRail",
	"ReadabilityProps/WallPosterRails/BackWallSaleBoardBottomRail",
	"ReadabilityProps/WallPosterRails/BackWallSaleBoardClipLeft",
	"ReadabilityProps/WallPosterRails/BackWallSaleBoardClipRight",
	"ReadabilityProps/WallPosterRails/BackWallPolicyFrame",
	"ReadabilityProps/WallPosterRails/BackWallPolicyCard",
	"ReadabilityProps/WallPosterRails/BackWallPolicyTopClip",
	"ReadabilityProps/WallPosterRails/LeftWallNoteRail",
	"ReadabilityProps/WallPosterRails/LeftWallNoteBacking",
	"ReadabilityProps/WallPosterRails/LeftWallNoteCardA",
	"ReadabilityProps/WallPosterRails/LeftWallNoteCardB",
	"ReadabilityProps/WallPosterRails/LeftWallNoteClipA",
]
const SPAWN_VIEW_MAIN_FLOOR_PROP_PATHS: Array[String] = [
	"ReadabilityProps/SpawnViewFloorDressing/EntrySideMatLeft",
	"ReadabilityProps/SpawnViewFloorDressing/EntrySideMatRight",
	"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableTop",
	"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableLegFrontLeft",
	"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableLegFrontRight",
	"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableLegBackLeft",
	"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableLegBackRight",
	"ReadabilityProps/SpawnViewFloorDressing/TableStackDungeonDad",
	"ReadabilityProps/SpawnViewFloorDressing/TableStackSpaceMall",
	"ReadabilityProps/SpawnViewFloorDressing/TableStackPixelPets",
	"ReadabilityProps/SpawnViewFloorDressing/SaleBasketA",
	"ReadabilityProps/SpawnViewFloorDressing/SaleBasketCaseA",
	"ReadabilityProps/SpawnViewFloorDressing/SaleBasketCaseB",
	"ReadabilityProps/SpawnViewFloorDressing/DisplayBinA",
	"ReadabilityProps/SpawnViewFloorDressing/CordCoilA",
	"ReadabilityProps/SpawnViewFloorDressing/CordTailA",
]
const SUPPRESSED_VISUAL_JUNK_PATHS: Array[String] = [
	"ReadabilityProps/DayOneRouteMarkers",
	"ReadabilityProps/SpawnViewFloorDressing",
	"ReadabilityProps/BargainBinOverflow",
	"ReadabilityProps/CartRackProductStacks",
	"ReadabilityProps/ShelfSpineRuns",
	"ReadabilityProps/UsedConsoleDressing",
	"ReadabilityProps/CheckoutCounterDressing/CounterImpulseDungeonDad",
	"ReadabilityProps/CheckoutCounterDressing/CounterImpulsePixelPets",
	"ReadabilityProps/CheckoutCounterDressing/CounterCardStack",
	"ReadabilityProps/CheckoutCounterDressing/StorePolicyCard",
	"ReadabilityProps/CheckoutCounterDressing/TradeInFlyer",
	"ReadabilityProps/CheckoutCounterDressing/CoinTray",
	"ReadabilityProps/CheckoutCounterDressing/StickerRoll",
	"ReadabilityProps/CheckoutCounterDressing/CounterPen",
	"ReadabilityProps/BackroomDressing/StockStackA",
	"ReadabilityProps/BackroomDressing/StockStackB",
	"ReadabilityProps/BackroomDressing/StockStackC",
	"ReadabilityProps/BackroomDressing/PackingSlip",
	"ReadabilityProps/BackroomDressing/BoxLabelA",
	"ReadabilityProps/BackroomDressing/BoxLabelB",
	"ReadabilityProps/BackroomDressing/ReceivingCartonTop",
	"ReadabilityProps/BackroomDressing/CartonTapeA",
	"ReadabilityProps/BackroomDressing/CartonShippingLabelA",
	"ReadabilityProps/BackroomDressing/CartonShippingLabelB",
	"ReadabilityProps/BackroomDressing/HandTruckFrameLeft",
	"ReadabilityProps/BackroomDressing/HandTruckFrameRight",
	"ReadabilityProps/BackroomDressing/HandTruckToePlate",
	"ReadabilityProps/BackroomDressing/HandTruckWheelLeft",
	"ReadabilityProps/BackroomDressing/HandTruckWheelRight",
]
const SPAWN_VIEW_CRITICAL_MARKERS: Array[String] = [
	"PlayerEntrySpawn",
	"Checkout",
	"BetaDayOneCustomer",
	"BetaBackroomPickup",
	"BetaRestockShelf",
	"BetaDayEndTrigger",
]
const SALES_FLOOR_PALETTE_NODE_PATHS: Array[String] = [
	"ReadabilityProps/ZoneIdentity/CheckoutCounterAccent",
	"ReadabilityProps/ZoneIdentity/ShelfStockAccent",
	"ReadabilityProps/ZoneIdentity/EntranceRubberMat",
	"ReadabilityProps/ZoneIdentity/BackWallBaseTrim",
	"ReadabilityProps/ZoneIdentity/BackWallShelfWarmBand",
	"ReadabilityProps/ZoneIdentity/RightWallConsoleCoolBand",
	"ReadabilityProps/ZoneIdentity/ReferenceCornerFloorInset",
	"ReadabilityProps/ZoneIdentity/ReferenceCornerWallPanel",
	"ReadabilityProps/WallPosterRails/BackWallSaleBoardPanel",
	"ReadabilityProps/WallPosterRails/BackWallPolicyCard",
	"ReadabilityProps/ProductDisplayRows/ShelfProductBacker",
	"ReadabilityProps/ProductDisplayRows/ShelfProductLip",
	"ReadabilityProps/CheckoutCounterDressing/StorePolicyCard",
	"ReadabilityProps/CheckoutCounterDressing/TradeInFlyer",
	"ReadabilityProps/UsedConsoleDressing/UsedConsoleDisplayDeck",
	"ReadabilityProps/UsedConsoleDressing/ControllerBinA",
	"ReadabilityProps/UsedConsoleDressing/NeoIgniteSilhouetteA/PowerDot",
	"ReadabilityProps/UsedConsoleDressing/CanopyWaveSilhouetteA/RaisedCanopy",
	"ReadabilityProps/UsedConsoleDressing/VecForceHDSilhouetteA/BlueSlot",
	"ReadabilityProps/UsedConsoleDressing/WavePocketSilhouetteA/ScreenInset",
	"ReadabilityProps/UsedConsoleDressing/IgniteGoSilhouetteA/LowerShell",
]
const STOCKROOM_UTILITY_PALETTE_NODE_PATHS: Array[String] = [
	"ReadabilityProps/ZoneIdentity/BackroomDoorThreshold",
	"ReadabilityProps/ZoneIdentity/BackroomFloorMat",
	"ReadabilityProps/ZoneIdentity/BackroomCeilingPractical",
	"ReadabilityProps/ZoneIdentity/BackroomServiceUtilityBand",
	"ReadabilityProps/BackroomDressing/LoadingZoneMat",
]
const SUBTLE_EMISSION_NODE_PATHS: Array[String] = [
	"ReadabilityProps/ZoneIdentity/CheckoutCounterAccent",
	"ReadabilityProps/ZoneIdentity/ShelfStockAccent",
	"ReadabilityProps/ZoneIdentity/BackroomDoorThreshold",
	"ReadabilityProps/ZoneIdentity/BackroomFloorMat",
	"ReadabilityProps/ZoneIdentity/CheckoutCeilingPractical",
	"ReadabilityProps/ZoneIdentity/ReferenceCornerWallPanel",
	"ReadabilityProps/ZoneIdentity/BackroomCeilingPractical",
	"ReadabilityProps/WallPosterRails/BackWallSaleBoardPanel",
	"ReadabilityProps/ProductDisplayRows/UsedShelfEmptySlotA",
	"ReadabilityProps/ProductDisplayRows/NewReleaseEmptySlotA",
	"ReadabilityProps/CheckoutCounterDressing/RegisterGlowPlate",
	"ReadabilityProps/UsedConsoleDressing/NeoIgniteSilhouetteA/PowerDot",
	"ReadabilityProps/UsedConsoleDressing/CanopyWaveSilhouetteA/WaveRidgeA",
	"ReadabilityProps/UsedConsoleDressing/VecForceHDSilhouetteA/BlueSlot",
	"ReadabilityProps/UsedConsoleDressing/WavePocketSilhouetteA/ScreenInset",
	"ReadabilityProps/UsedConsoleDressing/IgniteGoSilhouetteA/HingeBar",
	"ReadabilityProps/BackroomDressing/LoadingZoneMat",
	"crt_demo_area/WarmNeonPanel",
	"crt_demo_area/GreenNeonPanel",
]
const SUBTLE_EMISSION_MAX: float = 0.55


func test_slot_marker_material_renders_visible_with_emission() -> void:
	var mat: StandardMaterial3D = load(SLOT_MARKER_PATH) as StandardMaterial3D
	assert_not_null(mat, "mat_slot_marker.tres must load as StandardMaterial3D")
	if mat == null:
		return
	assert_gte(
		mat.albedo_color.a, SLOT_MARKER_MIN_ALPHA,
		(
			"Slot-marker albedo alpha=%.2f must be >= %.2f so empty slots are "
			+ "visible during placement mode (historical 0.0 alpha rendered "
			+ "the marker invisible even when PlaceholderMesh.visible=true)."
		) % [mat.albedo_color.a, SLOT_MARKER_MIN_ALPHA],
	)
	assert_true(
		mat.emission_enabled,
		(
			"Slot marker must enable emission so empty slots glow against the "
			+ "shelf wood material instead of fading into it."
		),
	)


func test_customer_body_material_uses_saturated_color() -> void:
	var scene: PackedScene = load(CUSTOMER_SCENE_PATH)
	assert_not_null(scene, "customer.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var body_mesh: MeshInstance3D = root.get_node_or_null(
		"BodyMesh"
	) as MeshInstance3D
	assert_not_null(body_mesh, "Customer/BodyMesh must exist")
	if body_mesh == null:
		root.free()
		return
	var body_mat: StandardMaterial3D = body_mesh.get_surface_override_material(
		0
	) as StandardMaterial3D
	assert_not_null(
		body_mat,
		"Customer BodyMesh must carry a StandardMaterial3D override",
	)
	if body_mat == null:
		root.free()
		return
	var c: Color = body_mat.albedo_color
	var saturation: float = maxf(maxf(c.r, c.g), c.b) - minf(minf(c.r, c.g), c.b)
	assert_gte(
		saturation, CUSTOMER_BODY_MIN_SATURATION,
		(
			"Customer body color rgb=(%.2f, %.2f, %.2f) saturation=%.2f must "
			+ "be >= %.2f so the customer reads as a distinctly colored "
			+ "shopper rather than a neutral gray prop."
		) % [c.r, c.g, c.b, saturation, CUSTOMER_BODY_MIN_SATURATION],
	)
	root.free()


func test_checkout_sign_scale_within_budget() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var sign: Label3D = root.get_node_or_null(
		"Checkout/Register/CheckoutSign"
	) as Label3D
	assert_not_null(
		sign, "Checkout/Register/CheckoutSign Label3D must exist",
	)
	if sign == null:
		root.free()
		return
	assert_lte(
		sign.pixel_size, CHECKOUT_SIGN_MAX_PIXEL_SIZE,
		(
			"CheckoutSign pixel_size=%.4f must be <= %.4f so the billboard "
			+ "label sits at counter scale rather than floating as a giant "
			+ "banner above the register."
		) % [sign.pixel_size, CHECKOUT_SIGN_MAX_PIXEL_SIZE],
	)
	root.free()


func test_register_screen_emission_clears_spawn_distance_floor() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var screen: MeshInstance3D = root.get_node_or_null(
		"Checkout/Register/RegisterScreen"
	) as MeshInstance3D
	assert_not_null(
		screen, "Checkout/Register/RegisterScreen MeshInstance3D must exist",
	)
	if screen == null:
		root.free()
		return
	var mat: StandardMaterial3D = screen.get_surface_override_material(
		0
	) as StandardMaterial3D
	assert_not_null(
		mat,
		"RegisterScreen must carry a StandardMaterial3D override (register_screen_mat)",
	)
	if mat == null:
		root.free()
		return
	assert_true(
		mat.emission_enabled,
		"register_screen_mat must keep emission enabled so the POS screen glows",
	)
	assert_gte(
		mat.emission_energy_multiplier, REGISTER_SCREEN_MIN_EMISSION,
		(
			"register_screen_mat emission_energy_multiplier=%.2f must be >= %.2f "
			+ "so the green screen glow reads at the ~8–12m entrance spawn "
			+ "distance against the 1.7–1.8 ambient neon panels."
		) % [mat.emission_energy_multiplier, REGISTER_SCREEN_MIN_EMISSION],
	)
	root.free()


func test_store_store_has_visual_landmark_overhaul_nodes() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in STORE_VISUAL_LANDMARKS:
		assert_not_null(
			root.get_node_or_null(node_path),
			"Store-session visual landmark missing: %s" % node_path
		)
	root.free()


func test_loose_visual_junk_stays_suppressed_by_default() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in SUPPRESSED_VISUAL_JUNK_PATHS:
		var node: Node3D = root.get_node_or_null(node_path) as Node3D
		assert_not_null(node, "Suppressed visual node must remain authored: %s" % node_path)
		if node == null:
			continue
		assert_false(
			_is_visible_in_tree(root, node),
			"%s must stay hidden so the store reads curated, not scattered" % node_path
		)
	root.free()


func test_room_cohesion_layer_has_wall_floor_and_ceiling_dressing() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in ROOM_COHESION_DRESSING_PATHS:
		assert_not_null(
			root.get_node_or_null(node_path),
			"Room cohesion dressing missing: %s" % node_path
		)
	for node_path: String in [
		"ReadabilityProps/ZoneIdentity/EntranceRubberMat",
		"ReadabilityProps/ZoneIdentity/EntranceMatScuffLeft",
		"ReadabilityProps/ZoneIdentity/EntranceMatScuffRight",
		"ReadabilityProps/ZoneIdentity/BackroomFloorMatScuff",
	]:
		var floor_detail: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(floor_detail, "Floor dressing missing: %s" % node_path)
		if floor_detail == null:
			continue
		assert_gte(
			_box_bottom_y(floor_detail),
			-0.01,
			"%s must sit on the floor rather than below it" % node_path
		)
		assert_lte(
			_box_bottom_y(floor_detail),
			0.06,
			"%s must read as scuffed floor dressing, not a floating marker"
			% node_path
		)
	root.free()


func test_store_material_palette_hierarchy_is_cohesive() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in SALES_FLOOR_PALETTE_NODE_PATHS:
		var mat: StandardMaterial3D = _standard_material_at(root, node_path)
		assert_not_null(mat, "%s must carry a StandardMaterial3D" % node_path)
		if mat == null:
			continue
		assert_true(
			_is_sales_floor_palette_color(mat.albedo_color),
			"%s must stay in the sales-floor palette; got %s"
			% [node_path, str(mat.albedo_color)]
		)
	for node_path: String in STOCKROOM_UTILITY_PALETTE_NODE_PATHS:
		var mat: StandardMaterial3D = _standard_material_at(root, node_path)
		assert_not_null(mat, "%s must carry a StandardMaterial3D" % node_path)
		if mat == null:
			continue
		assert_true(
			_is_stockroom_utility_color(mat.albedo_color),
			"%s must stay in the cooler stockroom utility palette; got %s"
			% [node_path, str(mat.albedo_color)]
		)
	var material_roles: Dictionary = {
		"Checkout/CounterTop": LAMINATE_COUNTER_MATERIAL_PATH,
		"Checkout/CounterCustomerRail": LAMINATE_COUNTER_MATERIAL_PATH,
		"Checkout/Register/CheckoutSignBacking": SIGN_BACKING_MATERIAL_PATH,
		"ReadabilityProps/ZoneIdentity/CheckoutCeilingPractical":
			FLUORESCENT_PANEL_MATERIAL_PATH,
		"ReadabilityProps/ZoneIdentity/ReferenceCornerWallPanel":
			SIGN_BACKING_MATERIAL_PATH,
		"ReadabilityProps/ZoneIdentity/ReferenceCornerProductAccent":
			RETRO_PRODUCT_MATERIAL_PATH,
	}
	for node_path: String in material_roles:
		var mat: StandardMaterial3D = _standard_material_at(root, node_path)
		assert_not_null(mat, "%s must carry a StandardMaterial3D" % node_path)
		if mat == null:
			continue
		assert_eq(
			mat.resource_path,
			String(material_roles[node_path]),
			"%s must use a reusable material resource" % node_path,
		)
	var floor_inset: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/ZoneIdentity/ReferenceCornerFloorInset"
	) as MeshInstance3D
	var wall_panel: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/ZoneIdentity/ReferenceCornerWallPanel"
	) as MeshInstance3D
	assert_not_null(floor_inset, "Reference corner floor inset must exist")
	assert_not_null(wall_panel, "Reference corner wall panel must exist")
	if floor_inset != null:
		assert_lte(
			_box_bottom_y(floor_inset),
			0.06,
			"Reference corner floor inset must sit on the retail floor"
		)
	if wall_panel != null:
		assert_gt(
			_scene_position(wall_panel).x,
			7.90,
			"Reference corner wall panel must be mounted on the checkout wall"
		)
	root.free()


func test_visual_palette_emissions_stay_subtle_outside_active_register() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in SUBTLE_EMISSION_NODE_PATHS:
		var mat: StandardMaterial3D = _standard_material_at(root, node_path)
		assert_not_null(mat, "%s must carry a StandardMaterial3D" % node_path)
		if mat == null or not mat.emission_enabled:
			continue
		assert_lte(
			mat.emission_energy_multiplier,
			SUBTLE_EMISSION_MAX,
			"%s emission must stay below active-register/sign brightness"
			% node_path
		)
	root.free()


func test_wall_cards_are_physically_anchored_to_rails_frames_or_clips() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in ANCHORED_WALL_CARD_PATHS:
		var prop: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(prop, "Anchored wall card prop missing: %s" % node_path)
		if prop != null:
			assert_not_null(prop.mesh, "%s must carry physical mesh geometry" % node_path)
	var sale_frame: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/WallPosterRails/BackWallSaleBoardFrame"
	) as MeshInstance3D
	var sale_panel: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/WallPosterRails/BackWallSaleBoardPanel"
	) as MeshInstance3D
	if sale_frame != null and sale_panel != null:
		assert_gt(
			_scene_position(sale_panel).z,
			_scene_position(sale_frame).z,
			"Back wall sale panel must sit in front of its frame/backing"
		)
	var note_backing: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/WallPosterRails/LeftWallNoteBacking"
	) as MeshInstance3D
	var note_card: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/WallPosterRails/LeftWallNoteCardA"
	) as MeshInstance3D
	if note_backing != null and note_card != null:
		assert_gt(
			_scene_position(note_card).x,
			_scene_position(note_backing).x,
			"Left wall note cards must sit in front of their backing board"
		)
	for node_path: String in [
		"ReadabilityProps/WallPosterRails/BackWallSaleBoardHeader",
		"ReadabilityProps/WallPosterRails/BackWallPolicyText",
		"ReadabilityProps/WallPosterRails/LeftWallNoteText",
	]:
		var label: Label3D = root.get_node_or_null(node_path) as Label3D
		assert_not_null(label, "Anchored wall card label missing: %s" % node_path)
		if label != null:
			assert_false(label.double_sided, "%s must not mirror from behind" % node_path)
	root.free()


func test_product_cover_svgs_exist_and_carry_named_art() -> void:
	for i: int in PRODUCT_COVER_PATHS.size():
		var path: String = PRODUCT_COVER_PATHS[i]
		assert_true(FileAccess.file_exists(path), "Product cover missing: %s" % path)
		assert_true(
			FileAccess.file_exists(PRODUCT_TEXTURE_PATHS[i]),
			"Runtime product texture missing: %s" % PRODUCT_TEXTURE_PATHS[i]
		)
		var file := FileAccess.open(path, FileAccess.READ)
		assert_not_null(file, "Product cover must be readable: %s" % path)
		if file == null:
			continue
		var source: String = file.get_as_text()
		assert_true(
			source.contains(PRODUCT_COVER_TITLES[i]),
			"Product cover %s must include the in-universe title text" % path
		)


func test_product_display_rows_have_at_least_four_named_products() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var product_nodes: Array[Node] = []
	_collect_group_nodes(root, &"product_display", product_nodes)
	assert_gte(
		product_nodes.size(),
		4,
		"Store session must render at least four named product displays"
	)
	for required_name: String in [
		"DungeonDad64_ShelfA",
		"SpaceMall3_ShelfA",
		"KartClerkDeluxe_ShelfA",
		"PixelPetsMoonMix_ShelfA",
	]:
		assert_not_null(
			root.find_child(required_name, true, false),
			"Missing named product display %s" % required_name
		)
	root.free()


func test_additive_visual_pass_has_zone_specific_dressing() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in [
		"ReadabilityProps/CheckoutCounterDressing",
		"ReadabilityProps/ShelfSpineRuns",
		"ReadabilityProps/UsedConsoleDressing",
		"ReadabilityProps/BackroomDressing",
	]:
		var dressing_root: Node = root.get_node_or_null(node_path)
		assert_not_null(
			dressing_root,
			"Additive visual pass missing zone dressing: %s" % node_path
		)
		if dressing_root != null:
			assert_gte(
				dressing_root.get_child_count(),
				4,
				"%s needs enough authored props to read as a dressed zone"
				% node_path
			)
	root.free()


func test_product_display_rows_use_svg_cover_textures() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in [
		"ReadabilityProps/ProductDisplayRows/DungeonDad64_ShelfA",
		"ReadabilityProps/ProductDisplayRows/SpaceMall3_ShelfA",
		"ReadabilityProps/ProductDisplayRows/KartClerkDeluxe_ShelfA",
		"ReadabilityProps/ProductDisplayRows/PixelPetsMoonMix_ShelfA",
	]:
		var product: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(product, "Missing product cover mesh: %s" % node_path)
		if product == null:
			continue
		var mat: StandardMaterial3D = product.get_surface_override_material(
			0
		) as StandardMaterial3D
		assert_not_null(mat, "Product cover must use a StandardMaterial3D")
		if mat != null:
			assert_not_null(
				mat.albedo_texture,
				"Product cover %s must bind an SVG texture" % node_path
			)
	root.free()


func test_product_display_rows_are_rail_supported_and_forward_offset() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var backer: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/ProductDisplayRows/ShelfProductBacker"
	) as MeshInstance3D
	var rail: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/ProductDisplayRows/ShelfProductLip"
	) as MeshInstance3D
	assert_not_null(backer, "ShelfProductBacker must exist")
	assert_not_null(rail, "ShelfProductLip must exist")
	if backer == null or rail == null:
		root.free()
		return
	var rail_top_y: float = _box_top_y(rail)
	for node_path: String in [
		"ReadabilityProps/ProductDisplayRows/DungeonDad64_ShelfA",
		"ReadabilityProps/ProductDisplayRows/SpaceMall3_ShelfA",
		"ReadabilityProps/ProductDisplayRows/KartClerkDeluxe_ShelfA",
		"ReadabilityProps/ProductDisplayRows/PixelPetsMoonMix_ShelfA",
	]:
		var product: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(product, "Missing product cover mesh: %s" % node_path)
		if product == null:
			continue
		var box: BoxMesh = product.mesh as BoxMesh
		assert_not_null(box, "%s must use a BoxMesh case with thickness" % node_path)
		if box == null:
			continue
		assert_gte(
			box.size.z,
			0.02,
			"%s must keep visible case thickness instead of a flat poster" % node_path
		)
		assert_gte(
			_scene_position(product).z - _scene_position(backer).z,
			0.05,
			"%s must sit forward of the backer to avoid z-fighting" % node_path
		)
		var bottom_y: float = _box_bottom_y(product)
		assert_gte(
			bottom_y,
			rail_top_y - SUPPORT_TOLERANCE,
			"%s bottom edge must rest on the shelf rail" % node_path
		)
		assert_lte(
			bottom_y,
			rail_top_y + SUPPORT_TOLERANCE,
			"%s must not float above the shelf rail" % node_path
		)
	root.free()


func test_store_store_visual_lighting_clears_readability_floor() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var main_fill: OmniLight3D = root.get_node_or_null(
		"ReadabilityProps/ZoneLighting/MainAisleWarmFill"
	) as OmniLight3D
	var checkout_fill: OmniLight3D = root.get_node_or_null(
		"ReadabilityProps/ZoneLighting/CheckoutAmberFill"
	) as OmniLight3D
	var shelf_fill: OmniLight3D = root.get_node_or_null(
		"ReadabilityProps/ZoneLighting/OldGenZoneFill"
	) as OmniLight3D
	assert_not_null(main_fill, "Main aisle fill light must exist")
	assert_not_null(checkout_fill, "Checkout fill light must exist")
	assert_not_null(shelf_fill, "Shelf fill light must exist")
	for fill: OmniLight3D in [main_fill, checkout_fill, shelf_fill]:
		if fill == null:
			continue
		assert_gte(
			fill.light_energy,
			ZONE_FILL_MIN_ENERGY,
			"%s must still reduce flat gray room wash" % fill.name,
		)
		assert_lte(
			fill.light_energy,
			ZONE_FILL_MAX_ENERGY,
			"%s must stay a subtle zone accent rather than debug paint" % fill.name,
		)
	root.free()


func test_checkout_counter_dressing_rests_on_counter_top() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var counter_top: MeshInstance3D = root.get_node_or_null(
		"Checkout/CounterTop"
	) as MeshInstance3D
	assert_not_null(counter_top, "Checkout/CounterTop must exist")
	if counter_top == null:
		root.free()
		return
	var counter_size: Vector3 = _box_world_size(counter_top)
	var counter_top_y: float = _box_top_y(counter_top)
	for node_path: String in [
		"ReadabilityProps/CheckoutCounterDressing/CounterReceiptSlipA",
		"ReadabilityProps/CheckoutCounterDressing/CounterReceiptSlipB",
		"ReadabilityProps/CheckoutCounterDressing/CounterImpulseDungeonDad",
		"ReadabilityProps/CheckoutCounterDressing/CounterImpulsePixelPets",
		"ReadabilityProps/CheckoutCounterDressing/CounterCardStack",
	]:
		var prop: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(prop, "Checkout dressing prop missing: %s" % node_path)
		if prop == null:
			continue
		var bottom_y: float = _box_bottom_y(prop)
		assert_gte(
			bottom_y,
			counter_top_y - SUPPORT_TOLERANCE,
			"%s must rest on the counter top instead of clipping below it" % node_path
		)
		assert_lte(
			bottom_y,
			counter_top_y + SUPPORT_TOLERANCE,
			"%s must not hover above the counter top" % node_path
		)
		assert_gte(
			_scene_position(prop).x,
			_scene_position(counter_top).x - counter_size.x * 0.5,
			"%s must stay within the checkout counter width" % node_path
		)
		assert_lte(
			_scene_position(prop).x,
			_scene_position(counter_top).x + counter_size.x * 0.5,
			"%s must stay within the checkout counter width" % node_path
		)
		assert_gte(
			_scene_position(prop).z,
			_scene_position(counter_top).z - counter_size.z * 0.5,
			"%s must stay within the checkout counter depth" % node_path
		)
		assert_lte(
			_scene_position(prop).z,
			_scene_position(counter_top).z + counter_size.z * 0.5,
			"%s must stay within the checkout counter depth" % node_path
		)
	root.free()


func test_checkout_anchor_has_required_register_and_transaction_props() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in CHECKOUT_ANCHOR_PROP_PATHS:
		assert_not_null(
			root.get_node_or_null(node_path),
			"Checkout anchor prop missing: %s" % node_path
		)
	root.free()


func test_checkout_anchor_new_counter_props_are_supported() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var counter_top: MeshInstance3D = root.get_node_or_null(
		"Checkout/CounterTop"
	) as MeshInstance3D
	assert_not_null(counter_top, "Checkout/CounterTop must exist")
	if counter_top == null:
		root.free()
		return
	var counter_top_y: float = _box_top_y(counter_top)
	for node_path: String in [
		"ReadabilityProps/CheckoutCounterDressing/RegisterGlowPlate",
		"ReadabilityProps/CheckoutCounterDressing/StorePolicyCard",
		"ReadabilityProps/CheckoutCounterDressing/TradeInFlyer",
		"ReadabilityProps/CheckoutCounterDressing/CoinTray",
		"ReadabilityProps/CheckoutCounterDressing/StickerRoll",
		"ReadabilityProps/CheckoutCounterDressing/CounterPen",
	]:
		var prop: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(prop, "Checkout prop missing: %s" % node_path)
		if prop == null:
			continue
		_assert_bottom_near_support(prop, counter_top_y, node_path)
	var service_mat: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/CheckoutCounterDressing/CustomerServiceSpotMat"
	) as MeshInstance3D
	assert_not_null(service_mat, "Customer service spot mat must exist")
	if service_mat != null:
		assert_gte(
			_box_bottom_y(service_mat),
			-0.01,
			"Customer service spot must sit on the customer-side floor"
		)
		assert_lte(
			_box_bottom_y(service_mat),
			0.05,
			"Customer service spot must not float above the customer-side floor"
		)
	root.free()


func test_checkout_queue_visuals_align_with_queue_markers() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in QUEUE_VISUAL_PROP_PATHS:
		assert_not_null(
			root.get_node_or_null(node_path),
			"Checkout queue visual missing: %s" % node_path
		)
	for i: int in range(3):
		var marker: Marker3D = root.get_node_or_null(
			"QueueMarker%d" % (i + 1)
		) as Marker3D
		var mat: MeshInstance3D = root.get_node_or_null(
			"FrontLaneQueue/LaneFixture/QueueMat%02d" % (i + 1)
		) as MeshInstance3D
		assert_not_null(marker, "Queue marker %d must exist" % (i + 1))
		assert_not_null(mat, "Queue mat %d must exist" % (i + 1))
		if marker == null or mat == null:
			continue
		assert_lte(
			absf(_scene_position(mat).x - _scene_position(marker).x),
			0.04,
			"Queue mat %d must align with marker X" % (i + 1)
		)
		assert_lte(
			absf(_scene_position(mat).z - _scene_position(marker).z),
			0.04,
			"Queue mat %d must align with marker Z" % (i + 1)
		)
	root.free()


func test_checkout_queue_reads_as_open_transaction_lane() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var checkout: Node3D = root.get_node_or_null("Checkout") as Node3D
	var lane: Node = root.get_node_or_null("FrontLaneQueue")
	assert_not_null(checkout, "Checkout must exist")
	assert_not_null(lane, "FrontLaneQueue must exist")
	if checkout == null or lane == null:
		root.free()
		return
	var marker_positions: Array[Vector3] = []
	for i: int in range(3):
		var marker: Marker3D = root.get_node_or_null(
			"QueueMarker%d" % (i + 1)
		) as Marker3D
		assert_not_null(marker, "Queue marker %d must exist" % (i + 1))
		if marker != null:
			marker_positions.append(_scene_position(marker))
	if marker_positions.size() == 3:
		assert_gt(
			marker_positions[0].distance_to(_scene_position(checkout)),
			0.6,
			"Active customer spot must sit on the customer side of the counter"
		)
		assert_lt(
			marker_positions[0].distance_to(_scene_position(checkout)),
			marker_positions[1].distance_to(_scene_position(checkout)),
			"QueueMarker1 must be closest to the register"
		)
		assert_lt(
			marker_positions[1].distance_to(_scene_position(checkout)),
			marker_positions[2].distance_to(_scene_position(checkout)),
			"Queue markers must advance toward the register in order"
		)
		assert_gt(
			marker_positions[0].x - marker_positions[2].x,
			1.5,
			"Queue lane must have a clear entry-to-register direction"
		)
	var post_count: int = _count_named_descendants(lane, "Post")
	assert_gte(
		post_count,
		4,
		"FrontLaneQueue must use visible stanchions to frame the customer line"
	)
	assert_null(
		root.get_node_or_null("FrontLaneQueue/QueuePrompt"),
		"Queue lane must not add a competing floating prompt"
	)
	root.free()


func test_checkout_queue_lane_does_not_add_interaction_surfaces() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var lane_fixture: Node = root.get_node_or_null("FrontLaneQueue/LaneFixture")
	assert_not_null(lane_fixture, "Reusable queue lane fixture must be instanced")
	if lane_fixture != null:
		assert_false(
			_has_area_descendant(lane_fixture),
			"Checkout queue lane must not add interaction areas"
		)
		for path: String in [
			"QueueMat01",
			"QueueMat02",
			"QueueMat03",
			"DirectionArrowShaft",
			"DirectionArrowHeadLeft",
			"DirectionArrowHeadRight",
			"LeftGuideRope",
			"RightGuideRope",
		]:
			var node: Node = lane_fixture.get_node_or_null(path)
			assert_not_null(node, "Queue lane cue missing: %s" % path)
			if node != null:
				assert_false(
					_has_collision_shape_descendant(node),
					"Queue lane cue %s must not add collision" % path
				)
	root.free()


func test_readability_props_remain_visual_only() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var readability_root: Node = root.get_node_or_null("ReadabilityProps")
	assert_not_null(readability_root, "ReadabilityProps must exist")
	if readability_root != null:
		assert_false(
			_has_collision_shape_descendant(readability_root),
			"Visual overhaul props must not add collision shapes"
		)
		assert_false(
			_has_area_descendant(readability_root),
			"Visual overhaul props must not add new interactable areas"
		)
	root.free()


func test_console_and_backroom_dressing_have_visible_support() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var support_pairs: Dictionary = {
		"ReadabilityProps/UsedConsoleDressing/ConsoleTowerA": "ConsoleShelf/ShelfBoard1",
		"ReadabilityProps/UsedConsoleDressing/ConsoleTowerB": "ConsoleShelf/ShelfBoard2",
		"ReadabilityProps/UsedConsoleDressing/ControllerBlockA": "ConsoleShelf/ShelfBoard1",
		"ReadabilityProps/UsedConsoleDressing/ControllerBlockB": "ConsoleShelf/ShelfBoard1",
		"ReadabilityProps/UsedConsoleDressing/CableRun": "ConsoleShelf/ShelfBoard1",
	}
	for prop_path: String in support_pairs.keys():
		var prop: MeshInstance3D = root.get_node_or_null(prop_path) as MeshInstance3D
		var support: MeshInstance3D = root.get_node_or_null(
			String(support_pairs[prop_path])
		) as MeshInstance3D
		assert_not_null(prop, "Used-console dressing prop missing: %s" % prop_path)
		assert_not_null(support, "Used-console support missing for %s" % prop_path)
		if prop == null or support == null:
			continue
		_assert_bottom_near_support(prop, _box_top_y(support), prop_path)
	for prop_path: String in [
		"ReadabilityProps/BackroomDressing/StockStackA",
		"ReadabilityProps/BackroomDressing/StockStackB",
		"ReadabilityProps/BackroomDressing/StockStackC",
	]:
		var stock: MeshInstance3D = root.get_node_or_null(prop_path) as MeshInstance3D
		assert_not_null(stock, "Backroom stock stack missing: %s" % prop_path)
		if stock == null:
			continue
		_assert_bottom_near_support(stock, 0.0, prop_path)
	root.free()


func test_used_console_department_has_fixture_stack_bin_and_cables() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in USED_CONSOLE_DEPARTMENT_PROP_PATHS:
		var prop: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(prop, "Used-console department prop missing: %s" % node_path)
		if prop != null:
			assert_not_null(prop.mesh, "%s must carry authored visual mesh" % node_path)
	root.free()


func test_used_console_department_has_condition_tags() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for tag_text: String in USED_CONSOLE_CONDITION_TAG_TEXT:
		var found: bool = false
		for child: Node in root.get_node("ReadabilityProps/UsedConsoleDressing").get_children():
			var label: Label3D = child as Label3D
			if label == null:
				continue
			if label.text == tag_text:
				found = true
				assert_false(label.double_sided, "%s condition tag must not mirror" % tag_text)
				assert_lte(
					label.pixel_size,
					0.0026,
					"%s condition tag must stay physical-card scale" % tag_text
				)
		assert_true(found, "Missing used-console condition tag: %s" % tag_text)
	root.free()


func test_used_console_department_has_platform_silhouettes_and_labels() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var found_labels: Dictionary = {}
	for node_path: String in USED_CONSOLE_SILHOUETTE_PATHS:
		var silhouette: Node = root.get_node_or_null(node_path)
		assert_not_null(silhouette, "Used-console platform silhouette missing: %s" % node_path)
		if silhouette == null:
			continue
		var mesh_count: int = _count_mesh_children(silhouette)
		assert_gte(
			mesh_count,
			4,
			"%s must be a multi-part prop, not a single generic box" % node_path
		)
		assert_gte(
			_count_distinct_surface_colors(silhouette),
			2,
			"%s must use at least two colors so platform identity reads" % node_path
		)
		var label: Label3D = silhouette.get_node_or_null("LabelText") as Label3D
		assert_not_null(label, "%s needs a small platform label card" % node_path)
		if label != null:
			found_labels[label.text] = true
	for label_text: String in USED_CONSOLE_PLATFORM_LABEL_TEXT:
		assert_true(
			found_labels.has(label_text),
			"Used-console platform label missing: %s" % label_text
		)
	root.free()


func test_used_console_department_has_distinct_controller_accessories() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in USED_CONSOLE_CONTROLLER_PATHS:
		var controller: Node = root.get_node_or_null(node_path)
		assert_not_null(controller, "Used-console controller/accessory missing: %s" % node_path)
		if controller != null:
			assert_gte(
				_count_mesh_children(controller),
				2,
				"%s must be a shaped controller/accessory assembly" % node_path
			)
	root.free()


func test_used_console_department_is_ordered_low_display_zone() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var shelf: Node3D = root.get_node_or_null("ConsoleShelf") as Node3D
	var deck: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/UsedConsoleDressing/UsedConsoleDisplayDeck"
	) as MeshInstance3D
	assert_not_null(shelf, "ConsoleShelf must remain the functional anchor")
	assert_not_null(deck, "UsedConsoleDisplayDeck must anchor the visual department")
	if shelf == null or deck == null:
		root.free()
		return
	var shelf_pos: Vector3 = _scene_position(shelf)
	var deck_pos: Vector3 = _scene_position(deck)
	assert_gt(
		deck_pos.z,
		shelf_pos.z,
		"Used-console display deck must sit in front of the right-wall shelf"
	)
	assert_lte(
		absf(deck_pos.x - shelf_pos.x),
		0.35,
		"Used-console display deck must stay visually tied to ConsoleShelf"
	)
	assert_lte(
		_box_world_size(deck).x,
		1.2,
		"Used-console display deck must stay a compact department fixture"
	)
	assert_lte(
		_box_world_size(deck).z,
		0.45,
		"Used-console display deck must not crowd the player path"
	)
	for node_path: String in [
		"ReadabilityProps/UsedConsoleDressing/NeoIgniteSilhouetteA",
		"ReadabilityProps/UsedConsoleDressing/CanopyWaveSilhouetteA",
		"ReadabilityProps/UsedConsoleDressing/VecForceHDSilhouetteA",
	]:
		var silhouette: Node3D = root.get_node_or_null(node_path) as Node3D
		assert_not_null(silhouette, "%s must exist" % node_path)
		if silhouette == null:
			continue
		assert_lt(
			_scene_position(silhouette).z,
			deck_pos.z - 0.08,
			"%s must read as a back-row console silhouette" % node_path
		)
	for node_path: String in [
		"ReadabilityProps/UsedConsoleDressing/WavePocketSilhouetteA",
		"ReadabilityProps/UsedConsoleDressing/IgniteGoSilhouetteA",
	]:
		var handheld: Node3D = root.get_node_or_null(node_path) as Node3D
		assert_not_null(handheld, "%s must exist" % node_path)
		if handheld == null:
			continue
		assert_gt(
			_scene_position(handheld).z,
			deck_pos.z + 0.08,
			"%s must read as a front-row handheld silhouette" % node_path
		)
	var controller_pairs: Dictionary = {
		"ReadabilityProps/UsedConsoleDressing/NeoIgniteSilhouetteA":
			"ReadabilityProps/UsedConsoleDressing/ControllerNeoIgniteA",
		"ReadabilityProps/UsedConsoleDressing/CanopyWaveSilhouetteA":
			"ReadabilityProps/UsedConsoleDressing/ControllerCanopyWaveA",
		"ReadabilityProps/UsedConsoleDressing/VecForceHDSilhouetteA":
			"ReadabilityProps/UsedConsoleDressing/ControllerVecForceHDA",
		"ReadabilityProps/UsedConsoleDressing/WavePocketSilhouetteA":
			"ReadabilityProps/UsedConsoleDressing/ControllerWavePocketA",
		"ReadabilityProps/UsedConsoleDressing/IgniteGoSilhouetteA":
			"ReadabilityProps/UsedConsoleDressing/ControllerIgniteGoA",
	}
	for silhouette_path: String in controller_pairs.keys():
		var silhouette: Node3D = root.get_node_or_null(silhouette_path) as Node3D
		var controller: Node3D = root.get_node_or_null(
			String(controller_pairs[silhouette_path])
		) as Node3D
		assert_not_null(silhouette, "%s must exist" % silhouette_path)
		assert_not_null(controller, "%s must exist" % controller_pairs[silhouette_path])
		if silhouette == null or controller == null:
			continue
		assert_lte(
			_xz_distance(_scene_position(silhouette), _scene_position(controller)),
			0.55,
			"%s must stay paired with its platform silhouette"
			% controller_pairs[silhouette_path]
		)
	for label_path: String in [
		"ReadabilityProps/UsedConsoleDressing/ConditionTagTested",
		"ReadabilityProps/UsedConsoleDressing/ConditionTagCleaned",
		"ReadabilityProps/UsedConsoleDressing/ConditionTagAsIs",
	]:
		var label: Label3D = root.get_node_or_null(label_path) as Label3D
		assert_not_null(label, "%s must exist" % label_path)
		if label == null:
			continue
		assert_lte(
			absf(_scene_position(label).y - deck_pos.y),
			0.10,
			"%s must read as a physical tag on the low display deck" % label_path
		)
	root.free()


func test_backroom_pickup_hotspot_has_receiving_bay_visual_anchor() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in BACKROOM_RECEIVING_BAY_PROP_PATHS:
		assert_not_null(
			root.get_node_or_null(node_path),
			"Backroom receiving-bay prop missing: %s" % node_path
		)
	var sign: Label3D = root.get_node_or_null(
		"ReadabilityProps/BackroomDressing/TodayDeliverySign"
	) as Label3D
	assert_not_null(sign, "TodayDeliverySign must be a physical Label3D")
	if sign != null:
		assert_eq(sign.text, "TODAY'S DELIVERY")
		assert_false(sign.double_sided, "TodayDeliverySign must not mirror from behind")
	var carton: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/BackroomDressing/ReceivingCartonStackA"
	) as MeshInstance3D
	var table: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/BackroomDressing/ReceivingTableTop"
	) as MeshInstance3D
	if carton != null:
		_assert_bottom_near_support(carton, 0.0, "ReceivingCartonStackA")
	if table != null:
		assert_gt(
			_box_bottom_y(table),
			0.45,
			"ReceivingTableTop must read as a table surface, not floor clutter"
		)
	var loading_mat_mesh: MeshInstance3D = root.get_node(
		"ReadabilityProps/BackroomDressing/LoadingZoneMat"
	) as MeshInstance3D
	var service_mat_mesh: MeshInstance3D = root.get_node(
		"ReadabilityProps/CheckoutCounterDressing/CustomerServiceSpotMat"
	) as MeshInstance3D
	var backroom_mat: StandardMaterial3D = loading_mat_mesh.get_surface_override_material(
		0
	) as StandardMaterial3D
	var checkout_mat: StandardMaterial3D = service_mat_mesh.get_surface_override_material(
		0
	) as StandardMaterial3D
	assert_not_null(backroom_mat, "LoadingZoneMat needs a stockroom material")
	assert_not_null(checkout_mat, "CustomerServiceSpotMat must keep checkout material")
	if backroom_mat != null and checkout_mat != null:
		assert_true(
			backroom_mat.albedo_color != checkout_mat.albedo_color,
			"Backroom loading mat must stay distinct from sales-floor service mats"
		)
	root.free()


func test_day_one_route_markers_are_floor_scale_details() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var markers: Node = root.get_node_or_null("ReadabilityProps/DayOneRouteMarkers")
	assert_not_null(markers, "DayOneRouteMarkers must exist")
	if markers == null:
		root.free()
		return
	for child: Node in markers.get_children():
		var marker: MeshInstance3D = child as MeshInstance3D
		if marker == null:
			continue
		var size: Vector3 = _box_world_size(marker)
		assert_gte(
			_box_bottom_y(marker),
			-0.01,
			"%s must sit on the floor, not below it" % marker.name
		)
		assert_lte(
			_box_bottom_y(marker),
			0.06,
			"%s must read as a floor detail, not a floating waypoint" % marker.name
		)
		assert_lte(
			maxf(size.x, size.z),
			FLOOR_DETAIL_MAX_AXIS,
			"%s must stay mat/decal sized instead of becoming a debug marker"
			% marker.name
		)
	root.free()


func test_spawn_view_main_floor_dressing_is_grounded_and_keeps_sightlines() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var floor_dressing: Node = root.get_node_or_null(
		"ReadabilityProps/SpawnViewFloorDressing"
	)
	assert_not_null(floor_dressing, "Spawn-view floor dressing must exist")
	if floor_dressing == null:
		root.free()
		return
	assert_false(
		_has_collision_shape_descendant(floor_dressing),
		"Spawn-view floor dressing must stay visual-only"
	)
	assert_false(
		_has_area_descendant(floor_dressing),
		"Spawn-view floor dressing must not add purchase or inventory interactions"
	)
	for node_path: String in SPAWN_VIEW_MAIN_FLOOR_PROP_PATHS:
		var prop: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(prop, "Spawn-view floor prop missing: %s" % node_path)
		if prop == null:
			continue
		assert_not_null(prop.mesh, "%s must carry authored mesh geometry" % node_path)
	for node_path: String in [
		"ReadabilityProps/SpawnViewFloorDressing/EntrySideMatLeft",
		"ReadabilityProps/SpawnViewFloorDressing/EntrySideMatRight",
		"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableLegFrontLeft",
		"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableLegFrontRight",
		"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableLegBackLeft",
		"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableLegBackRight",
		"ReadabilityProps/SpawnViewFloorDressing/SaleBasketA",
		"ReadabilityProps/SpawnViewFloorDressing/DisplayBinA",
		"ReadabilityProps/SpawnViewFloorDressing/CordCoilA",
		"ReadabilityProps/SpawnViewFloorDressing/CordTailA",
	]:
		var grounded: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		if grounded != null:
			_assert_bottom_near_support(grounded, 0.0, node_path)
	var table_top: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/SpawnViewFloorDressing/LowDisplayTableTop"
	) as MeshInstance3D
	assert_not_null(table_top, "LowDisplayTableTop must exist")
	if table_top != null:
		assert_lte(
			_box_top_y(table_top),
			0.62,
			"LowDisplayTableTop must stay low enough to preserve spawn sightlines"
		)
		for node_path: String in [
			"ReadabilityProps/SpawnViewFloorDressing/TableStackDungeonDad",
			"ReadabilityProps/SpawnViewFloorDressing/TableStackSpaceMall",
			"ReadabilityProps/SpawnViewFloorDressing/TableStackPixelPets",
		]:
			var table_product: MeshInstance3D = root.get_node_or_null(
				node_path
			) as MeshInstance3D
			if table_product != null:
				_assert_bottom_near_support(table_product, _box_top_y(table_top), node_path)
	var sale_basket: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/SpawnViewFloorDressing/SaleBasketA"
	) as MeshInstance3D
	if sale_basket != null:
		for node_path: String in [
			"ReadabilityProps/SpawnViewFloorDressing/SaleBasketCaseA",
			"ReadabilityProps/SpawnViewFloorDressing/SaleBasketCaseB",
		]:
			var basket_product: MeshInstance3D = root.get_node_or_null(
				node_path
			) as MeshInstance3D
			if basket_product != null:
				_assert_bottom_near_support(
					basket_product,
					_box_top_y(sale_basket),
					node_path
				)
	for node_path: String in SPAWN_VIEW_MAIN_FLOOR_PROP_PATHS:
		var prop: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		if prop == null:
			continue
		var position: Vector3 = _scene_position(prop)
		if node_path.ends_with("EntrySideMatLeft") or node_path.ends_with("EntrySideMatRight"):
			assert_between(
				position.x,
				-1.4,
				1.4,
				"%s must frame the entry threshold rather than drift into displays"
				% node_path,
			)
			assert_gt(
				position.z,
				7.7,
				"%s must stay inside the welcome-mat threshold band" % node_path,
			)
			continue
		assert_true(
			position.x <= -3.6 or position.x >= 5.8,
			"%s must stay in side floor dressing lanes, clear of the main path"
			% node_path
		)
	for marker_path: String in SPAWN_VIEW_CRITICAL_MARKERS:
		assert_not_null(
			root.get_node_or_null(marker_path),
			"Critical spawn-view marker must remain visible in scene: %s"
			% marker_path
		)
	root.free()


func test_wall_identity_bands_are_offset_from_walls() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in [
		"ReadabilityProps/ZoneIdentity/BackWallShelfWarmBand",
		"ReadabilityProps/ZoneIdentity/BackWallGamesWarmBand",
	]:
		var band: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(band, "Wall identity band missing: %s" % node_path)
		if band != null:
			assert_gt(
				_scene_position(band).z,
				-9.98,
				"%s must be offset into the room to avoid wall z-fighting" % node_path
			)
	var left_band: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/ZoneIdentity/LeftWallTestingCoolBand"
	) as MeshInstance3D
	assert_not_null(left_band, "LeftWallTestingCoolBand must exist")
	if left_band != null:
		assert_gt(
			_scene_position(left_band).x,
			-7.98,
			"LeftWallTestingCoolBand must be offset into the room to avoid wall z-fighting"
		)
	root.free()


func test_wall_accent_bands_are_split_zone_runs_not_full_room_stripes() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in [
		"ReadabilityProps/ZoneIdentity/BackWallShelfWarmBand",
		"ReadabilityProps/ZoneIdentity/BackWallGamesWarmBand",
		"ReadabilityProps/ZoneIdentity/LeftWallTestingCoolBand",
		"ReadabilityProps/ZoneIdentity/RightWallConsoleCoolBand",
		"ReadabilityProps/ZoneIdentity/BackroomServiceUtilityBand",
	]:
		var band: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(band, "Wall accent missing: %s" % node_path)
		if band == null:
			continue
		var size: Vector3 = _box_world_size(band)
		var longest_axis: float = maxf(maxf(size.x, size.y), size.z)
		assert_lte(
			longest_axis,
			7.2,
			"%s must stay a split zone accent, not a full-room stripe"
			% node_path
		)
	root.free()


func test_zone_wall_bands_use_limited_distinct_palette() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var colors: Dictionary = {}
	for node_path: String in [
		"ReadabilityProps/ZoneIdentity/BackWallShelfWarmBand",
		"ReadabilityProps/ZoneIdentity/BackWallGamesWarmBand",
		"ReadabilityProps/ZoneIdentity/LeftWallTestingCoolBand",
		"ReadabilityProps/ZoneIdentity/RightWallConsoleCoolBand",
		"ReadabilityProps/ZoneIdentity/BackroomServiceUtilityBand",
	]:
		var mat: StandardMaterial3D = _standard_material_at(root, node_path)
		assert_not_null(mat, "%s must carry a StandardMaterial3D" % node_path)
		if mat == null:
			continue
		colors[str(mat.albedo_color)] = true
	assert_between(
		colors.size(),
		3,
		5,
		"Wall identity bands must share a limited palette without collapsing to one color",
	)
	root.free()


func test_layout_floor_seams_are_not_visible_route_paint() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var seams: Node3D = root.get_node_or_null("AisleSeams") as Node3D
	assert_not_null(seams, "AisleSeams authoring hook must exist")
	if seams != null:
		assert_false(
			_is_visible_in_tree(root, seams),
			"Aisle seam guide strips must stay hidden so the room does not read as route paint",
		)
	root.free()


func test_store_store_removes_floating_unanchored_zone_signs() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in [
		"ZoneLabels/CheckoutBacking",
		"ZoneLabels/CheckoutLabel",
		"ZoneLabels/ExitBacking",
		"ZoneLabels/ExitLabel",
		"ZoneLabels/TradeInsBacking",
		"ZoneLabels/TradeInsLabel",
		"ZoneLabels/CloseDayBacking",
		"ZoneLabels/CloseDayLabel",
	]:
		var node: Node3D = root.get_node_or_null(node_path) as Node3D
		assert_not_null(node, "Expected optional sign node %s" % node_path)
		if node != null:
			assert_false(
				node.visible,
				"%s must stay hidden until it has a physical fixture anchor" % node_path
			)
	root.free()


func test_product_wall_posters_stay_hidden_until_physically_anchored() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	for node_path: String in [
		"ReadabilityProps/WallPosters/WallPosterA",
		"ReadabilityProps/WallPosters/WallPosterB",
		"ReadabilityProps/WallPosters/WallPosterC",
		"ReadabilityProps/WallPosters/WallPosterD",
	]:
		var node: Node3D = root.get_node_or_null(node_path) as Node3D
		assert_not_null(node, "Expected product poster node %s" % node_path)
		if node != null:
			assert_false(
				node.visible,
				"%s must stay hidden; named products should sit on rails or shelves"
				% node_path
			)
	root.free()


func test_backroom_entry_reads_as_service_bay_not_tiny_closet() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var left_wall: Node3D = root.get_node_or_null(
		"BetaBackroomWallFrontLeft"
	) as Node3D
	var right_wall: Node3D = root.get_node_or_null(
		"BetaBackroomWallFrontRight"
	) as Node3D
	var floor_mat: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/ZoneIdentity/BackroomFloorMat"
	) as MeshInstance3D
	assert_not_null(left_wall, "Backroom left front partition must exist")
	assert_not_null(right_wall, "Backroom right front partition must exist")
	assert_not_null(floor_mat, "Backroom floor mat must mark the service bay")
	if left_wall != null and right_wall != null:
		var left_mesh: MeshInstance3D = left_wall.get_node_or_null(
			"WallMesh"
		) as MeshInstance3D
		var right_mesh: MeshInstance3D = right_wall.get_node_or_null(
			"WallMesh"
		) as MeshInstance3D
		assert_not_null(left_mesh, "Backroom left front partition needs a mesh")
		assert_not_null(right_mesh, "Backroom right front partition needs a mesh")
		if left_mesh != null and right_mesh != null:
			var left_box: BoxMesh = left_mesh.mesh as BoxMesh
			var right_box: BoxMesh = right_mesh.mesh as BoxMesh
			assert_not_null(left_box, "Left partition must use a BoxMesh")
			assert_not_null(right_box, "Right partition must use a BoxMesh")
			if left_box != null and right_box != null:
				var left_edge: float = left_wall.position.x + left_box.size.x * 0.5
				var right_edge: float = right_wall.position.x - right_box.size.x * 0.5
				assert_gte(
					right_edge - left_edge,
					BACKROOM_MIN_DOORWAY_WIDTH,
					"Backroom doorway must stay wide enough to read as a service bay"
				)
	root.free()


func test_side_wall_used_consoles_label_is_not_backside_mirrored() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var label: Label3D = root.get_node_or_null(
		"ZoneLabels/UsedConsolesLabel"
	) as Label3D
	assert_not_null(label, "UsedConsolesLabel must exist")
	if label != null:
		assert_false(
			label.double_sided,
			"UsedConsolesLabel must not render mirrored on its backside"
		)
	root.free()


func test_ceiling_practicals_are_retail_scale_not_giant_planes() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var practical: MeshInstance3D = root.get_node_or_null(
		"ReadabilityProps/ZoneIdentity/CheckoutCeilingPractical"
	) as MeshInstance3D
	assert_not_null(practical, "Checkout ceiling practical must exist")
	if practical == null:
		root.free()
		return
	var mesh: BoxMesh = practical.mesh as BoxMesh
	assert_not_null(mesh, "Ceiling practical must use the shared BoxMesh")
	if mesh != null:
		assert_lte(
			mesh.size.x,
			0.9,
			"Ceiling practicals must stay small enough to read as fixtures"
		)
	var mat: StandardMaterial3D = practical.get_surface_override_material(
		0
	) as StandardMaterial3D
	assert_not_null(mat, "Ceiling practical must carry a StandardMaterial3D")
	if mat != null:
		assert_lte(
			mat.emission_energy_multiplier,
			0.55,
			"Ceiling practicals must not bloom into oversized flat yellow planes"
		)
	root.free()


func test_ceiling_practicals_have_low_poly_mounting_geometry() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	if root == null:
		return
	var mounted_practicals: Dictionary = {
		"ReadabilityProps/ZoneIdentity/CheckoutCeilingPractical":
			"ReadabilityProps/ZoneIdentity/CheckoutCeilingMount",
		"ReadabilityProps/ZoneIdentity/AisleCeilingPractical":
			"ReadabilityProps/ZoneIdentity/AisleCeilingMount",
		"ReadabilityProps/ZoneIdentity/ShelfCeilingPractical":
			"ReadabilityProps/ZoneIdentity/ShelfCeilingMount",
		"ReadabilityProps/ZoneIdentity/BackroomCeilingPractical":
			"ReadabilityProps/ZoneIdentity/BackroomCeilingMount",
		"ReadabilityProps/ZoneIdentity/EntryCeilingPractical":
			"ReadabilityProps/ZoneIdentity/EntryCeilingMount",
	}
	for practical_path: String in mounted_practicals.keys():
		var practical: MeshInstance3D = root.get_node_or_null(
			practical_path
		) as MeshInstance3D
		var mount: MeshInstance3D = root.get_node_or_null(
			String(mounted_practicals[practical_path])
		) as MeshInstance3D
		assert_not_null(practical, "Ceiling practical missing: %s" % practical_path)
		assert_not_null(mount, "Ceiling mount missing for %s" % practical_path)
		if practical == null or mount == null:
			continue
		assert_gte(
			_box_bottom_y(mount),
			_box_top_y(practical) - 0.02,
			"%s mount must sit above the practical body" % practical_path
		)
		assert_lte(
			_box_top_y(mount),
			RETAIL_CEILING_Y,
			"%s mount must stay tucked under the ceiling plane" % practical_path
		)
	root.free()


func _collect_group_nodes(root: Node, group_name: StringName, out: Array[Node]) -> void:
	if root.is_in_group(group_name):
		out.append(root)
	for child: Node in root.get_children():
		_collect_group_nodes(child, group_name, out)


func _has_collision_shape_descendant(root: Node) -> bool:
	for child: Node in root.get_children():
		if child is CollisionShape3D:
			return true
		if _has_collision_shape_descendant(child):
			return true
	return false


func _has_area_descendant(root: Node) -> bool:
	for child: Node in root.get_children():
		if child is Area3D:
			return true
		if _has_area_descendant(child):
			return true
	return false


func _count_named_descendants(root: Node, suffix: String) -> int:
	var count: int = 0
	for child: Node in root.get_children():
		if String(child.name).ends_with(suffix):
			count += 1
		count += _count_named_descendants(child, suffix)
	return count


func _box_world_size(mesh_inst: MeshInstance3D) -> Vector3:
	var box: BoxMesh = mesh_inst.mesh as BoxMesh
	if box == null:
		return Vector3.ZERO
	var basis_scale: Vector3 = _scene_transform(mesh_inst).basis.get_scale()
	return Vector3(
		box.size.x * absf(basis_scale.x),
		box.size.y * absf(basis_scale.y),
		box.size.z * absf(basis_scale.z),
	)


func _box_bottom_y(mesh_inst: MeshInstance3D) -> float:
	return _scene_position(mesh_inst).y - _box_world_size(mesh_inst).y * 0.5


func _box_top_y(mesh_inst: MeshInstance3D) -> float:
	return _scene_position(mesh_inst).y + _box_world_size(mesh_inst).y * 0.5


func _scene_position(node: Node3D) -> Vector3:
	return _scene_transform(node).origin


func _scene_transform(node: Node3D) -> Transform3D:
	var scene_transform: Transform3D = node.transform
	var cursor: Node = node.get_parent()
	while cursor is Node3D:
		scene_transform = (cursor as Node3D).transform * scene_transform
		cursor = cursor.get_parent()
	return scene_transform


func _xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func _assert_bottom_near_support(
	mesh_inst: MeshInstance3D,
	support_y: float,
	node_path: String,
) -> void:
	var bottom_y: float = _box_bottom_y(mesh_inst)
	assert_gte(
		bottom_y,
		support_y - SUPPORT_TOLERANCE,
		"%s must not clip below its support surface" % node_path
	)
	assert_lte(
		bottom_y,
		support_y + SUPPORT_TOLERANCE,
		"%s must not float above its support surface" % node_path
	)


func _count_mesh_children(root: Node) -> int:
	var count: int = 0
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			count += 1
	return count


func _count_distinct_surface_colors(root: Node) -> int:
	var colors: Dictionary = {}
	for child: Node in root.get_children():
		var mesh_inst: MeshInstance3D = child as MeshInstance3D
		if mesh_inst == null:
			continue
		var mat: StandardMaterial3D = mesh_inst.get_surface_override_material(
			0
		) as StandardMaterial3D
		if mat == null:
			continue
		colors[str(mat.albedo_color)] = true
	return colors.size()


func _standard_material_at(root: Node, node_path: String) -> StandardMaterial3D:
	var mesh_inst: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
	if mesh_inst == null:
		return null
	return mesh_inst.get_surface_override_material(0) as StandardMaterial3D


func _is_visible_in_tree(root: Node, node: Node3D) -> bool:
	var cursor: Node = node
	while cursor != null and cursor != root:
		if cursor is Node3D and not (cursor as Node3D).visible:
			return false
		cursor = cursor.get_parent()
	return node.visible


func _is_sales_floor_palette_color(color: Color) -> bool:
	return (
		_is_warm_wood_or_brown(color)
		or _is_cream(color)
		or _is_dark_metal(color)
		or _is_muted_purple(color)
		or _is_muted_teal(color)
		or _is_amber(color)
	)


func _is_stockroom_utility_color(color: Color) -> bool:
	var value: float = maxf(maxf(color.r, color.g), color.b)
	return (
		color.b >= color.g
		and color.g >= color.r
		and value <= 0.70
		and color.b - color.r <= 0.24
	)


func _is_warm_wood_or_brown(color: Color) -> bool:
	return (
		color.r >= color.g
		and color.g >= color.b
		and color.r >= 0.20
		and color.r <= 0.86
		and color.g <= 0.66
		and color.b <= 0.50
	)


func _is_cream(color: Color) -> bool:
	return (
		color.r >= 0.68
		and color.g >= 0.58
		and color.b >= 0.42
		and color.r >= color.b
	)


func _is_dark_metal(color: Color) -> bool:
	return (
		maxf(maxf(color.r, color.g), color.b) <= 0.24
		and absf(color.r - color.g) <= 0.08
		and absf(color.g - color.b) <= 0.08
	)


func _is_muted_purple(color: Color) -> bool:
	return (
		color.b >= color.r
		and color.r >= color.g
		and color.b <= 0.46
		and color.r >= 0.10
	)


func _is_muted_teal(color: Color) -> bool:
	return (
		color.g >= color.r
		and color.b >= color.r
		and color.g <= 0.32
		and color.b <= 0.34
		and absf(color.g - color.b) <= 0.12
	)


func _is_amber(color: Color) -> bool:
	return (
		color.r >= 0.55
		and color.g >= 0.28
		and color.g <= 0.62
		and color.b <= 0.32
	)
