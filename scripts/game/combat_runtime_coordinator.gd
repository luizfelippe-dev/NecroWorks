class_name CombatRuntimeCoordinator
extends RefCounted


static func get_valid_units(groups: Array) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for group_value: Variant in groups:
		for unit_value: Variant in group_value as Array:
			var unit: Node2D = unit_value as Node2D
			if is_instance_valid(unit):
				result.append(unit)
	return result


static func get_closest_by_axis(
	source: Node2D,
	candidates: Array[Node2D],
	reference_y: float
) -> Node2D:
	if not is_instance_valid(source):
		return null
	var closest: Node2D = null
	var best_horizontal: float = INF
	var best_vertical: float = INF
	for candidate: Node2D in candidates:
		if not is_instance_valid(candidate):
			continue
		var horizontal: float = absf(source.position.x - candidate.position.x)
		var vertical: float = absf(reference_y - candidate.position.y)
		if (
			horizontal < best_horizontal
			or (is_equal_approx(horizontal, best_horizontal) and vertical < best_vertical)
		):
			closest = candidate
			best_horizontal = horizontal
			best_vertical = vertical
	return closest


static func apply_damage(current_hp: int, damage_amount: int) -> int:
	return current_hp - maxi(damage_amount, 0)


static func erase_runtime_state(
	target: Node,
	collection: Array,
	state_maps: Array
) -> bool:
	if target == null or not collection.has(target):
		return false
	collection.erase(target)
	for state_map_value: Variant in state_maps:
		var state_map: Dictionary = state_map_value as Dictionary
		state_map.erase(target)
	return true
