extends SceneTree


const ANALYZER: Script = preload("res://scripts/game/run_defeat_analyzer.gd")


func _initialize() -> void:
	assert(ANALYZER.analyze({"wave": 7, "zombies_built": 0}) == "no_frontline")
	assert(ANALYZER.analyze({
		"wave": 7,
		"zombies_built": 2,
		"corpses_created": 10,
		"corpses_processed": 3,
	}) == "processing_stalled")
	assert(ANALYZER.analyze({
		"wave": 7,
		"zombies_built": 2,
		"corpses_created": 8,
		"corpses_processed": 8,
		"resources": {"bones": 1, "flesh": 1, "souls": 0},
		"cheapest_recipe_cost": 5,
	}) == "production_starved")
	assert(ANALYZER.analyze({
		"wave": 7,
		"zombies_built": 2,
		"corpses_created": 8,
		"corpses_processed": 8,
		"resources": {"bones": 8},
		"cheapest_recipe_cost": 5,
	}) == "attrition")
	assert(ANALYZER.get_translation_key("no_frontline") == "RUN_DEFEAT_CAUSE_NO_FRONTLINE")
	print("RUN DEFEAT ANALYZER VALIDATION: PASS")
	quit()
