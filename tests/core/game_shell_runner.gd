extends SceneTree


const APP_SCENE: PackedScene = preload("res://app.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	var shell: Node = APP_SCENE.instantiate()
	root.add_child(shell)
	await process_frame
	assert(shell.main_menu.visible)
	assert(not shell.pause_menu.visible)
	assert(shell.title_label.text == "NECROWORKS")

	LocalizationService.set_locale("pt-BR")
	await process_frame
	assert(shell.pause_title.text == "PRODUÇÃO PAUSADA")
	assert(shell.options_apply_button.text == "APLICAR")

	shell.start_game({})
	await process_frame
	assert(shell.current_game != null)
	assert(not shell.main_menu.visible)
	shell.pause_game()
	assert(paused)
	assert(shell.pause_menu.visible)
	shell.open_options_from_pause()
	assert(shell.options_menu.visible)
	shell.close_options()
	assert(shell.pause_menu.visible)
	shell.resume_game()
	assert(not paused)

	TranslationServer.set_locale(original_locale)
	print("GAME SHELL NAVIGATION VALIDATION: PASS")
	shell.queue_free()
	quit()
