## Tests fixture catalog content loading, registry resolution, and store filtering.
extends GutTest

const FIXTURE_CATALOG_PATH: String = "res://game/content/fixtures.json"
const CatalogEffectMetadataScript: GDScript = preload(
	"res://game/resources/catalog_effect_metadata.gd"
)
const StoreDesignCatalogScript: GDScript = preload(
	"res://game/scripts/systems/store_design_catalog.gd"
)

var _data_loader: DataLoader


func before_each() -> void:
	_data_loader = DataLoader.new()
	_data_loader.load_all_content()


func test_fixture_count() -> void:
	var fixtures: Array[FixtureDefinition] = _data_loader.get_all_fixtures()
	assert_gte(fixtures.size(), 10, "Should load at least 10 fixtures")


func test_fixture_json_entries_include_required_fields() -> void:
	var raw: Variant = DataLoader.load_json(FIXTURE_CATALOG_PATH)
	assert_true(raw is Dictionary, "fixtures.json should load as a dictionary")
	var entries: Array = (raw as Dictionary).get("entries", [])
	assert_gte(entries.size(), 10, "fixtures.json should include at least 10 entries")
	for entry_value: Variant in entries:
		assert_true(entry_value is Dictionary, "Each fixture entry must be a dictionary")
		var entry: Dictionary = entry_value as Dictionary
		for field: String in [
			"id",
			"display_name",
			"cost",
				"slot_count",
				"footprint_cells",
				"rotation_support",
				"store_type_restriction",
				"unlock_rep",
				"unlock_day",
				"catalog_category",
				"catalog_sort",
				"silhouette",
				"capacity_label",
				"effect_summary",
				"effects",
				"owned_limit",
			]:
				assert_true(entry.has(field), "Fixture entry missing field '%s'" % field)


func test_content_registry_resolves_fixture_entries() -> void:
	var wall_shelf_entry: Dictionary = ContentRegistry.get_entry(&"wall_shelf")
	assert_false(
		wall_shelf_entry.is_empty(),
		"wall_shelf should resolve from ContentRegistry"
	)
	assert_eq(wall_shelf_entry.get("display_name"), "Wall Shelf")
	assert_eq(int(wall_shelf_entry.get("slot_count", -1)), 4)


func test_register_matches_fixture_schema() -> void:
	var fixture: FixtureDefinition = _data_loader.get_fixture("register")
	assert_not_null(fixture, "register should load")
	assert_eq(fixture.cost, 90.0)
	assert_eq(fixture.slot_count, 0)
	assert_eq(fixture.footprint_cells.size(), 1)
	assert_false(fixture.rotation_support)
	assert_eq(fixture.catalog_category, "counters")
	assert_eq(fixture.silhouette, "register_1x1")
	assert_eq(fixture.owned_limit, 1)


func test_fixture_catalog_metadata_loads_into_resource() -> void:
	var fixture: FixtureDefinition = _data_loader.get_fixture("wall_shelf")
	assert_not_null(fixture, "wall_shelf should load")
	assert_eq(fixture.catalog_category, "shelves")
	assert_eq(fixture.catalog_sort, 20)
	assert_eq(fixture.capacity_label, "4 item slots")
	assert_string_contains(fixture.effect_summary, "Wall display")
	assert_gt(fixture.effects.size(), 0)


func test_fixture_effect_metadata_maps_to_owned_sources() -> void:
	for fixture: FixtureDefinition in _data_loader.get_all_fixtures():
		var errors: Array[String] = fixture.validate_catalog_effect_metadata()
		assert_eq(errors, [], "%s effect metadata must be owned" % fixture.id)
		for effect: Dictionary in fixture.get_catalog_effects():
			assert_false(str(effect.get("owner", "")).is_empty())
			if str(effect.get("type", "")) == CatalogEffectMetadataScript.TYPE_CAPACITY:
				assert_eq(str(effect.get("source", "")), "slot_count")
				assert_gt(fixture.slot_count, 0)


func test_store_design_catalog_effect_metadata_is_visual_only() -> void:
	var errors: Array[String] = StoreDesignCatalogScript.validate_catalog()
	assert_eq(errors, [], "Store design effects must be owned")
	for option: Dictionary in StoreDesignCatalogScript.all_options():
		var effects: Array[Dictionary] = []
		effects.assign(option.get("effects", []))
		assert_eq(effects.size(), 1)
		assert_eq(str(effects[0].get("type", "")), CatalogEffectMetadataScript.TYPE_COSMETIC)
		assert_eq(str(effects[0].get("owner", "")), "StoreCustomizationSystem")


func test_unsupported_advertised_effect_claims_are_rejected() -> void:
	var bad_effects: Array[Dictionary] = [
		{
			"type": CatalogEffectMetadataScript.TYPE_BROWSE_DEMAND,
			"source": "unowned_formula",
			"label": "+20% demand boost",
		},
	]
	var errors: Array[String] = CatalogEffectMetadataScript.validate_advertised_effects(
		"Demand boost and discount", bad_effects, "bad_card"
	)
	assert_gt(errors.size(), 0)
	assert_true(_contains_error(errors, "unowned source"))
	assert_true(_contains_error(errors, "discount"))


func test_store_specific_filter_resolves_store_aliases() -> void:
	var retro_fixtures: Array[FixtureDefinition] = _data_loader.get_fixtures_for_store("retro_games")
	assert_true(_contains_fixture(retro_fixtures, "testing_station"))
	assert_false(_contains_fixture(retro_fixtures, "authentication_station"))


func test_sellback_price_is_half_cost() -> void:
	var fixture: FixtureDefinition = _data_loader.get_fixture("glass_case")
	assert_not_null(fixture, "glass_case should load")
	assert_eq(fixture.get_sellback_price(), 40.0)


func _contains_fixture(
	fixtures: Array[FixtureDefinition],
	fixture_id: String
) -> bool:
	for fixture: FixtureDefinition in fixtures:
		if fixture.id == fixture_id:
			return true
	return false


func _contains_error(errors: Array[String], needle: String) -> bool:
	for error: String in errors:
		if error.contains(needle):
			return true
	return false
