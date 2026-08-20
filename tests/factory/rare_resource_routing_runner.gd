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
	game.factory_points = 20


	assert(game.purchase_soul_extractor())
	assert(game.soul_extractor_unlocked)
	game.toggle_soul_extractor_control()
	assert(game.soul_routing_enabled)
	game.spawn_corpse(Vector2(700.0, 500.0), "mage")
	game.spawn_corpse(Vector2(800.0, 500.0), "human_warrior")
	var arcane_corpse: Button = game.corpses[0]
	var common_corpse: Button = game.corpses[1]
	assert(arcane_corpse.text == "CADÁVER ARCANO")
	assert(game.enqueue_corpse_for_selected_route(arcane_corpse))
	assert(game.enqueue_corpse_for_selected_route(common_corpse))
	assert(game.soul_extraction_queue.size() == 1)
	assert(game.corpse_processing_queue.size() == 1)
	assert(game.is_corpse_queued(arcane_corpse))


	game.update_soul_extractor(game.get_soul_extractor_cycle_seconds())
	assert(game.souls == 1)
	assert(game.total_souls_earned == 1)
	assert(game.total_corpses_processed == 1)
	assert(game.soul_extraction_queue.is_empty())


	assert(game.purchase_factory_efficiency_upgrade())
	assert(game.purchase_factory_efficiency_upgrade())
	assert(game.factory_efficiency_level == 2)
	assert(is_equal_approx(game.get_soul_extractor_cycle_seconds(), 2.0))
	assert(game.purchase_hematic_press())
	assert(game.has_synergy(game.SYNERGY_DARK_REFINERY))
	assert(game.get_hematic_press_flesh_cost() == 6)


	game.automatic_corpse_collection_unlocked = true
	assert(game.set_automatic_corpse_collection_enabled(true))
	game.spawn_corpse(Vector2(900.0, 500.0), "elf")
	game.spawn_corpse(Vector2(1000.0, 500.0), "human_warrior")
	game.update_automatic_corpse_collection(
		game.FACTORY_AUTO_COLLECTION_SCAN_INTERVAL
	)
	assert(game.soul_extraction_queue.size() == 1)
	assert(game.corpse_processing_queue.size() == 2)
	game.update_factory_panel_ui()
	assert(game.factory_soul_extractor_button.text.contains("ROTA ARCANA ATIVADA"))
	assert(game.factory_efficiency_button.text.contains("EFICIÊNCIA INDUSTRIAL"))
	print("RARE RESOURCE ROUTING VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
