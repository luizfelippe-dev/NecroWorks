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
	assert(visual.source_valid)
	var source: Vector2 = visual.essence_source
	assert(visual.essence_position().distance_to(source) > 0)
	assert(game.corpses[0].visible)
	assert(visual.completion_count == 0)
	game.spawn_corpse(Vector2(1100, 600), "elf")
	assert(game.enqueue_corpse_for_soul_extraction(game.corpses[1]))
	visual.sync_state()
	assert(visual.essence_source == source)
	game.wave_preparation_in_progress = true
	visual.sync_state()
	assert(visual.states[0].status == "WORKSHOP_PAUSED")
	assert(visual.states[1].status == "WORKSHOP_PAUSED")
	var paused_position: Vector2 = visual.essence_position()
	var paused_timer: float = game.soul_extractor_timer
	game._process(0.4)
	visual.sync_state()
	assert(game.soul_extractor_timer == paused_timer)
	assert(visual.essence_position() == paused_position)
	# Rebinding reconstructs presentation without replaying completion.
	var restored: Node = preload("res://scripts/visual/rare_refinery_visual.gd").new()
	game.add_child(restored)
	restored.bind(game)
	restored.position = visual.position
	restored.scale = visual.scale
	restored.sync_state()
	assert(restored.essence_position() == paused_position)
	assert(restored.completion_count == 0)
	restored.free()
	game.reduced_motion_enabled = true
	visual.sync_state()
	assert(visual.reduced_motion)
	assert(visual.essence_position() == visual.SOUL_CENTER)
	for locale: String in ["pt_BR", "en", "es"]:
		TranslationServer.set_locale(locale)
		visual.sync_state()
		assert(not visual.labels[0].text.contains("REFINERY_"))
	game.wave_preparation_in_progress = false
	game.update_hematic_press(10)
	game.update_soul_extractor(10)
	visual.sync_state()
	assert(game.blood == 1 and game.souls == 1)
	assert(visual.completion_count == 2)
	assert(not visual.states[0].active and visual.states[1].active)
	assert(visual.essence_source != source)
	assert(get_nodes_in_group("processing_feedback").size() == 2)
	for effect: Node in get_nodes_in_group("processing_feedback"):
		assert(effect.arrived)
		assert(effect.global_position == game.RESOURCE_FEEDBACK_TARGET)
		assert(not effect.popup_label.text.contains("REFINERY_"))
	# Invalidated reservation cannot leave a stale beam or credit a second soul.
	game.corpses[0].queue_free()
	await process_frame
	visual.sync_state()
	assert(not visual.source_valid)
	game.update_soul_extractor(10)
	visual.sync_state()
	assert(game.souls == 1 and visual.completion_count == 2)
	assert(not visual.states[1].active)
	game.run_finished = true
	visual.sync_state()
	assert(not visual.states[0].active)
	game.queue_free()
	await process_frame
	print("RARE REFINERY VISUAL: PASS")
	quit()
