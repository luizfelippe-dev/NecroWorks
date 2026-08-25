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


	assert(not game.automatic_corpse_collection_unlocked)
	assert(not game.set_automatic_corpse_collection_enabled(true))
	assert(game.award_factory_points_for_wave(1) == 1)
	assert(game.award_factory_points_for_wave(5) == 2)
	assert(game.factory_points == 3)
	assert(game.purchase_automatic_corpse_collection())
	assert(game.factory_points == 1)
	assert(game.set_automatic_corpse_collection_enabled(true))


	for index: int in range(6):
		var corpse: Button = Button.new()
		corpse.position = Vector2(680.0 + float(index) * 30.0, 520.0)
		corpse.size = Vector2(90.0, 45.0)
		game.add_child(corpse)
		game.corpses.append(corpse)


	game.update_automatic_corpse_collection(
		game.FACTORY_AUTO_COLLECTION_SCAN_INTERVAL
	)
	assert(game.corpse_processing_queue.size() == 5)
	assert(game.corpses.size() == 6)


	game.update_corpse_processor(game.CORPSE_PROCESSOR_BASE_SECONDS + 0.01)
	assert(game.corpse_processing_queue.size() == 4)
	assert(game.corpses.size() == 5)
	game.update_automatic_corpse_collection(
		game.FACTORY_AUTO_COLLECTION_SCAN_INTERVAL
	)
	assert(game.corpse_processing_queue.size() == 5)


	assert(game.purchase_factory_queue_upgrade())
	assert(game.corpse_processor_capacity == 7)
	assert(game.factory_points == 0)
	game.award_factory_points_for_wave(2)
	assert(game.purchase_factory_speed_upgrade())
	assert(is_equal_approx(game.corpse_processor_seconds_per_corpse, 0.55))
	assert(game.factory_points == 0)
	game.toggle_factory_panel()
	assert(game.factory_panel.visible)
	assert(game.factory_nav_button.text == "FÁBRICA")
	assert(game.factory_points_label.text.contains("PONTOS DE FÁBRICA"))


	for _frame: int in range(30):
		await process_frame


	print("FACTORY AUTOMATION VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
