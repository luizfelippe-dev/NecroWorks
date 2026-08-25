extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const WAVE_POLICY: Script = preload(
	"res://scripts/game/enemy_wave_policy.gd"
)


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)

	assert(game.BOSS_WAVES == PackedInt32Array([10, 15, 20]))
	assert(WAVE_POLICY.get_enemies_for_wave(1) == 5)
	assert(WAVE_POLICY.get_enemies_for_wave(5) == 5)
	assert(WAVE_POLICY.get_enemies_for_wave(10) == 1)
	assert(WAVE_POLICY.get_enemy_hp_for_wave(5) == 251)
	assert(WAVE_POLICY.get_enemy_damage_for_wave(5) == 14)
	assert(WAVE_POLICY.get_max_simultaneous_enemies(10) == 3)
	assert(WAVE_POLICY.get_max_simultaneous_enemies(15) == 4)
	assert(game.get_boss_profile_for_wave(10).id == "grave_marshal")
	assert(game.get_boss_profile_for_wave(15).id == "arcane_auditor")
	assert(game.get_boss_profile_for_wave(20).id == "foreman")
	assert(game.get_boss_profile_for_wave(10).hp < game.get_boss_profile_for_wave(15).hp)
	assert(game.get_boss_profile_for_wave(15).hp < game.get_boss_profile_for_wave(20).hp)
	var mutable_profile: Dictionary = game.get_boss_profile_for_wave(10)
	mutable_profile.hp = 1
	assert(game.get_boss_profile_for_wave(10).hp == 1050)

	game.start_wave(10)
	await process_frame
	game.set_process(false)
	assert(game.boss_active and game.enemies.size() == 1)
	assert(game.enemy_types[game.enemies[0]] == "grave_marshal")
	game.kill_enemy(game.enemies[0])
	assert(not game.run_finished)
	assert(game.wave_transition_in_progress)
	assert(game.corpses.size() == 1)
	assert(bool(game.corpses[0].get_meta("source_boss", false)))

	game.hide_upgrade_selection()
	game.wave_transition_in_progress = false
	game.start_wave(15)
	await process_frame
	game.set_process(false)
	assert(game.boss_active and game.enemies.size() == 1)
	assert(game.enemy_types[game.enemies[0]] == "arcane_auditor")
	game.kill_enemy(game.enemies[0])
	assert(not game.run_finished)
	assert(game.wave_transition_in_progress)

	game.hide_upgrade_selection()
	game.wave_transition_in_progress = false
	game.start_wave(20)
	await process_frame
	game.set_process(false)
	assert(game.boss_active and game.enemies.size() == 1)
	assert(game.enemy_types[game.enemies[0]] == "foreman")
	game.kill_enemy(game.enemies[0])
	assert(game.run_finished and game.run_won)

	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		assert(TranslationServer.translate("ENEMY_GRAVE_MARSHAL") != "ENEMY_GRAVE_MARSHAL")
		assert(TranslationServer.translate("ENEMY_ARCANE_AUDITOR") != "ENEMY_ARCANE_AUDITOR")

	TranslationServer.set_locale(original_locale)
	print("THREE-BOSS PROGRESSION VALIDATION: PASS")
	game.queue_free()
	quit()
