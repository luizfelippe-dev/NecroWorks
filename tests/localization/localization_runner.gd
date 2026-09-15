extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
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
	assert(game.get_node("GameplayDashboard").resources_title.text == "RECURSOS")
	assert(game.factory_title_label.text == "LINHA DE PRODUÇÃO MORTA-VIVA")
	assert(game.processing_label.text.begins_with("PROCESSAMENTO DE CADÁVERES"))
	assert(game.wave_label.text.begins_with("ONDA 1"))
	assert(game.wave_label.text.contains("Inimigos Restantes"))
	assert(game.synergy_label.text.begins_with("SINERGIAS 0 / 10"))
	assert(game.synergy_label.text.contains("EM PROGRESSO"))
	assert(game.synergy_label.text.contains("REQUISITOS"))
	assert(
		game.initial_enemy.get_node("IdentityLabel").text
		== "GUERREIRO HUMANO"
	)
	game.spawn_corpse(Vector2(800.0, 520.0))
	assert(game.corpses.back().text == "CADÁVER")
	game.run_won = true
	game.show_run_end_screen()
	assert(game.run_end_title_label.text.contains("META DE PRODUÇÃO ATINGIDA"))
	assert(game.run_end_summary_label.text.contains("ESTATÍSTICAS DA PARTIDA"))
	assert(game.run_end_build_label.text.contains("RESUMO DA BUILD"))
	assert(game.restart_run_button.text == "REINICIAR PARTIDA")
	assert(game.return_to_menu_button.text == "VOLTAR AO MENU PRINCIPAL")
	assert(TranslationServer.translate("TUTORIAL_STEP_1").contains("automaticamente"))
	assert(TranslationServer.translate("OPTIONS_REDUCED_MOTION") == "REDUZIR MOVIMENTO")
	assert(TranslationServer.translate("BOSS_WARNING").begins_with("SINAL DE CHEFE"))
	game.run_end_panel.visible = false


	LOCALIZATION_SERVICE.set_locale("es_MX")
	await process_frame
	assert(TranslationServer.translate("RESOURCE_BONES") == "HUESOS")
	assert(game.get_node("GameplayDashboard").resource_names[0].text == "HUESOS")
	assert(game.processing_label.text.begins_with("PROCESAMIENTO DE CADÁVERES"))
	assert(game.wave_label.text.begins_with("OLEADA 1"))
	assert(game.synergy_label.text.begins_with("SINERGIAS 0 / 10"))
	assert(game.synergy_label.text.contains("EN PROGRESO"))
	assert(
		game.initial_enemy.get_node("IdentityLabel").text
		== "GUERRERO HUMANO"
	)
	assert(game.corpses.back().text == "CADÁVER")
	assert(TranslationServer.translate("TUTORIAL_STEP_5").contains("jefes"))
	assert(TranslationServer.translate("OPTIONS_HIGH_CONTRAST").contains("ALTO CONTRASTE"))


	LOCALIZATION_SERVICE.set_locale("en_US")
	await process_frame
	assert(
		TranslationServer.translate("PRODUCTION_QUEUE_ZOMBIE")
		== "ZOMBIE"
	)
	assert(game.create_zombie_button.text.begins_with("ZOMBIE"))
	assert(TranslationServer.translate("TUTORIAL_TITLE") == "SHIFT ORIENTATION")


	TranslationServer.set_locale(original_locale)
	print("LOCALIZATION FOUNDATION VALIDATION: PASS")
	game.queue_free()
	quit()
