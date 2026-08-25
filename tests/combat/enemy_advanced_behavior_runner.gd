extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
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


	game.skeleton_archer_unlocked = true
	assert(game.create_free_skeleton_archer("TEST"))
	assert(game.create_free_zombie("TEST"))
	var warrior: UndeadRuntimeUnit = game.skeletons[0] as UndeadRuntimeUnit
	var archer: UndeadRuntimeUnit = game.skeletons[1] as UndeadRuntimeUnit
	var zombie: UndeadRuntimeUnit = game.zombies[0] as UndeadRuntimeUnit
	assert(warrior != null and archer != null and zombie != null)
	warrior.position = Vector2(700.0, 520.0)
	archer.position = Vector2(760.0, 500.0)
	zombie.position = Vector2(650.0, 560.0)


	var ability_events: Array[Dictionary] = []
	game.enemy_ability_triggered.connect(
		func(
			archetype_id: String,
			ability_id: String,
			target_count: int
		) -> void:
			ability_events.append(
				{
					"archetype": archetype_id,
					"ability": ability_id,
					"targets": target_count,
				}
			)
	)


	var attacker: Node2D = game.enemy
	game.enemy_types[attacker] = "mage"
	game.enemy_damages[attacker] = 20
	game.enemy_attack_counts[attacker] = 2
	var warrior_hp: int = warrior.current_hp
	var archer_hp: int = archer.current_hp
	var zombie_hp: int = zombie.current_hp
	game.perform_enemy_attack(attacker, warrior)
	assert(warrior.current_hp == warrior_hp - 20)
	assert(archer.current_hp == archer_hp - 10)
	assert(zombie.current_hp == zombie_hp - 10)
	assert(warrior.attack_timer >= ENEMY_POLICY.MAGE_SUPPRESSION_DELAY)
	assert(archer.attack_timer >= ENEMY_POLICY.MAGE_SUPPRESSION_DELAY)
	assert(zombie.attack_timer >= ENEMY_POLICY.MAGE_SUPPRESSION_DELAY)
	assert(ability_events.size() == 1)
	assert(ability_events[0]["ability"] == "arcane_burst")
	assert(ability_events[0]["targets"] == 3)


	game.enemy_types[attacker] = "elf"
	game.enemy_attack_counts[attacker] = 3
	attacker.position = Vector2(720.0, 555.0)
	zombie.position.x = 710.0
	archer.position.x = 500.0
	var precision_target: Node2D = game.get_enemy_combat_target(attacker)
	assert(precision_target == archer)
	var archer_before_precision: int = archer.current_hp
	game.perform_enemy_attack(attacker, precision_target)
	assert(
		archer.current_hp
		== archer_before_precision - ENEMY_POLICY.get_precision_damage(20)
	)
	assert(ability_events.size() == 2)
	assert(ability_events[1]["ability"] == "precision_shot")


	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		for key: String in [
			"ENEMY_ABILITY_ARCANE_BURST",
			"ENEMY_ABILITY_PRECISION_SHOT"
		]:
			assert(TranslationServer.translate(key) != key)


	print("ENEMY ADVANCED BEHAVIOR VALIDATION: PASS")
	TranslationServer.set_locale(original_locale)
	game.queue_free()
	quit()
