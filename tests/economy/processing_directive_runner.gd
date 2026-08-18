extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)


	assert(game.get_processing_yield(game.PROCESSING_BALANCED) == Vector2i(8, 2))
	assert(game.get_processing_yield(game.PROCESSING_BONE_FOCUS) == Vector2i(12, 0))
	assert(game.get_processing_yield(game.PROCESSING_FLESH_FOCUS) == Vector2i(2, 6))
	assert(game.processing_directive_buttons.size() == 3)
	validate_six_corpse_build_options(game)
	for directive_button_value: Variant in game.processing_directive_buttons.values():
		var directive_button: Button = directive_button_value as Button
		assert(directive_button != null)
		assert(
			directive_button.position.y
			>= game.processing_label.position.y + game.processing_label.size.y
		)
		assert(directive_button.position.x >= 1080.0)
		assert(directive_button.position.x + directive_button.size.x <= 1895.0)
		assert(directive_button.position.y + directive_button.size.y <= 1057.0)


	process_one_corpse(game, game.PROCESSING_BALANCED, Vector2i(8, 2))
	process_one_corpse(game, game.PROCESSING_BONE_FOCUS, Vector2i(12, 0))
	process_one_corpse(game, game.PROCESSING_FLESH_FOCUS, Vector2i(2, 6))
	assert(game.corpses_processed_by_directive[game.PROCESSING_BALANCED] == 1)
	assert(game.corpses_processed_by_directive[game.PROCESSING_BONE_FOCUS] == 1)
	assert(game.corpses_processed_by_directive[game.PROCESSING_FLESH_FOCUS] == 1)


	game.bones_per_corpse = 10
	assert(game.get_processing_yield(game.PROCESSING_BALANCED) == Vector2i(10, 2))
	assert(game.get_processing_yield(game.PROCESSING_BONE_FOCUS) == Vector2i(14, 0))
	assert(game.get_processing_yield(game.PROCESSING_FLESH_FOCUS) == Vector2i(4, 6))
	game.update_metrics_ui()
	assert("14B / 0F" in game.processing_directive_buttons[game.PROCESSING_BONE_FOCUS].text)


	game.set_processing_directive(game.PROCESSING_BALANCED)
	game.finish_run(true)
	assert("Balanced: 1" in game.run_end_build_label.text)
	assert("Bone Focus: 1" in game.run_end_build_label.text)
	assert("Flesh Focus: 1" in game.run_end_build_label.text)
	for directive_button_value: Variant in game.processing_directive_buttons.values():
		var directive_button: Button = directive_button_value as Button
		assert(directive_button != null and directive_button.disabled)


	print("PROCESSING DIRECTIVE VALIDATION: PASS")
	game.queue_free()
	quit()


func process_one_corpse(
	game: Node,
	directive: String,
	expected_yield: Vector2i
) -> void:

	game.set_processing_directive(directive)
	assert(game.processing_directive_buttons[directive].button_pressed)
	var corpse: Button = Button.new()
	game.add_child(corpse)
	game.corpses.append(corpse)
	var previous_bones: int = game.bones
	var previous_flesh: int = game.flesh
	var previous_processed: int = game.total_corpses_processed
	game.process_corpse(corpse)
	assert(game.bones == previous_bones + expected_yield.x)
	assert(game.flesh == previous_flesh + expected_yield.y)
	assert(game.total_corpses_processed == previous_processed + 1)
	assert(not game.corpses.has(corpse))


func validate_six_corpse_build_options(game: Node) -> void:

	var corpse_count: int = 6
	var balanced_resources: Vector2i = (
		game.get_processing_yield(game.PROCESSING_BALANCED)
		* corpse_count
	)
	var bone_resources: Vector2i = (
		game.get_processing_yield(game.PROCESSING_BONE_FOCUS)
		* corpse_count
	)
	var flesh_resources: Vector2i = (
		game.get_processing_yield(game.PROCESSING_FLESH_FOCUS)
		* corpse_count
	)
	assert(balanced_resources == Vector2i(48, 12))
	assert(bone_resources == Vector2i(72, 0))
	assert(flesh_resources == Vector2i(12, 36))
	assert(int(balanced_resources.x / game.skeleton_cost) == 9)
	assert(int(balanced_resources.y / game.zombie_cost) == 2)
	assert(int(bone_resources.x / game.skeleton_cost) == 14)
	assert(int(flesh_resources.y / game.zombie_cost) == 6)
