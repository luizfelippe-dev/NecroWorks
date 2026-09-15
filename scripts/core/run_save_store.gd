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
const NARRATIVE_CATALOG: Script = preload("res://scripts/game/narrative_event_catalog.gd")
const FACTORY_POLICY: Script = preload("res://scripts/factory/factory_progression_policy.gd")
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
	return load_checkpoint_with_status(path).state


static func load_checkpoint_with_status(path: String = DEFAULT_PATH) -> Dictionary:
	for candidate: String in [path, path + TRANSACTION_STORE.BACKUP_SUFFIX]:
		var parsed: Dictionary = TRANSACTION_STORE.load_dictionary(candidate)
		if parsed.is_empty():
			continue
		var state: Dictionary = migrate_payload(parsed)
		if validate_checkpoint(state):
			return {"state": state, "status": "loaded" if candidate == path else "recovered"}
	var exists: bool = FileAccess.file_exists(path) or FileAccess.file_exists(path + TRANSACTION_STORE.BACKUP_SUFFIX)
	return {"state": {}, "status": "invalid" if exists else "missing"}


static func migrate_payload(payload: Dictionary) -> Dictionary:
	if not _is_bounded_integer(payload.get("save_version"), 1, SAVE_VERSION):
		return {}
	var version: int = int(payload.save_version)
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
	if not _is_bounded_integer(state.get("save_version"), SAVE_VERSION, SAVE_VERSION):
		return false
	if not _is_bounded_integer(state.get("wave"), 1, 1000):
		return false
	for key: String in REQUIRED_DICTIONARIES:
		if not state.get(key) is Dictionary:
			return false
	if not state.get("processing_directive") is String or str(
		state.processing_directive
	) not in PROCESSING_DIRECTIVES:
		return false
	if not state.get("save_metadata", {}) is Dictionary:
		return false
	if not validate_narrative(state.narrative):
		return false
	if not validate_runtime_fields(state):
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
	if not validate_processing_routes(state):
		return false
	return true


static func validate_processing_routes(state: Dictionary) -> bool:
	if not state.has("processing_routes"):
		return true
	if not state.processing_routes is Dictionary or not state.get("metrics", {}) is Dictionary:
		return false
	if not _is_bounded_integer(state.get("metrics", {}).get("corpses_processed", 0), 0, 100000000):
		return false
	var total: int = 0
	for route: Variant in state.processing_routes:
		if route not in PROCESSING_DIRECTIVES and route != "unknown":
			return false
		if not _is_bounded_integer(state.processing_routes[route], 0, 100000000):
			return false
		total += int(state.processing_routes[route])
	return total == int(state.get("metrics", {}).get("corpses_processed", 0))


static func validate_runtime_fields(state: Dictionary) -> bool:
	# Missing optional fields keep the defaults used by older checkpoints.
	if not state.get("preparation_pending", false) is bool:
		return false
	for section: String in ["factory", "rituals", "doctrine", "run_modifiers", "meta_loadout"]:
		if not state.get(section, {}) is Dictionary:
			return false
	var factory: Dictionary = state.get("factory", {})
	if not _validate_integer_fields(factory, ["points"], 100000000):
		return false
	if not _validate_integer_fields(factory, ["queue_level", "speed_level"], FACTORY_POLICY.PROCESSOR_UPGRADE_MAX_LEVEL):
		return false
	if not _validate_integer_fields(factory, ["efficiency_level"], FACTORY_POLICY.EFFICIENCY_MAX_LEVEL):
		return false
	if not _validate_boolean_fields(factory, [
		"auto_collection_unlocked", "auto_collection_enabled", "hematic_press_unlocked",
		"soul_extractor_unlocked", "soul_routing_enabled", "archer_unlocked", "lich_unlocked",
	]):
		return false
	if not _validate_integer_fields(state.get("rituals", {}), [
		"blood_extraction_level", "blood_infusion_level", "soul_focus_level", "soul_anchor_level",
	], 2):
		return false
	var doctrine: Dictionary = state.get("doctrine", {})
	if not _validate_integer_fields(doctrine, ["target_skeletons", "target_zombies"], 36):
		return false
	if not _validate_integer_fields(doctrine, ["bones_reserve", "flesh_reserve"], 100000000):
		return false
	if not _validate_boolean_fields(doctrine, ["configured", "automation_enabled"]):
		return false
	var priority: Variant = doctrine.get("priority", ArmyDoctrinePolicy.PRIORITY_BALANCED)
	if not priority is String or not ArmyDoctrinePolicy.is_valid_configuration(
		int(doctrine.get("target_skeletons", 0)), int(doctrine.get("target_zombies", 0)),
		int(doctrine.get("bones_reserve", 0)), int(doctrine.get("flesh_reserve", 0)), priority, 36
	):
		return false
	var modifiers: Dictionary = state.get("run_modifiers", {})
	if not _validate_integer_fields(modifiers, [
		"enemy_damage_bonus", "enemy_hp_percent_bonus", "event_zombie_hp_bonus", "event_ghost_damage_bonus",
	], 100000000):
		return false
	if not modifiers.get("faction_pressure", {}) is Dictionary:
		return false
	var pressure: Dictionary = modifiers.get("faction_pressure", {})
	for faction: Variant in pressure:
		if not faction is String or not _is_bounded_integer(pressure[faction], 0, 100000000):
			return false
	var loadout: Dictionary = state.get("meta_loadout", {})
	return (
		loadout.get("operator", OperatorCatalog.DIRECTOR) in OperatorCatalog.OPERATOR_IDS
		and loadout.get("modifier", StartingModifierCatalog.STANDARD) in StartingModifierCatalog.MODIFIER_IDS
	)


static func _validate_integer_fields(section: Dictionary, keys: Array, maximum: int) -> bool:
	for key: String in keys:
		if not _is_bounded_integer(section.get(key, 0), 0, maximum):
			return false
	return true


static func _validate_boolean_fields(section: Dictionary, keys: Array) -> bool:
	for key: String in keys:
		if not section.get(key, false) is bool:
			return false
	return true


static func _is_bounded_integer(value: Variant, minimum: int, maximum: int) -> bool:
	return _is_bounded_number(value, minimum, maximum) and float(value) == floorf(float(value))


static func validate_narrative(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var narrative: Dictionary = value as Dictionary
	if not narrative.get("choices", {}) is Dictionary:
		return false
	if not narrative.get("discoveries", {}) is Dictionary:
		return false
	if not narrative.get("pending_event", "") is String:
		return false
	var choices: Dictionary = narrative.get("choices", {}) as Dictionary
	for event_id: Variant in choices:
		if not event_id is String or not choices[event_id] is String:
			return false
		var event: Dictionary = NARRATIVE_CATALOG.get_event(event_id)
		if event.is_empty() or choices[event_id] not in event.get("choices", []):
			return false
	for discovery: Variant in (narrative.get("discoveries", {}) as Dictionary).values():
		if not discovery is bool:
			return false
	var pending: String = narrative.get("pending_event", "")
	return pending.is_empty() or (
		not NARRATIVE_CATALOG.get_event(pending).is_empty()
		and not choices.has(pending)
	)


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
