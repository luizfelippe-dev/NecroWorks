extends SceneTree


const DRIVER_SCRIPT: Script = preload(
	"res://scripts/visual/unit_animation_driver.gd"
)


func _initialize() -> void:
	call_deferred("run_validation")


func run_validation() -> void:
	var host: Node2D = Node2D.new()
	var sprite: Sprite2D = Sprite2D.new()
	var idle_texture: ImageTexture = create_test_texture(Color.GREEN)
	var attack_texture: ImageTexture = create_test_texture(Color.RED)
	var transition_texture: ImageTexture = create_test_texture(Color.BLUE)
	sprite.texture = idle_texture
	var driver: Node = DRIVER_SCRIPT.new()
	root.add_child(host)
	host.add_child(sprite)
	host.add_child(driver)
	driver.call("bind", sprite)
	assert(host.get_node_or_null("FrameBlend") is Sprite2D)
	assert(driver.call("configure_state_textures", {
		"idle": idle_texture,
		"attack": attack_texture,
	}))
	assert(sprite.texture == idle_texture)
	assert(driver.call("configure_frame_sequences", {
		"move": [attack_texture, transition_texture, idle_texture],
		"attack": [attack_texture, transition_texture, attack_texture],
	}))
	assert(driver.call("play", "attack", -1.0))
	assert(str(driver.get("current_animation")) == "attack")
	assert(sprite.texture == attack_texture)
	await create_timer(0.11).timeout
	assert(sprite.texture == transition_texture)
	await create_timer(0.20).timeout
	assert(str(driver.get("current_animation")) == "idle")
	assert(sprite.texture == idle_texture)
	assert(driver.call("play", "hit"))
	await create_timer(0.2).timeout
	assert(str(driver.get("current_animation")) == "idle")
	assert(not driver.call("play", "unsupported"))
	assert(not driver.call("configure_state_textures", {"unsupported": idle_texture}))
	assert(not driver.call("configure_frame_sequences", {"idle": [idle_texture, attack_texture]}))
	assert(not driver.call("configure_frame_sequences", {"move": [idle_texture]}))
	host.free()
	print("UNIT ANIMATION CONTRACT VALIDATION: PASS")
	quit()


func create_test_texture(color: Color) -> ImageTexture:
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)
