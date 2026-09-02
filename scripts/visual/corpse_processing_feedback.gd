extends Node2D


const TOKEN_RADIUS: float = 20.0
const TRAVEL_DURATION: float = 0.38
const POPUP_DURATION: float = 0.72

var accent_color: Color = Color(0.38, 0.82, 0.25, 1.0)
var popup_label: Label = null
var arrived: bool = false
var reduced_motion: bool = false


func play(
	start_position: Vector2,
	target_position: Vector2,
	bones_gained: int,
	flesh_gained: int,
	accent: Color
) -> void:

	global_position = start_position
	accent_color = accent
	z_index = 350
	add_to_group("processing_feedback")
	create_yield_label(bones_gained, flesh_gained)
	queue_redraw()
	if reduced_motion:
		global_position = target_position
		show_yield_popup()
		return


	var travel_tween: Tween = create_tween()
	travel_tween.set_trans(Tween.TRANS_QUAD)
	travel_tween.set_ease(Tween.EASE_IN_OUT)
	travel_tween.set_parallel(true)
	travel_tween.tween_property(
		self,
		"global_position",
		target_position,
		TRAVEL_DURATION
	)
	travel_tween.tween_property(
		self,
		"rotation",
		TAU * 0.85,
		TRAVEL_DURATION
	)
	travel_tween.tween_property(
		self,
		"scale",
		Vector2(0.55, 0.55),
		TRAVEL_DURATION
	)
	travel_tween.chain().tween_callback(show_yield_popup)


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled


func create_yield_label(
	bones_gained: int,
	flesh_gained: int
) -> void:

	popup_label = Label.new()
	popup_label.name = "YieldPopup"
	popup_label.position = Vector2(-170.0, -20.0)
	popup_label.size = Vector2(340.0, 42.0)
	popup_label.text = tr("FEEDBACK_RESOURCE_GAIN") % [
		bones_gained,
		flesh_gained
	]
	popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_label.add_theme_font_size_override("font_size", 20)
	popup_label.add_theme_color_override("font_color", accent_color)
	popup_label.add_theme_color_override("font_outline_color", Color.BLACK)
	popup_label.add_theme_constant_override("outline_size", 5)
	popup_label.visible = false
	popup_label.z_index = 5
	add_child(popup_label)


func show_yield_popup() -> void:

	arrived = true
	rotation = 0.0
	scale = Vector2.ONE
	popup_label.visible = true
	queue_redraw()
	if reduced_motion:
		popup_label.position.y = -46.0
		get_tree().create_timer(0.35, false).timeout.connect(queue_free)
		return


	var popup_tween: Tween = create_tween()
	popup_tween.set_trans(Tween.TRANS_QUAD)
	popup_tween.set_ease(Tween.EASE_OUT)
	popup_tween.set_parallel(true)
	popup_tween.tween_property(
		popup_label,
		"position:y",
		-78.0,
		POPUP_DURATION
	)
	popup_tween.tween_property(
		popup_label,
		"modulate:a",
		0.0,
		POPUP_DURATION
	)
	popup_tween.tween_property(
		self,
		"modulate:a",
		0.0,
		POPUP_DURATION
	)
	popup_tween.chain().tween_callback(queue_free)


func _draw() -> void:

	var glow_alpha: float = 0.34 if arrived else 0.18
	draw_circle(
		Vector2.ZERO,
		TOKEN_RADIUS + (8.0 if arrived else 2.0),
		Color(accent_color, glow_alpha)
	)
	draw_circle(
		Vector2.ZERO,
		TOKEN_RADIUS,
		Color(0.035, 0.045, 0.04, 0.98)
	)
	draw_arc(
		Vector2.ZERO,
		TOKEN_RADIUS,
		0.0,
		TAU,
		28,
		accent_color,
		3.0
	)
	draw_line(
		Vector2(-10.0, -7.0),
		Vector2(10.0, 7.0),
		accent_color,
		3.0
	)
	draw_line(
		Vector2(-10.0, 7.0),
		Vector2(10.0, -7.0),
		accent_color,
		3.0
	)
