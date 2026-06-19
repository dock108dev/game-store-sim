extends RefCounted
class_name EngineProofState

const SAVE_VERSION: int = 1
const DEFAULT_SAVE_PATH: String = "user://engine_proof_save.json"

var cash: float = 550.0
var day: int = 1
var phase: String = "prep"
var items: Dictionary = {}
var fixtures: Dictionary = {}
var customers: Dictionary = {}
var transactions: Array[Dictionary] = []
var event_log: Array[Dictionary] = []
var carried_item_id: String = ""

func setup_new_game() -> void:
    cash = 550.0
    day = 1
    phase = "prep"
    items = {}
    fixtures = {}
    customers = {}
    transactions = []
    event_log = []
    carried_item_id = ""
    _create_fixture("used_wall_shelf_01", "Used Wall Shelf", "wall_game_shelf", [-2.4, 1.0, -3.0], 0.0, 12)
    _create_fixture("new_release_shelf_01", "New Release Shelf", "freestanding_game_shelf", [2.0, 1.0, -2.6], 90.0, 8)
    _create_starter_items()
    _record("starter_shipment_ready", {"item_count": items.size(), "odd_detail": "Manifest line 7 repeats a crate seal number."})

func _create_fixture(fixture_id: String, display_name: String, fixture_type: String, position: Array, rotation_y: float, slot_count: int) -> void:
    var slots: Dictionary = {}
    for slot_index: int in range(slot_count):
        slots["slot_%02d" % (slot_index + 1)] = ""
    fixtures[fixture_id] = {
        "fixture_id": fixture_id,
        "display_name": display_name,
        "fixture_type": fixture_type,
        "position": position,
        "rotation_y": rotation_y,
        "slots": slots,
        "movable": true
    }

func _create_starter_items() -> void:
    var starter_rows: Array[Dictionary] = [
        {"product_id": "sky_cart_rally", "name": "Sky Cart Rally", "platform": "FoxBox", "used": true, "cost": 8.0, "price": 19.99, "min": 17.99, "max": 22.99},
        {"product_id": "moon_mall_brawlers", "name": "Moon Mall Brawlers", "platform": "FoxBox", "used": true, "cost": 6.0, "price": 15.99, "min": 13.99, "max": 18.99},
        {"product_id": "starline_goal", "name": "Starline Goal", "platform": "Orbit 64", "used": true, "cost": 5.5, "price": 14.99, "min": 12.99, "max": 17.99},
        {"product_id": "backlot_quest", "name": "Backlot Quest", "platform": "Orbit 64", "used": true, "cost": 7.5, "price": 18.99, "min": 16.99, "max": 21.99},
        {"product_id": "paper_dragon_dx", "name": "Paper Dragon DX", "platform": "FoxBox", "used": true, "cost": 9.0, "price": 24.99, "min": 22.99, "max": 29.99},
        {"product_id": "signal_tower_tactics", "name": "Signal Tower Tactics", "platform": "Orbit 64", "used": true, "cost": 10.0, "price": 27.99, "min": 24.99, "max": 31.99},
        {"product_id": "pocket_circuit", "name": "Pocket Circuit", "platform": "FoxBox", "used": true, "cost": 4.0, "price": 11.99, "min": 9.99, "max": 13.99},
        {"product_id": "harbor_pinball", "name": "Harbor Pinball", "platform": "Orbit 64", "used": true, "cost": 3.5, "price": 9.99, "min": 8.99, "max": 12.99},
        {"product_id": "launch_star_alpha", "name": "Launch Star Alpha", "platform": "Prism GS", "used": false, "cost": 38.0, "price": 49.99, "min": 49.99, "max": 49.99},
        {"product_id": "launch_star_alpha", "name": "Launch Star Alpha", "platform": "Prism GS", "used": false, "cost": 38.0, "price": 49.99, "min": 49.99, "max": 49.99},
        {"product_id": "neon_quest_ii", "name": "Neon Quest II", "platform": "Prism GS", "used": false, "cost": 36.0, "price": 49.99, "min": 49.99, "max": 49.99},
        {"product_id": "counter_cable_pack", "name": "Counter Cable Pack", "platform": "Universal", "used": false, "cost": 6.0, "price": 12.99, "min": 12.99, "max": 12.99}
    ]
    for row_index: int in range(starter_rows.size()):
        var row: Dictionary = starter_rows[row_index]
        var item_id: String = "item_%06d" % (row_index + 1)
        var new_or_used: String = "used" if row["used"] else "new"
        items[item_id] = {
            "item_id": item_id,
            "product_id": row["product_id"],
            "display_name": row["name"],
            "platform": row["platform"],
            "category": "game_case" if row["product_id"] != "counter_cable_pack" else "accessory_box",
            "condition": "good" if row["used"] else "new",
            "new_or_used": new_or_used,
            "cost_basis": row["cost"],
            "current_price": row["price"],
            "suggested_price_min": row["min"],
            "suggested_price_max": row["max"],
            "fixed_price": not row["used"],
            "location": {"type": "shipment_box", "fixture_id": "", "slot_id": ""},
            "provenance_state": "odd_manifest_note" if row_index == 6 else "normal",
            "is_sellable": true,
            "is_sold": false
        }

func pick_up_item(item_id: String) -> bool:
    if carried_item_id != "" or not items.has(item_id):
        return false
    var item: Dictionary = items[item_id]
    if item["is_sold"]:
        return false
    _clear_previous_fixture_slot(item_id)
    item["location"] = {"type": "player_hand", "fixture_id": "", "slot_id": ""}
    items[item_id] = item
    carried_item_id = item_id
    _record("item_picked_up", {"item_id": item_id})
    return true

func price_used_item(item_id: String, new_price: float) -> bool:
    if not items.has(item_id):
        return false
    var item: Dictionary = items[item_id]
    if item["fixed_price"]:
        _record("new_price_blocked", {"item_id": item_id, "price": item["current_price"]})
        return false
    item["current_price"] = snappedf(max(new_price, 0.01), 0.01)
    items[item_id] = item
    _record("item_priced", {"item_id": item_id, "price": item["current_price"]})
    return true

func stock_carried_item(fixture_id: String, slot_id: String) -> bool:
    if carried_item_id == "":
        return false
    return stock_item(carried_item_id, fixture_id, slot_id)

func stock_item(item_id: String, fixture_id: String, slot_id: String) -> bool:
    if not items.has(item_id) or not fixtures.has(fixture_id):
        return false
    var fixture: Dictionary = fixtures[fixture_id]
    var slots: Dictionary = fixture["slots"]
    if not slots.has(slot_id) or slots[slot_id] != "":
        return false
    var item: Dictionary = items[item_id]
    if item["is_sold"]:
        return false
    _clear_previous_fixture_slot(item_id)
    slots[slot_id] = item_id
    fixture["slots"] = slots
    fixtures[fixture_id] = fixture
    item["location"] = {"type": "fixture_slot", "fixture_id": fixture_id, "slot_id": slot_id}
    items[item_id] = item
    if carried_item_id == item_id:
        carried_item_id = ""
    _record("item_stocked", {"item_id": item_id, "fixture_id": fixture_id, "slot_id": slot_id})
    return true

func first_open_slot(fixture_id: String) -> String:
    if not fixtures.has(fixture_id):
        return ""
    var slots: Dictionary = fixtures[fixture_id]["slots"]
    for slot_id: String in slots.keys():
        if slots[slot_id] == "":
            return slot_id
    return ""

func move_fixture(fixture_id: String, position: Array, rotation_y: float) -> bool:
    if not fixtures.has(fixture_id):
        return false
    var fixture: Dictionary = fixtures[fixture_id]
    fixture["position"] = position
    fixture["rotation_y"] = rotation_y
    fixtures[fixture_id] = fixture
    _record("fixture_moved", {"fixture_id": fixture_id, "position": position, "rotation_y": rotation_y})
    return true

func open_store() -> bool:
    if phase != "prep":
        return false
    phase = "open"
    _record("store_opened", {"day": day})
    return true

func spawn_customer(archetype_id: String = "browser") -> String:
    if phase != "open":
        return ""
    var customer_id: String = "customer_%04d" % (customers.size() + 1)
    customers[customer_id] = {
        "customer_id": customer_id,
        "archetype_id": archetype_id,
        "state": "walking_mall",
        "spawn_path": "left_mall_path",
        "target_category": "game_case",
        "selected_item_id": ""
    }
    _record("customer_spawned", {"customer_id": customer_id, "archetype_id": archetype_id})
    return customer_id

func customer_browse_and_queue(customer_id: String) -> bool:
    if not customers.has(customer_id):
        return false
    var customer: Dictionary = customers[customer_id]
    var selected_item_id: String = _first_sellable_stocked_item()
    if selected_item_id == "":
        customer["state"] = "leaving"
        customers[customer_id] = customer
        _record("customer_left_no_stock", {"customer_id": customer_id})
        return false
    customer["state"] = "queued"
    customer["selected_item_id"] = selected_item_id
    customers[customer_id] = customer
    _record("customer_queued", {"customer_id": customer_id, "item_id": selected_item_id})
    return true

func complete_sale(customer_id: String) -> bool:
    if not customers.has(customer_id):
        return false
    var customer: Dictionary = customers[customer_id]
    if customer["state"] != "queued":
        return false
    var item_id: String = customer["selected_item_id"]
    if item_id == "" or not items.has(item_id):
        return false
    var item: Dictionary = items[item_id]
    if item["is_sold"]:
        return false
    _clear_previous_fixture_slot(item_id)
    item["is_sold"] = true
    item["location"] = {"type": "sold", "fixture_id": "", "slot_id": ""}
    items[item_id] = item
    var revenue: float = float(item["current_price"])
    var cost_basis: float = float(item["cost_basis"])
    cash = snappedf(cash + revenue, 0.01)
    var transaction: Dictionary = {
        "transaction_id": "txn_%04d" % (transactions.size() + 1),
        "day": day,
        "type": "sale",
        "customer_id": customer_id,
        "item_ids": [item_id],
        "gross_revenue": revenue,
        "cost_basis": cost_basis,
        "gross_margin": snappedf(revenue - cost_basis, 0.01)
    }
    transactions.append(transaction)
    customer["state"] = "leaving"
    customers[customer_id] = customer
    _record("item_sold", transaction)
    return true

func close_store() -> bool:
    if phase != "open":
        return false
    phase = "report"
    _record("store_closed", {"day": day})
    return true

func daily_report() -> Dictionary:
    var revenue: float = 0.0
    var cost_basis: float = 0.0
    for transaction: Dictionary in transactions:
        revenue += float(transaction["gross_revenue"])
        cost_basis += float(transaction["cost_basis"])
    return {
        "day": day,
        "phase": phase,
        "ending_cash": cash,
        "revenue": snappedf(revenue, 0.01),
        "cost_basis": snappedf(cost_basis, 0.01),
        "gross_margin": snappedf(revenue - cost_basis, 0.01),
        "items_sold": transactions.size(),
        "items_remaining": _count_remaining_sellable_items(),
        "events": event_log.size()
    }

func save_game(path: String = DEFAULT_SAVE_PATH) -> bool:
    var payload: Dictionary = {
        "save_version": SAVE_VERSION,
        "cash": cash,
        "day": day,
        "phase": phase,
        "items": items,
        "fixtures": fixtures,
        "customers": customers,
        "transactions": transactions,
        "event_log": event_log,
        "carried_item_id": carried_item_id
    }
    var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(payload, "\t"))
    file.close()
    _record("game_saved", {"path": path})
    return true

func load_game(path: String = DEFAULT_SAVE_PATH) -> bool:
    if not FileAccess.file_exists(path):
        return false
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var raw: String = file.get_as_text()
    file.close()
    var parsed: Variant = JSON.parse_string(raw)
    if typeof(parsed) != TYPE_DICTIONARY:
        return false
    var payload: Dictionary = parsed
    if int(payload.get("save_version", 0)) != SAVE_VERSION:
        return false
    cash = float(payload["cash"])
    day = int(payload["day"])
    phase = String(payload["phase"])
    items = payload["items"]
    fixtures = payload["fixtures"]
    customers = payload["customers"]
    transactions.assign(payload["transactions"])
    event_log.assign(payload["event_log"])
    carried_item_id = String(payload["carried_item_id"])
    _record("game_loaded", {"path": path})
    return true

func run_engine_proof(save_path: String = DEFAULT_SAVE_PATH) -> Dictionary:
    setup_new_game()
    var proof: Dictionary = {"steps": [], "ok": true}
    _proof_step(proof, "starter_items_created", items.size() == 12)
    var used_item_id: String = "item_000001"
    _proof_step(proof, "pick_up_case", pick_up_item(used_item_id))
    _proof_step(proof, "price_used_case", price_used_item(used_item_id, 21.99))
    _proof_step(proof, "stock_case", stock_carried_item("used_wall_shelf_01", "slot_01"))
    _proof_step(proof, "move_fixture", move_fixture("used_wall_shelf_01", [-1.6, 1.0, -3.2], 12.5))
    _proof_step(proof, "open_store", open_store())
    var customer_id: String = spawn_customer("browser")
    _proof_step(proof, "spawn_customer", customer_id != "")
    _proof_step(proof, "customer_browse_and_queue", customer_browse_and_queue(customer_id))
    _proof_step(proof, "register_sale", complete_sale(customer_id))
    _proof_step(proof, "close_day", close_store())
    var report: Dictionary = daily_report()
    _proof_step(proof, "report_created", int(report["items_sold"]) == 1 and float(report["revenue"]) > 0.0)
    _proof_step(proof, "save_game", save_game(save_path))
    var saved_fixture_position: Array = fixtures["used_wall_shelf_01"]["position"]
    var saved_cash: float = cash
    var reloaded: Variant = get_script().new()
    _proof_step(proof, "load_game", reloaded.load_game(save_path))
    _proof_step(proof, "load_restores_cash", is_equal_approx(reloaded.cash, saved_cash))
    _proof_step(proof, "load_restores_fixture", reloaded.fixtures["used_wall_shelf_01"]["position"] == saved_fixture_position)
    _proof_step(proof, "load_restores_sold_item", bool(reloaded.items[used_item_id]["is_sold"]))
    proof["report"] = report
    proof["cash"] = cash
    proof["transactions"] = transactions.size()
    return proof

func _proof_step(proof: Dictionary, label: String, ok: bool) -> void:
    proof["steps"].append({"label": label, "ok": ok})
    if not ok:
        proof["ok"] = false

func _first_sellable_stocked_item() -> String:
    for item_id: String in items.keys():
        var item: Dictionary = items[item_id]
        var location: Dictionary = item["location"]
        if not bool(item["is_sold"]) and bool(item["is_sellable"]) and String(location["type"]) == "fixture_slot":
            return item_id
    return ""

func _count_remaining_sellable_items() -> int:
    var count: int = 0
    for item_id: String in items.keys():
        var item: Dictionary = items[item_id]
        if not bool(item["is_sold"]) and bool(item["is_sellable"]):
            count += 1
    return count

func _clear_previous_fixture_slot(item_id: String) -> void:
    for fixture_id: String in fixtures.keys():
        var fixture: Dictionary = fixtures[fixture_id]
        var slots: Dictionary = fixture["slots"]
        var changed: bool = false
        for slot_id: String in slots.keys():
            if slots[slot_id] == item_id:
                slots[slot_id] = ""
                changed = true
        if changed:
            fixture["slots"] = slots
            fixtures[fixture_id] = fixture

func _record(event_type: String, data: Dictionary) -> void:
    event_log.append({
        "event_type": event_type,
        "day": day,
        "phase": phase,
        "data": data
    })
