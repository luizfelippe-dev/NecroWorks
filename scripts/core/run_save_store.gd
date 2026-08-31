class_name RunSaveStore
extends RefCounted


const SAVE_VERSION: int = 2
const DEFAULT_PATH: String = "user://necroworks_run.json"
const APP_VERSION: String = "0.4.1"


static func has_checkpoint(path: String = DEFAULT_PATH) -> bool:
	return not load_checkpoint(path).is_empty()


static func save_checkpoint(
	state: Dictionary,
	path: String = DEFAULT_PATH
) -> Error:
	if state.is_empty():
		return ERR_INVALID_DATA

	var payload: Dictionary = state.duplicate(true)
	payload["save_version"] = SAVE_VERSION
	payload["save_metadata"] = {
		"app_version": APP_VERSION,
		"checkpoint_kind": "between_wave",
		"saved_at_unix": int(Time.get_unix_time_from_system()),
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "\t"))
	return OK


static func load_checkpoint(path: String = DEFAULT_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return {}

	var state: Dictionary = migrate_payload(parsed as Dictionary)
	if state.is_empty():
		return {}
	if int(state.get("wave", 0)) < 1:
		return {}
	return state


static func migrate_payload(payload: Dictionary) -> Dictionary:
	var version: int = int(payload.get("save_version", -1))
	if version < 1 or version > SAVE_VERSION:
		return {}

	var migrated: Dictionary = payload.duplicate(true)
	while version < SAVE_VERSION:
		match version:
			1:
				migrated = _migrate_v1_to_v2(migrated)
				version = 2
			_:
				return {}

	if int(migrated.get("save_version", -1)) != SAVE_VERSION:
		return {}
	return migrated


static func _migrate_v1_to_v2(payload: Dictionary) -> Dictionary:
	var migrated: Dictionary = payload.duplicate(true)
	migrated["save_version"] = 2
	migrated["save_metadata"] = {
		"app_version": "legacy-v1",
		"checkpoint_kind": "between_wave",
		"saved_at_unix": 0,
	}
	if not migrated.has("narrative"):
		migrated["narrative"] = {
			"choices": {},
			"pending_event": "",
			"discoveries": {},
		}
	if not migrated.has("run_modifiers"):
		migrated["run_modifiers"] = {
			"enemy_damage_bonus": 0,
			"event_zombie_hp_bonus": 0,
			"event_ghost_damage_bonus": 0,
			"faction_pressure": {},
		}
	if not migrated.has("rituals"):
		migrated["rituals"] = {
			"blood_extraction_level": 0,
			"blood_infusion_level": 0,
			"soul_focus_level": 0,
			"soul_anchor_level": 0,
		}
	return migrated


static func delete_checkpoint(path: String = DEFAULT_PATH) -> Error:
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
