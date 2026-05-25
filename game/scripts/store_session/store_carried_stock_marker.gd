class_name StoreCarriedStockMarker
extends Node3D

const CARRY_LABEL: String = "Starter Stock Box"
const _CAMERA_LOCAL_POSITION: Vector3 = Vector3(0.42, -0.34, -0.92)
const _CAMERA_LOCAL_ROTATION_DEGREES: Vector3 = Vector3(-8.0, -18.0, 4.0)
const _CAMERA_LOCAL_SCALE: Vector3 = Vector3(0.42, 0.42, 0.42)

var _store_root: Node = null
var _label: Label3D = null


## Initializes the first-person stock-box marker and binds it to carry-state signals.
func configure(store_root: Node) -> void:
	_store_root = store_root
	name = "StoreCarriedStockMarker"
	visible = false
	process_mode = Node.PROCESS_MODE_INHERIT
	_build_visuals()
	_connect_carry_signal()
	_sync_from_run_state()


func _enter_tree() -> void:
	_connect_carry_signal()


func _exit_tree() -> void:
	if EventBus.store_carry_changed.is_connected(_on_store_carry_changed):
		EventBus.store_carry_changed.disconnect(_on_store_carry_changed)


func _process(_delta: float) -> void:
	if visible and not bool(StoreSessionState.carrying_stock):
		_set_carry_visible(false)
		return
	if visible:
		_attach_to_view_camera()


func _on_store_carry_changed(text: String) -> void:
	var has_carry: bool = not text.strip_edges().is_empty()
	_set_carry_visible(has_carry)
	if has_carry and _label != null:
		_label.text = text.to_upper()


func _connect_carry_signal() -> void:
	if not EventBus.store_carry_changed.is_connected(_on_store_carry_changed):
		EventBus.store_carry_changed.connect(_on_store_carry_changed)


func _sync_from_run_state() -> void:
	_set_carry_visible(bool(StoreSessionState.carrying_stock))


func _set_carry_visible(has_carry: bool) -> void:
	visible = has_carry
	if not has_carry:
		return
	_attach_to_view_camera()


func _attach_to_view_camera() -> void:
	var camera: Camera3D = _resolve_view_camera()
	if camera == null:
		return
	if get_parent() != camera:
		var old_parent: Node = get_parent()
		if old_parent != null:
			old_parent.remove_child(self)
		camera.add_child(self)
	position = _CAMERA_LOCAL_POSITION
	rotation_degrees = _CAMERA_LOCAL_ROTATION_DEGREES
	scale = _CAMERA_LOCAL_SCALE


func _resolve_view_camera() -> Camera3D:
	if CameraManager != null and is_instance_valid(CameraManager.active_camera):
		return CameraManager.active_camera
	var viewport: Viewport = get_viewport()
	if viewport != null and is_instance_valid(viewport.get_camera_3d()):
		return viewport.get_camera_3d()
	if _store_root != null:
		var authored_camera: Node = _store_root.find_child("StoreCamera", true, false)
		if authored_camera is Camera3D:
			return authored_camera as Camera3D
	return null


func _build_visuals() -> void:
	if get_child_count() > 0:
		return
	var carton_material := StandardMaterial3D.new()
	carton_material.albedo_color = Color(0.55, 0.38, 0.18, 1.0)
	carton_material.roughness = 0.82
	var tape_material := StandardMaterial3D.new()
	tape_material.albedo_color = Color(0.95, 0.72, 0.28, 1.0)
	tape_material.roughness = 0.7
	var label_material := StandardMaterial3D.new()
	label_material.albedo_color = Color(0.10, 0.08, 0.055, 1.0)
	label_material.roughness = 0.85

	var body := MeshInstance3D.new()
	body.name = "UsedGamesBox"
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(0.44, 0.24, 0.32)
	body.mesh = body_mesh
	body.material_override = carton_material
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(body)

	var tape := MeshInstance3D.new()
	tape.name = "PackingTape"
	tape.position = Vector3(0.0, 0.125, 0.0)
	var tape_mesh := BoxMesh.new()
	tape_mesh.size = Vector3(0.47, 0.018, 0.07)
	tape.mesh = tape_mesh
	tape.material_override = tape_material
	tape.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(tape)

	var label_card := MeshInstance3D.new()
	label_card.name = "UsedGamesLabelCard"
	label_card.position = Vector3(0.0, 0.015, -0.163)
	var label_mesh := BoxMesh.new()
	label_mesh.size = Vector3(0.31, 0.13, 0.012)
	label_card.mesh = label_mesh
	label_card.material_override = label_material
	label_card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(label_card)

	_label = Label3D.new()
	_label.name = "StarterStockBoxLabel"
	_label.position = Vector3(0.0, 0.02, -0.172)
	_label.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	_label.pixel_size = 0.0024
	_label.modulate = Color(1.0, 0.92, 0.55, 1.0)
	_label.font_size = 18
	_label.text = CARRY_LABEL.to_upper()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.outline_size = 3
	_label.outline_modulate = Color(0.04, 0.035, 0.03, 1.0)
	_label.shaded = false
	add_child(_label)
