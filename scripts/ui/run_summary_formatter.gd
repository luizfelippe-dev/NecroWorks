extends RefCounted


static func build_statistics(translate: Callable, state: Dictionary) -> String:
	var lines: PackedStringArray = [
		_t(translate, "RUN_STATISTICS"),
		"",
		_t(translate, "RUN_PROGRESS"),
		_value_line(translate, "RUN_WAVE_REACHED", state.get("wave", 1)),
		_value_line(translate, "METRICS_ENEMIES_KILLED", state.get("enemies_killed", 0)),
		_value_line(translate, "METRICS_CORPSES_PROCESSED", state.get("corpses_processed", 0)),
		_value_line(translate, "RUN_CORPSES_REMAINING", state.get("corpses_remaining", 0)),
		"",
		_t(translate, "RUN_UNDEAD_PRODUCTION"),
		_value_line(translate, "METRICS_SKELETONS_BUILT", state.get("skeletons_built", 0)),
		_value_line(translate, "METRICS_SKELETONS_LOST", state.get("skeletons_lost", 0)),
		_value_line(translate, "RUN_SKELETONS_REVIVED", state.get("skeletons_revived", 0)),
		_value_line(translate, "METRICS_ZOMBIES_BUILT", state.get("zombies_built", 0)),
		_value_line(translate, "METRICS_ZOMBIES_LOST", state.get("zombies_lost", 0)),
		_value_line(translate, "METRICS_GHOSTS_BUILT", state.get("ghosts_built", 0)),
		_value_line(translate, "METRICS_GHOSTS_LOST", state.get("ghosts_lost", 0)),
		_value_line(translate, "METRICS_LICHES_BUILT", state.get("liches_built", 0)),
		_value_line(translate, "METRICS_LICHES_LOST", state.get("liches_lost", 0)),
		_value_line(translate, "RUN_THRALLS_SUMMONED", state.get("thralls_summoned", 0)),
		_value_line(translate, "RUN_THRALLS_EXPIRED", state.get("thralls_expired", 0)),
		"",
		_t(translate, "RUN_ECONOMY"),
		_resource_line(translate, "RESOURCE_BONES", "RUN_EARNED", state.get("bones_earned", 0)),
		_resource_line(translate, "RESOURCE_FLESH", "RUN_EARNED", state.get("flesh_earned", 0)),
		_resource_line(translate, "RESOURCE_BLOOD", "RUN_EARNED", state.get("blood_earned", 0)),
		_resource_line(translate, "RESOURCE_SOULS", "RUN_EARNED", state.get("souls_earned", 0)),
		_resource_line(translate, "RESOURCE_BONES", "RUN_REMAINING", state.get("bones", 0)),
		_resource_line(translate, "RESOURCE_FLESH", "RUN_REMAINING", state.get("flesh", 0)),
		_resource_line(translate, "RESOURCE_BLOOD", "RUN_REMAINING", state.get("blood", 0)),
		_resource_line(translate, "RESOURCE_SOULS", "RUN_REMAINING", state.get("souls", 0)),
	]
	return "\n".join(lines)


static func build_build_summary(translate: Callable, state: Dictionary) -> String:
	var lines: PackedStringArray = [
		_t(translate, "RUN_BUILD_SUMMARY"),
		"",
		_value_line(translate, "RUN_ARMY_REMAINING", state.get("army_remaining", 0)),
		_value_line(translate, "RUN_UPGRADES_SELECTED", state.get("upgrades_selected", 0)),
		_value_line(translate, "RUN_SYNERGIES_UNLOCKED", state.get("synergies_unlocked", 0)),
		"",
		_t(translate, "RUN_PROCESSING_ROUTES"),
		_value_line(translate, "PROCESSING_BALANCED", state.get("balanced_processed", 0)),
		_value_line(translate, "PROCESSING_BONE_FOCUS", state.get("bone_processed", 0)),
		_value_line(translate, "PROCESSING_FLESH_FOCUS", state.get("flesh_processed", 0)),
		"",
		str(state.get("synergy_summary", "")),
		"",
		_t(translate, "RUN_OPERATION_STATUS"),
		str(state.get("result_message", "")),
	]
	var defeat_analysis: String = str(state.get("defeat_analysis", ""))
	if not defeat_analysis.is_empty():
		lines.append("")
		lines.append(_t(translate, "RUN_DEFEAT_DIAGNOSIS"))
		lines.append(defeat_analysis)
	return "\n".join(lines)


static func _value_line(translate: Callable, key: String, value: Variant) -> String:
	return _t(translate, key) + ": " + str(value)


static func _resource_line(
	translate: Callable,
	resource_key: String,
	state_key: String,
	value: Variant
) -> String:
	return (
		_t(translate, resource_key)
		+ " " + _t(translate, state_key)
		+ ": " + str(value)
	)


static func _t(translate: Callable, key: String) -> String:
	return str(translate.call(key))
