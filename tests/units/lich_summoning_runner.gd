extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
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


	assert(not game.lich_unlocked)
	assert(not game.create_lich())
	game.factory_points = game.LICH_BLUEPRINT_UNLOCK_COST
	assert(game.purchase_lich_blueprint())
	assert(game.lich_unlocked)
	assert(game.factory_points == 0)
	assert(not game.purchase_lich_blueprint())


	game.souls = game.lich_cost + 20
	var army_before: int = game.get_total_undead_count()
	assert(game.create_lich())
	assert(game.liches.size() == 1)
	assert(game.get_total_undead_count() == army_before + 1)
	var lich: UndeadRuntimeUnit = game.liches[0] as UndeadRuntimeUnit
	assert(lich != null)
	assert(lich.unit_type == RECIPE_CATALOG.LICH)
	assert(lich.combat_role == RECIPE_CATALOG.ROLE_SUMMONER)
	assert(lich.get_node("UnitSprite").texture != null)
	assert(lich.ability_timer > 0.0)
	var lich_target_hp: int = int(game.enemy_hps[game.enemy])
	game.lich_attack_enemy(lich)
	assert(int(game.enemy_hps[game.enemy]) == lich_target_hp - lich.damage)
	assert(is_equal_approx(lich.attack_timer, lich.attack_cooldown))


	var souls_before_summon: int = game.souls
	lich.ability_timer = 0.0
	game.update_lich_summons(0.0)
	assert(game.get_temporary_thrall_count() == 1)
	assert(game.souls == souls_before_summon - 1)
	assert(game.total_thralls_summoned == 1)


	game.souls = 100
	while game.get_temporary_thrall_count() < game.get_lich_summon_cap():
		lich.ability_timer = 0.0
		game.update_lich_summons(0.0)
	assert(game.get_temporary_thrall_count() == game.get_lich_summon_cap())
	var souls_at_cap: int = game.souls
	lich.ability_timer = 0.0
	game.update_lich_summons(0.0)
	assert(game.get_temporary_thrall_count() == game.get_lich_summon_cap())
	assert(game.souls == souls_at_cap)
	assert(is_equal_approx(lich.ability_timer, 1.0))


	var first_thrall: UndeadRuntimeUnit = null
	for current_skeleton: Node2D in game.skeletons:
		var runtime: UndeadRuntimeUnit = current_skeleton as UndeadRuntimeUnit
		if runtime != null and runtime.is_temporary:
			first_thrall = runtime
			break
	assert(first_thrall != null)
	assert(first_thrall.unit_type == RECIPE_CATALOG.LICH_THRALL)
	assert(first_thrall.remaining_lifetime == game.get_lich_summon_lifetime())


	var losses_before: int = game.total_skeletons_lost
	var enemy_hp_before: int = int(game.enemy_hps[game.enemy])
	game.reassembly_chance = 1.0
	game.final_service_damage = 999
	game.kill_skeleton(first_thrall)
	assert(game.total_skeletons_lost == losses_before)
	assert(int(game.enemy_hps[game.enemy]) == enemy_hp_before)
	assert(game.get_temporary_thrall_count() == game.get_lich_summon_cap() - 1)


	var expiring_thrall: UndeadRuntimeUnit = null
	for current_skeleton: Node2D in game.skeletons:
		var runtime: UndeadRuntimeUnit = current_skeleton as UndeadRuntimeUnit
		if runtime != null and runtime.is_temporary:
			expiring_thrall = runtime
			break
	assert(expiring_thrall != null)
	expiring_thrall.remaining_lifetime = 0.1
	var expired_before: int = game.total_thralls_expired
	game.update_lich_summons(0.2)
	assert(game.total_thralls_expired == expired_before + 1)


	game.apply_upgrade(game.UPGRADE_GRAVE_CONTRACT)
	game.upgrade_counts[game.UPGRADE_GRAVE_CONTRACT] = 1
	game.apply_upgrade(game.UPGRADE_RAPID_CONJURATION)
	game.upgrade_counts[game.UPGRADE_RAPID_CONJURATION] = 1
	game.apply_upgrade(game.UPGRADE_BOUND_SERVITUDE)
	game.upgrade_counts[game.UPGRADE_BOUND_SERVITUDE] = 1
	game.check_synergy_unlocks()
	assert(game.get_lich_summon_cap() == 8)
	assert(is_equal_approx(game.get_lich_summon_cooldown(), 8.5))
	assert(is_equal_approx(game.get_lich_summon_lifetime(), 19.0))
	assert(game.has_synergy(game.SYNERGY_SOUL_FOUNDRY))


	for current_skeleton: Node2D in game.skeletons.duplicate():
		var runtime: UndeadRuntimeUnit = current_skeleton as UndeadRuntimeUnit
		if runtime != null and runtime.is_temporary:
			game.expire_temporary_thrall(current_skeleton)
	game.souls = 10
	assert(game.try_lich_summon(lich))
	var empowered_thrall: UndeadRuntimeUnit = null
	for current_skeleton: Node2D in game.skeletons:
		var runtime: UndeadRuntimeUnit = current_skeleton as UndeadRuntimeUnit
		if runtime != null and runtime.is_temporary:
			empowered_thrall = runtime
			break
	assert(empowered_thrall != null)
	assert(empowered_thrall.maximum_hp == 55)
	assert(empowered_thrall.damage == 8)


	assert(
		game.factory_lich_button.position.y + game.factory_lich_button.size.y
		<= game.factory_panel.size.y
	)
	assert(game.factory_lich_button.clip_text)
	assert(game.factory_lich_button.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)
	assert(
		game.factory_skeleton_archer_button.position.x
		+ game.factory_skeleton_archer_button.size.x
		<= game.factory_lich_button.position.x
	)
	assert(
		game.factory_lich_button.position.x + game.factory_lich_button.size.x
		<= game.factory_panel.size.x
	)
	assert(
		game.ritual_lich_button.position.y + game.ritual_lich_button.size.y
		<= game.ritual_panel.size.y
	)
	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		game.refresh_localized_ui()
		for key: String in [
			"FACTORY_LICH_BLUEPRINT",
			"RITUAL_LICH",
			"UPGRADE_GRAVE_CONTRACT_NAME",
			"SYNERGY_SOUL_FOUNDRY"
		]:
			assert(TranslationServer.translate(key) != key)


	var lich_losses_before: int = game.total_liches_lost
	game.kill_lich(lich)
	assert(game.liches.is_empty())
	assert(game.total_liches_lost == lich_losses_before + 1)


	print("LICH SUMMONING VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
