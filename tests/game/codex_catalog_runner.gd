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
	print("CODEX CATALOG VALIDATION: PASS")
	quit()
