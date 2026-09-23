extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const SETTINGS_PATH: String = "user://necroworks_settings_test.cfg"
const LEGACY_SETTINGS_PATH: String = "user://necroworks_settings_v1_test.cfg"
const SAVE_PATH: String = "user://necroworks_run_test.json"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	SettingsStore.save_settings({
		"reading_scale": 1.3,
		"locale": "pt-BR",
		"master_volume": 1.7,
		"music_volume": 0.35,
		"sfx_volume": 0.55,
		"ui_volume": 0.75,
		"fullscreen": true,
		"reduced_motion": true,
		"high_contrast": true,
		"tutorial_enabled": false,
		"tutorial_completed": true,
		"guided_cycle_completed": true,
	}, SETTINGS_PATH)
	var loaded_settings: Dictionary = SettingsStore.load_settings(SETTINGS_PATH)
	assert(loaded_settings.locale == "pt_BR")
	assert(is_equal_approx(loaded_settings.reading_scale, 1.3))
	assert(SettingsStore.sanitize_reading_scale(NAN) == 1.0)
	assert(SettingsStore.sanitize_reading_scale("bad") == 1.0)
	assert(is_equal_approx(float(loaded_settings.master_volume), 1.0))
	assert(is_equal_approx(float(loaded_settings.music_volume), 0.35))
	assert(is_equal_approx(float(loaded_settings.sfx_volume), 0.55))
	assert(is_equal_approx(float(loaded_settings.ui_volume), 0.75))
	assert(loaded_settings.fullscreen)
	assert(loaded_settings.reduced_motion)
	assert(loaded_settings.high_contrast)
	assert(not loaded_settings.tutorial_enabled)
	assert(loaded_settings.tutorial_completed)
	assert(loaded_settings.guided_cycle_completed)
	var legacy_config := ConfigFile.new()
	legacy_config.set_value("meta", "version", 1)
	legacy_config.set_value("general", "locale", "es")
	legacy_config.set_value("audio", "master_volume", 0.45)
	legacy_config.set_value("display", "fullscreen", false)
	assert(legacy_config.save(LEGACY_SETTINGS_PATH) == OK)
	var migrated_settings: Dictionary = SettingsStore.load_settings(LEGACY_SETTINGS_PATH)
	assert(migrated_settings.locale == "es")
	assert(migrated_settings.reading_scale == 1.0)
	assert(is_equal_approx(float(migrated_settings.master_volume), 0.45))
	assert(is_equal_approx(float(migrated_settings.music_volume), 0.65))
	assert(not migrated_settings.reduced_motion)
	assert(migrated_settings.tutorial_enabled)
	assert(not migrated_settings.guided_cycle_completed)

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
	game.run_elapsed_seconds = 143.5
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
	assert(is_equal_approx(restored_game.run_elapsed_seconds, 143.5))
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
	DirAccess.remove_absolute(ProjectSettings.globalize_path(LEGACY_SETTINGS_PATH))
	print("SETTINGS AND CHECKPOINT PERSISTENCE VALIDATION: PASS")
	game.queue_free()
	restored_game.queue_free()
	quit()
