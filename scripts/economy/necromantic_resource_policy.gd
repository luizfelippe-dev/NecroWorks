class_name NecromanticResourcePolicy
extends RefCounted


const BLOOD_SACRIFICE_BASE_COST: int = 3
const BLOOD_FERVOR_BASE_MULTIPLIER: float = 1.25


static func get_kill_rewards(
	archetype_id: String,
	is_elite: bool,
	is_boss: bool,
	total_kills: int,
	extraction_level: int = 0
) -> Vector2i:

	if is_boss:
		return Vector2i(5, 4)


	var blood_gained: int = 1 if is_elite else 0
	var normal_interval: int = maxi(8 - extraction_level * 2, 4)


	if not is_elite and total_kills % normal_interval == 0:
		blood_gained = 1


	var souls_gained: int = 0


	if archetype_id == "mage" and total_kills % 3 == 0:
		souls_gained = 1
	elif archetype_id == "elf" and total_kills % 5 == 0:
		souls_gained = 1


	return Vector2i(blood_gained, souls_gained)


static func get_sacrifice_cost(has_crimson_synergy: bool) -> int:

	return BLOOD_SACRIFICE_BASE_COST - (1 if has_crimson_synergy else 0)


static func get_fervor_multiplier(infusion_level: int) -> float:

	return BLOOD_FERVOR_BASE_MULTIPLIER + 0.10 * float(infusion_level)
