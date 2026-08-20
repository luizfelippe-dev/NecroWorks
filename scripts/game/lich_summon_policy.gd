class_name LichSummonPolicy
extends RefCounted


const BASE_GLOBAL_CAP: int = 6
const BASE_COOLDOWN: float = 10.0
const BASE_LIFETIME: float = 15.0
const BASE_SOUL_COST: int = 1


static func can_summon(
	available_souls: int,
	current_thralls: int,
	global_cap: int,
	available_army_capacity: int
) -> bool:

	return (
		available_souls >= BASE_SOUL_COST
		and current_thralls < global_cap
		and available_army_capacity > 0
	)


static func get_effective_cap(bonus: int) -> int:

	return maxi(BASE_GLOBAL_CAP + bonus, 0)


static func get_effective_cooldown(reduction: float) -> float:

	return maxf(BASE_COOLDOWN - reduction, 3.0)


static func get_effective_lifetime(bonus: float) -> float:

	return maxf(BASE_LIFETIME + bonus, 1.0)
