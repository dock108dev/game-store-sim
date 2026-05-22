## Tests the beta diagnostics overlay gate used by editor and screenshot runs.
extends GutTest

const DEBUG_UI_SETTING: String = "debug/ui_enabled"
const BETA_DIAGNOSTICS_SETTING: String = "debug/beta_diagnostics_enabled"
const SCREENSHOT_MODE_SETTING: String = "mallcore/test/screenshot_mode"
const BetaDebugOverlayScript: GDScript = preload(
	"res://game/scripts/beta/beta_debug_overlay.gd"
)

var _prior_debug_ui: Variant
var _prior_beta_diagnostics: Variant
var _prior_screenshot_mode: Variant


func before_each() -> void:
	_prior_debug_ui = ProjectSettings.get_setting(DEBUG_UI_SETTING, false)
	_prior_beta_diagnostics = ProjectSettings.get_setting(
		BETA_DIAGNOSTICS_SETTING, false
	)
	_prior_screenshot_mode = ProjectSettings.get_setting(
		SCREENSHOT_MODE_SETTING, false
	)
	ProjectSettings.set_setting(DEBUG_UI_SETTING, false)
	ProjectSettings.set_setting(BETA_DIAGNOSTICS_SETTING, false)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, false)


func after_each() -> void:
	ProjectSettings.set_setting(DEBUG_UI_SETTING, _prior_debug_ui)
	ProjectSettings.set_setting(
		BETA_DIAGNOSTICS_SETTING, _prior_beta_diagnostics
	)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, _prior_screenshot_mode)


func _make_overlay() -> CanvasLayer:
	var overlay: CanvasLayer = CanvasLayer.new()
	overlay.set_script(BetaDebugOverlayScript)
	add_child_autofree(overlay)
	return overlay


func test_default_run_keeps_beta_diagnostics_hidden_and_inert() -> void:
	var overlay: CanvasLayer = _make_overlay()
	var panel: PanelContainer = overlay.get("_panel") as PanelContainer
	assert_not_null(panel, "Beta diagnostics panel remains available for QA mode")
	if panel != null:
		assert_false(panel.visible, "Diagnostics panel must start hidden")
	assert_eq(
		overlay.process_mode,
		Node.PROCESS_MODE_DISABLED,
		"Beta diagnostics overlay must stay inert in normal runs"
	)


func test_editor_debug_visual_setting_builds_hidden_panel() -> void:
	ProjectSettings.set_setting(DEBUG_UI_SETTING, true)
	var overlay: CanvasLayer = _make_overlay()
	var panel: PanelContainer = overlay.get("_panel") as PanelContainer
	assert_not_null(panel, "Debug visuals setting must build diagnostics panel")
	if panel != null:
		assert_false(panel.visible, "Diagnostics panel must still start hidden")


func test_beta_diagnostics_setting_builds_hidden_panel() -> void:
	ProjectSettings.set_setting(BETA_DIAGNOSTICS_SETTING, true)
	var overlay: CanvasLayer = _make_overlay()
	var panel: PanelContainer = overlay.get("_panel") as PanelContainer
	assert_not_null(panel, "Beta diagnostics setting must build diagnostics panel")
	if panel != null:
		assert_false(panel.visible, "Diagnostics panel must still start hidden")


func test_screenshot_mode_suppresses_debug_visuals() -> void:
	ProjectSettings.set_setting(DEBUG_UI_SETTING, true)
	ProjectSettings.set_setting(BETA_DIAGNOSTICS_SETTING, true)
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
