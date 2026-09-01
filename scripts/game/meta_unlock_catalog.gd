class_name MetaUnlockCatalog
extends RefCounted


const AUTO_RETRIEVAL: String = "auto_retrieval"
const SKELETON_ARCHER: String = "skeleton_archer"
const SOUL_EXTRACTOR: String = "soul_extractor"
const HEMATIC_PRESS: String = "hematic_press"
const LICH: String = "lich"

const UNLOCK_IDS: Array[String] = [
	AUTO_RETRIEVAL,
	SKELETON_ARCHER,
	SOUL_EXTRACTOR,
	HEMATIC_PRESS,
	LICH,
]

const REQUIREMENT_KEYS: Dictionary = {
	AUTO_RETRIEVAL: "META_REQUIREMENT_WAVE_5",
	SKELETON_ARCHER: "META_REQUIREMENT_WAVE_10",
	SOUL_EXTRACTOR: "META_REQUIREMENT_WAVE_13",
	HEMATIC_PRESS: "META_REQUIREMENT_CORPSES_30",
	LICH: "META_REQUIREMENT_VICTORY",
}
const NAME_KEYS: Dictionary = {
	AUTO_RETRIEVAL: "FACTORY_AUTO_COLLECTION",
	SKELETON_ARCHER: "FACTORY_ARCHER_BLUEPRINT",
	SOUL_EXTRACTOR: "FACTORY_SOUL_EXTRACTOR",
	HEMATIC_PRESS: "FACTORY_HEMATIC_PRESS",
	LICH: "FACTORY_LICH_BLUEPRINT",
}


static func get_eligible_unlocks(run_history: Array) -> Array[String]:
	var eligible: Array[String] = []
	var highest_wave: int = 0
	var total_corpses: int = 0
	var has_victory: bool = false
	for entry_value: Variant in run_history:
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value as Dictionary
		highest_wave = maxi(highest_wave, int(entry.get("wave", 0)))
		total_corpses += maxi(int(entry.get("corpses_processed", 0)), 0)
		has_victory = has_victory or bool(entry.get("victory", false))
	if highest_wave >= 5:
		eligible.append(AUTO_RETRIEVAL)
	if highest_wave >= 10:
		eligible.append(SKELETON_ARCHER)
	if highest_wave >= 13:
		eligible.append(SOUL_EXTRACTOR)
	if total_corpses >= 30:
		eligible.append(HEMATIC_PRESS)
	if has_victory:
		eligible.append(LICH)
	return eligible


static func grant_eligible_unlocks(profile: Dictionary) -> Array[String]:
	var unlocked: Dictionary = profile.get("unlocks", {}) as Dictionary
	var newly_unlocked: Array[String] = []
	for unlock_id: String in get_eligible_unlocks(profile.get("run_history", []) as Array):
		if bool(unlocked.get(unlock_id, false)):
			continue
		unlocked[unlock_id] = true
		newly_unlocked.append(unlock_id)
	profile["unlocks"] = unlocked
	return newly_unlocked


static func get_requirement_key(unlock_id: String) -> String:
	return str(REQUIREMENT_KEYS.get(unlock_id, ""))


static func get_name_key(unlock_id: String) -> String:
	return str(NAME_KEYS.get(unlock_id, ""))
