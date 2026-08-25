extends SceneTree


const CATALOG: Script = preload("res://scripts/game/upgrade_catalog.gd")


func _initialize() -> void:
	assert(CATALOG.ALL_UPGRADES.size() == 30)
	var unique_ids: Dictionary = {}
	for upgrade_id: String in CATALOG.ALL_UPGRADES:
		assert(not unique_ids.has(upgrade_id))
		unique_ids[upgrade_id] = true
		assert(not CATALOG.get_name_key(upgrade_id).is_empty())
		assert(not CATALOG.get_description_key(upgrade_id).is_empty())

	var base_state: Dictionary = {
		"wave": 1,
		"archer_unlocked": false,
		"lich_unlocked": false,
		"counts": {},
	}
	var base_pool: Array[String] = CATALOG.get_available_pool(base_state)
	assert(CATALOG.SHARPENED_BONES in base_pool)
	assert(CATALOG.FLETCHERS_MARK not in base_pool)
	assert(CATALOG.SPECTRAL_VOLTAGE not in base_pool)
	assert(CATALOG.EMERGENCY_RECLAMATION not in base_pool)

	var advanced_state: Dictionary = base_state.duplicate(true)
	advanced_state.wave = 12
	advanced_state.archer_unlocked = true
	advanced_state.lich_unlocked = true
	var advanced_pool: Array[String] = CATALOG.get_available_pool(advanced_state)
	for expected_id: String in [
		CATALOG.FLETCHERS_MARK,
		CATALOG.SPECTRAL_VOLTAGE,
		CATALOG.GRAVE_CONTRACT,
		CATALOG.EMERGENCY_RECLAMATION,
		CATALOG.CRIMSON_TITHE,
		CATALOG.FORBIDDEN_PATENT,
	]:
		assert(expected_id in advanced_pool)

	advanced_state.counts = {
		CATALOG.FLETCHERS_MARK: 3,
		CATALOG.GRAVE_CONTRACT: 2,
		CATALOG.EMERGENCY_RECLAMATION: 1,
	}
	advanced_state.skeleton_cost = 1
	advanced_state.skeleton_cooldown = 0.2
	advanced_state.minimum_cooldown = 0.2
	var capped_pool: Array[String] = CATALOG.get_available_pool(advanced_state)
	assert(CATALOG.FLETCHERS_MARK not in capped_pool)
	assert(CATALOG.GRAVE_CONTRACT not in capped_pool)
	assert(CATALOG.EMERGENCY_RECLAMATION not in capped_pool)
	assert(CATALOG.MASS_PRODUCTION not in capped_pool)
	assert(CATALOG.RAPID_ASSAULT not in capped_pool)

	assert(CATALOG.is_rare(CATALOG.CRIMSON_TITHE))
	assert(CATALOG.is_zombie_upgrade(CATALOG.ROTTEN_BULK))
	assert(not CATALOG.is_known("invalid_upgrade"))
	print("UPGRADE CATALOG POLICY VALIDATION: PASS")
	quit()
