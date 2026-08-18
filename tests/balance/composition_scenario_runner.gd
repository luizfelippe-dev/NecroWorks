extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const TEST_WAVE: int = 8
const ARMY_SIZE: int = 8
const SIMULATION_TIME_SCALE: float = 12.0
const MAX_SIMULATED_SECONDS: float = 120.0

const SCENARIOS: Array[Dictionary] = [
	{
		"id": "skeleton_only",
		"skeletons": ARMY_SIZE,
		"zombies": 0
	},
	{
		"id": "zombie_heavy",
		"skeletons": 0,
		"zombies": ARMY_SIZE
	},
	{
		"id": "mixed_army",
		"skeletons": ARMY_SIZE / 2,
		"zombies": ARMY_SIZE / 2
	}
]


func _initialize() -> void:
	call_deferred("run_all_scenarios")


func run_all_scenarios() -> void:
	Engine.time_scale = SIMULATION_TIME_SCALE
	var results: Array[Dictionary] = []


	for scenario: Dictionary in SCENARIOS:
		results.append(await run_scenario(scenario))


	Engine.time_scale = 1.0
	print("")
	print("=== COMPOSITION BALANCE SUMMARY ===")


	for result: Dictionary in results:
		print(JSON.stringify(result))


	assert(results.size() == SCENARIOS.size())
	print("COMPOSITION SCENARIO RUNNER: PASS")
	quit()


func run_scenario(scenario: Dictionary) -> Dictionary:
	seed(1337)
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	clear_runtime_units(game)
	await process_frame


	for _index: int in range(int(scenario["skeletons"])):
		assert(game.create_free_skeleton("BALANCE TEST"))


	game.flesh = int(scenario["zombies"]) * game.zombie_cost


	for _index: int in range(int(scenario["zombies"])):
		game.create_zombie()


	game.bones = 0
	game.flesh = 0
	game.start_wave(TEST_WAVE)
	game.set_process(true)


	var simulated_seconds: float = 0.0
	var outcome: String = "timeout"


	while simulated_seconds < MAX_SIMULATED_SECONDS:
		await process_frame
		simulated_seconds += (
			1.0
			/ 60.0
			* Engine.time_scale
		)


		if game.wave_transition_in_progress:
			outcome = "wave_cleared"
			break


		if game.get_total_undead_count() <= 0:
			outcome = "army_wiped"
			break


	var result: Dictionary = {
		"scenario": str(scenario["id"]),
		"wave": TEST_WAVE,
		"starting_army": int(scenario["skeletons"]) + int(scenario["zombies"]),
		"starting_skeletons": int(scenario["skeletons"]),
		"starting_zombies": int(scenario["zombies"]),
		"outcome": outcome,
		"simulated_seconds": snappedf(simulated_seconds, 0.1),
		"enemies_defeated": game.enemies_defeated_this_wave,
		"enemies_total": game.enemies_total_this_wave,
		"skeletons_remaining": game.skeletons.size(),
		"zombies_remaining": game.zombies.size(),
		"army_remaining": game.get_total_undead_count()
	}


	game.wave_in_progress = false
	game.set_process(false)
	game.queue_free()
	await process_frame
	await process_frame
	return result


func clear_runtime_units(game: Node) -> void:
	for current_enemy: Node2D in game.enemies.duplicate():
		current_enemy.queue_free()


	for current_skeleton: Node2D in game.skeletons.duplicate():
		current_skeleton.queue_free()


	for current_zombie: Node2D in game.zombies.duplicate():
		current_zombie.queue_free()


	for corpse: Button in game.corpses.duplicate():
		corpse.queue_free()


	game.enemy = null
	game.enemies.clear()
	game.enemy_hps.clear()
	game.enemy_max_hps.clear()
	game.enemy_damages.clear()
	game.enemy_speeds.clear()
	game.enemy_attack_cooldowns.clear()
	game.enemy_attack_ranges.clear()
	game.enemy_attack_timers.clear()
	game.enemy_lane_offsets.clear()
	game.enemy_types.clear()
	game.skeletons.clear()
	game.skeleton_hps.clear()
	game.skeleton_attack_timers.clear()
	game.skeleton_slots.clear()
	game.zombies.clear()
	game.zombie_hps.clear()
	game.zombie_attack_timers.clear()
	game.zombie_slots.clear()
	game.occupied_undead_slots.clear()
	game.corpses.clear()
