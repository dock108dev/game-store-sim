## Registry for reusable store fixture/prop scenes used by store layouts and
## runtime feedback. This is visual-only: inventory, unlocks, and economy stay
## in the game systems that decide when these assets appear.
class_name StoreVisualKit
extends RefCounted

const WALL_SHELF: StringName = &"wall_shelf"
const DISPLAY_TABLE: StringName = &"display_table"
const CHECKOUT_COUNTER: StringName = &"checkout_counter"
const STOCKROOM_TABLE: StringName = &"stockroom_table"
const STOCK_BOX: StringName = &"stock_box"
const GAME_CASE: StringName = &"game_case"
const CONSOLE_BOX: StringName = &"console_box"
const REGISTER: StringName = &"register"
const RECEIPT_PRINTER: StringName = &"receipt_printer"
const CARD_READER: StringName = &"card_reader"
const QUEUE_LANE: StringName = &"queue_lane"
const GLTF_COUNTER_REGISTER: StringName = &"gltf_counter_register"
const GLTF_GAME_CASE: StringName = &"gltf_game_case"
const GLTF_CONSOLE_BOX: StringName = &"gltf_console_box"
const GLTF_CARTRIDGE_GB: StringName = &"gltf_cartridge_gb"
const GLTF_CARTRIDGE_N64: StringName = &"gltf_cartridge_n64"
const GLTF_CARTRIDGE_SNES: StringName = &"gltf_cartridge_snes"
const GLTF_CONSOLE_N64: StringName = &"gltf_console_n64"
const GLTF_CONSOLE_PS1: StringName = &"gltf_console_ps1"
const GLTF_CONSOLE_SNES: StringName = &"gltf_console_snes"
const GLTF_CRT_MONITOR: StringName = &"gltf_crt_monitor"
const GLTF_HOLD_TAG: StringName = &"gltf_hold_tag"
const GLTF_RECEIPT_PRINTER: StringName = &"gltf_receipt_printer"
const GLTF_REGISTER_MONITOR: StringName = &"gltf_register_monitor"
const BARCODE_SCANNER: StringName = &"barcode_scanner"
const CLIPBOARD: StringName = &"clipboard"
const HAND_TRUCK: StringName = &"hand_truck"
const PAPER_STACK: StringName = &"paper_stack"
const SHIPPING_SCALE: StringName = &"shipping_scale"
const TAPE_ROLL: StringName = &"tape_roll"

const _SCENE_PATHS: Dictionary = {
	WALL_SHELF: "res://game/scenes/stores/fixtures/fixture_wall_shelf.tscn",
	DISPLAY_TABLE: "res://game/scenes/stores/fixtures/fixture_display_table.tscn",
	CHECKOUT_COUNTER: "res://game/scenes/stores/fixtures/fixture_checkout_counter.tscn",
	STOCKROOM_TABLE: "res://game/scenes/stores/fixtures/fixture_stockroom_table.tscn",
	STOCK_BOX: "res://game/scenes/stores/fixtures/box_stack.tscn",
	GAME_CASE: "res://game/scenes/stores/fixtures/prop_game_case.tscn",
	CONSOLE_BOX: "res://game/scenes/stores/fixtures/prop_console_box.tscn",
	REGISTER: "res://game/scenes/stores/fixtures/prop_register.tscn",
	RECEIPT_PRINTER: "res://game/scenes/stores/fixtures/prop_receipt_printer.tscn",
	CARD_READER: "res://game/scenes/stores/fixtures/prop_card_reader.tscn",
	QUEUE_LANE: "res://game/scenes/stores/fixtures/fixture_queue_lane.tscn",
	GLTF_COUNTER_REGISTER: "res://game/assets/models/fixtures/prop_counter_register.gltf",
	GLTF_GAME_CASE: "res://game/assets/models/props/prop_game_case.gltf",
	GLTF_CONSOLE_BOX: "res://game/assets/models/props/prop_console_box.gltf",
	GLTF_CARTRIDGE_GB: "res://game/assets/models/props/prop_cartridge_gb.gltf",
	GLTF_CARTRIDGE_N64: "res://game/assets/models/props/prop_cartridge_n64.gltf",
	GLTF_CARTRIDGE_SNES: "res://game/assets/models/props/prop_cartridge_snes.gltf",
	GLTF_CONSOLE_N64: "res://game/assets/models/props/prop_console_n64.gltf",
	GLTF_CONSOLE_PS1: "res://game/assets/models/props/prop_console_ps1.gltf",
	GLTF_CONSOLE_SNES: "res://game/assets/models/props/prop_console_snes.gltf",
	GLTF_CRT_MONITOR: "res://game/assets/models/props/prop_crt_monitor.gltf",
	GLTF_HOLD_TAG: "res://game/assets/models/props/prop_hold_tag.gltf",
	GLTF_RECEIPT_PRINTER: "res://game/assets/models/props/prop_receipt_printer.gltf",
	GLTF_REGISTER_MONITOR: "res://game/assets/models/props/prop_register_monitor.gltf",
}

const _STARTER_STORE_IDS: Array[StringName] = [
	WALL_SHELF,
	DISPLAY_TABLE,
	CHECKOUT_COUNTER,
	STOCKROOM_TABLE,
	STOCK_BOX,
	GAME_CASE,
	CONSOLE_BOX,
	REGISTER,
]

const _STARTER_SHELL_PROP_IDS: Array[StringName] = [
	GLTF_COUNTER_REGISTER,
	GLTF_GAME_CASE,
	GLTF_CONSOLE_BOX,
	GLTF_CARTRIDGE_GB,
	GLTF_CARTRIDGE_N64,
	GLTF_CARTRIDGE_SNES,
	GLTF_CONSOLE_N64,
	GLTF_CONSOLE_PS1,
	GLTF_CONSOLE_SNES,
	GLTF_CRT_MONITOR,
	GLTF_HOLD_TAG,
	GLTF_RECEIPT_PRINTER,
	GLTF_REGISTER_MONITOR,
	STOCK_BOX,
	CARD_READER,
	BARCODE_SCANNER,
	CLIPBOARD,
	HAND_TRUCK,
	PAPER_STACK,
	SHIPPING_SCALE,
	TAPE_ROLL,
]

const _PROCEDURAL_IDS: Array[StringName] = [
	BARCODE_SCANNER,
	CLIPBOARD,
	HAND_TRUCK,
	PAPER_STACK,
	SHIPPING_SCALE,
	TAPE_ROLL,
]


static func scene_path(id: StringName) -> String:
	return str(_SCENE_PATHS.get(id, ""))


static func has_visual(id: StringName) -> bool:
	var path: String = scene_path(id)
	return _PROCEDURAL_IDS.has(id) or (not path.is_empty() and ResourceLoader.exists(path))


static func instantiate(id: StringName) -> Node:
	if _PROCEDURAL_IDS.has(id):
		return _instantiate_procedural(id)
	var path: String = scene_path(id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		return null
	return scene.instantiate()


static func required_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in _SCENE_PATHS.keys():
		ids.append(raw_id as StringName)
	for id: StringName in _PROCEDURAL_IDS:
		ids.append(id)
	ids.sort()
	return ids


static func starter_store_ids() -> Array[StringName]:
	return _STARTER_STORE_IDS.duplicate()


static func starter_shell_prop_ids() -> Array[StringName]:
	return _STARTER_SHELL_PROP_IDS.duplicate()


static func validate() -> Dictionary:
	var missing: Array[StringName] = []
	for id: StringName in required_ids():
		if not has_visual(id):
			missing.append(id)
	return {
		"ok": missing.is_empty(),
		"missing": missing,
	}


static func source_type(id: StringName) -> StringName:
	if _PROCEDURAL_IDS.has(id):
		return &"procedural"
	if _SCENE_PATHS.has(id):
		return &"scene"
	return &"missing"


static func _instantiate_procedural(id: StringName) -> Node3D:
	match id:
		BARCODE_SCANNER:
			return _barcode_scanner()
		CLIPBOARD:
			return _clipboard()
		HAND_TRUCK:
			return _hand_truck()
		PAPER_STACK:
			return _paper_stack()
		SHIPPING_SCALE:
			return _shipping_scale()
		TAPE_ROLL:
			return _tape_roll()
	return null


static func _root(name: String, id: StringName) -> Node3D:
	var root := Node3D.new()
	root.name = name
	root.set_meta("store_visual_id", id)
	root.set_meta("store_visual_source", "store_visual_kit")
	return root


static func _barcode_scanner() -> Node3D:
	var root: Node3D = _root("PropBarcodeScanner", BARCODE_SCANNER)
	_add_cylinder(
		root,
		"Handle",
		0.035,
		0.28,
		Vector3(0.0, 0.10, 0.0),
		Color(0.06, 0.06, 0.07, 1.0),
		Vector3(14.0, 0.0, 0.0)
	)
	_add_capsule(
		root,
		"ScannerHead",
		0.07,
		0.18,
		Vector3(0.0, 0.24, -0.08),
		Color(0.08, 0.09, 0.10, 1.0),
		Vector3(90.0, 0.0, 0.0)
	)
	_add_plane(
		root,
		"ScanWindow",
		Vector2(0.13, 0.035),
		Vector3(0.0, 0.24, -0.175),
		Color(0.16, 0.95, 0.55, 1.0),
		Vector3(90.0, 0.0, 0.0),
		Color(0.12, 1.0, 0.55, 1.0)
	)
	return root


static func _clipboard() -> Node3D:
	var root: Node3D = _root("PropClipboard", CLIPBOARD)
	_add_plane(
		root,
		"Board",
		Vector2(0.34, 0.46),
		Vector3.ZERO,
		Color(0.46, 0.31, 0.18, 1.0),
		Vector3.ZERO
	)
	_add_plane(
		root,
		"Paper",
		Vector2(0.28, 0.34),
		Vector3(0.0, 0.006, 0.01),
		Color(0.94, 0.88, 0.70, 1.0),
		Vector3.ZERO
	)
	_add_cylinder(
		root,
		"Clip",
		0.025,
		0.18,
		Vector3(0.0, 0.018, -0.18),
		Color(0.74, 0.58, 0.30, 1.0),
		Vector3(0.0, 0.0, 90.0)
	)
	return root


static func _hand_truck() -> Node3D:
	var root: Node3D = _root("FixtureHandTruck", HAND_TRUCK)
	for x: float in [-0.12, 0.12]:
		_add_cylinder(
			root,
			"FrameRail%s" % ("Left" if x < 0.0 else "Right"),
			0.018,
			1.05,
			Vector3(x, 0.58, 0.0),
			Color(0.05, 0.055, 0.06, 1.0),
			Vector3(8.0, 0.0, 0.0)
		)
		_add_cylinder(
			root,
			"Wheel%s" % ("Left" if x < 0.0 else "Right"),
			0.095,
			0.055,
			Vector3(x, 0.10, 0.13),
			Color(0.03, 0.03, 0.035, 1.0),
			Vector3(0.0, 0.0, 90.0)
		)
	_add_cylinder(
		root,
		"Handle",
		0.022,
		0.38,
		Vector3(0.0, 1.12, -0.02),
		Color(0.05, 0.055, 0.06, 1.0),
		Vector3(0.0, 0.0, 90.0)
	)
	_add_plane(
		root,
		"ToePlate",
		Vector2(0.46, 0.28),
		Vector3(0.0, 0.045, -0.12),
		Color(0.06, 0.06, 0.065, 1.0),
		Vector3.ZERO
	)
	return root


static func _paper_stack() -> Node3D:
	var root: Node3D = _root("PropPaperStack", PAPER_STACK)
	for index: int in range(3):
		_add_plane(
			root,
			"Page%02d" % index,
			Vector2(0.30, 0.22),
			Vector3(float(index) * 0.018, float(index) * 0.004, 0.0),
			Color(0.96, 0.90, 0.74, 1.0),
			Vector3(0.0, float(index) * 2.0, 0.0)
		)
	return root


static func _shipping_scale() -> Node3D:
	var root: Node3D = _root("PropShippingScale", SHIPPING_SCALE)
	_add_cylinder(
		root,
		"WeighingPlate",
		0.15,
		0.035,
		Vector3(0.0, 0.035, 0.0),
		Color(0.12, 0.13, 0.14, 1.0)
	)
	_add_plane(
		root,
		"Readout",
		Vector2(0.15, 0.055),
		Vector3(0.0, 0.09, -0.13),
		Color(0.12, 0.36, 0.28, 1.0),
		Vector3(-55.0, 0.0, 0.0),
		Color(0.10, 0.62, 0.40, 1.0)
	)
	return root


static func _tape_roll() -> Node3D:
	var root: Node3D = _root("PropTapeRoll", TAPE_ROLL)
	_add_cylinder(
		root,
		"Roll",
		0.105,
		0.055,
		Vector3.ZERO,
		Color(0.86, 0.62, 0.20, 1.0),
		Vector3(90.0, 0.0, 0.0)
	)
	_add_cylinder(
		root,
		"Core",
		0.052,
		0.058,
		Vector3.ZERO,
		Color(0.95, 0.88, 0.68, 1.0),
		Vector3(90.0, 0.0, 0.0)
	)
	return root


static func _add_cylinder(
	parent: Node3D,
	name: String,
	radius: float,
	height: float,
	position: Vector3,
	color: Color,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 18
	return _add_mesh(parent, name, mesh, position, rotation_degrees, _mat(color))


static func _add_capsule(
	parent: Node3D,
	name: String,
	radius: float,
	height: float,
	position: Vector3,
	color: Color,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 6
	return _add_mesh(parent, name, mesh, position, rotation_degrees, _mat(color))


static func _add_plane(
	parent: Node3D,
	name: String,
	size: Vector2,
	position: Vector3,
	color: Color,
	rotation_degrees: Vector3,
	emission: Color = Color.TRANSPARENT
) -> MeshInstance3D:
	var mesh := PlaneMesh.new()
	mesh.size = size
	var material: StandardMaterial3D = _mat(color, emission)
	return _add_mesh(parent, name, mesh, position, rotation_degrees, material)


static func _add_mesh(
	parent: Node3D,
	name: String,
	mesh: Mesh,
	position: Vector3,
	rotation_degrees: Vector3,
	material: StandardMaterial3D
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = mesh
	instance.position = position
	instance.rotation_degrees = rotation_degrees
	instance.material_override = material
	parent.add_child(instance)
	return instance


static func _mat(color: Color, emission: Color = Color.TRANSPARENT) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.84
	if emission.a > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = 0.28
	return material
