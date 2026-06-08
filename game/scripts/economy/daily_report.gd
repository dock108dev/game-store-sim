extends Resource
class_name DailyReport


static func build_report(session: StoreSession) -> Dictionary:
	if session == null:
		return {}

	return {
		"day_number": session.day_number,
		"is_closed": session.is_day_closed,
		"day_phase": session.get_day_phase(),
		"day_phase_label": session.get_day_phase_label(),
		"day_structure_text": session.get_day_structure_text(),
		"opening_cash_cents": session.starting_cash_cents,
		"closing_cash_cents": session.get_cash_cents(),
		"net_cash_change_cents": session.get_cash_cents() - session.starting_cash_cents,
		"sales": session.get_sale_count(),
		"trade_ins": session.get_trade_in_count(),
		"preorders": session.get_preorder_deposit_count(),
		"services": session.get_service_count(),
		"revenue_cents": session.get_total_revenue_cents(),
		"cost_cents": session.get_total_cost_cents(),
		"service_revenue_cents": session.get_total_service_revenue_cents(),
		"service_cost_cents": session.get_total_service_cost_cents(),
		"service_profit_cents": session.get_total_service_profit_cents(),
		"trade_cash_cents": session.get_total_trade_in_cost_cents(),
		"trade_credit_cents": session.get_total_trade_in_credit_cents(),
		"preorder_deposits_cents": session.get_total_preorder_deposit_cents(),
		"gross_profit_cents": session.get_total_profit_cents(),
		"launch_events": session.get_launch_event_count(),
		"launch_revenue_cents": session.get_total_launch_revenue_cents(),
		"launch_profit_cents": session.get_total_launch_profit_cents(),
		"missed_launch_demand": _get_missed_launch_demand(session),
		"reputation": session.get_reputation_score(),
		"losses_cents": _get_losses_cents(session),
		"bills_text": get_bills_text(session),
		"tomorrow_recommendations": get_tomorrow_recommendations(session),
	}


static func format_report(session: StoreSession) -> String:
	var report := build_report(session)
	if report.is_empty():
		return "Daily report unavailable"

	if not bool(report.get("is_closed", false)):
		return "Daily report: day still open"

	return "Daily report day %d:\nEnd-of-day summary\nPhase: %s\nDay plan: Opening > Setup > Customer hours > Closing > Report > Tomorrow planning\nCash: opening %s / Closing cash %s / Net cash %s\nSales %d / Trade-ins %d / Services %d / Preorders %d\nRevenue %s / Cost %s\nGross profit %s\nTrade-ins: cash %s / Store credit %s\nServices: count %d / Service revenue %s / Service cost %s / Service profit %s\nPreorders: count %d / deposits %s\nLaunch activity: %d events / cash %s / profit %s / missed demand %d\nReputation: %d\nLosses: %s\nBills: %s\nTomorrow: %s" % [
		int(report.get("day_number", 0)),
		str(report.get("day_phase_label", "Report")),
		_format_money(int(report.get("opening_cash_cents", 0))),
		_format_money(int(report.get("closing_cash_cents", 0))),
		_format_delta(int(report.get("net_cash_change_cents", 0))),
		int(report.get("sales", 0)),
		int(report.get("trade_ins", 0)),
		int(report.get("services", 0)),
		int(report.get("preorders", 0)),
		_format_money(int(report.get("revenue_cents", 0))),
		_format_money(int(report.get("cost_cents", 0))),
		_format_money(int(report.get("gross_profit_cents", 0))),
		_format_money(int(report.get("trade_cash_cents", 0))),
		_format_money(int(report.get("trade_credit_cents", 0))),
		int(report.get("services", 0)),
		_format_money(int(report.get("service_revenue_cents", 0))),
		_format_money(int(report.get("service_cost_cents", 0))),
		_format_money(int(report.get("service_profit_cents", 0))),
		int(report.get("preorders", 0)),
		_format_money(int(report.get("preorder_deposits_cents", 0))),
		int(report.get("launch_events", 0)),
		_format_money(int(report.get("launch_revenue_cents", 0))),
		_format_money(int(report.get("launch_profit_cents", 0))),
		int(report.get("missed_launch_demand", 0)),
		int(report.get("reputation", 100)),
		_format_money(int(report.get("losses_cents", 0))),
		str(report.get("bills_text", "none due")),
		"; ".join(report.get("tomorrow_recommendations", [])),
	]


static func _get_missed_launch_demand(session: StoreSession) -> int:
	var total := 0
	for event in session.get_launch_events():
		total += int(event.get("missed_demand", 0))
	return total


static func _get_losses_cents(session: StoreSession) -> int:
	var losses := 0
	for event in session.get_launch_events():
		losses += maxi(0, int(event.get("missed_demand", 0))) * 500
	return losses


static func get_bills_text(_session: StoreSession) -> String:
	return "none due"


static func get_tomorrow_recommendations(session: StoreSession) -> Array[String]:
	var recommendations: Array[String] = []
	for order in session.get_pending_supplier_orders():
		if int(order.get("due_day", session.day_number + 1)) <= session.day_number + 1:
			recommendations.append("Receive %s in the backroom" % str(order.get("display_name", "supplier order")))

	for release in session.get_upcoming_releases(false):
		if int(release.get("release_day")) == session.day_number + 1:
			recommendations.append("Prepare %s launch allocation" % str(release.get("product_name")))

	var reorder_text := session.get_reorder_suggestions_text()
	if not reorder_text.ends_with("none"):
		recommendations.append("Review reorder suggestions")

	if recommendations.is_empty():
		recommendations.append("Keep shelves priced and stocked")

	return recommendations


static func _format_delta(cents: int) -> String:
	if cents > 0:
		return "+%s" % _format_money(cents)

	return _format_money(cents)


static func _format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)
