class_name GameplayHudPresenter
extends RefCounted


static func format_resources(state: Dictionary, translate: Callable) -> String:
	return "\n".join(PackedStringArray([
		_text(translate, "HUD_RESOURCES"),
		_text(translate, "RESOURCE_BONES") + ": " + str(int(state.get("bones", 0))),
		_text(translate, "RESOURCE_FLESH") + ": " + str(int(state.get("flesh", 0))),
		_text(translate, "RESOURCE_BLOOD") + ": " + str(int(state.get("blood", 0))),
		_text(translate, "RESOURCE_SOULS") + ": " + str(int(state.get("souls", 0))),
	]))


static func format_metrics(state: Dictionary, translate: Callable) -> String:
	var rows: Array = [
		["METRICS_ENEMIES_KILLED", "enemies_killed"],
		["METRICS_CORPSES_PROCESSED", "corpses_processed"],
		["METRICS_SKELETONS_BUILT", "skeletons_built"],
		["METRICS_SKELETONS_LOST", "skeletons_lost"],
		["METRICS_ZOMBIES_BUILT", "zombies_built"],
		["METRICS_ZOMBIES_LOST", "zombies_lost"],
		["METRICS_GHOSTS_BUILT", "ghosts_built"],
		["METRICS_GHOSTS_LOST", "ghosts_lost"],
		["METRICS_LICHES_BUILT", "liches_built"],
		["METRICS_LICHES_LOST", "liches_lost"],
		["METRICS_THRALLS_ACTIVE", "thralls_active"],
		["METRICS_ARMY_ACTIVE", "army_active"],
	]
	var lines: PackedStringArray = [_text(translate, "METRICS_TITLE"), ""]
	for row_value: Variant in rows:
		var row: Array = row_value as Array
		lines.append(
			_text(translate, str(row[0])) + ": "
			+ str(int(state.get(str(row[1]), 0)))
		)
	return "\n".join(lines)


static func format_wave(state: Dictionary, translate: Callable) -> String:
	if bool(state.get("run_finished", false)):
		return (
			_text(translate, "RUN_COMPLETE") + "\n"
			+ _text(translate, "RUN_VICTORY" if bool(state.get("won", false)) else "RUN_DEFEAT")
		)
	var title: String = str(state.get("title", ""))
	if bool(state.get("event_pending", false)):
		return title + "\n" + _text(translate, "EVENT_DECISION_PENDING")
	if bool(state.get("transition", false)):
		return (
			title + " " + _text(translate, "WAVE_COMPLETE") + "\n"
			+ _text(translate, "WAVE_SELECT_UPGRADE")
		)
	return (
		title + "\n"
		+ _text(translate, "WAVE_ENEMIES_REMAINING") + ": "
		+ str(int(state.get("remaining", 0))) + " / " + str(int(state.get("total", 0)))
		+ " | " + _text(translate, "WAVE_ACTIVE") + ": "
		+ str(int(state.get("active", 0))) + " / " + str(int(state.get("max_active", 0)))
		+ "\n" + _text(translate, "WAVE_PRIMARY") + ": "
		+ str(state.get("primary", ""))
		+ " | " + _text(translate, "STAT_HP") + ": " + str(int(state.get("hp", 0)))
		+ " | " + _text(translate, "STAT_DAMAGE") + ": " + str(int(state.get("damage", 0)))
	)


static func _text(translate: Callable, key: String) -> String:
	return str(translate.call(key))
