extends SceneTree


const APP_SCENE: PackedScene = preload("res://scenes/core/app.tscn")
const PROFILE_PATH: String = "user://necroworks_tutorial_profile.json"
const SETTINGS_PATH: String = "user://necroworks_tutorial_settings.cfg"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	SettingsStore.save_settings(SettingsStore.get_defaults(), SETTINGS_PATH)
	var shell: Node = APP_SCENE.instantiate()
	shell.profile_path = PROFILE_PATH
	shell.settings_path = SETTINGS_PATH
	root.add_child(shell)
	await process_frame
	shell.confirm_new_run()
	await process_frame
	assert(shell.tutorial_menu.visible)
	assert(paused)
	assert(shell.tutorial_body.text.length() > 40)
	assert_screen_panel_fits(shell.tutorial_menu)
	for step: int in range(4):
		shell.advance_tutorial()
		assert(shell.tutorial_step == step + 1)
	assert(shell.tutorial_next_button.text == tr("TUTORIAL_FINISH"))
	shell.advance_tutorial()
	assert(not shell.tutorial_menu.visible)
	assert(not paused)
	assert(bool(SettingsStore.load_settings(SETTINGS_PATH).tutorial_completed))
	shell.reset_tutorial()
	assert(shell.tutorial_menu.visible)
	assert(not bool(SettingsStore.load_settings(SETTINGS_PATH).tutorial_completed))
	shell.finish_tutorial()
	shell.return_to_menu()
	shell.open_options_from_main()
	await process_frame
	assert_screen_panel_fits(shell.options_menu)
	shell.queue_free()
	await process_frame
	for path: String in [PROFILE_PATH, SETTINGS_PATH]:
		if FileAccess.file_exists(path):
			assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK)
	print("FIRST-RUN TUTORIAL VALIDATION: PASS")
	quit()


func assert_screen_panel_fits(screen: Control) -> void:
	var center: Control = screen.get_child(0) as Control
	var panel: Control = center.get_child(0) as Control
	var panel_rect: Rect2 = panel.get_global_rect()
	assert(panel_rect.position.x >= 0.0)
	assert(panel_rect.position.y >= 0.0)
	assert(panel_rect.end.x <= 1920.0)
	assert(panel_rect.end.y <= 1080.0)
