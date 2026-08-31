extends SceneTree


func _initialize() -> void:
	var config: ConfigFile = ConfigFile.new()
	assert(config.load("res://export_presets.cfg") == OK)
	assert(str(config.get_value("preset.0", "name", "")) == "Windows Desktop")
	assert(bool(config.get_value("preset.0", "runnable", false)))
	assert(
		str(config.get_value("preset.0", "export_path", ""))
		== "builds/windows/NecroWorks.exe"
	)
	assert(
		str(config.get_value("preset.0.options", "application/product_name", ""))
		== "NecroWorks"
	)
	print("WINDOWS EXPORT PRESET VALIDATION: PASS")
	quit()
