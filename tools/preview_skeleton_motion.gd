extends SceneTree

# Disposable visual lab. No shell, profile, save, or combat economy is loaded.
const CATALOG := preload("res://scripts/visual/unit_sprite_catalog.gd")
const DRIVER := preload("res://scripts/visual/unit_animation_driver.gd")
var drivers: Array[Node] = []
var sample_positions: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]
var speed := 1.0
var frozen := false
var walking := true
var reduced := false
var caption: Label

func _initialize() -> void:
	call_deferred("build")

func build() -> void:
	root.size = Vector2i(1100, 700)
	root.content_scale_size = Vector2i(1100, 700)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("111b16")
	root.add_child(background)
	caption = Label.new()
	caption.position = Vector2(30, 22)
	caption.add_theme_font_size_override("font_size", 22)
	root.add_child(caption)
	var controls := HBoxContainer.new()
	controls.position = Vector2(30, 620)
	controls.add_theme_constant_override("separation", 12)
	root.add_child(controls)
	for title: String in ["0.5x", "1x", "2x", "Pausa", "Andar / Parar", "Atacar", "Movimento reduzido"]:
		var button := Button.new()
		button.text = title
		button.custom_minimum_size = Vector2(80, 42)
		button.pressed.connect(func(): activate(title))
		controls.add_child(button)
	for index: int in range(2):
		var host := Node2D.new()
		host.position = Vector2(280 + index * 530, 335)
		root.add_child(host)
		var sprite := Sprite2D.new()
		sprite.texture = CATALOG.get_texture("skeleton")
		sprite.scale = Vector2.ONE * 300.0 / sprite.texture.get_height()
		host.add_child(sprite)
		var driver: Node = DRIVER.new()
		host.add_child(driver)
		driver.bind(sprite)
		driver.configure_state_textures(CATALOG.get_animation_textures("skeleton"))
		driver.configure_motion(CATALOG.get_motion_profile("skeleton"))
		if index == 1:
			driver.configure_frame_sequences(CATALOG.get_animation_sequences("skeleton"))
		driver.set_process(false)
		driver.previous_world_position = Vector2.ZERO
		drivers.append(driver)
		var label := Label.new()
		label.text = "V1 • deformação procedural" if index == 0 else "Piloto • quadros de animação"
		label.position = Vector2(115 + index * 530, 525)
		label.add_theme_font_size_override("font_size", 20)
		root.add_child(label)
	refresh_caption()
	if "--capture" in OS.get_cmdline_user_args():
		await create_timer(0.5).timeout
		await RenderingServer.frame_post_draw
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://artifacts/presentation"))
		root.get_texture().get_image().save_png("res://artifacts/presentation/animation_lab.png")
		quit()

func activate(action: String) -> void:
	match action:
		"0.5x": speed = 0.5
		"1x": speed = 1.0
		"2x": speed = 2.0
		"Pausa": frozen = not frozen
		"Andar / Parar": walking = not walking
		"Atacar":
			for driver: Node in drivers:
				driver.play("attack")
		"Movimento reduzido":
			reduced = not reduced
			for driver: Node in drivers:
				driver.set_reduced_motion(reduced)
	refresh_caption()

func refresh_caption() -> void:
	caption.text = "NECROWORKS — laboratório de animação\n%.1fx | %s | Sem acesso ao save" % [speed, "PAUSADO" if frozen else ("ANDANDO" if walking else "PARADO")]

func _process(delta: float) -> bool:
	if not frozen:
		for index: int in range(drivers.size()):
			if walking:
				sample_positions[index].x += 90.0 * delta * speed
			drivers[index].advance(delta * speed, sample_positions[index])
	return false
