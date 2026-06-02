extends GutTest

const StarterProductVisualResolverScript: GDScript = preload(
	"res://game/scripts/visuals/starter_product_visual_resolver.gd"
)
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)

var _saved_data_loader: DataLoader = null


func before_each() -> void:
	_saved_data_loader = GameManager.data_loader


func after_each() -> void:
	ContentRegistry.clear_for_testing()
	DataLoaderSingleton.clear_for_testing()
	DataLoaderSingleton.load_all_content()
	if is_instance_valid(_saved_data_loader):
		GameManager.data_loader = _saved_data_loader
	else:
		GameManager.data_loader = DataLoaderSingleton


func test_starter_product_ids_match_stock_inventory_layout_and_resolution() -> void:
	ContentRegistry.clear_for_testing()
	DataLoaderSingleton.clear_for_testing()
	DataLoaderSingleton.load_all_content()
	GameManager.data_loader = DataLoaderSingleton

	var expected: PackedStringArray = _starter_ids()
	var store: StoreDefinition = DataLoaderSingleton.get_store("retro_games")
	assert_not_null(store, "Retro Games store definition must load")
	if store == null:
		return
	assert_eq(store.starting_inventory, expected)

	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout_ids: PackedStringArray = catalog.call(
		"get_product_item_ids", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	assert_eq(layout_ids, expected)

	for item_id: String in expected:
		var definition: ItemDefinition = DataLoaderSingleton.get_item(item_id)
		assert_not_null(definition, "Starter item must resolve through DataLoader: %s" % item_id)
		var data: Dictionary = StarterProductVisualResolverScript.visual_data_for_item_id(item_id)
		assert_eq(str(data.get("definition_id", "")), item_id)
		assert_ne(str(data.get("display_name", "")), "")
		assert_ne(str(data.get("category", "")), "")
		assert_eq(str(data.get("platform_id", "")), "neo_ignite")
		assert_eq(str(data.get("platform_visual_id", "")), "neo_ignite_disc_tower")
		assert_gt(int(data.get("price_cents", 0)), 0)
		assert_ne(str(data.get("visual_resolution_source", "")), "unknown_fallback")


func test_starter_products_keep_complete_visual_data_without_loader_or_registry() -> void:
	GameManager.data_loader = null
	ContentRegistry.clear_for_testing()

	for item_id: String in _starter_ids():
		var data: Dictionary = StarterProductVisualResolverScript.visual_data_for_item_id(item_id)
		assert_eq(str(data.get("definition_id", "")), item_id)
		assert_ne(str(data.get("display_name", "")), "")
		assert_ne(str(data.get("category", "")), "")
		assert_eq(str(data.get("platform_visual_id", "")), "neo_ignite_disc_tower")
		assert_gt(int(data.get("price_cents", 0)), 0)
		assert_eq(str(data.get("visual_resolution_source", "")), "starter_fallback")


func _starter_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for item_id: String in StoreSessionController.starter_first_delivery_item_ids():
		ids.append(item_id)
	for item_id: String in StoreSessionController.starter_reserve_item_ids():
		ids.append(item_id)
	return ids
