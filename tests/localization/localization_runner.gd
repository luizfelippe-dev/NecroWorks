extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const LOCALIZATION_SERVICE: Script = preload(
	"res://scripts/core/localization_service.gd"
)


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)


	assert(LOCALIZATION_SERVICE.normalize_locale("pt-BR") == "pt_BR")
	assert(LOCALIZATION_SERVICE.normalize_locale("es_MX") == "es")
	assert(LOCALIZATION_SERVICE.normalize_locale("fr_FR") == "en")


	LOCALIZATION_SERVICE.set_locale("pt-BR")
	await process_frame
	assert(TranslationServer.translate("HUD_RESOURCES") == "RECURSOS")
	assert(game.bones_label.text.begins_with("RECURSOS"))
	assert(game.factory_title_label.text == "LINHA DE PRODUÇÃO MORTA-VIVA")
	assert(game.processing_label.text.begins_with("PROCESSAMENTO DE CADÁVERES"))
	assert(game.wave_label.text.begins_with("ONDA 1"))
	assert(game.wave_label.text.contains("Inimigos Restantes"))
	assert(game.synergy_label.text.begins_with("SINERGIAS ATIVAS"))
	assert(game.synergy_label.text.contains("Nenhuma"))
	assert(
		game.initial_enemy.get_node("IdentityLabel").text
		== "GUERREIRO HUMANO"
	)
	game.spawn_corpse(Vector2(800.0, 520.0))
	assert(game.corpses.back().text == "CADÁVER")


	LOCALIZATION_SERVICE.set_locale("es_MX")
	await process_frame
	assert(TranslationServer.translate("RESOURCE_BONES") == "HUESOS")
	assert(game.bones_label.text.contains("HUESOS:"))
	assert(game.processing_label.text.begins_with("PROCESAMIENTO DE CADÁVERES"))
	assert(game.wave_label.text.begins_with("OLEADA 1"))
	assert(game.synergy_label.text.begins_with("SINERGIAS ACTIVAS"))
	assert(
		game.initial_enemy.get_node("IdentityLabel").text
		== "GUERRERO HUMANO"
	)
	assert(game.corpses.back().text == "CADÁVER")


	LOCALIZATION_SERVICE.set_locale("en_US")
	await process_frame
	assert(
		TranslationServer.translate("PRODUCTION_QUEUE_ZOMBIE")
		== "PRODUCE ZOMBIE (QUEUE)"
	)
	assert(game.create_zombie_button.text.begins_with("PRODUCE ZOMBIE (QUEUE)"))


	TranslationServer.set_locale(original_locale)
	print("LOCALIZATION FOUNDATION VALIDATION: PASS")
	game.queue_free()
	quit()
