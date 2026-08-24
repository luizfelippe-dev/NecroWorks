extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const ENEMY_POLICY: Script = preload(
	"res://scripts/game/enemy_combat_policy.gd"
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
	assert(game.is_elite_wave(14))
	assert(not game.is_elite_wave(game.BOSS_WAVE))
	game.start_wave(14)
	await process_frame
	game.set_process(false)


	var elite_warrior: Node2D = null
	var elite_mage: Node2D = null
	var elite_elf: Node2D = null
	for current_enemy: Node2D in game.enemies:
		assert(bool(game.enemy_elite_flags.get(current_enemy, false)))
		assert(current_enemy.get_node_or_null("EliteTraitLabel") != null)
		match str(game.enemy_types.get(current_enemy, "")):
			"human_warrior":
				elite_warrior = current_enemy
			"mage":
				elite_mage = current_enemy
			"elf":
				elite_elf = current_enemy
	assert(elite_warrior != null and elite_mage != null and elite_elf != null)


	var warrior_enemy_hp: int = int(game.enemy_hps[elite_warrior])
	var remaining_warrior_hp: int = game.apply_damage_to_enemy(
		elite_warrior,
		10
	)
	assert(remaining_warrior_hp == warrior_enemy_hp - 8)


	game.skeleton_archer_unlocked = true
	assert(game.create_free_skeleton_archer("ELITE TEST"))
	assert(game.create_free_zombie("ELITE TEST"))
	var skeleton: UndeadRuntimeUnit = game.skeletons[0]
	var archer: UndeadRuntimeUnit = game.skeletons[1]
	var zombie: UndeadRuntimeUnit = game.zombies[0]
	skeleton.position = Vector2(700.0, 520.0)
	archer.position = Vector2(740.0, 500.0)
	zombie.position = Vector2(660.0, 560.0)


	game.enemy_damages[elite_mage] = 20
	game.enemy_attack_counts[elite_mage] = 1
	var skeleton_hp: int = skeleton.current_hp
	var archer_hp: int = archer.current_hp
	game.perform_enemy_attack(elite_mage, skeleton)
	assert(skeleton.current_hp == skeleton_hp - 20)
	assert(archer.current_hp == archer_hp - 13)
	assert(
		archer.attack_timer
		>= ENEMY_POLICY.ELITE_MAGE_SUPPRESSION_DELAY
	)


	game.enemy_damages[elite_elf] = 20
	game.enemy_attack_counts[elite_elf] = 2
	elite_elf.position = Vector2(720.0, 555.0)
	zombie.position.x = 710.0
	archer.position.x = 500.0
	assert(game.get_enemy_combat_target(elite_elf) == archer)
	var archer_before_precision: int = archer.current_hp
	game.perform_enemy_attack(elite_elf, archer)
	assert(archer.current_hp == archer_before_precision - 30)


	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		for key: String in [
			"ENEMY_ELITE_NAME",
			"ENEMY_ELITE_TRAIT_BULWARK",
			"ENEMY_ELITE_TRAIT_OVERCHARGED",
			"ENEMY_ELITE_TRAIT_DEADEYE",
			"ENEMY_ABILITY_ELITE_ARCANE_BURST",
			"ENEMY_ABILITY_ELITE_PRECISION_SHOT"
		]:
			assert(TranslationServer.translate(key) != key)


	print("ENEMY ELITE VARIANT VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
