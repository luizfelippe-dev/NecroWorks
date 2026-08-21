class_name EnemyCombatPolicy
extends RefCounted


const MAGE_ARCANE_BURST_INTERVAL: int = 3
const ELITE_MAGE_ARCANE_BURST_INTERVAL: int = 2
const MAGE_MAX_TARGETS: int = 3
const MAGE_SPLASH_DAMAGE_MULTIPLIER: float = 0.50
const ELITE_MAGE_SPLASH_DAMAGE_MULTIPLIER: float = 0.65
const MAGE_SUPPRESSION_DELAY: float = 0.30
const ELITE_MAGE_SUPPRESSION_DELAY: float = 0.45
const MAGE_SPLASH_RADIUS: float = 250.0

const ELF_PRECISION_INTERVAL: int = 4
const ELITE_ELF_PRECISION_INTERVAL: int = 3
const ELF_PRECISION_DAMAGE_MULTIPLIER: float = 1.35
const ELITE_ELF_PRECISION_DAMAGE_MULTIPLIER: float = 1.50
const ELITE_WARRIOR_DAMAGE_REDUCTION: float = 0.20


static func is_mage_burst_attack(
	completed_attacks: int,
	is_elite: bool = false
) -> bool:

	var interval: int = (
		ELITE_MAGE_ARCANE_BURST_INTERVAL
		if is_elite
		else MAGE_ARCANE_BURST_INTERVAL
	)
	return (
		completed_attacks > 0
		and completed_attacks % interval == 0
	)


static func is_elf_precision_attack(
	completed_attacks: int,
	is_elite: bool = false
) -> bool:

	var interval: int = (
		ELITE_ELF_PRECISION_INTERVAL
		if is_elite
		else ELF_PRECISION_INTERVAL
	)
	return (
		completed_attacks > 0
		and completed_attacks % interval == 0
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


static func get_precision_damage(
	base_damage: int,
	is_elite: bool = false
) -> int:

	var multiplier: float = (
		ELITE_ELF_PRECISION_DAMAGE_MULTIPLIER
		if is_elite
		else ELF_PRECISION_DAMAGE_MULTIPLIER
	)
	return maxi(
		1,
		int(ceil(float(base_damage) * multiplier))
	)


static func get_splash_damage(
	base_damage: int,
	is_elite: bool = false
) -> int:

	var multiplier: float = (
		ELITE_MAGE_SPLASH_DAMAGE_MULTIPLIER
		if is_elite
		else MAGE_SPLASH_DAMAGE_MULTIPLIER
	)
	return maxi(
		1,
		int(ceil(float(base_damage) * multiplier))
	)


static func get_mage_suppression_delay(is_elite: bool = false) -> float:

	return (
		ELITE_MAGE_SUPPRESSION_DELAY
		if is_elite
		else MAGE_SUPPRESSION_DELAY
	)


static func get_incoming_damage(
	archetype_id: String,
	is_elite: bool,
	base_damage: int
) -> int:

	if base_damage <= 0:
		return 0


	if archetype_id == "human_warrior" and is_elite:
		return maxi(
			1,
			int(ceil(float(base_damage) * (1.0 - ELITE_WARRIOR_DAMAGE_REDUCTION)))
		)


	return maxi(base_damage, 0)
