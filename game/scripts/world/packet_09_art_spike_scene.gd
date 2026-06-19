extends Node3D
class_name Packet09ArtSpikeScene

const HERO_CAMERA_PATH := "BenchmarkCameras/InsideOutHeroCamera"
const SECONDARY_CAMERA_PATH := "BenchmarkCameras/ShelfDensityCamera"
const STOREFRONT_CAMERA_PATH := "BenchmarkCameras/StorefrontFrameCamera"

var _materials: Dictionary = {}
var _cover_materials: Array[StandardMaterial3D] = []


func _ready() -> void:
	if has_node("Packet09ArtRoot"):
		return

	_build_materials()
	_build_scene()


func reference_rules() -> PackedStringArray:
	return PackedStringArray([
		"inspiration: small-chain mall storefront, glass rhythm, fascia, corridor frame",
		"new_real_inspiration: quiet walls, drop ceiling, slatwall, empty retail capacity, restrained starter stock",
		"owner_review: less text, less color, no random wall clutter, stronger shopfit materials",
		"owner_review: pre-day-one store starts empty-ish; player sets up two games, one console, one accessory",
		"packet_09: inside-looking-out proof shot, no customers, no debug labels",
	])


func _build_scene() -> void:
	var root := Node3D.new()
	root.name = "Packet09ArtRoot"
	add_child(root)

	var rules := Node.new()
	rules.name = "ReferenceRuleMarkers"
	rules.set_meta("source_folders", PackedStringArray(["inspiration", "new_real_inspiration"]))
	rules.set_meta("visual_rules", reference_rules())
	root.add_child(rules)

	_build_lighting(root)
	_build_shell(root)
	_build_mall_corridor(root)
	_build_storefront(root)
	_build_drop_ceiling(root)
	_build_slatwall_product_bay(root)
	_build_counter_display_case(root)
	_build_attached_signage(root)
	_build_cameras(root)


func _build_lighting(root: Node3D) -> void:
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.55, 0.57, 0.55)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.73, 0.69)
	environment.ambient_light_energy = 0.96
	world.environment = environment
	root.add_child(world)

	var store_light := DirectionalLight3D.new()
	store_light.name = "SoftStoreDirectionLight"
	store_light.light_energy = 0.48
	store_light.rotation_degrees = Vector3(-48.0, -20.0, 0.0)
	root.add_child(store_light)

	for index in range(4):
		var light := OmniLight3D.new()
		light.name = "WarmFluorescentFill%02d" % [index + 1]
		light.light_color = Color(1.0, 0.93, 0.78)
		light.light_energy = 0.72
		light.omni_range = 4.8
		light.position = Vector3(-2.7 + float(index) * 1.8, 2.35, -0.8 + float(index % 2) * 2.2)
		root.add_child(light)


func _build_shell(root: Node3D) -> void:
	var shell := Node3D.new()
	shell.name = "InteriorFirstFifteenFeet"
	root.add_child(shell)

	_box(shell, "StoreCarpetField", Vector3(0.0, -0.035, 1.2), Vector3(7.45, 0.06, 6.9), _materials.carpet)
	_box(shell, "EntryTileInset", Vector3(0.0, -0.02, -1.42), Vector3(6.9, 0.07, 1.35), _materials.store_tile)
	for x in [-3.08, -1.54, 0.0, 1.54, 3.08]:
		_box(shell, "EntryTileGroutX%02d" % int((x + 3.08) * 10.0), Vector3(x, 0.018, -1.42), Vector3(0.025, 0.02, 1.35), _materials.grout)
	for z in [-1.86, -1.42, -0.98]:
		_box(shell, "EntryTileGroutZ%02d" % int((z + 2.0) * 100.0), Vector3(0.0, 0.02, z), Vector3(6.9, 0.02, 0.025), _materials.grout)

	_box(shell, "LeftPaintedWall", Vector3(-3.76, 1.28, 1.08), Vector3(0.10, 2.56, 6.72), _materials.wall_warm)
	_box(shell, "RightPaintedWall", Vector3(3.76, 1.28, 1.08), Vector3(0.10, 2.56, 6.72), _materials.wall_warm)
	_box(shell, "BackSlatwallBase", Vector3(0.0, 1.24, 4.46), Vector3(7.45, 2.48, 0.11), _materials.slatwall)
	_box(shell, "BackWallBaseboard", Vector3(0.0, 0.19, 4.34), Vector3(7.45, 0.22, 0.09), _materials.dark_laminate)
	_box(shell, "LeftWallBaseboard", Vector3(-3.69, 0.19, 1.0), Vector3(0.09, 0.22, 6.4), _materials.dark_laminate)
	_box(shell, "RightWallBaseboard", Vector3(3.69, 0.19, 1.0), Vector3(0.09, 0.22, 6.4), _materials.dark_laminate)

	for y in [0.54, 0.74, 0.94, 1.14, 1.34, 1.54, 1.74, 1.94, 2.14]:
		_box(shell, "BackSlatwallHorizontalGroove%03d" % int(y * 100.0), Vector3(0.0, y, 4.385), Vector3(7.35, 0.022, 0.05), _materials.slat_shadow)
		_box(shell, "LeftWallShopfitRail%03d" % int(y * 100.0), Vector3(-3.69, y, 1.0), Vector3(0.07, 0.025, 6.25), _materials.slat_shadow)
		_box(shell, "RightWallShopfitRail%03d" % int(y * 100.0), Vector3(3.69, y, 1.0), Vector3(0.07, 0.025, 6.25), _materials.slat_shadow)

	for x in [-2.8, -1.4, 0.0, 1.4, 2.8]:
		_box(shell, "BackWallSlatSeam%02d" % int((x + 2.8) * 10.0), Vector3(x, 1.24, 4.315), Vector3(0.035, 2.1, 0.06), _materials.slat_shadow)


func _build_mall_corridor(root: Node3D) -> void:
	var mall := Node3D.new()
	mall.name = "MallCorridorVisibleThroughGlass"
	root.add_child(mall)

	_box(mall, "MallTileFloor", Vector3(0.0, -0.045, -5.9), Vector3(10.6, 0.05, 7.4), _materials.mall_tile)
	for x in [-4.8, -3.2, -1.6, 0.0, 1.6, 3.2, 4.8]:
		_box(mall, "MallTileGroutX%02d" % int((x + 4.8) * 10.0), Vector3(x, 0.0, -5.9), Vector3(0.028, 0.02, 7.25), _materials.grout)
	for z in [-8.5, -7.1, -5.7, -4.3, -2.9]:
		_box(mall, "MallTileGroutZ%02d" % int((z + 9.0) * 10.0), Vector3(0.0, 0.002, z), Vector3(10.4, 0.02, 0.028), _materials.grout)

	_box(mall, "OppositeMallWall", Vector3(0.0, 1.32, -8.95), Vector3(10.6, 2.65, 0.12), _materials.mall_wall)
	_box(mall, "NeighborStoreLeftVoid", Vector3(-4.15, 1.05, -6.55), Vector3(1.4, 2.1, 0.12), _materials.black_glass)
	_box(mall, "NeighborStoreRightVoid", Vector3(4.15, 1.05, -6.55), Vector3(1.4, 2.1, 0.12), _materials.black_glass)
	_box(mall, "NeighborLeftLightboxStrip", Vector3(-4.15, 2.18, -6.48), Vector3(1.45, 0.08, 0.08), _materials.warm_lightbox)
	_box(mall, "NeighborRightLightboxStrip", Vector3(4.15, 2.18, -6.48), Vector3(1.45, 0.08, 0.08), _materials.warm_lightbox)
	_box(mall, "MallBenchSeat", Vector3(-2.2, 0.42, -6.1), Vector3(1.22, 0.14, 0.36), _materials.wood)
	_box(mall, "MallBenchLeftLeg", Vector3(-2.72, 0.22, -6.1), Vector3(0.12, 0.42, 0.12), _materials.dark_metal)
	_box(mall, "MallBenchRightLeg", Vector3(-1.68, 0.22, -6.1), Vector3(0.12, 0.42, 0.12), _materials.dark_metal)
	_box(mall, "MallDirectoryKiosk", Vector3(2.0, 0.82, -5.78), Vector3(0.38, 1.65, 0.18), _materials.directory_blue)
	_box(mall, "MallDirectoryScreen", Vector3(2.0, 1.18, -5.66), Vector3(0.32, 0.54, 0.035), _materials.warm_lightbox)


func _build_storefront(root: Node3D) -> void:
	var storefront := Node3D.new()
	storefront.name = "StorefrontGlassSystem"
	root.add_child(storefront)

	_box(storefront, "ChunkyStorefrontFascia", Vector3(0.0, 2.48, -2.2), Vector3(7.78, 0.36, 0.30), _materials.dark_blue)
	_box(storefront, "BacklitGames4UFasciaPanel", Vector3(0.0, 2.49, -2.39), Vector3(2.65, 0.44, 0.055), _materials.sign_cream)
	_sign_panel(storefront, "ExteriorGames4USignBitmap", "GAMES4U", Vector3(0.0, 2.49, -2.435), Vector3(0.0, 0.0, 0.0), Vector2(2.25, 0.32), _materials.sign_cream, _materials.dark_blue)
	_box(storefront, "InteriorFacingGames4USignPanel", Vector3(0.0, 2.48, -2.04), Vector3(2.85, 0.46, 0.04), _materials.sign_cream)
	_sign_panel(storefront, "InteriorGames4USignBitmap", "GAMES4U", Vector3(0.0, 2.48, -1.995), Vector3(0.0, 0.0, 0.0), Vector2(2.35, 0.32), _materials.sign_cream, _materials.dark_blue)
	_box(storefront, "StorefrontWarmTrim", Vector3(0.0, 2.75, -2.36), Vector3(7.65, 0.045, 0.055), _materials.warm_lightbox)
	_box(storefront, "LowerStorefrontKickPlate", Vector3(0.0, 0.18, -2.2), Vector3(7.74, 0.36, 0.22), _materials.dark_metal)

	for x in [-3.72, -2.24, -0.74, 0.74, 2.24, 3.72]:
		_box(storefront, "StorefrontMullion%02d" % int((x + 4.0) * 10.0), Vector3(x, 1.28, -2.22), Vector3(0.075, 2.52, 0.13), _materials.dark_metal)
	for y in [0.72, 1.56, 2.2]:
		_box(storefront, "StorefrontHorizontalMullion%02d" % int(y * 100.0), Vector3(0.0, y, -2.23), Vector3(7.72, 0.065, 0.13), _materials.dark_metal)

	for x in [-2.98, -1.49, 1.49, 2.98]:
		_box(storefront, "StorefrontGlassPane%02d" % int((x + 3.0) * 10.0), Vector3(x, 1.36, -2.285), Vector3(1.32, 1.62, 0.025), _materials.glass)

	var door := Node3D.new()
	door.name = "FramedOpenGlassDoor"
	door.position = Vector3(-0.32, 0.0, -2.24)
	door.rotation_degrees = Vector3(0.0, -13.0, 0.0)
	storefront.add_child(door)
	_box(door, "OpenDoorGlassPane", Vector3(0.0, 1.23, -0.04), Vector3(1.03, 1.78, 0.025), _materials.glass)
	_box(door, "OpenDoorTopRail", Vector3(0.0, 2.15, -0.02), Vector3(1.12, 0.08, 0.09), _materials.dark_metal)
	_box(door, "OpenDoorBottomRail", Vector3(0.0, 0.32, -0.02), Vector3(1.12, 0.08, 0.09), _materials.dark_metal)
	_box(door, "OpenDoorLeftRail", Vector3(-0.56, 1.23, -0.02), Vector3(0.08, 1.86, 0.09), _materials.dark_metal)
	_box(door, "OpenDoorRightRail", Vector3(0.56, 1.23, -0.02), Vector3(0.08, 1.86, 0.09), _materials.dark_metal)
	_box(door, "OpenDoorPullHandle", Vector3(0.42, 1.13, -0.085), Vector3(0.06, 0.72, 0.075), _materials.handle_metal)

	_box(storefront, "SmallOpenPlacardOnDoor", Vector3(0.58, 1.64, -2.43), Vector3(0.42, 0.18, 0.035), _materials.sign_cream)
	_sign_panel(storefront, "OpenSignBitmap", "OPEN", Vector3(0.58, 1.64, -2.47), Vector3(0.0, 0.0, 0.0), Vector2(0.34, 0.10), _materials.sign_cream, _materials.dark_blue)


func _build_drop_ceiling(root: Node3D) -> void:
	var ceiling := Node3D.new()
	ceiling.name = "DropCeilingGridWithFluorescents"
	root.add_child(ceiling)

	_box(ceiling, "AcousticCeilingField", Vector3(0.0, 2.78, 1.0), Vector3(7.55, 0.07, 6.8), _materials.ceiling_tile)
	for x in [-3.0, -1.5, 0.0, 1.5, 3.0]:
		_box(ceiling, "CeilingGridRunnerX%02d" % int((x + 3.0) * 10.0), Vector3(x, 2.72, 1.0), Vector3(0.035, 0.06, 6.7), _materials.ceiling_grid)
	for z in [-1.75, -0.45, 0.85, 2.15, 3.45]:
		_box(ceiling, "CeilingGridRunnerZ%02d" % int((z + 2.0) * 100.0), Vector3(0.0, 2.715, z), Vector3(7.45, 0.06, 0.035), _materials.ceiling_grid)

	for index in range(5):
		var x := -2.4 + float(index % 3) * 2.4
		var z := -0.9 + float(index / 3) * 2.4
		_box(ceiling, "FluorescentDiffuser%02d" % [index + 1], Vector3(x, 2.675, z), Vector3(1.05, 0.045, 0.34), _materials.fluorescent)
		_box(ceiling, "FluorescentFixtureLip%02d" % [index + 1], Vector3(x, 2.69, z), Vector3(1.22, 0.035, 0.48), _materials.ceiling_grid)


func _build_slatwall_product_bay(root: Node3D) -> void:
	var bay := Node3D.new()
	bay.name = "SlatwallStarterSetupBayEmptyRails"
	root.add_child(bay)

	_box(bay, "RightWallSlatwallPanel", Vector3(3.66, 1.34, 0.85), Vector3(0.08, 2.18, 4.5), _materials.slatwall)
	for rail in range(11):
		var y := 0.42 + float(rail) * 0.17
		_box(bay, "RightWallSlatwallGroove%02d" % [rail + 1], Vector3(3.565, y, 0.85), Vector3(0.07, 0.018, 4.35), _materials.slat_shadow)
	for z_index in range(9):
		var z := -1.08 + float(z_index) * 0.48
		_rod_x(bay, "RightWallRoundedShelfBracket%02dA" % [z_index + 1], Vector3(3.42, 0.64 + float(z_index % 4) * 0.37, z - 0.64), 0.018, 0.30, _materials.dark_metal)
		_rod_x(bay, "RightWallRoundedShelfBracket%02dB" % [z_index + 1], Vector3(3.42, 0.64 + float(z_index % 4) * 0.37, z + 0.64), 0.018, 0.30, _materials.dark_metal)

	for shelf in range(4):
		var y := 0.72 + float(shelf) * 0.38
		_box(bay, "RightWallAcrylicShelf%02d" % [shelf + 1], Vector3(3.35, y, -0.05 + float(shelf) * 0.18), Vector3(0.42, 0.04, 3.25), _materials.acrylic)
		_box(bay, "RightWallShelfHeaderRailPanel%02d" % [shelf + 1], Vector3(3.15, y + 0.19, -0.06 + float(shelf) * 0.18), Vector3(0.04, 0.06, 3.05), _materials.shelf_label_rail)
		_rod_z(bay, "RightWallRoundedShelfFrontRail%02d" % [shelf + 1], Vector3(3.10, y + 0.04, -0.06 + float(shelf) * 0.18), 0.018, 3.22, _materials.dark_metal)

	for shelf in range(4):
		for row in range(2):
			for slot in range(10):
				var y := 0.83 + float(shelf) * 0.38 + float(row) * 0.115
				var z := -1.17 + float(slot) * 0.265
				if _is_day_one_starter_game_slot(shelf, row, slot):
					var mat := _cover_materials[(shelf * 20 + row * 10 + slot) % _cover_materials.size()]
					var game := _starter_game_case(bay, "StarterGameCaseS%02dR%02dN%02d" % [shelf + 1, row + 1, slot + 1], Vector3(3.12, y, z), mat, shelf + slot)
					game.rotation_degrees = Vector3(0.0, -0.3 + float(slot) * 0.2, 0.0)
				else:
					_rod_y(bay, "EmptyShelfSlotGuideS%02dR%02dN%02d" % [shelf + 1, row + 1, slot + 1], Vector3(3.102, y - 0.09, z), 0.010, 0.10, _materials.empty_slot_shadow)

	var left_gondola := Node3D.new()
	left_gondola.name = "LowGondolaCaseRun"
	left_gondola.position = Vector3(-2.35, 0.0, -0.18)
	left_gondola.rotation_degrees = Vector3(0.0, 5.0, 0.0)
	bay.add_child(left_gondola)
	_box(left_gondola, "GondolaLaminateBase", Vector3(0.0, 0.33, 0.0), Vector3(1.4, 0.66, 2.15), _materials.dark_laminate)
	_rod_z(left_gondola, "GondolaWireRackBackTopRoundedRail", Vector3(0.0, 1.26, 0.0), 0.025, 2.0, _materials.dark_metal)
	_rod_z(left_gondola, "GondolaWireRackBackMidRoundedRail", Vector3(0.0, 0.98, 0.0), 0.018, 2.0, _materials.dark_metal)
	_rod_z(left_gondola, "GondolaWireRackBackBottomRoundedRail", Vector3(0.0, 0.74, 0.0), 0.018, 2.0, _materials.dark_metal)
	for rack_post in [-0.62, 0.0, 0.62]:
		_rod_y(left_gondola, "GondolaWireRackRoundedPost%02d" % int((rack_post + 0.7) * 100.0), Vector3(rack_post, 0.98, -0.98), 0.018, 0.68, _materials.dark_metal)
	for slot in range(8):
		var z := -0.84 + float(slot) * 0.22
		_rod_x(left_gondola, "EmptyGondolaSlotGuide%02d" % [slot + 1], Vector3(-0.44 + float(slot % 2) * 0.88, 0.93, z), 0.012, 0.32, _materials.empty_slot_shadow)
	_box(left_gondola, "StarterConsoleBoxForSetup", Vector3(-0.38, 0.98, -0.38), Vector3(0.46, 0.28, 0.34), _materials.console_box)
	_box(left_gondola, "StarterConsoleBoxFaceStripe", Vector3(-0.38, 1.06, -0.565), Vector3(0.36, 0.065, 0.028), _materials.shelf_label_rail)
	_box(left_gondola, "StarterAccessoryBoxForSetup", Vector3(0.42, 0.94, 0.12), Vector3(0.28, 0.21, 0.22), _materials.accessory_box)
	_box(left_gondola, "StarterAccessoryHangTab", Vector3(0.42, 1.08, 0.0), Vector3(0.16, 0.06, 0.04), _materials.paper)
	_box(left_gondola, "SetupTaskCardOnEmptyFixture", Vector3(0.0, 1.16, -0.92), Vector3(0.58, 0.18, 0.035), _materials.sign_cream)
	_box(left_gondola, "LowGondolaPriceRail", Vector3(0.0, 0.77, -1.22), Vector3(1.5, 0.10, 0.08), _materials.shelf_label_rail)

	_box(bay, "DayOneSetupBoxUnderFixtureA", Vector3(2.98, 0.16, 1.52), Vector3(0.44, 0.30, 0.36), _materials.cardboard)
	_box(bay, "DayOneSetupBoxUnderFixtureB", Vector3(2.92, 0.20, 2.05), Vector3(0.34, 0.24, 0.30), _materials.cardboard_dark)


func _build_counter_display_case(root: Node3D) -> void:
	var counter := Node3D.new()
	counter.name = "CheckoutDisplayCaseAnchor"
	counter.position = Vector3(-1.42, 0.0, 0.16)
	counter.rotation_degrees = Vector3(0.0, -6.5, 0.0)
	root.add_child(counter)

	_box(counter, "GlassDisplayCaseLowerLaminate", Vector3(0.0, 0.36, 0.0), Vector3(2.35, 0.72, 0.72), _materials.dark_laminate)
	_box(counter, "GlassDisplayCasePaneFront", Vector3(0.0, 0.88, -0.38), Vector3(2.28, 0.72, 0.035), _materials.glass)
	_box(counter, "GlassDisplayCaseTop", Vector3(0.0, 1.24, 0.0), Vector3(2.35, 0.06, 0.8), _materials.acrylic)
	_box(counter, "DisplayCaseMetalLeftTrim", Vector3(-1.2, 0.86, 0.0), Vector3(0.055, 0.78, 0.82), _materials.dark_metal)
	_box(counter, "DisplayCaseMetalRightTrim", Vector3(1.2, 0.86, 0.0), Vector3(0.055, 0.78, 0.82), _materials.dark_metal)
	_box(counter, "RegisterBody", Vector3(-0.58, 1.43, 0.16), Vector3(0.48, 0.22, 0.38), _materials.register_gray)
	_box(counter, "RegisterScreen", Vector3(-0.58, 1.62, -0.02), Vector3(0.38, 0.28, 0.055), _materials.black_glass)
	_box(counter, "ScannerWedge", Vector3(0.05, 1.37, -0.12), Vector3(0.32, 0.09, 0.25), _materials.handle_metal)
	_box(counter, "BagStack", Vector3(0.74, 1.34, 0.2), Vector3(0.38, 0.08, 0.28), _materials.paper)
	_box(counter, "TradeInForms", Vector3(0.58, 1.31, -0.19), Vector3(0.42, 0.035, 0.28), _materials.paper_blue)
	_box(counter, "ControllerDisplayLeft", Vector3(-0.24, 1.42, -0.44), Vector3(0.33, 0.08, 0.12), _materials.controller_dark)
	_box(counter, "ControllerDisplayRight", Vector3(0.2, 1.42, -0.44), Vector3(0.33, 0.08, 0.12), _materials.controller_blue)
	for slot in range(5):
		_box(counter, "DisplayCaseInteriorItem%02d" % [slot + 1], Vector3(-0.82 + float(slot) * 0.4, 0.84, -0.16), Vector3(0.28, 0.18, 0.05), _cover_materials[slot])


func _build_attached_signage(root: Node3D) -> void:
	var signage := Node3D.new()
	signage.name = "AttachedRetailSignageAndPriceLanguage"
	root.add_child(signage)

	_box(signage, "BlankStarterShelfRailAttachedA", Vector3(3.24, 1.96, -0.42), Vector3(0.07, 0.12, 1.42), _materials.shelf_label_rail)
	_box(signage, "BlankStarterShelfRailAttachedB", Vector3(3.24, 1.76, 1.25), Vector3(0.07, 0.12, 1.22), _materials.shelf_label_rail)
	_box(signage, "QuietTradeWindowDecal", Vector3(-2.72, 1.46, -2.43), Vector3(0.78, 0.30, 0.028), _materials.window_decal)
	_sign_panel(signage, "TradeWindowDecalBitmap", "TRADE", Vector3(-3.02, 1.55, -2.468), Vector3(-90.0, 0.0, 0.0), Vector2(0.5, 0.12), _materials.window_decal, _materials.sign_text)
	_box(signage, "SmallSaleStickerSheetOnCounter", Vector3(-0.1, 1.31, -0.55), Vector3(0.36, 0.02, 0.18), _materials.price_yellow)


func _build_cameras(root: Node3D) -> void:
	var cameras := Node3D.new()
	cameras.name = "BenchmarkCameras"
	root.add_child(cameras)

	var hero := Camera3D.new()
	hero.name = "InsideOutHeroCamera"
	hero.current = true
	hero.fov = 66.0
	cameras.add_child(hero)
	hero.global_position = Vector3(0.25, 1.48, 1.82)
	hero.look_at(Vector3(0.02, 1.42, -3.55), Vector3.UP)

	var shelf := Camera3D.new()
	shelf.name = "ShelfDensityCamera"
	shelf.fov = 58.0
	cameras.add_child(shelf)
	shelf.global_position = Vector3(0.95, 1.18, -0.95)
	shelf.look_at(Vector3(3.18, 1.08, 0.70), Vector3.UP)

	var frame := Camera3D.new()
	frame.name = "StorefrontFrameCamera"
	frame.fov = 62.0
	cameras.add_child(frame)
	frame.global_position = Vector3(-1.15, 1.34, -0.55)
	frame.look_at(Vector3(0.0, 1.55, -3.4), Vector3.UP)


func _build_materials() -> void:
	_materials = {
		"carpet": _mat("carpet", Color(0.31, 0.32, 0.29), 0.9, 0.0, _noise_texture(Color(0.24, 0.26, 0.24), Color(0.43, 0.42, 0.36), 32)),
		"store_tile": _mat("store_tile", Color(0.58, 0.57, 0.52), 0.74),
		"mall_tile": _mat("mall_tile", Color(0.56, 0.55, 0.50), 0.72, 0.0, _checker_texture(Color(0.49, 0.49, 0.44), Color(0.63, 0.62, 0.56), 48)),
		"grout": _mat("grout", Color(0.77, 0.72, 0.58), 0.94),
		"wall_warm": _mat("wall_warm", Color(0.77, 0.78, 0.72), 0.86, 0.0, _noise_texture(Color(0.69, 0.71, 0.66), Color(0.84, 0.84, 0.76), 24)),
		"wall_panel": _mat("wall_panel", Color(0.68, 0.70, 0.64), 0.86),
		"slatwall": _mat("slatwall", Color(0.74, 0.75, 0.68), 0.88),
		"slat_shadow": _mat("slat_shadow", Color(0.38, 0.40, 0.37), 0.92),
		"mall_wall": _mat("mall_wall", Color(0.57, 0.58, 0.55), 0.9),
		"dark_metal": _mat("dark_metal", Color(0.03, 0.05, 0.055), 0.48, 0.12),
		"handle_metal": _mat("handle_metal", Color(0.70, 0.64, 0.48), 0.38, 0.2),
		"dark_blue": _mat("dark_blue", Color(0.04, 0.16, 0.21), 0.66),
		"sign_cream": _mat("sign_cream", Color(0.88, 0.80, 0.62), 0.58),
		"window_decal": _mat("window_decal", Color(0.42, 0.18, 0.13), 0.65),
		"sign_text": _mat("sign_text", Color(0.97, 0.93, 0.76), 0.5),
		"small_text": _mat("small_text", Color(0.95, 0.96, 0.88), 0.5),
		"dark_text": _mat("dark_text", Color(0.02, 0.12, 0.13), 0.6),
		"warm_lightbox": _emissive_mat("warm_lightbox", Color(0.93, 0.82, 0.58), 0.5),
		"glass": _glass_mat("glass", Color(0.62, 0.78, 0.84, 0.28)),
		"black_glass": _glass_mat("black_glass", Color(0.0, 0.02, 0.025, 0.92)),
		"acrylic": _glass_mat("acrylic", Color(0.82, 0.93, 0.95, 0.22)),
		"ceiling_tile": _mat("ceiling_tile", Color(0.68, 0.67, 0.63), 0.92, 0.0, _checker_texture(Color(0.62, 0.62, 0.59), Color(0.74, 0.73, 0.69), 16)),
		"ceiling_grid": _mat("ceiling_grid", Color(0.30, 0.31, 0.30), 0.58),
		"fluorescent": _emissive_mat("fluorescent", Color(1.0, 0.92, 0.72), 0.38),
		"dark_laminate": _mat("dark_laminate", Color(0.09, 0.07, 0.055), 0.5),
		"wood": _mat("wood", Color(0.42, 0.26, 0.12), 0.62),
		"directory_blue": _mat("directory_blue", Color(0.36, 0.40, 0.40), 0.6),
		"price_yellow": _mat("price_yellow", Color(0.82, 0.68, 0.36), 0.58),
		"shelf_label_rail": _mat("shelf_label_rail", Color(0.09, 0.18, 0.20), 0.65),
		"empty_slot_shadow": _mat("empty_slot_shadow", Color(0.52, 0.54, 0.49), 0.84),
		"game_case_black": _mat("game_case_black", Color(0.015, 0.018, 0.018), 0.48),
		"console_box": _mat("console_box", Color(0.38, 0.42, 0.40), 0.72, 0.0, _checker_texture(Color(0.31, 0.35, 0.34), Color(0.47, 0.49, 0.45), 24)),
		"accessory_box": _mat("accessory_box", Color(0.68, 0.63, 0.50), 0.74),
		"cardboard": _mat("cardboard", Color(0.53, 0.36, 0.18), 0.82),
		"cardboard_dark": _mat("cardboard_dark", Color(0.36, 0.25, 0.14), 0.84),
		"register_gray": _mat("register_gray", Color(0.3, 0.34, 0.35), 0.55),
		"paper": _mat("paper", Color(0.86, 0.82, 0.68), 0.92),
		"paper_blue": _mat("paper_blue", Color(0.62, 0.78, 0.84), 0.86),
		"controller_dark": _mat("controller_dark", Color(0.02, 0.04, 0.05), 0.58),
		"controller_blue": _mat("controller_blue", Color(0.07, 0.20, 0.25), 0.6),
		"platform_blue": _mat("platform_blue", Color(0.12, 0.22, 0.30), 0.66),
		"platform_green": _mat("platform_green", Color(0.18, 0.27, 0.22), 0.66),
		"platform_red": _mat("platform_red", Color(0.33, 0.17, 0.14), 0.66),
		"platform_purple": _mat("platform_purple", Color(0.22, 0.18, 0.28), 0.66),
	}

	_cover_materials.clear()
	var cover_colors: Array[Color] = [
		Color(0.16, 0.24, 0.38),
		Color(0.38, 0.20, 0.16),
		Color(0.18, 0.32, 0.24),
		Color(0.52, 0.42, 0.22),
		Color(0.28, 0.22, 0.36),
		Color(0.14, 0.34, 0.38),
	]
	for index in range(18):
		var base := cover_colors[index % cover_colors.size()]
		_cover_materials.append(_mat(
			"cover_%02d" % index,
			base,
			0.62,
			0.0,
			_cover_texture(base, Color(0.96, 0.86, 0.52), index)
		))


func _box(parent: Node3D, node_name: String, position_value: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = position_value
	parent.add_child(node)
	return node


func _rod_x(parent: Node3D, node_name: String, position_value: Vector3, radius: float, length: float, material: StandardMaterial3D) -> MeshInstance3D:
	return _cylinder(parent, node_name, position_value, radius, length, Vector3(0.0, 0.0, 90.0), material)


func _rod_y(parent: Node3D, node_name: String, position_value: Vector3, radius: float, length: float, material: StandardMaterial3D) -> MeshInstance3D:
	return _cylinder(parent, node_name, position_value, radius, length, Vector3.ZERO, material)


func _rod_z(parent: Node3D, node_name: String, position_value: Vector3, radius: float, length: float, material: StandardMaterial3D) -> MeshInstance3D:
	return _cylinder(parent, node_name, position_value, radius, length, Vector3(90.0, 0.0, 0.0), material)


func _cylinder(parent: Node3D, node_name: String, position_value: Vector3, radius: float, length: float, rotation_value: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = length
	mesh.radial_segments = 8
	mesh.rings = 1
	mesh.material = material
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = position_value
	node.rotation_degrees = rotation_value
	parent.add_child(node)
	return node


func _cover_face(parent: Node3D, node_name: String, position_value: Vector3, size_yz: Vector2, cover_material: StandardMaterial3D, variant: int) -> MeshInstance3D:
	var mesh := QuadMesh.new()
	mesh.size = Vector2(size_yz.y, size_yz.x)
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = position_value
	node.rotation_degrees = Vector3(0.0, -90.0, 0.0)
	node.material_override = _case_cover_material("%sMaterial" % node_name, cover_material.albedo_color, variant)
	parent.add_child(node)
	return node


func _case_cover_material(name: String, base: Color, variant: int) -> StandardMaterial3D:
	var accent := _platform_case_band_material(variant + 1).albedo_color
	var material := _mat(name, base, 0.64, 0.0, _case_cover_texture(base, accent, variant))
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _starter_game_case(parent: Node3D, node_name: String, position_value: Vector3, cover_material: StandardMaterial3D, variant: int) -> Node3D:
	var holder := Node3D.new()
	holder.name = node_name
	holder.position = position_value
	parent.add_child(holder)

	_box(holder, "BlackPlasticCaseShell", Vector3(0.0, 0.0, 0.0), Vector3(0.058, 0.255, 0.178), _materials.game_case_black)
	_cover_face(holder, "InsetCoverArtPanel", Vector3(-0.036, 0.002, 0.006), Vector2(0.206, 0.132), cover_material, variant)
	_rod_y(holder, "RoundedLeftCaseSpine", Vector3(-0.044, 0.0, -0.082), 0.009, 0.235, _platform_case_band_material(variant + 1))
	_rod_y(holder, "RoundedRightCaseEdge", Vector3(-0.044, 0.0, 0.082), 0.006, 0.230, _materials.dark_metal)
	_rod_z(holder, "RoundedTopCaseLip", Vector3(-0.044, 0.123, 0.0), 0.007, 0.170, _materials.game_case_black)
	_rod_z(holder, "RoundedBottomCaseLip", Vector3(-0.044, -0.123, 0.0), 0.007, 0.170, _materials.game_case_black)
	return holder


func _sign_panel(
	parent: Node3D,
	node_name: String,
	text: String,
	position_value: Vector3,
	rotation_value: Vector3,
	size: Vector2,
	background_material: StandardMaterial3D,
	foreground_material: StandardMaterial3D
) -> MeshInstance3D:
	var mesh := QuadMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = position_value
	node.rotation_degrees = rotation_value
	node.material_override = _sign_bitmap_material(
		"%sMaterial" % node_name,
		background_material.albedo_color,
		foreground_material.albedo_color,
		text
	)
	parent.add_child(node)
	return node


func _glyph_rows(letter: String) -> PackedStringArray:
	match letter.to_upper():
		"B":
			return PackedStringArray(["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."])
		"C":
			return PackedStringArray([".####", "#....", "#....", "#....", "#....", "#....", ".####"])
		"D":
			return PackedStringArray(["####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."])
		"G":
			return PackedStringArray([".####", "#....", "#....", "#.###", "#...#", "#...#", ".####"])
		"A":
			return PackedStringArray([".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"])
		"I":
			return PackedStringArray(["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "#####"])
		"M":
			return PackedStringArray(["#...#", "##.##", "#.#.#", "#...#", "#...#", "#...#", "#...#"])
		"E":
			return PackedStringArray(["#####", "#....", "#....", "####.", "#....", "#....", "#####"])
		"S":
			return PackedStringArray([".####", "#....", "#....", ".###.", "....#", "....#", "####."])
		"4":
			return PackedStringArray(["#...#", "#...#", "#...#", "#####", "....#", "....#", "....#"])
		"U":
			return PackedStringArray(["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."])
		"O":
			return PackedStringArray([".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."])
		"P":
			return PackedStringArray(["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."])
		"R":
			return PackedStringArray(["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"])
		"T":
			return PackedStringArray(["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."])
		"N":
			return PackedStringArray(["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"])
		"W":
			return PackedStringArray(["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "##.##", "#...#"])
		"L":
			return PackedStringArray(["#....", "#....", "#....", "#....", "#....", "#....", "#####"])
		_:
			return PackedStringArray([".....", ".....", ".....", ".....", ".....", ".....", "....."])


func _mat(_name: String, color: Color, roughness: float, metallic: float = 0.0, texture: Texture2D = null) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if texture != null:
		material.albedo_texture = texture
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _glass_mat(name: String, color: Color) -> StandardMaterial3D:
	var material := _mat(name, color, 0.08, 0.0)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	return material


func _emissive_mat(name: String, color: Color, energy: float) -> StandardMaterial3D:
	var material := _mat(name, color, 0.32, 0.0)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


func _sign_bitmap_material(name: String, background: Color, foreground: Color, text: String) -> StandardMaterial3D:
	var material := _mat(name, background, 0.72, 0.0, _sign_texture(background, foreground, text))
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _checker_texture(a: Color, b: Color, cell_size: int) -> ImageTexture:
	var image := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(128):
			var use_a := int(floor(float(x) / float(cell_size)) + floor(float(y) / float(cell_size))) % 2 == 0
			image.set_pixel(x, y, a if use_a else b)
	return ImageTexture.create_from_image(image)


func _noise_texture(a: Color, b: Color, cell_size: int) -> ImageTexture:
	var image := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(128):
			var band := float(((x * 17 + y * 31) % cell_size)) / float(maxi(1, cell_size))
			image.set_pixel(x, y, a.lerp(b, band))
	return ImageTexture.create_from_image(image)


func _sign_texture(background: Color, foreground: Color, text: String) -> ImageTexture:
	var image := Image.create(256, 64, false, Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(256):
			var vignette: float = 0.94 + 0.06 * (1.0 - abs(float(x) - 128.0) / 128.0)
			image.set_pixel(x, y, background * vignette)

	var glyph_width := 5
	var glyph_height := 7
	var pixel := 5
	var gap := 3
	var total_width := 0
	for letter in text:
		if letter == " ":
			total_width += pixel * 2
		else:
			total_width += glyph_width * pixel + gap
	var cursor_x := maxi(8, int((256 - total_width) / 2.0))
	var origin_y := int((64 - glyph_height * pixel) / 2.0)
	for letter in text:
		if letter == " ":
			cursor_x += pixel * 2
			continue
		var rows := _glyph_rows(letter)
		for row in range(rows.size()):
			var row_text := rows[row]
			for column in range(row_text.length()):
				if row_text.substr(column, 1) != "#":
					continue
				_fill_rect(image, cursor_x + column * pixel, origin_y + row * pixel, pixel - 1, pixel - 1, foreground)
		cursor_x += glyph_width * pixel + gap
	return ImageTexture.create_from_image(image)


func _fill_rect(image: Image, x0: int, y0: int, width: int, height: int, color: Color) -> void:
	for y in range(y0, mini(image.get_height(), y0 + height)):
		for x in range(x0, mini(image.get_width(), x0 + width)):
			image.set_pixel(x, y, color)


func _cover_texture(base: Color, accent: Color, index: int) -> ImageTexture:
	var image := Image.create(64, 96, false, Image.FORMAT_RGBA8)
	for y in range(96):
		for x in range(64):
			var color := base.darkened(0.08)
			if y < 12:
				color = accent
			elif x > 46 and y > 16 and y < 82:
				color = base.lightened(0.2)
			elif (x + index * 7) % 19 < 3 and y > 22 and y < 76:
				color = accent.darkened(0.18)
			elif y > 78:
				color = Color(0.05, 0.06, 0.07)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


func _case_cover_texture(base: Color, accent: Color, index: int) -> ImageTexture:
	var image := Image.create(96, 144, false, Image.FORMAT_RGBA8)
	var dark := Color(0.03, 0.035, 0.035)
	for y in range(144):
		for x in range(96):
			var uv_x := float(x) / 95.0
			var uv_y := float(y) / 143.0
			var shade: float = 0.78 + 0.18 * (1.0 - abs(uv_x - 0.5) * 1.7)
			var color: Color = base * shade
			if y < 16:
				color = accent.lerp(Color(0.98, 0.88, 0.58), 0.16)
			elif y > 125:
				color = dark
			elif x < 10:
				color = accent.darkened(0.24)
			elif x > 78 and y > 22 and y < 112:
				color = base.lightened(0.2)
			image.set_pixel(x, y, color)

	_draw_cover_art_shape(image, index)
	_fill_rect(image, 12, 23, 68, 4, Color(0.90, 0.88, 0.74))
	_fill_rect(image, 12, 31, 46, 3, Color(0.76, 0.74, 0.64))
	_fill_rect(image, 67, 126, 20, 10, Color(0.90, 0.78, 0.43))
	_fill_rect(image, 70, 129, 14, 2, dark)
	return ImageTexture.create_from_image(image)


func _draw_cover_art_shape(image: Image, index: int) -> void:
	var palette: Array[Color] = [
		Color(0.18, 0.36, 0.50),
		Color(0.60, 0.37, 0.22),
		Color(0.30, 0.47, 0.28),
		Color(0.55, 0.49, 0.26),
	]
	var color_a := palette[index % palette.size()]
	var color_b := palette[(index + 2) % palette.size()]
	match index % 4:
		0:
			_fill_ellipse(image, Vector2i(48, 72), Vector2i(25, 31), color_a)
			_fill_ellipse(image, Vector2i(38, 66), Vector2i(9, 12), color_b.lightened(0.18))
			_fill_ellipse(image, Vector2i(58, 80), Vector2i(8, 10), color_b.darkened(0.08))
		1:
			_fill_slanted_rect(image, Vector2i(24, 49), Vector2i(72, 91), color_a)
			_fill_slanted_rect(image, Vector2i(31, 60), Vector2i(61, 101), color_b.lightened(0.12))
		2:
			_fill_ellipse(image, Vector2i(47, 71), Vector2i(30, 21), color_a.darkened(0.08))
			_fill_rect(image, 33, 62, 29, 34, color_b.lightened(0.12))
		_:
			_fill_rect(image, 28, 48, 40, 54, color_a)
			_fill_ellipse(image, Vector2i(50, 75), Vector2i(18, 18), color_b.lightened(0.16))


func _fill_ellipse(image: Image, center: Vector2i, radius: Vector2i, color: Color) -> void:
	for y in range(maxi(0, center.y - radius.y), mini(image.get_height(), center.y + radius.y)):
		for x in range(maxi(0, center.x - radius.x), mini(image.get_width(), center.x + radius.x)):
			var dx := float(x - center.x) / float(maxi(1, radius.x))
			var dy := float(y - center.y) / float(maxi(1, radius.y))
			if dx * dx + dy * dy <= 1.0:
				image.set_pixel(x, y, color)


func _fill_slanted_rect(image: Image, top_left: Vector2i, bottom_right: Vector2i, color: Color) -> void:
	for y in range(maxi(0, top_left.y), mini(image.get_height(), bottom_right.y)):
		var offset := int(float(y - top_left.y) * 0.22)
		for x in range(maxi(0, top_left.x + offset), mini(image.get_width(), bottom_right.x + offset)):
			image.set_pixel(x, y, color)


func _platform_case_band_material(index: int) -> StandardMaterial3D:
	match index % 4:
		0:
			return _materials.platform_blue
		1:
			return _materials.platform_green
		2:
			return _materials.platform_red
		_:
			return _materials.platform_purple


func _is_day_one_starter_game_slot(shelf: int, row: int, slot: int) -> bool:
	return (shelf == 0 and row == 0 and slot == 1) or (shelf == 0 and row == 0 and slot == 2)
