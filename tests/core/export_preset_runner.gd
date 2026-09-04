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
	var excluded: String = str(config.get_value("preset.0", "exclude_filter", ""))
	assert(excluded.contains("assets/reference/*"))
	assert(excluded.contains("assets/sprites/animation_concepts/*"))
	assert(excluded.contains("assets/sprites/units/skeleton_prototype.png"))
	assert(excluded.contains("assets/sprites/units/zombie_prototype.png"))
	assert(excluded.contains("assets/sprites/units/human_warrior_prototype.png"))
	assert(excluded.contains("assets/sprites/units/mage_prototype.png"))
	assert(excluded.contains("assets/sprites/units/elf_prototype.png"))
	assert(excluded.contains("assets/sprites/bosses/grave_marshal_prototype.png"))
	assert(excluded.contains("tests/*"))
	assert(excluded.contains("docs/*"))
	assert(
		str(config.get_value("preset.0.options", "application/product_name", ""))
		== "NecroWorks"
	)
	print("WINDOWS EXPORT PRESET VALIDATION: PASS")
	quit()
