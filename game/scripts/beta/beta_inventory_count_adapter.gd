class_name BetaInventoryCountAdapter
extends RefCounted

const DEFAULT_STORE_ID: StringName = &"retro_games"
const SOURCE_REAL_INVENTORY: String = "real_inventory"
const SOURCE_PRESENTATION_TUTORIAL: String = "presentation_tutorial"

var _inventory_system: InventorySystem
var _store_id: StringName = DEFAULT_STORE_ID


func _init(
	inventory_system: InventorySystem = null,
	store_id: StringName = DEFAULT_STORE_ID
) -> void:
	_inventory_system = inventory_system
	_store_id = store_id


## Returns real inventory counts and transaction deltas from an inventory-effect result.
func from_transaction(transaction: Dictionary) -> Dictionary:
	var counts: Dictionary = _counts_from_transaction(transaction)
	var applied: Array = transaction.get("applied", []) as Array
	var summary: Dictionary = _base_summary(
		SOURCE_REAL_INVENTORY,
		counts,
		bool(transaction.get("ok", false)),
		applied,
		transaction.get("failed", []) as Array
	)
	for applied_variant: Variant in applied:
		if applied_variant is not Dictionary:
			continue
		_accumulate_applied(summary, applied_variant as Dictionary)
	return summary


## Returns beta tutorial counts that are explicitly presentation state.
func presentation_counts(
	shelf_count: int,
	backroom_count: int,
	damaged_count: int = 0,
	returned_backroom_count: int = 0
) -> Dictionary:
	var counts: Dictionary = {
		"shelf": maxi(shelf_count, 0),
		"backroom": maxi(backroom_count, 0),
		"damaged": maxi(damaged_count, 0),
	}
	var summary: Dictionary = _base_summary(
		SOURCE_PRESENTATION_TUTORIAL,
		counts,
		true,
		[],
		[]
	)
	summary["returned_backroom_count"] = maxi(returned_backroom_count, 0)
	return summary


## Reads current InventorySystem counts for the adapter store without applying effects.
func current_real_counts() -> Dictionary:
	return _base_summary(SOURCE_REAL_INVENTORY, _current_inventory_counts(), true, [], [])


func _base_summary(
	source: String,
	counts: Dictionary,
	ok: bool,
	applied: Array,
	failed: Array
) -> Dictionary:
	var normalized_counts: Dictionary = _normalize_counts(counts)
	return {
		"source": source,
		"store_id": String(_store_id),
		"ok": ok,
		"applied": applied.duplicate(true),
		"failed": failed.duplicate(true),
		"inventory_counts": normalized_counts.duplicate(true),
		"shelf": int(normalized_counts.get("shelf", 0)),
		"backroom": int(normalized_counts.get("backroom", 0)),
		"damaged": int(normalized_counts.get("damaged", 0)),
		"returned_backroom_count": 0,
		"damaged_return_count": 0,
		"applied_remove_quantity": 0,
		"applied_create_quantity": 0,
		"applied_move_quantity": 0,
		"applied_shelf_removed_quantity": 0,
		"applied_backroom_removed_quantity": 0,
		"applied_backroom_created_quantity": 0,
		"applied_damaged_created_quantity": 0,
		"applied_moved_from_shelf_quantity": 0,
		"applied_moved_to_shelf_quantity": 0,
		"applied_moved_to_backroom_quantity": 0,
		"applied_moved_to_damaged_quantity": 0,
	}


func _counts_from_transaction(transaction: Dictionary) -> Dictionary:
	var counts: Variant = transaction.get("inventory_counts", {})
	if counts is Dictionary:
		return _normalize_counts(counts as Dictionary)
	return _current_inventory_counts()


func _normalize_counts(counts: Dictionary) -> Dictionary:
	return {
		"shelf": maxi(int(counts.get("shelf", 0)), 0),
		"backroom": maxi(int(counts.get("backroom", 0)), 0),
		"damaged": maxi(int(counts.get("damaged", 0)), 0),
	}


func _current_inventory_counts() -> Dictionary:
	var counts: Dictionary = {"shelf": 0, "backroom": 0, "damaged": 0}
	if _inventory_system == null:
		return counts
	for item: ItemInstance in _inventory_system.get_stock(_store_id):
		if item.current_location.begins_with("shelf:"):
			counts["shelf"] = int(counts["shelf"]) + 1
		elif item.current_location == BetaCustomerInventoryEffects.LOCATION_BACKROOM:
			counts["backroom"] = int(counts["backroom"]) + 1
		elif item.current_location == InventorySystem.DAMAGED_BIN_LOCATION:
			counts["damaged"] = int(counts["damaged"]) + 1
	return counts


func _accumulate_applied(summary: Dictionary, applied: Dictionary) -> void:
	var op: String = str(applied.get("op", ""))
	var from_location: String = str(applied.get("from_location", ""))
	var to_location: String = str(applied.get("to_location", ""))
	match op:
		BetaCustomerInventoryEffects.OP_REMOVE_STOCK:
			summary["applied_remove_quantity"] = int(summary["applied_remove_quantity"]) + 1
			if from_location.begins_with("shelf:"):
				summary["applied_shelf_removed_quantity"] = (
					int(summary["applied_shelf_removed_quantity"]) + 1
				)
			elif from_location == BetaCustomerInventoryEffects.LOCATION_BACKROOM:
				summary["applied_backroom_removed_quantity"] = (
					int(summary["applied_backroom_removed_quantity"]) + 1
				)
		BetaCustomerInventoryEffects.OP_CREATE_ITEM:
			summary["applied_create_quantity"] = int(summary["applied_create_quantity"]) + 1
			if to_location == BetaCustomerInventoryEffects.LOCATION_BACKROOM:
				summary["applied_backroom_created_quantity"] = (
					int(summary["applied_backroom_created_quantity"]) + 1
				)
				summary["returned_backroom_count"] = int(summary["returned_backroom_count"]) + 1
			elif to_location == InventorySystem.DAMAGED_BIN_LOCATION:
				summary["applied_damaged_created_quantity"] = (
					int(summary["applied_damaged_created_quantity"]) + 1
				)
				summary["damaged_return_count"] = int(summary["damaged_return_count"]) + 1
		BetaCustomerInventoryEffects.OP_MOVE_EXISTING:
			summary["applied_move_quantity"] = int(summary["applied_move_quantity"]) + 1
			if from_location.begins_with("shelf:"):
				summary["applied_moved_from_shelf_quantity"] = (
					int(summary["applied_moved_from_shelf_quantity"]) + 1
				)
			if to_location.begins_with("shelf:"):
				summary["applied_moved_to_shelf_quantity"] = (
					int(summary["applied_moved_to_shelf_quantity"]) + 1
				)
			elif to_location == BetaCustomerInventoryEffects.LOCATION_BACKROOM:
				summary["applied_moved_to_backroom_quantity"] = (
					int(summary["applied_moved_to_backroom_quantity"]) + 1
				)
				summary["returned_backroom_count"] = int(summary["returned_backroom_count"]) + 1
			elif to_location == InventorySystem.DAMAGED_BIN_LOCATION:
				summary["applied_moved_to_damaged_quantity"] = (
					int(summary["applied_moved_to_damaged_quantity"]) + 1
				)
				summary["damaged_return_count"] = int(summary["damaged_return_count"]) + 1
