extends SceneTree

const GAME := preload("res://scenes/world/gameplay.tscn")

func _initialize() -> void:
	call_deferred("validate")

func validate() -> void:
	var game: Node = GAME.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var visual: Node2D = game.get_node("MaterialProcessorVisual")
	visual.set_process(false)
	visual.sync_state()
	assert(not visual.active)
	game.spawn_corpse(Vector2(700, 500))
	var corpse: Button = game.corpses.back()
	assert(game.enqueue_corpse_for_processing(corpse))
	game.spawn_corpse(Vector2(950, 450))
	var waiting: Button = game.corpses.back()
	assert(game.enqueue_corpse_for_processing(waiting))
	visual.sync_state()
	assert(not corpse.visible and waiting.visible)
	assert(visual.transported_corpse == corpse)
	assert(visual.payload_center().is_equal_approx(visual.transport_origin))
	var queue_size: int = game.corpse_processing_queue.size()
	var before: int = game.bones
	for fraction: float in [0.1, 0.5, 0.9]:
		game.corpse_processor_timer = game.corpse_processor_seconds_per_corpse * (1.0 - fraction)
		visual.sync_state()
		assert(is_equal_approx(visual.progress, fraction))
		assert(visual.payload != null)
		assert(game.bones == before)
		assert(game.corpse_processing_queue.size() == queue_size)
		assert(not corpse.visible and waiting.visible)
	game.wave_preparation_in_progress = true
	visual.sync_state()
	assert(visual.status.text == game.tr("PRESS_PAUSED"))
	game.reduced_motion_enabled = true
	visual.sync_state()
	assert(visual.reduced_motion)
	assert(visual.payload_center().is_equal_approx(Vector2(145, 70)))
	game.wave_preparation_in_progress = false
	game.update_corpse_processor(10.0)
	visual.sync_state()
	assert(visual.active and visual.transported_corpse == waiting)
	assert(not waiting.visible)
	assert(game.bones > before)
	var frozen_center: Vector2 = visual.payload_center()
	paused = true
	await process_frame
	await process_frame
	assert(visual.payload_center() == frozen_center)
	paused = false
	game.remove_corpse_from_processing_queue(waiting)
	visual.sync_state()
	assert(not visual.active and waiting.visible)
	# Restoring/replacing a presenter must not strand its payload as invisible.
	assert(game.enqueue_corpse_for_processing(waiting))
	visual.sync_state()
	assert(not waiting.visible)
	visual.free()
	assert(waiting.visible)
	game.queue_free()
	await process_frame
	print("MATERIAL PROCESSOR VISUAL: PASS")
	quit()
