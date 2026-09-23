extends RefCounted

var elapsed: float = 0.0
var combat_seconds: float = 0.0
var idle_seconds: float = 0.0
var first_events: Dictionary = {}
var previous: Dictionary = {}
var losses: int = 0

func observe(state: Dictionary, delta: float) -> void:
	if previous.is_empty():
		previous = state.duplicate(true)
		return
	if bool(state.get("finished", false)):
		delta = 0.0
	elapsed += maxf(delta, 0.0)
	if not bool(state.get("planning", false)):
		combat_seconds += maxf(delta, 0.0)
		if bool(state.get("idle", false)):
			idle_seconds += maxf(delta, 0.0)
	for key: String in ["orders", "upgrades", "directive", "automation"]:
		if state.get(key) != previous.get(key) and not first_events.has(key):
			first_events[key] = elapsed
	losses += maxi(int(state.get("losses", 0)) - int(previous.get("losses", 0)), 0)
	previous = state.duplicate(true)

func report() -> Dictionary:
	return {
		"scope": "current_session_segment", "seconds_excluding_pause": elapsed,
		"combat_seconds": combat_seconds, "production_idle_seconds": idle_seconds,
		"first_observed_changes": first_events.duplicate(true), "units_lost": losses,
	}
