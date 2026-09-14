extends SceneTree

const GAME := preload("res://scenes/world/gameplay.tscn")
const PATH := "user://necroworks_narrative_integrity_test.json"


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	RunSaveStore.delete_checkpoint(PATH)
	var game: Node = GAME.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var original: Dictionary = game.build_checkpoint_state()
	assert(RunSaveStore.save_checkpoint(original, PATH) == OK)
	original = RunSaveStore.load_checkpoint(PATH)
	assert(RunSaveStore.validate_checkpoint(original))
	var invalid_narratives: Array = [
		{"pending_event": "unknown_event"},
		{"pending_event": 5},
		{"choices": []},
		{"discoveries": []},
		{"discoveries": {"grave_manifest": "true"}},
		{"choices": {"unknown_event": "grave_bones"}},
		{"choices": {"grave_shipment": "arcanist_souls"}},
		{"choices": {"grave_shipment": "grave_bones"}, "pending_event": "grave_shipment"},
	]
	var initial_unit: Node = game.skeletons[0]
	for narrative: Dictionary in invalid_narratives:
		var invalid: Dictionary = original.duplicate(true)
		invalid.narrative = narrative
		assert(not RunSaveStore.validate_checkpoint(invalid))
		assert(not game.restore_checkpoint_state(invalid))
		assert(game.skeletons[0] == initial_unit)
		assert(not initial_unit.is_queued_for_deletion())
		assert(game.wave_in_progress)
		assert(not game.event_decision_in_progress)
		assert(RunSaveStore.save_checkpoint(invalid, PATH) == ERR_INVALID_DATA)

	# Simulate valid JSON with an invalid event, preserving a healthy backup.
	assert(RunSaveStore.save_checkpoint(original, PATH) == OK)
	var corrupt: Dictionary = original.duplicate(true)
	corrupt.narrative.pending_event = "unknown_event"
	assert(TransactionalJsonStore.save_dictionary(corrupt, PATH) == OK)
	var recovered: Dictionary = RunSaveStore.load_checkpoint(PATH)
	assert(not recovered.is_empty())
	assert(recovered.narrative.pending_event == "")
	assert(game.restore_checkpoint_state(recovered))
	assert(game.wave_in_progress)
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH + ".bak")) == OK)
	assert(RunSaveStore.load_checkpoint(PATH).is_empty())
	assert(not RunSaveStore.has_checkpoint(PATH))
	assert(FileAccess.file_exists(PATH))

	# Valid pending decisions still reopen, with rewards applied only on choice.
	var pending: Dictionary = original.duplicate(true)
	pending.wave = 7
	pending.narrative.pending_event = "grave_shipment"
	assert(RunSaveStore.validate_checkpoint(pending))
	assert(game.restore_checkpoint_state(pending))
	assert(game.event_decision_in_progress)
	assert(not game.wave_in_progress)
	assert(game.bones == original.resources.bones)
	game.select_narrative_event_choice_by_index(0)
	assert(game.wave_in_progress)
	assert(not game.event_decision_in_progress)
	assert(game.bones == original.resources.bones + 18)
	assert(game.narrative_event_choices.grave_shipment == "grave_bones")

	game.queue_free()
	await process_frame
	RunSaveStore.delete_checkpoint(PATH)
	print("NARRATIVE CHECKPOINT INTEGRITY VALIDATION: PASS")
	quit()
