extends SceneTree


const PRESENTER: Script = preload("res://scripts/ui/gameplay_hud_presenter.gd")


func _initialize() -> void:
	var identity := func(key: String) -> String: return key
	var wave: String = PRESENTER.format_wave({
		"title": "HUD_WAVE 8", "remaining": 3, "total": 11,
		"active": 2, "max_active": 2, "primary": "MAGE", "hp": 80,
		"damage": 14,
	}, identity)
	assert(wave.contains("WAVE_ENEMIES_REMAINING: 3 / 11"))
	assert(wave.contains("WAVE_PRIMARY: MAGE"))
	assert(PRESENTER.format_wave({"event_pending": true}, identity).contains("EVENT_DECISION_PENDING"))
	assert(PRESENTER.format_wave({"transition": true}, identity).contains("WAVE_SELECT_UPGRADE"))
	assert(PRESENTER.format_wave({"preparation": true}, identity).contains("WAVE_PREPARATION_STATUS"))
	assert(PRESENTER.format_wave({"run_finished": true, "won": true}, identity).contains("RUN_VICTORY"))
	assert(PRESENTER.format_wave({"run_finished": true, "won": false}, identity).contains("RUN_DEFEAT"))
	print("GAMEPLAY HUD PRESENTER VALIDATION: PASS")
	quit()
