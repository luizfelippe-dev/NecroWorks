extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const FUSIONS: Script = preload("res://scripts/game/fusion_recipe_catalog.gd")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)

	assert(FUSIONS.get_recipe_ids().size() == 2)
	assert(not game.execute_fusion_recipe("missing_recipe"))
	var starting_bones: int = game.bones
	var starting_flesh: int = game.flesh
	assert(not game.execute_fusion_recipe(FUSIONS.OSSUARY_ALLOY))
	assert(game.bones == starting_bones and game.flesh == starting_flesh)

	game.bones = 12
	game.flesh = 6
	var points_before: int = game.factory_points
	assert(game.execute_fusion_recipe(FUSIONS.OSSUARY_ALLOY))
	assert(game.bones == 0 and game.flesh == 0)
	assert(game.factory_points == points_before + 2)

	game.blood = 2
	game.souls = 3
	var ghosts_before: int = game.ghosts.size()
	assert(game.execute_fusion_recipe(FUSIONS.SOULBOUND_MUSTER))
	assert(game.blood == 0 and game.souls == 0)
	assert(game.ghosts.size() == ghosts_before + 1)

	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		for key: String in [
			"FUSION_NAV", "FUSION_TITLE", "FUSION_OSSUARY_NAME",
			"FUSION_OSSUARY_DESC", "FUSION_SOULBOUND_NAME",
			"FUSION_SOULBOUND_DESC"
		]:
			assert(TranslationServer.translate(key) != key)

	TranslationServer.set_locale(original_locale)
	print("NECROMANTIC FUSION RECIPE VALIDATION: PASS")
	game.queue_free()
	quit()
