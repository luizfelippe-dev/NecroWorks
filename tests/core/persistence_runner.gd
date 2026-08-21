extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const SETTINGS_PATH: String = "user://necroworks_settings_test.cfg"
const SAVE_PATH: String = "user://necroworks_run_test.json"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	SettingsStore.save_settings({
		"locale": "pt-BR",
		"master_volume": 1.7,
		"fullscreen": true,
	}, SETTINGS_PATH)
	var loaded_settings: Dictionary = SettingsStore.load_settings(SETTINGS_PATH)
	assert(loaded_settings.locale == "pt_BR")
	assert(is_equal_approx(float(loaded_settings.master_volume), 1.0))
	assert(loaded_settings.fullscreen)

	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.bones = 37
	game.flesh = 19
	game.blood = 4
	game.souls = 6
	game.factory_points = 5
	game.skeleton_archer_unlocked = true
	game.total_enemies_killed = 12
	game.total_corpses_processed = 9
	game.processing_directive = game.PROCESSING_BONE_FOCUS
	game.skeleton_production_queue.append({
		"unit_type": "skeleton_warrior",
		"remaining": 2,
		"total_cost": 10,
	})
	game.apply_army_doctrine_configuration(4, 2, 10, 6, "balanced")
	var state: Dictionary = game.build_checkpoint_state()
	state.wave = 4
	assert(RunSaveStore.save_checkpoint(state, SAVE_PATH) == OK)
	assert(RunSaveStore.has_checkpoint(SAVE_PATH))
	var loaded_state: Dictionary = RunSaveStore.load_checkpoint(SAVE_PATH)
	assert(int(loaded_state.wave) == 4)
	assert(int(loaded_state.resources.bones) == 37)
	assert(bool(loaded_state.factory.archer_unlocked))

	var restored_game: Node = MAIN_SCENE.instantiate()
	root.add_child(restored_game)
	await process_frame
	restored_game.set_process(false)
	assert(restored_game.restore_checkpoint_state(loaded_state))
	assert(restored_game.current_wave == 4)
	assert(restored_game.bones == 37)
	assert(restored_game.flesh == 19)
	assert(restored_game.factory_points == 5)
	assert(restored_game.skeleton_archer_unlocked)
	assert(restored_game.total_enemies_killed == 12)
	assert(restored_game.total_corpses_processed == 9)
	assert(restored_game.processing_directive == game.PROCESSING_BONE_FOCUS)
	assert(restored_game.skeleton_production_queue.size() == 1)
	assert(restored_game.doctrine_target_skeletons == 4)
	assert(restored_game.get_total_undead_count() == 1)

	assert(RunSaveStore.delete_checkpoint(SAVE_PATH) == OK)
	var corrupt_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	corrupt_save.store_string("{not valid json")
	corrupt_save = null
	assert(RunSaveStore.load_checkpoint(SAVE_PATH).is_empty())
	assert(RunSaveStore.delete_checkpoint(SAVE_PATH) == OK)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_PATH))
	print("SETTINGS AND CHECKPOINT PERSISTENCE VALIDATION: PASS")
	game.queue_free()
	restored_game.queue_free()
	quit()
