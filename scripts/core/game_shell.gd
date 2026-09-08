extends Node


const GAME_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const ACCENT: Color = Color("55d83e")
const PANEL: Color = Color(0.018, 0.024, 0.022, 0.98)
const BORDER: Color = Color(0.32, 0.31, 0.25, 1.0)
const META_STORE: Script = preload("res://scripts/core/meta_progression_store.gd")
const CODEX_CATALOG: Script = preload("res://scripts/game/codex_catalog.gd")
const META_UNLOCK_CATALOG: Script = preload("res://scripts/game/meta_unlock_catalog.gd")
const OPERATOR_CATALOG: Script = preload("res://scripts/game/operator_catalog.gd")
const MODIFIER_CATALOG: Script = preload("res://scripts/game/starting_modifier_catalog.gd")
const CHALLENGE_CATALOG: Script = preload("res://scripts/game/challenge_catalog.gd")

var current_game: Node = null
var settings: Dictionary = {}
var settings_path: String = SettingsStore.DEFAULT_PATH
var options_return_to_pause: bool = false
var tutorial_step: int = 0

var ui_layer: CanvasLayer
var main_menu: Control
var prologue_menu: Control
var pause_menu: Control
var options_menu: Control
var codex_menu: Control
var history_menu: Control
var loadout_menu: Control
var continue_button: Button
var title_label: Label
var subtitle_label: Label
var prologue_title: Label
var prologue_body: Label
var pause_title: Label
var pause_status_label: Label
var options_title: Label
var language_label: Label
var volume_label: Label
var music_volume_label: Label
var sfx_volume_label: Label
var ui_volume_label: Label
var fullscreen_check: CheckButton
var reduced_motion_check: CheckButton
var high_contrast_check: CheckButton
var tutorial_check: CheckButton
var tutorial_reset_button: Button
var language_option: OptionButton
var volume_slider: HSlider
var music_volume_slider: HSlider
var sfx_volume_slider: HSlider
var ui_volume_slider: HSlider
var options_apply_button: Button
var options_back_button: Button
var tutorial_menu: Control
var tutorial_title: Label
var tutorial_body: Label
var tutorial_progress: Label
var tutorial_next_button: Button
var tutorial_skip_button: Button
var codex_title: Label
var codex_content: Label
var history_title: Label
var history_content: Label
var loadout_title: Label
var operator_name_label: Label
var operator_description_label: Label
var modifier_name_label: Label
var modifier_description_label: Label
var challenges_label: Label
var next_operator_button: Button
var next_modifier_button: Button
var profile: Dictionary = {}
var profile_path: String = META_STORE.DEFAULT_PATH
var run_save_path: String = RunSaveStore.DEFAULT_PATH
var localized_buttons: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings = SettingsStore.apply_settings(SettingsStore.load_settings(settings_path))
	profile = META_STORE.load_profile(profile_path)
	build_interface()
	refresh_localized_text()
	show_main_menu()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		refresh_localized_text()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if tutorial_menu != null and tutorial_menu.visible:
		finish_tutorial()
	elif options_menu.visible:
		close_options()
	elif codex_menu.visible:
		show_main_menu()
	elif history_menu.visible:
		show_main_menu()
	elif loadout_menu.visible:
		show_main_menu()
	elif prologue_menu.visible:
		show_main_menu()
	elif current_game != null:
		if get_tree().paused:
			resume_game()
		else:
			pause_game()


func build_interface() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui_layer)

	main_menu = create_screen("MainMenu", Color(0.002, 0.006, 0.005, 1.0))
	var main_box := create_center_panel(main_menu, Vector2(620.0, 780.0))
	title_label = create_label(42, ACCENT)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_box.add_child(title_label)
	subtitle_label = create_label(17, Color(0.78, 0.77, 0.67))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_box.add_child(subtitle_label)
	main_box.add_child(create_separator())
	add_localized_button(main_box, "MENU_NEW_RUN", start_new_run)
	continue_button = add_localized_button(main_box, "MENU_CONTINUE", continue_run)
	add_localized_button(main_box, "MENU_OPTIONS", open_options_from_main)
	add_localized_button(main_box, "MENU_CODEX", show_codex)
	add_localized_button(main_box, "MENU_RUN_HISTORY", show_run_history)
	add_localized_button(main_box, "MENU_LOADOUT", show_loadout)
	add_localized_button(main_box, "MENU_QUIT", quit_game)

	prologue_menu = create_screen("PrologueMenu", Color(0.002, 0.006, 0.005, 1.0))
	var prologue_box := create_center_panel(prologue_menu, Vector2(880.0, 660.0))
	prologue_title = create_label(34, ACCENT)
	prologue_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prologue_box.add_child(prologue_title)
	prologue_box.add_child(create_separator())
	prologue_body = create_label(20)
	prologue_body.custom_minimum_size = Vector2(0.0, 330.0)
	prologue_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prologue_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prologue_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prologue_body.add_theme_constant_override("line_spacing", 8)
	prologue_box.add_child(prologue_body)
	prologue_box.add_child(create_separator())
	add_localized_button(prologue_box, "PROLOGUE_BEGIN", confirm_new_run)
	add_localized_button(prologue_box, "OPTIONS_BACK", show_main_menu)

	pause_menu = create_screen("PauseMenu", Color(0.0, 0.0, 0.0, 0.72))
	var pause_box := create_center_panel(pause_menu, Vector2(500.0, 500.0))
	pause_title = create_label(34, ACCENT)
	pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_box.add_child(pause_title)
	pause_box.add_child(create_separator())
	add_localized_button(pause_box, "PAUSE_RESUME", resume_game)
	add_localized_button(pause_box, "MENU_OPTIONS", open_options_from_pause)
	add_localized_button(pause_box, "PAUSE_SAVE_MENU", save_and_return_to_menu)
	add_localized_button(pause_box, "PAUSE_RESTART", restart_game)
	pause_status_label = create_label(14, Color(0.82, 0.80, 0.68, 1.0))
	pause_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pause_status_label.custom_minimum_size = Vector2(0.0, 44.0)
	pause_box.add_child(pause_status_label)

	options_menu = create_screen("OptionsMenu", Color(0.0, 0.0, 0.0, 0.84))
	var options_box := create_center_panel(options_menu, Vector2(700.0, 840.0))
	options_box.add_theme_constant_override("separation", 8)
	options_title = create_label(34, ACCENT)
	options_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	options_box.add_child(options_title)
	options_box.add_child(create_separator())
	language_label = create_label(18)
	options_box.add_child(language_label)
	language_option = OptionButton.new()
	language_option.custom_minimum_size = Vector2(0.0, 48.0)
	language_option.add_item("English", 0)
	language_option.add_item("Português (Brasil)", 1)
	language_option.add_item("Español", 2)
	options_box.add_child(language_option)
	volume_label = create_label(18)
	options_box.add_child(volume_label)
	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.custom_minimum_size = Vector2(0.0, 44.0)
	options_box.add_child(volume_slider)
	music_volume_label = create_label(16)
	options_box.add_child(music_volume_label)
	music_volume_slider = create_volume_slider(options_box)
	sfx_volume_label = create_label(16)
	options_box.add_child(sfx_volume_label)
	sfx_volume_slider = create_volume_slider(options_box)
	ui_volume_label = create_label(16)
	options_box.add_child(ui_volume_label)
	ui_volume_slider = create_volume_slider(options_box)
	fullscreen_check = CheckButton.new()
	fullscreen_check.custom_minimum_size = Vector2(0.0, 48.0)
	options_box.add_child(fullscreen_check)
	reduced_motion_check = CheckButton.new()
	reduced_motion_check.custom_minimum_size = Vector2(0.0, 44.0)
	options_box.add_child(reduced_motion_check)
	high_contrast_check = CheckButton.new()
	high_contrast_check.custom_minimum_size = Vector2(0.0, 44.0)
	options_box.add_child(high_contrast_check)
	tutorial_check = CheckButton.new()
	tutorial_check.custom_minimum_size = Vector2(0.0, 44.0)
	options_box.add_child(tutorial_check)
	tutorial_reset_button = add_localized_button(
		options_box, "OPTIONS_REPLAY_TUTORIAL", reset_tutorial
	)
	options_box.add_child(create_separator())
	options_apply_button = add_localized_button(options_box, "OPTIONS_APPLY", apply_options)
	options_back_button = add_localized_button(options_box, "OPTIONS_BACK", close_options)

	codex_menu = create_screen("CodexMenu", Color(0.0, 0.0, 0.0, 0.90))
	var codex_box := create_center_panel(codex_menu, Vector2(940.0, 820.0))
	codex_title = create_label(34, ACCENT)
	codex_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	codex_box.add_child(codex_title)
	var codex_scroll := ScrollContainer.new()
	codex_scroll.custom_minimum_size = Vector2(0.0, 610.0)
	codex_box.add_child(codex_scroll)
	codex_content = create_label(17)
	codex_content.custom_minimum_size = Vector2(800.0, 0.0)
	codex_content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	codex_content.add_theme_constant_override("line_spacing", 6)
	codex_scroll.add_child(codex_content)
	add_localized_button(codex_box, "OPTIONS_BACK", show_main_menu)

	history_menu = create_screen("RunHistoryMenu", Color(0.0, 0.0, 0.0, 0.90))
	var history_box := create_center_panel(history_menu, Vector2(880.0, 780.0))
	history_title = create_label(34, ACCENT)
	history_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	history_box.add_child(history_title)
	var history_scroll := ScrollContainer.new()
	history_scroll.custom_minimum_size = Vector2(0.0, 570.0)
	history_box.add_child(history_scroll)
	history_content = create_label(18)
	history_content.custom_minimum_size = Vector2(740.0, 0.0)
	history_content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	history_content.add_theme_constant_override("line_spacing", 7)
	history_scroll.add_child(history_content)
	add_localized_button(history_box, "OPTIONS_BACK", show_main_menu)

	loadout_menu = create_screen("LoadoutMenu", Color(0.0, 0.0, 0.0, 0.92))
	var loadout_box := create_center_panel(loadout_menu, Vector2(900.0, 820.0))
	loadout_title = create_label(34, ACCENT)
	loadout_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loadout_box.add_child(loadout_title)
	operator_name_label = create_label(24, Color(0.88, 0.84, 0.69))
	operator_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loadout_box.add_child(operator_name_label)
	operator_description_label = create_wrapped_center_label(17, 86.0)
	loadout_box.add_child(operator_description_label)
	next_operator_button = add_localized_button(
		loadout_box, "LOADOUT_NEXT_OPERATOR", select_next_operator
	)
	modifier_name_label = create_label(24, Color(0.70, 0.34, 0.28))
	modifier_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loadout_box.add_child(modifier_name_label)
	modifier_description_label = create_wrapped_center_label(17, 86.0)
	loadout_box.add_child(modifier_description_label)
	next_modifier_button = add_localized_button(
		loadout_box, "LOADOUT_NEXT_MODIFIER", select_next_modifier
	)
	challenges_label = create_wrapped_center_label(16, 125.0)
	loadout_box.add_child(challenges_label)
	add_localized_button(loadout_box, "OPTIONS_BACK", show_main_menu)

	tutorial_menu = create_screen("TutorialMenu", Color(0.0, 0.0, 0.0, 0.82))
	var tutorial_box := create_center_panel(tutorial_menu, Vector2(820.0, 540.0))
	tutorial_title = create_label(32, ACCENT)
	tutorial_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_box.add_child(tutorial_title)
	tutorial_progress = create_label(16, Color(0.72, 0.72, 0.64))
	tutorial_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_box.add_child(tutorial_progress)
	tutorial_box.add_child(create_separator())
	tutorial_body = create_wrapped_center_label(21, 250.0)
	tutorial_body.add_theme_constant_override("line_spacing", 8)
	tutorial_box.add_child(tutorial_body)
	tutorial_next_button = add_localized_button(
		tutorial_box, "TUTORIAL_NEXT", advance_tutorial
	)
	tutorial_skip_button = add_localized_button(
		tutorial_box, "TUTORIAL_SKIP", finish_tutorial
	)

	prologue_menu.visible = false
	pause_menu.visible = false
	options_menu.visible = false
	codex_menu.visible = false
	history_menu.visible = false
	loadout_menu.visible = false
	tutorial_menu.visible = false


func create_screen(screen_name: String, color: Color) -> Control:
	var screen := ColorRect.new()
	screen.name = screen_name
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.color = color
	screen.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(screen)
	return screen


func create_center_panel(parent: Control, minimum_size: Vector2) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = minimum_size
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = PANEL
	panel_style.border_color = BORDER
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(5)
	panel_style.content_margin_left = 48.0
	panel_style.content_margin_right = 48.0
	panel_style.content_margin_top = 42.0
	panel_style.content_margin_bottom = 42.0
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	return box


func create_label(font_size: int, color: Color = Color(0.9, 0.9, 0.84)) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func create_wrapped_center_label(font_size: int, minimum_height: float) -> Label:
	var label: Label = create_label(font_size)
	label.custom_minimum_size.y = minimum_height
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func create_separator() -> HSeparator:
	var separator := HSeparator.new()
	separator.custom_minimum_size.y = 12.0
	return separator


func add_localized_button(
	parent: VBoxContainer,
	translation_key: String,
	callback: Callable
) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0.0, 56.0)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(callback)
	parent.add_child(button)
	localized_buttons[button] = translation_key
	return button


func refresh_localized_text() -> void:
	if title_label == null:
		return
	title_label.text = tr("GAME_TITLE")
	subtitle_label.text = tr("GAME_TAGLINE")
	prologue_title.text = tr("PROLOGUE_TITLE")
	prologue_body.text = tr("PROLOGUE_BODY")
	pause_title.text = tr("PAUSE_TITLE")
	if pause_status_label != null:
		pause_status_label.text = tr("PAUSE_CHECKPOINT_NOTE")
	options_title.text = tr("OPTIONS_TITLE")
	codex_title.text = tr("CODEX_TITLE")
	history_title.text = tr("RUN_HISTORY_TITLE")
	loadout_title.text = tr("LOADOUT_TITLE")
	language_label.text = tr("OPTIONS_LANGUAGE")
	volume_label.text = tr("OPTIONS_MASTER_VOLUME")
	music_volume_label.text = tr("OPTIONS_MUSIC_VOLUME")
	sfx_volume_label.text = tr("OPTIONS_SFX_VOLUME")
	ui_volume_label.text = tr("OPTIONS_UI_VOLUME")
	fullscreen_check.text = tr("OPTIONS_FULLSCREEN")
	reduced_motion_check.text = tr("OPTIONS_REDUCED_MOTION")
	high_contrast_check.text = tr("OPTIONS_HIGH_CONTRAST")
	tutorial_check.text = tr("OPTIONS_TUTORIAL_ENABLED")
	for button_value: Variant in localized_buttons:
		var button: Button = button_value as Button
		if is_instance_valid(button):
			button.text = tr(str(localized_buttons[button_value]))
	refresh_codex_content()
	refresh_run_history_content()
	refresh_loadout_content()
	refresh_tutorial_content()
	apply_shell_accessibility()


func show_main_menu() -> void:
	get_tree().paused = false
	main_menu.visible = true
	prologue_menu.visible = false
	pause_menu.visible = false
	options_menu.visible = false
	codex_menu.visible = false
	history_menu.visible = false
	loadout_menu.visible = false
	tutorial_menu.visible = false
	continue_button.disabled = not RunSaveStore.has_checkpoint()


func start_new_run() -> void:
	main_menu.visible = false
	prologue_menu.visible = true


func show_codex() -> void:
	main_menu.visible = false
	codex_menu.visible = true
	refresh_codex_content()


func refresh_codex_content() -> void:
	if codex_content == null:
		return
	var discoveries: Dictionary = profile.get("discoveries", {}) as Dictionary
	var sections: PackedStringArray = []
	for discovery_id: String in CODEX_CATALOG.DISCOVERY_IDS:
		if bool(discoveries.get(discovery_id, false)):
			sections.append(
				tr(CODEX_CATALOG.get_title_key(discovery_id))
				+ "\n" + tr(CODEX_CATALOG.get_body_key(discovery_id))
			)
		else:
			sections.append(tr("CODEX_LOCKED_ENTRY"))
	sections.append(tr("CODEX_REFERENCE_TITLE"))
	for reference_id: String in CODEX_CATALOG.REFERENCE_IDS:
		if CODEX_CATALOG.is_reference_unlocked(reference_id, profile):
			sections.append(
				tr(CODEX_CATALOG.get_reference_title_key(reference_id))
				+ "\n" + tr(CODEX_CATALOG.get_reference_body_key(reference_id))
			)
		else:
			sections.append(tr("CODEX_LOCKED_ENTRY"))
	codex_content.text = "\n\n".join(sections)


func show_run_history() -> void:
	main_menu.visible = false
	history_menu.visible = true
	refresh_run_history_content()


func show_loadout() -> void:
	main_menu.visible = false
	loadout_menu.visible = true
	refresh_loadout_content()


func refresh_loadout_content() -> void:
	if operator_name_label == null:
		return
	var operator_id: String = str(profile.get(
		"selected_operator", OPERATOR_CATALOG.DIRECTOR
	))
	var modifier_id: String = str(profile.get(
		"selected_modifier", MODIFIER_CATALOG.STANDARD
	))
	var operator_definition: Dictionary = OPERATOR_CATALOG.get_definition(operator_id)
	var modifier_definition: Dictionary = MODIFIER_CATALOG.get_definition(modifier_id)
	operator_name_label.text = tr("LOADOUT_OPERATOR") + ": " + tr(
		str(operator_definition.get("name_key", ""))
	)
	operator_description_label.text = tr(str(
		operator_definition.get("description_key", "")
	))
	modifier_name_label.text = tr("LOADOUT_MODIFIER") + ": " + tr(
		str(modifier_definition.get("name_key", ""))
	)
	modifier_description_label.text = tr(str(
		modifier_definition.get("description_key", "")
	))
	var challenge_lines: PackedStringArray = [tr("CHALLENGES_TITLE")]
	for challenge_id: String in CHALLENGE_CATALOG.CHALLENGE_IDS:
		var definition: Dictionary = CHALLENGE_CATALOG.DEFINITIONS[challenge_id] as Dictionary
		var value: Vector2i = CHALLENGE_CATALOG.get_progress(challenge_id, profile)
		var status: String = tr("CHALLENGE_COMPLETE") if value.x >= value.y else (
			str(mini(value.x, value.y)) + "/" + str(value.y)
		)
		challenge_lines.append(
			tr(str(definition.get("title_key", ""))) + " — " + status
		)
	challenges_label.text = "\n".join(challenge_lines)


func select_next_operator() -> void:
	var available: Array[String] = OPERATOR_CATALOG.get_available_ids(
		profile.get("unlocks", {}) as Dictionary
	)
	cycle_loadout_selection(available, "selected_operator")


func select_next_modifier() -> void:
	var available: Array[String] = MODIFIER_CATALOG.get_available_ids(
		profile.get("unlocks", {}) as Dictionary
	)
	cycle_loadout_selection(available, "selected_modifier")


func cycle_loadout_selection(available: Array[String], profile_key: String) -> void:
	if available.is_empty():
		return
	var current_index: int = available.find(str(profile.get(profile_key, "")))
	profile[profile_key] = available[(current_index + 1) % available.size()]
	META_STORE.save_profile(profile, profile_path)
	refresh_loadout_content()


func refresh_run_history_content() -> void:
	if history_content == null:
		return
	var history: Array = profile.get("run_history", []) as Array
	var unlocks: Dictionary = profile.get("unlocks", {}) as Dictionary
	var unlocked_names: PackedStringArray = []
	for unlock_id: String in META_UNLOCK_CATALOG.UNLOCK_IDS:
		if bool(unlocks.get(unlock_id, false)):
			unlocked_names.append(tr(META_UNLOCK_CATALOG.get_name_key(unlock_id)))
	var lines: PackedStringArray = [
		tr("META_UNLOCKS_TITLE"),
		(" • " + "\n • ".join(unlocked_names))
			if not unlocked_names.is_empty() else tr("META_UNLOCKS_NONE"),
		"",
		tr("RUN_HISTORY_TITLE"),
	]
	if history.is_empty():
		lines.append(tr("RUN_HISTORY_EMPTY"))
		history_content.text = "\n".join(lines)
		return
	for index: int in range(history.size()):
		var entry: Dictionary = history[index] as Dictionary
		var result_key: String = (
			"RUN_HISTORY_VICTORY" if bool(entry.get("victory", false))
			else "RUN_HISTORY_DEFEAT"
		)
		lines.append(tr("RUN_HISTORY_ENTRY") % [
			index + 1,
			tr(result_key),
			int(entry.get("wave", 0)),
			int(entry.get("enemies_killed", 0)),
			int(entry.get("corpses_processed", 0)),
			int(entry.get("army_remaining", 0)),
		])
	history_content.text = "\n\n".join(lines)


func confirm_new_run() -> void:
	RunSaveStore.delete_checkpoint(run_save_path)
	start_game({})
	if bool(settings.get("tutorial_enabled", true)) and not bool(
		settings.get("tutorial_completed", false)
	):
		show_tutorial()


func continue_run() -> void:
	var checkpoint: Dictionary = RunSaveStore.load_checkpoint(run_save_path)
	if checkpoint.is_empty():
		show_main_menu()
		return
	start_game(checkpoint)


func start_game(checkpoint: Dictionary) -> void:
	get_tree().paused = false
	if is_instance_valid(current_game):
		current_game.queue_free()
	current_game = GAME_SCENE.instantiate()
	add_child(current_game)
	move_child(current_game, 0)
	current_game.run_checkpoint_requested.connect(save_checkpoint)
	current_game.run_completed.connect(on_run_completed)
	current_game.meta_progress_reported.connect(on_meta_progress_reported)
	current_game.restart_requested.connect(restart_game)
	current_game.return_to_menu_requested.connect(return_to_menu)
	main_menu.visible = false
	prologue_menu.visible = false
	pause_menu.visible = false
	options_menu.visible = false
	codex_menu.visible = false
	history_menu.visible = false
	loadout_menu.visible = false
	tutorial_menu.visible = false
	if current_game.has_method("configure_accessibility"):
		current_game.configure_accessibility(settings)
	if not checkpoint.is_empty():
		var checkpoint_metrics: Dictionary = checkpoint.get("metrics", {}) as Dictionary
		META_STORE.apply_progress_event(profile, {
			"highest_wave": int(checkpoint.get("wave", 0)),
			"corpses_processed": int(checkpoint_metrics.get("corpses_processed", 0)),
		})
		META_STORE.save_profile(profile, profile_path)
	if current_game.has_method("configure_meta_progression"):
		var saved_loadout: Dictionary = checkpoint.get("meta_loadout", {}) as Dictionary
		current_game.configure_meta_progression(
			profile.get("unlocks", {}) as Dictionary,
			{
				"operator": saved_loadout.get(
					"operator", profile.get("selected_operator", OPERATOR_CATALOG.DIRECTOR)
				),
				"modifier": saved_loadout.get(
					"modifier", profile.get("selected_modifier", MODIFIER_CATALOG.STANDARD)
				),
			}
		)
	if not checkpoint.is_empty():
		current_game.restore_checkpoint_state(checkpoint)
	else:
		save_checkpoint(current_game.get_resume_checkpoint_state())


func save_checkpoint(state: Dictionary) -> Error:
	var checkpoint_error: Error = RunSaveStore.save_checkpoint(state, run_save_path)
	if checkpoint_error != OK:
		return checkpoint_error
	META_STORE.merge_discoveries(
		profile, state.get("narrative", {}).get("discoveries", {}) as Dictionary
	)
	return META_STORE.save_profile(profile, profile_path)


func on_meta_progress_reported(event: Dictionary) -> void:
	var newly_unlocked: Array[String] = META_STORE.apply_progress_event(profile, event)
	if (
		not newly_unlocked.is_empty()
		or event.has("highest_wave")
		or int(event.get("victories_delta", 0)) > 0
	):
		META_STORE.save_profile(profile, profile_path)
	if is_instance_valid(current_game) and not newly_unlocked.is_empty():
		current_game.update_meta_unlocks(profile.get("unlocks", {}) as Dictionary)
	if not newly_unlocked.is_empty():
		refresh_run_history_content()
		refresh_loadout_content()


func on_run_completed(victory: bool) -> void:
	if is_instance_valid(current_game):
		var completed_profile: Dictionary = profile.duplicate(true)
		META_STORE.merge_discoveries(
			completed_profile, current_game.lore_discoveries
		)
		META_STORE.record_run(completed_profile, {
			"victory": victory,
			"wave": current_game.current_wave,
			"duration_seconds": snappedf(current_game.run_elapsed_seconds, 0.1),
			"enemies_killed": current_game.total_enemies_killed,
			"corpses_processed": current_game.total_corpses_processed,
			"army_remaining": current_game.get_total_undead_count(),
			"skeletons_built": current_game.total_skeletons_created,
			"skeletons_lost": current_game.total_skeletons_lost,
			"zombies_built": current_game.total_zombies_created,
			"zombies_lost": current_game.total_zombies_lost,
			"ghosts_built": current_game.total_ghosts_created,
			"ghosts_lost": current_game.total_ghosts_lost,
			"liches_built": current_game.total_liches_created,
			"liches_lost": current_game.total_liches_lost,
			"upgrades_selected": current_game.total_upgrades_selected,
			"bones_remaining": current_game.bones,
			"flesh_remaining": current_game.flesh,
			"blood_remaining": current_game.blood,
			"souls_remaining": current_game.souls,
			"processing_routes": current_game.corpses_processed_by_directive.duplicate(true),
			"defeat_reason": current_game.last_defeat_reason,
			"operator": current_game.selected_operator,
			"contract": current_game.selected_starting_modifier,
			"progress_recorded_live": true,
		})
		if META_STORE.save_profile(completed_profile, profile_path) == OK:
			profile = completed_profile
			RunSaveStore.delete_checkpoint(run_save_path)


func pause_game() -> void:
	if current_game == null:
		return
	get_tree().paused = true
	pause_menu.visible = true
	pause_status_label.text = tr("PAUSE_CHECKPOINT_NOTE")


func resume_game() -> void:
	pause_menu.visible = false
	options_menu.visible = false
	get_tree().paused = false


func save_and_return_to_menu() -> void:
	if is_instance_valid(current_game):
		var save_error: Error = save_checkpoint(
			current_game.get_resume_checkpoint_state()
		)
		if save_error != OK:
			pause_status_label.text = tr("PAUSE_SAVE_FAILED") % save_error
			return
		current_game.queue_free()
	current_game = null
	show_main_menu()


func return_to_menu() -> void:
	if is_instance_valid(current_game):
		current_game.queue_free()
	current_game = null
	show_main_menu()


func restart_game() -> void:
	RunSaveStore.delete_checkpoint(run_save_path)
	start_game({})


func open_options_from_main() -> void:
	options_return_to_pause = false
	open_options()


func open_options_from_pause() -> void:
	options_return_to_pause = true
	open_options()


func open_options() -> void:
	main_menu.visible = false
	prologue_menu.visible = false
	pause_menu.visible = false
	options_menu.visible = true
	codex_menu.visible = false
	history_menu.visible = false
	loadout_menu.visible = false
	var locale: String = LocalizationService.normalize_locale(str(settings.locale))
	language_option.select({"en": 0, "pt_BR": 1, "es": 2}.get(locale, 0))
	volume_slider.value = float(settings.master_volume)
	music_volume_slider.value = float(settings.music_volume)
	sfx_volume_slider.value = float(settings.sfx_volume)
	ui_volume_slider.value = float(settings.ui_volume)
	fullscreen_check.button_pressed = bool(settings.fullscreen)
	reduced_motion_check.button_pressed = bool(settings.reduced_motion)
	high_contrast_check.button_pressed = bool(settings.high_contrast)
	tutorial_check.button_pressed = bool(settings.tutorial_enabled)


func apply_options() -> void:
	var locales: PackedStringArray = ["en", "pt_BR", "es"]
	settings = {
		"locale": locales[language_option.selected],
		"master_volume": volume_slider.value,
		"music_volume": music_volume_slider.value,
		"sfx_volume": sfx_volume_slider.value,
		"ui_volume": ui_volume_slider.value,
		"fullscreen": fullscreen_check.button_pressed,
		"reduced_motion": reduced_motion_check.button_pressed,
		"high_contrast": high_contrast_check.button_pressed,
		"tutorial_enabled": tutorial_check.button_pressed,
		"tutorial_completed": bool(settings.get("tutorial_completed", false)),
	}
	settings = SettingsStore.apply_settings(settings)
	SettingsStore.save_settings(settings, settings_path)
	if is_instance_valid(current_game) and current_game.has_method("configure_accessibility"):
		current_game.configure_accessibility(settings)
	refresh_localized_text()


func create_volume_slider(parent: Container) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.custom_minimum_size = Vector2(0.0, 32.0)
	parent.add_child(slider)
	return slider


func close_options() -> void:
	options_menu.visible = false
	if options_return_to_pause and current_game != null:
		pause_menu.visible = true
	else:
		main_menu.visible = true


func quit_game() -> void:
	get_tree().quit()


func show_tutorial() -> void:
	if current_game == null or not bool(settings.get("tutorial_enabled", true)):
		return
	tutorial_step = 0
	tutorial_menu.visible = true
	pause_menu.visible = false
	options_menu.visible = false
	get_tree().paused = true
	refresh_tutorial_content()


func advance_tutorial() -> void:
	tutorial_step += 1
	if tutorial_step >= 5:
		finish_tutorial()
		return
	refresh_tutorial_content()


func finish_tutorial() -> void:
	tutorial_menu.visible = false
	settings.tutorial_completed = true
	SettingsStore.save_settings(settings, settings_path)
	get_tree().paused = false


func reset_tutorial() -> void:
	settings.tutorial_completed = false
	settings.tutorial_enabled = true
	tutorial_check.button_pressed = true
	SettingsStore.save_settings(settings, settings_path)
	if current_game != null:
		show_tutorial()


func refresh_tutorial_content() -> void:
	if tutorial_title == null:
		return
	tutorial_title.text = tr("TUTORIAL_TITLE")
	tutorial_progress.text = tr("TUTORIAL_PROGRESS") % [tutorial_step + 1, 5]
	tutorial_body.text = tr("TUTORIAL_STEP_%d" % [tutorial_step + 1])
	tutorial_next_button.text = tr(
		"TUTORIAL_FINISH" if tutorial_step == 4 else "TUTORIAL_NEXT"
	)


func apply_shell_accessibility() -> void:
	if ui_layer == null:
		return
	var high_contrast: bool = bool(settings.get("high_contrast", false))
	apply_contrast_recursive(ui_layer, high_contrast)


func apply_contrast_recursive(node: Node, enabled: bool) -> void:
	if node is Label or node is Button:
		var control: Control = node as Control
		control.add_theme_color_override("font_outline_color", Color.BLACK)
		control.add_theme_constant_override("outline_size", 4 if enabled else 0)
	for child: Node in node.get_children():
		apply_contrast_recursive(child, enabled)
