extends GutTest

const MIGRATED_RANDOM_PATHS: Array[String] = [
	"res://game/autoload/automation_runner.gd",
	"res://game/autoload/checkout_system.gd",
	"res://game/scripts/characters/customer.gd",
	"res://game/scripts/systems/ambient_moments_system.gd",
	"res://game/scripts/systems/checkout_system.gd",
	"res://game/scripts/systems/customer_system.gd",
	"res://game/scripts/systems/customer_system_eligibility.gd",
	"res://game/scripts/systems/customer_system_mall_shoppers.gd",
	"res://game/scripts/systems/haggle_system.gd",
	"res://game/scripts/systems/order_system.gd",
	"res://game/scripts/systems/shopper_archetype_config.gd",
]
const DIRECT_RANDOM_TOKENS: Array[String] = [
	"randf(",
	"randf_range(",
	"randi(",
	"randi_range(",
	"randomize(",
	"seed(",
	".pick_random(",
]


func after_each() -> void:
	GameRandom.disable_test_mode()


func test_same_seed_and_stream_replays_sequence() -> void:
	var first: Array = _roll_sequence("mallcore_001", RandomStreamIds.ORDER_STOCKOUT)
	var second: Array = _roll_sequence("mallcore_001", RandomStreamIds.ORDER_STOCKOUT)

	assert_eq(first, second)


func test_streams_are_isolated_under_same_seed() -> void:
	GameRandom.enable_test_mode("mallcore_001")
	var before: int = GameRandom.get_stream_state(RandomStreamIds.ORDER_STOCKOUT)
	GameRandom.randf(RandomStreamIds.CUSTOMER_APPEARANCE)
	GameRandom.randf(RandomStreamIds.CUSTOMER_APPEARANCE)
	var after: int = GameRandom.get_stream_state(RandomStreamIds.ORDER_STOCKOUT)

	assert_eq(after, before)


func test_different_stream_ids_do_not_share_sequence() -> void:
	var order_values: Array = _roll_sequence(
		"mallcore_001", RandomStreamIds.ORDER_STOCKOUT
	)
	var checkout_values: Array = _roll_sequence(
		"mallcore_001", RandomStreamIds.CHECKOUT_OFFER
	)

	assert_ne(order_values, checkout_values)


func test_direct_random_calls_stay_out_of_migrated_paths() -> void:
	var violations: Array[String] = []
	for path: String in MIGRATED_RANDOM_PATHS:
		violations.append_array(_find_direct_random_calls(path))

	assert_true(
		violations.is_empty(),
		"Migrated random paths must use GameRandom: %s" % str(violations)
	)


func _roll_sequence(seed_text: String, stream_id: StringName) -> Array:
	GameRandom.enable_test_mode(seed_text)
	return [
		GameRandom.randf(stream_id),
		GameRandom.randf(stream_id),
		GameRandom.randi_range(stream_id, 1, 100),
	]


func _find_direct_random_calls(path: String) -> Array[String]:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Expected readable source file: %s" % path)
	if file == null:
		return ["%s: unreadable" % path]
	var violations: Array[String] = []
	var line_number: int = 0
	while not file.eof_reached():
		line_number += 1
		var line: String = file.get_line()
		var stripped: String = line.strip_edges()
		if stripped.begins_with("#") or stripped.contains("GameRandom."):
			continue
		for token: String in DIRECT_RANDOM_TOKENS:
			if stripped.contains(token):
				violations.append("%s:%d:%s" % [path, line_number, stripped])
	file.close()
	return violations
