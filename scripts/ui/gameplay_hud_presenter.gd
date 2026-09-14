class_name GameplayHudPresenter
extends RefCounted


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
