extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const DESIGN_SIZE: Vector2 = Vector2(1920.0, 1080.0)
const EMBEDDED_SAFE_BOTTOM_Y: float = 1015.0


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	assert(
		str(ProjectSettings.get_setting("display/window/stretch/aspect"))
		== "keep"
	)
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var controls: Array[Control] = [
		game.get_node("ResourcesPanel") as Control,
		game.get_node("ProductionPanel") as Control,
		game.get_node("ProcessingPanel") as Control,
		game.create_skeleton_button,
		game.create_skeleton_archer_button,
		game.create_zombie_button,
		game.production_quantity_selector,
		game.production_queue_label,
		game.factory_title_label,
		game.processing_label,
		game.bones_label,
		game.factory_nav_button,
		game.doctrine_nav_button,
		game.ritual_nav_button
	]
	for directive_button: Variant in game.processing_directive_buttons.values():
		controls.append(directive_button as Control)


	for control: Control in controls:
		var control_bottom: float = control.position.y + control.size.y
		assert(control.position.x >= 0.0)
		assert(control.position.y >= 0.0)
		assert(control.position.x + control.size.x <= DESIGN_SIZE.x)
		assert(
			control_bottom <= EMBEDDED_SAFE_BOTTOM_Y,
			(
				control.name
				+ " ends at y="
				+ str(control_bottom)
				+ ", below the embedded safe limit y="
				+ str(EMBEDDED_SAFE_BOTTOM_Y)
			)
		)


	print("RESPONSIVE LAYOUT BOUNDS VALIDATION: PASS")
	game.queue_free()
	quit()
