class_name ArmyDoctrinePolicy
extends RefCounted


const PRIORITY_BALANCED: String = "balanced"
const PRIORITY_SKELETONS: String = "skeletons_first"
const PRIORITY_ZOMBIES: String = "zombies_first"

const VALID_PRIORITIES: Array[String] = [
	PRIORITY_BALANCED,
	PRIORITY_SKELETONS,
	PRIORITY_ZOMBIES
]


static func is_valid_configuration(
	target_skeletons: int,
	target_zombies: int,
	bones_reserve: int,
	flesh_reserve: int,
	priority: String,
	maximum_undead: int
) -> bool:

	if target_skeletons < 0 or target_zombies < 0:
		return false


	if target_skeletons + target_zombies > maximum_undead:
		return false


	if bones_reserve < 0 or flesh_reserve < 0:
		return false


	return priority in VALID_PRIORITIES


static func get_deficits(
	target_skeletons: int,
	target_zombies: int,
	current_skeletons: int,
	current_zombies: int
) -> Vector2i:

	return Vector2i(
		maxi(target_skeletons - current_skeletons, 0),
		maxi(target_zombies - current_zombies, 0)
	)


static func can_spend_above_reserve(
	available_resource: int,
	unit_cost: int,
	reserve: int
) -> bool:

	return available_resource - unit_cost >= reserve


static func get_ordered_unit_types(priority: String) -> Array[String]:

	match priority:
		PRIORITY_SKELETONS:
			return ["skeleton", "zombie"]
		PRIORITY_ZOMBIES:
			return ["zombie", "skeleton"]
		_:
			return ["balanced"]
