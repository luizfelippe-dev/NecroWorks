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


	assert(not game.hematic_press_unlocked)
	assert(not game.enqueue_hematic_press())
	assert(game.award_factory_points_for_wave(1) == 1)
	assert(game.award_factory_points_for_wave(5) == 2)
	assert(game.purchase_hematic_press())
	assert(game.hematic_press_unlocked)
	assert(game.factory_points == 0)
	assert(not game.purchase_hematic_press())


	var queued_events: Array[int] = []
	var completed_events: Array[int] = []
	game.hematic_press_order_queued.connect(
		func(queued_units: int) -> void:
			queued_events.append(queued_units)
	)
	game.hematic_press_completed.connect(
		func(remaining_units: int) -> void:
			completed_events.append(remaining_units)
	)
	game.flesh = game.HEMATIC_PRESS_FLESH_COST * 2
	assert(game.enqueue_hematic_press())
	assert(game.enqueue_hematic_press())
	assert(not game.enqueue_hematic_press())
	assert(game.flesh == 0)
	assert(game.hematic_press_queue == 2)
	assert(queued_events == [1, 2])


	game.update_hematic_press(game.HEMATIC_PRESS_CYCLE_SECONDS - 0.1)
	assert(game.blood == 0)
	assert(game.hematic_press_queue == 2)
	game.update_hematic_press(0.11)
	assert(game.blood == 1)
	assert(game.total_blood_earned == 1)
	assert(game.hematic_press_queue == 1)
	game.update_hematic_press(game.HEMATIC_PRESS_CYCLE_SECONDS)
	assert(game.blood == 2)
	assert(game.total_blood_earned == 2)
	assert(game.hematic_press_queue == 0)
	assert(is_zero_approx(game.hematic_press_timer))
	assert(completed_events == [1, 0])


	game.update_factory_panel_ui()
	assert(game.factory_hematic_press_button.text.contains("PRENSA HEMÁTICA"))
	assert(game.factory_hematic_press_button.text.contains("PRODUZIR 1 SANGUE"))
	print("HEMATIC PRESS VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
