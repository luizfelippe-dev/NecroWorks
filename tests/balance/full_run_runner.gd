extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const EnemyWavePolicy: Script = preload("res://scripts/game/enemy_wave_policy.gd")
const TIME_SCALE: float = 20.0
const MAX_SIMULATED_SECONDS: float = 1800.0


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	Engine.time_scale = TIME_SCALE
	assert(EnemyWavePolicy.get_max_simultaneous_enemies(1, 20) == 1)
	assert(EnemyWavePolicy.get_max_simultaneous_enemies(6, 20) == 2)
	assert(EnemyWavePolicy.get_max_simultaneous_enemies(10, 20) == 3)
	assert(EnemyWavePolicy.get_max_simultaneous_enemies(14, 20) == 4)
	assert(EnemyWavePolicy.get_max_simultaneous_enemies(18, 20) == 5)
	assert(EnemyWavePolicy.get_max_simultaneous_enemies(20, 20) == 1)
	var bone_run: Dictionary = await run_strategy("bone")
	var flesh_run: Dictionary = await run_strategy("flesh")
	Engine.time_scale = 1.0


	print("=== V0.2 FULL RUN BALANCE SUMMARY ===")
	print(JSON.stringify(bone_run))
	print(JSON.stringify(flesh_run))
	var valid: bool = (
		bool(bone_run["won"])
		and bool(flesh_run["won"])
		and int(bone_run["skeletons_built"]) > int(bone_run["zombies_built"])
		and int(flesh_run["zombies_built"]) > int(flesh_run["skeletons_built"])
	)


	if not valid:
		push_error("V0.2 full-run balance gate failed.")
		quit(1)
		return
	print("V0.2 FULL RUN VALIDATION: PASS")
	quit()


func run_strategy(strategy: String) -> Dictionary:
	seed(2402 if strategy == "bone" else 2403)
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	var simulated_seconds: float = 0.0


	while simulated_seconds < MAX_SIMULATED_SECONDS and not game.run_finished:
		for corpse: Button in game.corpses.duplicate():
			if is_instance_valid(corpse) and not game.is_corpse_queued(corpse):
				game.enqueue_corpse_for_processing(corpse)


		if game.wave_transition_in_progress:
			game.set_processing_directive(
				game.PROCESSING_BONE_FOCUS
				if strategy == "bone"
				else game.PROCESSING_FLESH_FOCUS
			)
			if not game.current_upgrade_choices.is_empty():
				game.select_upgrade_by_index(0)


		if game.event_decision_in_progress:
			var event_choice_index: int = 0
			if game.current_narrative_event_id == "grave_shipment":
				event_choice_index = 0 if strategy == "bone" else 1
			elif game.current_narrative_event_id == "bound_arcanist":
				event_choice_index = 1 if strategy == "bone" else 0
			elif game.current_narrative_event_id == "saboteur_offer":
				event_choice_index = 0 if strategy == "bone" else 1
			elif game.current_narrative_event_id == "marshal_remains":
				event_choice_index = 1 if strategy == "bone" else 0
			elif game.current_narrative_event_id == "auditor_core":
				event_choice_index = 1 if strategy == "bone" else 0
			game.select_narrative_event_choice_by_index(event_choice_index)


		var available_capacity: int = game.get_available_production_capacity()


		if available_capacity > 0:
			if strategy == "bone" and game.bones >= game.skeleton_cost:
				game.enqueue_skeleton_production(1)
			elif strategy == "flesh" and game.flesh >= game.zombie_cost:
				game.enqueue_zombie_production(1)
			elif (
				strategy == "flesh"
				and game.current_wave == 1
				and game.bones >= game.skeleton_cost
			):
				game.enqueue_skeleton_production(1)


		if game.souls >= game.ghost_cost and game.get_available_production_capacity() > 0:
			game.create_ghost()


		if game.blood >= game.get_blood_sacrifice_cost():
			game.activate_blood_fervor()


		await process_frame
		simulated_seconds += 1.0 / 60.0 * Engine.time_scale


	var result: Dictionary = {
		"strategy": strategy,
		"won": game.run_won,
		"wave": game.current_wave,
		"simulated_seconds": snappedf(simulated_seconds, 0.1),
		"enemies_killed": game.total_enemies_killed,
		"skeletons_built": game.total_skeletons_created,
		"zombies_built": game.total_zombies_created,
		"ghosts_built": game.total_ghosts_created,
		"army_remaining": game.get_total_undead_count(),
		"blood_earned": game.total_blood_earned,
		"souls_earned": game.total_souls_earned
	}
	game.set_process(false)
	game.queue_free()
	await process_frame
	await process_frame
	return result
