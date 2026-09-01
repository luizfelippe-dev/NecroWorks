class_name GameplayPanelCoordinator
extends RefCounted


var panels: Dictionary = {}


func register(panel_id: String, panel: Control) -> void:
	if panel_id.is_empty() or panel == null:
		return
	panels[panel_id] = panel


func is_open(panel_id: String) -> bool:
	var panel: Control = panels.get(panel_id) as Control
	return is_instance_valid(panel) and panel.visible


func close_all(except_id: String = "") -> void:
	for panel_id_value: Variant in panels:
		var panel_id: String = str(panel_id_value)
		var panel: Control = panels[panel_id_value] as Control
		if is_instance_valid(panel) and panel_id != except_id:
			panel.visible = false


func show_exclusive(panel_id: String) -> bool:
	var panel: Control = panels.get(panel_id) as Control
	if not is_instance_valid(panel):
		return false
	close_all(panel_id)
	panel.visible = true
	return true


func toggle_exclusive(panel_id: String, blocked_by: PackedStringArray = []) -> bool:
	var panel: Control = panels.get(panel_id) as Control
	if not is_instance_valid(panel):
		return false
	for blocker_id: String in blocked_by:
		if is_open(blocker_id):
			panel.visible = false
			return false
	var should_open: bool = not panel.visible
	close_all(panel_id if should_open else "")
	panel.visible = should_open
	return panel.visible
