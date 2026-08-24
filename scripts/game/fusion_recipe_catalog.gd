class_name FusionRecipeCatalog
extends RefCounted


const OSSUARY_ALLOY: String = "ossuary_alloy"
const SOULBOUND_MUSTER: String = "soulbound_muster"

const RECIPES: Dictionary = {
	OSSUARY_ALLOY: {
		"name_key": "FUSION_OSSUARY_NAME",
		"description_key": "FUSION_OSSUARY_DESC",
		"costs": {"bones": 12, "flesh": 6},
		"rewards": {"factory_points": 2},
	},
	SOULBOUND_MUSTER: {
		"name_key": "FUSION_SOULBOUND_NAME",
		"description_key": "FUSION_SOULBOUND_DESC",
		"costs": {"blood": 2, "souls": 3},
		"rewards": {"free_ghost": 1},
	},
}


static func get_recipe(recipe_id: String) -> Dictionary:
	return (RECIPES.get(recipe_id, {}) as Dictionary).duplicate(true)


static func get_recipe_ids() -> PackedStringArray:
	return PackedStringArray([OSSUARY_ALLOY, SOULBOUND_MUSTER])
