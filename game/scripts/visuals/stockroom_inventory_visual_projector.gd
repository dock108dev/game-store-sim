## Visual-only projection of stockroom inventory state onto the generated shell.
class_name StockroomInventoryVisualProjector
extends Node3D

const RetailDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/retail_detail_builder.gd"
)
const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)

const ROOT_NAME: StringName = &"StockroomInventoryState"
const DEFAULT_STORE_ID: StringName = &"retro_games"
const MAX_PICKUP_BOXES: int = 3
const MAX_RACK_GROUPS: int = 4
const MAX_RESERVE_CARTONS: int = 4

const STATUS_EMPTY: StringName = &"empty"
const STATUS_PICKUP_READY: StringName = &"pickup_ready"
const STATUS_BACKROOM: StringName = &"backroom_inventory"
const STATUS_RESERVE: StringName = &"reserve_stock"
const STATUS_HOLD: StringName = &"hold"
const STATUS_TRADE_IN: StringName = &"trade_in_intake"
const STATUS_USED: StringName = &"used_bay"

var _store_root: Node = null
var _inventory_system: InventorySystem = null
var _store_id: StringName = DEFAULT_STORE_ID
var _fallback_backroom_count: int = -1
var _event_hold_count: int = 0
var _event_expired_hold_count: int = 0
var _trade_in_pending: bool = false
var _trade_in_recent_count: int = 0


func setup(store_root: Node, inventory_system: InventorySystem, store_id: StringName) -> void:
	_store_root = store_root
	_inventory_system = inventory_system
	_store_id = _resolve_store_id(store_id)
	name = ROOT_NAME
	set_meta("visual_only", true)
	set_meta("stockroom_inventory_projection", true)
	_connect_event_signals()
	refresh()


func _exit_tree() -> void:
	_disconnect_event_signals()


func refresh() -> void:
	_clear_children()
	var snapshot: Dictionary = _build_snapshot()
	set_meta("stockroom_snapshot", snapshot.duplicate(true))
	_render_pickup_bay(snapshot)
	_render_backroom_racks(snapshot)
	_render_reserve_stock(snapshot)
	_render_holds(snapshot)
	_render_trade_in_intake(snapshot)
	_render_summary_label(snapshot)


func _connect_event_signals() -> void:
	if not EventBus.inventory_changed.is_connected(_on_inventory_changed):
		EventBus.inventory_changed.connect(_on_inventory_changed)
	if not EventBus.inventory_updated.is_connected(_on_inventory_updated):
		EventBus.inventory_updated.connect(_on_inventory_updated)
	if not EventBus.store_backroom_count_changed.is_connected(_on_store_backroom_count_changed):
		EventBus.store_backroom_count_changed.connect(_on_store_backroom_count_changed)
	if not EventBus.hold_added.is_connected(_on_hold_added):
		EventBus.hold_added.connect(_on_hold_added)
	if not EventBus.hold_fulfilled.is_connected(_on_hold_terminal):
		EventBus.hold_fulfilled.connect(_on_hold_terminal)
	if not EventBus.hold_expired.is_connected(_on_hold_expired):
		EventBus.hold_expired.connect(_on_hold_expired)
	if not EventBus.trade_in_initiated.is_connected(_on_trade_in_initiated):
		EventBus.trade_in_initiated.connect(_on_trade_in_initiated)
	if not EventBus.trade_in_accepted.is_connected(_on_trade_in_accepted):
		EventBus.trade_in_accepted.connect(_on_trade_in_accepted)
	if not EventBus.trade_in_rejected.is_connected(_on_trade_in_rejected):
		EventBus.trade_in_rejected.connect(_on_trade_in_rejected)
	if not EventBus.trade_in_completed.is_connected(_on_trade_in_completed):
		EventBus.trade_in_completed.connect(_on_trade_in_completed)


func _disconnect_event_signals() -> void:
	if EventBus.inventory_changed.is_connected(_on_inventory_changed):
		EventBus.inventory_changed.disconnect(_on_inventory_changed)
	if EventBus.inventory_updated.is_connected(_on_inventory_updated):
		EventBus.inventory_updated.disconnect(_on_inventory_updated)
	if EventBus.store_backroom_count_changed.is_connected(_on_store_backroom_count_changed):
		EventBus.store_backroom_count_changed.disconnect(_on_store_backroom_count_changed)
	if EventBus.hold_added.is_connected(_on_hold_added):
		EventBus.hold_added.disconnect(_on_hold_added)
	if EventBus.hold_fulfilled.is_connected(_on_hold_terminal):
		EventBus.hold_fulfilled.disconnect(_on_hold_terminal)
	if EventBus.hold_expired.is_connected(_on_hold_expired):
		EventBus.hold_expired.disconnect(_on_hold_expired)
	if EventBus.trade_in_initiated.is_connected(_on_trade_in_initiated):
		EventBus.trade_in_initiated.disconnect(_on_trade_in_initiated)
	if EventBus.trade_in_accepted.is_connected(_on_trade_in_accepted):
		EventBus.trade_in_accepted.disconnect(_on_trade_in_accepted)
	if EventBus.trade_in_rejected.is_connected(_on_trade_in_rejected):
		EventBus.trade_in_rejected.disconnect(_on_trade_in_rejected)
	if EventBus.trade_in_completed.is_connected(_on_trade_in_completed):
		EventBus.trade_in_completed.disconnect(_on_trade_in_completed)


func _on_inventory_changed() -> void:
	refresh()


func _on_inventory_updated(updated_store_id: StringName) -> void:
	if _resolve_store_id(updated_store_id) == _store_id:
		refresh()


func _on_store_backroom_count_changed(count: int) -> void:
	_fallback_backroom_count = maxi(count, 0)
	refresh()


func _on_hold_added(store_id: StringName, _slip_id: String, _item_id: StringName, _customer_name: String) -> void:
	if _resolve_store_id(store_id) != _store_id:
		return
	_event_hold_count += 1
	refresh()


func _on_hold_terminal(store_id: StringName, _slip_id: String, _item_id: StringName, _reason: String) -> void:
	if _resolve_store_id(store_id) != _store_id:
		return
	_event_hold_count = maxi(_event_hold_count - 1, 0)
	refresh()


func _on_hold_expired(store_id: StringName, _slip_id: String, _item_id: StringName) -> void:
	if _resolve_store_id(store_id) != _store_id:
		return
	_event_hold_count = maxi(_event_hold_count - 1, 0)
	_event_expired_hold_count += 1
	refresh()


func _on_trade_in_initiated(_customer_id: String) -> void:
	_trade_in_pending = true
	refresh()


func _on_trade_in_accepted(_customer_id: String, _instance_id: String, _credit_value: float) -> void:
	_trade_in_pending = false
	_trade_in_recent_count += 1
	refresh()


func _on_trade_in_rejected(_customer_id: String) -> void:
	_trade_in_pending = false
	refresh()


func _on_trade_in_completed(_customer_id: String, _instance_id: String) -> void:
	_trade_in_pending = false
	_trade_in_recent_count += 1
	refresh()


func _build_snapshot() -> Dictionary:
	var rows: Array[Dictionary] = []
	if _inventory_system != null:
		rows = _inventory_system.get_store_inventory(_store_id)
	var snapshot: Dictionary = {
		"store_id": String(_store_id),
		"backroom": 0,
		"shelf": 0,
		"damaged": 0,
		"held": 0,
		"counter": 0,
		"unknown": 0,
		"backroom_groups": {},
		"hold_count": _active_hold_count(),
		"expired_hold_count": _expired_hold_count(),
		"trade_in_pending": _trade_in_pending,
		"trade_in_recent": _trade_in_recent_count,
	}
	for entry: Dictionary in rows:
		_add_inventory_row(snapshot, entry)
	if rows.is_empty() and _fallback_backroom_count >= 0:
		snapshot["backroom"] = _fallback_backroom_count
		(snapshot["backroom_groups"] as Dictionary)["Backroom stock"] = {
			"count": _fallback_backroom_count,
			"category": "stock",
			"display_name": "Backroom stock",
			"definition_id": "",
			"location": "backroom",
		}
	return snapshot


func _add_inventory_row(snapshot: Dictionary, entry: Dictionary) -> void:
	var loc: String = str(entry.get("location", ""))
	var item: ItemInstance = entry.get("item", null) as ItemInstance
	var category: String = "unknown"
	var display_name: String = str(entry.get("display_name", "Unknown"))
	var definition_id: String = str(entry.get("definition_id", ""))
	if item == null or item.definition == null:
		snapshot["unknown"] = int(snapshot.get("unknown", 0)) + 1
	else:
		category = item.definition.category
		display_name = item.definition.item_name
		definition_id = item.definition.id
	if loc == "backroom":
		snapshot["backroom"] = int(snapshot.get("backroom", 0)) + 1
		_increment_backroom_group(snapshot, definition_id, display_name, category, loc)
	elif loc.begins_with("shelf:"):
		snapshot["shelf"] = int(snapshot.get("shelf", 0)) + 1
	elif loc == InventorySystem.DAMAGED_BIN_LOCATION:
		snapshot["damaged"] = int(snapshot.get("damaged", 0)) + 1
	elif loc.contains("hold") or loc.contains("held"):
		snapshot["held"] = int(snapshot.get("held", 0)) + 1
	elif loc.begins_with("counter") or loc.contains("trade") or loc.contains("intake"):
		snapshot["counter"] = int(snapshot.get("counter", 0)) + 1


func _increment_backroom_group(
	snapshot: Dictionary, definition_id: String, display_name: String, category: String, location: String
) -> void:
	var key: String = definition_id if not definition_id.is_empty() else display_name
	if key.is_empty():
		key = "Unknown"
	var groups: Dictionary = snapshot["backroom_groups"] as Dictionary
	if not groups.has(key):
		groups[key] = {
			"count": 0,
			"category": category,
			"display_name": display_name if not display_name.is_empty() else "Unknown item",
			"definition_id": definition_id,
			"location": location,
		}
	groups[key]["count"] = int(groups[key].get("count", 0)) + 1


func _render_pickup_bay(snapshot: Dictionary) -> void:
	var backroom_count: int = int(snapshot.get("backroom", 0))
	var ready_count: int = mini(backroom_count, MAX_PICKUP_BOXES)
	if ready_count <= 0:
		_add_status_box(
			"EmptyPickupBayMarker",
			Vector3(4.90, 0.12, -8.70),
			Vector3(0.64, 0.035, 0.36),
			STATUS_EMPTY
		)
		return
	for index: int in range(ready_count):
		_add_status_box(
			"PickupReadyBox%02d" % index,
			Vector3(4.58 + float(index) * 0.32, 0.25, -8.68),
			Vector3(0.24, 0.28, 0.28),
			STATUS_PICKUP_READY
		)


func _render_backroom_racks(snapshot: Dictionary) -> void:
	var groups: Array[Dictionary] = _sorted_backroom_groups(snapshot)
	if groups.is_empty():
		_add_status_box(
			"BackroomRackEmptyMarker",
			Vector3(4.20, 1.17, -9.28),
			Vector3(0.32, 0.05, 0.20),
			STATUS_EMPTY
		)
		return
	for index: int in range(mini(groups.size(), MAX_RACK_GROUPS)):
		var column: int = index % 2
		var row: int = index / 2
		var pos := Vector3(3.86 + float(column) * 0.52, 1.18 + float(row) * 0.42, -9.20)
		_add_status_box("BackroomInventoryBox%02d" % index, pos, Vector3(0.32, 0.22, 0.26), STATUS_BACKROOM)


func _render_reserve_stock(snapshot: Dictionary) -> void:
	var backroom_count: int = int(snapshot.get("backroom", 0))
	var reserve_count: int = clampi(backroom_count - MAX_PICKUP_BOXES, 0, MAX_RESERVE_CARTONS)
	if reserve_count <= 0:
		_add_status_box(
			"ReserveStockEmptyMarker",
			Vector3(3.55, 0.93, -9.05),
			Vector3(0.24, 0.035, 0.24),
			STATUS_EMPTY
		)
		return
	for index: int in range(reserve_count):
		_add_status_box(
			"ReserveStockCarton%02d" % index,
			Vector3(3.35 + float(index) * 0.28, 0.64, -8.92),
			Vector3(0.22, 0.26, 0.28),
			STATUS_RESERVE
		)


func _render_holds(snapshot: Dictionary) -> void:
	var hold_count: int = int(snapshot.get("hold_count", 0)) + int(snapshot.get("held", 0))
	var expired_count: int = int(snapshot.get("expired_hold_count", 0))
	if hold_count <= 0 and expired_count <= 0:
		_add_status_box(
			"HoldBayEmptyMarker",
			Vector3(2.16, 0.18, -7.32),
			Vector3(0.34, 0.05, 0.30),
			STATUS_EMPTY
		)
		return
	for index: int in range(mini(hold_count, 3)):
		_add_status_box(
			"HoldBayBox%02d" % index,
			Vector3(2.08 + float(index) * 0.24, 0.34, -7.32),
			Vector3(0.18, 0.20, 0.24),
			STATUS_HOLD
		)
	if expired_count > 0:
		_add_status_box("ExpiredHoldSlipStack", Vector3(2.38, 0.19, -7.00), Vector3(0.28, 0.035, 0.18), STATUS_USED)


func _render_trade_in_intake(snapshot: Dictionary) -> void:
	var damaged_count: int = int(snapshot.get("damaged", 0))
	var counter_count: int = int(snapshot.get("counter", 0))
	var intake_count: int = damaged_count + counter_count + int(snapshot.get("trade_in_recent", 0))
	var pending: bool = bool(snapshot.get("trade_in_pending", false))
	if intake_count <= 0 and not pending:
		_add_status_box("TradeInIntakeEmptyTray", Vector3(5.62, 0.89, -7.86), Vector3(0.30, 0.025, 0.18), STATUS_EMPTY)
		return
	_add_status_box("TradeInIntakeTray", Vector3(5.62, 0.90, -7.86), Vector3(0.34, 0.045, 0.24), STATUS_TRADE_IN)
	_add_status_box("TradeInIntakeItem", Vector3(5.62, 0.96, -7.86), Vector3(0.20, 0.10, 0.16), STATUS_TRADE_IN)


func _render_summary_label(snapshot: Dictionary) -> void:
	var top_group: Dictionary = _top_summary_group(snapshot)
	var group_text: String = str(top_group.get("display_name", "No item"))
	if top_group.is_empty():
		group_text = "No item"
	else:
		group_text = "%s %s x%d" % [
			str(top_group.get("location", "backroom")).capitalize(),
			str(top_group.get("category", "stock")).capitalize(),
			int(top_group.get("count", 0)),
		]
	var text: String = "Backroom x%d shelf x%d\n%s\nUnknown x%d" % [
		int(snapshot.get("backroom", 0)),
		int(snapshot.get("shelf", 0)),
		group_text,
		int(snapshot.get("unknown", 0)),
	]
	_add_stockroom_label("StockroomInventorySummaryLabel", text, Vector3(5.78, 1.86, -6.86), snapshot)


func _sorted_backroom_groups(snapshot: Dictionary) -> Array[Dictionary]:
	var groups: Array[Dictionary] = []
	for raw_group: Variant in (snapshot.get("backroom_groups", {}) as Dictionary).values():
		if raw_group is Dictionary:
			groups.append((raw_group as Dictionary).duplicate(true))
	groups.sort_custom(_sort_group_desc)
	return groups


func _top_summary_group(snapshot: Dictionary) -> Dictionary:
	var groups: Array[Dictionary] = _sorted_backroom_groups(snapshot)
	if groups.is_empty():
		return {}
	return groups[0]


func _sort_group_desc(left: Dictionary, right: Dictionary) -> bool:
	var left_count: int = int(left.get("count", 0))
	var right_count: int = int(right.get("count", 0))
	if left_count != right_count:
		return left_count > right_count
	return str(left.get("display_name", "")) < str(right.get("display_name", ""))


func _active_hold_count() -> int:
	var count: int = _event_hold_count
	var hold_list: HoldList = _hold_list()
	if hold_list == null:
		return count
	for slip: HoldSlip in hold_list.get_all_slips():
		if slip.is_active() or slip.is_flagged():
			count += 1
	return count


func _expired_hold_count() -> int:
	var count: int = _event_expired_hold_count
	var hold_list: HoldList = _hold_list()
	if hold_list == null:
		return count
	for slip: HoldSlip in hold_list.get_all_slips():
		if slip.status == HoldSlip.Status.EXPIRED:
			count += 1
	return count


func _hold_list() -> HoldList:
	if _store_root == null:
		return null
	var holds_manager: Object = _store_root.get("holds") as Object
	if holds_manager == null or not holds_manager.has_method("get_hold_list"):
		return null
	return holds_manager.call("get_hold_list") as HoldList


func _add_status_box(name_base: String, position: Vector3, size: Vector3, status: StringName) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = name_base
	node.mesh = mesh
	node.position = position
	node.material_override = _status_material(status)
	node.set_meta("visual_only", true)
	node.set_meta("stockroom_inventory_status", status)
	node.set_meta("stockroom_inventory_projection", true)
	StarterDetailBuilderScript.apply_visual_metadata(node, _family_for_status(status), StarterDetailBuilderScript.ROLE_PANEL)
	add_child(node)
	return node


func _add_stockroom_label(
	name_base: String, label_text: String, position: Vector3, payload: Dictionary = {}
) -> Node3D:
	var label: Node3D = RetailDetailBuilderScript.stockroom_label(label_text)
	label.name = name_base
	label.position = position
	label.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	label.set_meta("stockroom_inventory_projection", true)
	label.set_meta("stockroom_inventory_payload", payload.duplicate(true))
	add_child(label)
	return label


func _status_material(status: StringName) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.resource_name = "stockroom_%s" % String(status)
	match status:
		STATUS_PICKUP_READY:
			mat.albedo_color = Color(0.95, 0.72, 0.24, 1.0)
			mat.emission_enabled = true
			mat.emission = Color(0.50, 0.30, 0.08, 1.0)
			mat.emission_energy_multiplier = 0.25
		STATUS_BACKROOM:
			mat.albedo_color = Color(0.54, 0.44, 0.28, 1.0)
		STATUS_RESERVE:
			mat.albedo_color = Color(0.36, 0.30, 0.23, 1.0)
		STATUS_HOLD:
			mat.albedo_color = Color(0.38, 0.55, 0.86, 1.0)
		STATUS_TRADE_IN:
			mat.albedo_color = Color(0.40, 0.72, 0.56, 1.0)
		STATUS_USED:
			mat.albedo_color = Color(0.50, 0.48, 0.44, 1.0)
		_:
			mat.albedo_color = Color(0.18, 0.20, 0.20, 0.42)
	return mat


func _family_for_status(status: StringName) -> StringName:
	match status:
		STATUS_PICKUP_READY:
			return StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM
		STATUS_BACKROOM, STATUS_RESERVE:
			return StarterDetailBuilderScript.FAMILY_CARDBOARD
		STATUS_HOLD:
			return StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL
		STATUS_TRADE_IN:
			return StarterDetailBuilderScript.FAMILY_RUBBER
		STATUS_USED, STATUS_EMPTY:
			return StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT
	return StarterDetailBuilderScript.FAMILY_PAPER


func _clear_children() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()


func _resolve_store_id(store_id: StringName) -> StringName:
	if not String(store_id).is_empty():
		return store_id
	var active: StringName = GameManager.get_active_store_id()
	if not String(active).is_empty():
		return active
	return DEFAULT_STORE_ID
