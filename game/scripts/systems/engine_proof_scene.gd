extends Node3D

const EngineProofState = preload("res://scripts/systems/engine_proof_state.gd")

var state: EngineProofState = EngineProofState.new()
var player: CharacterBody3D
var camera: Camera3D
var item_nodes: Dictionary = {}
var fixture_nodes: Dictionary = {}
var customer_node: Node3D
var prompt_label: Label
var status_label: Label
var report_label: Label
var carried_visual: MeshInstance3D
var yaw: float = 0.0
var pitch: float = 0.0
var mouse_captured: bool = false

func _ready() -> void:
    state.setup_new_game()
    _build_world()
    _build_player()
    _build_ui()
    _sync_all_visuals()
    _set_status("Engine proof ready. E pickup/place/sell, P price, F move shelf, O open, R report, K save, L load.")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        mouse_captured = true
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        mouse_captured = false
    if event is InputEventMouseMotion and mouse_captured:
        yaw -= event.relative.x * 0.0025
        pitch = clamp(pitch - event.relative.y * 0.0025, -1.2, 1.2)
        player.rotation.y = yaw
        camera.rotation.x = pitch

func _physics_process(delta: float) -> void:
    _update_player(delta)
    if Input.is_action_just_pressed("interact"):
        _handle_interact()
    if Input.is_action_just_pressed("price_item"):
        _handle_price()
    if Input.is_action_just_pressed("open_store"):
        _handle_open_store()
    if Input.is_action_just_pressed("move_fixture"):
        _handle_move_fixture()
    if Input.is_action_just_pressed("save_game"):
        _handle_save()
    if Input.is_action_just_pressed("load_game"):
        _handle_load()
    if Input.is_action_just_pressed("close_day"):
        _handle_close_day()
    _update_prompt()

func _build_world() -> void:
    _add_box("MallFloor", Vector3(14.0, 0.1, 4.0), Vector3(0.0, -0.05, 4.0), Color(0.55, 0.52, 0.47))
    _add_box("StoreFloor", Vector3(10.0, 0.1, 10.0), Vector3(0.0, -0.05, -2.0), Color(0.22, 0.30, 0.34))
    _add_box("BackroomFloor", Vector3(5.0, 0.1, 3.0), Vector3(0.0, -0.04, -8.4), Color(0.25, 0.23, 0.22))
    _add_box("LeftWall", Vector3(0.2, 2.8, 10.0), Vector3(-5.1, 1.35, -2.0), Color(0.72, 0.76, 0.72))
    _add_box("RightWall", Vector3(0.2, 2.8, 10.0), Vector3(5.1, 1.35, -2.0), Color(0.72, 0.76, 0.72))
    _add_box("BackWall", Vector3(10.0, 2.8, 0.2), Vector3(0.0, 1.35, -7.0), Color(0.66, 0.69, 0.66))
    _add_box("StorefrontGlassLeft", Vector3(3.6, 2.6, 0.08), Vector3(-3.2, 1.3, 2.9), Color(0.45, 0.72, 0.88, 0.45))
    _add_box("StorefrontGlassRight", Vector3(3.6, 2.6, 0.08), Vector3(3.2, 1.3, 2.9), Color(0.45, 0.72, 0.88, 0.45))
    _add_box("CounterRegister", Vector3(2.0, 1.0, 0.8), Vector3(2.7, 0.5, -0.6), Color(0.15, 0.16, 0.16))
    _add_box("RegisterScreen", Vector3(0.55, 0.35, 0.12), Vector3(2.35, 1.15, -0.85), Color(0.08, 0.18, 0.22))
    _add_box("BackroomComputer", Vector3(0.8, 0.5, 0.18), Vector3(-1.8, 1.0, -8.0), Color(0.08, 0.12, 0.16))
    _add_box("StarterShipmentBox", Vector3(1.2, 0.7, 0.8), Vector3(-1.0, 0.35, -6.2), Color(0.56, 0.38, 0.18))
    _add_text_sign("OpenClosedSign", "CLOSED", Vector3(0.0, 1.9, 2.82), Color(0.95, 0.82, 0.28))
    var sun: DirectionalLight3D = DirectionalLight3D.new()
    sun.name = "RetailLight"
    sun.light_energy = 1.4
    sun.rotation_degrees = Vector3(-55.0, 35.0, 0.0)
    add_child(sun)

func _build_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0.0, 0.9, 4.8)
    add_child(player)
    var collision: CollisionShape3D = CollisionShape3D.new()
    var capsule: CapsuleShape3D = CapsuleShape3D.new()
    capsule.height = 1.7
    capsule.radius = 0.32
    collision.shape = capsule
    player.add_child(collision)
    camera = Camera3D.new()
    camera.name = "Camera"
    camera.position = Vector3(0.0, 0.65, 0.0)
    camera.current = true
    player.add_child(camera)

func _build_ui() -> void:
    var canvas: CanvasLayer = CanvasLayer.new()
    add_child(canvas)
    var panel: PanelContainer = PanelContainer.new()
    panel.position = Vector2(16, 16)
    panel.size = Vector2(600, 128)
    canvas.add_child(panel)
    var box: VBoxContainer = VBoxContainer.new()
    panel.add_child(box)
    status_label = Label.new()
    status_label.text = ""
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(status_label)
    prompt_label = Label.new()
    prompt_label.text = ""
    prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(prompt_label)
    report_label = Label.new()
    report_label.text = ""
    report_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(report_label)

func _sync_all_visuals() -> void:
    for child: Node in get_children():
        if child.name.begins_with("ItemVisual_") or child.name.begins_with("FixtureVisual_"):
            child.queue_free()
    item_nodes = {}
    fixture_nodes = {}
    for fixture_id: String in state.fixtures.keys():
        _spawn_fixture_visual(fixture_id)
    for item_id: String in state.items.keys():
        _spawn_item_visual(item_id)
    _update_carried_visual()

func _spawn_fixture_visual(fixture_id: String) -> void:
    var fixture: Dictionary = state.fixtures[fixture_id]
    var pos: Array = fixture["position"]
    var node: StaticBody3D = _add_box("FixtureVisual_%s" % fixture_id, Vector3(2.6, 1.2, 0.35), Vector3(float(pos[0]), float(pos[1]), float(pos[2])), Color(0.08, 0.09, 0.10))
    node.rotation_degrees.y = float(fixture["rotation_y"])
    fixture_nodes[fixture_id] = node
    _add_text_sign("ShelfHeader_%s" % fixture_id, String(fixture["display_name"]), node.position + Vector3(0.0, 0.95, -0.22), Color(0.95, 0.78, 0.25))

func _spawn_item_visual(item_id: String) -> void:
    var item: Dictionary = state.items[item_id]
    if bool(item["is_sold"]):
        return
    var location: Dictionary = item["location"]
    var pos: Vector3 = Vector3.ZERO
    if String(location["type"]) == "shipment_box":
        var item_index: int = int(item_id.right(6)) - 1
        pos = Vector3(-1.45 + float(item_index % 4) * 0.28, 0.83 + float(item_index / 4) * 0.08, -6.2)
    elif String(location["type"]) == "fixture_slot":
        pos = _slot_world_position(String(location["fixture_id"]), String(location["slot_id"]))
    elif String(location["type"]) == "player_hand":
        return
    else:
        return
    var color: Color = Color(0.15, 0.38, 0.84) if String(item["new_or_used"]) == "new" else Color(0.86, 0.28, 0.23)
    if String(item["category"]) == "accessory_box":
        color = Color(0.32, 0.70, 0.35)
    var node: StaticBody3D = _add_box("ItemVisual_%s" % item_id, Vector3(0.18, 0.32, 0.04), pos, color)
    item_nodes[item_id] = node

func _slot_world_position(fixture_id: String, slot_id: String) -> Vector3:
    var fixture: Dictionary = state.fixtures[fixture_id]
    var pos: Array = fixture["position"]
    var slot_number: int = int(slot_id.trim_prefix("slot_")) - 1
    var x_offset: float = -1.05 + float(slot_number % 6) * 0.42
    var y_offset: float = 0.20 + float(slot_number / 6) * 0.34
    return Vector3(float(pos[0]) + x_offset, float(pos[1]) + y_offset, float(pos[2]) - 0.24)

func _update_player(delta: float) -> void:
    var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var forward: Vector3 = -player.global_transform.basis.z
    var right: Vector3 = player.global_transform.basis.x
    var direction: Vector3 = (right * input_vector.x + forward * input_vector.y)
    direction.y = 0.0
    direction = direction.normalized()
    player.velocity.x = direction.x * 4.0
    player.velocity.z = direction.z * 4.0
    player.move_and_slide()

func _handle_interact() -> void:
    if state.carried_item_id != "":
        var slot_id: String = state.first_open_slot("used_wall_shelf_01")
        if slot_id != "" and state.stock_carried_item("used_wall_shelf_01", slot_id):
            _set_status("Placed carried case into %s." % slot_id)
            _sync_all_visuals()
            return
    var queued_customer_id: String = _queued_customer_id()
    if queued_customer_id != "":
        var sold_item_id: String = String(state.customers[queued_customer_id]["selected_item_id"])
        if state.complete_sale(queued_customer_id):
            _set_status("Sale complete: %s. Cash now $%.2f." % [state.items[sold_item_id]["display_name"], state.cash])
            _remove_customer_visual()
            _sync_all_visuals()
            return
    var item_id: String = _nearest_available_item()
    if item_id != "" and state.pick_up_item(item_id):
        _set_status("Picked up %s." % state.items[item_id]["display_name"])
        _sync_all_visuals()
        return
    _set_status("Nothing ready for E. Try picking stock near the starter box or selling after a customer queues.")

func _handle_price() -> void:
    if state.carried_item_id == "":
        _set_status("Pick up a used case before pricing.")
        return
    var item_id: String = state.carried_item_id
    var item: Dictionary = state.items[item_id]
    var ok: bool = state.price_used_item(item_id, float(item["suggested_price_max"]))
    if ok:
        _set_status("Priced %s at suggested high: $%.2f." % [item["display_name"], state.items[item_id]["current_price"]])
    else:
        _set_status("%s is new stock with fixed price: $%.2f." % [item["display_name"], item["current_price"]])

func _handle_open_store() -> void:
    if not state.open_store():
        _set_status("Store is already open or past opening phase.")
        return
    _set_status("Store opened. Customer spawning from mall path.")
    var customer_id: String = state.spawn_customer("browser")
    _spawn_customer_visual(customer_id)

func _handle_move_fixture() -> void:
    var moved: bool = state.move_fixture("used_wall_shelf_01", [-1.6, 1.0, -3.2], 12.5)
    if moved:
        _set_status("Moved and rotated Used Wall Shelf. Fixture state is now part of save/load proof.")
        _sync_all_visuals()

func _handle_save() -> void:
    if state.save_game():
        _set_status("Saved engine proof state.")
    else:
        _set_status("Save failed.")

func _handle_load() -> void:
    if state.load_game():
        _set_status("Loaded engine proof state.")
        _sync_all_visuals()
    else:
        _set_status("No save found or load failed.")

func _handle_close_day() -> void:
    if state.close_store():
        var report: Dictionary = state.daily_report()
        report_label.text = "Report: revenue $%.2f, margin $%.2f, sold %d, remaining %d." % [report["revenue"], report["gross_margin"], report["items_sold"], report["items_remaining"]]
        _set_status("Register closed.")
    else:
        _set_status("Close requires the store to be open.")

func _spawn_customer_visual(customer_id: String) -> void:
    _remove_customer_visual()
    customer_node = Node3D.new()
    customer_node.name = "CustomerVisual_%s" % customer_id
    customer_node.position = Vector3(-6.2, 0.9, 4.1)
    add_child(customer_node)
    var body: MeshInstance3D = MeshInstance3D.new()
    var capsule: CapsuleMesh = CapsuleMesh.new()
    capsule.height = 1.45
    capsule.radius = 0.28
    body.mesh = capsule
    body.material_override = _material(Color(0.88, 0.74, 0.55))
    customer_node.add_child(body)
    var tween: Tween = create_tween()
    tween.tween_property(customer_node, "position", Vector3(-1.6, 0.9, -2.7), 2.0)
    tween.tween_callback(func() -> void:
        state.customer_browse_and_queue(customer_id)
        _set_status("Customer browsed shelf and queued at register.")
    )
    tween.tween_property(customer_node, "position", Vector3(2.7, 0.9, -0.1), 1.4)

func _remove_customer_visual() -> void:
    if customer_node != null:
        customer_node.queue_free()
        customer_node = null

func _nearest_available_item() -> String:
    var best_id: String = ""
    var best_distance: float = 999.0
    for item_id: String in item_nodes.keys():
        var node: Node3D = item_nodes[item_id]
        var distance: float = player.global_position.distance_to(node.global_position)
        if distance < best_distance and distance < 3.0:
            best_distance = distance
            best_id = item_id
    return best_id

func _queued_customer_id() -> String:
    for customer_id: String in state.customers.keys():
        if String(state.customers[customer_id]["state"]) == "queued":
            return customer_id
    return ""

func _update_carried_visual() -> void:
    if carried_visual != null:
        carried_visual.queue_free()
        carried_visual = null
    if state.carried_item_id == "":
        return
    carried_visual = MeshInstance3D.new()
    carried_visual.name = "CarriedCase"
    var mesh: BoxMesh = BoxMesh.new()
    mesh.size = Vector3(0.22, 0.32, 0.05)
    carried_visual.mesh = mesh
    carried_visual.material_override = _material(Color(0.95, 0.80, 0.25))
    carried_visual.position = Vector3(0.35, -0.18, -0.65)
    camera.add_child(carried_visual)

func _update_prompt() -> void:
    prompt_label.text = "Cash $%.2f | Phase %s | Carried %s" % [state.cash, state.phase, state.carried_item_id if state.carried_item_id != "" else "none"]

func _set_status(message: String) -> void:
    if status_label != null:
        status_label.text = message
    print(message)

func _add_box(node_name: String, size: Vector3, position: Vector3, color: Color) -> StaticBody3D:
    var body: StaticBody3D = StaticBody3D.new()
    body.name = node_name
    body.position = position
    add_child(body)
    var mesh_instance: MeshInstance3D = MeshInstance3D.new()
    var mesh: BoxMesh = BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.material_override = _material(color)
    body.add_child(mesh_instance)
    var collision: CollisionShape3D = CollisionShape3D.new()
    var shape: BoxShape3D = BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)
    return body

func _add_text_sign(node_name: String, text: String, position: Vector3, color: Color) -> void:
    var label: Label3D = Label3D.new()
    label.name = node_name
    label.text = text
    label.position = position
    label.modulate = color
    label.pixel_size = 0.018
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(label)

func _material(color: Color) -> StandardMaterial3D:
    var material: StandardMaterial3D = StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.82
    if color.a < 1.0:
        material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    return material
