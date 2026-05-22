## Normalizes content item categories to the runtime ShelfSlot category keys.
class_name ShelfCategoryNormalizer
extends RefCounted


const _CATEGORY_ALIASES: Dictionary = {
	"cartridges": "cartridge",
	"consoles": "console",
	"accessories": "accessory",
	"guides": "guide",
	"sealed_products": "sealed_product",
}


## Returns the runtime ShelfSlot category key for content/catalog input.
static func normalize(category: Variant) -> String:
	var raw: String = str(category).strip_edges().to_lower()
	if raw.is_empty():
		return ""
	return str(_CATEGORY_ALIASES.get(raw, raw))


## Returns true when a slot category accepts an item category after normalization.
static func matches(accepted_category: Variant, item_category: Variant) -> bool:
	var accepted: String = normalize(accepted_category)
	if accepted.is_empty():
		return true
	return accepted == normalize(item_category)
