extends Node2D

# Presentation only. The production systems remain the sole owners of resources.
var game: Node
var states: Array[Dictionary] = []
var labels: Array[Label] = []
var previous: Array = []
var reduced_motion: bool = false

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
	sync_state()

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
	var snapshot: Array = [states.duplicate(true), reduced_motion, TranslationServer.get_locale()]
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
	for index: int in range(states.size()):
		var state: Dictionary = states[index]
		if not state.unlocked:
			continue
		var x: float = index * 150.0
		var tint := Color("bb5650") if index == 0 else Color("b994e0")
		# Closed vessels, pipes and gauge are code-native vector artwork.
		draw_rect(Rect2(x + 10, 78, 120, 12), Color("292f29"))
		draw_rect(Rect2(x + 34, 8, 72, 73), Color("0c1414"))
		draw_rect(Rect2(x + 34, 8, 72, 73), Color("8b7c56"), false, 3)
		draw_line(Vector2(x + 15, 19), Vector2(x + 34, 19), Color("8b7c56"), 5)
		draw_line(Vector2(x + 106, 66), Vector2(x + 129, 66), Color("8b7c56"), 5)
		var progress: float = state.progress
		if state.active:
			if index == 0:
				draw_rect(Rect2(x + 39, 76 - progress * 62, 62, progress * 62), tint.darkened(0.35))
			else:
				var center := Vector2(x + 70, 44)
				draw_circle(center, 10 + progress * 13, Color(tint, 0.25))
				draw_circle(center, 5 + progress * 8, tint)
				if not reduced_motion and state.status == "REFINERY_WORKING":
					for mote: int in range(3):
						var angle: float = progress * TAU + mote * TAU / 3
						draw_circle(center + Vector2.from_angle(angle) * 25, 2, tint)
		for y: int in [15, 73]:
			for offset: int in [28, 112]:
				draw_circle(Vector2(x + offset, y), 3, Color("756949"))
		draw_rect(Rect2(x + 15, 87, 110 * progress, 3), tint)
