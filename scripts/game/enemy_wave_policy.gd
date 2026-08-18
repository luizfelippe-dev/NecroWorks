extends RefCounted


static func get_max_simultaneous_enemies(
	wave_number: int,
	boss_wave: int
) -> int:

	if wave_number == boss_wave:
		return 1


	if wave_number >= 18:
		return 5


	if wave_number >= 14:
		return 4


	if wave_number >= 10:
		return 3


	if wave_number >= 6:
		return 2


	return 1
