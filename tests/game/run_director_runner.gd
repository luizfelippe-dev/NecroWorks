extends SceneTree


const RUN_DIRECTOR: Script = preload("res://scripts/game/run_director.gd")


func _initialize() -> void:
	var director: RefCounted = RUN_DIRECTOR.new()
	assert(director.current_wave == 1)
	assert(not director.wave_in_progress)

	director.begin_wave(10, 1, true)
	assert(director.current_wave == 10)
	assert(director.enemies_total_this_wave == 1)
	assert(director.boss_active)
	assert(director.wave_in_progress)
	assert(not director.wave_transition_in_progress)

	assert(director.record_enemy_spawned() == 1)
	assert(director.record_enemy_spawned() == 1)
	assert(director.schedule_enemy_refill())
	assert(not director.schedule_enemy_refill())
	director.clear_enemy_refill()
	assert(not director.enemy_refill_scheduled)

	assert(director.record_enemy_defeated() == 1)
	director.complete_wave()
	assert(not director.wave_in_progress)
	assert(director.wave_transition_in_progress)
	assert(not director.boss_active)
	assert(director.advance_to_next_wave() == 11)
	assert(director.wave_preparation_in_progress)
	assert(director.start_prepared_wave())
	assert(not director.wave_preparation_in_progress)
	assert(not director.start_prepared_wave())

	director.finish(true)
	assert(director.run_finished and director.run_won)
	director.prepare_resume(7, true)
	assert(director.current_wave == 7)
	assert(not director.run_finished and not director.run_won)
	assert(director.wave_preparation_in_progress)

	print("RUN DIRECTOR VALIDATION: PASS")
	quit()
