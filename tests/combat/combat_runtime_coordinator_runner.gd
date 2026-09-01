extends SceneTree


const CombatRuntimeCoordinator: Script = preload(
	"res://scripts/game/combat_runtime_coordinator.gd"
)


func _initialize() -> void:
	var source := Node2D.new()
	source.position = Vector2(500.0, 500.0)
	var far_unit := Node2D.new()
	far_unit.position = Vector2(100.0, 500.0)
	var near_unit := Node2D.new()
	near_unit.position = Vector2(430.0, 520.0)
	root.add_child(source)
	root.add_child(far_unit)
	root.add_child(near_unit)
	var units: Array[Node2D] = CombatRuntimeCoordinator.get_valid_units([
		[far_unit], [near_unit]
	])
	assert(units.size() == 2)
	assert(CombatRuntimeCoordinator.get_closest_by_axis(source, units, 500.0) == near_unit)
	assert(CombatRuntimeCoordinator.apply_damage(10, 4) == 6)
	assert(CombatRuntimeCoordinator.apply_damage(2, 5) == -3)
	var collection: Array = [near_unit]
	var hp_map: Dictionary = {near_unit: 10}
	var timer_map: Dictionary = {near_unit: 0.5}
	assert(CombatRuntimeCoordinator.erase_runtime_state(
		near_unit, collection, [hp_map, timer_map]
	))
	assert(collection.is_empty() and hp_map.is_empty() and timer_map.is_empty())
	print("COMBAT RUNTIME COORDINATOR VALIDATION: PASS")
	quit()
