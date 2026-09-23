extends Node2D


const MAX_TRANSIENTS: int = 48
const DAMAGE_DURATION: float = 0.46
const TRACE_DURATION: float = 0.16

var reduced_motion: bool = false
var high_contrast: bool = false
var feedback_created: int = 0


func set_accessibility(reduce_motion: bool, contrast: bool) -> void:
	reduced_motion = reduce_motion
	high_contrast = contrast


func show_damage(
	world_position: Vector2,
	amount: int,
	is_hostile: bool,
	is_critical: bool = false
) -> void:
	trim_transients()
	var label := Label.new()
	label.name = "DamageNumber"
	label.position = world_position + Vector2(-55.0, -86.0)
	label.size = Vector2(110.0, 32.0)
	label.text = "-%d" % maxi(amount, 0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 420
	label.add_theme_font_size_override("font_size", 23 if is_critical else 18)
	label.add_theme_color_override(
		"font_color",
		Color(1.0, 0.34, 0.24) if is_hostile else Color(0.74, 0.92, 0.55)
	)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6 if high_contrast else 4)
	add_child(label)
	feedback_created += 1
	var tween: Tween = label.create_tween()
	tween.set_parallel(true)
	if not reduced_motion:
		tween.tween_property(label, "position:y", label.position.y - 28.0, DAMAGE_DURATION)
	tween.tween_property(
		label, "modulate:a", 0.0, 0.20 if reduced_motion else DAMAGE_DURATION
	)
	tween.chain().tween_callback(label.queue_free)


func show_attack_trace(
	start_position: Vector2,
	target_position: Vector2,
	color: Color,
	width: float = 3.0
) -> void:
	trim_transients()
	var trace := Line2D.new()
	trace.name = "AttackTrace"
	trace.points = PackedVector2Array([start_position, target_position])
	trace.width = width + (1.5 if high_contrast else 0.0)
	trace.default_color = color
	trace.z_index = 390
	trace.antialiased = true
	add_child(trace)
	feedback_created += 1
	var tween: Tween = trace.create_tween()
	tween.tween_property(
		trace, "modulate:a", 0.0, 0.08 if reduced_motion else TRACE_DURATION
	)
	tween.tween_callback(trace.queue_free)


func show_impact(
	world_position: Vector2,
	color: Color,
	radius: float = 34.0,
	is_boss: bool = false
) -> void:
	trim_transients()
	var ring := Line2D.new()
	ring.name = "BossImpact" if is_boss else "ImpactRing"
	ring.closed = true
	ring.width = 5.0 if is_boss else 3.0
	ring.default_color = color
	ring.z_index = 400
	ring.position = world_position
	var points := PackedVector2Array()
	for index: int in range(25):
		var angle: float = TAU * float(index) / 24.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	ring.points = points
	add_child(ring)
	feedback_created += 1
	var tween: Tween = ring.create_tween()
	tween.set_parallel(true)
	if not reduced_motion:
		tween.tween_property(ring, "scale", Vector2(1.45, 1.45), 0.28)
	tween.tween_property(ring, "modulate:a", 0.0, 0.14 if reduced_motion else 0.28)
	tween.chain().tween_callback(ring.queue_free)


func show_boss_banner(message: String, color: Color) -> void:
	for child: Node in get_children():
		if child is Label and child.name == "BossBanner":
			child.free()
	trim_transients()
	var banner := Label.new()
	banner.name = "BossBanner"
	banner.position = Vector2(560.0, 222.0)
	banner.size = Vector2(800.0, 58.0)
	banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banner.set_meta("priority_feedback", true)
	banner.text = message
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.z_index = 430
	banner.add_theme_font_size_override("font_size", 27)
	banner.add_theme_color_override("font_color", color)
	banner.add_theme_color_override("font_outline_color", Color.BLACK)
	banner.add_theme_constant_override("outline_size", 7)
	add_child(banner)
	feedback_created += 1
	var tween: Tween = banner.create_tween()
	tween.tween_interval(1.15)
	tween.set_parallel(true)
	if not reduced_motion:
		tween.tween_property(banner, "position:y", 205.0, 0.45)
	tween.tween_property(banner, "modulate:a", 0.0, 0.30 if reduced_motion else 0.45)
	tween.chain().tween_callback(banner.queue_free)


func trim_transients() -> void:
	var active: Array[Node] = get_children()
	while active.size() >= MAX_TRANSIENTS:
		var removable: int = -1
		for index: int in range(active.size()):
			if not active[index].has_meta("priority_feedback"):
				removable = index
				break
		if removable < 0:
			break
		var oldest: Node = active[removable]
		active.remove_at(removable)
		if is_instance_valid(oldest):
			oldest.free()
