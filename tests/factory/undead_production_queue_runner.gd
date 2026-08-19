extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	TranslationServer.set_locale("pt_BR")
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.bones = 100
	game.flesh = 100
	game.update_bones_ui()


	var queued_events: Array[Dictionary] = []
	var completed_units: Array[Dictionary] = []
	var completed_orders: Array[Dictionary] = []
	game.production_order_queued.connect(
		func(unit_type: String, quantity: int, total_cost: int) -> void:
			queued_events.append({
				"unit_type": unit_type,
				"quantity": quantity,
				"total_cost": total_cost
			})
	)
	game.production_unit_completed.connect(
		func(unit_type: String, remaining: int) -> void:
			completed_units.append({
				"unit_type": unit_type,
				"remaining": remaining
			})
	)
	game.batch_production_completed.connect(
		func(unit_type: String, quantity: int, total_cost: int) -> void:
			completed_orders.append({
				"unit_type": unit_type,
				"quantity": quantity,
				"total_cost": total_cost
			})
	)


	assert(game.enqueue_skeleton_production(3))
	assert(game.enqueue_zombie_production(2))
	assert(game.bones == 85)
	assert(game.flesh == 88)
	assert(game.get_total_queued_undead() == 5)
	assert(game.skeletons.size() == 1)
	assert(game.zombies.is_empty())
	assert(queued_events.size() == 2)


	game.update_undead_production_queues(0.45)
	assert(game.skeletons.size() == 2)
	assert(game.zombies.is_empty())
	game.update_undead_production_queues(0.36)
	assert(game.zombies.size() == 1)
	game.update_undead_production_queues(0.10)
	game.update_undead_production_queues(0.45)
	assert(game.skeletons.size() == 4)
	game.update_undead_production_queues(0.26)
	assert(game.zombies.size() == 2)
	assert(game.get_total_queued_undead() == 0)
	assert(game.bones == 85)
	assert(game.flesh == 88)
	assert(completed_units.size() == 5)
	assert(completed_orders.size() == 2)


	assert(game.enqueue_skeleton_production(1))
	assert(game.enqueue_skeleton_production(1))
	assert(game.enqueue_skeleton_production(1))
	var bones_after_three_orders: int = game.bones
	assert(not game.enqueue_skeleton_production(1))
	assert(game.bones == bones_after_three_orders)
	assert(game.skeleton_production_queue.size() == 3)


	game.update_bones_ui()
	assert(game.create_skeleton_button.text.contains("PRODUZIR ESQUELETO (FILA)"))
	assert(game.production_queue_label.text.contains("Montador: 3"))


	for _frame: int in range(30):
		await process_frame


	print("UNDEAD PRODUCTION QUEUE VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
