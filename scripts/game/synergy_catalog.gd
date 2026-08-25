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


static func get_unlockable_synergies(state: Dictionary) -> Array[String]:
	var upgrade_counts: Dictionary = state.get("upgrade_counts", {})
	var active_synergies: Dictionary = state.get("active_synergies", {})
	var candidates: Array[String] = []

	_append_when(
		candidates,
		RECYCLING_PLANT,
		_has_upgrade(upgrade_counts, UPGRADE_CATALOG.EFFICIENT_RECYCLING)
		and _has_upgrade(upgrade_counts, UPGRADE_CATALOG.BONE_HARVEST)
	)
	_append_when(
		candidates,
		SECOND_SHIFT,
		_has_upgrade(upgrade_counts, UPGRADE_CATALOG.REASSEMBLY)
		and _has_upgrade(upgrade_counts, UPGRADE_CATALOG.FINAL_SERVICE)
	)
	_append_when(
		candidates,
		BONE_ASSEMBLY_LINE,
		_has_upgrade(upgrade_counts, UPGRADE_CATALOG.MASS_PRODUCTION)
		and _has_upgrade(upgrade_counts, UPGRADE_CATALOG.EFFICIENT_RECYCLING)
	)
	_append_when(
		candidates,
		OVERCLOCKED_OSSUARY,
		_has_upgrade(upgrade_counts, UPGRADE_CATALOG.HEAVY_BONES)
		and _has_upgrade(upgrade_counts, UPGRADE_CATALOG.RAPID_ASSAULT)
	)
	_append_when(
		candidates,
		MEAT_SHIELD_PROTOCOL,
		_has_upgrade(upgrade_counts, UPGRADE_CATALOG.ROTTEN_BULK)
		and _has_upgrade(upgrade_counts, UPGRADE_CATALOG.RAPID_ASSAULT)
	)
	_append_when(
		candidates,
		SOUL_FOUNDRY,
		_has_upgrade(upgrade_counts, UPGRADE_CATALOG.GRAVE_CONTRACT)
		and _has_upgrade(upgrade_counts, UPGRADE_CATALOG.RAPID_CONJURATION)
	)
	_append_when(
		candidates,
		OSSUARY_BALLISTICS,
		bool(state.get("skeleton_archer_unlocked", false))
		and _has_upgrade(upgrade_counts, UPGRADE_CATALOG.HEAVY_BONES)
		and _has_upgrade(upgrade_counts, UPGRADE_CATALOG.DEATH_MARCH)
	)
	_append_when(
		candidates,
		CRIMSON_ASSEMBLY,
		int(state.get("blood_extraction_level", 0)) > 0
		and int(state.get("blood_infusion_level", 0)) > 0
	)
	_append_when(
		candidates,
		PHANTOM_CONDUIT,
		int(state.get("soul_focus_level", 0)) > 0
		and int(state.get("soul_anchor_level", 0)) > 0
	)
	_append_when(
		candidates,
		DARK_REFINERY,
		bool(state.get("hematic_press_unlocked", false))
		and int(state.get("factory_efficiency_level", 0)) >= 2
	)

	var unlockable: Array[String] = []
	for synergy_id: String in ALL_SYNERGIES:
		if synergy_id in candidates and not bool(active_synergies.get(synergy_id, false)):
			unlockable.append(synergy_id)
	return unlockable


static func _has_upgrade(upgrade_counts: Dictionary, upgrade_id: String) -> bool:
	return int(upgrade_counts.get(upgrade_id, 0)) > 0


static func _append_when(
	candidates: Array[String], synergy_id: String, condition: bool
) -> void:
	if condition:
		candidates.append(synergy_id)
