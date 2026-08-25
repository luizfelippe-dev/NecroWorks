extends SceneTree


const CATALOG: Script = preload("res://scripts/game/upgrade_catalog.gd")
const FORMATTER: Script = preload("res://scripts/ui/upgrade_status_formatter.gd")


func _initialize() -> void:
	var state: Dictionary = {
		"skeleton_damage": 17,
		"bone_harvest_chance": 0.35,
		"zombie_max_hp": 240,
		"zombie_speed": 62.0,
	}
	var translate: Callable = Callable(self, "_translate")
	assert(FORMATTER.format(CATALOG.SHARPENED_BONES, state, translate) == "damage=17")
	assert(FORMATTER.format(CATALOG.BONE_HARVEST, state, translate) == "chance=35")
	assert(FORMATTER.format(CATALOG.DEAD_WEIGHT, state, translate) == "hp=240 speed=62")
	assert(FORMATTER.format("invalid_upgrade", state, translate).is_empty())
	print("UPGRADE STATUS FORMATTER VALIDATION: PASS")
	quit()


func _translate(key: String) -> String:
	match key:
		"UPGRADE_CURRENT_SKELETON_DAMAGE":
			return "damage=%s"
		"UPGRADE_CURRENT_CHANCE":
			return "chance=%s"
		"UPGRADE_CURRENT_DEAD_WEIGHT":
			return "hp=%s speed=%s"
		_:
			return key
