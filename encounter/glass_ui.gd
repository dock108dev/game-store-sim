# Native Godot adaptation of Glass UI Starter 01.
# Uses translucent StyleBoxFlat surfaces, not a screen-reading blur shader.
extends RefCounted

static func panel_style(dark: bool = false) -> StyleBoxFlat:
 var box := StyleBoxFlat.new()
 box.bg_color = Color("17243df2") if dark else Color("f3f7fff5")
 box.border_color = Color("ffffff55") if dark else Color("ffffff")
 box.set_border_width_all(1)
 box.set_corner_radius_all(18)
 box.shadow_color = Color("182d5022")
 box.shadow_size = 8
 box.shadow_offset = Vector2(0, 4)
 box.content_margin_left = 12
 box.content_margin_right = 12
 box.content_margin_top = 8
 box.content_margin_bottom = 8
 return box

static func make_theme() -> Theme:
 var theme := Theme.new()
 theme.default_font_size = 18
 for type in ["Button", "OptionButton", "MenuButton"]:
  for state in ["normal", "hover", "pressed", "disabled"]:
   var box := panel_style()
   box.set_corner_radius_all(12)
   box.bg_color = {"normal":Color("f8fafff5"),"hover":Color("e3eeff"),"pressed":Color("d0e2ff"),"disabled":Color("dce3efdd")}[state]
   box.shadow_size = 2
   box.content_margin_top = 6
   box.content_margin_bottom = 6
   theme.set_stylebox(state, type, box)
  for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
   theme.set_color(key, type, Color("184779"))
  theme.set_color("font_disabled_color", type, Color("69778b"))
  var focus := panel_style()
  focus.draw_center = false
  focus.border_color = Color("1477ef")
  focus.set_border_width_all(2)
  focus.set_corner_radius_all(12)
  focus.shadow_size = 0
  theme.set_stylebox("focus", type, focus)
 for type in ["LineEdit", "TextEdit"]:
  theme.set_stylebox("normal", type, panel_style())
  theme.set_color("font_color", type, Color("182338"))
  theme.set_color("caret_color", type, Color("0969df"))
 theme.set_stylebox("panel", "Panel", panel_style())
 theme.set_stylebox("panel", "PanelContainer", panel_style())
 theme.set_stylebox("panel", "PopupMenu", panel_style())
 theme.set_color("font_color", "PopupMenu", Color("182338"))
 theme.set_stylebox("panel", "AcceptDialog", panel_style())
 theme.set_color("font_color", "Label", Color("182338"))
 return theme

# Starter 02 adaptation: one clear primary action without changing focus behavior.
static func emphasize(button: Button) -> void:
 for state in ["normal", "hover", "pressed"]:
  var box=panel_style()
  box.bg_color=Color("0969df") if state=="normal" else Color("0757bd")
  box.set_corner_radius_all(12)
  button.add_theme_stylebox_override(state,box)
 for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
  button.add_theme_color_override(key,Color.WHITE)
