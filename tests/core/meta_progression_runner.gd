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
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(PROFILE_PATH)) == OK)
	print("META PROGRESSION PROFILE VALIDATION: PASS")
	quit()
