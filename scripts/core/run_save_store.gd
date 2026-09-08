class_name RunSaveStore
extends RefCounted


const SAVE_VERSION: int = 2
const DEFAULT_PATH: String = "user://necroworks_run.json"
const APP_VERSION: String = "0.6.0-dev"
const TRANSACTION_STORE: Script = preload(
	"res://scripts/core/transactional_json_store.gd"
)
const REQUIRED_DICTIONARIES: Array[String] = [
	"resources", "army", "upgrades", "factory", "production", "metrics",
	"doctrine", "narrative", "run_modifiers", "rituals"
]


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
	if not validate_checkpoint(payload):
		return ERR_INVALID_DATA
	return TRANSACTION_STORE.save_dictionary(payload, path)


static func load_checkpoint(path: String = DEFAULT_PATH) -> Dictionary:
	for candidate: String in [path, path + TRANSACTION_STORE.BACKUP_SUFFIX]:
		var parsed: Dictionary = TRANSACTION_STORE.load_dictionary(candidate)
		if parsed.is_empty():
			continue
		var state: Dictionary = migrate_payload(parsed)
		if validate_checkpoint(state):
			return state
	return {}


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
	if not validate_checkpoint(migrated):
		return {}
	return migrated


static func validate_checkpoint(state: Dictionary) -> bool:
	if state.is_empty() or int(state.get("save_version", -1)) != SAVE_VERSION:
		return false
	var wave_value: Variant = state.get("wave")
	if not wave_value is int and not wave_value is float:
		return false
	var wave: int = int(wave_value)
	if wave < 1 or wave > 1000:
		return false
	for key: String in REQUIRED_DICTIONARIES:
		if not state.get(key) is Dictionary:
			return false
	if not state.get("processing_directive") is String:
		return false
	var metadata: Dictionary = state.get("save_metadata", {}) as Dictionary
	if str(metadata.get("checkpoint_kind", "")) != "between_wave":
		return false
	for resource_value: Variant in (state.resources as Dictionary).values():
		if int(resource_value) < 0:
			return false
	for count_value: Variant in (state.army as Dictionary).values():
		var count: int = int(count_value)
		if count < 0 or count > 1000:
			return false
	return true


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
	return TRANSACTION_STORE.delete_family(path)
