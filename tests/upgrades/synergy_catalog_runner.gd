extends SceneTree


const CATALOG: Script = preload("res://scripts/game/synergy_catalog.gd")


func _initialize() -> void:
	assert(CATALOG.ALL_SYNERGIES.size() == 10)
	var unique_ids: Dictionary = {}
	for synergy_id: String in CATALOG.ALL_SYNERGIES:
		assert(not unique_ids.has(synergy_id))
		unique_ids[synergy_id] = true
		assert(CATALOG.is_known(synergy_id))
		assert(not CATALOG.get_name_key(synergy_id).is_empty())
		assert(not CATALOG.get_description_key(synergy_id).is_empty())
		var requirements: Array[Dictionary] = CATALOG.get_requirements(synergy_id)
		assert(requirements.size() >= 2)
		for requirement: Dictionary in requirements:
			assert(not str(requirement.name_key).is_empty())
			assert(int(requirement.target) >= 1)
	assert(not CATALOG.is_known("invalid_synergy"))
	assert(CATALOG.get_name_key("invalid_synergy").is_empty())
	_validate_unlock_rules()
	print("SYNERGY CATALOG VALIDATION: PASS")
	quit()


func _validate_unlock_rules() -> void:
	var state: Dictionary = {
		"upgrade_counts": {
			CATALOG.UPGRADE_CATALOG.EFFICIENT_RECYCLING: 1,
			CATALOG.UPGRADE_CATALOG.BONE_HARVEST: 1,
			CATALOG.UPGRADE_CATALOG.MASS_PRODUCTION: 1,
			CATALOG.UPGRADE_CATALOG.HEAVY_BONES: 1,
			CATALOG.UPGRADE_CATALOG.RAPID_ASSAULT: 1,
			CATALOG.UPGRADE_CATALOG.DEATH_MARCH: 1,
		},
		"active_synergies": {},
		"skeleton_archer_unlocked": true,
	}
	var unlockable: Array[String] = CATALOG.get_unlockable_synergies(state)
	assert(CATALOG.RECYCLING_PLANT in unlockable)
	assert(CATALOG.BONE_ASSEMBLY_LINE in unlockable)
	assert(CATALOG.OVERCLOCKED_OSSUARY in unlockable)
	assert(CATALOG.OSSUARY_BALLISTICS in unlockable)
	assert(not CATALOG.CRIMSON_ASSEMBLY in unlockable)
	var ballistic_progress: Dictionary = CATALOG.get_requirement_progress(
		CATALOG.OSSUARY_BALLISTICS, state
	)
	assert(ballistic_progress.completed == 3 and ballistic_progress.total == 3)

	state["active_synergies"] = {CATALOG.RECYCLING_PLANT: true}
	state["blood_extraction_level"] = 1
	state["blood_infusion_level"] = 1
	state["soul_focus_level"] = 1
	state["soul_anchor_level"] = 1
	state["hematic_press_unlocked"] = true
	state["factory_efficiency_level"] = 2
	unlockable = CATALOG.get_unlockable_synergies(state)
	assert(not CATALOG.RECYCLING_PLANT in unlockable)
	assert(CATALOG.CRIMSON_ASSEMBLY in unlockable)
	assert(CATALOG.PHANTOM_CONDUIT in unlockable)
	assert(CATALOG.DARK_REFINERY in unlockable)
	var refinery_progress: Dictionary = CATALOG.get_requirement_progress(
		CATALOG.DARK_REFINERY, state
	)
	assert(refinery_progress.completed == 2)
	assert(refinery_progress.entries[1].current == 2)
