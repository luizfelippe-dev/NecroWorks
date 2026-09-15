extends SceneTree

const APP: PackedScene = preload("res://scenes/core/app.tscn")
const PREFIX: String = "user://necroworks_context_tutorial_"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	cleanup()
	var out_of_order := GameplayTutorialGuide.new()
	root.add_child(out_of_order)
	await process_frame
	out_of_order.configure(true)
	assert(not out_of_order.record_event("production_queued"))
	for event_id: String in ["enemy_defeated", "corpse_queued", "corpse_processed"]:
		assert(out_of_order.record_event(event_id))
	assert(out_of_order.step == 4, "An early production order must not block the guide")
	assert(out_of_order.record_event("production_completed"))
	assert(out_of_order.cycle_completed)
	out_of_order.queue_free()
	await process_frame
	var settings: Dictionary = SettingsStore.get_defaults()
	settings.tutorial_completed = true
	settings.guided_cycle_completed = false
	assert(SettingsStore.save_settings(settings, PREFIX + "settings.cfg") == OK)
	var shell: Node = APP.instantiate()
	shell.profile_path = PREFIX + "profile.json"
	shell.settings_path = PREFIX + "settings.cfg"
	shell.run_save_path = PREFIX + "run.json"
	root.add_child(shell)
	await process_frame
	shell.confirm_new_run()
	await process_frame
	var game: Node = shell.current_game
	game.set_process(false)
	var guide: GameplayTutorialGuide = game.contextual_tutorial_guide
	assert(not shell.tutorial_menu.visible)
	assert(guide.visible and guide.active and guide.step == 0)
	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		guide.refresh_text()
		assert(not guide.objective_label.text.is_empty())
		assert(Rect2(Vector2.ZERO, Vector2(1920, 1080)).encloses(guide.get_global_rect()))

	game.kill_enemy(game.enemies[0])
	assert(guide.step == 1 and game.corpses.size() == 1)
	if "--capture" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(
			"res://artifacts/presentation"
		))
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(
			"res://artifacts/presentation/contextual_tutorial_1280x720.png"
		) == OK)
	assert(game.enqueue_corpse_for_processing(game.corpses[0]))
	assert(guide.step == 2)
	game.update_corpse_processor(10.0)
	assert(guide.step == 3 and game.total_corpses_processed == 1)
	assert(game.enqueue_skeleton_production(1))
	assert(guide.step == 4)
	game.update_undead_production_queues(10.0)
	assert(guide.cycle_completed and guide.visible)
	assert(bool(SettingsStore.load_settings(PREFIX + "settings.cfg").guided_cycle_completed))
	guide.dismiss_button.pressed.emit()
	assert(not guide.visible)

	shell.queue_free()
	await process_frame
	var returning_shell: Node = APP.instantiate()
	returning_shell.profile_path = PREFIX + "profile.json"
	returning_shell.settings_path = PREFIX + "settings.cfg"
	returning_shell.run_save_path = PREFIX + "run.json"
	root.add_child(returning_shell)
	await process_frame
	returning_shell.start_game({})
	await process_frame
	assert(not returning_shell.current_game.contextual_tutorial_guide.visible)
	returning_shell.queue_free()
	await process_frame
	cleanup()
	print("CONTEXTUAL TUTORIAL VALIDATION: PASS")
	quit()


func cleanup() -> void:
	RunSaveStore.delete_checkpoint(PREFIX + "run.json")
	for path: String in [
		PREFIX + "profile.json", PREFIX + "profile.json.bak",
		PREFIX + "profile.json.tmp", PREFIX + "settings.cfg",
	]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
