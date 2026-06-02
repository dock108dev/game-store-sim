class_name VisualSweepOverhaulFixtures
extends RefCounted

const StoreVisualOverhaulRowsScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_overhaul_rows.gd"
)


## Applies the capture-only visual state for one overhaul acceptance row.
static func apply(store_root: Node3D, row: Dictionary) -> Dictionary:
	_clear(store_root)
	match str(row.get("setup_state", "")):
		"":
			return {"ok": true, "state": ""}
		"build_mode_active":
			return _setup_build_mode_active(store_root)
		"stocked_shelf":
			return _setup_stocked_shelf(store_root)
		"shelf_gap_active":
			return _setup_shelf_gap_active(store_root)
		"checkout_transaction_active":
			return _setup_checkout_transaction_active(store_root)
		"register_trade_in_no_sale":
			return _setup_register_trade_in_no_sale(store_root)
		"queue_waiting":
			return _setup_queue_waiting(store_root)
		"customization_preview":
			return _setup_customization_preview(store_root)
		"stockroom_inventory":
			return _setup_stockroom_inventory(store_root)
		"growth_expansion_preview":
			return _setup_growth_expansion_preview(store_root)
		"lighting_balance":
			return _setup_lighting_balance(store_root)
		"decision_panels_balance":
			return _setup_decision_panels_balance(store_root)
		_:
			return {
				"ok": false,
				"error": "Unknown visual sweep setup_state: %s" % row.get("setup_state", ""),
			}


static func _clear(store_root: Node3D) -> void:
	if store_root == null:
		return
	var existing: Node = store_root.get_node_or_null(StoreVisualOverhaulRowsScript.FIXTURE_ROOT)
	if existing != null:
		store_root.remove_child(existing)
		existing.free()


static func _root(store_root: Node3D) -> Node3D:
	var root_node := Node3D.new()
	root_node.name = StoreVisualOverhaulRowsScript.FIXTURE_ROOT
	store_root.add_child(root_node)
	return root_node


static func _setup_build_mode_active(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "BuildDesignTool", Vector3(-1.2, 0.04, 2.9))
	_add_box(group, "Grid", Vector3(0.0, 0.01, 0.0), Vector3(2.7, 0.02, 1.2), Color(0.12, 0.28, 0.26, 0.45))
	_add_box(group, "PlacementFootprint", Vector3(0.0, 0.06, 0.0), Vector3(0.95, 0.04, 0.65), Color(0.92, 0.67, 0.22, 0.9))
	_add_box(group, "PlacementGhost", Vector3(0.0, 0.45, 0.0), Vector3(0.72, 0.78, 0.42), Color(0.45, 0.82, 0.70, 0.55))
	_add_box(group, "BlockedTileMarker", Vector3(0.9, 0.09, 0.0), Vector3(0.48, 0.08, 0.48), Color(0.90, 0.24, 0.17, 0.95))
	_add_label(group, "Toolbar", "PLACE  ROTATE  CANCEL", Vector3(-0.55, 1.1, -0.75), Color(0.96, 0.91, 0.83, 1.0))
	return {"ok": true, "state": "build_mode_active"}


static func _setup_stocked_shelf(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "StockedShelf", Vector3(-3.25, 0.85, 1.35))
	_add_box(group, "ProductFacingA", Vector3(-0.35, 0.1, 0.0), Vector3(0.22, 0.45, 0.08), Color(0.25, 0.48, 0.90, 1.0))
	_add_box(group, "ProductFacingB", Vector3(0.0, 0.1, 0.0), Vector3(0.22, 0.45, 0.08), Color(0.91, 0.65, 0.28, 1.0))
	_add_label(group, "PriceRail", "$18  $22", Vector3(-0.25, -0.35, 0.02), Color(0.12, 0.10, 0.08, 1.0))
	return {"ok": true, "state": "stocked_shelf"}


static func _setup_shelf_gap_active(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "ShelfGap", Vector3(-3.25, 0.85, 1.35))
	_add_box(group, "RemainingFacingA", Vector3(-0.45, 0.1, 0.0), Vector3(0.22, 0.45, 0.08), Color(0.25, 0.48, 0.90, 1.0))
	_add_box(group, "RemainingFacingB", Vector3(0.45, 0.1, 0.0), Vector3(0.22, 0.45, 0.08), Color(0.91, 0.65, 0.28, 1.0))
	_add_box(group, "GapMarker", Vector3(0.0, 0.1, 0.01), Vector3(0.34, 0.32, 0.04), Color(0.90, 0.24, 0.17, 0.88))
	_add_label(group, "LowStockTag", "RESTOCK", Vector3(-0.15, -0.35, 0.02), Color(0.95, 0.72, 0.11, 1.0))
	return {"ok": true, "state": "shelf_gap_active"}


static func _setup_checkout_transaction_active(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "CheckoutTransaction", Vector3(3.65, 0.95, 5.9))
	_add_box(group, "Surface", Vector3(0.0, 0.0, 0.0), Vector3(0.92, 0.08, 0.62), Color(0.16, 0.12, 0.09, 1.0))
	_add_box(group, "ScannedItemSlot", Vector3(-0.25, 0.11, -0.08), Vector3(0.32, 0.08, 0.22), Color(0.25, 0.48, 0.90, 1.0))
	_add_label(group, "PaymentPrompt", "PAY $22", Vector3(0.1, 0.32, -0.12), Color(0.43, 0.81, 0.35, 1.0))
	_add_capsule(group, "CustomerAtCheckout", Vector3(0.55, 0.75, 0.85), Color(0.58, 0.46, 0.35, 1.0))
	return {"ok": true, "state": "checkout_transaction_active"}


static func _setup_register_trade_in_no_sale(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "RegisterDecision", Vector3(3.55, 1.05, 5.75))
	_add_box(group, "TradeSlip", Vector3(-0.25, 0.05, 0.0), Vector3(0.36, 0.04, 0.5), Color(0.96, 0.91, 0.83, 1.0))
	_add_label(group, "NoSaleStamp", "NO SALE", Vector3(-0.28, 0.22, -0.02), Color(0.90, 0.24, 0.17, 1.0))
	_add_label(group, "NegativeCashBadge", "-$35", Vector3(0.22, 0.22, -0.02), Color(1.0, 0.71, 0.66, 1.0))
	return {"ok": true, "state": "register_trade_in_no_sale"}


static func _setup_queue_waiting(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "CustomerQueue", Vector3(1.0, 0.0, 6.15))
	_add_capsule(group, "WaitingCustomerA", Vector3(0.0, 0.8, 0.0), Color(0.37, 0.56, 0.75, 1.0))
	_add_capsule(group, "WaitingCustomerB", Vector3(-0.75, 0.8, -0.65), Color(0.70, 0.45, 0.34, 1.0))
	return {"ok": true, "state": "queue_waiting"}


static func _setup_customization_preview(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "Customization", Vector3(-2.95, 0.82, 1.25))
	_add_box(group, "SelectedFixture", Vector3(0.0, 0.1, 0.0), Vector3(0.9, 0.5, 0.42), Color(0.45, 0.82, 0.70, 1.0))
	_add_box(group, "SelectionOutline", Vector3(0.0, 0.1, 0.0), Vector3(1.02, 0.58, 0.48), Color(0.95, 0.72, 0.11, 0.45))
	_add_label(group, "PosterPreview", "RETRO REWIND", Vector3(-0.45, 0.85, -0.02), Color(0.96, 0.91, 0.83, 1.0))
	_add_box(group, "FeaturedDisplay", Vector3(0.52, 0.32, 0.0), Vector3(0.22, 0.34, 0.12), Color(0.68, 0.36, 0.72, 1.0))
	_add_box(group, "MaterialSwatches", Vector3(-0.52, -0.32, 0.0), Vector3(0.62, 0.08, 0.12), Color(0.25, 0.48, 0.90, 1.0))
	return {"ok": true, "state": "customization_preview"}


static func _setup_stockroom_inventory(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "StockroomInventory", Vector3(3.25, 0.62, -5.25))
	_add_box(group, "InventoryCrate", Vector3(0.0, 0.2, 0.0), Vector3(0.8, 0.42, 0.58), Color(0.42, 0.31, 0.18, 1.0))
	_add_label(group, "CountTags", "12 IN BACK", Vector3(-0.15, 0.62, -0.05), Color(0.95, 0.72, 0.11, 1.0))
	_add_label(group, "PickList", "PULL 3", Vector3(0.42, 0.35, -0.05), Color(0.96, 0.91, 0.83, 1.0))
	return {"ok": true, "state": "stockroom_inventory"}


static func _setup_growth_expansion_preview(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "GrowthExpansion", Vector3(-0.2, 0.04, 1.0))
	_add_box(group, "NewFloorOutline", Vector3(0.0, 0.02, -1.2), Vector3(3.4, 0.03, 1.1), Color(0.45, 0.82, 0.70, 0.45))
	_add_box(group, "LeaseBoundary", Vector3(0.0, 0.1, -1.78), Vector3(3.4, 0.12, 0.06), Color(0.91, 0.65, 0.28, 0.9))
	_add_label(group, "FixtureCapacityTag", "+4 FIXTURES", Vector3(-0.8, 0.45, -1.8), Color(0.96, 0.91, 0.83, 1.0))
	return {"ok": true, "state": "growth_expansion_preview"}


static func _setup_lighting_balance(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "LightingBalance", Vector3(0.8, 1.2, 4.85))
	_add_label(group, "LightMeterCard", "KEY OK  ACCENT LOW", Vector3(0.0, 0.0, 0.0), Color(0.96, 0.91, 0.83, 1.0))
	_add_box(group, "WorkSurfaceGlow", Vector3(1.9, -0.62, 0.85), Vector3(1.1, 0.03, 0.7), Color(0.91, 0.65, 0.28, 0.35))
	return {"ok": true, "state": "lighting_balance"}


static func _setup_decision_panels_balance(store_root: Node3D) -> Dictionary:
	var group: Node3D = _add_group(_root(store_root), "DecisionPanels", Vector3(3.05, 1.18, 5.25))
	_add_label(group, "ActionPanel", "ACCEPT  DECLINE", Vector3(-0.35, 0.25, 0.0), Color(0.96, 0.91, 0.83, 1.0))
	_add_label(group, "OutcomePanel", "MARGIN +$8", Vector3(0.35, 0.25, 0.0), Color(0.43, 0.81, 0.35, 1.0))
	_add_box(group, "CounterClearZone", Vector3(0.0, -0.25, 0.08), Vector3(1.1, 0.04, 0.48), Color(0.45, 0.82, 0.70, 0.38))
	return {"ok": true, "state": "decision_panels_balance"}


static func _add_group(parent: Node3D, name: String, position: Vector3) -> Node3D:
	var group := Node3D.new()
	group.name = name
	group.position = position
	parent.add_child(group)
	return group


static func _add_box(parent: Node3D, name: String, position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var box := MeshInstance3D.new()
	box.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	box.mesh = mesh
	box.position = position
	box.material_override = _material(color)
	parent.add_child(box)
	return box


static func _add_capsule(parent: Node3D, name: String, position: Vector3, color: Color) -> MeshInstance3D:
	var capsule := MeshInstance3D.new()
	capsule.name = name
	var mesh := CapsuleMesh.new()
	mesh.height = 1.2
	mesh.radius = 0.24
	capsule.mesh = mesh
	capsule.position = position
	capsule.material_override = _material(color)
	parent.add_child(capsule)
	return capsule


static func _add_label(parent: Node3D, name: String, text: String, position: Vector3, color: Color) -> Label3D:
	var label := Label3D.new()
	label.name = name
	label.text = text
	label.font_size = 28
	label.pixel_size = 0.012
	label.modulate = color
	label.position = position
	parent.add_child(label)
	return label


static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
