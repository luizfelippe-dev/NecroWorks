extends SceneTree


const GAME_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	var previous_end: float = 0.0
	for button: Button in game.upgrade_buttons:
		assert(button.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)
		assert(button.clip_text)
		assert(button.position.x >= previous_end)
		assert(button.position.x + button.size.x <= game.upgrade_panel.size.x)
		previous_end = button.position.x + button.size.x
	assert(game.upgrade_panel.position.x + game.upgrade_panel.size.x <= 1920.0)
	print("UPGRADE LAYOUT VALIDATION: PASS")
	quit()
