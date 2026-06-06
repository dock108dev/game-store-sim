extends Resource
class_name ProductDefinition

@export var product_id: String = ""
@export var display_name: String = ""
@export var category: String = "used_game"
@export var platform: String = ""
@export var condition: String = "good"
@export var completeness: String = "complete"
@export var format: String = "disc"
@export var demand_tier: String = "medium"
@export var cost_basis_cents: int = 0
@export var market_value_cents: int = 0
@export var suggested_price_cents: int = 0


func describe() -> String:
	var details := [
		display_name,
		platform,
		condition.capitalize(),
		completeness.capitalize(),
		"Market $%0.2f" % (market_value_cents / 100.0),
	]
	return " - ".join(details)
