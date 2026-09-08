extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const SHELL_SCENE: PackedScene = preload("res://scenes/core/app.tscn")
const RUN_PATH: String = "user://necroworks_reliability_run.json"
const PROFILE_PATH: String = "user://necroworks_reliability_profile.json"
const FAILURE_PATH: String = "user://missing_reliability_folder/run.json"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	cleanup()
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.bones = 21
	game.total_enemies_killed = 3
	var wave_start: Dictionary = game.capture_resume_checkpoint_state()
	game.bones = 99
	game.total_enemies_killed = 15
	var resume_state: Dictionary = game.get_resume_checkpoint_state()
	assert(int(resume_state.resources.bones) == 21)
	assert(int(resume_state.metrics.enemies_killed) == 3)
	var restored_game: Node = MAIN_SCENE.instantiate()
	root.add_child(restored_game)
	await process_frame
	restored_game.set_process(false)
	assert(restored_game.restore_checkpoint_state(resume_state))
	assert(restored_game.bones == 21)
	assert(restored_game.total_enemies_killed == 3)
	restored_game.queue_free()
	await process_frame
	assert(RunSaveStore.save_checkpoint(wave_start, RUN_PATH) == OK)

	var next_state: Dictionary = wave_start.duplicate(true)
	next_state.resources.bones = 34
	assert(RunSaveStore.save_checkpoint(next_state, RUN_PATH) == OK)
	assert(FileAccess.file_exists(RUN_PATH + ".bak"))
	var corrupt_file: FileAccess = FileAccess.open(RUN_PATH, FileAccess.WRITE)
	assert(corrupt_file != null)
	corrupt_file.store_string("{truncated")
	corrupt_file = null
	var recovered: Dictionary = RunSaveStore.load_checkpoint(RUN_PATH)
	assert(not recovered.is_empty())
	assert(int(recovered.resources.bones) == 21)

	var invalid_state: Dictionary = wave_start.duplicate(true)
	invalid_state.erase("resources")
	assert(RunSaveStore.save_checkpoint(invalid_state, RUN_PATH) == ERR_INVALID_DATA)
	assert(RunSaveStore.save_checkpoint(wave_start, FAILURE_PATH) != OK)

	var first_profile: Dictionary = MetaProgressionStore.default_profile()
	first_profile.progress.highest_wave = 4
	assert(MetaProgressionStore.save_profile(first_profile, PROFILE_PATH) == OK)
	var second_profile: Dictionary = first_profile.duplicate(true)
	second_profile.progress.highest_wave = 9
	assert(MetaProgressionStore.save_profile(second_profile, PROFILE_PATH) == OK)
	corrupt_file = FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	assert(corrupt_file != null)
	corrupt_file.store_string("not json")
	corrupt_file = null
	var recovered_profile: Dictionary = MetaProgressionStore.load_profile(PROFILE_PATH)
	assert(int(recovered_profile.progress.highest_wave) == 4)
	assert(str(recovered_profile.get(MetaProgressionStore.LOAD_STATUS_MARKER)) ==
		MetaProgressionStore.STATUS_RECOVERED)

	var future_profile: Dictionary = MetaProgressionStore.default_profile()
	future_profile.profile_version = MetaProgressionStore.PROFILE_VERSION + 1
	assert(TransactionalJsonStore.save_dictionary(future_profile, PROFILE_PATH) == OK)
	var protected_profile: Dictionary = MetaProgressionStore.load_profile(PROFILE_PATH)
	assert(bool(protected_profile.get(
		MetaProgressionStore.READ_ONLY_MARKER, false
	)))
	assert(
		MetaProgressionStore.save_profile(protected_profile, PROFILE_PATH)
		== ERR_FILE_UNRECOGNIZED
	)
	var preserved_future: Dictionary = TransactionalJsonStore.load_dictionary(
		PROFILE_PATH
	)
	assert(
		int(preserved_future.profile_version)
		== MetaProgressionStore.PROFILE_VERSION + 1
	)
	var still_healthy_backup: Dictionary = TransactionalJsonStore.load_dictionary(
		PROFILE_PATH + TransactionalJsonStore.BACKUP_SUFFIX
	)
	assert(int(still_healthy_backup.progress.highest_wave) == 4)

	TransactionalJsonStore.delete_family(PROFILE_PATH)
	corrupt_file = FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	assert(corrupt_file != null)
	corrupt_file.store_string("broken without backup")
	corrupt_file = null
	var corrupt_profile: Dictionary = MetaProgressionStore.load_profile(PROFILE_PATH)
	assert(str(corrupt_profile.get(MetaProgressionStore.LOAD_STATUS_MARKER)) ==
		MetaProgressionStore.STATUS_CORRUPT)
	assert(MetaProgressionStore.save_profile(corrupt_profile, PROFILE_PATH) ==
		ERR_FILE_UNRECOGNIZED)

	var shell: Node = SHELL_SCENE.instantiate()
	shell.profile_path = PROFILE_PATH + ".shell"
	shell.run_save_path = RUN_PATH + ".shell"
	root.add_child(shell)
	await process_frame
	shell.start_game({})
	await process_frame
	var running_game: Node = shell.current_game
	shell.run_save_path = FAILURE_PATH
	shell.pause_game()
	shell.save_and_return_to_menu()
	assert(shell.current_game == running_game)
	assert(is_instance_valid(running_game))
	assert(shell.pause_menu.visible)
	var failure_text: String = shell.pause_status_label.text
	assert(
		failure_text.contains("Falha ao salvar")
		or failure_text.contains("Save failed")
		or failure_text.contains("Error al guardar")
	)

	print("TRANSACTIONAL SAVE AND RESUME RELIABILITY VALIDATION: PASS")
	game.queue_free()
	shell.queue_free()
	cleanup()
	quit()


func cleanup() -> void:
	for path: String in [
		RUN_PATH,
		PROFILE_PATH,
		PROFILE_PATH + ".shell",
		RUN_PATH + ".shell",
	]:
		TransactionalJsonStore.delete_family(path)
