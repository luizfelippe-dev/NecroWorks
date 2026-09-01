class_name MetaUnlockCatalog
extends RefCounted


const AUTO_RETRIEVAL: String = "auto_retrieval"
const SKELETON_ARCHER: String = "skeleton_archer"
const SOUL_EXTRACTOR: String = "soul_extractor"
const HEMATIC_PRESS: String = "hematic_press"
const LICH: String = "lich"
const OSSUARY_ENGINEER: String = "operator_ossuary_engineer"
const PLAGUE_STEWARD: String = "operator_plague_steward"
const NIGHT_SHIFT: String = "modifier_night_shift"
const IRON_AUDIT: String = "modifier_iron_audit"

const UNLOCK_IDS: Array[String] = [
	AUTO_RETRIEVAL,
	SKELETON_ARCHER,
	SOUL_EXTRACTOR,
	HEMATIC_PRESS,
	LICH,
	OSSUARY_ENGINEER,
	PLAGUE_STEWARD,
	NIGHT_SHIFT,
	IRON_AUDIT,
]

const REQUIREMENT_KEYS: Dictionary = {
	AUTO_RETRIEVAL: "META_REQUIREMENT_WAVE_5",
	SKELETON_ARCHER: "META_REQUIREMENT_WAVE_10",
	SOUL_EXTRACTOR: "META_REQUIREMENT_WAVE_13",
	HEMATIC_PRESS: "META_REQUIREMENT_CORPSES_30",
	LICH: "META_REQUIREMENT_VICTORY",
	OSSUARY_ENGINEER: "META_REQUIREMENT_WAVE_10",
	PLAGUE_STEWARD: "META_REQUIREMENT_CORPSES_30",
	NIGHT_SHIFT: "META_REQUIREMENT_WAVE_13",
	IRON_AUDIT: "META_REQUIREMENT_VICTORY",
}
const NAME_KEYS: Dictionary = {
	AUTO_RETRIEVAL: "FACTORY_AUTO_COLLECTION",
	SKELETON_ARCHER: "FACTORY_ARCHER_BLUEPRINT",
	SOUL_EXTRACTOR: "FACTORY_SOUL_EXTRACTOR",
	HEMATIC_PRESS: "FACTORY_HEMATIC_PRESS",
	LICH: "FACTORY_LICH_BLUEPRINT",
	OSSUARY_ENGINEER: "OPERATOR_OSSUARY_NAME",
	PLAGUE_STEWARD: "OPERATOR_PLAGUE_NAME",
	NIGHT_SHIFT: "MODIFIER_NIGHT_SHIFT_NAME",
	IRON_AUDIT: "MODIFIER_IRON_AUDIT_NAME",
}


static func build_progress_from_history(run_history: Array) -> Dictionary:
	var highest_wave: int = 0
	var highest_corpses: int = 0
	var victories: int = 0
	var runs_completed: int = 0
	for entry_value: Variant in run_history:
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value as Dictionary
		highest_wave = maxi(highest_wave, int(entry.get("wave", 0)))
		highest_corpses = maxi(
			highest_corpses, maxi(int(entry.get("corpses_processed", 0)), 0)
		)
		victories += 1 if bool(entry.get("victory", false)) else 0
		runs_completed += 1
	return {
		"highest_wave": highest_wave,
		"highest_corpses_processed": highest_corpses,
		"victories": victories,
		"runs_completed": runs_completed,
	}


static func get_eligible_unlocks(progress: Dictionary) -> Array[String]:
	var eligible: Array[String] = []
	var highest_wave: int = maxi(int(progress.get("highest_wave", 0)), 0)
	var highest_corpses: int = maxi(
		int(progress.get("highest_corpses_processed", 0)), 0
	)
	var has_victory: bool = int(progress.get("victories", 0)) > 0
	if highest_wave >= 5:
		eligible.append(AUTO_RETRIEVAL)
	if highest_wave >= 10:
		eligible.append(SKELETON_ARCHER)
		eligible.append(OSSUARY_ENGINEER)
	if highest_wave >= 13:
		eligible.append(SOUL_EXTRACTOR)
		eligible.append(NIGHT_SHIFT)
	if highest_corpses >= 30:
		eligible.append(HEMATIC_PRESS)
		eligible.append(PLAGUE_STEWARD)
	if has_victory:
		eligible.append(LICH)
		eligible.append(IRON_AUDIT)
	return eligible


static func grant_eligible_unlocks(profile: Dictionary) -> Array[String]:
	var unlocked: Dictionary = profile.get("unlocks", {}) as Dictionary
	var newly_unlocked: Array[String] = []
	for unlock_id: String in get_eligible_unlocks(profile.get("progress", {}) as Dictionary):
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
