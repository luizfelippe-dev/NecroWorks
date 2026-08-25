extends RefCounted


const BASE_ENEMIES_PER_WAVE: int = 5
const ENEMIES_PER_WAVE_GROWTH: int = 1

const BASE_ENEMY_HP: int = 100
const ENEMY_HP_GROWTH: int = 20

const BASE_ENEMY_DAMAGE: int = 7
const ENEMY_DAMAGE_GROWTH: int = 1

const ELITE_WAVES: PackedInt32Array = [5, 9, 14, 18]
const ELITE_ENEMIES_PER_WAVE: int = 5
const ELITE_HP_MULTIPLIER: float = 1.4
const ELITE_DAMAGE_BONUS: int = 3

const FINAL_BOSS_WAVE: int = 20
const BOSS_WAVES: PackedInt32Array = [10, 15, 20]
const BOSS_PROFILES: Dictionary = {
	10: {
		"id": "grave_marshal",
		"name_key": "ENEMY_GRAVE_MARSHAL",
		"hp": 1050,
		"damage": 18,
		"special_interval": 5.0,
		"special_targets": 3,
		"special_damage": 20,
	},
	15: {
		"id": "arcane_auditor",
		"name_key": "ENEMY_ARCANE_AUDITOR",
		"hp": 1650,
		"damage": 24,
		"special_interval": 4.5,
		"special_targets": 4,
		"special_damage": 28,
	},
	20: {
		"id": "foreman",
		"name_key": "ENEMY_THE_FOREMAN",
		"hp": 2200,
		"damage": 28,
		"special_interval": 4.0,
		"special_targets": 6,
		"special_damage": 35,
	},
}


static func get_enemies_for_wave(wave_number: int) -> int:
	if is_boss_wave(wave_number):
		return 1

	if is_elite_wave(wave_number):
		return ELITE_ENEMIES_PER_WAVE

	return BASE_ENEMIES_PER_WAVE + (wave_number - 1) * ENEMIES_PER_WAVE_GROWTH


static func get_enemy_hp_for_wave(wave_number: int) -> int:
	var result: int = BASE_ENEMY_HP + (wave_number - 1) * ENEMY_HP_GROWTH
	if is_elite_wave(wave_number):
		result = int(float(result) * ELITE_HP_MULTIPLIER)
	return result


static func get_enemy_damage_for_wave(wave_number: int) -> int:
	var result: int = BASE_ENEMY_DAMAGE + (wave_number - 1) * ENEMY_DAMAGE_GROWTH
	if is_elite_wave(wave_number):
		result += ELITE_DAMAGE_BONUS
	return result


static func is_elite_wave(wave_number: int) -> bool:
	return wave_number in ELITE_WAVES


static func is_boss_wave(wave_number: int) -> bool:
	return wave_number in BOSS_WAVES


static func is_final_boss_wave(wave_number: int) -> bool:
	return wave_number == FINAL_BOSS_WAVE


static func get_boss_profile(wave_number: int) -> Dictionary:
	return (BOSS_PROFILES.get(wave_number, {}) as Dictionary).duplicate(true)


static func get_max_simultaneous_enemies(
	wave_number: int,
	final_boss_wave: int = FINAL_BOSS_WAVE
) -> int:

	if wave_number == final_boss_wave:
		return 1


	if wave_number >= 18:
		return 5


	if wave_number >= 14:
		return 4


	if wave_number >= 10:
		return 3


	if wave_number >= 6:
		return 2


	return 1
