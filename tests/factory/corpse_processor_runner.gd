extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.set_processing_directive_locked(false)
	game.set_processing_directive(game.PROCESSING_BONE_FOCUS)


	var test_corpses: Array[Button] = []


	for index: int in range(game.CORPSE_PROCESSOR_BASE_CAPACITY + 1):
		var corpse: Button = Button.new()
		corpse.position = Vector2(700.0 + float(index) * 20.0, 520.0)
		corpse.size = Vector2(90.0, 45.0)
		game.add_child(corpse)
		game.corpses.append(corpse)
		test_corpses.append(corpse)


	for index: int in range(game.CORPSE_PROCESSOR_BASE_CAPACITY):
		assert(game.enqueue_corpse_for_processing(test_corpses[index]))


	assert(not game.enqueue_corpse_for_processing(test_corpses.back()))
	assert(game.corpse_processing_queue.size() == 5)
	assert(game.bones == 0)
	assert(game.flesh == 0)


	game.set_processing_directive(game.PROCESSING_FLESH_FOCUS)
	game.update_corpse_processor(game.CORPSE_PROCESSOR_BASE_SECONDS + 0.01)


	assert(game.corpse_processing_queue.size() == 4)
	assert(game.bones == 12)
	assert(game.flesh == 0)
	assert(game.corpses_processed_by_directive[game.PROCESSING_BONE_FOCUS] == 1)
	assert(game.corpses_processed_by_directive[game.PROCESSING_FLESH_FOCUS] == 0)
	assert(game.enqueue_corpse_for_processing(test_corpses.back()))
	assert(game.corpse_processing_queue.size() == 5)
	print("CORPSE PROCESSOR QUEUE VALIDATION: PASS")
	game.queue_free()
	quit()
