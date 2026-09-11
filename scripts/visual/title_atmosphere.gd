extends Control

const ART: Texture2D = preload("res://assets/backgrounds/necroworks_title_v2.png")
var time: float = 0.0
var reduced_motion: bool = false
var artwork: TextureRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	artwork = TextureRect.new()
	artwork.texture = ART
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(artwork)
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	artwork.offset_left = -12.0
	artwork.offset_right = 12.0
	artwork.offset_top = -12.0
	artwork.offset_bottom = 12.0
	var shade := TextureRect.new()
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.38, 0.64, 1.0])
	gradient.colors = PackedColorArray([
		Color(0.015, 0.022, 0.020, 0.95), Color(0.015, 0.022, 0.020, 0.88),
		Color(0.015, 0.022, 0.020, 0.14), Color(0.015, 0.022, 0.020, 0.08),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2.RIGHT
	shade.texture = texture
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(artwork, 0)


func _process(delta: float) -> void:
	if not is_visible_in_tree() or reduced_motion:
		return
	time += delta
	artwork.position = Vector2(-12.0 + sin(time * 0.09) * 6.0, -12.0 + sin(time * 0.12) * 3.0)


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	if artwork != null:
		artwork.position = Vector2(-12.0, -12.0)
