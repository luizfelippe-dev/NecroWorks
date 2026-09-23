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
		"warning_key": "BOSS_FRONT_WARNING",
		"name_key": "ENEMY_GRAVE_MARSHAL",
		"hp": 1050,
		"damage": 18,
		"special_interval": 5.0,
		"special_targets": 3,
		"special_damage": 20,
	},
	15: {
		"id": "arcane_auditor",
		"warning_key": "BOSS_REAR_WARNING",
		"name_key": "ENEMY_ARCANE_AUDITOR",
		"hp": 1650,
		"damage": 24,
		"special_interval": 4.5,
		"special_targets": 4,
		"special_damage": 28,
	},
	20: {
		"id": "foreman",
		"warning_key": "BOSS_CLUSTER_WARNING",
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


static func select_special_targets(
	wave_number: int, origin: Vector2, candidates: Array[Node2D]
) -> Array[Node2D]:
	var targets: Array[Node2D] = []
	for candidate: Node2D in candidates:
		if is_instance_valid(candidate) and not candidate.is_queued_for_deletion():
			targets.append(candidate)
	var center: Vector2 = origin
	if wave_number == 20:
		var largest_cluster: int = -1
		for candidate: Node2D in targets:
			var neighbors: int = 0
			for other: Node2D in targets:
				if candidate.position.distance_squared_to(other.position) <= 180.0 * 180.0:
					neighbors += 1
			if neighbors > largest_cluster:
				largest_cluster = neighbors
				center = candidate.position
	targets.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		var distance_a: float = a.position.distance_squared_to(center)
		var distance_b: float = b.position.distance_squared_to(center)
		if is_equal_approx(distance_a, distance_b):
			return a.get_instance_id() < b.get_instance_id()
		return distance_a > distance_b if wave_number == 15 else distance_a < distance_b
	)
	if wave_number == 20:
		targets = targets.filter(func(unit: Node2D) -> bool:
			return unit.position.distance_squared_to(center) <= 180.0 * 180.0
		)
	var limit: int = int(get_boss_profile(wave_number).get("special_targets", 0))
	if targets.size() > limit:
		targets.resize(limit)
	return targets


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
