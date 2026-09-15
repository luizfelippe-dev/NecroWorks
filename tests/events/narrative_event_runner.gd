extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const EVENT_CATALOG: Script = preload(
	"res://scripts/game/narrative_event_catalog.gd"
)


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var original_locale: String = TranslationServer.get_locale()
	assert(EVENT_CATALOG.get_event_id_for_wave(7) == EVENT_CATALOG.GRAVE_SHIPMENT)
	assert(EVENT_CATALOG.get_event_id_for_wave(13) == EVENT_CATALOG.BOUND_ARCANIST)
	assert(EVENT_CATALOG.get_event_id_for_wave(4) == EVENT_CATALOG.SABOTEUR_OFFER)
	assert(EVENT_CATALOG.get_event_id_for_wave(11) == EVENT_CATALOG.MARSHAL_REMAINS)
	assert(EVENT_CATALOG.get_event_id_for_wave(16) == EVENT_CATALOG.AUDITOR_CORE)
	assert(EVENT_CATALOG.EVENT_DATA.size() == 5)
	var discovery_ids: Dictionary = {}
	for choice_id_value: Variant in EVENT_CATALOG.CHOICE_DATA:
		var choice_data: Dictionary = EVENT_CATALOG.get_choice(str(choice_id_value))
		var discovery_id: String = str(choice_data.get("discovery_id", ""))
		assert(not discovery_id.is_empty())
		discovery_ids[discovery_id] = true
	assert(discovery_ids.size() == 10)
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
	for choice_button: Button in game.narrative_event_buttons:
		assert(choice_button.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)
		assert(choice_button.clip_text)
		assert(choice_button.position.x >= 0.0)
		assert(
			choice_button.position.x + choice_button.size.x
			<= game.narrative_event_panel.size.x
		)
		assert(
			choice_button.position.y + choice_button.size.y
			<= game.narrative_event_panel.size.y
		)
	var bones_before: int = game.bones
	assert(not game.select_narrative_event_choice(EVENT_CATALOG.ARCANIST_SOULS))
	assert(game.select_narrative_event_choice(EVENT_CATALOG.GRAVE_BONES))
	assert(game.bones == bones_before + 18)
	assert(game.total_bones_earned == 18)
	assert(game.current_wave == 7)
	assert(game.wave_in_progress)
	assert(game.narrative_event_choices[EVENT_CATALOG.GRAVE_SHIPMENT] == EVENT_CATALOG.GRAVE_BONES)
	assert(game.lore_discoveries.has("grave_manifest"))

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
	assert(restored_game.wave_preparation_in_progress)
	assert(not restored_game.wave_in_progress)

	# Risk/reward consequence and both Boss Corpse branches remain permanent.
	restored_game.event_decision_in_progress = false
	restored_game.current_narrative_event_id = ""
	assert(restored_game.show_narrative_event(EVENT_CATALOG.SABOTEUR_OFFER))
	assert(restored_game.select_narrative_event_choice(EVENT_CATALOG.BUY_SILENCE))
	assert(restored_game.faction_pressure.iron_concord == 1)
	assert(restored_game.get_faction_damage_bonus("human_warrior") == 2)
	assert(restored_game.get_faction_damage_bonus("mage") == 0)
	restored_game.event_decision_in_progress = false
	restored_game.current_narrative_event_id = ""
	assert(restored_game.show_narrative_event(EVENT_CATALOG.MARSHAL_REMAINS))
	assert(restored_game.select_narrative_event_choice(EVENT_CATALOG.PLATE_ZOMBIES))
	assert(restored_game.event_zombie_hp_bonus == 40)
	restored_game.event_decision_in_progress = false
	restored_game.current_narrative_event_id = ""
	assert(restored_game.show_narrative_event(EVENT_CATALOG.AUDITOR_CORE))
	assert(restored_game.select_narrative_event_choice(EVENT_CATALOG.BIND_RESONANCE))
	assert(restored_game.event_ghost_damage_bonus == 4)
	var consequence_checkpoint: Dictionary = restored_game.build_checkpoint_state()
	assert(consequence_checkpoint.run_modifiers.faction_pressure.iron_concord == 1)
	assert(consequence_checkpoint.run_modifiers.event_zombie_hp_bonus == 40)
	assert(consequence_checkpoint.run_modifiers.event_ghost_damage_bonus == 4)
	assert(consequence_checkpoint.narrative.discoveries.size() == 5)

	for locale: String in ["en", "pt_BR", "es"]:
		TranslationServer.set_locale(locale)
		for key: String in [
			"EVENT_SABOTEUR_TITLE", "EVENT_MARSHAL_TITLE",
			"EVENT_AUDITOR_TITLE", "EVENT_MARSHAL_PLATE",
			"EVENT_AUDITOR_BIND"
		]:
			assert(TranslationServer.translate(key) != key)

	TranslationServer.set_locale(original_locale)
	print("NARRATIVE EVENT DECISION VALIDATION: PASS")
	game.queue_free()
	restored_game.queue_free()
	quit()
