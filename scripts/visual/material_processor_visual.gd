extends Node2D

# Read-only presentation: progress comes from the real material queue.
const CORPSES := preload("res://scripts/visual/corpse_visual_catalog.gd")
const HOUSING := preload("res://assets/sprites/factory/material_press_v1.png")
const ORIGIN := Vector2(65, 575)
const DRAW_SCALE: float = 1.15
const OUTPUT := ORIGIN + Vector2(260, 84) * DRAW_SCALE
var game: Node
var progress: float = 0.0
var active: bool = false
var payload: Texture2D
var status: Label
var reduced_motion: bool = false
var last_state: Array = []

func bind(target: Node) -> void:
	game = target
	position = ORIGIN
	scale = Vector2.ONE * DRAW_SCALE
	z_index = 5
	status = Label.new()
	status.position = Vector2(-10, 120)
	status.size = Vector2(305, 35)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 15)
	status.add_theme_color_override("font_color", Color("dbcba1"))
	status.add_theme_color_override("font_outline_color", Color.BLACK)
	status.add_theme_constant_override("outline_size", 4)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(status)
	sync_state()

func _process(_delta: float) -> void:
	sync_state()

func sync_state() -> void:
	if not is_instance_valid(game):
		return
	active = not game.corpse_processing_queue.is_empty() and not game.run_finished
	reduced_motion = game.reduced_motion_enabled
	progress = clampf(1.0 - game.corpse_processor_timer / maxf(game.corpse_processor_seconds_per_corpse, 0.001), 0.0, 1.0) if active else 0.0
	var archetype: String = ""
	if active:
		var corpse: Button = game.corpse_processing_queue[0].get("corpse") as Button
		if is_instance_valid(corpse):
			archetype = str(corpse.get_meta("source_archetype", "human_warrior"))
			payload = CORPSES.get_death_texture(archetype)
	var paused: bool = game.wave_transition_in_progress or game.wave_preparation_in_progress or game.event_decision_in_progress
	var key: String = "PRESS_IDLE"
	if active:
		key = "PRESS_PAUSED" if paused else ("PRESS_INTAKE" if progress < 0.30 else ("PRESS_CRUSH" if progress < 0.75 else "PRESS_OUTPUT"))
	status.text = tr(key)
	var state: Array = [active, progress, archetype, reduced_motion, status.text]
	if state != last_state:
		last_state = state
		queue_redraw()

func _draw() -> void:
	var metal := Color("343d35")
	var bronze := Color("9b8151")
	var accent := Color("8cc54c") if active else Color("506045")
	draw_texture_rect(HOUSING, Rect2(0, 0, 285, 112), false)
	var travel: float = progress * 72.0 if active and not reduced_motion else 0.0
	for index: int in range(12):
		var x: float = fposmod(index * 25.0 + travel, 279.0) + 3.0
		draw_line(Vector2(x, 83), Vector2(x - 3, 86), bronze.darkened(0.4), 1)
	# Moving ram occupies the open chamber in the painted housing.
	var compression: float = sin(clampf((progress - 0.30) / 0.45, 0.0, 1.0) * PI) if active and not reduced_motion else 0.0
	draw_rect(Rect2(139, 36, 12, 9 + compression * 30), Color("b9b8a6"))
	draw_line(Vector2(142, 36), Vector2(142, 45 + compression * 30), Color("eee3bb"), 2)
	if active and payload != null:
		var intake: float = clampf(progress / 0.3, 0.0, 1.0)
		var at_x: float = 145.0 if reduced_motion else lerpf(35, 145, intake)
		if progress < 0.75:
			var height: float = 26.0 * (1.0 - compression * 0.8)
			draw_texture_rect(payload, Rect2(at_x - 32, 83 - height, 64, height), false)
		else:
			var output_x: float = 248.0 if reduced_motion else lerpf(165, 260, (progress - 0.75) / 0.25)
			for index: int in range(4):
				draw_rect(Rect2(output_x + index * 5, 75 + (index % 2) * 4, 5, 7), Color("d9cda8"))
	draw_rect(Rect2(113, 43 + compression * 30, 62, 10), metal)
	draw_rect(Rect2(113, 43 + compression * 30, 62, 10), bronze, false, 1)
	for x: float in [120.0, 168.0]:
		draw_circle(Vector2(x, 48 + compression * 30), 2, bronze)
	if compression > 0.6 and not reduced_motion:
		for index: int in range(5):
			var drift: float = fposmod(progress * 8 + index * 0.23, 1.0)
			draw_circle(Vector2(116 + index * 13, 76 - drift * 19), 1.5, Color(0.7, 0.75, 0.5, 1.0 - drift))
	draw_rect(Rect2(4, 115, 277, 3), Color("1c291a"))
	if active:
		draw_rect(Rect2(4, 115, 277 * progress, 3), accent)
