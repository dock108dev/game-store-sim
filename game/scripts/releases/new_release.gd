extends Resource
class_name NewRelease

@export var release_id: String = ""
@export var product_name: String = ""
@export var platform: String = ""
@export var category: String = "new_game"
@export var release_day: int = 1
@export var wholesale_cost_cents: int = 0
@export var suggested_price_cents: int = 0
@export var allocation_limit: int = 0
@export var demand_tier: String = "medium"


func days_until(current_day: int) -> int:
	return release_day - current_day


func format_calendar_line(current_day: int) -> String:
	return "Day %d (%s): %s - %s - cost %s - MSRP %s - allocation %d - demand %s" % [
		release_day,
		_format_countdown(current_day),
		product_name,
		platform,
		_format_money(wholesale_cost_cents),
		_format_money(suggested_price_cents),
		allocation_limit,
		demand_tier.capitalize(),
	]


func _format_countdown(current_day: int) -> String:
	var remaining := days_until(current_day)
	if remaining < 0:
		return "released"
	if remaining == 0:
		return "today"
	if remaining == 1:
		return "tomorrow"
	return "in %d days" % remaining


func _format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)
