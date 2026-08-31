class_name MetaProgressionStore
extends RefCounted


const PROFILE_VERSION: int = 1
const DEFAULT_PATH: String = "user://necroworks_profile.json"
const MAX_RUN_HISTORY: int = 20


static func default_profile() -> Dictionary:
	return {
		"profile_version": PROFILE_VERSION,
		"discoveries": {},
		"unlocks": {},
		"run_history": [],
	}


static func load_profile(path: String = DEFAULT_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return default_profile()
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return default_profile()
	var parser: JSON = JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		return default_profile()
	var profile: Dictionary = parser.data as Dictionary
	if int(profile.get("profile_version", -1)) != PROFILE_VERSION:
		return default_profile()
	profile["discoveries"] = (profile.get("discoveries", {}) as Dictionary).duplicate(true)
	profile["unlocks"] = (profile.get("unlocks", {}) as Dictionary).duplicate(true)
	profile["run_history"] = (profile.get("run_history", []) as Array).duplicate(true)
	return profile


static func save_profile(
	profile: Dictionary, path: String = DEFAULT_PATH
) -> Error:
	var payload: Dictionary = profile.duplicate(true)
	payload["profile_version"] = PROFILE_VERSION
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "\t"))
	return OK


static func merge_discoveries(profile: Dictionary, discoveries: Dictionary) -> void:
	var stored: Dictionary = profile.get("discoveries", {}) as Dictionary
	for discovery_id: Variant in discoveries:
		if bool(discoveries[discovery_id]):
			stored[str(discovery_id)] = true
	profile["discoveries"] = stored


static func record_run(profile: Dictionary, summary: Dictionary) -> void:
	var history: Array = profile.get("run_history", []) as Array
	var entry: Dictionary = summary.duplicate(true)
	entry["completed_at_unix"] = int(Time.get_unix_time_from_system())
	history.push_front(entry)
	if history.size() > MAX_RUN_HISTORY:
		history.resize(MAX_RUN_HISTORY)
	profile["run_history"] = history
