extends RefCounted


const WARRIOR: Dictionary = {
	"id": "human_warrior",
	"display_name": "HUMAN WARRIOR",
	"hp_multiplier": 1.20,
	"damage_multiplier": 1.00,
	"speed_multiplier": 0.85,
	"cooldown": 0.85,
	"attack_range": 135.0,
	"color": Color(0.72, 0.20, 0.14, 1.0)
}

const MAGE: Dictionary = {
	"id": "mage",
	"display_name": "MAGE",
	"hp_multiplier": 0.72,
	"damage_multiplier": 1.40,
	"speed_multiplier": 0.75,
	"cooldown": 1.25,
	"attack_range": 340.0,
	"color": Color(0.33, 0.30, 0.82, 1.0)
}

const ELF: Dictionary = {
	"id": "elf",
	"display_name": "ELF SKIRMISHER",
	"hp_multiplier": 0.85,
	"damage_multiplier": 1.05,
	"speed_multiplier": 1.45,
	"cooldown": 0.55,
	"attack_range": 190.0,
	"color": Color(0.18, 0.67, 0.43, 1.0)
}

const FOREMAN: Dictionary = {
	"id": "foreman",
	"display_name": "THE FOREMAN",
	"hp_multiplier": 1.00,
	"damage_multiplier": 1.00,
	"speed_multiplier": 1.00,
	"cooldown": 0.70,
	"attack_range": 135.0,
	"color": Color(0.42, 0.08, 0.55, 1.0)
}


static func get_archetype(
	wave_number: int,
	spawn_index: int,
	boss_wave: int
) -> Dictionary:

	if wave_number == boss_wave:
		return FOREMAN.duplicate(true)


	if wave_number < 8:
		return WARRIOR.duplicate(true)


	if wave_number < 11:

		if spawn_index % 3 == 2:
			return MAGE.duplicate(true)


		return WARRIOR.duplicate(true)


	var rotation_index: int = spawn_index % 3


	if rotation_index == 1:
		return MAGE.duplicate(true)


	if rotation_index == 2:
		return ELF.duplicate(true)


	return WARRIOR.duplicate(true)
