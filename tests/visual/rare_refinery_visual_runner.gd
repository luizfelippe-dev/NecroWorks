extends SceneTree

func _initialize() -> void:
	call_deferred("validate")

func validate() -> void:
	var game: Node = preload("res://scenes/world/gameplay.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var visual: Node = game.get_node("RareRefineryVisual")
	visual.set_process(false)
	visual.sync_state()
	assert(not visual.labels[0].visible and not visual.labels[1].visible)
	game.factory_points = 20
	game.flesh = 100
	assert(game.purchase_hematic_press())
	assert(game.purchase_soul_extractor())
	assert(game.enqueue_hematic_press())
	game.spawn_corpse(Vector2(900, 500), "mage")
	assert(game.enqueue_corpse_for_soul_extraction(game.corpses[0]))
	game.update_hematic_press(0.5)
	game.update_soul_extractor(0.5)
	var before: Array = [game.flesh, game.blood, game.souls, game.hematic_press_timer, game.soul_extractor_timer, game.corpses.size()]
	for index: int in range(10):
		visual.sync_state()
	assert(before == [game.flesh, game.blood, game.souls, game.hematic_press_timer, game.soul_extractor_timer, game.corpses.size()])
	assert(is_equal_approx(visual.states[0].progress, 0.25))
	assert(visual.states[1].active)
	game.wave_preparation_in_progress = true
	visual.sync_state()
	assert(visual.states[0].status == "WORKSHOP_PAUSED")
	assert(visual.states[1].status == "WORKSHOP_PAUSED")
	game.reduced_motion_enabled = true
	visual.sync_state()
	assert(visual.reduced_motion)
	for locale: String in ["pt_BR", "en", "es"]:
		TranslationServer.set_locale(locale)
		visual.sync_state()
		assert(not visual.labels[0].text.contains("REFINERY_"))
	game.wave_preparation_in_progress = false
	game.update_hematic_press(10)
	game.update_soul_extractor(10)
	visual.sync_state()
	assert(game.blood == 1 and game.souls == 1)
	assert(not visual.states[0].active and not visual.states[1].active)
	game.run_finished = true
	visual.sync_state()
	assert(not visual.states[0].active)
	game.queue_free()
	await process_frame
	print("RARE REFINERY VISUAL: PASS")
	quit()
