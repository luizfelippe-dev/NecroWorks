extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const SAMPLE_FRAMES: int = 300
const MAX_DEBUG_AVERAGE_MS: float = 35.0


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	await _clear_runtime(game)
	game.skeleton_archer_unlocked = true
	game.lich_unlocked = true
	for _index: int in range(8):
		assert(game.create_free_skeleton("STRESS"))
	for _index: int in range(10):
		game.flesh += game.zombie_cost
		game.create_zombie()
	for _index: int in range(6):
		assert(game.create_free_skeleton_archer("STRESS"))
	for _index: int in range(10):
		assert(game.create_free_ghost())
	for _index: int in range(2):
		assert(game.create_free_lich())
	assert(game.get_total_undead_count() == game.MAX_UNDEAD)
	game.start_wave(18)
	assert(game.enemies.size() == game.get_max_simultaneous_enemies())
	var started_ms: int = Time.get_ticks_msec()
	for _frame: int in range(SAMPLE_FRAMES):
		game._process(1.0 / 60.0)
	var elapsed_ms: int = Time.get_ticks_msec() - started_ms
	var average_ms: float = float(elapsed_ms) / float(SAMPLE_FRAMES)
	assert(average_ms <= MAX_DEBUG_AVERAGE_MS)
	assert(game.combat_feedback.get_child_count() <= 48)
	print("HORDE STRESS: PASS | 36 UNDEAD | AVG DEBUG FRAME: %.2f ms" % average_ms)
	game.wave_in_progress = false
	game.queue_free()
	await process_frame
	quit()


func _clear_runtime(game: Node) -> void:
	for group: Array in [game.enemies, game.skeletons, game.zombies, game.ghosts, game.liches]:
		for unit: Node2D in group.duplicate():
			unit.queue_free()
		group.clear()
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
