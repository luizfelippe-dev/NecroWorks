extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const RECIPE_CATALOG: Script = preload(
	"res://scripts/game/undead_recipe_catalog.gd"
)


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)


	var skeleton: UndeadRuntimeUnit = game.initial_skeleton as UndeadRuntimeUnit
	assert(skeleton != null)
	assert(skeleton.unit_type == RECIPE_CATALOG.SKELETON_WARRIOR)
	assert(skeleton.production_family == RECIPE_CATALOG.FAMILY_BONE)
	assert(skeleton.combat_role == RECIPE_CATALOG.ROLE_MELEE_DAMAGE)
	assert(skeleton.current_hp == game.skeleton_max_hp)
	assert(skeleton.maximum_hp == game.skeleton_max_hp)
	assert(skeleton.formation_slot == 0)
	assert(game.skeleton_hps[skeleton] == skeleton.current_hp)
	assert(game.skeleton_slots[skeleton] == skeleton.formation_slot)


	game.flesh = game.zombie_cost
	assert(game.create_zombie())
	var zombie: UndeadRuntimeUnit = game.zombies.back() as UndeadRuntimeUnit
	assert(zombie != null)
	assert(zombie.unit_type == RECIPE_CATALOG.ZOMBIE_TANK)
	assert(zombie.production_family == RECIPE_CATALOG.FAMILY_FLESH)
	assert(zombie.combat_role == RECIPE_CATALOG.ROLE_FRONTLINE_TANK)
	assert(zombie.current_hp == game.zombie_max_hp)
	assert(game.zombie_hps[zombie] == zombie.current_hp)


	game.damage_undead(skeleton, 13, "TEST")
	assert(skeleton.current_hp == game.skeleton_max_hp - 13)
	assert(game.skeleton_hps[skeleton] == skeleton.current_hp)
	game.damage_undead(zombie, 17, "TEST")
	assert(zombie.current_hp == game.zombie_max_hp - 17)
	assert(game.zombie_hps[zombie] == zombie.current_hp)


	var damaged_skeleton_hp: int = skeleton.current_hp
	game.apply_upgrade(game.UPGRADE_BONE_PLATING)
	assert(skeleton.maximum_hp == game.skeleton_max_hp)
	assert(skeleton.current_hp == damaged_skeleton_hp + 25)
	assert(game.skeleton_hps[skeleton] == skeleton.current_hp)
	game.apply_upgrade(game.UPGRADE_SHARPENED_BONES)
	assert(skeleton.damage == game.skeleton_damage)
	assert(skeleton.attack_cooldown == game.skeleton_attack_cooldown)


	var damaged_zombie_hp: int = zombie.current_hp
	game.increase_zombie_max_hp(40)
	assert(zombie.maximum_hp == game.zombie_max_hp)
	assert(zombie.current_hp == damaged_zombie_hp + 40)
	assert(game.zombie_hps[zombie] == zombie.current_hp)


	var warrior_recipe: Dictionary = RECIPE_CATALOG.get_recipe(
		RECIPE_CATALOG.SKELETON_WARRIOR
	)
	assert(warrior_recipe.resource == "bones")
	assert(warrior_recipe.base_cost == game.skeleton_cost)
	assert(warrior_recipe.unlocked_by_default)
	var archer_recipe: Dictionary = RECIPE_CATALOG.get_recipe(
		RECIPE_CATALOG.SKELETON_ARCHER
	)
	assert(archer_recipe.resource == "bones")
	assert(archer_recipe.base_cost == 8)
	assert(not archer_recipe.unlocked_by_default)


	print("UNDEAD RUNTIME VALIDATION: PASS")
	game.queue_free()
	quit()
