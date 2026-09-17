extends SceneTree

const SHELL := preload("res://scenes/core/app.tscn")
const TEST_PREFIX := "user://presentation_layout_test_"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var shell: Node = SHELL.instantiate()
	shell.profile_path = TEST_PREFIX + "profile.json"
	shell.settings_path = TEST_PREFIX + "settings.cfg"
	shell.run_save_path = TEST_PREFIX + "run.json"
	root.add_child(shell)
	await process_frame
	for locale: String in ["en", "pt_BR", "es"]:
		LocalizationService.set_locale(locale)
		await process_frame
		await process_frame
		assert(Rect2(Vector2.ZERO, Vector2(1920, 1080)).encloses(shell.menu_content.get_global_rect()))
		assert(shell.menu_content.get_global_rect().end.y < shell.version_label.position.y)
		for button: Button in shell.localized_buttons:
			if button.is_visible_in_tree():
				assert(button.size.y >= button.get_combined_minimum_size().y)
	shell.settings["reduced_motion"] = true
	shell.apply_shell_accessibility()
	assert(shell.menu_atmosphere.reduced_motion)
	shell.start_game({})
	await process_frame
	var game: Node = shell.current_game
	game.set_process(false)
	var dashboard: Node = game.get_node("GameplayDashboard")
	assert(not game.has_node("BonesLabel"))
	assert(not game.has_node("MetricsLabel"))
	dashboard.set_process(false)
	for locale: String in ["en", "pt_BR", "es"]:
		LocalizationService.set_locale(locale)
		game.bones = 1234
		game.flesh = 45
		game.blood = 16
		game.souls = 8
		game.production_quantity_selector.value = 10
		game.update_bones_ui()
		dashboard._refresh()
		await process_frame
		await process_frame
		assert(dashboard.resource_values[0].text == "1234")
		assert(dashboard.resource_values[3].text == "8")
		assert(not dashboard.metric_title.text.begins_with("METRICS_"))
		assert(not dashboard.history_visible)
		assert(dashboard.operations_label.is_visible_in_tree())
		assert(not dashboard.metric_names[0].is_visible_in_tree())
		assert(dashboard.operations_label.get_global_rect().end.y <= dashboard.flow_label.position.y + game.get_node("MetricsPanel").position.y)
		assert(game.get_node("MetricsPanel").get_global_rect().encloses(dashboard.flow_label.get_global_rect()))
		dashboard.history_toggle.pressed.emit()
		assert(dashboard.history_visible and dashboard.metric_names[0].is_visible_in_tree())
		assert(not dashboard.operations_label.is_visible_in_tree())
		dashboard.history_toggle.pressed.emit()
		for button: Button in [game.create_skeleton_button, game.create_skeleton_archer_button, game.create_zombie_button]:
			assert(game.get_node("ProductionPanel").get_global_rect().encloses(button.get_global_rect()))
			assert(button.get_global_rect().end.y <= game.production_queue_label.position.y, "%s %s %s" % [locale, button.text, button.get_global_rect()])
			assert(not button.tooltip_text.is_empty())
		for label: Label in dashboard.metric_names:
			assert(game.get_node("MetricsPanel").get_global_rect().encloses(label.get_global_rect()))
		for label: Label in dashboard.metric_values:
			assert(game.get_node("MetricsPanel").get_global_rect().encloses(label.get_global_rect()))
		for bar: ProgressBar in [dashboard.wave_progress, dashboard.production_progress, dashboard.processing_progress]:
			assert(bar.size.y <= 7.0)
			assert(bar.get_parent().get_global_rect().encloses(bar.get_global_rect()))
		assert(game.production_queue_label.get_global_rect().end.y < dashboard.production_progress.get_global_rect().position.y)
	game.zombie_production_queue.append({"kind": "zombie"})
	game.flesh_vat_timer = game.FLESH_VAT_BASE_SECONDS * 0.5
	dashboard._process(0.01)
	assert(is_equal_approx(dashboard.production_progress.value, 50.0))
	game.configure_accessibility({"high_contrast": true, "reduced_motion": true})
	assert(dashboard.resource_values[0].get_theme_constant("outline_size") >= 5)
	shell.queue_free()
	await process_frame
	for suffix: String in ["profile.json", "profile.json.bak", "settings.cfg", "run.json", "run.json.bak"]:
		var path := TEST_PREFIX + suffix
		if FileAccess.file_exists(path):
			assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK)
	print("PRESENTATION LAYOUT VALIDATION: PASS")
	quit()
