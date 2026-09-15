extends SceneTree

const GAME: PackedScene = preload("res://scenes/world/gameplay.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = GAME.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var requested_checkpoints: Array[Dictionary] = []
	game.run_checkpoint_requested.connect(
		func(state: Dictionary) -> void: requested_checkpoints.append(state)
	)
	for hostile: Node2D in game.enemies:
		if is_instance_valid(hostile):
			hostile.queue_free()
	game.enemies.clear()
	game.run_director.complete_wave()
	game.skeleton_assembler_timer = 1.75
	game._process(1.0)
	assert(is_equal_approx(game.skeleton_assembler_timer, 1.75))
	assert(is_equal_approx(game.run_elapsed_seconds, 0.0))
	game.current_upgrade_choices.clear()
	game.current_upgrade_choices.append(game.UPGRADE_SHARPENED_BONES)
	game.select_upgrade_by_index(0)
	assert(game.current_wave == 2)
	assert(game.wave_preparation_in_progress)
	assert(game.wave_preparation_panel.visible)
	assert(requested_checkpoints.size() == 1)
	assert(not game.wave_in_progress)
	var checkpoint: Dictionary = game.build_checkpoint_state()
	assert(checkpoint.preparation_pending)
	var resumed_game: Node = GAME.instantiate()
	root.add_child(resumed_game)
	await process_frame
	resumed_game.set_process(false)
	assert(resumed_game.restore_checkpoint_state(checkpoint))
	assert(resumed_game.wave_preparation_in_progress)
	assert(resumed_game.wave_preparation_panel.visible)
	assert(not resumed_game.wave_in_progress)
	assert(resumed_game.current_wave == 2)
	resumed_game.queue_free()
	await process_frame

	var elapsed_before: float = game.run_elapsed_seconds
	game.skeleton_assembler_timer = 1.5
	game.corpse_processor_timer = 1.25
	game._process(1.0)
	assert(game.run_elapsed_seconds == elapsed_before)
	assert(is_equal_approx(game.skeleton_assembler_timer, 1.5))
	assert(is_equal_approx(game.corpse_processor_timer, 1.25))

	for locale in ["pt_BR", "en", "es"]:
		TranslationServer.set_locale(locale)
		game.refresh_localized_ui()
		assert(not game.wave_preparation_title.text.is_empty())
		assert(game.wave_preparation_threat.text.contains("6"))
		assert(not game.start_prepared_wave_button.text.is_empty())
	TranslationServer.set_locale("pt_BR")
	game.refresh_localized_ui()
	game.current_wave = 11
	game.refresh_wave_preparation_ui()
	assert(game.wave_preparation_threat.text.contains("GUERREIRO HUMANO"))
	assert(game.wave_preparation_threat.text.contains("MAGO"))
	assert(game.wave_preparation_threat.text.contains("ELFO"))
	game.current_wave = 2
	game.refresh_wave_preparation_ui()
	if "--capture" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(
			"res://artifacts/presentation"
		))
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(
			"res://artifacts/presentation/wave_preparation_1280x720.png"
		) == OK)

	game.bones = game.skeleton_cost
	assert(game.enqueue_skeleton_production(1))
	assert(game.skeleton_production_queue.size() == 1)
	var queued_timer: float = game.skeleton_assembler_timer
	game._process(1.0)
	assert(is_equal_approx(game.skeleton_assembler_timer, queued_timer))

	game.start_prepared_wave()
	assert(requested_checkpoints.size() == 2)
	assert(requested_checkpoints[-1].preparation_pending)
	assert(requested_checkpoints[-1].production.skeleton_queue.size() == 1)
	assert(not game.wave_preparation_in_progress)
	assert(not game.wave_preparation_panel.visible)
	assert(game.wave_in_progress)
	assert(game.current_wave == 2)
	assert(game.enemies.size() == 1)
	var timer_at_combat_start: float = game.skeleton_assembler_timer
	game._process(0.1)
	assert(game.skeleton_assembler_timer < timer_at_combat_start)
	assert(game.run_elapsed_seconds > elapsed_before)
	game.start_prepared_wave()
	assert(game.enemies.size() == 1, "A second click must not restart the wave")
	game.set_process(false)
	game.queue_free()
	await process_frame
	print("WAVE PREPARATION VALIDATION: PASS")
	quit()
