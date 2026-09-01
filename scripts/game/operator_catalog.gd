class_name OperatorCatalog
extends RefCounted


const DIRECTOR: String = "director"
const OSSUARY_ENGINEER: String = "ossuary_engineer"
const PLAGUE_STEWARD: String = "plague_steward"

const OPERATOR_IDS: Array[String] = [
	DIRECTOR,
	OSSUARY_ENGINEER,
	PLAGUE_STEWARD,
]

const DEFINITIONS: Dictionary = {
	DIRECTOR: {
		"name_key": "OPERATOR_DIRECTOR_NAME",
		"description_key": "OPERATOR_DIRECTOR_DESC",
		"unlock_id": "",
		"effects": {},
	},
	OSSUARY_ENGINEER: {
		"name_key": "OPERATOR_OSSUARY_NAME",
		"description_key": "OPERATOR_OSSUARY_DESC",
		"unlock_id": "operator_ossuary_engineer",
		"effects": {"bones": 5, "skeleton_cost": -1, "zombie_cost": 1},
	},
	PLAGUE_STEWARD: {
		"name_key": "OPERATOR_PLAGUE_NAME",
		"description_key": "OPERATOR_PLAGUE_DESC",
		"unlock_id": "operator_plague_steward",
		"effects": {"flesh": 6, "zombie_hp": 30, "skeleton_cost": 1},
	},
}


static func get_definition(operator_id: String) -> Dictionary:
	return (DEFINITIONS.get(operator_id, DEFINITIONS[DIRECTOR]) as Dictionary).duplicate(true)


static func is_available(operator_id: String, unlocks: Dictionary) -> bool:
	var unlock_id: String = str(get_definition(operator_id).get("unlock_id", ""))
	return unlock_id.is_empty() or bool(unlocks.get(unlock_id, false))


static func get_available_ids(unlocks: Dictionary) -> Array[String]:
	var available: Array[String] = []
	for operator_id: String in OPERATOR_IDS:
		if is_available(operator_id, unlocks):
			available.append(operator_id)
	return available
