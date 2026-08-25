extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	TranslationServer.set_locale("pt_BR")
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)


	assert(
		game.ARMY_DOCTRINE_POLICY.get_replenishment_plan(
			Vector2i(5, 5),
			5,
			5,
			3,
			game.ARMY_DOCTRINE_POLICY.PRIORITY_BALANCED
		) == Vector2i(2, 1)
	)
	assert(
		game.ARMY_DOCTRINE_POLICY.get_replenishment_plan(
			Vector2i(5, 5),
			5,
			5,
			3,
			game.ARMY_DOCTRINE_POLICY.PRIORITY_ZOMBIES
		) == Vector2i(0, 3)
	)


	var automation_events: Array[bool] = []
	game.army_doctrine_automation_changed.connect(
		func(enabled: bool) -> void:
			automation_events.append(enabled)
	)
	assert(not game.set_army_doctrine_automation_enabled(true))
	assert(
		game.apply_army_doctrine_configuration(
			3,
			2,
			20,
			12,
			game.ARMY_DOCTRINE_POLICY.PRIORITY_BALANCED
		)
	)
	game.bones = 30
	game.flesh = 24
	assert(game.set_army_doctrine_automation_enabled(true))
	assert(automation_events == [true])
	assert(game.doctrine_automation_button.text == "PAUSAR REPOSIÇÃO")


	assert(game.execute_army_doctrine_replenishment() == Vector2i(2, 2))
	assert(game.get_army_doctrine_pending_deficits() == Vector2i.ZERO)
	assert(game.bones == game.doctrine_bones_reserve)
	assert(game.flesh == game.doctrine_flesh_reserve)
	assert(game.execute_army_doctrine_replenishment() == Vector2i.ZERO)
	assert(game.skeleton_production_queue.size() == 1)
	assert(game.zombie_production_queue.size() == 1)


	game.update_undead_production_queues(0.45)
	game.update_undead_production_queues(0.45)
	game.update_undead_production_queues(0.80)
	assert(game.skeletons.size() == 3)
	assert(game.zombies.size() == 2)
	assert(game.skeleton_production_queue.is_empty())
	assert(game.zombie_production_queue.is_empty())


	assert(game.set_army_doctrine_automation_enabled(false))
	assert(automation_events == [true, false])
	game.kill_skeleton(game.skeletons.back())
	game.bones = game.doctrine_bones_reserve + game.skeleton_cost
	assert(game.execute_army_doctrine_replenishment() == Vector2i.ZERO)
	assert(game.skeleton_production_queue.is_empty())
	assert(game.set_army_doctrine_automation_enabled(true))
	assert(game.execute_army_doctrine_replenishment() == Vector2i(1, 0))
	assert(game.bones == game.doctrine_bones_reserve)


	print("ARMY DOCTRINE AUTOMATION VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
