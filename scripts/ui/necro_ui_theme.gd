extends RefCounted

const FRAME_SCRIPT: Script = preload("res://scripts/ui/industrial_panel_frame.gd")
const DISPLAY_FONT: Font = preload("res://assets/fonts/cinzel/Cinzel.ttf")
const BODY_FONT: Font = preload("res://assets/fonts/barlow/Barlow-Medium.ttf")
const COMPACT_FONT: Font = preload("res://assets/fonts/barlow_condensed/BarlowCondensed-Medium.ttf")
const INK := Color("101514")
const SURFACE := Color("19201c")
const BRONZE := Color("796c4d")
const IVORY := Color("e8dec0")
const GREEN := Color("9fca58")
const MUTED := Color("97a08e")
const BLOOD := Color("cf776b")
const SOUL := Color("b99cdf")


static func stylebox(fill: Color, border: Color, width: int = 1, radius: int = 3) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style


static func style_button(button: Button, accent: Color = GREEN) -> void:
	button.add_theme_font_override("font", BODY_FONT)
	button.add_theme_stylebox_override("normal", stylebox(SURFACE, BRONZE))
	button.add_theme_stylebox_override("hover", stylebox(SURFACE.lightened(0.09), accent, 2))
	button.add_theme_stylebox_override("pressed", stylebox(accent.darkened(0.78), accent, 2))
	button.add_theme_stylebox_override("disabled", stylebox(INK, BRONZE.darkened(0.35)))
	var focus_style := stylebox(Color.TRANSPARENT, IVORY, 2)
	focus_style.expand_margin_left = 3.0
	focus_style.expand_margin_right = 3.0
	focus_style.expand_margin_top = 3.0
	focus_style.expand_margin_bottom = 3.0
	button.add_theme_stylebox_override("focus", focus_style)
	button.add_theme_color_override("font_color", IVORY)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", MUTED.darkened(0.13))
	button.add_theme_color_override("icon_disabled_color", Color(0.65, 0.65, 0.65, 0.7))


static func decorate_panel(panel: Control, accent: Color = BRONZE) -> Control:
	var previous := panel.get_node_or_null("IndustrialFrame")
	if previous != null:
		return previous as Control
	var frame := FRAME_SCRIPT.new() as Control
	frame.name = "IndustrialFrame"
	frame.set("accent", accent)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(frame)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return frame
