extends SceneTree


const GAME_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")
const META_STORE: Script = preload("res://scripts/core/meta_progression_store.gd")
const UNLOCK_CATALOG: Script = preload("res://scripts/game/meta_unlock_catalog.gd")

var profile: Dictionary = META_STORE.default_profile()
var game: Node


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	game = GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.meta_progress_reported.connect(on_meta_progress)
	game.configure_meta_progression({})
	assert(not META_STORE.is_unlocked(profile, UNLOCK_CATALOG.AUTO_RETRIEVAL))
	game.meta_progress_reported.emit({"highest_wave": 5})
	assert(META_STORE.is_unlocked(profile, UNLOCK_CATALOG.AUTO_RETRIEVAL))
	assert(game.meta_allows(UNLOCK_CATALOG.AUTO_RETRIEVAL))
	assert(game.meta_unlock_feedback_label.visible)
	assert(not game.meta_unlock_feedback_label.text.is_empty())
	game.meta_progress_reported.emit({"corpses_processed": 30})
	game.meta_progress_reported.emit({"corpses_processed": 30})
	assert(META_STORE.is_unlocked(profile, UNLOCK_CATALOG.HEMATIC_PRESS))
	assert(META_STORE.is_unlocked(profile, UNLOCK_CATALOG.PLAGUE_STEWARD))
	assert(int(profile.progress.highest_corpses_processed) == 30)
	print("LIVE META PROGRESSION VALIDATION: PASS")
	quit()


func on_meta_progress(event: Dictionary) -> void:
	META_STORE.apply_progress_event(profile, event)
	game.update_meta_unlocks(profile.get("unlocks", {}) as Dictionary)
