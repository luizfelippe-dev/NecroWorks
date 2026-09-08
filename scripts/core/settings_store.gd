class_name SettingsStore
extends RefCounted


const SETTINGS_VERSION: int = 3
const DEFAULT_PATH: String = "user://necroworks_settings.cfg"


static func get_defaults() -> Dictionary:
	return {
		"version": SETTINGS_VERSION,
		"locale": LocalizationService.DEFAULT_LOCALE,
		"master_volume": 0.8,
		"music_volume": 0.65,
		"sfx_volume": 0.85,
		"ui_volume": 0.8,
		"fullscreen": false,
		"reduced_motion": false,
		"high_contrast": false,
		"tutorial_enabled": true,
		"tutorial_completed": false,
	}


static func load_settings(path: String = DEFAULT_PATH) -> Dictionary:
	var result: Dictionary = get_defaults()
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return result
	var stored_version: int = int(config.get_value("meta", "version", -1))
	if stored_version < 1 or stored_version > SETTINGS_VERSION:
		return result

	result.locale = LocalizationService.normalize_locale(
		str(config.get_value("general", "locale", result.locale))
	)
	result.master_volume = clampf(
		float(config.get_value("audio", "master_volume", result.master_volume)),
		0.0,
		1.0
	)
	result.music_volume = _read_volume(config, "music_volume", result.music_volume)
	result.sfx_volume = _read_volume(config, "sfx_volume", result.sfx_volume)
	result.ui_volume = _read_volume(config, "ui_volume", result.ui_volume)
	result.fullscreen = bool(
		config.get_value("display", "fullscreen", result.fullscreen)
	)
	result.reduced_motion = bool(
		config.get_value("accessibility", "reduced_motion", result.reduced_motion)
	)
	result.high_contrast = bool(
		config.get_value("accessibility", "high_contrast", result.high_contrast)
	)
	result.tutorial_enabled = bool(
		config.get_value("tutorial", "enabled", result.tutorial_enabled)
	)
	result.tutorial_completed = bool(
		config.get_value("tutorial", "completed", result.tutorial_completed)
	)
	return result


static func save_settings(
	settings: Dictionary,
	path: String = DEFAULT_PATH
) -> Error:
	var sanitized: Dictionary = get_defaults()
	sanitized.locale = LocalizationService.normalize_locale(
		str(settings.get("locale", sanitized.locale))
	)
	sanitized.master_volume = clampf(
		float(settings.get("master_volume", sanitized.master_volume)),
		0.0,
		1.0
	)
	sanitized.music_volume = _sanitize_volume(settings, "music_volume", sanitized.music_volume)
	sanitized.sfx_volume = _sanitize_volume(settings, "sfx_volume", sanitized.sfx_volume)
	sanitized.ui_volume = _sanitize_volume(settings, "ui_volume", sanitized.ui_volume)
	sanitized.fullscreen = bool(
		settings.get("fullscreen", sanitized.fullscreen)
	)
	sanitized.reduced_motion = bool(settings.get(
		"reduced_motion", sanitized.reduced_motion
	))
	sanitized.high_contrast = bool(settings.get(
		"high_contrast", sanitized.high_contrast
	))
	sanitized.tutorial_enabled = bool(settings.get(
		"tutorial_enabled", sanitized.tutorial_enabled
	))
	sanitized.tutorial_completed = bool(settings.get(
		"tutorial_completed", sanitized.tutorial_completed
	))

	var config := ConfigFile.new()
	config.set_value("meta", "version", SETTINGS_VERSION)
	config.set_value("general", "locale", sanitized.locale)
	config.set_value("audio", "master_volume", sanitized.master_volume)
	config.set_value("audio", "music_volume", sanitized.music_volume)
	config.set_value("audio", "sfx_volume", sanitized.sfx_volume)
	config.set_value("audio", "ui_volume", sanitized.ui_volume)
	config.set_value("display", "fullscreen", sanitized.fullscreen)
	config.set_value("accessibility", "reduced_motion", sanitized.reduced_motion)
	config.set_value("accessibility", "high_contrast", sanitized.high_contrast)
	config.set_value("tutorial", "enabled", sanitized.tutorial_enabled)
	config.set_value("tutorial", "completed", sanitized.tutorial_completed)
	return config.save(path)


static func apply_settings(
	settings: Dictionary,
	apply_display: bool = true
) -> Dictionary:
	var sanitized: Dictionary = get_defaults()
	sanitized.locale = LocalizationService.set_locale(
		str(settings.get("locale", sanitized.locale))
	)
	sanitized.master_volume = clampf(
		float(settings.get("master_volume", sanitized.master_volume)),
		0.0,
		1.0
	)
	sanitized.music_volume = _sanitize_volume(settings, "music_volume", sanitized.music_volume)
	sanitized.sfx_volume = _sanitize_volume(settings, "sfx_volume", sanitized.sfx_volume)
	sanitized.ui_volume = _sanitize_volume(settings, "ui_volume", sanitized.ui_volume)
	sanitized.fullscreen = bool(
		settings.get("fullscreen", sanitized.fullscreen)
	)
	sanitized.reduced_motion = bool(settings.get(
		"reduced_motion", sanitized.reduced_motion
	))
	sanitized.high_contrast = bool(settings.get(
		"high_contrast", sanitized.high_contrast
	))
	sanitized.tutorial_enabled = bool(settings.get(
		"tutorial_enabled", sanitized.tutorial_enabled
	))
	sanitized.tutorial_completed = bool(settings.get(
		"tutorial_completed", sanitized.tutorial_completed
	))

	_apply_bus_volume("Master", float(sanitized.master_volume))
	_apply_bus_volume("Music", float(sanitized.music_volume))
	_apply_bus_volume("SFX", float(sanitized.sfx_volume))
	_apply_bus_volume("UI", float(sanitized.ui_volume))

	if apply_display and not DisplayServer.get_name().to_lower().contains("headless"):
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
			if sanitized.fullscreen
			else DisplayServer.WINDOW_MODE_WINDOWED
		)

	return sanitized


static func _read_volume(config: ConfigFile, key: String, fallback: float) -> float:
	return clampf(float(config.get_value("audio", key, fallback)), 0.0, 1.0)


static func _sanitize_volume(settings: Dictionary, key: String, fallback: float) -> float:
	return clampf(float(settings.get(key, fallback)), 0.0, 1.0)


static func _apply_bus_volume(bus_name: String, volume: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(bus_index, volume <= 0.0)
