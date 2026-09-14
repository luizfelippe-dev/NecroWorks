extends RefCounted


# Read-only snapshots keep presentation independent from the running match.
static func production(state: Dictionary, translate: Callable) -> Dictionary:
	var quantity: int = state.quantity
	var blocked: bool = state.finished or quantity > int(state.capacity)
	var result: Dictionary = {
		"prefix": str(translate.call("PRODUCTION_QUANTITY")) + ": ",
		"editable": not state.finished,
	}
	for kind in ["skeleton", "archer", "zombie"]:
		var unit: Dictionary = state[kind]
		var cost: int = quantity * int(unit.cost)
		var unlocked: bool = unit.unlocked
		result[kind] = {
			"text": (
				str(translate.call(unit.title)) + " x" + str(quantity)
				+ "\n" + str(cost) + " " + str(translate.call(unit.resource))
				if unlocked else str(translate.call("PRODUCTION_ARCHER_LOCKED"))
			),
			"disabled": blocked or not unlocked or int(unit.available) < cost
				or int(unit.orders) >= int(state.max_orders),
		}
	return result


static func processing(state: Dictionary, translate: Callable) -> String:
	return (
		str(translate.call("PROCESSING_TITLE")) + "\n"
		+ str(translate.call("PROCESSING_MODE")) + ": " + str(state.directive)
		+ "  |  " + str(translate.call(
			"PROCESSING_LOCKED_WAVE" if state.locked else "PROCESSING_CHOOSE_NEXT"
		)) + "  |  " + str(translate.call("PROCESSING_CORPSES")) + ": " + str(state.corpses)
		+ "\n" + str(translate.call("PROCESSING_YIELD")) + ": +" + str(state.bones)
		+ " " + str(translate.call("RESOURCE_BONES")) + "  /  +" + str(state.flesh)
		+ " " + str(translate.call("RESOURCE_FLESH"))
		+ "\n" + str(translate.call("PROCESSOR_QUEUE")) + ": " + str(state.queued)
		+ " / " + str(state.capacity) + "  |  "
		+ str(translate.call("PROCESSOR_THROUGHPUT")) + ": " + str(state.seconds)
		+ str(translate.call("PROCESSOR_SECONDS_PER_CORPSE"))
	)


static func queue_status(counts_and_timers: Array, translate: Callable) -> String:
	return str(translate.call("PRODUCTION_QUEUE_STATUS")) % counts_and_timers
