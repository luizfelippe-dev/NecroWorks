extends Node2D

var game: Node
var panel: Panel
var toggle: Button
var machines: Array[Node2D] = []
var expanded := true
var belt_phase := 0.0

func bind(target: Node) -> void:
	game = target
	panel = Panel.new()
	z_index = 145
	panel.position = Vector2(20, 640)
	panel.size = Vector2(1480, 130)
	panel.z_index = 144
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color("101713")
	style.border_color = Color("827754")
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 8
	panel.add_theme_stylebox_override("panel", style)
	game.add_child(panel)
	toggle = Button.new()
	toggle.position = Vector2(20, 242)
	toggle.size = Vector2(365, 42)
	toggle.z_index = 160
	game.apply_button_style(toggle, game.UI_GREEN)
	toggle.pressed.connect(func(): set_expanded(not expanded))
	game.add_child(toggle)
	toggle.hide()
	for name_value: String in ["UndeadWorkshopVisual", "MaterialProcessorVisual", "RareRefineryVisual"]:
		var machine: Node2D = game.get_node(name_value)
		machines.append(machine)
		machine.z_index = 150
	machines[0].position = Vector2(700, 640)
	machines[0].scale = Vector2.ONE * 0.72
	machines[1].position = Vector2(150, 644)
	machines[1].scale = Vector2.ONE * 0.8
	machines[2].position = Vector2(1150, 656)
	machines[2].scale = Vector2.ONE * 0.72
	set_expanded(true)

func _process(delta: float) -> void:
	if is_instance_valid(toggle):
		toggle.text = tr("FACTORY_LIVE_CLOSE" if expanded else "FACTORY_LIVE_OPEN")
	if not is_instance_valid(game):
		return
	var running: bool = not game.run_finished and not game.wave_preparation_in_progress and not game.wave_transition_in_progress and not game.event_decision_in_progress
	var working: bool = not game.corpse_processing_queue.is_empty() or not game.skeleton_production_queue.is_empty() or not game.zombie_production_queue.is_empty()
	if expanded and running and working and not game.reduced_motion_enabled:
		belt_phase = fposmod(belt_phase + delta * 28.0, 24.0)
		queue_redraw()

func set_expanded(value: bool) -> void:
	expanded = value
	panel.visible = value
	for machine: Node2D in machines:
		machine.visible = value
		machine.sync_state()
	_process(0)
	queue_redraw()

func _draw() -> void:
	if not expanded:
		return
	# Shared footing, rails and pipework connect the existing machine housings.
	draw_rect(Rect2(26, 740, 1468, 20), Color("080d0b"))
	draw_line(Vector2(26, 740), Vector2(1494, 740), Color("817454"), 3)
	draw_line(Vector2(26, 760), Vector2(1494, 760), Color("817454"), 3)
	for index: int in range(61):
		var x := 30.0 + index * 24 + belt_phase
		draw_circle(Vector2(x, 750), 6, Color("494333"))
		draw_circle(Vector2(x, 750), 2, Color("111811"))
	for x: float in [40.0, 470.0, 1000.0, 1480.0]:
		draw_line(Vector2(x, 659), Vector2(x, 735), Color("393c30"), 8)
		draw_circle(Vector2(x, 665), 5, Color("9a8756"))
	draw_line(Vector2(45, 680), Vector2(1480, 680), Color("3d4638"), 5)
