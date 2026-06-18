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
		"new_real_inspiration: drop ceiling, slatwall, dense case rows, yellow price stickers",
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
	environment.background_color = Color(0.33, 0.35, 0.35)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.65, 0.62)
	environment.ambient_light_energy = 0.82
	world.environment = environment
	root.add_child(world)

	var store_light := DirectionalLight3D.new()
	store_light.name = "SoftStoreDirectionLight"
	store_light.light_energy = 0.62
	store_light.rotation_degrees = Vector3(-48.0, -20.0, 0.0)
	root.add_child(store_light)

	for index in range(4):
		var light := OmniLight3D.new()
		light.name = "WarmFluorescentFill%02d" % [index + 1]
		light.light_color = Color(1.0, 0.9, 0.7)
		light.light_energy = 0.95
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
	_box(shell, "BackSlatwallBase", Vector3(0.0, 1.24, 4.46), Vector3(7.45, 2.48, 0.11), _materials.wall_panel)

	for y in [0.72, 1.18, 1.64, 2.10]:
		_box(shell, "StoreTrimRailY%03d" % int(y * 100.0), Vector3(0.0, y, 4.38), Vector3(7.35, 0.045, 0.08), _materials.dark_metal)
		_box(shell, "LeftWallTrimRailY%03d" % int(y * 100.0), Vector3(-3.69, y, 1.0), Vector3(0.08, 0.045, 6.25), _materials.dark_metal)
		_box(shell, "RightWallTrimRailY%03d" % int(y * 100.0), Vector3(3.69, y, 1.0), Vector3(0.08, 0.045, 6.25), _materials.dark_metal)

	for x in [-2.8, -1.4, 0.0, 1.4, 2.8]:
		_box(shell, "BackWallSlatSeam%02d" % int((x + 2.8) * 10.0), Vector3(x, 1.24, 4.315), Vector3(0.035, 2.1, 0.06), _materials.slat_shadow)

	for x in [-2.2, 0.2, 2.5]:
		_poster(shell, "PromoWallPanel%02d" % int((x + 3.0) * 10.0), Vector3(x, 1.72, 4.25), Vector3(0.72, 0.52, 0.035), _pick_promo_material(x))


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
	_box(mall, "NeighborLeftNeonStrip", Vector3(-4.15, 2.18, -6.48), Vector3(1.45, 0.08, 0.08), _materials.cyan_light)
	_box(mall, "NeighborRightPinkStrip", Vector3(4.15, 2.18, -6.48), Vector3(1.45, 0.08, 0.08), _materials.magenta_light)
	_box(mall, "MallBenchSeat", Vector3(-2.2, 0.42, -6.1), Vector3(1.22, 0.14, 0.36), _materials.wood)
	_box(mall, "MallBenchLeftLeg", Vector3(-2.72, 0.22, -6.1), Vector3(0.12, 0.42, 0.12), _materials.dark_metal)
	_box(mall, "MallBenchRightLeg", Vector3(-1.68, 0.22, -6.1), Vector3(0.12, 0.42, 0.12), _materials.dark_metal)
	_box(mall, "MallDirectoryKiosk", Vector3(2.0, 0.82, -5.78), Vector3(0.38, 1.65, 0.18), _materials.directory_blue)
	_box(mall, "MallDirectoryScreen", Vector3(2.0, 1.18, -5.66), Vector3(0.32, 0.54, 0.035), _materials.cyan_light)


func _build_storefront(root: Node3D) -> void:
	var storefront := Node3D.new()
	storefront.name = "StorefrontGlassSystem"
	root.add_child(storefront)

	_box(storefront, "ChunkyStorefrontFascia", Vector3(0.0, 2.48, -2.2), Vector3(7.78, 0.36, 0.30), _materials.dark_blue)
	_box(storefront, "BacklitGames4UFasciaPanel", Vector3(0.0, 2.49, -2.39), Vector3(2.65, 0.44, 0.055), _materials.sign_gold)
	_box(storefront, "InteriorFacingGames4USignPanel", Vector3(0.0, 2.48, -2.04), Vector3(2.85, 0.46, 0.04), _materials.sign_gold)
	_block_text(storefront, "Games4UBlockSign", "GAMES4U", Vector3(-1.18, 2.61, -1.995), 0.052, _materials.dark_text)
	_block_text(storefront, "G4UBlockLogo", "G4U", Vector3(-0.62, 2.52, -1.965), 0.09, _materials.dark_blue)
	_text(storefront, "Games4USignTextMesh", "Games4U", Vector3(-1.17, 2.37, -2.435), Vector3(-90.0, 0.0, 0.0), 42, _materials.sign_text)
	_box(storefront, "CyanStorefrontTrim", Vector3(0.0, 2.75, -2.36), Vector3(7.65, 0.045, 0.055), _materials.cyan_light)
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

	_box(storefront, "OpenSignPanelAttachedToDoor", Vector3(0.58, 1.64, -2.43), Vector3(0.58, 0.24, 0.035), _materials.store_open)
	_block_text(storefront, "OpenBlockSign", "OPEN", Vector3(0.36, 1.72, -2.392), 0.025, _materials.dark_text)
	_text(storefront, "OpenSignTextMesh", "OPEN", Vector3(0.36, 1.57, -2.465), Vector3(-90.0, 0.0, 0.0), 18, _materials.sign_text)


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
	bay.name = "SlatwallProductBayDenseCaseRows"
	root.add_child(bay)

	_box(bay, "RightWallSlatwallPanel", Vector3(3.66, 1.34, 0.85), Vector3(0.08, 2.18, 4.5), _materials.slatwall)
	for z_index in range(9):
		var z := -1.08 + float(z_index) * 0.48
		_box(bay, "RightWallShelfRail%02d" % [z_index + 1], Vector3(3.57, 0.68 + float(z_index % 4) * 0.37, z), Vector3(0.18, 0.045, 1.58), _materials.dark_metal)

	for shelf in range(4):
		var y := 0.72 + float(shelf) * 0.38
		_box(bay, "RightWallAcrylicShelf%02d" % [shelf + 1], Vector3(3.35, y, -0.05 + float(shelf) * 0.18), Vector3(0.42, 0.04, 3.25), _materials.acrylic)
		_box(bay, "RightWallShelfHeader%02d" % [shelf + 1], Vector3(3.28, y + 0.19, -1.62), Vector3(0.08, 0.22, 0.78), _platform_header_material(shelf))
		_text(bay, "PlatformHeaderText%02d" % [shelf + 1], _platform_name(shelf), Vector3(3.215, y + 0.09, -1.96), Vector3(0.0, -90.0, 0.0), 10, _materials.small_text)

	for shelf in range(4):
		for row in range(2):
			for slot in range(11):
				var y := 0.83 + float(shelf) * 0.38 + float(row) * 0.115
				var z := -1.23 + float(slot) * 0.26
				var mat := _cover_materials[(shelf * 22 + row * 11 + slot) % _cover_materials.size()]
				var game := _box(bay, "DenseCaseFacingS%02dR%02dN%02d" % [shelf + 1, row + 1, slot + 1], Vector3(3.12, y, z), Vector3(0.055, 0.24, 0.17), mat)
				game.rotation_degrees = Vector3(0.0, -2.0 + float(slot % 4), 0.0)
				if slot % 3 == 0:
					_box(bay, "YellowPriceStickerS%02dR%02dN%02d" % [shelf + 1, row + 1, slot + 1], Vector3(3.078, y - 0.055, z + 0.045), Vector3(0.018, 0.045, 0.055), _materials.price_yellow)

	var left_gondola := Node3D.new()
	left_gondola.name = "LowGondolaCaseRun"
	left_gondola.position = Vector3(-2.35, 0.0, -0.18)
	left_gondola.rotation_degrees = Vector3(0.0, 5.0, 0.0)
	bay.add_child(left_gondola)
	_box(left_gondola, "GondolaLaminateBase", Vector3(0.0, 0.33, 0.0), Vector3(1.4, 0.66, 2.15), _materials.dark_laminate)
	_box(left_gondola, "GondolaWireRackBack", Vector3(0.0, 0.94, 0.0), Vector3(1.46, 0.72, 0.08), _materials.dark_metal)
	for slot in range(10):
		var z := -0.92 + float(slot) * 0.2
		_box(left_gondola, "GondolaGameCase%02d" % [slot + 1], Vector3(-0.32 + float(slot % 2) * 0.55, 1.0, z), Vector3(0.38, 0.25, 0.05), _cover_materials[slot % _cover_materials.size()])
	_box(left_gondola, "BargainBinLip", Vector3(0.0, 0.77, -1.22), Vector3(1.5, 0.16, 0.08), _materials.sign_red)


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

	_box(signage, "NewReleaseHeaderAttached", Vector3(3.28, 2.02, -0.42), Vector3(0.08, 0.28, 1.62), _materials.dark_blue)
	_block_text(signage, "NewBlockHeader", "NEW", Vector3(3.225, 2.11, -0.86), 0.026, _materials.sign_text)
	_text(signage, "NewReleaseHeaderText", "NEW RELEASES", Vector3(3.205, 1.9, -0.97), Vector3(0.0, -90.0, 0.0), 12, _materials.sign_text)
	_box(signage, "UsedGamesHeaderAttached", Vector3(3.28, 1.82, 1.25), Vector3(0.08, 0.25, 1.42), _materials.sign_gold)
	_block_text(signage, "UsedBlockHeader", "USED", Vector3(3.225, 1.9, 0.9), 0.024, _materials.dark_text)
	_text(signage, "UsedGamesHeaderText", "USED GAMES", Vector3(3.205, 1.72, 0.78), Vector3(0.0, -90.0, 0.0), 12, _materials.dark_text)
	_box(signage, "TradeDealWindowDecal", Vector3(-2.72, 1.46, -2.43), Vector3(0.95, 0.42, 0.028), _materials.sign_red)
	_text(signage, "TradeDealWindowText", "TRADE BONUS", Vector3(-3.08, 1.34, -2.468), Vector3(-90.0, 0.0, 0.0), 13, _materials.sign_text)
	_box(signage, "SaleStickerSheetOnCounter", Vector3(-0.1, 1.31, -0.55), Vector3(0.48, 0.025, 0.26), _materials.price_yellow)


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
	shelf.global_position = Vector3(1.0, 1.22, -0.9)
	shelf.look_at(Vector3(3.25, 1.22, 0.85), Vector3.UP)

	var frame := Camera3D.new()
	frame.name = "StorefrontFrameCamera"
	frame.fov = 62.0
	cameras.add_child(frame)
	frame.global_position = Vector3(-1.15, 1.34, -0.55)
	frame.look_at(Vector3(0.0, 1.55, -3.4), Vector3.UP)


func _build_materials() -> void:
	_materials = {
		"carpet": _mat("carpet", Color(0.39, 0.39, 0.35), 0.88, 0.0, _noise_texture(Color(0.34, 0.35, 0.32), Color(0.48, 0.47, 0.4), 32)),
		"store_tile": _mat("store_tile", Color(0.62, 0.62, 0.56), 0.72),
		"mall_tile": _mat("mall_tile", Color(0.54, 0.53, 0.48), 0.7, 0.0, _checker_texture(Color(0.48, 0.48, 0.43), Color(0.62, 0.61, 0.55), 48)),
		"grout": _mat("grout", Color(0.82, 0.76, 0.58), 0.94),
		"wall_warm": _mat("wall_warm", Color(0.72, 0.74, 0.68), 0.82, 0.0, _noise_texture(Color(0.64, 0.67, 0.63), Color(0.78, 0.79, 0.71), 24)),
		"wall_panel": _mat("wall_panel", Color(0.55, 0.65, 0.65), 0.84),
		"slatwall": _mat("slatwall", Color(0.68, 0.7, 0.64), 0.86),
		"slat_shadow": _mat("slat_shadow", Color(0.23, 0.27, 0.27), 0.9),
		"mall_wall": _mat("mall_wall", Color(0.42, 0.44, 0.42), 0.9),
		"dark_metal": _mat("dark_metal", Color(0.02, 0.06, 0.08), 0.46, 0.15),
		"handle_metal": _mat("handle_metal", Color(0.75, 0.66, 0.47), 0.35, 0.25),
		"dark_blue": _mat("dark_blue", Color(0.03, 0.18, 0.24), 0.62),
		"sign_gold": _mat("sign_gold", Color(0.88, 0.68, 0.36), 0.48),
		"sign_red": _mat("sign_red", Color(0.68, 0.1, 0.08), 0.6),
		"sign_text": _mat("sign_text", Color(0.97, 0.93, 0.76), 0.5),
		"small_text": _mat("small_text", Color(0.95, 0.96, 0.88), 0.5),
		"dark_text": _mat("dark_text", Color(0.02, 0.12, 0.13), 0.6),
		"store_open": _mat("store_open", Color(0.24, 0.76, 0.42), 0.5),
		"cyan_light": _emissive_mat("cyan_light", Color(0.24, 0.95, 1.0), 0.75),
		"magenta_light": _emissive_mat("magenta_light", Color(1.0, 0.28, 0.78), 0.7),
		"glass": _glass_mat("glass", Color(0.58, 0.82, 0.92, 0.34)),
		"black_glass": _glass_mat("black_glass", Color(0.0, 0.02, 0.025, 0.92)),
		"acrylic": _glass_mat("acrylic", Color(0.82, 0.95, 1.0, 0.28)),
		"ceiling_tile": _mat("ceiling_tile", Color(0.62, 0.62, 0.59), 0.92, 0.0, _checker_texture(Color(0.56, 0.56, 0.54), Color(0.68, 0.68, 0.64), 16)),
		"ceiling_grid": _mat("ceiling_grid", Color(0.24, 0.25, 0.25), 0.55),
		"fluorescent": _emissive_mat("fluorescent", Color(1.0, 0.9, 0.68), 0.45),
		"dark_laminate": _mat("dark_laminate", Color(0.09, 0.07, 0.055), 0.5),
		"wood": _mat("wood", Color(0.42, 0.26, 0.12), 0.62),
		"directory_blue": _mat("directory_blue", Color(0.32, 0.38, 0.42), 0.58),
		"price_yellow": _mat("price_yellow", Color(0.96, 0.78, 0.32), 0.55),
		"register_gray": _mat("register_gray", Color(0.3, 0.34, 0.35), 0.55),
		"paper": _mat("paper", Color(0.86, 0.82, 0.68), 0.92),
		"paper_blue": _mat("paper_blue", Color(0.62, 0.78, 0.84), 0.86),
		"controller_dark": _mat("controller_dark", Color(0.02, 0.04, 0.05), 0.58),
		"controller_blue": _mat("controller_blue", Color(0.08, 0.27, 0.38), 0.58),
		"platform_blue": _mat("platform_blue", Color(0.08, 0.22, 0.62), 0.6),
		"platform_green": _mat("platform_green", Color(0.08, 0.42, 0.28), 0.6),
		"platform_red": _mat("platform_red", Color(0.62, 0.12, 0.12), 0.6),
		"platform_purple": _mat("platform_purple", Color(0.28, 0.16, 0.52), 0.6),
	}

	_cover_materials.clear()
	var cover_colors: Array[Color] = [
		Color(0.1, 0.23, 0.62),
		Color(0.74, 0.18, 0.14),
		Color(0.1, 0.48, 0.31),
		Color(0.82, 0.62, 0.16),
		Color(0.43, 0.22, 0.65),
		Color(0.04, 0.45, 0.62),
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


func _poster(parent: Node3D, node_name: String, position_value: Vector3, size: Vector3, material: StandardMaterial3D) -> void:
	var poster := _box(parent, node_name, position_value, size, material)
	poster.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	_box(parent, "%sBottomTag" % node_name, position_value + Vector3(0.0, -0.28, -0.025), Vector3(size.x * 0.62, 0.08, 0.04), _materials.price_yellow)


func _text(parent: Node3D, node_name: String, text: String, position_value: Vector3, rotation_value: Vector3, font_size: int, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := TextMesh.new()
	mesh.text = text
	mesh.font_size = font_size
	mesh.depth = 0.008
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = position_value
	node.rotation_degrees = rotation_value
	node.scale = Vector3(0.01, 0.01, 0.01)
	node.material_override = material
	parent.add_child(node)
	return node


func _block_text(parent: Node3D, node_name: String, text: String, origin: Vector3, pixel: float, material: StandardMaterial3D) -> Node3D:
	var holder := Node3D.new()
	holder.name = node_name
	parent.add_child(holder)

	var cursor_x := 0.0
	for letter in text:
		var rows := _glyph_rows(letter)
		for row in range(rows.size()):
			var row_text := rows[row]
			for column in range(row_text.length()):
				if row_text.substr(column, 1) != "#":
					continue
				_box(holder, "%s_%s_%02d_%02d" % [node_name, letter, row, column],
					origin + Vector3(cursor_x + float(column) * pixel, -float(row) * pixel, 0.0),
					Vector3(pixel * 0.78, pixel * 0.78, 0.024),
					material
				)
		cursor_x += pixel * 4.6
	return holder


func _glyph_rows(letter: String) -> PackedStringArray:
	match letter.to_upper():
		"G":
			return PackedStringArray(["####", "#...", "#.##", "#..#", "####"])
		"A":
			return PackedStringArray([".##.", "#..#", "####", "#..#", "#..#"])
		"M":
			return PackedStringArray(["#..#", "####", "####", "#..#", "#..#"])
		"E":
			return PackedStringArray(["####", "#...", "###.", "#...", "####"])
		"S":
			return PackedStringArray(["####", "#...", "####", "...#", "####"])
		"4":
			return PackedStringArray(["#..#", "#..#", "####", "...#", "...#"])
		"U":
			return PackedStringArray(["#..#", "#..#", "#..#", "#..#", "####"])
		"O":
			return PackedStringArray(["####", "#..#", "#..#", "#..#", "####"])
		"P":
			return PackedStringArray(["####", "#..#", "####", "#...", "#..."])
		"N":
			return PackedStringArray(["#..#", "##.#", "#.##", "#..#", "#..#"])
		"W":
			return PackedStringArray(["#..#", "#..#", "####", "####", "#..#"])
		"D":
			return PackedStringArray(["###.", "#..#", "#..#", "#..#", "###."])
		_:
			return PackedStringArray(["....", "....", "....", "....", "...."])


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


func _platform_header_material(index: int) -> StandardMaterial3D:
	match index:
		0:
			return _materials.platform_blue
		1:
			return _materials.platform_green
		2:
			return _materials.platform_red
		_:
			return _materials.platform_purple


func _platform_name(index: int) -> String:
	match index:
		0:
			return "ORBIT"
		1:
			return "NOVA"
		2:
			return "POCKET"
		_:
			return "USED"


func _pick_promo_material(x: float) -> StandardMaterial3D:
	if x < -1.0:
		return _materials.sign_red
	if x < 1.0:
		return _materials.platform_blue
	return _materials.platform_green
