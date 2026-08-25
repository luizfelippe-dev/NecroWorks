extends SceneTree


const FORMATION_POLICY: Script = preload(
	"res://scripts/game/combat_formation_policy.gd"
)


func _initialize() -> void:
	assert(FORMATION_POLICY.MAX_UNDEAD == 36)
	assert(FORMATION_POLICY.get_spawn_position(0) == Vector2(250.0, 350.0))
	assert(FORMATION_POLICY.get_spawn_position(5) == Vector2(675.0, 350.0))
	assert(FORMATION_POLICY.get_spawn_position(6) == Vector2(250.0, 435.0))
	assert(FORMATION_POLICY.get_spawn_position(35) == Vector2(675.0, 775.0))
	assert(FORMATION_POLICY.get_spawn_position(-1) == Vector2(250.0, 350.0))

	var front_center: Vector2 = FORMATION_POLICY.get_combat_position(
		Vector2(1000.0, 555.0),
		0
	)
	assert(front_center == Vector2(890.0, 512.5))
	assert(
		FORMATION_POLICY.get_combat_position(Vector2(50.0, 555.0), 0).x
		== FORMATION_POLICY.COMBAT_MIN_X
	)
	var ranged: Vector2 = FORMATION_POLICY.get_ranged_combat_position(
		Vector2(1000.0, 555.0),
		380.0,
		front_center
	)
	assert(ranged == Vector2(620.0, 512.5))

	var ordered_slots: Array[int] = [8, 2, 15]
	assert(FORMATION_POLICY.get_compacted_slot(8, ordered_slots) == 0)
	assert(FORMATION_POLICY.get_compacted_slot(15, ordered_slots) == 2)
	assert(FORMATION_POLICY.get_compacted_slot(4, ordered_slots) == 4)

	print("COMBAT FORMATION POLICY VALIDATION: PASS")
	quit()
