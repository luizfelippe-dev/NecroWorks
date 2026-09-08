extends SceneTree


const EVALUATOR: Script = preload("res://scripts/game/run_recovery_evaluator.gd")


func _initialize() -> void:
	var base: Dictionary = {
		"active_army": 0,
		"queued_undead": 0,
		"recoverable_corpses": 0,
		"available_capacity": 36,
		"resources": {"bones": 0, "flesh": 0, "blood": 0, "souls": 0},
		"pending_resources": {},
		"recipes": [
			{"available": true, "resource": "bones", "cost": 5},
			{"available": true, "resource": "flesh", "cost": 6},
			{"available": true, "resource": "souls", "cost": 4},
			{"available": false, "resource": "souls", "cost": 2},
		],
		"fusion_routes": [
			{
				"available": true,
				"costs": {"blood": 2, "souls": 3},
			},
		],
	}
	assert(not EVALUATOR.can_recover(base))

	for field: String in ["active_army", "queued_undead", "recoverable_corpses"]:
		var state: Dictionary = base.duplicate(true)
		state[field] = 1
		assert(EVALUATOR.can_recover(state))

	for resource_case: Dictionary in [
		{"bones": 5}, {"flesh": 6}, {"souls": 4},
	]:
		var state: Dictionary = base.duplicate(true)
		for resource_id: String in resource_case:
			state.resources[resource_id] = resource_case[resource_id]
		assert(EVALUATOR.can_recover(state))

	var locked_recipe: Dictionary = base.duplicate(true)
	locked_recipe.resources.souls = 2
	assert(not EVALUATOR.can_recover(locked_recipe))
	locked_recipe.recipes[3].available = true
	assert(EVALUATOR.can_recover(locked_recipe))

	var fusion: Dictionary = base.duplicate(true)
	fusion.resources.blood = 2
	fusion.resources.souls = 3
	assert(EVALUATOR.can_recover(fusion))
	var pending_fusion: Dictionary = base.duplicate(true)
	pending_fusion.resources.souls = 3
	pending_fusion.pending_resources.blood = 2
	assert(EVALUATOR.can_recover(pending_fusion))

	var no_capacity: Dictionary = base.duplicate(true)
	no_capacity.resources.bones = 100
	no_capacity.available_capacity = 0
	assert(not EVALUATOR.can_recover(no_capacity))

	print("RUN RECOVERY EVALUATOR VALIDATION: PASS")
	quit()
