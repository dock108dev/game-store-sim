## Debug-only reference-corner camera comparison aid.
##
## Open `reference_corner_camera_comparison.tscn` directly to compare the
## first-person inspection pose, the fixed-angle store camera, and a
## counter-focused customer interaction pose against the same store corner.
class_name ReferenceCornerCameraComparison
extends Node3D

enum Mode {
	FIRST_PERSON,
	FIXED_ANGLE,
	COUNTER_FOCUS,
}

const MODE_FIRST_PERSON: int = Mode.FIRST_PERSON
const MODE_FIXED_ANGLE: int = Mode.FIXED_ANGLE
const MODE_COUNTER_FOCUS: int = Mode.COUNTER_FOCUS

const SOURCE_FIRST_PERSON: StringName = &"player_fp"
const SOURCE_FIXED_ANGLE: StringName = &"fixed_angle"
const SOURCE_COUNTER_FOCUS: StringName = &"counter_focus"
const MODE_COUNT: int = 3

const STORE_SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const FIXED_CONTROLLER_PATH: NodePath = ^"PlayerController"

const _FIRST_PERSON_FOCUS_PATH: String = "Checkout/Register/CheckoutSign"
const _COUNTER_FOCUS_PATH: String = "StoreSessionDayOneCustomer"
const _FIRST_PERSON_CAMERA_POSITION := Vector3(2.2, 1.7, 8.75)
const _FIXED_PIVOT := Vector3(3.35, 0.0, 3.2)
const _COUNTER_CAMERA_POSITION := Vector3(2.8, 1.55, 5.95)

@export var auto_setup: bool = true
@export var auto_select_first_mode: bool = true

var _store_root: Node3D = null
var _mode: int = Mode.FIRST_PERSON
var _cameras: Dictionary = {}


func _ready() -> void:
	if auto_setup:
		setup_comparison()


## Builds the debug comparison scene. Returns false if required store anchors
## are missing, leaving normal gameplay scenes untouched.
# gdlint:disable=max-returns
func setup_comparison() -> bool:
	if _store_root != null and is_instance_valid(_store_root):
		return true
	var store_scene: PackedScene = load(STORE_SCENE_PATH) as PackedScene
	if store_scene == null:
		push_error("Camera comparison store scene could not be loaded")
		return false
	var instance: Node = store_scene.instantiate()
	if not instance is Node3D:
		push_error("Camera comparison store scene root must be Node3D")
		instance.queue_free()
		return false
	_store_root = instance as Node3D
	_store_root.name = "ReferenceCornerStore"
	add_child(_store_root)
	_store_root.process_mode = Node.PROCESS_MODE_DISABLED

	if not _build_first_person_camera():
		return false
	if not _build_fixed_angle_camera():
		return false
	if not _build_counter_focus_camera():
		return false
	if auto_select_first_mode:
		return select_mode(Mode.FIRST_PERSON)
	return true
# gdlint:enable=max-returns


## Selects one comparison mode and activates exactly one camera via
## CameraAuthority.
func select_mode(mode: int) -> bool:
	var cam: Camera3D = get_camera_for_mode(mode)
	if cam == null:
		push_error("Camera comparison mode has no camera: %s" % mode)
		return false
	var authority: Node = _camera_authority()
	if authority == null or not authority.has_method("request_current"):
		push_error("Camera comparison requires CameraAuthority")
		return false
	var ok: bool = bool(authority.call("request_current", cam, _source_for_mode(mode)))
	if ok:
		_mode = mode
	return ok


## Advances to the next comparison camera.
func select_next_mode() -> bool:
	var next_mode: int = (_mode + 1) % MODE_COUNT
	return select_mode(next_mode)


## Returns the selected comparison mode.
func get_mode() -> int:
	return _mode


## Returns mode names in presentation order for debug UI or screenshot tooling.
func get_mode_names() -> PackedStringArray:
	return PackedStringArray(["first_person", "fixed_angle", "counter_focus"])


## Returns visual-review metadata for the three captures this scene is meant
## to produce.
func get_visual_evidence_rows() -> Array[Dictionary]:
	return [
		{
			"mode": "first_person",
			"source": String(SOURCE_FIRST_PERSON),
			"label": "First-person inspection view",
			"scope": "reference_corner",
			"camera_path": _camera_path_for_mode(Mode.FIRST_PERSON),
			"focus": _FIRST_PERSON_FOCUS_PATH,
			"anchors": [
				"Checkout",
				"StoreSessionDayEndTrigger",
				"ReadabilityProps/CheckoutCounterDressing",
				"ReadabilityProps/ZoneIdentity/ReferenceCornerWallPanel",
			],
			"suggested_filename": "camera_compare_first_person.png",
		},
		{
			"mode": "fixed_angle",
			"source": String(SOURCE_FIXED_ANGLE),
			"label": "Fixed-angle store view",
			"scope": "reference_corner",
			"camera_path": _camera_path_for_mode(Mode.FIXED_ANGLE),
			"focus": "ReadabilityProps/ZoneIdentity/ReferenceCornerFloorInset",
			"anchors": [
				"Checkout",
				"StoreSessionRestockShelf",
				"ReadabilityProps/DayOneRouteMarkers",
				"ReadabilityProps/ZoneIdentity/ReferenceCornerFloorInset",
			],
			"suggested_filename": "camera_compare_fixed_angle.png",
		},
		{
			"mode": "counter_focus",
			"source": String(SOURCE_COUNTER_FOCUS),
			"label": "Counter-focused customer view",
			"scope": "reference_corner",
			"camera_path": _camera_path_for_mode(Mode.COUNTER_FOCUS),
			"focus": _COUNTER_FOCUS_PATH,
			"anchors": [
				"FrontLaneQueue",
				"StoreSessionDayOneCustomer",
				"ReadabilityProps/CheckoutCounterDressing/CustomerServiceSpotMat",
			],
			"suggested_filename": "camera_compare_counter_focus.png",
		},
	]


## Returns the camera backing a comparison mode.
func get_camera_for_mode(mode: int) -> Camera3D:
	var value: Variant = _cameras.get(mode, null)
	if value is Camera3D and is_instance_valid(value):
		return value as Camera3D
	return null


## Returns the loaded store preview root.
func get_store_root() -> Node3D:
	return _store_root


func _build_first_person_camera() -> bool:
	var focus: Node3D = _required_anchor(_FIRST_PERSON_FOCUS_PATH)
	if focus == null:
		return false
	var cam := Camera3D.new()
	cam.name = "FirstPersonComparisonCamera"
	cam.fov = 75.0
	cam.near = 0.05
	add_child(cam)
	cam.global_position = _FIRST_PERSON_CAMERA_POSITION
	cam.look_at(focus.global_position, Vector3.UP)
	cam.add_to_group(&"cameras")
	_cameras[Mode.FIRST_PERSON] = cam
	return true


func _build_fixed_angle_camera() -> bool:
	var controller: PlayerController = (
		_store_root.get_node_or_null(FIXED_CONTROLLER_PATH) as PlayerController
	)
	if controller == null:
		push_error("Camera comparison requires the store PlayerController")
		return false
	controller.process_mode = Node.PROCESS_MODE_DISABLED
	controller.set_input_listening(false)
	controller.set_pivot(_FIXED_PIVOT)
	controller.set_camera_angles(-32.0, 54.0)
	controller.set_zoom_distance(12.0)
	var cam: Camera3D = controller.get_camera()
	if cam == null:
		push_error("Camera comparison fixed-angle camera is missing")
		return false
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 11.0
	cam.add_to_group(&"cameras")
	_cameras[Mode.FIXED_ANGLE] = cam
	return true


func _build_counter_focus_camera() -> bool:
	var focus: Node3D = _required_anchor(_COUNTER_FOCUS_PATH)
	if focus == null:
		return false
	var cam := Camera3D.new()
	cam.name = "CounterFocusComparisonCamera"
	cam.fov = 65.0
	cam.near = 0.05
	add_child(cam)
	cam.global_position = _COUNTER_CAMERA_POSITION
	cam.look_at(focus.global_position, Vector3.UP)
	cam.add_to_group(&"cameras")
	_cameras[Mode.COUNTER_FOCUS] = cam
	return true


func _required_anchor(path: String) -> Node3D:
	if _store_root == null:
		return null
	var node: Node3D = _store_root.get_node_or_null(NodePath(path)) as Node3D
	if node == null:
		push_error("Camera comparison anchor missing: %s" % path)
	return node


func _camera_path_for_mode(mode: int) -> String:
	var cam: Camera3D = get_camera_for_mode(mode)
	return str(cam.get_path()) if cam != null else ""


func _source_for_mode(mode: int) -> StringName:
	match mode:
		Mode.FIRST_PERSON:
			return SOURCE_FIRST_PERSON
		Mode.FIXED_ANGLE:
			return SOURCE_FIXED_ANGLE
		Mode.COUNTER_FOCUS:
			return SOURCE_COUNTER_FOCUS
		_:
			return &"camera_comparison"


func _camera_authority() -> Node:
	var tree: SceneTree = get_tree()
	if tree == null:
		return null
	return tree.root.get_node_or_null("CameraAuthority")
