extends SceneTree

func _initialize() -> void:
	call_deferred("validate")

func validate() -> void:
	var catalog := preload("res://scripts/visual/unit_sprite_catalog.gd")
	var sequences: Dictionary = catalog.get_animation_sequences("skeleton")
	assert(sequences.move.size() == 8 and sequences.attack.size() == 4)
	assert(catalog.get_animation_sequences("zombie").is_empty())
	for fps: int in [30, 60, 144]:
		assert(is_equal_approx(distance_cycle(fps, 90.0), TAU / 0.56))
		assert(is_equal_approx(distance_cycle(fps, 45.0), TAU / 0.56 / 2))
	var host := Node2D.new()
	root.add_child(host)
	var sprite := Sprite2D.new()
	sprite.texture = catalog.get_texture("skeleton")
	host.add_child(sprite)
	var driver := preload("res://scripts/visual/unit_animation_driver.gd").new()
	host.add_child(driver)
	driver.bind(sprite)
	driver.set_process(false)
	driver.configure_state_textures(catalog.get_animation_textures("skeleton"))
	driver.configure_frame_sequences(sequences)
	driver.play("move")
	for index: int in range(8):
		driver.gait_phase = TAU * (index + 0.1) / 8
		driver._render_pose()
		assert(sprite.texture == sequences.move[index])
		assert(sprite.material == null)
		assert(sprite.texture.get_image().get_used_rect().has_area())
	driver.play("attack")
	assert(sprite.texture == catalog.SKELETON_ATTACK)
	driver.advance(0.12, Vector2.ZERO)
	assert(sprite.texture == sequences.attack[1])
	driver.play("hit")
	assert(driver.current_animation == "attack")
	driver.set_reduced_motion(true)
	assert(sprite.texture == catalog.SKELETON_ATTACK)
	driver.advance(0.4, Vector2.ZERO)
	assert(sprite.texture == catalog.SKELETON_IDLE)
	assert(sprite.material is ShaderMaterial)
	host.free()
	print("SKELETON SEQUENCE: PASS")
	quit()

func distance_cycle(fps: int, speed: float) -> float:
	var host := Node2D.new()
	root.add_child(host)
	var sprite := Sprite2D.new()
	var catalog := preload("res://scripts/visual/unit_sprite_catalog.gd")
	sprite.texture = catalog.get_texture("skeleton")
	host.add_child(sprite)
	var driver := preload("res://scripts/visual/unit_animation_driver.gd").new()
	host.add_child(driver)
	driver.bind(sprite)
	driver.set_process(false)
	driver.configure_frame_sequences(catalog.get_animation_sequences("skeleton"))
	for index: int in range(fps):
		driver.advance(1.0 / fps, Vector2((index + 1.0) * speed / fps, 0))
	var result: float = driver.gait_phase
	driver.advance(0.5, Vector2(speed, 0))
	assert(driver.gait_phase == result)
	driver.advance(0.1, Vector2(speed + 200, 0))
	assert(driver.gait_phase == result)
	host.free()
	return result
