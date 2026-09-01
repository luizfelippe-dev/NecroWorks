extends SceneTree


const GAME_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const UNLOCK_CATALOG: Script = preload("res://scripts/game/meta_unlock_catalog.gd")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	LocalizationService.set_locale("pt-BR")
	var game: Node = GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.factory_points = 100
	game.configure_meta_progression({})
	assert(game.factory_skeleton_archer_button.disabled)
	assert(game.factory_skeleton_archer_button.text.contains("PROJETO PERMANENTE"))
	assert(not game.purchase_automatic_corpse_collection())
	assert(not game.purchase_hematic_press())
	assert(not game.purchase_soul_extractor())
	assert(not game.purchase_skeleton_archer_blueprint())
	assert(not game.purchase_lich_blueprint())
	var unlocks: Dictionary = {}
	for unlock_id: String in UNLOCK_CATALOG.UNLOCK_IDS:
		unlocks[unlock_id] = true
	game.configure_meta_progression(unlocks)
	assert(game.purchase_automatic_corpse_collection())
	assert(game.purchase_hematic_press())
	assert(game.purchase_soul_extractor())
	assert(game.purchase_skeleton_archer_blueprint())
	assert(game.purchase_lich_blueprint())
	TranslationServer.set_locale(original_locale)
	print("META UNLOCK GAMEPLAY VALIDATION: PASS")
	quit()
