extends SceneTree


const MetaUnlockCatalog: Script = preload("res://scripts/game/meta_unlock_catalog.gd")


func _initialize() -> void:
	var profile: Dictionary = MetaProgressionStore.default_profile()
	MetaProgressionStore.record_run(profile, {
		"wave": 10,
		"victory": false,
		"corpses_processed": 18,
	})
	assert(MetaProgressionStore.is_unlocked(profile, MetaUnlockCatalog.AUTO_RETRIEVAL))
	assert(MetaProgressionStore.is_unlocked(profile, MetaUnlockCatalog.SKELETON_ARCHER))
	assert(not MetaProgressionStore.is_unlocked(profile, MetaUnlockCatalog.SOUL_EXTRACTOR))
	assert(not MetaProgressionStore.is_unlocked(profile, MetaUnlockCatalog.HEMATIC_PRESS))
	assert(not MetaProgressionStore.is_unlocked(profile, MetaUnlockCatalog.LICH))
	MetaProgressionStore.record_run(profile, {
		"wave": 20,
		"victory": true,
		"corpses_processed": 30,
	})
	for unlock_id: String in MetaUnlockCatalog.UNLOCK_IDS:
		assert(MetaProgressionStore.is_unlocked(profile, unlock_id))
		assert(not MetaUnlockCatalog.get_requirement_key(unlock_id).is_empty())
		assert(not MetaUnlockCatalog.get_name_key(unlock_id).is_empty())
	print("META UNLOCK CATALOG VALIDATION: PASS")
	quit()
