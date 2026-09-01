extends SceneTree


func _initialize() -> void:
	assert(CodexCatalog.DISCOVERY_IDS.size() == 10)
	var unique: Dictionary = {}
	for discovery_id: String in CodexCatalog.DISCOVERY_IDS:
		assert(not unique.has(discovery_id))
		unique[discovery_id] = true
		assert(not CodexCatalog.get_title_key(discovery_id).is_empty())
		assert(not CodexCatalog.get_body_key(discovery_id).is_empty())
	assert(CodexCatalog.get_title_key("invalid").is_empty())
	assert(CodexCatalog.REFERENCE_IDS.size() == 10)
	var profile: Dictionary = MetaProgressionStore.default_profile()
	for reference_id: String in CodexCatalog.REFERENCE_IDS:
		assert(not CodexCatalog.get_reference_title_key(reference_id).is_empty())
		assert(not CodexCatalog.get_reference_body_key(reference_id).is_empty())
	assert(CodexCatalog.is_reference_unlocked("skeleton", profile))
	assert(not CodexCatalog.is_reference_unlocked("sepulchral_marshal", profile))
	MetaProgressionStore.apply_progress_event(profile, {"highest_wave": 10})
	assert(CodexCatalog.is_reference_unlocked("sepulchral_marshal", profile))
	print("CODEX CATALOG VALIDATION: PASS")
	quit()
