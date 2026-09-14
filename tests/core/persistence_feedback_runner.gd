extends SceneTree

const SHELL := preload("res://scenes/core/app.tscn")
const PREFIX := "user://necroworks_feedback_test_"
const FAILURE := "user://missing_feedback_test_folder/data.json"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	cleanup()
	var shell: Node = SHELL.instantiate()
	shell.profile_path = PREFIX + "profile.json"
	shell.run_save_path = PREFIX + "run.json"
	shell.settings_path = PREFIX + "settings.cfg"
	root.add_child(shell)
	await process_frame
	assert(not shell.persistence_notice.visible)
	shell.start_game({})
	await process_frame
	var game: Node = shell.current_game
	game.set_process(false)
	game.debug_label.text = "unchanged"
	game.update_debug_ui()
	assert(game.debug_label.text == "unchanged")
	game.debug_label.show()
	game.update_debug_ui()
	assert(game.debug_label.text != "unchanged")
	game.debug_label.hide()
	game.corpses_processed_by_directive = {"balanced": 3, "bone_focus": 4, "flesh_focus": 2}
	game.total_corpses_processed = 9
	var state: Dictionary = game.build_checkpoint_state()
	assert(shell.save_checkpoint(state) == OK)
	var loaded: Dictionary = RunSaveStore.load_checkpoint(shell.run_save_path)
	assert(loaded.processing_routes.bone_focus == 4)
	assert(game.restore_checkpoint_state(loaded))
	assert(game.corpses_processed_by_directive.balanced == 3)
	assert(game.corpses_processed_route_unknown == 0)
	var invalid: Dictionary = loaded.duplicate(true)
	invalid.processing_routes.bone_focus = 50
	assert(not RunSaveStore.validate_checkpoint(invalid))
	assert(not game.restore_checkpoint_state(invalid))
	var legacy: Dictionary = loaded.duplicate(true)
	legacy.erase("processing_routes")
	assert(game.restore_checkpoint_state(legacy))
	assert(game.corpses_processed_route_unknown == 9)
	assert(game.corpses_processed_by_directive.bone_focus == 0)
	assert(game.get_processing_route_metrics().unknown == 9)
	assert(shell.save_checkpoint(game.build_checkpoint_state()) == OK)
	assert(RunSaveStore.load_checkpoint(shell.run_save_path).processing_routes.unknown == 9)

	# Real save failure triggered through the autosave signal must be visible.
	shell.run_save_path = FAILURE
	game.set_process(true)
	game.run_checkpoint_requested.emit(game.get_resume_checkpoint_state())
	assert(shell.persistence_notice.visible)
	assert(paused)
	assert(shell.persistence_messages.checkpoint.key == "PERSIST_CHECKPOINT_FAILED")
	var elapsed: float = game.run_elapsed_seconds
	for frame: int in range(30):
		await process_frame
	assert(game.run_elapsed_seconds == elapsed)
	shell.persistence_notice.hide()
	assert(shell.save_checkpoint(state) != OK)
	assert(not shell.persistence_notice.visible) # Acknowledged error does not spam.
	shell.run_save_path = PREFIX + "run.json"
	shell.retry_persistence()
	assert(not shell.persistence_messages.has("checkpoint"))
	shell.settings_path = FAILURE
	assert(shell.persist_settings() != OK)
	assert(shell.persistence_messages.settings.key == "PERSIST_SETTINGS_FAILED")
	shell.settings_path = PREFIX + "settings.cfg"
	assert(shell.persist_settings() == OK)
	shell.profile_path = FAILURE
	assert(shell.persist_profile(shell.profile) != OK)
	assert(shell.persistence_messages.profile.key == "PERSIST_PROFILE_FAILED")
	shell.profile_path = PREFIX + "profile.json"
	assert(shell.persist_profile(shell.profile) == OK)
	# A failed end-of-run write keeps history in memory for an explicit retry.
	game.run_finished = true
	shell.profile_path = FAILURE
	shell.on_run_completed(false)
	assert(shell.profile.run_history.size() == 1)
	assert(FileAccess.file_exists(shell.run_save_path))
	shell.profile_path = PREFIX + "profile.json"
	shell.retry_persistence()
	assert(not FileAccess.file_exists(shell.run_save_path))
	assert(MetaProgressionStore.load_profile(shell.profile_path).run_history.size() == 1)
	assert(shell.save_checkpoint(state) == OK)
	shell.return_to_menu()
	await process_frame
	# Backup recovery and invalid checkpoint notices do not erase source files.
	assert(TransactionalJsonStore.save_dictionary({"broken": true}, shell.run_save_path) == OK)
	shell.show_main_menu()
	assert(not shell.continue_button.disabled)
	assert(shell.persistence_messages.checkpoint_load.key == "PERSIST_CHECKPOINT_RECOVERED")
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(shell.run_save_path + ".bak")) == OK)
	shell.show_main_menu()
	assert(shell.continue_button.disabled)
	assert(shell.persistence_messages.checkpoint_load.key == "PERSIST_CHECKPOINT_INVALID")
	assert(FileAccess.file_exists(shell.run_save_path))
	for locale: String in ["en", "pt_BR", "es"]:
		LocalizationService.set_locale(locale)
		shell.refresh_persistence_notice()
		assert(not shell.persistence_notice_body.text.contains("PERSIST_"))
		await process_frame
		var panel: Control = shell.persistence_notice.get_child(0).get_child(0)
		assert(panel.get_global_rect().end.y <= 1080)
		if "--capture" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			DirAccess.make_dir_recursive_absolute("res://artifacts/presentation")
			assert(root.get_texture().get_image().save_png("res://artifacts/presentation/persistence_" + locale + ".png") == OK)
	shell.queue_free()
	await process_frame
	var future: Dictionary = MetaProgressionStore.default_profile()
	future.profile_version = 999
	assert(TransactionalJsonStore.save_dictionary(future, PREFIX + "profile.json") == OK)
	var bytes: String = FileAccess.get_file_as_string(PREFIX + "profile.json")
	shell = SHELL.instantiate()
	shell.profile_path = PREFIX + "profile.json"
	shell.run_save_path = PREFIX + "run2.json"
	shell.settings_path = PREFIX + "settings.cfg"
	root.add_child(shell)
	await process_frame
	assert(shell.persistence_messages.profile_load.key == "PERSIST_PROFILE_PROTECTED")
	assert(shell.persistence_notice.visible)
	assert(shell.persist_profile(shell.profile) != OK)
	assert(FileAccess.get_file_as_string(shell.profile_path) == bytes)
	shell.queue_free()
	await process_frame
	cleanup()
	print("PERSISTENCE FEEDBACK AND ROUTE METRICS VALIDATION: PASS")
	quit()


func cleanup() -> void:
	for suffix: String in ["profile.json", "run.json", "run2.json", "settings.cfg"]:
		TransactionalJsonStore.delete_family(PREFIX + suffix)
