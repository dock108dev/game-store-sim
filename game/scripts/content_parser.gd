## Static facade for constructing typed Resources from JSON content dictionaries.
class_name ContentParser

const CatalogParserScript: GDScript = preload(
	"res://game/scripts/content_catalog_resource_parser.gd"
)
const GameplayParserScript: GDScript = preload(
	"res://game/scripts/content_gameplay_resource_parser.gd"
)


static func build_resource(
	content_type: String, data: Dictionary
) -> Resource:
	match content_type:
		"item":
			return parse_item(data)
		"store":
			return parse_store(data)
		"customer":
			return parse_customer(data)
		"fixture":
			return parse_fixture(data)
		"market_event":
			return parse_market_event(data)
		"random_event":
			return parse_random_event(data)
		"staff":
			return parse_staff(data)
		"milestone":
			return parse_milestone(data)
		"upgrade":
			return parse_upgrade(data)
		"supplier":
			return parse_supplier(data)
		"unlock":
			return parse_unlock(data)
		"ambient_moment":
			return parse_ambient_moment(data)
	push_error("ContentParser: unknown type '%s'" % content_type)
	return null


static func parse_item(data: Dictionary) -> ItemDefinition:
	return CatalogParserScript.parse_item(data)


static func parse_store(data: Dictionary) -> StoreDefinition:
	return CatalogParserScript.parse_store(data)


static func parse_customer(data: Dictionary) -> CustomerTypeDefinition:
	return CatalogParserScript.parse_customer(data)


static func parse_fixture(data: Dictionary) -> FixtureDefinition:
	return CatalogParserScript.parse_fixture(data)


static func parse_market_event(data: Dictionary) -> MarketEventDefinition:
	return GameplayParserScript.parse_market_event(data)


static func parse_random_event(data: Dictionary) -> RandomEventDefinition:
	return GameplayParserScript.parse_random_event(data)


static func parse_staff(data: Dictionary) -> StaffDefinition:
	return GameplayParserScript.parse_staff(data)


static func parse_milestone(data: Dictionary) -> MilestoneDefinition:
	return GameplayParserScript.parse_milestone(data)


static func parse_upgrade(data: Dictionary) -> UpgradeDefinition:
	return GameplayParserScript.parse_upgrade(data)


static func parse_supplier(data: Dictionary) -> SupplierDefinition:
	return GameplayParserScript.parse_supplier(data)


static func parse_unlock(data: Dictionary) -> UnlockDefinition:
	return GameplayParserScript.parse_unlock(data)


static func parse_economy_config(data: Dictionary) -> EconomyConfig:
	return GameplayParserScript.parse_economy_config(data)


static func parse_ambient_moment(
	data: Dictionary
) -> AmbientMomentDefinition:
	return GameplayParserScript.parse_ambient_moment(data)
