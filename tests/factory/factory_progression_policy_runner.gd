extends SceneTree


const POLICY: Script = preload("res://scripts/factory/factory_progression_policy.gd")


func _initialize() -> void:
	assert(POLICY.get_queue_upgrade_cost(0) == 1)
	assert(POLICY.get_queue_upgrade_cost(2) == 3)
	assert(POLICY.get_speed_upgrade_cost(1) == 2)
	assert(POLICY.get_efficiency_upgrade_cost(2) == 4)
	assert(POLICY.get_processor_capacity(0) == 5)
	assert(POLICY.get_processor_capacity(3) == 11)
	assert(is_equal_approx(POLICY.get_processor_cycle_seconds(3), 0.35))
	assert(POLICY.get_hematic_flesh_cost(12, 2, false) == 8)
	assert(POLICY.get_hematic_flesh_cost(12, 2, true) == 6)
	assert(is_equal_approx(POLICY.get_soul_extractor_cycle_seconds(2.5, 3), 1.75))
	print("FACTORY PROGRESSION POLICY VALIDATION: PASS")
	quit()
