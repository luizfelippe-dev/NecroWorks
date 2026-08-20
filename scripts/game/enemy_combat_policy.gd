class_name EnemyCombatPolicy
extends RefCounted


const MAGE_ARCANE_BURST_INTERVAL: int = 3
const MAGE_MAX_TARGETS: int = 3
const MAGE_SPLASH_DAMAGE_MULTIPLIER: float = 0.50
const MAGE_SUPPRESSION_DELAY: float = 0.30
const MAGE_SPLASH_RADIUS: float = 250.0

const ELF_PRECISION_INTERVAL: int = 4
const ELF_PRECISION_DAMAGE_MULTIPLIER: float = 1.35


static func is_mage_burst_attack(completed_attacks: int) -> bool:

	return (
		completed_attacks > 0
		and completed_attacks % MAGE_ARCANE_BURST_INTERVAL == 0
	)


static func is_elf_precision_attack(completed_attacks: int) -> bool:

	return (
		completed_attacks > 0
		and completed_attacks % ELF_PRECISION_INTERVAL == 0
	)


static func get_elf_role_priority(combat_role: String) -> int:

	match combat_role:
		"summoner":
			return 0
		"ranged_support":
			return 1
		"ranged_damage":
			return 2
		"melee_damage":
			return 3
		"frontline_tank":
			return 4
		_:
			return 5


static func get_precision_damage(base_damage: int) -> int:

	return maxi(
		1,
		int(ceil(float(base_damage) * ELF_PRECISION_DAMAGE_MULTIPLIER))
	)


static func get_splash_damage(base_damage: int) -> int:

	return maxi(
		1,
		int(ceil(float(base_damage) * MAGE_SPLASH_DAMAGE_MULTIPLIER))
	)
