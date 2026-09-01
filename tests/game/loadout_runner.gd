extends SceneTree


const GAME_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const META_UNLOCKS: Script = preload("res://scripts/game/meta_unlock_catalog.gd")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	var base_enemy_damage: int = int(game.enemy_damages.get(game.enemy, 0))
	game.configure_meta_progression({
		META_UNLOCKS.OSSUARY_ENGINEER: true,
		META_UNLOCKS.NIGHT_SHIFT: true,
	}, {
		"operator": "ossuary_engineer",
		"modifier": "night_shift",
	})
	assert(game.selected_operator == "ossuary_engineer")
	assert(game.selected_starting_modifier == "night_shift")
	assert(game.bones == 5)
	assert(game.factory_points == 2)
	assert(game.skeleton_cost == 4)
	assert(game.zombie_cost == 7)
	assert(int(game.enemy_damages.get(game.enemy, 0)) == base_enemy_damage + 2)
	assert(game.build_checkpoint_state().meta_loadout.operator == "ossuary_engineer")
	print("META LOADOUT VALIDATION: PASS")
	quit()
