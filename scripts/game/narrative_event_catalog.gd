class_name NarrativeEventCatalog
extends RefCounted


const GRAVE_SHIPMENT: String = "grave_shipment"
const BOUND_ARCANIST: String = "bound_arcanist"
const SABOTEUR_OFFER: String = "saboteur_offer"
const MARSHAL_REMAINS: String = "marshal_remains"
const AUDITOR_CORE: String = "auditor_core"

const GRAVE_BONES: String = "grave_bones"
const GRAVE_FLESH: String = "grave_flesh"
const ARCANIST_SOULS: String = "arcanist_souls"
const ARCANIST_TOOLS: String = "arcanist_tools"
const EXPOSE_SPIES: String = "expose_spies"
const BUY_SILENCE: String = "buy_silence"
const PLATE_ZOMBIES: String = "plate_zombies"
const MILL_BONES: String = "mill_bones"
const BIND_RESONANCE: String = "bind_resonance"
const SALVAGE_RELAY: String = "salvage_relay"

const EVENTS_BY_WAVE: Dictionary = {
	4: SABOTEUR_OFFER,
	7: GRAVE_SHIPMENT,
	11: MARSHAL_REMAINS,
	13: BOUND_ARCANIST,
	16: AUDITOR_CORE,
}

const EVENT_DATA: Dictionary = {
	GRAVE_SHIPMENT: {
		"title_key": "EVENT_GRAVE_TITLE",
		"body_key": "EVENT_GRAVE_BODY",
		"choices": [GRAVE_BONES, GRAVE_FLESH],
	},
	BOUND_ARCANIST: {
		"title_key": "EVENT_ARCANIST_TITLE",
		"body_key": "EVENT_ARCANIST_BODY",
		"choices": [ARCANIST_SOULS, ARCANIST_TOOLS],
	},
	SABOTEUR_OFFER: {
		"title_key": "EVENT_SABOTEUR_TITLE",
		"body_key": "EVENT_SABOTEUR_BODY",
		"choices": [EXPOSE_SPIES, BUY_SILENCE],
	},
	MARSHAL_REMAINS: {
		"title_key": "EVENT_MARSHAL_TITLE",
		"body_key": "EVENT_MARSHAL_BODY",
		"choices": [PLATE_ZOMBIES, MILL_BONES],
	},
	AUDITOR_CORE: {
		"title_key": "EVENT_AUDITOR_TITLE",
		"body_key": "EVENT_AUDITOR_BODY",
		"choices": [BIND_RESONANCE, SALVAGE_RELAY],
	},
}

const CHOICE_DATA: Dictionary = {
	GRAVE_BONES: {
		"label_key": "EVENT_GRAVE_BONES",
		"discovery_id": "grave_manifest",
		"rewards": {"bones": 18},
	},
	GRAVE_FLESH: {
		"label_key": "EVENT_GRAVE_FLESH",
		"discovery_id": "rendering_marks",
		"rewards": {"flesh": 8, "blood": 1},
	},
	ARCANIST_SOULS: {
		"label_key": "EVENT_ARCANIST_SOULS",
		"discovery_id": "sealed_memories",
		"rewards": {"souls": 4},
	},
	ARCANIST_TOOLS: {
		"label_key": "EVENT_ARCANIST_TOOLS",
		"discovery_id": "collegium_tools",
		"rewards": {"factory_points": 2},
	},
	EXPOSE_SPIES: {
		"label_key": "EVENT_SABOTEUR_EXPOSE",
		"discovery_id": "concord_spy_ring",
		"rewards": {"bones": 12},
	},
	BUY_SILENCE: {
		"label_key": "EVENT_SABOTEUR_BRIBE",
		"discovery_id": "factory_breach_codes",
		"rewards": {
			"factory_points": 3,
			"faction_pressure": {"iron_concord": 1},
		},
	},
	PLATE_ZOMBIES: {
		"label_key": "EVENT_MARSHAL_PLATE",
		"discovery_id": "marshal_armor_spec",
		"rewards": {"zombie_hp_bonus": 40},
	},
	MILL_BONES: {
		"label_key": "EVENT_MARSHAL_MILL",
		"discovery_id": "marshal_ossification",
		"rewards": {"bones": 30},
	},
	BIND_RESONANCE: {
		"label_key": "EVENT_AUDITOR_BIND",
		"discovery_id": "auditor_resonance",
		"rewards": {"souls": 2, "ghost_damage_bonus": 4},
	},
	SALVAGE_RELAY: {
		"label_key": "EVENT_AUDITOR_SALVAGE",
		"discovery_id": "auditor_relay_schema",
		"rewards": {"factory_points": 3},
	},
}


static func get_event_id_for_wave(wave: int) -> String:
	return str(EVENTS_BY_WAVE.get(wave, ""))


static func get_event(event_id: String) -> Dictionary:
	return (EVENT_DATA.get(event_id, {}) as Dictionary).duplicate(true)


static func get_choice(choice_id: String) -> Dictionary:
	return (CHOICE_DATA.get(choice_id, {}) as Dictionary).duplicate(true)


static func is_choice_for_event(event_id: String, choice_id: String) -> bool:
	var event: Dictionary = get_event(event_id)
	return choice_id in (event.get("choices", []) as Array)
