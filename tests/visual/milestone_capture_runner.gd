extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("capture_milestone")


func capture_milestone() -> void:
	TranslationServer.set_locale("pt_BR")
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.bones = 30
	game.flesh = 24
	game.souls = 12
	game.blood = 12
	game.create_skeleton_batch(3)
	game.create_zombie_batch(2)
	game.purchase_soul_focus_upgrade()
	game.purchase_soul_anchor_upgrade()
	game.create_ghost()
	game.create_ghost()
	game.toggle_ritual_panel()


	for _frame: int in range(120):
		await process_frame


	game.toggle_ritual_panel()
	game.set_process(true)


	for _frame: int in range(180):
		await process_frame


	print("V0.2 MILESTONE CAPTURE: PASS")
	game.queue_free()
	quit()
