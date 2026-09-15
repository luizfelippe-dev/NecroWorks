extends RefCounted


const CATALOG: Script = preload("res://scripts/game/synergy_catalog.gd")


static func format(state: Dictionary, translate: Callable) -> String:
	var active: Dictionary = state.get("active_synergies", {}) as Dictionary
	var rows: Array[Dictionary] = []
	for synergy_id: String in CATALOG.ALL_SYNERGIES:
		var progress: Dictionary = CATALOG.get_requirement_progress(synergy_id, state)
		var is_active: bool = bool(active.get(synergy_id, false))
		var is_ready: bool = int(progress.completed) == int(progress.total)
		rows.append({
			"id": synergy_id,
			"active": is_active,
			"ready": is_ready,
			"completed": int(progress.completed),
			"total": int(progress.total),
			"entries": progress.entries,
		})
	rows.sort_custom(_higher_priority)

	var lines: PackedStringArray = PackedStringArray([
		str(translate.call("SYNERGIES_OVERVIEW")) % [active.size(), CATALOG.ALL_SYNERGIES.size()]
	])
	for row: Dictionary in rows:
		var status_key: String = "SYNERGY_STATUS_ACTIVE" if row.active else (
			"SYNERGY_STATUS_READY" if row.ready else "SYNERGY_STATUS_PROGRESS"
		)
		lines.append("")
		lines.append("[%s] %s" % [
			str(translate.call(status_key)),
			str(translate.call(CATALOG.get_name_key(row.id))),
		])
		var description: String = str(translate.call(CATALOG.get_description_key(row.id)))
		var separator: int = description.find(":")
		if separator >= 0:
			description = description.substr(separator + 1).strip_edges()
		lines.append(str(translate.call("SYNERGY_EFFECT")) + ": " + description)
		var requirements: PackedStringArray = PackedStringArray()
		for requirement: Dictionary in row.entries:
			var marker: String = "[x]" if row.active or requirement.met else "[ ]"
			var value: String = ""
			if int(requirement.target) > 1:
				value = " %d/%d" % [requirement.current, requirement.target]
			requirements.append("%s %s%s" % [
				marker,
				str(translate.call(requirement.name_key)),
				value,
			])
		lines.append(str(translate.call("SYNERGY_REQUIREMENTS")) + ": " + " + ".join(requirements))
	return "\n".join(lines)


static func _higher_priority(left: Dictionary, right: Dictionary) -> bool:
	var left_rank: int = _rank(left)
	var right_rank: int = _rank(right)
	if left_rank != right_rank:
		return left_rank < right_rank
	if int(left.completed) != int(right.completed):
		return int(left.completed) > int(right.completed)
	return CATALOG.ALL_SYNERGIES.find(left.id) < CATALOG.ALL_SYNERGIES.find(right.id)


static func _rank(row: Dictionary) -> int:
	if bool(row.active):
		return 0
	if bool(row.ready):
		return 1
	return 2
