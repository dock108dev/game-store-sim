## Unit tests for NPCSpawnerSystem store-capacity and archetype configuration.
extends GutTest

var _system: NPCSpawnerSystem
var _store_root: Node3D
var _store_definition: StoreDefinition
var _pool_events: Array[Dictionary] = []


func before_each() -> void:
	ContentRegistry.clear_for_testing()
	_pool_events = []
	EventBus.npc_pool_changed.connect(_on_npc_pool_changed)
	_store_root = Node3D.new()
	_store_root.name = "retro_games"
	add_child_autofree(_store_root)
	_system = NPCSpawnerSystem.new()
	add_child_autofree(_system)
	_system.initialize()
	_store_definition = StoreDefinition.new()
	_store_definition.id = "retro_games"
	_store_definition.size_category = "medium"
	ContentRegistry.register(&"retro_games", _store_definition, "store")
	ContentRegistry.register_entry(
		{"id": "retro_games", "display_name": "Retro Games"},
		"store"
	)
	ContentRegistry.register_entry(
		{
			"id": "window_browser",
			"personality_type": "WINDOW_BROWSER",
			"browse_duration_mult": 1.5,
		},
		"personality_data"
	)
	EventBus.active_store_changed.emit(&"retro_games")


func after_each() -> void:
	if EventBus.npc_pool_changed.is_connected(_on_npc_pool_changed):
		EventBus.npc_pool_changed.disconnect(_on_npc_pool_changed)
	ContentRegistry.clear_for_testing()


func _on_npc_pool_changed(data: Dictionary) -> void:
	_pool_events.append(data)


func test_medium_store_uses_medium_capacity_constant() -> void:
	for _i: int in range(NPCSpawnerSystem.MEDIUM_STORE_CAPACITY):
		assert_not_null(_system.spawn_npc(&"window_browser", Vector3.ZERO))
	assert_null(_system.spawn_npc(&"window_browser", Vector3.ONE))


func test_missing_npc_container_is_created_on_demand() -> void:
	var created_store := Node3D.new()
	created_store.name = "created_store"
	add_child_autofree(created_store)
	var created_def := StoreDefinition.new()
	created_def.id = "created_store"
	ContentRegistry.register(&"created_store", created_def, "store")
	ContentRegistry.register_entry({"id": "created_store"}, "store")
	EventBus.active_store_changed.emit(&"created_store")
	var npc: ShopperAI = (
		_system.spawn_npc(&"window_browser", Vector3(5.0, 0.0, 0.0))
		as ShopperAI
	)
	var container := created_store.get_node("npc_container") as Node3D
	assert_not_null(npc)
	assert_not_null(container)
	assert_eq(npc.get_parent(), container)


func test_spawn_and_despawn_emit_pool_metrics() -> void:
	var npc: ShopperAI = (
		_system.spawn_npc(&"window_browser", Vector3.ZERO) as ShopperAI
	)
	assert_not_null(npc)
	_system.despawn_npc(npc)
	var reasons: Array[String] = []
	for event: Dictionary in _pool_events:
		reasons.append(str(event.get("reason", "")))
	assert_true(reasons.has("spawn_success"))
	assert_true(reasons.has("despawn"))
	assert_eq(int(_pool_events[-1].get("active_count", -1)), 0)
