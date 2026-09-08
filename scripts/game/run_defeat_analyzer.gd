class_name RunDefeatAnalyzer
extends RefCounted


const NO_FRONTLINE: String = "no_frontline"
const PROCESSING_STALLED: String = "processing_stalled"
const PRODUCTION_STARVED: String = "production_starved"
const ATTRITION: String = "attrition"


static func analyze(state: Dictionary) -> String:
	var wave: int = maxi(int(state.get("wave", 1)), 1)
	var zombies_built: int = maxi(int(state.get("zombies_built", 0)), 0)
	var corpses_created: int = maxi(int(state.get("corpses_created", 0)), 0)
	var corpses_processed: int = maxi(int(state.get("corpses_processed", 0)), 0)
	var resources: Dictionary = state.get("resources", {}) as Dictionary
	var cheapest_recipe_cost: int = maxi(
		int(state.get("cheapest_recipe_cost", 1)),
		1
	)
	var spendable_total: int = 0
	for resource_id: String in ["bones", "flesh", "souls"]:
		spendable_total += maxi(int(resources.get(resource_id, 0)), 0)

	if wave >= 4 and zombies_built == 0:
		return NO_FRONTLINE
	if corpses_created >= 4 and corpses_processed * 2 < corpses_created:
		return PROCESSING_STALLED
	if spendable_total < cheapest_recipe_cost:
		return PRODUCTION_STARVED
	return ATTRITION


static func get_translation_key(reason: String) -> String:
	match reason:
		NO_FRONTLINE:
			return "RUN_DEFEAT_CAUSE_NO_FRONTLINE"
		PROCESSING_STALLED:
			return "RUN_DEFEAT_CAUSE_PROCESSING_STALLED"
		PRODUCTION_STARVED:
			return "RUN_DEFEAT_CAUSE_PRODUCTION_STARVED"
		_:
			return "RUN_DEFEAT_CAUSE_ATTRITION"
