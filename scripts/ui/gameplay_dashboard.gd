extends Node

const UI: Script = preload("res://scripts/ui/necro_ui_theme.gd")
const GLYPH: Script = preload("res://scripts/ui/resource_glyph.gd")
const SPRITES: Script = preload("res://scripts/visual/unit_sprite_catalog.gd")
const RESOURCE_IDS := ["bones", "flesh", "blood", "souls"]
const RESOURCE_COLORS := [UI.IVORY, Color("d78a72"), Color("e56e70"), UI.SOUL]
const METRIC_KEYS := [
	"METRICS_ENEMIES_KILLED", "METRICS_CORPSES_PROCESSED", "METRICS_SKELETONS_BUILT",
	"METRICS_SKELETONS_LOST", "METRICS_ZOMBIES_BUILT", "METRICS_ZOMBIES_LOST",
	"METRICS_GHOSTS_BUILT", "METRICS_GHOSTS_LOST", "METRICS_LICHES_BUILT",
	"METRICS_LICHES_LOST", "METRICS_THRALLS_ACTIVE", "METRICS_ARMY_ACTIVE",
]
var game: Node
var resource_values: Array[Label] = []
var resource_names: Array[Label] = []
var metric_values: Array[Label] = []
var metric_names: Array[Label] = []
var wave_progress: ProgressBar
var production_progress: ProgressBar
var processing_progress: ProgressBar
var metric_title: Label
var resources_title: Label
var refresh_time: float = 0.0
var last_resources: Array = []
var last_metrics: Array = []
var history_visible: bool = false
var history_toggle: Button
var operations_label: Label
var flow_label: Label


func bind(target: Node) -> void:
	game = target
	for panel_name: String in ["WavePanel", "MetricsPanel", "SynergyPanel", "ResourcesPanel", "ProductionPanel", "ProcessingPanel"]:
		var panel: Control = game.get_node(panel_name)
		panel.add_theme_stylebox_override("panel", UI.stylebox(Color("101714ed"), UI.BRONZE))
		UI.decorate_panel(panel)
	_build_resources()
	_build_metrics()
	_build_operations()
	wave_progress = _bar(game.get_node("WavePanel"), Rect2(24, 119, 572, 7), UI.GREEN)
	production_progress = _bar(game.get_node("ProductionPanel"), Rect2(24, 163, 652, 4), UI.GREEN)
	processing_progress = _bar(game.get_node("ProcessingPanel"), Rect2(24, 160, 767, 4), UI.SOUL)
	game.brand_label.add_theme_font_override("font", UI.DISPLAY_FONT)
	game.brand_label.add_theme_font_size_override("font_size", 36)
	game.brand_label.add_theme_color_override("font_color", UI.IVORY)
	var tagline: Label = game.get_node("TaglineLabel")
	tagline.add_theme_font_override("font", UI.BODY_FONT)
	tagline.add_theme_font_size_override("font_size", 19)
	tagline.add_theme_color_override("font_color", UI.MUTED)
	tagline.size.x = 440.0
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game.wave_label.add_theme_font_override("font", UI.BODY_FONT)
	game.wave_label.add_theme_font_size_override("font_size", 22)
	game.wave_label.add_theme_color_override("font_color", UI.IVORY)
	game.wave_label.size.y = 94.0
	game.synergy_label.add_theme_font_override("font", UI.BODY_FONT)
	game.synergy_label.add_theme_font_size_override("font_size", 17)
	game.synergy_label.add_theme_color_override("font_color", UI.IVORY)
	var synergy_scroll := ScrollContainer.new()
	synergy_scroll.name = "SynergyScroll"
	game.get_node("SynergyPanel").add_child(synergy_scroll)
	synergy_scroll.position = Vector2(18, 15)
	synergy_scroll.size = Vector2(319, 300)
	synergy_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	synergy_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	game.synergy_label.reparent(synergy_scroll, false)
	game.synergy_label.position = Vector2.ZERO
	game.synergy_label.size = Vector2(300, 0)
	game.synergy_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game.synergy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game.factory_title_label.add_theme_font_override("font", UI.DISPLAY_FONT)
	game.factory_title_label.add_theme_font_size_override("font_size", 18)
	game.factory_title_label.size.y = 30.0
	game.production_quantity_selector.position.y = 884.0
	game.processing_label.add_theme_font_override("font", UI.BODY_FONT)
	game.processing_label.add_theme_font_size_override("font_size", 18)
	game.production_queue_label.add_theme_font_override("font", UI.BODY_FONT)
	game.production_queue_label.add_theme_font_size_override("font_size", 14)
	game.production_queue_label.position.y = 986.0
	game.production_queue_label.size.y = 18.0
	game.production_queue_label.add_theme_font_size_override("font_size", 13)
	var buttons: Array = [game.create_skeleton_button, game.create_skeleton_archer_button, game.create_zombie_button]
	var ids: Array[String] = ["skeleton", "skeleton_archer", "zombie"]
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		button.icon = SPRITES.get_texture(ids[index])
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 30)
		button.add_theme_constant_override("h_separation", 5)
		button.add_theme_font_size_override("font_size", 16)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.position.y = 924.0
		button.size.y = 60.0
		for style_name: String in ["normal", "hover", "pressed", "disabled"]:
			var style: StyleBoxFlat = button.get_theme_stylebox(style_name).duplicate()
			style.content_margin_top = 4.0
			style.content_margin_bottom = 4.0
			style.content_margin_left = 6.0
			style.content_margin_right = 6.0
			button.add_theme_stylebox_override(style_name, style)
	for navigation: Button in [game.factory_nav_button, game.doctrine_nav_button, game.ritual_nav_button, game.fusion_nav_button]:
		navigation.add_theme_font_size_override("font_size", 20)
		UI.decorate_panel(navigation)
	_refresh_localization()
	_refresh()


func _build_resources() -> void:
	var panel: Control = game.resources_panel
	resources_title = _label(panel, Rect2(20, 12, 280, 24), 17, UI.MUTED)
	for index: int in range(4):
		var at := Vector2(17 + (index % 2) * 152, 45 + (index / 2) * 58)
		var cell := Panel.new()
		cell.name = "Resource_" + RESOURCE_IDS[index]
		panel.add_child(cell)
		cell.position = at
		cell.size = Vector2(144, 54)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_theme_stylebox_override("panel", UI.stylebox(Color("1a211e"), Color("313d30"), 1))
		var icon := GLYPH.new() as Control
		icon.set("kind", RESOURCE_IDS[index])
		icon.set("tint", RESOURCE_COLORS[index])
		cell.add_child(icon)
		icon.position = Vector2(6, 9)
		icon.size = Vector2(34, 34)
		resource_names.append(_label(cell, Rect2(47, 3, 88, 20), 14, UI.MUTED))
		resource_values.append(_label(cell, Rect2(47, 19, 88, 32), 27, RESOURCE_COLORS[index]))


func _build_metrics() -> void:
	var panel: Control = game.get_node("MetricsPanel")
	metric_title = _label(panel, Rect2(22, 14, 310, 29), 20, UI.IVORY)
	metric_title.add_theme_font_override("font", UI.DISPLAY_FONT)
	metric_title.add_theme_font_size_override("font_size", 17)
	for index: int in range(METRIC_KEYS.size()):
		var y := 53.0 + index * 24.0
		if index % 2 == 0:
			var stripe := ColorRect.new()
			stripe.color = Color(0.5, 0.6, 0.45, 0.045)
			stripe.position = Vector2(15, y)
			stripe.size = Vector2(325, 24)
			stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
			panel.add_child(stripe)
		var name_label := _label(panel, Rect2(23, y, 259, 24), 18, UI.IVORY)
		metric_names.append(name_label)
		var value := _label(panel, Rect2(280, y, 48, 24), 20, UI.IVORY)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		metric_values.append(value)


func _process(delta: float) -> void:
	if not is_instance_valid(game):
		return
	refresh_time += delta
	if refresh_time >= 0.10:
		refresh_time = 0.0
		_refresh()
	if wave_progress != null:
		wave_progress.value = 100.0 * (1.0 - float(game.get_enemies_remaining()) / maxf(1.0, game.enemies_total_this_wave))
		processing_progress.value = 0.0 if game.corpse_processing_queue.is_empty() else 100.0 * (1.0 - game.corpse_processor_timer / maxf(0.01, game.corpse_processor_seconds_per_corpse))
		production_progress.value = 0.0 if game.skeleton_production_queue.is_empty() else 100.0 * (1.0 - game.skeleton_assembler_timer / maxf(0.01, game.SKELETON_ASSEMBLER_BASE_SECONDS))
		if game.skeleton_production_queue.is_empty() and not game.zombie_production_queue.is_empty():
			production_progress.value = 100.0 * (1.0 - game.flesh_vat_timer / maxf(0.01, game.FLESH_VAT_BASE_SECONDS))


func _refresh() -> void:
	_refresh_operations()
	var resources: Array = [game.bones, game.flesh, game.blood, game.souls]
	if resources != last_resources:
		for index: int in range(resources.size()):
			resource_values[index].text = str(resources[index])
		last_resources = resources
	var values: Array = [
		game.total_enemies_killed, game.total_corpses_processed, game.total_skeletons_created,
		game.total_skeletons_lost, game.total_zombies_created, game.total_zombies_lost,
		game.total_ghosts_created, game.total_ghosts_lost, game.total_liches_created,
		game.total_liches_lost, game.get_temporary_thrall_count(), game.get_total_undead_count(),
	]
	if values != last_metrics:
		for index: int in range(values.size()):
			metric_values[index].text = str(values[index])
		last_metrics = values


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and resources_title != null:
		_refresh_localization()


func _refresh_localization() -> void:
	resources_title.text = tr("HUD_RESOURCES")
	metric_title.text = tr("METRICS_TITLE")
	_refresh_operations()
	for index: int in range(RESOURCE_IDS.size()):
		resource_names[index].text = tr("RESOURCE_" + RESOURCE_IDS[index].to_upper())
	for index: int in range(METRIC_KEYS.size()):
		metric_names[index].text = tr(METRIC_KEYS[index])
	(game.get_node("TaglineLabel") as Label).text = tr("GAME_TAGLINE")
	for button: Button in [game.create_skeleton_button, game.create_skeleton_archer_button, game.create_zombie_button]:
		button.tooltip_text = tr("PRODUCTION_QUEUE_TOOLTIP")


func _build_operations() -> void:
	var panel: Control = game.get_node("MetricsPanel")
	metric_title.hide()
	history_toggle = Button.new()
	panel.add_child(history_toggle)
	history_toggle.position = Vector2(18, 10)
	history_toggle.size = Vector2(319, 36)
	history_toggle.add_theme_font_override("font", UI.BODY_FONT)
	history_toggle.add_theme_font_size_override("font_size", 18)
	UI.style_button(history_toggle, UI.BRONZE)
	history_toggle.pressed.connect(func() -> void:
		history_visible = not history_visible
		_refresh_operations()
	)
	operations_label = _label(panel, Rect2(23, 57, 302, 200), 21, UI.IVORY)
	operations_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flow_label = _label(panel, Rect2(23, 262, 302, 84), 20, UI.GREEN)
	flow_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flow_label.clip_text = true
	_refresh_operations()


func _refresh_operations() -> void:
	if operations_label == null:
		return
	history_toggle.text = tr("HUD_SHOW_OPERATIONS" if history_visible else "HUD_SHOW_HISTORY")
	for label: Label in metric_names + metric_values:
		label.visible = history_visible
	operations_label.visible = not history_visible
	flow_label.visible = not history_visible
	if history_visible:
		return
	var state: Dictionary = game.get_factory_flow_snapshot()
	var text: String = tr("HUD_OPERATION_ARMY") % [game.get_total_undead_count(), game.MAX_UNDEAD, game.get_total_queued_undead()]
	text += "\n" + tr("HUD_OPERATION_COMPOSITION") % [
		game.skeletons.size() - game.get_skeleton_archer_count(), game.get_skeleton_archer_count(),
		game.zombies.size(), game.ghosts.size(), game.liches.size(), game.get_temporary_thrall_count(),
	]
	text += "\n" + tr("HUD_OPERATION_PROCESSOR") % [state.processor_queued, state.processor_capacity, state.waiting_corpses]
	text += "\n" + tr("HUD_OPERATION_SOULS") % [state.soul_queued]
	if operations_label.text != text:
		operations_label.text = text
	var flow: String = game.FACTORY_FLOW_PRESENTER.format(state, Callable(self, "tr"))
	if flow_label.text != flow:
		flow_label.text = flow


func _bar(parent: Control, rect: Rect2, tint: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = rect.position
	bar.size = rect.size
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background: StyleBoxFlat = UI.stylebox(Color("080d0a"), Color("303e29"), 1, 1)
	var fill: StyleBoxFlat = UI.stylebox(tint.darkened(0.1), tint, 0, 1)
	for style: StyleBoxFlat in [background, fill]:
		style.content_margin_top = 0
		style.content_margin_bottom = 0
		style.content_margin_left = 0
		style.content_margin_right = 0
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	parent.add_child(bar)
	# The initial default theme has a larger minimum; resize only after replacing it.
	bar.size = rect.size
	return bar


func _label(parent: Control, rect: Rect2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", UI.BODY_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	parent.add_child(label)
	return label
