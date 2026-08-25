extends RefCounted


const FORMATION_POLICY: Script = preload(
	"res://scripts/game/combat_formation_policy.gd"
)

var skeletons: Array[Node2D] = []
var zombies: Array[Node2D] = []
var ghosts: Array[Node2D] = []
var liches: Array[Node2D] = []
var skeleton_slots: Dictionary = {}
var zombie_slots: Dictionary = {}
var occupied_slots: Dictionary = {}


func get_total_count() -> int:
	return skeletons.size() + zombies.size() + ghosts.size() + liches.size()


func get_free_slot() -> int:
	for slot: int in range(FORMATION_POLICY.MAX_UNDEAD):
		if not occupied_slots.has(slot):
			return slot
	return -1


func reserve_slot(slot: int) -> bool:
	if slot < 0 or slot >= FORMATION_POLICY.MAX_UNDEAD:
		return false
	if occupied_slots.has(slot):
		return false
	occupied_slots[slot] = true
	return true


func release_slot(slot: int) -> void:
	occupied_slots.erase(slot)


func clear() -> void:
	skeletons.clear()
	zombies.clear()
	ghosts.clear()
	liches.clear()
	skeleton_slots.clear()
	zombie_slots.clear()
	occupied_slots.clear()
