extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const EVENT_CATALOG: Script = preload(
	"res://scripts/game/narrative_event_catalog.gd"
)


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	assert(EVENT_CATALOG.get_event_id_for_wave(7) == EVENT_CATALOG.GRAVE_SHIPMENT)
	assert(EVENT_CATALOG.get_event_id_for_wave(13) == EVENT_CATALOG.BOUND_ARCANIST)
	assert(EVENT_CATALOG.get_event_id_for_wave(8).is_empty())
	assert(EVENT_CATALOG.is_choice_for_event(
		EVENT_CATALOG.GRAVE_SHIPMENT,
		EVENT_CATALOG.GRAVE_BONES
	))
	assert(not EVENT_CATALOG.is_choice_for_event(
		EVENT_CATALOG.GRAVE_SHIPMENT,
		EVENT_CATALOG.ARCANIST_SOULS
	))

	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.current_wave = 7
	LocalizationService.set_locale("pt-BR")
	assert(game.show_narrative_event(EVENT_CATALOG.GRAVE_SHIPMENT))
	assert(game.event_decision_in_progress)
	assert(game.narrative_event_panel.visible)
	assert(game.narrative_event_title_label.text == "CARGA DE SEPULTURA NÃO REGISTRADA")
	assert(game.narrative_event_buttons[0].text.contains("+18 OSSOS"))
	assert(game.narrative_event_panel.position.x >= 0.0)
	assert(game.narrative_event_panel.position.y >= 0.0)
	assert(game.narrative_event_panel.position.x + game.narrative_event_panel.size.x <= 1920.0)
	assert(game.narrative_event_panel.position.y + game.narrative_event_panel.size.y <= 1080.0)
	var bones_before: int = game.bones
	assert(not game.select_narrative_event_choice(EVENT_CATALOG.ARCANIST_SOULS))
	assert(game.select_narrative_event_choice(EVENT_CATALOG.GRAVE_BONES))
	assert(game.bones == bones_before + 18)
	assert(game.total_bones_earned == 18)
	assert(game.current_wave == 7)
	assert(game.wave_in_progress)
	assert(game.narrative_event_choices[EVENT_CATALOG.GRAVE_SHIPMENT] == EVENT_CATALOG.GRAVE_BONES)

	var checkpoint: Dictionary = game.build_checkpoint_state()
	checkpoint.wave = 13
	checkpoint.narrative.pending_event = EVENT_CATALOG.BOUND_ARCANIST
	var restored_game: Node = MAIN_SCENE.instantiate()
	root.add_child(restored_game)
	await process_frame
	restored_game.set_process(false)
	assert(restored_game.restore_checkpoint_state(checkpoint))
	assert(restored_game.event_decision_in_progress)
	assert(restored_game.current_narrative_event_id == EVENT_CATALOG.BOUND_ARCANIST)
	LocalizationService.set_locale("es")
	assert(restored_game.narrative_event_title_label.text == "EL ARCANISTA CAUTIVO")
	assert(restored_game.narrative_event_buttons[0].text.contains("+4 ALMAS"))
	var souls_before: int = restored_game.souls
	assert(restored_game.select_narrative_event_choice(EVENT_CATALOG.ARCANIST_SOULS))
	assert(restored_game.souls == souls_before + 4)
	assert(restored_game.current_wave == 13)
	assert(restored_game.wave_in_progress)

	TranslationServer.set_locale(original_locale)
	print("NARRATIVE EVENT DECISION VALIDATION: PASS")
	game.queue_free()
	restored_game.queue_free()
	quit()
