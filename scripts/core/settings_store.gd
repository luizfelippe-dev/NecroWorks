class_name SettingsStore
extends RefCounted


const SETTINGS_VERSION: int = 1
const DEFAULT_PATH: String = "user://necroworks_settings.cfg"


static func get_defaults() -> Dictionary:
	return {
		"version": SETTINGS_VERSION,
		"locale": LocalizationService.DEFAULT_LOCALE,
		"master_volume": 0.8,
		"fullscreen": false,
	}


static func load_settings(path: String = DEFAULT_PATH) -> Dictionary:
	var result: Dictionary = get_defaults()
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return result
	if int(config.get_value("meta", "version", -1)) != SETTINGS_VERSION:
		return result

	result.locale = LocalizationService.normalize_locale(
		str(config.get_value("general", "locale", result.locale))
	)
	result.master_volume = clampf(
		float(config.get_value("audio", "master_volume", result.master_volume)),
		0.0,
		1.0
	)
	result.fullscreen = bool(
		config.get_value("display", "fullscreen", result.fullscreen)
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
	sanitized.fullscreen = bool(
		settings.get("fullscreen", sanitized.fullscreen)
	)

	var config := ConfigFile.new()
	config.set_value("meta", "version", SETTINGS_VERSION)
	config.set_value("general", "locale", sanitized.locale)
	config.set_value("audio", "master_volume", sanitized.master_volume)
	config.set_value("display", "fullscreen", sanitized.fullscreen)
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
	sanitized.fullscreen = bool(
		settings.get("fullscreen", sanitized.fullscreen)
	)

	var master_bus: int = AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_db(
			master_bus,
			linear_to_db(maxf(float(sanitized.master_volume), 0.0001))
		)
		AudioServer.set_bus_mute(master_bus, sanitized.master_volume <= 0.0)

	if apply_display and not DisplayServer.get_name().to_lower().contains("headless"):
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
			if sanitized.fullscreen
			else DisplayServer.WINDOW_MODE_WINDOWED
		)

	return sanitized
