extends Node

var game: Node
var panel: Panel
var toggle: Button
var machines: Array[Node2D] = []
var expanded := false

func bind(target: Node) -> void:
	game = target
	panel = Panel.new()
	panel.position = Vector2(20, 290)
	panel.size = Vector2(365, 465)
	panel.z_index = 145
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
	for name_value: String in ["UndeadWorkshopVisual", "MaterialProcessorVisual", "RareRefineryVisual"]:
		var machine: Node2D = game.get_node(name_value)
		machines.append(machine)
		machine.z_index = 150
	machines[0].position = Vector2(55, 320)
	machines[0].scale = Vector2.ONE * 0.85
	machines[1].position = Vector2(70, 485)
	machines[1].scale = Vector2.ONE * 0.75
	machines[2].position = Vector2(60, 615)
	machines[2].scale = Vector2.ONE * 0.85
	set_expanded(false)

func _process(_delta: float) -> void:
	if is_instance_valid(toggle):
		toggle.text = tr("FACTORY_LIVE_CLOSE" if expanded else "FACTORY_LIVE_OPEN")

func set_expanded(value: bool) -> void:
	expanded = value
	panel.visible = value
	for machine: Node2D in machines:
		machine.visible = value
		machine.sync_state()
	_process(0)
