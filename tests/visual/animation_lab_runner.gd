extends "res://tools/preview_skeleton_motion.gd"

func _initialize() -> void:
	call_deferred("validate_lab")

func validate_lab() -> void:
	await build()
	assert(drivers.size() == 2)
	assert(drivers[0].frame_sequences.is_empty())
	assert(drivers[1].frame_sequences.move.size() == 8)
	activate("0.5x")
	assert(speed == 0.5)
	_process(0.1)
	assert(is_equal_approx(sample_positions[1].x, 4.5))
	activate("Pausa")
	var phase: float = drivers[1].gait_phase
	_process(1.0)
	assert(drivers[1].gait_phase == phase)
	activate("Pausa")
	activate("Andar / Parar")
	_process(1.0)
	assert(drivers[1].current_animation == "idle")
	activate("Atacar")
	assert(drivers[1].current_animation == "attack")
	activate("Movimento reduzido")
	assert(drivers[0].reduced_motion and drivers[1].reduced_motion)
	activate("2x")
	assert(speed == 2)
	_process(1.0)
	assert(drivers[1].current_animation == "idle")
	print("ANIMATION LAB: PASS")
	quit()
