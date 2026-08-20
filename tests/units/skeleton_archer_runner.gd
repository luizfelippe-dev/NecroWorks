extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const RECIPE_CATALOG: Script = preload(
	"res://scripts/game/undead_recipe_catalog.gd"
)


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	TranslationServer.set_locale("pt_BR")
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)


	assert(not game.skeleton_archer_unlocked)
	assert(not game.enqueue_skeleton_archer_production(1))
	assert(game.create_skeleton_archer_button.disabled)
	game.factory_points = game.SKELETON_ARCHER_UNLOCK_COST
	assert(game.purchase_skeleton_archer_blueprint())
	assert(game.skeleton_archer_unlocked)
	assert(game.factory_points == 0)
	assert(not game.purchase_skeleton_archer_blueprint())
	assert(
		game.factory_skeleton_archer_button.position.y
		+ game.factory_skeleton_archer_button.size.y
		<= game.factory_panel.size.y
	)


	game.bones = game.skeleton_archer_cost * 2
	assert(game.enqueue_skeleton_archer_production(2))
	assert(game.bones == 0)
	assert(game.skeleton_production_queue.size() == 1)
	assert(game.skeleton_production_queue[0].unit_type == "skeleton_archer")
	assert(game.get_total_queued_undead() == 2)


	game.skeleton_assembler_timer = 0.0
	game.update_undead_production_queues(1.0)
	game.update_undead_production_queues(1.0)
	assert(game.get_skeleton_archer_count() == 2)
	assert(game.get_total_queued_undead() == 0)


	var archer: UndeadRuntimeUnit = null
	for current_skeleton: Node2D in game.skeletons:
		var runtime: UndeadRuntimeUnit = current_skeleton as UndeadRuntimeUnit
		if runtime != null and runtime.unit_type == RECIPE_CATALOG.SKELETON_ARCHER:
			archer = runtime
			break


	assert(archer != null)
	assert(archer.production_family == RECIPE_CATALOG.FAMILY_BONE)
	assert(archer.combat_role == RECIPE_CATALOG.ROLE_RANGED_DAMAGE)
	assert(archer.maximum_hp == game.skeleton_archer_max_hp)
	assert(archer.damage == game.skeleton_archer_damage)
	assert(is_equal_approx(archer.attack_range, game.skeleton_archer_attack_range))
	assert(archer.get_node("UnitSprite").texture != null)


	var ranged_target: Vector2 = game.get_bone_unit_combat_target_position(
		archer,
		archer.formation_slot
	)
	var melee_target: Vector2 = game.get_combat_target_position(0)
	assert(ranged_target.x < melee_target.x)


	var enemy_before: int = int(game.enemy_hps[game.enemy])
	game.attack_enemy(archer)
	assert(int(game.enemy_hps[game.enemy]) == enemy_before - archer.damage)
	assert(is_equal_approx(archer.attack_timer, archer.attack_cooldown))


	var archer_hp_before: int = archer.current_hp
	game.apply_upgrade(game.UPGRADE_BONE_PLATING)
	assert(archer.maximum_hp == game.skeleton_archer_max_hp)
	assert(archer.current_hp == archer_hp_before + 25)
	assert(int(game.skeleton_hps[archer]) == archer.current_hp)


	game.upgrade_counts[game.UPGRADE_HEAVY_BONES] = 1
	game.upgrade_counts[game.UPGRADE_DEATH_MARCH] = 1
	game.check_synergy_unlocks()
	assert(game.has_synergy(game.SYNERGY_OSSUARY_BALLISTICS))
	assert(
		is_equal_approx(
			archer.attack_range,
			game.skeleton_archer_attack_range
			+ game.OSSUARY_BALLISTICS_RANGE_BONUS
		)
	)


	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		game.refresh_localized_ui()
		for key: String in [
			"PRODUCTION_QUEUE_ARCHER",
			"PRODUCTION_ARCHER_LOCKED",
			"FACTORY_ARCHER_BLUEPRINT",
			"FACTORY_ARCHER_UNLOCK",
			"FACTORY_ARCHER_UNLOCKED",
			"SYNERGY_OSSUARY_BALLISTICS"
		]:
			assert(TranslationServer.translate(key) != key)


	print("SKELETON ARCHER VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
