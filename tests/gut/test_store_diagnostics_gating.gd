## Tests the store session diagnostics overlay gate used by editor and screenshot runs.
extends GutTest

const DEBUG_UI_SETTING: String = "debug/ui_enabled"
const STORE_DIAGNOSTICS_SETTING: String = "debug/store_session_diagnostics_enabled"
const SCREENSHOT_MODE_SETTING: String = "mallcore/test/screenshot_mode"
const StoreDebugOverlayScript: GDScript = preload(
	"res://game/scripts/store_session/store_debug_overlay.gd"
)

var _prior_debug_ui: Variant
var _prior_store_diagnostics: Variant
var _prior_screenshot_mode: Variant


func before_each() -> void:
	_prior_debug_ui = ProjectSettings.get_setting(DEBUG_UI_SETTING, false)
	_prior_store_diagnostics = ProjectSettings.get_setting(
		STORE_DIAGNOSTICS_SETTING, false
	)
	_prior_screenshot_mode = ProjectSettings.get_setting(
		SCREENSHOT_MODE_SETTING, false
	)
	ProjectSettings.set_setting(DEBUG_UI_SETTING, false)
	ProjectSettings.set_setting(STORE_DIAGNOSTICS_SETTING, false)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, false)


func after_each() -> void:
	ProjectSettings.set_setting(DEBUG_UI_SETTING, _prior_debug_ui)
	ProjectSettings.set_setting(
		STORE_DIAGNOSTICS_SETTING, _prior_store_diagnostics
	)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, _prior_screenshot_mode)


func _make_overlay() -> CanvasLayer:
	var overlay: CanvasLayer = CanvasLayer.new()
	overlay.set_script(StoreDebugOverlayScript)
	add_child_autofree(overlay)
	return overlay


func test_default_run_keeps_store_diagnostics_hidden_and_inert() -> void:
	var overlay: CanvasLayer = _make_overlay()
	var panel: PanelContainer = overlay.get("_panel") as PanelContainer
	assert_not_null(panel, "store session diagnostics panel remains available for QA mode")
	if panel != null:
		assert_false(panel.visible, "Diagnostics panel must start hidden")
	assert_eq(
		overlay.process_mode,
		Node.PROCESS_MODE_DISABLED,
		"store session diagnostics overlay must stay inert in normal runs"
	)


func test_editor_debug_visual_setting_builds_hidden_panel() -> void:
	ProjectSettings.set_setting(DEBUG_UI_SETTING, true)
	var overlay: CanvasLayer = _make_overlay()
	var panel: PanelContainer = overlay.get("_panel") as PanelContainer
	assert_not_null(panel, "Debug visuals setting must build diagnostics panel")
	if panel != null:
		assert_false(panel.visible, "Diagnostics panel must still start hidden")


func test_store_diagnostics_setting_builds_hidden_panel() -> void:
	ProjectSettings.set_setting(STORE_DIAGNOSTICS_SETTING, true)
	var overlay: CanvasLayer = _make_overlay()
	var panel: PanelContainer = overlay.get("_panel") as PanelContainer
	assert_not_null(panel, "store session diagnostics setting must build diagnostics panel")
	if panel != null:
		assert_false(panel.visible, "Diagnostics panel must still start hidden")


func test_screenshot_mode_suppresses_debug_visuals() -> void:
	ProjectSettings.set_setting(DEBUG_UI_SETTING, true)
	ProjectSettings.set_setting(STORE_DIAGNOSTICS_SETTING, true)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, true)
	var overlay: CanvasLayer = _make_overlay()
	var panel: PanelContainer = overlay.get("_panel") as PanelContainer
	assert_not_null(panel, "Screenshot mode keeps the QA panel seam available")
	if panel != null:
		assert_false(panel.visible, "Screenshot mode must keep diagnostics hidden")
	assert_eq(
		overlay.process_mode,
		Node.PROCESS_MODE_DISABLED,
		"Screenshot mode must suppress diagnostics even when debug settings are on"
	)
