extends SceneTree


const ARMY_REGISTRY: Script = preload(
	"res://scripts/game/undead_army_registry.gd"
)


func _initialize() -> void:
	var registry: RefCounted = ARMY_REGISTRY.new()
	assert(registry.get_total_count() == 0)
	assert(registry.get_free_slot() == 0)
	assert(not registry.reserve_slot(-1))
	assert(not registry.reserve_slot(36))
	assert(registry.reserve_slot(0))
	assert(not registry.reserve_slot(0))
	assert(registry.get_free_slot() == 1)

	var skeleton := Node2D.new()
	var zombie := Node2D.new()
	var ghost := Node2D.new()
	var lich := Node2D.new()
	registry.skeletons.append(skeleton)
	registry.zombies.append(zombie)
	registry.ghosts.append(ghost)
	registry.liches.append(lich)
	assert(registry.get_total_count() == 4)

	registry.release_slot(0)
	assert(registry.get_free_slot() == 0)
	registry.reserve_slot(0)
	registry.skeleton_slots[skeleton] = 0
	registry.zombie_slots[zombie] = 1
	registry.clear()
	assert(registry.get_total_count() == 0)
	assert(registry.get_free_slot() == 0)
	assert(registry.skeleton_slots.is_empty())
	assert(registry.zombie_slots.is_empty())

	skeleton.free()
	zombie.free()
	ghost.free()
	lich.free()
	print("UNDEAD ARMY REGISTRY VALIDATION: PASS")
	quit()
