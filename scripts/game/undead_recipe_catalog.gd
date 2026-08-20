class_name UndeadRecipeCatalog
extends RefCounted


const SKELETON_WARRIOR: String = "skeleton_warrior"
const SKELETON_ARCHER: String = "skeleton_archer"
const ZOMBIE_TANK: String = "zombie_tank"
const GHOST: String = "ghost"
const LICH: String = "lich"
const LICH_THRALL: String = "lich_thrall"

const FAMILY_BONE: String = "bone"
const FAMILY_FLESH: String = "flesh"
const FAMILY_SOUL: String = "soul"

const ROLE_MELEE_DAMAGE: String = "melee_damage"
const ROLE_RANGED_DAMAGE: String = "ranged_damage"
const ROLE_FRONTLINE_TANK: String = "frontline_tank"
const ROLE_RANGED_SUPPORT: String = "ranged_support"
const ROLE_SUMMONER: String = "summoner"

const RECIPES: Dictionary = {
	SKELETON_WARRIOR: {
		"family": FAMILY_BONE,
		"role": ROLE_MELEE_DAMAGE,
		"resource": "bones",
		"base_cost": 5,
		"unlocked_by_default": true,
	},
	SKELETON_ARCHER: {
		"family": FAMILY_BONE,
		"role": ROLE_RANGED_DAMAGE,
		"resource": "bones",
		"base_cost": 8,
		"unlocked_by_default": false,
	},
	ZOMBIE_TANK: {
		"family": FAMILY_FLESH,
		"role": ROLE_FRONTLINE_TANK,
		"resource": "flesh",
		"base_cost": 6,
		"unlocked_by_default": true,
	},
	GHOST: {
		"family": FAMILY_SOUL,
		"role": ROLE_RANGED_SUPPORT,
		"resource": "souls",
		"base_cost": 3,
		"unlocked_by_default": false,
	},
	LICH: {
		"family": FAMILY_SOUL,
		"role": ROLE_SUMMONER,
		"resource": "souls",
		"base_cost": 8,
		"unlocked_by_default": false,
	},
	LICH_THRALL: {
		"family": FAMILY_BONE,
		"role": ROLE_MELEE_DAMAGE,
		"resource": "summon",
		"base_cost": 0,
		"unlocked_by_default": false,
	},
}


static func get_recipe(recipe_id: String) -> Dictionary:

	return RECIPES.get(recipe_id, {}).duplicate(true)


static func has_recipe(recipe_id: String) -> bool:

	return RECIPES.has(recipe_id)
