extends SceneTree


const APP_SCENE: PackedScene = preload("res://scenes/core/app.tscn")
const PROFILE_PATH: String = "user://necroworks_shell_test_profile.json"
const SETTINGS_PATH: String = "user://necroworks_shell_test_settings.cfg"
const RUN_PATH: String = "user://necroworks_shell_test_run.json"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	TranslationServer.set_locale("en")
	RunSaveStore.delete_checkpoint(RUN_PATH)
	var shell: Node = APP_SCENE.instantiate()
	shell.profile_path = PROFILE_PATH
	shell.settings_path = SETTINGS_PATH
	shell.run_save_path = RUN_PATH
	root.add_child(shell)
	await process_frame
	LocalizationService.set_locale("en")
	await process_frame
	assert(shell.main_menu.visible)
	assert(shell.continue_button.disabled)
	assert(not shell.pause_menu.visible)
	assert(shell.title_label.text == "NECROWORKS")
	assert(shell.version_label.text == AppVersion.DISPLAY)
	assert(shell.codex_content.text.contains("LOCKED RECORD"))
	shell.profile.discoveries["grave_manifest"] = true
	shell.show_codex()
	assert(shell.codex_menu.visible)
	assert(shell.codex_content.text.contains("THE UNREGISTERED MANIFEST"))
	shell.show_main_menu()
	shell.profile.run_history = []
	shell.refresh_run_history_content()
	assert(shell.history_content.text.contains("NO COMPLETED RUNS"))
	shell.profile.run_history = [{
		"victory": true,
		"wave": 20,
		"enemies_killed": 120,
		"corpses_processed": 80,
		"army_remaining": 12,
	}]
	shell.show_run_history()
	assert(shell.history_menu.visible)
	assert(shell.history_content.text.contains("VICTORY"))
	assert(shell.history_content.text.contains("Wave 20"))
	shell.show_main_menu()
	shell.show_loadout()
	assert(shell.loadout_menu.visible)
	assert(shell.operator_name_label.text.contains("OPERATOR"))
	assert(shell.challenges_label.text.contains("OPERATIONAL CHALLENGES"))
	shell.show_main_menu()
	shell.start_new_run()
	assert(shell.prologue_menu.visible)
	assert(not shell.main_menu.visible)
	shell.show_main_menu()

	LocalizationService.set_locale("pt-BR")
	await process_frame
	assert(shell.pause_title.text == "PRODUÇÃO PAUSADA")
	assert(shell.options_apply_button.text == "APLICAR")
	assert(shell.prologue_title.text == "A ÚLTIMA LINHA DE PRODUÇÃO")
	assert(shell.prologue_body.text.contains("Cada cadáver é matéria-prima"))
	assert(shell.reduced_motion_check.text == "REDUZIR MOVIMENTO")

	shell.start_game({})
	await process_frame
	assert(shell.current_game != null)
	assert(not shell.current_game.restart_requested.get_connections().is_empty())
	assert(not shell.current_game.return_to_menu_requested.get_connections().is_empty())
	assert(not shell.main_menu.visible)
	shell.pause_game()
	assert(paused)
	assert(shell.pause_menu.visible)
	assert(shell.can_process())
	assert(not shell.current_game.can_process())
	var game: Node = shell.current_game
	game.bones = 100
	assert(game.enqueue_skeleton_production(3))
	var production_timer_before: float = game.skeleton_assembler_timer
	var queued_before: int = game.get_total_queued_undead()
	var elapsed_before: float = game.run_elapsed_seconds
	var position_before: Vector2 = game.skeletons[0].position
	var enemy_before: Vector2 = game.enemies[0].position
	game.enemy_spawn_delay = 0.05
	game.schedule_enemy_refill()
	for frame: int in range(120):
		await process_frame
	assert(game.run_elapsed_seconds == elapsed_before)
	assert(game.skeletons[0].position == position_before)
	assert(game.enemies[0].position == enemy_before)
	assert(game.skeleton_assembler_timer == production_timer_before)
	assert(game.get_total_queued_undead() == queued_before)
	assert(game.run_director.enemy_refill_scheduled)
	shell.open_options_from_pause()
	assert(shell.options_menu.visible)
	shell.close_options()
	assert(shell.pause_menu.visible)
	shell.resume_game()
	assert(not paused)
	for frame: int in range(30):
		await process_frame
	assert(game.run_elapsed_seconds > elapsed_before)
	assert(game.get_total_queued_undead() < queued_before)
	assert(not game.run_director.enemy_refill_scheduled)
	shell.show_main_menu()
	assert(not shell.continue_button.disabled)
	var legacy_checkpoint: Dictionary = shell.current_game.build_checkpoint_state()
	legacy_checkpoint["wave"] = 12
	(legacy_checkpoint["metrics"] as Dictionary)["corpses_processed"] = 30
	shell.profile = MetaProgressionStore.default_profile()
	shell.start_game(legacy_checkpoint)
	await process_frame
	assert(MetaProgressionStore.is_unlocked(shell.profile, "auto_retrieval"))
	assert(MetaProgressionStore.is_unlocked(shell.profile, "skeleton_archer"))
	assert(MetaProgressionStore.is_unlocked(shell.profile, "hematic_press"))
	assert(shell.current_game.meta_allows("auto_retrieval"))

	TranslationServer.set_locale(original_locale)
	print("GAME SHELL NAVIGATION VALIDATION: PASS")
	shell.queue_free()
	await process_frame
	RunSaveStore.delete_checkpoint(RUN_PATH)
	for path: String in [PROFILE_PATH, PROFILE_PATH + ".bak", PROFILE_PATH + ".tmp", SETTINGS_PATH]:
		if FileAccess.file_exists(path):
			assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK)
	quit()
