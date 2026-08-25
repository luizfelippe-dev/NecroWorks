extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const RESOURCE_POLICY: Script = preload(
	"res://scripts/economy/necromantic_resource_policy.gd"
)


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.skeleton_archer_unlocked = true
	game.current_wave = 12

	var catalog: Array[String] = [
		game.UPGRADE_SHARPENED_BONES, game.UPGRADE_BONE_PLATING,
		game.UPGRADE_EFFICIENT_RECYCLING, game.UPGRADE_RAPID_ASSAULT,
		game.UPGRADE_DEATH_MARCH, game.UPGRADE_MASS_PRODUCTION,
		game.UPGRADE_HEAVY_BONES, game.UPGRADE_BONE_HARVEST,
		game.UPGRADE_REASSEMBLY, game.UPGRADE_FINAL_SERVICE,
		game.UPGRADE_ROTTEN_BULK, game.UPGRADE_GRAVE_HUNGER,
		game.UPGRADE_DEAD_WEIGHT, game.UPGRADE_CARRION_RECOVERY,
		game.UPGRADE_GRAVE_CONTRACT, game.UPGRADE_RAPID_CONJURATION,
		game.UPGRADE_BOUND_SERVITUDE, game.UPGRADE_EMERGENCY_RECLAMATION,
		game.UPGRADE_FLETCHERS_MARK, game.UPGRADE_HOLLOW_SHAFTS,
		game.UPGRADE_OSSUARY_SCOPE, game.UPGRADE_STITCHED_HIDE,
		game.UPGRADE_SEPTIC_STRIKES, game.UPGRADE_GRAVE_MOMENTUM,
		game.UPGRADE_SPECTRAL_VOLTAGE, game.UPGRADE_PHASE_CYCLE,
		game.UPGRADE_FLESH_PRESERVATION, game.UPGRADE_SOUL_SIPHON,
		game.UPGRADE_CRIMSON_TITHE, game.UPGRADE_FORBIDDEN_PATENT,
	]
	var unique_catalog: Dictionary = {}
	for upgrade_id: String in catalog:
		unique_catalog[upgrade_id] = true
	assert(catalog.size() == 30)
	assert(unique_catalog.size() == 30)
	var pool: Array[String] = game.get_upgrade_pool()
	for expected_id: String in [
		game.UPGRADE_FLETCHERS_MARK,
		game.UPGRADE_STITCHED_HIDE,
		game.UPGRADE_SPECTRAL_VOLTAGE,
		game.UPGRADE_FLESH_PRESERVATION,
		game.UPGRADE_CRIMSON_TITHE,
		game.UPGRADE_FORBIDDEN_PATENT,
	]:
		assert(expected_id in pool)

	var archer_damage_before: int = game.skeleton_archer_damage
	var zombie_hp_before: int = game.zombie_max_hp
	var flesh_yield_before: int = game.flesh_per_corpse
	game.apply_upgrade(game.UPGRADE_FLETCHERS_MARK)
	game.apply_upgrade(game.UPGRADE_STITCHED_HIDE)
	game.apply_upgrade(game.UPGRADE_SPECTRAL_VOLTAGE)
	game.apply_upgrade(game.UPGRADE_FLESH_PRESERVATION)
	assert(game.skeleton_archer_damage == archer_damage_before + 4)
	assert(game.zombie_max_hp == zombie_hp_before + 30)
	assert(game.ghost_damage_bonus == 4)
	assert(game.flesh_per_corpse == flesh_yield_before + 1)

	game.upgrade_counts[game.UPGRADE_SOUL_SIPHON] = 1
	game.soul_yield_bonus = 1
	var expected_arcane: Vector2i = RESOURCE_POLICY.get_kill_rewards(
		"mage", false, false, 0, game.blood_extraction_level
	)
	var actual_arcane: Vector2i = game.apply_necromantic_kill_rewards(
		"mage", false, false
	)
	assert(actual_arcane.y == expected_arcane.y + 1)

	game.upgrade_counts[game.UPGRADE_CRIMSON_TITHE] = 1
	game.total_enemies_killed = 5
	var expected_tithe: Vector2i = RESOURCE_POLICY.get_kill_rewards(
		"human_warrior", false, false, 5, game.blood_extraction_level
	)
	var actual_tithe: Vector2i = game.apply_necromantic_kill_rewards(
		"human_warrior", false, false
	)
	assert(actual_tithe.x == expected_tithe.x + 1)

	game.upgrade_counts[game.UPGRADE_FORBIDDEN_PATENT] = 1
	var factory_before: int = game.factory_points
	assert(game.award_factory_points_for_wave(3) == 2)
	assert(game.factory_points == factory_before + 2)
	assert(game.is_rare_upgrade(game.UPGRADE_EMERGENCY_RECLAMATION))
	assert(game.is_rare_upgrade(game.UPGRADE_CRIMSON_TITHE))
	assert(game.is_rare_upgrade(game.UPGRADE_FORBIDDEN_PATENT))

	LocalizationService.set_locale("pt-BR")
	assert(game.get_upgrade_name(game.UPGRADE_CRIMSON_TITHE).contains("RARO"))
	assert(game.get_upgrade_description(game.UPGRADE_FLETCHERS_MARK).contains("+4"))
	assert(game.get_upgrade_name(game.UPGRADE_SHARPENED_BONES) == "Ossos Afiados")
	assert(game.get_upgrade_description(game.UPGRADE_CARRION_RECOVERY).contains("Zumbis"))
	assert(game.get_upgrade_status(game.UPGRADE_BONE_PLATING).contains("PV Máximo"))
	assert(game.get_synergy_description(game.SYNERGY_RECYCLING_PLANT).contains("Reciclagem"))
	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		for upgrade_id: String in catalog:
			var prefix: String = "UPGRADE_" + upgrade_id.to_upper()
			assert(TranslationServer.translate(prefix + "_NAME") != prefix + "_NAME")
			assert(TranslationServer.translate(prefix + "_DESC") != prefix + "_DESC")
	TranslationServer.set_locale(original_locale)
	print("EXPANDED 30-UPGRADE CATALOG VALIDATION: PASS")
	game.queue_free()
	quit()
