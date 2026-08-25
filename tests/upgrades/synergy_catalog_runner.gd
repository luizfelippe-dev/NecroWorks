extends SceneTree


const CATALOG: Script = preload("res://scripts/game/synergy_catalog.gd")


func _initialize() -> void:
	assert(CATALOG.ALL_SYNERGIES.size() == 10)
	var unique_ids: Dictionary = {}
	for synergy_id: String in CATALOG.ALL_SYNERGIES:
		assert(not unique_ids.has(synergy_id))
		unique_ids[synergy_id] = true
		assert(CATALOG.is_known(synergy_id))
		assert(not CATALOG.get_name_key(synergy_id).is_empty())
		assert(not CATALOG.get_description_key(synergy_id).is_empty())
	assert(not CATALOG.is_known("invalid_synergy"))
	assert(CATALOG.get_name_key("invalid_synergy").is_empty())
	print("SYNERGY CATALOG VALIDATION: PASS")
	quit()
