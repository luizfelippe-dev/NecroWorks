extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	TranslationServer.set_locale("pt_BR")
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)


	var doctrine_events: Array[Dictionary] = []
	game.army_doctrine_changed.connect(
		func(configuration: Dictionary) -> void:
			doctrine_events.append(configuration.duplicate(true))
	)


	assert(
		game.apply_army_doctrine_configuration(
			30,
			5,
			20,
			12,
			game.ARMY_DOCTRINE_POLICY.PRIORITY_SKELETONS
		)
	)
	assert(game.army_doctrine_configured)
	assert(game.doctrine_target_skeletons == 30)
	assert(game.doctrine_target_zombies == 5)
	assert(game.doctrine_bones_reserve == 20)
	assert(game.doctrine_flesh_reserve == 12)
	assert(game.get_army_doctrine_deficits() == Vector2i(29, 5))
	assert(doctrine_events.size() == 1)


	game.bones = 24
	game.flesh = 17
	assert(not game.doctrine_can_build_skeleton())
	assert(not game.doctrine_can_build_zombie())
	game.bones = 25
	game.flesh = 18
	assert(game.doctrine_can_build_skeleton())
	assert(game.doctrine_can_build_zombie())


	assert(
		not game.apply_army_doctrine_configuration(
			32,
			5,
			0,
			0,
			game.ARMY_DOCTRINE_POLICY.PRIORITY_BALANCED
		)
	)
	assert(game.doctrine_target_skeletons == 30)
	assert(game.doctrine_target_zombies == 5)
	assert(doctrine_events.size() == 1)


	game.toggle_army_doctrine_panel()
	assert(game.doctrine_panel.visible)
	assert(game.doctrine_nav_button.text == "DOUTRINA")
	assert(game.doctrine_status_label.text.contains("Meta: 30 Esqueletos / 5 Zumbis"))
	assert(game.doctrine_status_label.text.contains("Faltam: 29 Esqueletos / 5 Zumbis"))
	assert(
		str(game.doctrine_priority_input.get_selected_metadata())
		== game.ARMY_DOCTRINE_POLICY.PRIORITY_SKELETONS
	)


	for _frame: int in range(30):
		await process_frame


	print("ARMY DOCTRINE PLANNING VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
