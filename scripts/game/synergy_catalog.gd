extends RefCounted


const UPGRADE_CATALOG: Script = preload("res://scripts/game/upgrade_catalog.gd")


const RECYCLING_PLANT: String = "recycling_plant"
const SECOND_SHIFT: String = "second_shift"
const BONE_ASSEMBLY_LINE: String = "bone_assembly_line"
const OVERCLOCKED_OSSUARY: String = "overclocked_ossuary"
const MEAT_SHIELD_PROTOCOL: String = "meat_shield_protocol"
const CRIMSON_ASSEMBLY: String = "crimson_assembly"
const PHANTOM_CONDUIT: String = "phantom_conduit"
const DARK_REFINERY: String = "dark_refinery"
const SOUL_FOUNDRY: String = "soul_foundry"
const OSSUARY_BALLISTICS: String = "ossuary_ballistics"

const ALL_SYNERGIES: Array[String] = [
	RECYCLING_PLANT,
	SECOND_SHIFT,
	BONE_ASSEMBLY_LINE,
	OVERCLOCKED_OSSUARY,
	MEAT_SHIELD_PROTOCOL,
	CRIMSON_ASSEMBLY,
	PHANTOM_CONDUIT,
	DARK_REFINERY,
	SOUL_FOUNDRY,
	OSSUARY_BALLISTICS,
]


static func is_known(synergy_id: String) -> bool:
	return synergy_id in ALL_SYNERGIES


static func get_name_key(synergy_id: String) -> String:
	return "SYNERGY_" + synergy_id.to_upper() if is_known(synergy_id) else ""


static func get_description_key(synergy_id: String) -> String:
	return (
		"SYNERGY_" + synergy_id.to_upper() + "_DESC"
		if is_known(synergy_id)
		else ""
	)


static func get_requirements(synergy_id: String) -> Array[Dictionary]:
	match synergy_id:
		RECYCLING_PLANT:
			return [_upgrade(UPGRADE_CATALOG.EFFICIENT_RECYCLING), _upgrade(UPGRADE_CATALOG.BONE_HARVEST)]
		SECOND_SHIFT:
			return [_upgrade(UPGRADE_CATALOG.REASSEMBLY), _upgrade(UPGRADE_CATALOG.FINAL_SERVICE)]
		BONE_ASSEMBLY_LINE:
			return [_upgrade(UPGRADE_CATALOG.MASS_PRODUCTION), _upgrade(UPGRADE_CATALOG.EFFICIENT_RECYCLING)]
		OVERCLOCKED_OSSUARY:
			return [_upgrade(UPGRADE_CATALOG.HEAVY_BONES), _upgrade(UPGRADE_CATALOG.RAPID_ASSAULT)]
		MEAT_SHIELD_PROTOCOL:
			return [_upgrade(UPGRADE_CATALOG.ROTTEN_BULK), _upgrade(UPGRADE_CATALOG.RAPID_ASSAULT)]
		SOUL_FOUNDRY:
			return [_upgrade(UPGRADE_CATALOG.GRAVE_CONTRACT), _upgrade(UPGRADE_CATALOG.RAPID_CONJURATION)]
		OSSUARY_BALLISTICS:
			return [
				{"kind": "flag", "id": "skeleton_archer_unlocked", "name_key": "SYNERGY_REQ_ARCHER_BLUEPRINT", "target": 1},
				_upgrade(UPGRADE_CATALOG.HEAVY_BONES),
				_upgrade(UPGRADE_CATALOG.DEATH_MARCH),
			]
		CRIMSON_ASSEMBLY:
			return [
				_level("blood_extraction_level", "SYNERGY_REQ_HEMATIC_EXTRACTION", 1),
				_level("blood_infusion_level", "SYNERGY_REQ_CRIMSON_INFUSION", 1),
			]
		PHANTOM_CONDUIT:
			return [
				_level("soul_focus_level", "SYNERGY_REQ_SPECTRAL_FOCUS", 1),
				_level("soul_anchor_level", "SYNERGY_REQ_ETHEREAL_ANCHOR", 1),
			]
		DARK_REFINERY:
			return [
				{"kind": "flag", "id": "hematic_press_unlocked", "name_key": "SYNERGY_REQ_HEMATIC_PRESS", "target": 1},
				_level("factory_efficiency_level", "SYNERGY_REQ_INDUSTRIAL_EFFICIENCY", 2),
			]
		_:
			return []


static func get_requirement_progress(synergy_id: String, state: Dictionary) -> Dictionary:
	var entries: Array[Dictionary] = []
	var completed: int = 0
	for requirement: Dictionary in get_requirements(synergy_id):
		var current: int = _requirement_value(requirement, state)
		var target: int = int(requirement.target)
		var met: bool = current >= target
		if met:
			completed += 1
		var entry: Dictionary = requirement.duplicate()
		entry["current"] = mini(current, target)
		entry["met"] = met
		entries.append(entry)
	return {"completed": completed, "total": entries.size(), "entries": entries}


static func get_unlockable_synergies(state: Dictionary) -> Array[String]:
	var active_synergies: Dictionary = state.get("active_synergies", {})
	var unlockable: Array[String] = []
	for synergy_id: String in ALL_SYNERGIES:
		var progress: Dictionary = get_requirement_progress(synergy_id, state)
		if (
			int(progress.total) > 0
			and int(progress.completed) == int(progress.total)
			and not bool(active_synergies.get(synergy_id, false))
		):
			unlockable.append(synergy_id)
	return unlockable


static func _upgrade(upgrade_id: String) -> Dictionary:
	return {"kind": "upgrade", "id": upgrade_id, "name_key": UPGRADE_CATALOG.get_name_key(upgrade_id), "target": 1}


static func _level(id: String, name_key: String, target: int) -> Dictionary:
	return {"kind": "level", "id": id, "name_key": name_key, "target": target}


static func _requirement_value(requirement: Dictionary, state: Dictionary) -> int:
	match str(requirement.kind):
		"upgrade":
			return maxi(int((state.get("upgrade_counts", {}) as Dictionary).get(requirement.id, 0)), 0)
		"flag":
			return 1 if bool(state.get(requirement.id, false)) else 0
		"level":
			return maxi(int(state.get(requirement.id, 0)), 0)
		_:
			return 0
