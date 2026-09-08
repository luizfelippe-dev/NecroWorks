extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const TEST_WAVE: int = 12
const SIMULATION_TIME_SCALE: float = 16.0
const MAX_SIMULATED_SECONDS: float = 150.0

const BUILDS: Array[Dictionary] = [
	{"id": "bone_swarm", "skeletons": 16, "zombies": 0, "archers": 0, "ghosts": 0, "liches": 0},
	{"id": "flesh_frontline", "skeletons": 0, "zombies": 14, "archers": 0, "ghosts": 0, "liches": 0},
	{"id": "soul_caster", "skeletons": 0, "zombies": 5, "archers": 0, "ghosts": 7, "liches": 2},
	{"id": "hybrid", "skeletons": 5, "zombies": 5, "archers": 3, "ghosts": 2, "liches": 1},
	{"id": "automation_target", "skeletons": 8, "zombies": 6, "archers": 2, "ghosts": 0, "liches": 0}
]


func _initialize() -> void:
	call_deferred("run_matrix")


func run_matrix() -> void:
	Engine.time_scale = SIMULATION_TIME_SCALE
	var results: Array[Dictionary] = []
	for build: Dictionary in BUILDS:
		results.append(await run_build(build))
	Engine.time_scale = 1.0

	var resolved_builds: int = 0
	for result: Dictionary in results:
		print(JSON.stringify(result))
		assert(str(result["outcome"]) != "timeout")
		if str(result["outcome"]) in ["wave_cleared", "army_wiped"]:
			resolved_builds += 1
	assert(resolved_builds == BUILDS.size())
	assert(results[0]["starting_skeletons"] > results[0]["starting_zombies"])
	assert(results[1]["starting_zombies"] > results[1]["starting_skeletons"])
	assert(results[2]["starting_casters"] >= 9)
	assert(results[3]["starting_families"] == 5)
	assert(results[4]["starting_army"] == 16)
	print("VERTICAL SLICE BUILD MATRIX: PASS")
	quit()


func run_build(build: Dictionary) -> Dictionary:
	seed(4100 + BUILDS.find(build))
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	await clear_runtime(game)
	game.skeleton_archer_unlocked = true
	game.lich_unlocked = true

	for _index: int in range(int(build["skeletons"])):
		assert(game.create_free_skeleton("BUILD MATRIX"))
	for _index: int in range(int(build["zombies"])):
		assert(game.create_free_zombie("BUILD MATRIX"))
	for _index: int in range(int(build["archers"])):
		assert(game.create_free_skeleton_archer("BUILD MATRIX"))
	for _index: int in range(int(build["ghosts"])):
		assert(game.create_free_ghost())
	for _index: int in range(int(build["liches"])):
		assert(game.create_free_lich())

	var starting_army: int = game.get_total_undead_count()
	assert(starting_army == build_total(build))
	game.start_wave(TEST_WAVE)
	game.set_process(true)
	var simulated_seconds: float = 0.0
	var outcome: String = "timeout"
	while simulated_seconds < MAX_SIMULATED_SECONDS:
		await process_frame
		simulated_seconds += 1.0 / 60.0 * Engine.time_scale
		if game.wave_transition_in_progress:
			outcome = "wave_cleared"
			break
		if game.get_total_undead_count() <= 0:
			outcome = "army_wiped"
			break

	var families: int = 0
	for key: String in ["skeletons", "zombies", "archers", "ghosts", "liches"]:
		families += 1 if int(build[key]) > 0 else 0
	var result: Dictionary = {
		"build": str(build["id"]),
		"wave": TEST_WAVE,
		"outcome": outcome,
		"simulated_seconds": snappedf(simulated_seconds, 0.1),
		"starting_army": starting_army,
		"starting_skeletons": int(build["skeletons"]) + int(build["archers"]),
		"starting_zombies": int(build["zombies"]),
		"starting_casters": int(build["ghosts"]) + int(build["liches"]),
		"starting_families": families,
		"enemies_defeated": game.enemies_defeated_this_wave,
		"enemies_total": game.enemies_total_this_wave,
		"army_remaining": game.get_total_undead_count()
	}
	game.wave_in_progress = false
	game.set_process(false)
	game.queue_free()
	await process_frame
	await process_frame
	return result


func build_total(build: Dictionary) -> int:
	return (
		int(build["skeletons"])
		+ int(build["zombies"])
		+ int(build["archers"])
		+ int(build["ghosts"])
		+ int(build["liches"])
	)


func clear_runtime(game: Node) -> void:
	for group: Array in [game.enemies, game.skeletons, game.zombies, game.ghosts, game.liches]:
		for unit: Node2D in group.duplicate():
			unit.queue_free()
		group.clear()
	for corpse: Button in game.corpses.duplicate():
		corpse.queue_free()
	game.enemy = null
	game.corpses.clear()
	game.enemy_hps.clear()
	game.enemy_max_hps.clear()
	game.enemy_damages.clear()
	game.enemy_speeds.clear()
	game.enemy_attack_cooldowns.clear()
	game.enemy_attack_ranges.clear()
	game.enemy_attack_timers.clear()
	game.enemy_lane_offsets.clear()
	game.enemy_types.clear()
	game.skeleton_hps.clear()
	game.skeleton_attack_timers.clear()
	game.skeleton_slots.clear()
	game.zombie_hps.clear()
	game.zombie_attack_timers.clear()
	game.zombie_slots.clear()
	game.occupied_undead_slots.clear()
	await process_frame
