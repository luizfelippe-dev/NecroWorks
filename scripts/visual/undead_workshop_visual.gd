extends Node2D

const HOUSING := preload("res://assets/sprites/factory/undead_workshop_v1.png")
const SPRITES := preload("res://scripts/visual/unit_sprite_catalog.gd")
const ORIGIN := Vector2(65, 385)
var game: Node
var lines: Array[Dictionary] = []
var labels: Array[Label] = []
var textures: Dictionary = {}
var reduced_motion: bool = false
var completion_count: int = 0
var last_signature: Array = []

func bind(target: Node) -> void:
	game = target
	position = ORIGIN
	z_index = 5
	for index: int in range(2):
		var label := Label.new()
		label.position = Vector2(index * 165, 143)
		label.size = Vector2(155, 42)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color("dbd0ae"))
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 4)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
		labels.append(label)
	game.production_unit_completed.connect(_on_completed)
	sync_state()

func _process(_delta: float) -> void:
	sync_state()

func _line_state(queue: Array[Dictionary], timer: float, cycle: float, fallback: String) -> Dictionary:
	var working: bool = not queue.is_empty() and not game.run_finished
	var recipe: String = str(queue[0].get("unit_type", fallback)) if working else fallback
	var progress: float = clampf(1.0 - timer / maxf(cycle, 0.001), 0, 1) if working else 0.0
	var paused: bool = game.wave_preparation_in_progress or game.wave_transition_in_progress or game.event_decision_in_progress
	var key: String = "WORKSHOP_IDLE"
	if working:
		key = "WORKSHOP_PAUSED" if paused else ("WORKSHOP_FULL" if timer <= 0 and game.get_available_undead_capacity() <= 0 else "WORKSHOP_BUILDING")
	if not textures.has(recipe):
		var base: Texture2D = SPRITES.get_texture(recipe)
		var cropped := AtlasTexture.new()
		cropped.atlas = base
		cropped.region = base.get_image().get_used_rect()
		textures[recipe] = cropped
	return {"active": working, "recipe": recipe, "progress": progress, "status": key}

func sync_state() -> void:
	if not is_instance_valid(game):
		return
	reduced_motion = game.reduced_motion_enabled
	lines = [
		_line_state(game.skeleton_production_queue, game.skeleton_assembler_timer, game.SKELETON_ASSEMBLER_BASE_SECONDS, "skeleton"),
		_line_state(game.zombie_production_queue, game.flesh_vat_timer, game.FLESH_VAT_BASE_SECONDS, "zombie"),
	]
	var signature: Array = [lines.duplicate(true), reduced_motion, TranslationServer.get_locale()]
	if signature == last_signature:
		return
	last_signature = signature
	for index: int in range(2):
		labels[index].text = tr("WORKSHOP_BONES" if index == 0 else "WORKSHOP_FLESH") + "\n" + tr(lines[index].status)
	queue_redraw()

func _on_completed(recipe: String, _remaining: int) -> void:
	if not is_instance_valid(game) or game.combat_feedback == null:
		return
	var units: Array = game.zombies if recipe == "zombie" else game.skeletons
	if units.is_empty() or not is_instance_valid(units.back()):
		return
	completion_count += 1
	var destination: Vector2 = units.back().global_position
	var source: Vector2 = to_global(Vector2(248 if recipe == "zombie" else 86, 110))
	if not visible:
		source = Vector2(200, 263)
	var tint := Color("cf976f") if recipe == "zombie" else Color("c7d992")
	# Confirmation only: the unit is already alive. No duplicated sprite or delay.
	if not game.reduced_motion_enabled:
		game.combat_feedback.show_attack_trace(source, destination, tint, 2.0)
	game.combat_feedback.show_impact(destination, tint, 24.0)

func _draw() -> void:
	if lines.size() != 2:
		return
	for index: int in range(2):
		var state: Dictionary = lines[index]
		if not state.active:
			continue
		var center_x: float = 86.0 if index == 0 else 248.0
		var floor_y: float = 104.0 if index == 0 else 98.0
		var texture: Texture2D = textures[state.recipe]
		var factor: float = minf(48.0 / texture.get_width(), 68.0 / texture.get_height())
		var extent: Vector2 = texture.get_size() * factor
		var shown: float = 1.0 if reduced_motion else maxf(float(state.progress), 0.04)
		var region := Rect2(0, texture.get_height() * (1.0 - shown), texture.get_width(), texture.get_height() * shown)
		var rect := Rect2(center_x - extent.x * 0.5, floor_y - extent.y * shown, extent.x, extent.y * shown)
		draw_texture_rect_region(texture, rect, region, Color(1, 1, 1, 0.45 + 0.55 * float(state.progress)))
		if index == 1:
			draw_rect(Rect2(221, 49, 54, 49), Color(0.30, 0.48, 0.16, 0.18))
		if not reduced_motion and state.status == "WORKSHOP_BUILDING":
			var phase: float = float(state.progress) * TAU * 2.0
			if index == 0:
				var tip := Vector2(center_x + cos(phase) * 19, floor_y - 25 - sin(phase) * 10)
				draw_line(Vector2(53, 40), tip, Color("b4a779"), 2)
				draw_circle(tip, 2.5, Color("d0e4a3"))
			else:
				for bubble: int in range(4):
					var rise: float = fposmod(float(state.progress) * 2 + bubble * 0.25, 1.0)
					draw_circle(Vector2(228 + bubble * 12, 95 - rise * 42), 1.5, Color(0.7, 0.85, 0.4, 0.6))
	draw_texture_rect(HOUSING, Rect2(0, 0, 320, 140), false)
	for index: int in range(2):
		var state: Dictionary = lines[index]
		var tint := Color("cf976f") if index == 1 else Color("c7d992")
		draw_rect(Rect2(index * 165, 137, 155, 3), Color("18211a"))
		if state.active:
			draw_rect(Rect2(index * 165, 137, 155 * float(state.progress), 3), tint)
