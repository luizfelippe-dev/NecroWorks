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


static func get_replenishment_plan(
	deficits: Vector2i,
	affordable_skeletons: int,
	affordable_zombies: int,
	available_capacity: int,
	priority: String
) -> Vector2i:

	var skeleton_limit: int = mini(
		maxi(deficits.x, 0),
		maxi(affordable_skeletons, 0)
	)
	var zombie_limit: int = mini(
		maxi(deficits.y, 0),
		maxi(affordable_zombies, 0)
	)
	var capacity: int = maxi(available_capacity, 0)
	var plan: Vector2i = Vector2i.ZERO


	if priority == PRIORITY_SKELETONS:
		plan.x = mini(skeleton_limit, capacity)
		capacity -= plan.x
		plan.y = mini(zombie_limit, capacity)
		return plan


	if priority == PRIORITY_ZOMBIES:
		plan.y = mini(zombie_limit, capacity)
		capacity -= plan.y
		plan.x = mini(skeleton_limit, capacity)
		return plan


	while capacity > 0 and (
		plan.x < skeleton_limit or plan.y < zombie_limit
	):
		if plan.x < skeleton_limit:
			plan.x += 1
			capacity -= 1


		if capacity > 0 and plan.y < zombie_limit:
			plan.y += 1
			capacity -= 1


	return plan
