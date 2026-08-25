extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)


	var synergy_ids: Array[String] = [
		game.SYNERGY_RECYCLING_PLANT,
		game.SYNERGY_SECOND_SHIFT,
		game.SYNERGY_BONE_ASSEMBLY_LINE,
		game.SYNERGY_OVERCLOCKED_OSSUARY,
		game.SYNERGY_MEAT_SHIELD_PROTOCOL,
		game.SYNERGY_CRIMSON_ASSEMBLY,
		game.SYNERGY_PHANTOM_CONDUIT,
		game.SYNERGY_DARK_REFINERY,
		game.SYNERGY_SOUL_FOUNDRY,
		game.SYNERGY_OSSUARY_BALLISTICS
	]
	for synergy_id: String in synergy_ids:
		game.active_synergies[synergy_id] = true
	game.update_synergy_ui()
	await process_frame


	var metrics_panel: Control = game.get_node("MetricsPanel") as Control
	var panel: Control = game.get_node("SynergyPanel") as Control
	var label: Label = game.synergy_label
	game.update_metrics_ui()
	await process_frame
	assert(
		metrics_panel.position.y + metrics_panel.size.y
		<= panel.position.y
	)
	assert(
		game.metrics_label.size.y
		>= game.metrics_label.get_combined_minimum_size().y
	)
	assert(
		game.metrics_label.position.y + game.metrics_label.size.y
		<= metrics_panel.position.y + metrics_panel.size.y
	)
	assert(label.get_line_count() == synergy_ids.size() + 1)
	assert(label.size.y >= label.get_combined_minimum_size().y)
	assert(label.position.y + label.size.y <= panel.position.y + panel.size.y)
	print("SYNERGY PANEL BOUNDS VALIDATION: PASS")
	game.queue_free()
	quit()
