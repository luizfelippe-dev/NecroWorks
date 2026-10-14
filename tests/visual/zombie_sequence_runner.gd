extends SceneTree

func _initialize() -> void:
	call_deferred("validate")

func validate() -> void:
	var catalog := preload("res://scripts/visual/unit_sprite_catalog.gd")
	var sequences: Dictionary = catalog.get_animation_sequences("zombie")
	assert(sequences.move.size() == 8 and sequences.attack.size() == 3)
	for fps: int in [30, 60, 144]:
		var host := Node2D.new()
		root.add_child(host)
		var sprite := Sprite2D.new()
		sprite.texture = catalog.get_texture("zombie")
		host.add_child(sprite)
		var driver := preload("res://scripts/visual/unit_animation_driver.gd").new()
		host.add_child(driver)
		driver.bind(sprite)
		driver.set_process(false)
		driver.configure_motion(catalog.get_motion_profile("zombie"))
		driver.configure_state_textures(catalog.get_animation_textures("zombie"))
		driver.configure_frame_sequences(sequences)
		driver.play("move")
		for index: int in range(8):
			driver.gait_phase = TAU * (index + 0.1) / 8
			driver._render_pose()
			assert(sprite.texture == sequences.move[index])
			assert(sprite.material == null)
			assert(sprite.texture.get_image().get_used_rect().has_area())
		driver.gait_phase = 0
		for index: int in range(fps):
			driver.advance(1.0 / fps, Vector2((index + 1.0) * 60 / fps, 0))
		var expected: float = 60 * TAU / (0.76 * 90)
		assert(is_equal_approx(driver.gait_phase, expected))
		driver.advance(0.5, Vector2(60, 0))
		assert(is_equal_approx(driver.gait_phase, expected))
		driver.play("attack")
		assert(sprite.texture == sequences.attack[0] and sprite.material == null)
		for index: int in range(3):
			driver.action_elapsed = (index + 0.1) / 3.0 * 0.38
			driver._render_pose()
			assert(sprite.texture == sequences.attack[index])
			var frame_image := sprite.texture.get_image()
			assert(frame_image.get_used_rect().has_area())
			# Ignore imperceptible alpha residue; visible anatomy must not touch crop edges.
			for x: int in range(frame_image.get_width()):
				assert(frame_image.get_pixel(x, 0).a < 0.13)
				assert(frame_image.get_pixel(x, frame_image.get_height() - 1).a < 0.13)
			for y: int in range(frame_image.get_height()):
				assert(frame_image.get_pixel(0, y).a < 0.13)
				assert(frame_image.get_pixel(frame_image.get_width() - 1, y).a < 0.13)
		driver.play("hit")
		assert(driver.current_animation == "attack")
		driver.advance(0.5, Vector2(60, 0))
		assert(sprite.texture == catalog.ZOMBIE_IDLE and sprite.material is ShaderMaterial)
		driver.play("attack")
		driver.set_reduced_motion(true)
		assert(sprite.texture == catalog.ZOMBIE_ATTACK)
		driver.advance(0.5, Vector2(60, 0))
		assert(sprite.texture == catalog.ZOMBIE_IDLE)
		host.free()
	print("ZOMBIE SEQUENCE: PASS")
	quit()
