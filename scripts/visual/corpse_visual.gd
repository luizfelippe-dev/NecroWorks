extends Button


const CATALOG: Script = preload("res://scripts/visual/corpse_visual_catalog.gd")

var unit_sprite: Sprite2D
var identity_label: Label


func _ready() -> void:
	flat = true
	custom_minimum_size = Vector2(118.0, 82.0)
	size = custom_minimum_size
	for color_name: String in [
		"font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"
	]:
		add_theme_color_override(color_name, Color.TRANSPARENT)
	_create_visual_nodes()


func configure_visual(
	source_archetype: String, source_elite: bool, source_boss: bool
) -> void:
	_create_visual_nodes()
	var profile: Dictionary = CATALOG.get_profile(
		source_archetype, source_elite, source_boss
	)
	unit_sprite.texture = profile.get("texture") as Texture2D
	unit_sprite.modulate = profile.get("tint", Color.WHITE) as Color
	unit_sprite.rotation = float(profile.get("rotation", -0.12))
	var texture_height: float = maxf(float(unit_sprite.texture.get_height()), 1.0)
	var target_height: float = float(profile.get("target_height", 58.0))
	unit_sprite.scale = Vector2.ONE * minf(
		target_height / texture_height,
		110.0 / maxf(float(unit_sprite.texture.get_width()), 1.0)
	)
	set_meta("visual_family", str(profile.get("family", "armored")))


func set_display_text(value: String) -> void:
	_create_visual_nodes()
	text = value
	identity_label.text = value


func _create_visual_nodes() -> void:
	if unit_sprite == null:
		unit_sprite = Sprite2D.new()
		unit_sprite.name = "CorpseSprite"
		unit_sprite.position = Vector2(59.0, 35.0)
		unit_sprite.z_index = 1
		unit_sprite.show_behind_parent = false
		add_child(unit_sprite)
	if identity_label == null:
		identity_label = Label.new()
		identity_label.name = "IdentityLabel"
		identity_label.position = Vector2(-8.0, 61.0)
		identity_label.size = Vector2(134.0, 20.0)
		identity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		identity_label.add_theme_font_size_override("font_size", 12)
		identity_label.add_theme_color_override(
			"font_color", Color(0.82, 0.80, 0.72, 1.0)
		)
		identity_label.z_index = 2
		identity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(identity_label)
