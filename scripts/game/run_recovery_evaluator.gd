class_name RunRecoveryEvaluator
extends RefCounted


static func can_recover(state: Dictionary) -> bool:
	if int(state.get("active_army", 0)) > 0:
		return true
	if int(state.get("queued_undead", 0)) > 0:
		return true
	if int(state.get("recoverable_corpses", 0)) > 0:
		return true
	if int(state.get("available_capacity", 0)) <= 0:
		return false

	var resources: Dictionary = state.get("resources", {}) as Dictionary
	var recipes: Array = state.get("recipes", []) as Array
	for recipe_value: Variant in recipes:
		if not recipe_value is Dictionary:
			continue
		var recipe: Dictionary = recipe_value as Dictionary
		if not bool(recipe.get("available", false)):
			continue
		var resource_id: String = str(recipe.get("resource", ""))
		var cost: int = int(recipe.get("cost", -1))
		if resource_id.is_empty() or cost < 0:
			continue
		if int(resources.get(resource_id, 0)) >= cost:
			return true

	var pending_resources: Dictionary = (
		state.get("pending_resources", {}) as Dictionary
	)
	var fusion_routes: Array = state.get("fusion_routes", []) as Array
	for route_value: Variant in fusion_routes:
		if not route_value is Dictionary:
			continue
		var route: Dictionary = route_value as Dictionary
		if not bool(route.get("available", false)):
			continue
		var costs: Dictionary = route.get("costs", {}) as Dictionary
		var affordable: bool = true
		for resource_id_value: Variant in costs:
			var resource_id: String = str(resource_id_value)
			var total_available: int = (
				int(resources.get(resource_id, 0))
				+ int(pending_resources.get(resource_id, 0))
			)
			if total_available < int(costs[resource_id_value]):
				affordable = false
				break
		if affordable:
			return true
	return false
