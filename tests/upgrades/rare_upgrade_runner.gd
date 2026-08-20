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


	game.current_wave = 7
	assert(
		not game.get_upgrade_pool().has(
			game.UPGRADE_EMERGENCY_RECLAMATION
		)
	)
	game.current_wave = 8
	assert(
		game.get_upgrade_pool().has(
			game.UPGRADE_EMERGENCY_RECLAMATION
		)
	)
	game.apply_upgrade(game.UPGRADE_EMERGENCY_RECLAMATION)
	game.upgrade_counts[game.UPGRADE_EMERGENCY_RECLAMATION] = 1
	assert(game.is_rare_upgrade(game.UPGRADE_EMERGENCY_RECLAMATION))
	assert(
		not game.get_upgrade_pool().has(
			game.UPGRADE_EMERGENCY_RECLAMATION
		)
	)


	var reclamation_events: Array[Dictionary] = []
	game.emergency_reclamation_triggered.connect(
		func(unit_type: String, resource_id: String, amount: int) -> void:
			reclamation_events.append(
				{
					"unit_type": unit_type,
					"resource": resource_id,
					"amount": amount,
				}
			)
	)


	var temporary_skeleton: UndeadRuntimeUnit = game.skeletons[0]
	temporary_skeleton.configure_temporary(2.0, "TEST")
	var bones_before_temporary_loss: int = game.bones
	game.kill_skeleton(temporary_skeleton)
	assert(game.emergency_reclamation_available)
	assert(game.bones == bones_before_temporary_loss)
	assert(reclamation_events.is_empty())


	assert(game.create_free_zombie("TEST"))
	var zombie: Node2D = game.zombies[0]
	var flesh_before_refund: int = game.flesh
	game.kill_zombie(zombie)
	assert(not game.emergency_reclamation_available)
	assert(game.flesh == flesh_before_refund + 3)
	assert(reclamation_events.size() == 1)
	assert(reclamation_events[0]["resource"] == "flesh")
	assert(reclamation_events[0]["amount"] == 3)


	assert(game.create_free_skeleton("TEST"))
	var permanent_skeleton: Node2D = game.skeletons[0]
	var bones_before_second_loss: int = game.bones
	game.kill_skeleton(permanent_skeleton)
	assert(game.bones == bones_before_second_loss)
	assert(reclamation_events.size() == 1)


	game.start_wave(9)
	assert(game.emergency_reclamation_available)
	assert(game.create_free_skeleton("TEST"))
	var next_wave_skeleton: Node2D = game.skeletons[0]
	var bones_before_next_wave_loss: int = game.bones
	game.kill_skeleton(next_wave_skeleton)
	assert(game.bones == bones_before_next_wave_loss + 2)
	assert(reclamation_events.size() == 2)


	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		for key: String in [
			"UPGRADE_EMERGENCY_RECLAMATION_NAME",
			"UPGRADE_EMERGENCY_RECLAMATION_DESC",
			"UPGRADE_EMERGENCY_RECLAMATION_STATUS",
			"UPGRADE_EMERGENCY_RECLAMATION_FEEDBACK"
		]:
			assert(TranslationServer.translate(key) != key)


	print("RARE UPGRADE VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
