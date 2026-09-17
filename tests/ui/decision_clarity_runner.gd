extends SceneTree


const SYNERGY_PRESENTER: Script = preload("res://scripts/ui/synergy_status_presenter.gd")
const FLOW_PRESENTER: Script = preload("res://scripts/ui/factory_flow_presenter.gd")
const CATALOG: Script = preload("res://scripts/game/synergy_catalog.gd")
const UPGRADE: Script = preload("res://scripts/game/upgrade_catalog.gd")


func _initialize() -> void:
	var translate := func(key: String) -> String: return TranslationServer.translate(key)
	var state: Dictionary = {
		"upgrade_counts": {UPGRADE.EFFICIENT_RECYCLING: 1},
		"active_synergies": {},
	}
	for locale: String in ["pt_BR", "en", "es"]:
		TranslationServer.set_locale(locale)
		var text: String = SYNERGY_PRESENTER.format(state, translate)
		assert(text.contains("0 / 10"))
		assert(text.contains(TranslationServer.translate("SYNERGY_EFFECT")))
		assert(text.contains(TranslationServer.translate("SYNERGY_REQUIREMENTS")))
		assert(text.contains(TranslationServer.translate(
			UPGRADE.get_name_key(UPGRADE.EFFICIENT_RECYCLING)
		)))
		assert(text.contains("[x]") and text.contains("[ ]"))

	state.active_synergies = {CATALOG.RECYCLING_PLANT: true}
	var original: Dictionary = state.duplicate(true)
	var preview: String = SYNERGY_PRESENTER.upgrade_preview(UPGRADE.MASS_PRODUCTION, state, translate)
	assert(preview.contains("2/2") and preview.contains("ACTIVA"))
	assert(state == original, "Preview must not buy the upgrade or alter the match")
	assert(SYNERGY_PRESENTER.upgrade_preview(UPGRADE.EFFICIENT_RECYCLING, state, translate).is_empty())
	state.upgrade_counts[UPGRADE.BONE_HARVEST] = 1
	var prioritized: String = SYNERGY_PRESENTER.format(state, translate)
	assert(prioritized.begins_with("SINERGIAS 1 / 10"))
	assert(prioritized.find(TranslationServer.translate("SYNERGY_RECYCLING_PLANT"))
		< prioritized.find(TranslationServer.translate("SYNERGY_SECOND_SHIFT")))

	var base_flow: Dictionary = {
		"finished": false, "available_capacity": 5, "corpses": 0,
		"processor_queued": 0, "processor_capacity": 5,
		"skeleton_orders": 0, "zombie_orders": 0, "max_orders": 3,
		"auto_collection": false, "bones": 0, "flesh": 0,
		"skeleton_cost": 5, "zombie_cost": 6,
	}
	assert(FLOW_PRESENTER.status_key(base_flow) == "FACTORY_FLOW_AWAITING_CORPSE")
	base_flow.corpses = 2
	assert(FLOW_PRESENTER.status_key(base_flow) == "FACTORY_FLOW_CORPSES_WAITING")
	base_flow.processor_queued = 5
	assert(FLOW_PRESENTER.status_key(base_flow) == "FACTORY_FLOW_PROCESSOR_FULL")
	base_flow.corpses = 0
	base_flow.processor_queued = 0
	base_flow.bones = 5
	assert(FLOW_PRESENTER.status_key(base_flow) == "FACTORY_FLOW_PRODUCTION_IDLE")
	base_flow.skeleton_orders = 1
	assert(FLOW_PRESENTER.status_key(base_flow) == "FACTORY_FLOW_PRODUCING")
	base_flow.available_capacity = 0
	assert(FLOW_PRESENTER.status_key(base_flow) == "FACTORY_FLOW_ARMY_FULL")
	base_flow.preparation = true
	assert(FLOW_PRESENTER.status_key(base_flow) == "FACTORY_FLOW_PLANNING")
	base_flow.preparation = false
	base_flow.available_capacity = 5
	base_flow.skeleton_orders = 0
	base_flow.bones = 0
	base_flow.corpses = 1
	base_flow.waiting_corpses = 0
	base_flow.soul_queued = 1
	assert(FLOW_PRESENTER.status_key(base_flow) == "FACTORY_FLOW_SOULS")
	print("DECISION CLARITY VALIDATION: PASS")
	quit()
