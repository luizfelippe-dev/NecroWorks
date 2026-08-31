class_name CodexCatalog
extends RefCounted


const DISCOVERY_IDS: Array[String] = [
	"concord_spy_ring", "factory_breach_codes", "grave_manifest",
	"rendering_marks", "marshal_armor_spec", "marshal_ossification",
	"sealed_memories", "collegium_tools", "auditor_resonance",
	"auditor_relay_schema",
]


static func get_title_key(discovery_id: String) -> String:
	return "CODEX_" + discovery_id.to_upper() + "_TITLE" if discovery_id in DISCOVERY_IDS else ""


static func get_body_key(discovery_id: String) -> String:
	return "CODEX_" + discovery_id.to_upper() + "_BODY" if discovery_id in DISCOVERY_IDS else ""
