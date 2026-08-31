extends Node


const GAME_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const ACCENT: Color = Color("55d83e")
const PANEL: Color = Color(0.018, 0.024, 0.022, 0.98)
const BORDER: Color = Color(0.32, 0.31, 0.25, 1.0)
const META_STORE: Script = preload("res://scripts/core/meta_progression_store.gd")
const CODEX_CATALOG: Script = preload("res://scripts/game/codex_catalog.gd")

var current_game: Node = null
var settings: Dictionary = {}
var options_return_to_pause: bool = false

var ui_layer: CanvasLayer
var main_menu: Control
var prologue_menu: Control
var pause_menu: Control
var options_menu: Control
var codex_menu: Control
var continue_button: Button
var title_label: Label
var subtitle_label: Label
var prologue_title: Label
var prologue_body: Label
var pause_title: Label
var options_title: Label
var language_label: Label
var volume_label: Label
var fullscreen_check: CheckButton
var language_option: OptionButton
var volume_slider: HSlider
var options_apply_button: Button
var options_back_button: Button
var codex_title: Label
var codex_content: Label
var profile: Dictionary = {}
var localized_buttons: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings = SettingsStore.apply_settings(SettingsStore.load_settings())
	profile = META_STORE.load_profile()
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
	if options_menu.visible:
		close_options()
	elif codex_menu.visible:
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
	var main_box := create_center_panel(main_menu, Vector2(620.0, 720.0))
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

	options_menu = create_screen("OptionsMenu", Color(0.0, 0.0, 0.0, 0.84))
	var options_box := create_center_panel(options_menu, Vector2(640.0, 610.0))
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
	fullscreen_check = CheckButton.new()
	fullscreen_check.custom_minimum_size = Vector2(0.0, 48.0)
	options_box.add_child(fullscreen_check)
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

	prologue_menu.visible = false
	pause_menu.visible = false
	options_menu.visible = false
	codex_menu.visible = false


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
	options_title.text = tr("OPTIONS_TITLE")
	codex_title.text = tr("CODEX_TITLE")
	language_label.text = tr("OPTIONS_LANGUAGE")
	volume_label.text = tr("OPTIONS_MASTER_VOLUME")
	fullscreen_check.text = tr("OPTIONS_FULLSCREEN")
	for button_value: Variant in localized_buttons:
		var button: Button = button_value as Button
		if is_instance_valid(button):
			button.text = tr(str(localized_buttons[button_value]))
	refresh_codex_content()


func show_main_menu() -> void:
	get_tree().paused = false
	main_menu.visible = true
	prologue_menu.visible = false
	pause_menu.visible = false
	options_menu.visible = false
	codex_menu.visible = false
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
	codex_content.text = "\n\n".join(sections)


func confirm_new_run() -> void:
	RunSaveStore.delete_checkpoint()
	start_game({})


func continue_run() -> void:
	var checkpoint: Dictionary = RunSaveStore.load_checkpoint()
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
	current_game.restart_requested.connect(restart_game)
	current_game.return_to_menu_requested.connect(return_to_menu)
	main_menu.visible = false
	prologue_menu.visible = false
	pause_menu.visible = false
	options_menu.visible = false
	codex_menu.visible = false
	if not checkpoint.is_empty():
		current_game.restore_checkpoint_state(checkpoint)


func save_checkpoint(state: Dictionary) -> void:
	RunSaveStore.save_checkpoint(state)
	META_STORE.merge_discoveries(
		profile, state.get("narrative", {}).get("discoveries", {}) as Dictionary
	)
	META_STORE.save_profile(profile)


func on_run_completed(victory: bool) -> void:
	RunSaveStore.delete_checkpoint()
	if is_instance_valid(current_game):
		META_STORE.merge_discoveries(profile, current_game.lore_discoveries)
		META_STORE.record_run(profile, {
			"victory": victory,
			"wave": current_game.current_wave,
			"enemies_killed": current_game.total_enemies_killed,
			"army_remaining": current_game.get_total_undead_count(),
		})
		META_STORE.save_profile(profile)


func pause_game() -> void:
	if current_game == null:
		return
	get_tree().paused = true
	pause_menu.visible = true


func resume_game() -> void:
	pause_menu.visible = false
	options_menu.visible = false
	get_tree().paused = false


func save_and_return_to_menu() -> void:
	if is_instance_valid(current_game):
		save_checkpoint(current_game.build_checkpoint_state())
		current_game.queue_free()
	current_game = null
	show_main_menu()


func return_to_menu() -> void:
	if is_instance_valid(current_game):
		current_game.queue_free()
	current_game = null
	show_main_menu()


func restart_game() -> void:
	RunSaveStore.delete_checkpoint()
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
	var locale: String = LocalizationService.normalize_locale(str(settings.locale))
	language_option.select({"en": 0, "pt_BR": 1, "es": 2}.get(locale, 0))
	volume_slider.value = float(settings.master_volume)
	fullscreen_check.button_pressed = bool(settings.fullscreen)


func apply_options() -> void:
	var locales: PackedStringArray = ["en", "pt_BR", "es"]
	settings = {
		"locale": locales[language_option.selected],
		"master_volume": volume_slider.value,
		"fullscreen": fullscreen_check.button_pressed,
	}
	settings = SettingsStore.apply_settings(settings)
	SettingsStore.save_settings(settings)
	refresh_localized_text()


func close_options() -> void:
	options_menu.visible = false
	if options_return_to_pause and current_game != null:
		pause_menu.visible = true
	else:
		main_menu.visible = true


func quit_game() -> void:
	get_tree().quit()
