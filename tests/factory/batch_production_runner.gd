extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.bones = 100
	game.flesh = 100
	game.update_bones_ui()


	var production_events: Array[Dictionary] = []
	game.batch_production_completed.connect(
		func(unit_type: String, quantity: int, total_cost: int) -> void:
			production_events.append(
				{
					"unit_type": unit_type,
					"quantity": quantity,
					"total_cost": total_cost
				}
			)
	)


	assert(game.create_skeleton_batch(5) == 5)
	assert(game.skeletons.size() == 6)
	assert(game.bones == 75)
	assert(game.total_skeletons_created == 5)
	assert(production_events.size() == 1)
	assert(production_events[0]["unit_type"] == "skeleton")
	assert(production_events[0]["quantity"] == 5)
	assert(production_events[0]["total_cost"] == 25)


	var bones_before_rejected_batch: int = game.bones
	assert(game.create_skeleton_batch(31) == 0)
	assert(game.create_skeleton_batch(0) == 0)
	assert(game.create_skeleton_batch(game.MAX_UNDEAD + 1) == 0)
	assert(game.bones == bones_before_rejected_batch)
	assert(game.skeletons.size() == 6)


	assert(game.create_zombie_batch(5) == 5)
	assert(game.zombies.size() == 5)
	assert(game.flesh == 70)
	assert(game.total_zombies_created == 5)
	assert(production_events.size() == 2)
	assert(production_events[1]["unit_type"] == "zombie")
	assert(production_events[1]["quantity"] == 5)
	assert(production_events[1]["total_cost"] == 30)


	game.flesh = 29
	var zombies_before_rejected_batch: int = game.zombies.size()
	assert(game.create_zombie_batch(5) == 0)
	assert(game.flesh == 29)
	assert(game.zombies.size() == zombies_before_rejected_batch)
	assert(production_events.size() == 2)


	game.production_quantity_selector.value = 4.0
	game.bones = 20
	game.flesh = 24
	game.update_bones_ui()
	assert(game.create_skeleton_button.text.contains("x4"))
	assert(game.create_skeleton_button.text.contains("20"))
	assert(not game.create_skeleton_button.disabled)
	assert(game.create_zombie_button.text.contains("24"))
	assert(not game.create_zombie_button.disabled)
	print("BATCH PRODUCTION VALIDATION: PASS")
	game.queue_free()
	quit()
