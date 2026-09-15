class_name GameplayTutorialGuide
extends PanelContainer


signal completed
signal dismissed

const UI_THEME: Script = preload("res://scripts/ui/necro_ui_theme.gd")
const EVENTS: Array[String] = [
	"enemy_defeated",
	"corpse_queued",
	"corpse_processed",
	"production_queued",
	"production_completed",
]

var step: int = 0
var active: bool = false
var cycle_completed: bool = false
var observed: Dictionary = {}
var title_label: Label
var progress_label: Label
var objective_label: Label
var dismiss_button: Button


func _ready() -> void:
	name = "GameplayTutorialGuide"
	position = Vector2(20.0, 550.0)
	size = Vector2(360.0, 178.0)
	z_index = 440
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_stylebox_override(
		"panel", UI_THEME.stylebox(
			Color(0.018, 0.024, 0.022, 0.97), UI_THEME.GREEN, 2, 4
		)
	)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	add_child(content)
	title_label = _label(17, UI_THEME.GREEN)
	content.add_child(title_label)
	progress_label = _label(12, UI_THEME.MUTED)
	content.add_child(progress_label)
	objective_label = _label(15, UI_THEME.IVORY)
	objective_label.custom_minimum_size.y = 58.0
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(objective_label)
	dismiss_button = Button.new()
	dismiss_button.custom_minimum_size.y = 34.0
	dismiss_button.add_theme_font_size_override("font_size", 12)
	dismiss_button.pressed.connect(_dismiss)
	UI_THEME.style_button(dismiss_button, UI_THEME.BRONZE)
	content.add_child(dismiss_button)
	hide()


func configure(enabled: bool, snapshot: Dictionary = {}) -> void:
	active = enabled
	cycle_completed = false
	observed.clear()
	if not active:
		hide()
		return
	step = infer_step(snapshot)
	for completed_step: int in range(step):
		observed[EVENTS[completed_step]] = true
	if step >= EVENTS.size():
		_complete()
		return
	show()
	refresh_text()


func infer_step(snapshot: Dictionary) -> int:
	if int(snapshot.get("units_produced", 0)) > 0:
		return EVENTS.size()
	if int(snapshot.get("production_queued", 0)) > 0:
		return 4
	if int(snapshot.get("corpses_processed", 0)) > 0:
		return 3
	if int(snapshot.get("corpses_queued", 0)) > 0:
		return 2
	if int(snapshot.get("corpses_available", 0)) > 0 or int(
		snapshot.get("enemies_defeated", 0)
	) > 0:
		return 1
	return 0


func record_event(event_id: String) -> bool:
	if not active or cycle_completed or step >= EVENTS.size():
		return false
	if event_id not in EVENTS:
		return false
	observed[event_id] = true
	var previous_step: int = step
	while step < EVENTS.size() and bool(observed.get(EVENTS[step], false)):
		step += 1
	if step == previous_step:
		return false
	if step >= EVENTS.size():
		_complete()
	else:
		refresh_text()
	return true


func refresh_text() -> void:
	if title_label == null:
		return
	title_label.text = tr("CONTEXT_TUTORIAL_TITLE")
	if cycle_completed:
		progress_label.text = tr("CONTEXT_TUTORIAL_COMPLETE_TITLE")
		objective_label.text = tr("CONTEXT_TUTORIAL_COMPLETE_BODY")
		dismiss_button.text = tr("CONTEXT_TUTORIAL_CLOSE")
		return
	progress_label.text = tr("CONTEXT_TUTORIAL_PROGRESS") % [step + 1, EVENTS.size()]
	objective_label.text = tr("CONTEXT_TUTORIAL_STEP_%d" % [step + 1])
	dismiss_button.text = tr("CONTEXT_TUTORIAL_DISMISS")


func _complete() -> void:
	cycle_completed = true
	active = false
	show()
	refresh_text()
	completed.emit()


func _dismiss() -> void:
	hide()
	if not cycle_completed:
		active = false
		dismissed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		refresh_text()


func _label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_override("font", UI_THEME.BODY_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
