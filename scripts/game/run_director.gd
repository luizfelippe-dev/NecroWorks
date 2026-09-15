extends RefCounted


var current_wave: int = 1
var enemies_total_this_wave: int = 0
var enemies_defeated_this_wave: int = 0
var enemies_spawned_this_wave: int = 0
var enemy_refill_scheduled: bool = false
var wave_in_progress: bool = false
var wave_transition_in_progress: bool = false
var wave_preparation_in_progress: bool = false
var boss_active: bool = false
var run_finished: bool = false
var run_won: bool = false


func begin_wave(wave_number: int, enemy_total: int, is_boss: bool) -> void:
	current_wave = maxi(wave_number, 1)
	enemies_total_this_wave = maxi(enemy_total, 0)
	enemies_defeated_this_wave = 0
	enemies_spawned_this_wave = 0
	enemy_refill_scheduled = false
	wave_in_progress = true
	wave_transition_in_progress = false
	wave_preparation_in_progress = false
	boss_active = is_boss
	run_finished = false
	run_won = false


func record_enemy_spawned() -> int:
	enemies_spawned_this_wave = mini(
		enemies_spawned_this_wave + 1,
		enemies_total_this_wave
	)
	return enemies_spawned_this_wave


func record_enemy_defeated() -> int:
	enemies_defeated_this_wave = mini(
		enemies_defeated_this_wave + 1,
		enemies_total_this_wave
	)
	return enemies_defeated_this_wave


func schedule_enemy_refill() -> bool:
	if run_finished or not wave_in_progress or enemy_refill_scheduled:
		return false
	enemy_refill_scheduled = true
	return true


func clear_enemy_refill() -> void:
	enemy_refill_scheduled = false


func complete_wave() -> void:
	wave_in_progress = false
	wave_transition_in_progress = true
	enemy_refill_scheduled = false
	boss_active = false


func advance_to_next_wave() -> int:
	wave_transition_in_progress = false
	current_wave += 1
	wave_preparation_in_progress = true
	return current_wave


func start_prepared_wave() -> bool:
	if not wave_preparation_in_progress or run_finished:
		return false
	wave_preparation_in_progress = false
	return true


func finish(victory: bool) -> void:
	run_finished = true
	run_won = victory
	boss_active = false
	wave_in_progress = false
	wave_transition_in_progress = false
	wave_preparation_in_progress = false
	enemy_refill_scheduled = false


func prepare_resume(wave_number: int, preparation_pending: bool = false) -> void:
	current_wave = maxi(wave_number, 1)
	run_finished = false
	run_won = false
	wave_in_progress = false
	wave_transition_in_progress = false
	wave_preparation_in_progress = preparation_pending
	boss_active = false
	enemy_refill_scheduled = false
