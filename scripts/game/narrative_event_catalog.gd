class_name NarrativeEventCatalog
extends RefCounted


const GRAVE_SHIPMENT: String = "grave_shipment"
const BOUND_ARCANIST: String = "bound_arcanist"

const GRAVE_BONES: String = "grave_bones"
const GRAVE_FLESH: String = "grave_flesh"
const ARCANIST_SOULS: String = "arcanist_souls"
const ARCANIST_TOOLS: String = "arcanist_tools"

const EVENTS_BY_WAVE: Dictionary = {
	7: GRAVE_SHIPMENT,
	13: BOUND_ARCANIST,
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
}

const CHOICE_DATA: Dictionary = {
	GRAVE_BONES: {
		"label_key": "EVENT_GRAVE_BONES",
		"rewards": {"bones": 18},
	},
	GRAVE_FLESH: {
		"label_key": "EVENT_GRAVE_FLESH",
		"rewards": {"flesh": 8, "blood": 1},
	},
	ARCANIST_SOULS: {
		"label_key": "EVENT_ARCANIST_SOULS",
		"rewards": {"souls": 4},
	},
	ARCANIST_TOOLS: {
		"label_key": "EVENT_ARCANIST_TOOLS",
		"rewards": {"factory_points": 2},
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
