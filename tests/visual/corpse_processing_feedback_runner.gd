extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const FEEDBACK_SETTLE_SECONDS: float = 1.3


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.set_processing_directive_locked(false)
	game.set_processing_directive(game.PROCESSING_FLESH_FOCUS)


	var feedback_events: Array[Dictionary] = []
	game.corpse_processing_feedback_started.connect(
		func(directive: String, bones_gained: int, flesh_gained: int) -> void:
			feedback_events.append(
				{
					"directive": directive,
					"bones": bones_gained,
					"flesh": flesh_gained
				}
			)
	)


	var corpse: Button = Button.new()
	corpse.position = Vector2(820.0, 520.0)
	corpse.size = Vector2(90.0, 45.0)
	game.add_child(corpse)
	game.corpses.append(corpse)
	game.process_corpse(corpse)


	assert(game.bones == 2)
	assert(game.flesh == 6)
	assert(feedback_events.size() == 1)
	assert(feedback_events[0]["directive"] == game.PROCESSING_FLESH_FOCUS)
	assert(feedback_events[0]["bones"] == 2)
	assert(feedback_events[0]["flesh"] == 6)
	assert(game.get_tree().get_nodes_in_group("processing_feedback").size() == 1)
	assert(game.resources_panel.modulate != Color.WHITE)
	assert(game.processing_panel.modulate == Color.WHITE)


	await create_timer(FEEDBACK_SETTLE_SECONDS).timeout


	assert(game.get_tree().get_nodes_in_group("processing_feedback").is_empty())
	assert(game.resources_panel.modulate.is_equal_approx(Color.WHITE))
	print("CORPSE PROCESSING FEEDBACK VALIDATION: PASS")
	game.queue_free()
	quit()
