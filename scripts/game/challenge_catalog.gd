class_name ChallengeCatalog
extends RefCounted


const WAVE_FIVE: String = "wave_five"
const WAVE_TEN: String = "wave_ten"
const CORPSE_THIRTY: String = "corpse_thirty"
const WAVE_THIRTEEN: String = "wave_thirteen"
const FIRST_VICTORY: String = "first_victory"

const CHALLENGE_IDS: Array[String] = [
	WAVE_FIVE,
	WAVE_TEN,
	CORPSE_THIRTY,
	WAVE_THIRTEEN,
	FIRST_VICTORY,
]

const DEFINITIONS: Dictionary = {
	WAVE_FIVE: {"title_key": "CHALLENGE_WAVE_5", "metric": "highest_wave", "target": 5},
	WAVE_TEN: {"title_key": "CHALLENGE_WAVE_10", "metric": "highest_wave", "target": 10},
	CORPSE_THIRTY: {"title_key": "CHALLENGE_CORPSES_30", "metric": "highest_corpses_processed", "target": 30},
	WAVE_THIRTEEN: {"title_key": "CHALLENGE_WAVE_13", "metric": "highest_wave", "target": 13},
	FIRST_VICTORY: {"title_key": "CHALLENGE_VICTORY", "metric": "victories", "target": 1},
}


static func refresh_completed(profile: Dictionary) -> Array[String]:
	var progress: Dictionary = profile.get("progress", {}) as Dictionary
	var completed: Dictionary = profile.get("completed_challenges", {}) as Dictionary
	var newly_completed: Array[String] = []
	for challenge_id: String in CHALLENGE_IDS:
		var definition: Dictionary = DEFINITIONS[challenge_id] as Dictionary
		if int(progress.get(str(definition.metric), 0)) < int(definition.target):
			continue
		if not bool(completed.get(challenge_id, false)):
			completed[challenge_id] = true
			newly_completed.append(challenge_id)
	profile["completed_challenges"] = completed
	return newly_completed


static func get_progress(challenge_id: String, profile: Dictionary) -> Vector2i:
	var definition: Dictionary = DEFINITIONS.get(challenge_id, {}) as Dictionary
	var current: int = int((profile.get("progress", {}) as Dictionary).get(
		str(definition.get("metric", "")), 0
	))
	return Vector2i(current, int(definition.get("target", 1)))
