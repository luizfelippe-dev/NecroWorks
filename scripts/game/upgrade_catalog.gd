extends RefCounted


const SHARPENED_BONES: String = "sharpened_bones"
const BONE_PLATING: String = "bone_plating"
const EFFICIENT_RECYCLING: String = "efficient_recycling"
const RAPID_ASSAULT: String = "rapid_assault"
const DEATH_MARCH: String = "death_march"
const MASS_PRODUCTION: String = "mass_production"
const HEAVY_BONES: String = "heavy_bones"
const BONE_HARVEST: String = "bone_harvest"
const REASSEMBLY: String = "reassembly"
const FINAL_SERVICE: String = "final_service"
const ROTTEN_BULK: String = "rotten_bulk"
const GRAVE_HUNGER: String = "grave_hunger"
const DEAD_WEIGHT: String = "dead_weight"
const CARRION_RECOVERY: String = "carrion_recovery"
const GRAVE_CONTRACT: String = "grave_contract"
const RAPID_CONJURATION: String = "rapid_conjuration"
const BOUND_SERVITUDE: String = "bound_servitude"
const EMERGENCY_RECLAMATION: String = "emergency_reclamation"
const FLETCHERS_MARK: String = "fletchers_mark"
const HOLLOW_SHAFTS: String = "hollow_shafts"
const OSSUARY_SCOPE: String = "ossuary_scope"
const STITCHED_HIDE: String = "stitched_hide"
const SEPTIC_STRIKES: String = "septic_strikes"
const GRAVE_MOMENTUM: String = "grave_momentum"
const SPECTRAL_VOLTAGE: String = "spectral_voltage"
const PHASE_CYCLE: String = "phase_cycle"
const FLESH_PRESERVATION: String = "flesh_preservation"
const SOUL_SIPHON: String = "soul_siphon"
const CRIMSON_TITHE: String = "crimson_tithe"
const FORBIDDEN_PATENT: String = "forbidden_patent"

const BASE_POOL: Array[String] = [
	SHARPENED_BONES, BONE_PLATING, EFFICIENT_RECYCLING, RAPID_ASSAULT,
	DEATH_MARCH, MASS_PRODUCTION, HEAVY_BONES, BONE_HARVEST,
	REASSEMBLY, FINAL_SERVICE, ROTTEN_BULK, GRAVE_HUNGER, DEAD_WEIGHT,
	CARRION_RECOVERY, STITCHED_HIDE, SEPTIC_STRIKES, GRAVE_MOMENTUM,
	FLESH_PRESERVATION, SOUL_SIPHON,
]
const ARCHER_POOL: Array[String] = [FLETCHERS_MARK, HOLLOW_SHAFTS, OSSUARY_SCOPE]
const GHOST_POOL: Array[String] = [SPECTRAL_VOLTAGE, PHASE_CYCLE]
const LICH_POOL: Array[String] = [GRAVE_CONTRACT, RAPID_CONJURATION, BOUND_SERVITUDE]
const RARE_UPGRADES: Array[String] = [
	EMERGENCY_RECLAMATION, CRIMSON_TITHE, FORBIDDEN_PATENT,
]
const ZOMBIE_UPGRADES: Array[String] = [
	ROTTEN_BULK, GRAVE_HUNGER, DEAD_WEIGHT, CARRION_RECOVERY,
]
const STACK_LIMITED_UPGRADES: Array[String] = [
	FLETCHERS_MARK, HOLLOW_SHAFTS, OSSUARY_SCOPE, STITCHED_HIDE,
	SEPTIC_STRIKES, GRAVE_MOMENTUM, SPECTRAL_VOLTAGE, PHASE_CYCLE,
	FLESH_PRESERVATION, SOUL_SIPHON,
]
const ALL_UPGRADES: Array[String] = [
	SHARPENED_BONES, BONE_PLATING, EFFICIENT_RECYCLING, RAPID_ASSAULT,
	DEATH_MARCH, MASS_PRODUCTION, HEAVY_BONES, BONE_HARVEST,
	REASSEMBLY, FINAL_SERVICE, ROTTEN_BULK, GRAVE_HUNGER, DEAD_WEIGHT,
	CARRION_RECOVERY, GRAVE_CONTRACT, RAPID_CONJURATION, BOUND_SERVITUDE,
	EMERGENCY_RECLAMATION, FLETCHERS_MARK, HOLLOW_SHAFTS, OSSUARY_SCOPE,
	STITCHED_HIDE, SEPTIC_STRIKES, GRAVE_MOMENTUM, SPECTRAL_VOLTAGE,
	PHASE_CYCLE, FLESH_PRESERVATION, SOUL_SIPHON, CRIMSON_TITHE,
	FORBIDDEN_PATENT,
]


static func get_available_pool(state: Dictionary) -> Array[String]:
	var counts: Dictionary = state.get("counts", {}) as Dictionary
	var pool: Array[String] = BASE_POOL.duplicate()
	var wave: int = int(state.get("wave", 1))

	if bool(state.get("archer_unlocked", false)):
		pool.append_array(ARCHER_POOL)
	if wave >= 6:
		pool.append_array(GHOST_POOL)
	if bool(state.get("lich_unlocked", false)):
		for upgrade_id: String in LICH_POOL:
			if _count(counts, upgrade_id) < 2:
				pool.append(upgrade_id)

	_append_once_at_wave(pool, counts, EMERGENCY_RECLAMATION, wave, 8)
	_append_once_at_wave(pool, counts, CRIMSON_TITHE, wave, 10)
	_append_once_at_wave(pool, counts, FORBIDDEN_PATENT, wave, 12)

	for upgrade_id: String in STACK_LIMITED_UPGRADES:
		if _count(counts, upgrade_id) >= 3:
			pool.erase(upgrade_id)

	if int(state.get("skeleton_cost", 5)) <= 1:
		pool.erase(MASS_PRODUCTION)
	if float(state.get("skeleton_cooldown", 0.7)) <= float(state.get("minimum_cooldown", 0.2)):
		pool.erase(RAPID_ASSAULT)
	if float(state.get("bone_harvest_chance", 0.0)) >= float(state.get("bone_harvest_cap", 1.0)):
		pool.erase(BONE_HARVEST)
	if float(state.get("reassembly_chance", 0.0)) >= float(state.get("reassembly_cap", 0.75)):
		pool.erase(REASSEMBLY)
	return pool


static func is_known(upgrade_id: String) -> bool:
	return upgrade_id in ALL_UPGRADES


static func is_rare(upgrade_id: String) -> bool:
	return upgrade_id in RARE_UPGRADES


static func is_zombie_upgrade(upgrade_id: String) -> bool:
	return upgrade_id in ZOMBIE_UPGRADES


static func get_name_key(upgrade_id: String) -> String:
	return "UPGRADE_" + upgrade_id.to_upper() + "_NAME" if is_known(upgrade_id) else ""


static func get_description_key(upgrade_id: String) -> String:
	return "UPGRADE_" + upgrade_id.to_upper() + "_DESC" if is_known(upgrade_id) else ""


static func _append_once_at_wave(
	pool: Array[String], counts: Dictionary, upgrade_id: String,
	wave: int, required_wave: int
) -> void:
	if wave >= required_wave and _count(counts, upgrade_id) == 0:
		pool.append(upgrade_id)


static func _count(counts: Dictionary, upgrade_id: String) -> int:
	return maxi(int(counts.get(upgrade_id, 0)), 0)
