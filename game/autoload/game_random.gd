## Central random service with deterministic named streams for automation runs.
extends Node

const DEFAULT_ROOT_SEED: String = ""

var _test_mode: bool = false
var _root_seed_text: String = DEFAULT_ROOT_SEED
var _streams: Dictionary = {}


## Enables deterministic streams derived from the supplied root seed.
func enable_test_mode(root_seed: Variant) -> void:
	_test_mode = true
	_root_seed_text = str(root_seed)
	_streams.clear()


## Returns to nondeterministic stream seeding.
func disable_test_mode() -> void:
	_test_mode = false
	_root_seed_text = DEFAULT_ROOT_SEED
	_streams.clear()


## Returns true when streams are derived from a fixed root seed.
func is_test_mode() -> bool:
	return _test_mode


## Returns the active root seed text used for stream derivation.
func get_root_seed() -> String:
	return _root_seed_text


## Clears one stream so its next use starts from the derived initial state.
func reset_stream(stream_id: StringName) -> void:
	_streams.erase(stream_id)


## Overrides one stream seed without changing the root seed.
func set_stream_seed(stream_id: StringName, seed_value: Variant) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_text_to_int(str(seed_value))
	_streams[stream_id] = rng


## Returns the current engine state for one stream.
func get_stream_state(stream_id: StringName) -> int:
	return _get_rng(stream_id).state


## Restores the current engine state for one stream.
func set_stream_state(stream_id: StringName, state_value: int) -> void:
	_get_rng(stream_id).state = state_value


## Returns a random float in [0, 1) from a named stream.
func randf(stream_id: StringName) -> float:
	return _get_rng(stream_id).randf()


## Returns a random float in [from, to] from a named stream.
func randf_range(stream_id: StringName, from: float, to: float) -> float:
	if is_equal_approx(from, to):
		return from
	if from > to:
		push_error("GameRandom: invalid float range %.3f..%.3f" % [from, to])
		return from
	return _get_rng(stream_id).randf_range(from, to)


## Returns a random integer from a named stream.
func randi(stream_id: StringName) -> int:
	return _get_rng(stream_id).randi()


## Returns a random integer in [from, to] from a named stream.
func randi_range(stream_id: StringName, from: int, to: int) -> int:
	if from == to:
		return from
	if from > to:
		push_error("GameRandom: invalid integer range %d..%d" % [from, to])
		return from
	return _get_rng(stream_id).randi_range(from, to)


## Returns true with the supplied probability without advancing fixed outcomes.
func chance(stream_id: StringName, probability: float) -> bool:
	if probability <= 0.0:
		return false
	if probability >= 1.0:
		return true
	return self.randf(stream_id) < probability


## Returns a stream-backed random array index, or -1 for empty arrays.
func pick_index(stream_id: StringName, size: int) -> int:
	if size <= 0:
		return -1
	return self.randi_range(stream_id, 0, size - 1)


## Returns a stream-backed weighted index, or -1 when all weights are zero.
func weighted_index(stream_id: StringName, weights: Array[float]) -> int:
	var total: float = 0.0
	for weight: float in weights:
		total += maxf(weight, 0.0)
	if total <= 0.0:
		return -1

	var roll: float = self.randf(stream_id) * total
	var cumulative: float = 0.0
	for index: int in range(weights.size()):
		cumulative += maxf(weights[index], 0.0)
		if roll <= cumulative:
			return index
	return weights.size() - 1


func _get_rng(stream_id: StringName) -> RandomNumberGenerator:
	if _streams.has(stream_id):
		return _streams[stream_id] as RandomNumberGenerator
	var rng := RandomNumberGenerator.new()
	if _test_mode:
		rng.seed = _derive_stream_seed(stream_id)
	else:
		rng.randomize()
	_streams[stream_id] = rng
	return rng


func _derive_stream_seed(stream_id: StringName) -> int:
	return _seed_text_to_int("%s:%s" % [_root_seed_text, String(stream_id)])


func _seed_text_to_int(seed_text: String) -> int:
	if seed_text.is_valid_int():
		return int(seed_text)
	return seed_text.hash()
