extends SceneTree


const PROFILE_PATH: String = "user://necroworks_profile_test.json"


func _initialize() -> void:
	var profile: Dictionary = MetaProgressionStore.default_profile()
	MetaProgressionStore.merge_discoveries(profile, {
		"grave_manifest": true,
		"ignored_false_value": false,
	})
	assert(bool(profile.discoveries.grave_manifest))
	assert(not profile.discoveries.has("ignored_false_value"))
	for index: int in range(24):
		MetaProgressionStore.record_run(profile, {
			"victory": index % 2 == 0,
			"wave": index + 1,
		})
	assert((profile.run_history as Array).size() == 20)
	assert(int((profile.run_history as Array)[0].wave) == 24)
	assert(MetaProgressionStore.save_profile(profile, PROFILE_PATH) == OK)
	var loaded: Dictionary = MetaProgressionStore.load_profile(PROFILE_PATH)
	assert(bool(loaded.discoveries.grave_manifest))
	assert((loaded.run_history as Array).size() == 20)
	var legacy_path: String = "user://necroworks_profile_v1_test.json"
	var legacy_file: FileAccess = FileAccess.open(legacy_path, FileAccess.WRITE)
	legacy_file.store_string(JSON.stringify({
		"profile_version": 1,
		"discoveries": {"sealed_memories": true},
		"run_history": [{"wave": 10, "corpses_processed": 30}],
	}))
	legacy_file = null
	var migrated: Dictionary = MetaProgressionStore.load_profile(legacy_path)
	assert(int(migrated.profile_version) == MetaProgressionStore.PROFILE_VERSION)
	assert(bool(migrated.discoveries.sealed_memories))
	assert(MetaProgressionStore.is_unlocked(migrated, "skeleton_archer"))
	assert(MetaProgressionStore.is_unlocked(migrated, "hematic_press"))
	var malformed_path: String = "user://necroworks_profile_malformed_test.json"
	var malformed_file: FileAccess = FileAccess.open(malformed_path, FileAccess.WRITE)
	malformed_file.store_string(JSON.stringify({
		"profile_version": 2,
		"discoveries": "invalid",
		"unlocks": 42,
		"run_history": ["invalid", {"wave": 5}],
	}))
	malformed_file = null
	var sanitized: Dictionary = MetaProgressionStore.load_profile(malformed_path)
	assert((sanitized.discoveries as Dictionary).is_empty())
	assert((sanitized.run_history as Array).size() == 1)
	assert(MetaProgressionStore.is_unlocked(sanitized, "auto_retrieval"))
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(PROFILE_PATH)) == OK)
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(legacy_path)) == OK)
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(malformed_path)) == OK)
	print("META PROGRESSION PROFILE VALIDATION: PASS")
	quit()
