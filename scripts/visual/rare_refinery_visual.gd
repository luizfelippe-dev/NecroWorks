extends Node2D

# Presentation only. The production systems remain the sole owners of resources.
var game: Node
var states: Array[Dictionary] = []
var labels: Array[Label] = []
var previous: Array = []
var reduced_motion: bool = false
var essence_source := Vector2.ZERO
var source_valid: bool = false
var completion_count: int = 0
const SOUL_CENTER := Vector2(220, 44)
const FEEDBACK := preload("res://scripts/visual/corpse_processing_feedback.gd")
const HOUSING := preload("res://assets/sprites/factory/rare_refinery_v1.png")

func bind(target: Node) -> void:
	game = target
	position = Vector2(425, 600)
	z_index = 5
	for index: int in range(2):
		var label := Label.new()
		label.position = Vector2(index * 150, 94)
		label.size = Vector2(140, 48)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color("dbcba1"))
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 4)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
		labels.append(label)
	game.soul_extractor_completed.connect(_on_souls_completed)
	game.hematic_press_completed.connect(_on_blood_completed)
	sync_state()

func _on_souls_completed(amount: int, _remaining: int) -> void:
	confirm_output(1, amount)

func _on_blood_completed(_remaining: int) -> void:
	confirm_output(0, 1)

func confirm_output(index: int, amount: int) -> void:
	if amount <= 0 or not is_instance_valid(game):
		return
	completion_count += 1
	var effect := FEEDBACK.new()
	game.add_child(effect)
	effect.set_reduced_motion(game.reduced_motion_enabled)
	var tint := Color("bb5650") if index == 0 else Color("b994e0")
	var origin: Vector2 = to_global(Vector2(70 + index * 150, 44)) if visible else Vector2(200, 263)
	effect.play(origin, game.RESOURCE_FEEDBACK_TARGET,
		0, 0, tint, tr("REFINERY_GAIN_BLOOD" if index == 0 else "REFINERY_GAIN_SOUL") % amount)
	game.pulse_resources_panel(tint)

func essence_position() -> Vector2:
	if reduced_motion or states.size() < 2:
		return SOUL_CENTER
	var t: float = smoothstep(0.0, 0.65, float(states[1].progress))
	return essence_source.lerp(SOUL_CENTER, t) + Vector2(0, -sin(t * PI) * 32)

func _process(_delta: float) -> void:
	sync_state()

func sync_state() -> void:
	if not is_instance_valid(game):
		return
	reduced_motion = game.reduced_motion_enabled
	var paused: bool = game.wave_preparation_in_progress or game.wave_transition_in_progress or game.event_decision_in_progress
	states = [
		build_state(game.hematic_press_unlocked, game.hematic_press_queue, game.hematic_press_timer, game.HEMATIC_PRESS_CYCLE_SECONDS, paused),
		build_state(game.soul_extractor_unlocked, game.soul_extraction_queue.size(), game.soul_extractor_timer, game.get_soul_extractor_cycle_seconds(), paused),
	]
	source_valid = false
	if states[1].active:
		var candidate: Variant = game.soul_extraction_queue[0].get("corpse")
		if is_instance_valid(candidate) and candidate is Button and not candidate.is_queued_for_deletion():
			var corpse: Button = candidate
			source_valid = true
			essence_source = to_local(corpse.global_position + corpse.size * 0.5)
	var snapshot: Array = [states.duplicate(true), reduced_motion, TranslationServer.get_locale(), source_valid, essence_source]
	if snapshot == previous:
		return
	previous = snapshot
	for index: int in range(2):
		labels[index].visible = states[index].unlocked
		labels[index].text = tr("REFINERY_BLOOD" if index == 0 else "REFINERY_SOUL") + "\n" + tr(states[index].status)
	queue_redraw()

func build_state(unlocked: bool, count: int, timer: float, cycle: float, paused: bool) -> Dictionary:
	var active: bool = unlocked and count > 0 and not game.run_finished
	return {
		"unlocked": unlocked, "active": active,
		"progress": clampf(1.0 - timer / maxf(cycle, 0.001), 0, 1) if active else 0.0,
		"status": "WORKSHOP_PAUSED" if active and paused else ("REFINERY_WORKING" if active else "WORKSHOP_IDLE"),
	}

func _draw() -> void:
	# Only the head of the real queue emits essence; the corpse stays on the ground.
	if source_valid:
		var center: Vector2 = essence_position()
		var tint := Color("b994e0")
		if not reduced_motion and float(states[1].progress) < 0.65:
			draw_arc(essence_source, 15, 0, TAU, 24, Color(tint, 0.45), 1.5)
			draw_line(center, center.lerp(essence_source, 0.12), Color(tint, 0.35), 2)
			draw_circle(center, 12, Color(tint, 0.18))
			draw_circle(center, 4, tint)
	for index: int in range(states.size()):
		var state: Dictionary = states[index]
		if not state.unlocked:
			continue
		var x: float = index * 150.0
		var tint := Color("bb5650") if index == 0 else Color("b994e0")
		draw_rect(Rect2(x + 39, 23, 57, 45), Color("0c1414"))
		var progress: float = state.progress
		if state.active:
			if index == 0:
				draw_rect(Rect2(x + 39, 68 - progress * 45, 57, progress * 45), tint.darkened(0.35))
			else:
				var center := Vector2(x + 70, 44)
				draw_circle(center, 10 + progress * 13, Color(tint, 0.25))
				draw_circle(center, 5 + progress * 8, tint)
				if not reduced_motion and state.status == "REFINERY_WORKING":
					for mote: int in range(3):
						var angle: float = progress * TAU + mote * TAU / 3
						draw_circle(center + Vector2.from_angle(angle) * 25, 2, tint)
		# Separate halves preserve independent unlocks; chamber contents stay behind art.
		var half: Vector2 = HOUSING.get_size() * Vector2(0.5, 1)
		draw_texture_rect_region(HOUSING, Rect2(x, 0, 145, 90), Rect2(Vector2(index * half.x, 0), half))
		draw_rect(Rect2(x + 15, 87, 110 * progress, 3), tint)
