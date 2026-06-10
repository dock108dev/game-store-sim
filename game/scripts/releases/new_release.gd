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
@export_multiline var tagline: String = ""
@export_multiline var buyer_hook: String = ""
@export_multiline var allocation_note: String = ""


func days_until(current_day: int) -> int:
	return release_day - current_day


func format_calendar_line(current_day: int) -> String:
	var hook := buyer_hook.strip_edges()
	if hook.is_empty():
		hook = "Expected demand from regulars and launch browsers"
	return "Day %d (%s): %s - %s - cost %s - MSRP %s - allocation %d - demand %s - %s" % [
		release_day,
		_format_countdown(current_day),
		product_name,
		platform,
		_format_money(wholesale_cost_cents),
		_format_money(suggested_price_cents),
		allocation_limit,
		demand_tier.capitalize(),
		hook,
	]


func format_planning_line(current_day: int) -> String:
	var note := allocation_note.strip_edges()
	if note.is_empty():
		note = "Commit only the copies you can afford to display on launch day"
	var title := tagline.strip_edges()
	if title.is_empty():
		title = product_name
	title = title.trim_suffix(".")
	return "%s: %s. %s" % [
		_format_countdown_lead(current_day),
		title,
		note,
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


func _format_countdown_lead(current_day: int) -> String:
	var text := _format_countdown(current_day)
	if text.is_empty():
		return text
	return text.substr(0, 1).to_upper() + text.substr(1)


func _format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)
