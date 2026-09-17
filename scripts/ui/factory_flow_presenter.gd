extends RefCounted


static func status_key(state: Dictionary) -> String:
	if bool(state.get("finished", false)):
		return "FACTORY_FLOW_PAUSED"
	if bool(state.get("preparation", false)):
		return "FACTORY_FLOW_PLANNING"
	if int(state.get("available_capacity", 0)) <= 0:
		return "FACTORY_FLOW_ARMY_FULL"
	if (
		int(state.get("waiting_corpses", state.get("corpses", 0))) > 0
		and int(state.get("processor_queued", 0)) >= int(state.get("processor_capacity", 1))
	):
		return "FACTORY_FLOW_PROCESSOR_FULL"
	if (
		int(state.get("skeleton_orders", 0)) >= int(state.get("max_orders", 1))
		and int(state.get("zombie_orders", 0)) >= int(state.get("max_orders", 1))
	):
		return "FACTORY_FLOW_PRODUCTION_FULL"
	if (
		int(state.get("waiting_corpses", state.get("corpses", 0))) > 0
		and int(state.get("processor_queued", 0)) == 0
		and not bool(state.get("auto_collection", false))
	):
		return "FACTORY_FLOW_CORPSES_WAITING"
	if (
		int(state.get("skeleton_orders", 0)) == 0
		and int(state.get("zombie_orders", 0)) == 0
		and (
			int(state.get("bones", 0)) >= int(state.get("skeleton_cost", 1))
			or int(state.get("flesh", 0)) >= int(state.get("zombie_cost", 1))
		)
	):
		return "FACTORY_FLOW_PRODUCTION_IDLE"
	if int(state.get("processor_queued", 0)) > 0:
		return "FACTORY_FLOW_PROCESSING"
	if int(state.get("soul_queued", 0)) > 0:
		return "FACTORY_FLOW_SOULS"
	if int(state.get("skeleton_orders", 0)) > 0 or int(state.get("zombie_orders", 0)) > 0:
		return "FACTORY_FLOW_PRODUCING"
	if int(state.get("corpses", 0)) == 0:
		return "FACTORY_FLOW_AWAITING_CORPSE"
	return "FACTORY_FLOW_STABLE"


static func format(state: Dictionary, translate: Callable) -> String:
	return str(translate.call("FACTORY_FLOW_LABEL")) + ": " + str(
		translate.call(status_key(state))
	)
