class_name RunSaveStore
extends RefCounted


const SAVE_VERSION: int = 2
const DEFAULT_PATH: String = "user://necroworks_run.json"
const APP_VERSION_DATA: Script = preload("res://scripts/core/app_version.gd")
const APP_VERSION: String = APP_VERSION_DATA.NUMBER
const TRANSACTION_STORE: Script = preload(
	"res://scripts/core/transactional_json_store.gd"
)
const UPGRADE_CATALOG: Script = preload("res://scripts/game/upgrade_catalog.gd")
const REQUIRED_DICTIONARIES: Array[String] = [
	"resources", "army", "upgrades", "factory", "production", "metrics",
	"doctrine", "narrative", "run_modifiers", "rituals"
]
const RESOURCE_IDS: Array[String] = ["bones", "flesh", "blood", "souls"]
const ARMY_IDS: Array[String] = [
	"skeleton_warrior", "skeleton_archer", "zombie_tank", "ghost", "lich"
]
const PROCESSING_DIRECTIVES: Array[String] = [
	"balanced", "bone_focus", "flesh_focus"
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
	if not state.get("processing_directive") is String or str(
		state.processing_directive
	) not in PROCESSING_DIRECTIVES:
		return false
	var metadata: Dictionary = state.get("save_metadata", {}) as Dictionary
	if str(metadata.get("checkpoint_kind", "")) != "between_wave":
		return false
	var resources: Dictionary = state.resources as Dictionary
	for resource_id: String in RESOURCE_IDS:
		if not _is_bounded_number(resources.get(resource_id), 0, 100000000):
			return false
	var army: Dictionary = state.army as Dictionary
	var army_total: int = 0
	for unit_id_value: Variant in army:
		var unit_id: String = str(unit_id_value)
		if unit_id not in ARMY_IDS or not _is_bounded_number(
			army[unit_id_value], 0, 36
		):
			return false
		army_total += int(army[unit_id_value])
	if army_total > 36:
		return false
	for upgrade_id_value: Variant in (state.upgrades as Dictionary):
		var upgrade_id: String = str(upgrade_id_value)
		if not UPGRADE_CATALOG.is_known(upgrade_id) or not _is_bounded_number(
			state.upgrades[upgrade_id_value], 0, 100
		):
			return false
	var production: Dictionary = state.production as Dictionary
	for queue_id: String in ["skeleton_queue", "zombie_queue"]:
		if not production.get(queue_id, []) is Array:
			return false
		if not _validate_production_queue(production.get(queue_id, []) as Array):
			return false
	if not _is_bounded_number(production.get("hematic_press_queue", 0), 0, 3):
		return false
	for metric_value: Variant in (state.metrics as Dictionary).values():
		if not _is_bounded_number(metric_value, 0, 100000000):
			return false
	return true


static func _validate_production_queue(queue: Array) -> bool:
	if queue.size() > 3:
		return false
	var queued_total: int = 0
	for order_value: Variant in queue:
		if not order_value is Dictionary:
			return false
		var order: Dictionary = order_value as Dictionary
		var unit_type: String = str(order.get("unit_type", ""))
		if unit_type not in [
			"skeleton", "skeleton_warrior", "skeleton_archer",
			"zombie", "zombie_tank",
		]:
			return false
		if not _is_bounded_number(order.get("remaining"), 1, 36):
			return false
		queued_total += int(order.remaining)
	return queued_total <= 36


static func _is_bounded_number(value: Variant, minimum: int, maximum: int) -> bool:
	if not value is int and not value is float:
		return false
	var numeric_value: float = float(value)
	return (
		not is_nan(numeric_value)
		and not is_inf(numeric_value)
		and numeric_value >= minimum
		and numeric_value <= maximum
	)


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
