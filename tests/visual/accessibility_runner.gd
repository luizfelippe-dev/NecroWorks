extends SceneTree


const MAIN_SCENE: PackedScene = preload("res://scenes/world/gameplay.tscn")


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var game: Node = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	game.configure_accessibility({
		"reduced_motion": true,
		"high_contrast": true,
	})
	var backdrop: Node = game.get_node("IndustrialBackdrop")
	var artwork: Sprite2D = backdrop.get_node("FactoryArtwork") as Sprite2D
	var static_position: Vector2 = artwork.position
	backdrop.call("_process", 3.0)
	assert(bool(backdrop.get("reduced_motion")))
	assert(artwork.position == static_position)
	var driver: Node = game.initial_skeleton.get_node("AnimationDriver")
	assert(bool(driver.get("reduced_motion")))
	var health_bar: Node = game.initial_skeleton.get_node("HealthBar")
	assert(bool(health_bar.get("high_contrast")))
	assert(game.wave_label.get_theme_constant("outline_size") >= 5)
	game.configure_accessibility({
		"reduced_motion": false,
		"high_contrast": false,
	})
	assert(not bool(driver.get("reduced_motion")))
	assert(not bool(health_bar.get("high_contrast")))
	assert(game.wave_label.get_theme_constant("outline_size") < 5)
	game.free()
	print("ACCESSIBILITY RUNTIME VALIDATION: PASS")
	quit()
