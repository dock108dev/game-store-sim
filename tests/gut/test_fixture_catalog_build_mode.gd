## Tests fixture catalog panel animation, filtering, and build mode selection flow.
extends GutTest

const _CatalogScene: PackedScene = preload(
	"res://game/scenes/ui/fixture_catalog.tscn"
)
const _CatalogScript := preload(
	"res://game/scripts/ui/fixture_catalog_panel.gd"
)

var _saved_game_state: GameManager.State
var _saved_store_id: StringName = &""
var _catalog
var _data_loader: DataLoader
var _economy_system: EconomySystem


func before_each() -> void:
	_saved_game_state = GameManager.current_state
	_saved_store_id = GameManager.current_store_id
	GameManager.current_state = GameManager.State.GAMEPLAY
	GameManager.current_store_id = &"sports"
	StoreCustomizationSystem.reset_for_testing()

	_data_loader = DataLoader.new()
	_data_loader.load_all_content()
	add_child_autofree(_data_loader)

	_economy_system = EconomySystem.new()
	add_child_autofree(_economy_system)
	_economy_system.initialize(1000.0)

	_catalog = _CatalogScene.instantiate()
	_catalog.data_loader = _data_loader
	_catalog.economy_system = _economy_system
	_catalog.store_type = &"sports"
	add_child_autofree(_catalog)


func after_each() -> void:
	GameManager.current_state = _saved_game_state
	GameManager.current_store_id = _saved_store_id


func test_build_mode_enter_opens_catalog_without_delay() -> void:
	EventBus.build_mode_entered.emit()
	await get_tree().process_frame
	assert_true(_catalog.is_open())
	assert_true(_catalog._panel.visible)


func test_retro_locked_fixture_is_grayed_out_with_tooltip() -> void:
	_catalog.store_type = &"retro_games"
	GameManager.current_store_id = &"retro_games"
	_catalog.open()
	_catalog._set_active_category_tab(&"stockroom")

	var card: PanelContainer = _catalog._card_panels.get("repair_workbench") as PanelContainer
	var button: Button = _catalog._card_buttons.get("repair_workbench") as Button
	assert_not_null(card)
	assert_not_null(button)
	assert_true(button.disabled)
	assert_eq(card.modulate, _CatalogScript.LOCKED_COLOR)
	assert_string_contains(card.tooltip_text, "Reputation 15 required")
	assert_string_contains(card.tooltip_text, "Day 3 required")


func test_store_specific_fixtures_only_show_for_active_store() -> void:
	_catalog.store_type = &"retro_games"
	GameManager.current_store_id = &"retro_games"
	_catalog.open()

	assert_not_null(_catalog._card_panels.get("testing_station"))
	assert_null(_catalog._card_panels.get("authentication_station"))


func test_selecting_fixture_emits_signal_and_enters_placement() -> void:
	var build_mode: BuildModeSystem = BuildModeSystem.new()
	add_child_autofree(build_mode)
	build_mode.initialize(null, BuildModeGrid.StoreSize.SMALL, Vector3.ZERO)

	var placement: FixturePlacementSystem = FixturePlacementSystem.new()
	add_child_autofree(placement)
	placement.initialize(
		build_mode.get_grid(), null, _economy_system, 8,
		BuildModeGrid.StoreSize.SMALL
	)
	placement.set_data_loader(_data_loader)
	build_mode.set_placement_system(placement)
	build_mode.enter_build_mode()

	_catalog.open()
	watch_signals(EventBus)
	var button: Button = _catalog._card_buttons.get("floor_rack") as Button
	assert_not_null(button)

	button.emit_signal("pressed")

	assert_signal_emitted(EventBus, "fixture_catalog_requested")
	assert_eq(build_mode.get_state(), BuildModeSystem.State.PLACEMENT)
	assert_eq(placement.get_selected_fixture_type(), "floor_rack")


func test_fixture_card_shows_catalog_metadata_and_silhouette() -> void:
	_catalog.open()
	_catalog._set_active_category_tab(&"shelves")
	var card: PanelContainer = _catalog._card_panels.get("wall_shelf") as PanelContainer
	assert_not_null(card)
	assert_null(card.find_child("IconPlaceholder", true, false))
	assert_not_null(card.find_child("SilhouetteView", true, false))
	var owned_label: Label = card.find_child("OwnedLabel", true, false) as Label
	var capacity_label: Label = card.find_child("CapacityLabel", true, false) as Label
	var effect_label: Label = card.find_child("EffectLabel", true, false) as Label
	var footprint_label: Label = card.find_child("FootprintLabel", true, false) as Label
	assert_string_contains(owned_label.text, "Owned: 0")
	assert_string_contains(capacity_label.text, "4 item slots")
	assert_string_contains(effect_label.text, "Wall display capacity")
	assert_string_contains(footprint_label.text, "Sell-back: $15")
	assert_string_contains(footprint_label.text, "Wall")


func test_category_tabs_include_store_design_groups() -> void:
	_catalog.open()
	for tab_name: String in [
		"FixturesTab", "ShelvesTab", "CountersTab", "SignageTab",
		"DecorTab", "SurfacesTab", "LightingTab", "StockroomTab",
	]:
		assert_not_null(_catalog._category_tabs.get_node_or_null(tab_name))


func test_surface_tab_shows_swatch_states() -> void:
	_catalog.open()
	_catalog._set_active_category_tab(&"surfaces")
	var ready_card: PanelContainer = _catalog._card_panels.get("floor_tile_cream") as PanelContainer
	var selected_card: PanelContainer = _catalog._card_panels.get("wall_warm_white") as PanelContainer
	assert_not_null(ready_card.find_child("SurfaceSwatch", true, false))
	assert_not_null(selected_card.find_child("SurfaceSwatch", true, false))
	assert_eq(selected_card.modulate, _CatalogScript.SELECTED_COLOR)


func test_design_card_applies_selection_from_shared_catalog() -> void:
	_catalog.open()
	_catalog._set_active_category_tab(&"surfaces")
	var button: Button = _catalog._card_buttons.get("floor_tile_cream") as Button
	assert_not_null(button)

	button.emit_signal("pressed")

	assert_eq(
		StoreCustomizationSystem.get_design_selection(&"floor"),
		&"floor_tile_cream"
	)
	assert_eq(_economy_system.get_cash(), 965.0)
	assert_string_contains(_catalog._info_label.text, "Applied")


func test_unaffordable_card_uses_need_cash_state() -> void:
	_economy_system.initialize(10.0)
	_catalog.open()
	_catalog._set_active_category_tab(&"counters")
	var counter_card: PanelContainer = _catalog._card_panels.get("counter") as PanelContainer
	var counter_button: Button = _catalog._card_buttons.get("counter") as Button
	assert_eq(counter_card.modulate, _CatalogScript.UNAFFORDABLE_COLOR)
	assert_true(counter_button.disabled)
	assert_eq(counter_button.text, _CatalogScript.UNAFFORDABLE_BUTTON_TEXT)


func test_owned_count_refreshes_from_placement_system() -> void:
	var grid := BuildModeGrid.new()
	add_child_autofree(grid)
	grid.initialize(BuildModeGrid.StoreSize.SMALL, Vector3.ZERO)
	var placement := FixturePlacementSystem.new()
	add_child_autofree(placement)
	placement.initialize(grid, null, _economy_system, 8, BuildModeGrid.StoreSize.SMALL)
	placement.set_data_loader(_data_loader)
	placement.register_existing_fixture(
		"placed_wall_shelf", "wall_shelf", Vector2i(1, 1), 0, false, 30.0
	)
	_catalog.placement_system = placement
	_catalog.open()
	_catalog._set_active_category_tab(&"shelves")
	var card: PanelContainer = _catalog._card_panels.get("wall_shelf") as PanelContainer
	var owned_label: Label = card.find_child("OwnedLabel", true, false) as Label
	assert_string_contains(owned_label.text, "Owned: 1")


func test_build_action_controls_reflect_selection_and_invalid_state() -> void:
	_catalog.open()
	assert_true(_catalog._place_button.disabled)
	assert_true(_catalog._rotate_button.disabled)
	assert_true(_catalog._move_button.disabled)
	assert_true(_catalog._sell_button.disabled)
	var button: Button = _catalog._card_buttons.get("floor_rack") as Button
	button.emit_signal("pressed")
	assert_false(_catalog._place_button.disabled)
	assert_false(_catalog._rotate_button.disabled)
	assert_eq(_catalog._back_button.text, "Cancel")
	EventBus.fixture_placement_invalid.emit("blocked")
	assert_string_contains(_catalog._info_label.text, "Invalid placement")
