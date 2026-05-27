## Verifies that DataLoaderSingleton.generate_starter_inventory("retro_games")
## uses store_definitions.json as the starter-stock SSOT for the sparse
## Day-1 opening: one console and four games.
extends GutTest

const STORE_ID: String = "retro_games"
const STARTER_ITEMS: PackedStringArray = [
	"console_neo_ignite",
	"neo_ignite_motorway_kings_loose",
	"neo_ignite_kingdom_embers_loose",
	"neo_ignite_torque_force_3_loose",
	"neo_ignite_gridiron_2005_loose",
]


func before_all() -> void:
	DataLoaderSingleton.load_all_content()


func test_generate_starter_inventory_returns_exact_starter_items() -> void:
	var items: Array[ItemInstance] = (
		DataLoaderSingleton.generate_starter_inventory(STORE_ID)
	)
	assert_eq(items.size(), STARTER_ITEMS.size())
	var ids: PackedStringArray = []
	for item: ItemInstance in items:
		ids.append(item.definition.id)
	assert_eq(ids, STARTER_ITEMS)


func test_starter_items_default_to_backroom_with_visible_sell_price() -> void:
	var items: Array[ItemInstance] = (
		DataLoaderSingleton.generate_starter_inventory(STORE_ID)
	)
	assert_false(items.is_empty(), "Starter inventory should not be empty")
	for item: ItemInstance in items:
		assert_eq(
			item.current_location,
			"backroom",
			"Item '%s' must land in backroom, got '%s'"
				% [item.instance_id, item.current_location]
		)
		assert_gt(
			item.player_set_price,
			0.0,
			"Item '%s' must show a real starter sell price" % item.instance_id
		)


func test_starter_items_have_sparse_category_distribution() -> void:
	var items: Array[ItemInstance] = (
		DataLoaderSingleton.generate_starter_inventory(STORE_ID)
	)
	assert_false(items.is_empty(), "Starter inventory should not be empty")
	var category_counts: Dictionary = {}
	for item: ItemInstance in items:
		assert_not_null(
			item.definition,
			"Item '%s' must have a non-null definition" % item.instance_id
		)
		var def: ItemDefinition = item.definition
		category_counts[def.category] = int(category_counts.get(def.category, 0)) + 1
		assert_gt(
			def.base_price,
			0.0,
			"Item '%s' must have base_price > 0 for PricingPanel suggestion"
				% def.id
		)
		var resolved: StringName = ContentRegistry.resolve(def.store_type)
		assert_eq(
			String(resolved),
			STORE_ID,
			"Item '%s' must resolve to retro_games, got '%s'"
				% [def.id, resolved]
		)
	assert_eq(int(category_counts.get(&"consoles", 0)), 1)
	assert_eq(int(category_counts.get(&"cartridges", 0)), 4)


## Verifies the catalog supplies at least one broadly desirable common
## retro_games item (low base price, "good" in condition_range) so the
## live-customer flow has a viable match path. Catalog-level check rather
## than inventory-level, since condition is randomized per instance.
func test_retro_games_common_pool_contains_broadly_desirable_item() -> void:
	var max_desirable_price: float = 30.0
	var found: bool = false
	for item_id: StringName in ContentRegistry.get_all_ids("item"):
		var def: ItemDefinition = (
			DataLoaderSingleton.get_item(String(item_id))
		)
		if def == null or def.rarity != "common":
			continue
		var resolved: StringName = ContentRegistry.resolve(def.store_type)
		if String(resolved) != STORE_ID:
			continue
		if def.base_price <= 0.0 or def.base_price > max_desirable_price:
			continue
		if "good" in def.condition_range:
			found = true
			break
	assert_true(
		found,
		(
			"retro_games common-item pool must contain >=1 broadly desirable "
			+ "entry (base_price <= %.2f, 'good' in condition_range) so a "
			+ "Day-1 customer can match the live-buy step."
		) % max_desirable_price
	)
