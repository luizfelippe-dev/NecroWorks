extends SceneTree


const LEGACY_PATH: String = "user://necroworks_run_v1_migration_test.json"


func _initialize() -> void:
	var legacy_payload: Dictionary = {
		"save_version": 1,
		"wave": 8,
		"resources": {"bones": 41, "flesh": 12, "blood": 2, "souls": 3},
		"army": {},
		"upgrades": {},
		"factory": {"points": 4},
		"production": {},
		"metrics": {},
		"doctrine": {},
		"processing_directive": "balanced",
	}
	var file: FileAccess = FileAccess.open(LEGACY_PATH, FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify(legacy_payload))
	file = null

	var migrated: Dictionary = RunSaveStore.load_checkpoint(LEGACY_PATH)
	assert(not migrated.is_empty())
	assert(int(migrated.save_version) == 2)
	assert(int(migrated.wave) == 8)
	assert(int(migrated.resources.bones) == 41)
	assert(str(migrated.save_metadata.app_version) == "legacy-v1")
	assert(str(migrated.save_metadata.checkpoint_kind) == "between_wave")
	assert((migrated.narrative as Dictionary).has("discoveries"))
	assert((migrated.run_modifiers as Dictionary).has("faction_pressure"))
	assert((migrated.rituals as Dictionary).has("soul_anchor_level"))

	var future_payload: Dictionary = legacy_payload.duplicate(true)
	future_payload.save_version = RunSaveStore.SAVE_VERSION + 1
	assert(RunSaveStore.migrate_payload(future_payload).is_empty())
	assert(RunSaveStore.delete_checkpoint(LEGACY_PATH) == OK)
	print("RUN SAVE V1 TO V2 MIGRATION VALIDATION: PASS")
	quit()
