## Shelf placement and removal actions used by the InventoryPanel.
class_name InventoryShelfActions
extends RefCounted

const _ShelfCategoryNormalizer: GDScript = preload(
	"res://game/scripts/stores/shelf_category_normalizer.gd"
)
const _ProductVisualFactory: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)

var inventory_system: InventorySystem
var is_placement_mode: bool = false


## `item` is optional so legacy/test callers can enter placement mode without a
## specific ItemInstance.
func enter_placement_mode(item: ItemInstance = null) -> void:
	if is_placement_mode:
		return
	is_placement_mode = true
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	EventBus.placement_mode_entered.emit()
	var item_name: String = ""
	if item != null:
		if item.definition != null:
			item_name = item.definition.item_name
		else:
			# Malformed inventory state should surface instead of falling back silently.
			push_warning(
				"InventoryShelfActions: ItemInstance %s has no definition; "
				% item.instance_id
				+ "placement hint will fall back to the generic prompt."
			)
	EventBus.placement_hint_requested.emit(item_name)


func exit_placement_mode() -> void:
	if not is_placement_mode:
		return
	is_placement_mode = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	EventBus.placement_mode_exited.emit()


func place_item(
	item: ItemInstance, slot: ShelfSlot
) -> bool:
	# Press-E with no selected item is already gated by InventoryPanel.
	if item == null:
		return false
	# InventoryPanel.open() owns wiring this reference.
	if inventory_system == null:
		push_warning(
			"InventoryShelfActions.place_item: inventory_system not wired; "
			+ "rejecting placement."
		)
		return false
	if slot.is_occupied():
		EventBus.notification_requested.emit(
			tr("INVENTORY_SLOT_OCCUPIED")
		)
		return false
	if item.current_location != "backroom":
		EventBus.notification_requested.emit(
			tr("INVENTORY_NOT_IN_LOCATION") % "backroom"
		)
		return false
	var category: String = _normalized_item_category(item)
	var item_name: String = ""
	if item.definition:
		item_name = item.definition.item_name
	# Reject before mutation so the inventory stays in backroom on mismatch.
	if not slot.accepts_category(category):
		EventBus.notification_requested.emit(
			tr("INVENTORY_WRONG_CATEGORY") % slot.accepted_category
		)
		return false
	inventory_system.move_item(
		item.instance_id, "shelf:%s" % slot.slot_id
	)
	slot.place_item_with_data(_ProductVisualFactory.visual_data_from_item(item))
	EventBus.item_stocked.emit(item.instance_id, slot.slot_id)
	if not item_name.is_empty():
		EventBus.notification_requested.emit(
			tr("INVENTORY_STOCKED") % item_name
		)
	exit_placement_mode()
	return true


## Auto-stocks one unit by routing place_item to the first compatible empty
## slot in `slots`. Returns true on success, false when no compatible slot
## exists or the underlying place_item call rejected. Bypasses placement
## mode — caller is responsible for surfacing the failure to the player when
## false is returned.
func stock_one(item: ItemInstance, slots: Array) -> bool:
	# Null item mirrors place_item; InventoryPanel owns button gating.
	if item == null:
		return false
	# Same InventoryPanel wiring contract as place_item/remove_item_from_shelf.
	if inventory_system == null:
		push_warning(
			"InventoryShelfActions.stock_one: inventory_system not wired; "
			+ "rejecting one-click stock."
		)
		return false
	var slot: ShelfSlot = _find_compatible_empty_slot(item, slots)
	if slot == null:
		return false
	return place_item(item, slot)


## Iterates compatible empty `slots` and places `item` plus matching backroom
## copies (same definition_id) up to capacity. Returns the number of items
## placed. Zero indicates either no compatible slots or no matching backroom
## stock; caller decides how to surface that to the player.
func stock_max(item: ItemInstance, slots: Array) -> int:
	# Null item mirrors stock_one/place_item; InventoryPanel owns button gating.
	if item == null:
		return 0
	# Same InventoryPanel wiring contract as stock_one/place_item.
	if inventory_system == null:
		push_warning(
			"InventoryShelfActions.stock_max: inventory_system not wired; "
			+ "rejecting bulk stock."
		)
		return 0
	if item.definition == null:
		return 0
	var def_id: String = item.definition.id
	if def_id.is_empty():
		return 0
	var queue: Array[ItemInstance] = _collect_backroom_matches(def_id, item)
	if queue.is_empty():
		return 0
	var category: String = _normalized_item_category(item)
	var placed: int = 0
	for node: Node in slots:
		if queue.is_empty():
			break
		if not (node is ShelfSlot):
			continue
		var slot := node as ShelfSlot
		if slot.is_occupied():
			continue
		if not slot.accepts_category(category):
			continue
		var next_item: ItemInstance = queue.pop_front()
		if place_item(next_item, slot):
			placed += 1
	return placed


func _collect_backroom_matches(
	def_id: String, primary: ItemInstance
) -> Array[ItemInstance]:
	var queue: Array[ItemInstance] = [primary]
	for inv_item: ItemInstance in inventory_system.get_backroom_items():
		if inv_item == null or inv_item.definition == null:
			continue
		if inv_item.instance_id == primary.instance_id:
			continue
		if inv_item.definition.id != def_id:
			continue
		queue.append(inv_item)
	return queue


static func _find_compatible_empty_slot(
	item: ItemInstance, slots: Array
) -> ShelfSlot:
	if item == null:
		return null
	var category: String = _normalized_item_category(item)
	for node: Node in slots:
		if not (node is ShelfSlot):
			continue
		var slot := node as ShelfSlot
		if slot.is_occupied():
			continue
		if not slot.accepts_category(category):
			continue
		return slot
	return null


static func _normalized_item_category(item: ItemInstance) -> String:
	if item == null or item.definition == null:
		return ""
	return _ShelfCategoryNormalizer.normalize(item.definition.category)


func remove_item_from_shelf(slot: ShelfSlot) -> void:
	# Same InventoryPanel wiring contract as place_item.
	if inventory_system == null:
		push_warning(
			"InventoryShelfActions.remove_item_from_shelf: inventory_system "
			+ "not wired; cannot return slot %s contents to backroom."
			% slot.slot_id
		)
		return
	var item_id: String = slot.get_item_instance_id()
	if item_id.is_empty():
		return
	slot.remove_item()
	inventory_system.move_item(item_id, "backroom")
	EventBus.item_removed_from_shelf.emit(item_id, slot.slot_id)
	EventBus.notification_requested.emit(tr("INVENTORY_RETURNED"))


func move_to_backroom(item: ItemInstance) -> void:
	# Context menus can invoke this with no current selection.
	if item == null:
		return
	if inventory_system == null:
		push_warning(
			"InventoryShelfActions.move_to_backroom: inventory_system not "
			+ "wired; cannot move %s." % item.instance_id
		)
		return
	if not item.current_location.begins_with("shelf:"):
		return
	var shelf_id: String = item.current_location.substr(6)
	inventory_system.move_item(item.instance_id, "backroom")
	EventBus.item_removed_from_shelf.emit(
		item.instance_id, shelf_id
	)
