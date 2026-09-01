class_name StartingModifierCatalog
extends RefCounted


const STANDARD: String = "standard"
const NIGHT_SHIFT: String = "night_shift"
const IRON_AUDIT: String = "iron_audit"

const MODIFIER_IDS: Array[String] = [STANDARD, NIGHT_SHIFT, IRON_AUDIT]

const DEFINITIONS: Dictionary = {
	STANDARD: {
		"name_key": "MODIFIER_STANDARD_NAME",
		"description_key": "MODIFIER_STANDARD_DESC",
		"unlock_id": "",
		"effects": {},
	},
	NIGHT_SHIFT: {
		"name_key": "MODIFIER_NIGHT_SHIFT_NAME",
		"description_key": "MODIFIER_NIGHT_SHIFT_DESC",
		"unlock_id": "modifier_night_shift",
		"effects": {"factory_points": 2, "enemy_damage": 2},
	},
	IRON_AUDIT: {
		"name_key": "MODIFIER_IRON_AUDIT_NAME",
		"description_key": "MODIFIER_IRON_AUDIT_DESC",
		"unlock_id": "modifier_iron_audit",
		"effects": {"bones": 10, "flesh": 6, "enemy_hp_percent": 12},
	},
}


static func get_definition(modifier_id: String) -> Dictionary:
	return (DEFINITIONS.get(modifier_id, DEFINITIONS[STANDARD]) as Dictionary).duplicate(true)


static func is_available(modifier_id: String, unlocks: Dictionary) -> bool:
	var unlock_id: String = str(get_definition(modifier_id).get("unlock_id", ""))
	return unlock_id.is_empty() or bool(unlocks.get(unlock_id, false))


static func get_available_ids(unlocks: Dictionary) -> Array[String]:
	var available: Array[String] = []
	for modifier_id: String in MODIFIER_IDS:
		if is_available(modifier_id, unlocks):
			available.append(modifier_id)
	return available
