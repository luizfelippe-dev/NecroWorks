extends SceneTree

# Render real menu/HUD frames with a disposable profile; never touch a player's run.
const SHELL: PackedScene = preload("res://scenes/core/app.tscn")
const OUTPUT := "res://artifacts/presentation"
const TEST_PATH := "user://presentation_capture_"


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var shell: Node = SHELL.instantiate()
	shell.profile_path = TEST_PATH + "profile.json"
	shell.settings_path = TEST_PATH + "settings.cfg"
	shell.run_save_path = TEST_PATH + "run.json"
	root.add_child(shell)
	await process_frame
	shell.settings["tutorial_enabled"] = false
	for locale: String in ["pt-BR", "en", "es"]:
		LocalizationService.set_locale(locale)
		await save_frame("menu_" + locale)
		shell.open_options_from_main()
		await save_frame("options_" + locale)
		shell.close_options()
	LocalizationService.set_locale("pt-BR")
	shell.start_game({})
	await process_frame
	var game: Node = shell.current_game
	game.set_process(false)
	if "--large-text" in OS.get_cmdline_user_args():
		game.configure_accessibility({"reading_scale": 1.3})
	game.bones = 123
	game.flesh = 42
	game.blood = 12
	game.souls = 5
	game.update_bones_ui()
	game.update_metrics_ui()
	for synergy_id: String in game.SYNERGY_CATALOG.ALL_SYNERGIES:
		game.active_synergies[synergy_id] = true
	game.update_synergy_ui()
	for locale: String in ["pt-BR", "en", "es"]:
		LocalizationService.set_locale(locale)
		await create_timer(0.2).timeout
		await save_frame("hud_" + locale)
	game.active_synergies.clear()
	if "--factory-process" in OS.get_cmdline_user_args():
		var index: int = 0
		for archetype: String in ["human_warrior", "mage", "elf", "grave_marshal", "arcane_auditor", "foreman"]:
			game.spawn_corpse(Vector2(550 + index * 150, 590), archetype, false, index >= 3)
			index += 1
		game.enqueue_corpse_for_processing(game.corpses[0])
		var processor: Node = game.get_node("MaterialProcessorVisual")
		processor.set_process(false)
		for fraction: float in [0.1, 0.5, 0.9]:
			game.corpse_processor_timer = game.corpse_processor_seconds_per_corpse * (1.0 - fraction)
			processor.sync_state()
			await save_frame("processor_phase_" + str(int(fraction * 100)))
	if "--narrative" in OS.get_cmdline_user_args():
		for locale: String in ["pt-BR", "en", "es"]:
			LocalizationService.set_locale(locale)
			game.narrative_event_choices["saboteur_offer"] = "buy_silence"
			game.show_narrative_event("marshal_remains")
			await save_frame("narrative_consequence_" + locale)
			game.narrative_event_panel.hide()
			game.run_won = true
			game.narrative_event_choices["auditor_core"] = "bind_resonance"
			game.show_run_end_screen()
			await save_frame("epilogue_" + locale)
			game.run_end_panel.hide()
		game.event_decision_in_progress = false
		game.run_won = false
	if "--boss-warnings" in OS.get_cmdline_user_args():
		for locale: String in ["pt-BR", "en", "es"]:
			LocalizationService.set_locale(locale)
			for warning: String in ["BOSS_FRONT_WARNING", "BOSS_REAR_WARNING", "BOSS_CLUSTER_WARNING"]:
				game.combat_feedback.show_boss_banner(tr(warning), Color.ORANGE)
				await save_frame(warning.to_lower() + "_" + locale)
	game.upgrade_counts[game.UPGRADE_EFFICIENT_RECYCLING] = 1
	game.current_upgrade_choices.assign([
		game.UPGRADE_BONE_HARVEST, game.UPGRADE_MASS_PRODUCTION, game.UPGRADE_HEAVY_BONES,
	])
	game.upgrade_panel.show()
	for locale: String in ["pt-BR", "en", "es"]:
		LocalizationService.set_locale(locale)
		game.update_upgrade_ui()
		await save_frame("upgrade_preview_" + locale)
	shell.queue_free()
	await process_frame
	await capture_motion()
	for suffix: String in ["profile.json", "settings.cfg", "run.json", "run.json.bak"]:
		var path := TEST_PATH + suffix
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PRESENTATION CAPTURE: PASS")
	quit()


func capture_motion() -> void:
	var catalog: Script = preload("res://scripts/visual/unit_sprite_catalog.gd")
	var driver_script: Script = preload("res://scripts/visual/unit_animation_driver.gd")
	var ids := ["skeleton", "skeleton_archer", "zombie", "human_warrior", "elf", "mage", "lich", "ghost", "grave_marshal", "arcane_auditor", "foreman"]
	for page: int in range(2):
		var gallery := Node2D.new()
		root.add_child(gallery)
		var background := ColorRect.new()
		background.size = Vector2(1920, 1080)
		background.color = Color("121916")
		gallery.add_child(background)
		for row: int in range(6):
			var unit_index := page * 6 + row
			if unit_index >= ids.size():
				break
			var visual_id: String = ids[unit_index]
			var label := Label.new()
			label.text = visual_id
			label.position = Vector2(40, 95 + row * 165)
			label.add_theme_font_size_override("font_size", 24)
			gallery.add_child(label)
			for column: int in range(4):
				var host := Node2D.new()
				host.position = Vector2(450 + column * 400, 105 + row * 165)
				gallery.add_child(host)
				var sprite := Sprite2D.new()
				sprite.texture = catalog.get_animation_textures(visual_id)["move"]
				sprite.scale = Vector2.ONE * 195.0 / sprite.texture.get_height()
				host.add_child(sprite)
				var driver: Node = driver_script.new()
				host.add_child(driver)
				driver.bind(sprite)
				driver.configure_state_textures(catalog.get_animation_textures(visual_id))
				driver.configure_motion(catalog.get_motion_profile(visual_id))
				driver.play("move")
				driver.set_process(false)
				driver.gait_phase = column * PI * 0.5
				driver.locomotion_weight = 1.0
				driver._render_pose()
		await save_frame("motion_" + str(page + 1))
		gallery.queue_free()
		await process_frame


func save_frame(label: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var suffix := "_%dx%d" % [image.get_width(), image.get_height()]
	assert(image.save_png(OUTPUT + "/" + label + suffix + ".png") == OK)
