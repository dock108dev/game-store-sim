extends Resource
class_name DailyReport


static func build_report(session: StoreSession) -> Dictionary:
	if session == null:
		return {}

	return {
		"day_number": session.day_number,
		"is_closed": session.is_day_closed,
		"opening_cash_cents": session.starting_cash_cents,
		"closing_cash_cents": session.get_cash_cents(),
		"net_cash_change_cents": session.get_cash_cents() - session.starting_cash_cents,
		"sales": session.get_sale_count(),
		"trade_ins": session.get_trade_in_count(),
		"revenue_cents": session.get_total_revenue_cents(),
		"cost_cents": session.get_total_cost_cents(),
		"trade_cash_cents": session.get_total_trade_in_cost_cents(),
		"trade_credit_cents": session.get_total_trade_in_credit_cents(),
		"gross_profit_cents": session.get_total_profit_cents(),
	}


static func format_report(session: StoreSession) -> String:
	var report := build_report(session)
	if report.is_empty():
		return "Daily report unavailable"

	if not bool(report.get("is_closed", false)):
		return "Daily report: day still open"

	return "Daily report day %d:\nClosing cash %s\nNet cash %s\nSales %d / Trade-ins %d\nRevenue %s / Cost %s\nTrade cash %s / Store credit %s\nGross profit %s" % [
		int(report.get("day_number", 0)),
		_format_money(int(report.get("closing_cash_cents", 0))),
		_format_delta(int(report.get("net_cash_change_cents", 0))),
		int(report.get("sales", 0)),
		int(report.get("trade_ins", 0)),
		_format_money(int(report.get("revenue_cents", 0))),
		_format_money(int(report.get("cost_cents", 0))),
		_format_money(int(report.get("trade_cash_cents", 0))),
		_format_money(int(report.get("trade_credit_cents", 0))),
		_format_money(int(report.get("gross_profit_cents", 0))),
	]


static func _format_delta(cents: int) -> String:
	if cents > 0:
		return "+%s" % _format_money(cents)

	return _format_money(cents)


static func _format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)
