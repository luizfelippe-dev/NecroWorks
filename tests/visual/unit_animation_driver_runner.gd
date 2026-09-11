extends SceneTree

const DRIVER_SCRIPT: Script = preload("res://scripts/visual/unit_animation_driver.gd")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var host := Node2D.new()
	var sprite := Sprite2D.new()
	var idle_texture := create_test_texture(Color.GREEN)
	var attack_texture := create_test_texture(Color.RED)
	sprite.texture = idle_texture
	var driver: Node = DRIVER_SCRIPT.new()
	root.add_child(host)
	host.add_child(sprite)
	host.add_child(driver)
	driver.bind(sprite)
	driver.set_process(false)
	assert(host.get_node_or_null("FrameBlend") == null)
	assert(sprite.material is ShaderMaterial)
	assert(driver.configure_state_textures({"idle": idle_texture, "attack": attack_texture}))
	assert(driver.play("move"))
	driver.advance(0.05, Vector2(4.5, 0))
	var elapsed: float = driver.action_elapsed
	var phase: float = driver.gait_phase
	assert(driver.play("move"))
	assert(is_equal_approx(driver.action_elapsed, elapsed))
	assert(is_equal_approx(driver.gait_phase, phase))
	for index: int in range(120):
		driver.play("move")
		driver.advance(1.0 / 60.0, Vector2(6.0 + index * 1.5, 0))
		assert(driver.current_animation == "move")
	assert(driver.gait_phase > phase + TAU)
	assert(driver.play("attack", -1.0))
	assert(sprite.texture == attack_texture)
	driver.advance(0.08, Vector2(184.5, 0))
	elapsed = driver.action_elapsed
	assert(driver.play("hit"))
	assert(driver.current_animation == "attack")
	assert(is_equal_approx(driver.action_elapsed, elapsed))
	driver.advance(0.03, Vector2(184.5, 0))
	assert(sprite.modulate != driver.base_modulate)
	driver.advance(0.25, Vector2(184.5, 0))
	assert(driver.current_animation == "idle")
	assert(sprite.texture == idle_texture)
	assert(driver.play("hit"))
	driver.advance(0.2, Vector2(184.5, 0))
	assert(driver.current_animation == "idle")
	assert(not driver.play("unsupported"))
	assert(not driver.configure_state_textures({"unsupported": idle_texture}))
	assert(not driver.configure_frame_sequences({"idle": [idle_texture, attack_texture]}))
	assert(not driver.configure_frame_sequences({"move": [idle_texture]}))
	# The optional sequence contract remains usable for future genuinely authored sheets.
	assert(driver.configure_frame_sequences({"attack": [attack_texture, idle_texture, attack_texture]}))
	driver.play("attack")
	driver.advance(0.12, Vector2(184.5, 0))
	assert(sprite.texture == idle_texture)
	driver.advance(0.3, Vector2(184.5, 0))
	driver.configure_frame_sequences({})
	var completed: Array[String] = []
	driver.animation_finished.connect(func(state: String): completed.append(state))
	driver.play("death")
	driver.advance(0.23, Vector2(184.5, 0))
	assert(sprite.modulate.a == 0.0)
	assert(not driver.play("hit"))
	assert(not driver.play("move"))
	driver.set_reduced_motion(true)
	driver.set_reduced_motion(false)
	assert(driver.current_animation == "death")
	assert(sprite.modulate.a == 0.0)
	assert(completed == ["death"])
	host.free()
	var phase_30 := simulate_gait(30)
	assert(is_equal_approx(phase_30, simulate_gait(60)))
	assert(is_equal_approx(phase_30, simulate_gait(144)))
	print("UNIT ANIMATION CONTRACT VALIDATION: PASS")
	quit()


func simulate_gait(fps: int) -> float:
	var host := Node2D.new()
	var sprite := Sprite2D.new()
	sprite.texture = create_test_texture(Color.WHITE)
	var driver: Node = DRIVER_SCRIPT.new()
	root.add_child(host)
	host.add_child(sprite)
	host.add_child(driver)
	driver.bind(sprite)
	driver.set_process(false)
	for index: int in range(fps):
		driver.advance(1.0 / fps, Vector2((index + 1.0) * 90.0 / fps, 0))
	var phase: float = driver.gait_phase
	driver.set_reduced_motion(true)
	assert(sprite.position == driver.base_position)
	assert(sprite.rotation == 0.0)
	assert(float(driver.motion_material.get_shader_parameter("movement")) == 0.0)
	driver.play("death")
	driver.set_reduced_motion(false)
	assert(sprite.modulate.a == 0.0)
	host.free()
	return phase


func create_test_texture(color: Color) -> ImageTexture:
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)
