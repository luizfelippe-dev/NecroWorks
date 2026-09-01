extends SceneTree


const PRESENTER: Script = preload("res://scripts/ui/gameplay_hud_presenter.gd")


func _initialize() -> void:
	var identity := func(key: String) -> String: return key
	var resources: String = PRESENTER.format_resources({
		"bones": 8, "flesh": 2, "blood": 1, "souls": 3,
	}, identity)
	assert(resources.contains("RESOURCE_BONES: 8"))
	var metrics: String = PRESENTER.format_metrics({
		"enemies_killed": 12, "army_active": 4,
	}, identity)
	assert(metrics.contains("METRICS_ENEMIES_KILLED: 12"))
	assert(metrics.contains("METRICS_ARMY_ACTIVE: 4"))
	var wave: String = PRESENTER.format_wave({
		"title": "HUD_WAVE 8", "remaining": 3, "total": 11,
		"active": 2, "max_active": 2, "primary": "MAGE", "hp": 80,
		"damage": 14,
	}, identity)
	assert(wave.contains("WAVE_ENEMIES_REMAINING: 3 / 11"))
	assert(wave.contains("WAVE_PRIMARY: MAGE"))
	print("GAMEPLAY HUD PRESENTER VALIDATION: PASS")
	quit()
