class_name MetaProgressionStore
extends RefCounted


const PROFILE_VERSION: int = 3
const DEFAULT_PATH: String = "user://necroworks_profile.json"
const MAX_RUN_HISTORY: int = 20
const UNLOCK_CATALOG: Script = preload("res://scripts/game/meta_unlock_catalog.gd")
const CHALLENGE_CATALOG: Script = preload("res://scripts/game/challenge_catalog.gd")
const OPERATOR_CATALOG: Script = preload("res://scripts/game/operator_catalog.gd")
const MODIFIER_CATALOG: Script = preload("res://scripts/game/starting_modifier_catalog.gd")


static func default_profile() -> Dictionary:
	return {
		"profile_version": PROFILE_VERSION,
		"discoveries": {},
		"unlocks": {},
		"run_history": [],
		"progress": {
			"highest_wave": 0,
			"highest_corpses_processed": 0,
			"victories": 0,
			"runs_completed": 0,
		},
		"completed_challenges": {},
		"selected_operator": OPERATOR_CATALOG.DIRECTOR,
		"selected_modifier": MODIFIER_CATALOG.STANDARD,
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
	var stored_version: int = int(profile.get("profile_version", 1))
	if stored_version < 1 or stored_version > PROFILE_VERSION:
		return default_profile()
	if stored_version < PROFILE_VERSION:
		profile["profile_version"] = PROFILE_VERSION
	var discoveries_value: Variant = profile.get("discoveries", {})
	var unlocks_value: Variant = profile.get("unlocks", {})
	var history_value: Variant = profile.get("run_history", [])
	profile["discoveries"] = (
		(discoveries_value as Dictionary).duplicate(true)
		if discoveries_value is Dictionary else {}
	)
	profile["unlocks"] = (
		(unlocks_value as Dictionary).duplicate(true)
		if unlocks_value is Dictionary else {}
	)
	var sanitized_history: Array = []
	if history_value is Array:
		for entry_value: Variant in history_value as Array:
			if entry_value is Dictionary:
				sanitized_history.append((entry_value as Dictionary).duplicate(true))
			if sanitized_history.size() >= MAX_RUN_HISTORY:
				break
	profile["run_history"] = sanitized_history
	var history_progress: Dictionary = UNLOCK_CATALOG.build_progress_from_history(
		sanitized_history
	)
	var progress_value: Variant = profile.get("progress", history_progress)
	var progress: Dictionary = (
		(progress_value as Dictionary).duplicate(true)
		if progress_value is Dictionary else history_progress
	)
	for metric: String in [
		"highest_wave", "highest_corpses_processed", "victories", "runs_completed"
	]:
		progress[metric] = maxi(
			int(progress.get(metric, 0)), int(history_progress.get(metric, 0))
		)
	var migrated_unlocks: Dictionary = profile.get("unlocks", {}) as Dictionary
	if bool(migrated_unlocks.get(UNLOCK_CATALOG.AUTO_RETRIEVAL, false)):
		progress["highest_wave"] = maxi(int(progress.highest_wave), 5)
	if bool(migrated_unlocks.get(UNLOCK_CATALOG.SKELETON_ARCHER, false)):
		progress["highest_wave"] = maxi(int(progress.highest_wave), 10)
	if bool(migrated_unlocks.get(UNLOCK_CATALOG.SOUL_EXTRACTOR, false)):
		progress["highest_wave"] = maxi(int(progress.highest_wave), 13)
	if bool(migrated_unlocks.get(UNLOCK_CATALOG.HEMATIC_PRESS, false)):
		progress["highest_corpses_processed"] = maxi(
			int(progress.highest_corpses_processed), 30
		)
	if bool(migrated_unlocks.get(UNLOCK_CATALOG.LICH, false)):
		progress["victories"] = maxi(int(progress.victories), 1)
	profile["progress"] = progress
	var challenges_value: Variant = profile.get("completed_challenges", {})
	profile["completed_challenges"] = (
		(challenges_value as Dictionary).duplicate(true)
		if challenges_value is Dictionary else {}
	)
	UNLOCK_CATALOG.grant_eligible_unlocks(profile)
	CHALLENGE_CATALOG.refresh_completed(profile)
	var unlocks: Dictionary = profile.get("unlocks", {}) as Dictionary
	var selected_operator: String = str(profile.get(
		"selected_operator", OPERATOR_CATALOG.DIRECTOR
	))
	if not OPERATOR_CATALOG.is_available(selected_operator, unlocks):
		selected_operator = OPERATOR_CATALOG.DIRECTOR
	profile["selected_operator"] = selected_operator
	var selected_modifier: String = str(profile.get(
		"selected_modifier", MODIFIER_CATALOG.STANDARD
	))
	if not MODIFIER_CATALOG.is_available(selected_modifier, unlocks):
		selected_modifier = MODIFIER_CATALOG.STANDARD
	profile["selected_modifier"] = selected_modifier
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
	var progress_recorded_live: bool = bool(summary.get("progress_recorded_live", false))
	var entry: Dictionary = summary.duplicate(true)
	entry.erase("progress_recorded_live")
	entry["completed_at_unix"] = int(Time.get_unix_time_from_system())
	history.push_front(entry)
	if history.size() > MAX_RUN_HISTORY:
		history.resize(MAX_RUN_HISTORY)
	profile["run_history"] = history
	var progress_event: Dictionary = {
		"highest_wave": int(summary.get("wave", 0)),
		"runs_completed_delta": 1,
		"victories_delta": (
			0 if progress_recorded_live
			else (1 if bool(summary.get("victory", false)) else 0)
		),
		"corpses_processed": int(summary.get("corpses_processed", 0)),
	}
	apply_progress_event(profile, progress_event)


static func apply_progress_event(profile: Dictionary, event: Dictionary) -> Array[String]:
	var progress: Dictionary = profile.get("progress", {}) as Dictionary
	progress["highest_wave"] = maxi(
		int(progress.get("highest_wave", 0)),
		maxi(int(event.get("highest_wave", 0)), 0)
	)
	progress["highest_corpses_processed"] = maxi(
		int(progress.get("highest_corpses_processed", 0)),
		maxi(int(event.get("corpses_processed", 0)), 0)
	)
	for metric: String in [
		"victories", "runs_completed"
	]:
		var event_key: String = metric + "_delta"
		progress[metric] = maxi(
			int(progress.get(metric, 0)) + maxi(int(event.get(event_key, 0)), 0),
			0
		)
	profile["progress"] = progress
	var newly_unlocked: Array[String] = UNLOCK_CATALOG.grant_eligible_unlocks(profile)
	CHALLENGE_CATALOG.refresh_completed(profile)
	return newly_unlocked


static func set_loadout(
	profile: Dictionary, operator_id: String, modifier_id: String
) -> bool:
	var unlocks: Dictionary = profile.get("unlocks", {}) as Dictionary
	if not OPERATOR_CATALOG.is_available(operator_id, unlocks):
		return false
	if not MODIFIER_CATALOG.is_available(modifier_id, unlocks):
		return false
	profile["selected_operator"] = operator_id
	profile["selected_modifier"] = modifier_id
	return true


static func is_unlocked(profile: Dictionary, unlock_id: String) -> bool:
	return bool((profile.get("unlocks", {}) as Dictionary).get(unlock_id, false))
