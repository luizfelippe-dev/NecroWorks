extends SceneTree

const GAME := preload("res://scenes/world/gameplay.tscn")
const PATH := "user://necroworks_checkpoint_fields_test.json"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	RunSaveStore.delete_checkpoint(PATH)
	var game: Node = GAME.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	assert(RunSaveStore.save_checkpoint(game.build_checkpoint_state(), PATH) == OK)
	var valid: Dictionary = RunSaveStore.load_checkpoint(PATH)
	var original_bytes: String = FileAccess.get_file_as_string(PATH)
	var initial_unit: Node = game.skeletons[0]
	var cases: Array = [
		["factory", "points", -1], ["factory", "points", "5"],
		["factory", "queue_level", 4], ["factory", "speed_level", 0.5],
		["factory", "efficiency_level", INF], ["factory", "points", NAN],
		["factory", "auto_collection_enabled", "false"],
		["factory", "archer_unlocked", 1], ["factory", "lich_unlocked", []],
		["rituals", "blood_extraction_level", 3], ["rituals", "blood_infusion_level", -1],
		["rituals", "soul_focus_level", true], ["rituals", "soul_anchor_level", {}],
		["doctrine", "target_skeletons", 37], ["doctrine", "target_zombies", 1.5],
		["doctrine", "bones_reserve", -1], ["doctrine", "flesh_reserve", "0"],
		["doctrine", "priority", "unknown"], ["doctrine", "automation_enabled", 1],
		["doctrine", "configured", "true"],
		["run_modifiers", "enemy_damage_bonus", -1],
		["run_modifiers", "enemy_hp_percent_bonus", []],
		["run_modifiers", "event_zombie_hp_bonus", 0.5],
		["run_modifiers", "event_ghost_damage_bonus", INF],
		["run_modifiers", "faction_pressure", []],
		["run_modifiers", "faction_pressure", {"iron_concord": "1"}],
		["meta_loadout", "operator", "unknown"],
		["meta_loadout", "modifier", "unknown"],
	]
	for mutation: Array in cases:
		var invalid: Dictionary = valid.duplicate(true)
		invalid[mutation[0]][mutation[1]] = mutation[2]
		assert(not RunSaveStore.validate_checkpoint(invalid), str(mutation))
		assert(not game.restore_checkpoint_state(invalid), str(mutation))
		assert(game.skeletons[0] == initial_unit and not initial_unit.is_queued_for_deletion())
		assert(RunSaveStore.save_checkpoint(invalid, PATH) == ERR_INVALID_DATA)
		assert(FileAccess.get_file_as_string(PATH) == original_bytes)
	for section: String in ["factory", "rituals", "doctrine", "run_modifiers", "meta_loadout"]:
		var invalid: Dictionary = valid.duplicate(true)
		invalid[section] = []
		assert(not RunSaveStore.validate_checkpoint(invalid))
		assert(not game.restore_checkpoint_state(invalid))
	var over_capacity: Dictionary = valid.duplicate(true)
	over_capacity.doctrine.target_skeletons = 20
	over_capacity.doctrine.target_zombies = 20
	assert(not RunSaveStore.validate_checkpoint(over_capacity))
	for invalid_version: Variant in ["2", true, 1.5, {}, INF]:
		var invalid: Dictionary = valid.duplicate(true)
		invalid.save_version = invalid_version
		assert(RunSaveStore.migrate_payload(invalid).is_empty())
	for invalid_wave: Variant in [0, 1.5, INF, NAN]:
		var invalid: Dictionary = valid.duplicate(true)
		invalid.wave = invalid_wave
		assert(not RunSaveStore.validate_checkpoint(invalid))
	var legacy: Dictionary = valid.duplicate(true)
	for section: String in ["factory", "rituals", "doctrine", "run_modifiers", "meta_loadout"]:
		legacy[section] = {}
	assert(RunSaveStore.validate_checkpoint(legacy))
	var maximum: Dictionary = valid.duplicate(true)
	maximum.factory.queue_level = 3.0
	maximum.factory.speed_level = 3
	maximum.factory.efficiency_level = 3
	maximum.rituals.soul_anchor_level = 2
	maximum.doctrine.target_skeletons = 30
	maximum.doctrine.target_zombies = 6
	assert(RunSaveStore.validate_checkpoint(maximum))
	var preparing: Dictionary = valid.duplicate(true)
	preparing.preparation_pending = true
	assert(RunSaveStore.validate_checkpoint(preparing))
	var invalid_preparation: Dictionary = valid.duplicate(true)
	invalid_preparation.preparation_pending = 1
	assert(not RunSaveStore.validate_checkpoint(invalid_preparation))
	# Invalid main file must fall back to the healthy copy, not enter runtime.
	assert(TransactionalJsonStore.save_dictionary(over_capacity, PATH) == OK)
	assert(RunSaveStore.load_checkpoint(PATH) == valid)
	game.queue_free()
	await process_frame
	RunSaveStore.delete_checkpoint(PATH)
	print("CHECKPOINT FIELD VALIDATION: PASS")
	quit()
