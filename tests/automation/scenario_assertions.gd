## Assertion helpers for data-driven automation scenarios.
class_name ScenarioAssertions
extends RefCounted

const MODE_EQUALS: String = "equals"
const MODE_NOT_EQUALS: String = "not_equals"
const MODE_GREATER_THAN: String = "greater_than"
const MODE_LESS_THAN: String = "less_than"
const MODE_CONTAINS: String = "contains"
const MODE_HAS_KEY: String = "has_key"
const MODE_TRUTHY: String = "truthy"
const MODE_FALSY: String = "falsy"

const MODES: Array[String] = [
	MODE_EQUALS,
	MODE_NOT_EQUALS,
	MODE_GREATER_THAN,
	MODE_LESS_THAN,
	MODE_CONTAINS,
	MODE_HAS_KEY,
	MODE_TRUTHY,
	MODE_FALSY,
]


## Returns a structured pass/fail result for an assertion dictionary.
static func evaluate(actual: Variant, assertion: Dictionary) -> Dictionary:
	var mode: String = str(assertion.get("mode", MODE_EQUALS))
	var expected: Variant = assertion.get("expected")
	match mode:
		MODE_EQUALS:
			return _result(actual == expected, actual, expected, mode)
		MODE_NOT_EQUALS:
			return _result(actual != expected, actual, expected, mode)
		MODE_GREATER_THAN:
			return _result(_as_float(actual) > _as_float(expected), actual, expected, mode)
		MODE_LESS_THAN:
			return _result(_as_float(actual) < _as_float(expected), actual, expected, mode)
		MODE_CONTAINS:
			return _result(_contains(actual, expected), actual, expected, mode)
		MODE_HAS_KEY:
			return _result(actual is Dictionary and actual.has(expected), actual, expected, mode)
		MODE_TRUTHY:
			return _result(bool(actual), actual, true, mode)
		MODE_FALSY:
			return _result(not bool(actual), actual, false, mode)
		_:
			return {
				"ok": false,
				"reason": "unsupported assertion mode '%s'" % mode,
				"actual": actual,
				"expected": expected,
				"mode": mode,
			}


## Validates the static shape of an assertion dictionary before execution.
static func validate(assertion: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var mode: String = str(assertion.get("mode", MODE_EQUALS))
	if not MODES.has(mode):
		errors.append("unsupported assertion mode '%s'" % mode)
	if not assertion.has("expected") and mode not in [MODE_TRUTHY, MODE_FALSY]:
		errors.append("assertion missing expected")
	return errors


static func _result(ok: bool, actual: Variant, expected: Variant, mode: String) -> Dictionary:
	var reason: String = ""
	if not ok:
		reason = "assertion failed mode=%s expected=%s actual=%s" % [
			mode,
			str(expected),
			str(actual),
		]
	return {
		"ok": ok,
		"reason": reason,
		"actual": actual,
		"expected": expected,
		"mode": mode,
	}


static func _as_float(value: Variant) -> float:
	if value is int or value is float:
		return float(value)
	return str(value).to_float()


static func _contains(actual: Variant, expected: Variant) -> bool:
	if actual is Array:
		return actual.has(expected)
	if actual is Dictionary:
		return actual.values().has(expected)
	if actual is String:
		return (actual as String).contains(str(expected))
	return false
