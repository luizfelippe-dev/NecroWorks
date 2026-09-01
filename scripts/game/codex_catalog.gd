class_name CodexCatalog
extends RefCounted


const DISCOVERY_IDS: Array[String] = [
	"concord_spy_ring", "factory_breach_codes", "grave_manifest",
	"rendering_marks", "marshal_armor_spec", "marshal_ossification",
	"sealed_memories", "collegium_tools", "auditor_resonance",
	"auditor_relay_schema",
]

const REFERENCE_IDS: Array[String] = [
	"skeleton", "zombie", "ghost", "lich", "human_warrior",
	"human_mage", "elf_ranger", "sepulchral_marshal",
	"arcane_auditor", "foreman",
]

const REFERENCE_WAVE_REQUIREMENTS: Dictionary = {
	"skeleton": 0,
	"zombie": 0,
	"human_warrior": 0,
	"human_mage": 5,
	"ghost": 7,
	"elf_ranger": 8,
	"sepulchral_marshal": 10,
	"arcane_auditor": 15,
	"lich": 20,
	"foreman": 20,
}


static func get_title_key(discovery_id: String) -> String:
	return "CODEX_" + discovery_id.to_upper() + "_TITLE" if discovery_id in DISCOVERY_IDS else ""


static func get_body_key(discovery_id: String) -> String:
	return "CODEX_" + discovery_id.to_upper() + "_BODY" if discovery_id in DISCOVERY_IDS else ""


static func get_reference_title_key(reference_id: String) -> String:
	return "CODEX_REF_" + reference_id.to_upper() + "_TITLE" if reference_id in REFERENCE_IDS else ""


static func get_reference_body_key(reference_id: String) -> String:
	return "CODEX_REF_" + reference_id.to_upper() + "_BODY" if reference_id in REFERENCE_IDS else ""


static func is_reference_unlocked(reference_id: String, profile: Dictionary) -> bool:
	var required_wave: int = int(REFERENCE_WAVE_REQUIREMENTS.get(reference_id, 99))
	return int((profile.get("progress", {}) as Dictionary).get("highest_wave", 0)) >= required_wave
