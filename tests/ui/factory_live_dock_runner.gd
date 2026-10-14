extends SceneTree

func _initialize() -> void:
	call_deferred("validate")

func validate() -> void:
	var game: Node = preload("res://scenes/world/gameplay.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var dock: Node = game.get_node("FactoryLiveDock")
	assert(dock.expanded and not dock.toggle.visible)
	assert(dock.panel.position.y == 640 and dock.panel.size.x == 1480)
	var formation := preload("res://scripts/game/combat_formation_policy.gd")
	for slot: int in range(36):
		assert(formation.get_spawn_position(slot).y + 50 < dock.panel.position.y)
		assert(formation.get_combat_position(Vector2(1400, 450), slot).y + 50 < dock.panel.position.y)
	for machine: Node2D in dock.machines:
		assert(machine.visible)
	game.spawn_corpse(Vector2(850, 550), "human_warrior")
	var corpse: Button = game.corpses[0]
	assert(game.enqueue_corpse_for_processing(corpse))
	dock.set_expanded(true)
	assert(dock.panel.visible and not corpse.visible)
	var phase: float = dock.belt_phase
	dock._process(0.1)
	assert(dock.belt_phase != phase)
	game.reduced_motion_enabled = true
	phase = dock.belt_phase
	dock._process(0.1)
	assert(dock.belt_phase == phase)
	game.reduced_motion_enabled = false
	game.wave_preparation_in_progress = true
	dock._process(0.1)
	assert(dock.belt_phase == phase)
	game.wave_preparation_in_progress = false
	dock.set_expanded(false)
	assert(corpse.visible)
	assert(game.corpse_processing_queue.size() == 1)
	dock.set_expanded(true)
	assert(not corpse.visible)
	assert(game.bones == 0)
	for locale: String in ["pt_BR", "en", "es"]:
		TranslationServer.set_locale(locale)
		dock._process(0)
		assert(not dock.toggle.text.contains("FACTORY_LIVE"))
	dock.set_expanded(false)
	game.update_corpse_processor(10)
	assert(game.bones > 0)
	game.queue_free()
	await process_frame
	print("FACTORY LIVE DOCK: PASS")
	quit()
