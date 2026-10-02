extends SceneTree

func _initialize() -> void:
	call_deferred("validate")

func validate() -> void:
	var game: Node = preload("res://scenes/world/gameplay.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var visual: Node = game.get_node("UndeadWorkshopVisual")
	visual.set_process(false)
	game.bones = 100
	game.flesh = 100
	assert(game.enqueue_skeleton_production(1))
	assert(game.enqueue_zombie_production(1))
	var before: Array = [game.bones, game.flesh, game.skeleton_assembler_timer, game.flesh_vat_timer, game.get_total_queued_undead()]
	for index: int in range(10):
		visual.sync_state()
	assert(before == [game.bones, game.flesh, game.skeleton_assembler_timer, game.flesh_vat_timer, game.get_total_queued_undead()])
	assert(visual.lines[0].active and visual.lines[1].active)
	game.wave_preparation_in_progress = true
	visual.sync_state()
	assert(visual.lines[0].status == "WORKSHOP_PAUSED")
	game.wave_preparation_in_progress = false
	game.reduced_motion_enabled = true
	visual.sync_state()
	assert(visual.reduced_motion)
	assert(visual.completion_count == 0)
	game.update_undead_production_queues(0.45)
	assert(visual.completion_count == 1)
	game.update_undead_production_queues(0.36)
	assert(visual.completion_count == 2)
	visual.sync_state()
	assert(not visual.lines[0].active and not visual.lines[1].active)
	var orders: Array[Dictionary] = [{"unit_type": "skeleton_archer", "remaining": 1}]
	assert(visual._line_state(orders, 0.2, 0.45, "skeleton").recipe == "skeleton_archer")
	assert(game.bones == 95 and game.flesh == 94)
	game.queue_free()
	await process_frame
	print("UNDEAD WORKSHOP VISUAL: PASS")
	quit()
